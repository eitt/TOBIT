# R/06_generate_report.R
# Purpose: Dynamically generate a full scientific manuscript (Markdown, LaTeX, PDF, Word)
# incorporating theoretical foundations, bivariate stats, power analysis, 
# dynamic NLP coefficient interpretations, and normality tests.
# Execution Order: 7

source("R/00_config.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/io_functions.R")
source("R/utils/power_functions.R")
source("R/utils/table_functions.R")
source("R/utils/narrative_functions.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
source("R/utils/figure_functions.R")
source("R/utils/significance_figure_functions.R")
source("R/utils/nl_generation.R")
paths <- get_project_paths()
figure_radar_file <- get_standard_figure_filename("radar")
figure_severity_panels_file <- get_standard_figure_filename("severity_panels")
figure_victim_case_panels_file <- get_standard_figure_filename("victim_case_panels")
figure_bystander_case_panels_file <- get_standard_figure_filename("bystander_case_panels")
figure_accepted_case_panels_file <- get_standard_figure_filename("accepted_case_panels")
figure_rejected_case_panels_file <- get_standard_figure_filename("rejected_case_panels")
figure_bivariate_scatters_file <- get_standard_figure_filename("bivariate_scatters")
case_examples_latex <- paste(get_case_configuration_example_labels(latex = TRUE), collapse = ", ")
configured_clad_bootstrap_reps <- resolve_clad_bootstrap_reps()
report_hypothesis_specs <- get_hypothesis_family_specs(paths = paths)
report_h1_spec <- get_hypothesis_spec("H1", paths = paths)
report_h2_spec <- get_hypothesis_spec("H2", paths = paths)
report_h3_spec <- get_hypothesis_spec("H3", paths = paths)
report_pipeline_mode <- toupper(trimws(as.character(
  getOption("tobit.pipeline_mode", get_default_pipeline_mode())
)))
if (!(report_pipeline_mode %in% c("TOBIT", "BOTH"))) {
  report_pipeline_mode <- "TOBIT"
}
report_active_model_suffixes <- resolve_active_model_suffixes()
if (length(report_active_model_suffixes) == 0L) {
  report_active_model_suffixes <- "B"
}

report_includes_nonparametric <- function() {
  identical(report_pipeline_mode, "BOTH")
}

report_uses_composite_model <- function() {
  "A" %in% report_active_model_suffixes
}

report_uses_construct_model <- function() {
  "B" %in% report_active_model_suffixes
}

get_report_approaches <- function() {
  if (report_includes_nonparametric()) {
    c("Tobit", "CLAD")
  } else {
    "Tobit"
  }
}

format_count_value <- function(x) {
  if (length(x) == 0L || is.na(x[1])) return("NA")
  format(as.integer(x[1]), big.mark = ",", scientific = FALSE, trim = TRUE)
}

format_sample_description <- function(fit_stats, subset_role = NULL) {
  subset_prefix <- if (!is.null(subset_role)) {
    paste0(subset_role, " subset: ")
  } else {
    ""
  }
  if (is.null(fit_stats) || nrow(fit_stats) == 0L) {
    return(paste0(subset_prefix, "sample counts unavailable"))
  }
  sprintf(
    "%s%s observations from %s participants",
    subset_prefix,
    format_count_value(fit_stats$Observations[1]),
    format_count_value(fit_stats$Participants[1])
  )
}

message("Generating Comprehensive Scientific Manuscript (LaTeX/PDF/Word)...")

# 1. LOAD DATA & ASSETS
judgments_df <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
power_results <- calc_effective_sample_size(judgments_df$judgement, judgments_df$id)
bivar_cor <- read.csv(file.path(paths$tables_dir, "bivariate_correlations.csv"), row.names = 1, check.names = FALSE)
case_configuration_summary_path <- file.path(paths$tables_dir, "case_configuration_summary.csv")
case_configuration_summary <- if (file.exists(case_configuration_summary_path)) {
  read.csv(case_configuration_summary_path, stringsAsFactors = FALSE)
} else {
  NULL
}

dataset_mode_suffix <- function(dataset_mode) {
  mode_key <- toupper(trimws(as.character(dataset_mode)))
  switch(
    mode_key,
    BUC = "Buca",
    FLORIDA = "Florida",
    BOTH = "",
    mode_key
  )
}

get_dataset_specific_stem <- function(prefix, dataset_mode) {
  suffix <- dataset_mode_suffix(dataset_mode)
  if (!nzchar(suffix)) return(NULL)
  paste(prefix, suffix, sep = "_")
}

copy_if_present <- function(source_path, target_path) {
  if (!file.exists(source_path)) return(FALSE)
  if (normalizePath(dirname(source_path), winslash = "/", mustWork = TRUE) ==
      normalizePath(dirname(target_path), winslash = "/", mustWork = TRUE) &&
      basename(source_path) == basename(target_path)) {
    return(TRUE)
  }
  file.copy(source_path, target_path, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
}

sync_dataset_specific_report_aliases <- function(dataset_mode) {
  report_alias_stem <- get_dataset_specific_stem("tobit_analysis_report", dataset_mode)
  if (is.null(report_alias_stem)) return(invisible(FALSE))

  report_extensions <- c(".tex", ".md", ".pdf", ".docx", ".log", ".aux", ".out")
  for (ext in report_extensions) {
    source_path <- file.path(paths$report_dir, paste0("tobit_analysis_report", ext))
    target_path <- file.path(paths$report_dir, paste0(report_alias_stem, ext))
    copy_if_present(source_path, target_path)
  }

  log_alias_stem <- get_dataset_specific_stem("dynamic_report", dataset_mode)
  if (!is.null(log_alias_stem)) {
    copy_if_present(
      file.path(paths$logs_dir, "dynamic_report.md"),
      file.path(paths$logs_dir, paste0(log_alias_stem, ".md"))
    )
  }

  invisible(TRUE)
}

read_fit_stats <- function(output_prefix) {
  stats_file <- file.path(paths$models_dir, sprintf("%s_fit_stats.csv", output_prefix))
  if (!file.exists(stats_file)) return(NULL)
  read.csv(stats_file, stringsAsFactors = FALSE)
}

write_model_fit_summary <- function() {
  fit_files <- list.files(
    paths$models_dir,
    pattern = "^(H1|H2|H3)_(A|B)_(Victim|Bystander)(_CLAD)?_fit_stats\\.csv$",
    full.names = TRUE
  )
  if (length(fit_files) == 0L) return(NULL)

  required_cols <- c(
    "Model", "Approach", "Observations", "Participants", "LowerBoundCensored",
    "UpperBoundCensored", "LogLik", "AIC", "PseudoR2", "Quantile", "Converged",
    "Iterations", "Inference", "ClusterUnit", "BootstrapReplicates",
    "BootstrapSuccessful", "BootstrapFailed", "BootstrapSuccessRate",
    "ConfidenceLevel", "Status", "ErrorMessage"
  )
  fit_rows <- lapply(fit_files, function(path) {
    fit_df <- read.csv(path, stringsAsFactors = FALSE)
    missing_cols <- setdiff(required_cols, names(fit_df))
    for (col_name in missing_cols) {
      fit_df[[col_name]] <- NA
    }
    fit_df[, required_cols, drop = FALSE]
  })
  fit_summary <- do.call(rbind, fit_rows)
  fit_summary <- fit_summary[fit_summary$Approach %in% get_report_approaches(), , drop = FALSE]
  if (nrow(fit_summary) == 0L) return(NULL)
  fit_summary <- fit_summary[order(fit_summary$Approach, fit_summary$Model), , drop = FALSE]
  write.csv(fit_summary, file.path(paths$tables_dir, "model_fit_summary.csv"), row.names = FALSE)
  fit_summary
}

model_fit_summary <- write_model_fit_summary()

collapse_with_and <- function(values) {
  values <- unique(values[nzchar(values)])
  if (length(values) == 0L) return("")
  if (length(values) == 1L) return(values)
  if (length(values) == 2L) return(paste(values, collapse = " and "))
  paste(paste(values[-length(values)], collapse = ", "), values[length(values)], sep = ", and ")
}

coerce_fit_flag <- function(x) {
  if (length(x) == 0L || is.na(x[1])) return(FALSE)
  tolower(trimws(as.character(x[1]))) %in% c("true", "t", "1", "yes")
}

coerce_integer_or_na <- function(x) {
  if (length(x) == 0L || is.na(x[1])) return(NA_integer_)
  suppressWarnings(as.integer(x[1]))
}

format_p_clause <- function(p_value) {
  p_text <- format_p_value(p_value)
  if (startsWith(p_text, "<")) {
    return(paste("p", sub("^<", "< ", p_text)))
  }
  paste("p =", p_text)
}

has_sufficient_clad_bootstrap <- function(fit_stats, min_successes = 2L) {
  if (is.null(fit_stats) || nrow(fit_stats) == 0L) return(FALSE)
  bootstrap_successes <- if ("BootstrapSuccessful" %in% names(fit_stats)) {
    coerce_integer_or_na(fit_stats$BootstrapSuccessful[1])
  } else {
    NA_integer_
  }
  !is.na(bootstrap_successes) && bootstrap_successes >= min_successes
}

is_clad_bootstrap_deferred <- function(fit_stats) {
  !is.null(fit_stats) &&
    nrow(fit_stats) > 0L &&
    tolower(trimws(as.character(fit_stats$Status[1]))) == "bootstrap_deferred"
}

is_clad_bootstrap_sparse <- function(fit_stats, min_successes = 2L) {
  if (is.null(fit_stats) || nrow(fit_stats) == 0L) return(FALSE)
  status_value <- tolower(trimws(as.character(fit_stats$Status[1])))
  if (status_value == "bootstrap_sparse") return(TRUE)
  status_value == "completed" && !has_sufficient_clad_bootstrap(fit_stats, min_successes = min_successes)
}

is_fit_usable <- function(fit_stats, approach) {
  if (is.null(fit_stats) || nrow(fit_stats) == 0L) return(FALSE)
  status_value <- tolower(trimws(as.character(fit_stats$Status[1])))
  if (status_value != "completed") return(FALSE)
  if (approach == "CLAD") {
    return(
      coerce_fit_flag(fit_stats$Converged[1]) &&
        has_sufficient_clad_bootstrap(fit_stats)
    )
  }
  TRUE
}

read_model_bundle <- function(hypothesis_id, model_suffix, approach, subset_role = NULL) {
  subset_part <- if (!is.null(subset_role)) paste0("_", subset_role) else ""
  output_prefix <- paste0(hypothesis_id, "_", model_suffix, subset_part, if (approach == "CLAD") "_CLAD" else "")
  coef_file <- file.path(paths$models_dir, sprintf("%s_coefficients.csv", output_prefix))
  fit_stats <- read_fit_stats(output_prefix)
  coef_df <- if (file.exists(coef_file)) read.csv(coef_file, stringsAsFactors = FALSE) else NULL

  list(
    hypothesis_id = hypothesis_id,
    model_suffix = model_suffix,
    approach = approach,
    subset_role = subset_role,
    output_prefix = output_prefix,
    fit_stats = fit_stats,
    coef_df = coef_df,
    available = !is.null(coef_df) && is_fit_usable(fit_stats, approach)
  )
}

get_fit_issue_text <- function(bundle) {
  if (is.null(bundle$fit_stats) || nrow(bundle$fit_stats) == 0L) {
    return("its fit summary is missing")
  }

  if (bundle$approach == "CLAD" && is_clad_bootstrap_deferred(bundle$fit_stats)) {
    return("participant-level cluster bootstrap inference was not run for this pass")
  }

  if (bundle$approach == "CLAD" && !coerce_fit_flag(bundle$fit_stats$Converged[1])) {
    iteration_text <- if (!is.na(bundle$fit_stats$Iterations[1])) {
      sprintf(" after %s iterations", bundle$fit_stats$Iterations[1])
    } else {
      ""
    }
    return(paste0("the non-parametric optimization did not converge", iteration_text))
  }

  if (bundle$approach == "CLAD" && "BootstrapSuccessful" %in% names(bundle$fit_stats)) {
    bootstrap_successes <- coerce_integer_or_na(bundle$fit_stats$BootstrapSuccessful[1])
    if (!is.na(bootstrap_successes) && bootstrap_successes < 1L) {
      return("the participant-level cluster bootstrap produced no successful refits")
    }
    if (!is.na(bootstrap_successes) && bootstrap_successes < 2L) {
      return("the participant-level cluster bootstrap produced fewer than two successful refits, so inferential summaries are too sparse to interpret")
    }
  }

  sprintf("its status is '%s'", bundle$fit_stats$Status[1])
}

select_hypothesis_rows <- function(coef_df, terms) {
  if (is.null(coef_df) || nrow(coef_df) == 0L) return(NULL)

  target_terms <- vapply(terms, canonicalize_term_name, character(1))
  observed_terms <- vapply(coef_df$term, canonicalize_term_name, character(1))
  coef_df[observed_terms %in% target_terms, , drop = FALSE]
}

matches_expected_direction <- function(estimates, expected_direction) {
  if (expected_direction %in% c("either", "relational")) {
    return(rep(TRUE, length(estimates)))
  }
  if (expected_direction == "negative") return(estimates < 0)
  estimates > 0
}

describe_effect_short <- function(row) {
  sprintf(
    "%s with a %s association (%s)",
    row$label[1],
    if (row$estimate[1] > 0) "positive" else "negative",
    format_p_clause(row$p_value[1])
  )
}

describe_row_group <- function(rows) {
  phrases <- vapply(
    seq_len(nrow(rows)),
    function(i) describe_effect_short(rows[i, , drop = FALSE]),
    character(1)
  )
  collapse_with_and(phrases)
}

assess_model_terms <- function(bundle, term_info, expected_direction, alpha = 0.10) {
  if (!bundle$available) {
    return(list(
      status = "unavailable",
      sentence = sprintf("Model %s is not interpreted because %s.", bundle$model_suffix, get_fit_issue_text(bundle))
    ))
  }

  rows <- select_hypothesis_rows(bundle$coef_df, term_info$terms)
  if (is.null(rows) || nrow(rows) == 0L) {
    return(list(
      status = "missing",
      sentence = sprintf(
        "Model %s cannot be evaluated because %s are missing from the coefficient table.",
        bundle$model_suffix,
        term_info$description
      )
    ))
  }

  rows <- rows[order(ifelse(is.na(rows$p_value), Inf, rows$p_value)), , drop = FALSE]
  sig_rows <- rows[!is.na(rows$p_value) & rows$p_value < alpha, , drop = FALSE]
  expected_rows <- sig_rows[matches_expected_direction(sig_rows$estimate, expected_direction), , drop = FALSE]
  opposite_rows <- sig_rows[!matches_expected_direction(sig_rows$estimate, expected_direction), , drop = FALSE]

  if (nrow(expected_rows) > 0L) {
    return(list(
      status = "support",
      sentence = sprintf("Model %s supports the hypothesis through %s.", bundle$model_suffix, describe_row_group(expected_rows))
    ))
  }

  if (nrow(opposite_rows) > 0L) {
    return(list(
      status = "contradict",
      sentence = sprintf("Model %s points in the opposite direction through %s.", bundle$model_suffix, describe_row_group(opposite_rows))
    ))
  }

  closest_row <- rows[1, , drop = FALSE]
  if (nrow(rows) == 1L) {
    return(list(
      status = "no_support",
      sentence = sprintf(
        "Model %s does not support the hypothesis; %s is %s but not statistically significant (%s).",
        bundle$model_suffix,
        closest_row$label[1],
        if (closest_row$estimate[1] > 0) "positive" else "negative",
        format_p_clause(closest_row$p_value[1])
      )
    ))
  }

  list(
    status = "no_support",
    sentence = sprintf(
      "Model %s does not support the hypothesis; none of %s are statistically significant, and the closest signal is %s.",
      bundle$model_suffix,
      term_info$description,
      describe_effect_short(closest_row)
    )
  )
}

summarize_additional_signals <- function(bundles, excluded_terms, alpha = 0.10, max_terms = 2L) {
  available_bundles <- Filter(function(bundle) isTRUE(bundle$available), bundles)
  if (length(available_bundles) == 0L) return(NULL)

  signal_rows <- lapply(available_bundles, function(bundle) {
    if (is.null(bundle$coef_df) || nrow(bundle$coef_df) == 0L) return(NULL)
    bundle$coef_df
  })
  signal_rows <- Filter(Negate(is.null), signal_rows)
  if (length(signal_rows) == 0L) return(NULL)

  signal_df <- do.call(rbind, signal_rows)
  signal_df$canonical_term <- vapply(signal_df$term, canonicalize_term_name, character(1))
  excluded_canonical <- unique(vapply(excluded_terms, canonicalize_term_name, character(1)))

  signal_df <- signal_df[
    !is.na(signal_df$p_value) &
      signal_df$p_value < alpha &
      !(signal_df$canonical_term %in% excluded_canonical) &
      signal_df$term != "(Intercept)" &
      signal_df$term != "Log(scale)" &
      !grepl("^factor\\(negotiator_slot\\)", signal_df$term) &
      !grepl("^factor\\(stage\\)", signal_df$term),
    ,
    drop = FALSE
  ]

  if (nrow(signal_df) == 0L) return(NULL)

  signal_df <- signal_df[order(signal_df$p_value), , drop = FALSE]
  signal_df <- signal_df[!duplicated(signal_df$canonical_term), , drop = FALSE]
  signal_df <- utils::head(signal_df, max_terms)

  sprintf("Additional statistically significant signals include %s.", describe_row_group(signal_df))
}

summarize_overall_support <- function(statuses) {
  if (length(statuses) == 0L) return("the available evidence is inconclusive.")
  if (all(statuses == "support")) return("the available models support the hypothesis.")
  if (any(statuses == "support")) return("the evidence is mixed but offers partial support for the hypothesis.")
  if (all(statuses == "contradict")) return("the available models point in the opposite direction of the hypothesis.")
  if (any(statuses == "contradict")) return("the available models do not support the hypothesis and at least one model points in the opposite direction.")
  "the available models do not support the hypothesis."
}

summarize_estimator_hypothesis_for_subset <- function(spec, approach, subset_role, alpha = 0.10) {
  bundles <- stats::setNames(
    lapply(report_active_model_suffixes, function(model_suffix) {
      read_model_bundle(spec$id, model_suffix, approach, subset_role)
    }),
    report_active_model_suffixes
  )
  assessments <- stats::setNames(
    lapply(report_active_model_suffixes, function(model_suffix) {
      assess_model_terms(
        bundles[[model_suffix]],
        get_hypothesis_model_terms(spec, model_suffix, subset_role),
        spec$expected_direction,
        alpha
      )
    }),
    report_active_model_suffixes
  )

  available_flags <- vapply(bundles, function(bundle) isTRUE(bundle$available), logical(1))
  if (!any(available_flags)) {
    if (approach == "CLAD") {
      deferred_flags <- vapply(
        bundles,
        function(bundle) is_clad_bootstrap_deferred(bundle$fit_stats),
        logical(1)
      )
      if (any(deferred_flags)) {
        return("Non-parametric conclusion: the full-sample non-parametric fit is available, but participant-level cluster-bootstrap inference was not run for this pass, so the robustness check is not yet interpreted inferentially.")
      }
      sparse_flags <- vapply(
        bundles,
        function(bundle) is_clad_bootstrap_sparse(bundle$fit_stats),
        logical(1)
      )
      if (any(sparse_flags)) {
        return("Non-parametric conclusion: the full-sample non-parametric fit converged, but fewer than two participant-level bootstrap refits succeeded, so the robustness check is not interpreted inferentially for this hypothesis.")
      }
      return("Non-parametric conclusion: no converged second-phase non-parametric model is available, so the robustness check is inconclusive for this hypothesis.")
    }
    return("Tobit conclusion: Tobit outputs are unavailable for this hypothesis.")
  }

  available_statuses <- vapply(
    assessments[names(assessments)[available_flags]],
    function(assessment) assessment$status,
    character(1)
  )
  approach_label <- if (approach == "CLAD") "Non-parametric conclusion" else "Tobit conclusion"
  partial_availability_note <- if (approach == "CLAD" && sum(available_flags) < length(available_flags)) {
    "Only non-parametric specifications with available cluster-bootstrap inference are interpreted here."
  } else {
    NULL
  }
  additional_signal_text <- summarize_additional_signals(bundles, spec$exclude_terms, alpha)

  paste(
    c(
      sprintf("%s: %s", approach_label, summarize_overall_support(available_statuses)),
      partial_availability_note,
      vapply(assessments, function(assessment) assessment$sentence, character(1)),
      additional_signal_text
    ),
    collapse = " "
  )
}

summarize_estimator_hypothesis <- function(spec, approach, alpha = 0.10) {
  victim_summary <- summarize_estimator_hypothesis_for_subset(spec, approach, "Victim", alpha)
  bystander_summary <- summarize_estimator_hypothesis_for_subset(spec, approach, "Bystander", alpha)

  sprintf(
    "Victim subset: %s Bystander subset: %s",
    victim_summary,
    bystander_summary
  )
}

empty_signal_details_df <- function() {
  data.frame(
    hypothesis_id = character(0),
    hypothesis_family_id = character(0),
    hypothesis_statement = character(0),
    hypothesis_family_statement = character(0),
    short_label = character(0),
    hypothesis_family_label = character(0),
    data_path = character(0),
    approach = character(0),
    subset_role = character(0),
    model_suffix = character(0),
    output_prefix = character(0),
    term = character(0),
    canonical_term = character(0),
    label = character(0),
    label_short = character(0),
    estimate = numeric(0),
    p_value = numeric(0),
    symbol = character(0),
    stringsAsFactors = FALSE
  )
}

filter_significant_coefficients <- function(coef_df, alpha = 0.10) {
  if (is.null(coef_df) || nrow(coef_df) == 0L) return(NULL)
  rows <- coef_df
  rows$canonical_term <- vapply(rows$term, canonicalize_term_name, character(1))
  rows <- rows[
    !is.na(rows$p_value) &
      rows$p_value < alpha &
      rows$term != "(Intercept)" &
      rows$term != "Log(scale)" &
      !grepl("^factor\\(negotiator_slot\\)", rows$term) &
      !grepl("^factor\\(stage\\)", rows$term),
    ,
    drop = FALSE
  ]
  if (nrow(rows) == 0L) return(NULL)
  rows
}

collect_hypothesis_signal_details <- function(spec, alpha = 0.10) {
  bundle_grid <- expand.grid(
    approach = get_report_approaches(),
    model_suffix = report_active_model_suffixes,
    subset_role = c("Victim", "Bystander"),
    stringsAsFactors = FALSE
  )
  signal_rows <- lapply(seq_len(nrow(bundle_grid)), function(idx) {
    approach <- bundle_grid$approach[idx]
    model_suffix <- bundle_grid$model_suffix[idx]
    subset_role <- bundle_grid$subset_role[idx]
    bundle <- read_model_bundle(spec$id, model_suffix, approach, subset_role)
    if (!isTRUE(bundle$available) || is.null(bundle$coef_df) || nrow(bundle$coef_df) == 0L) {
      return(NULL)
    }
    term_info <- get_hypothesis_model_terms(spec, model_suffix, subset_role)
    target_terms <- term_info$terms
    rows <- select_hypothesis_rows(bundle$coef_df, target_terms)
    if (is.null(rows) || nrow(rows) == 0L) return(NULL)
    rows$canonical_term <- vapply(rows$term, canonicalize_term_name, character(1))
    rows <- rows[!is.na(rows$p_value) & rows$p_value < alpha, , drop = FALSE]
    if (nrow(rows) == 0L) return(NULL)

    data.frame(
      hypothesis_id = spec$id,
      hypothesis_family_id = get_hypothesis_family_id(spec),
      hypothesis_statement = spec$statement,
      hypothesis_family_statement = get_hypothesis_family_statement(spec),
      short_label = spec$short_label,
      hypothesis_family_label = get_hypothesis_family_short_label(spec),
      data_path = if (subset_role == "Victim") paths$processed_victim else paths$processed_bystander,
      approach = bundle$approach,
      subset_role = subset_role,
      model_suffix = model_suffix,
      output_prefix = bundle$output_prefix,
      term = rows$term,
      canonical_term = rows$canonical_term,
      label = rows$label,
      label_short = if ("label_short" %in% names(rows)) rows$label_short else rows$label,
      estimate = rows$estimate,
      p_value = rows$p_value,
      symbol = vapply(rows$p_value, significance_symbol, character(1)),
      stringsAsFactors = FALSE
    )
  })
  signal_rows <- Filter(Negate(is.null), signal_rows)
  if (length(signal_rows) == 0L) return(empty_signal_details_df())
  do.call(rbind, signal_rows)
}

collect_all_hypothesis_signal_details <- function(alpha = 0.10) {
  hypothesis_specs <- get_hypothesis_specs(paths = paths)
  signal_rows <- lapply(hypothesis_specs, collect_hypothesis_signal_details, alpha = alpha)
  signal_rows <- Filter(function(df) nrow(df) > 0L, signal_rows)

  signal_df <- if (length(signal_rows) == 0L) {
    empty_signal_details_df()
  } else {
    do.call(rbind, signal_rows)
  }

  write.csv(signal_df, file.path(paths$tables_dir, "hypothesis_signal_details.csv"), row.names = FALSE)
  signal_df
}

collect_all_significant_predictor_details <- function(alpha = 0.10) {
  hypothesis_specs <- get_hypothesis_specs(paths = paths)
  bundle_grid <- expand.grid(
    hypothesis_idx = seq_along(hypothesis_specs),
    approach = get_report_approaches(),
    model_suffix = report_active_model_suffixes,
    subset_role = c("Victim", "Bystander"),
    stringsAsFactors = FALSE
  )

  signal_rows <- lapply(seq_len(nrow(bundle_grid)), function(idx) {
    spec <- hypothesis_specs[[bundle_grid$hypothesis_idx[idx]]]
    bundle <- read_model_bundle(spec$id, bundle_grid$model_suffix[idx], bundle_grid$approach[idx], bundle_grid$subset_role[idx])
    if (!isTRUE(bundle$available) || is.null(bundle$coef_df) || nrow(bundle$coef_df) == 0L) {
      return(NULL)
    }

    rows <- filter_significant_coefficients(bundle$coef_df, alpha = alpha)
    if (is.null(rows) || nrow(rows) == 0L) return(NULL)

    data.frame(
      hypothesis_id = spec$id,
      hypothesis_family_id = get_hypothesis_family_id(spec),
      hypothesis_statement = spec$statement,
      hypothesis_family_statement = get_hypothesis_family_statement(spec),
      short_label = spec$short_label,
      hypothesis_family_label = get_hypothesis_family_short_label(spec),
      data_path = if (bundle_grid$subset_role[idx] == "Victim") paths$processed_victim else paths$processed_bystander,
      approach = bundle$approach,
      subset_role = bundle_grid$subset_role[idx],
      model_suffix = bundle_grid$model_suffix[idx],
      output_prefix = bundle$output_prefix,
      term = rows$term,
      canonical_term = rows$canonical_term,
      label = rows$label,
      label_short = if ("label_short" %in% names(rows)) rows$label_short else rows$label,
      estimate = rows$estimate,
      p_value = rows$p_value,
      symbol = vapply(rows$p_value, significance_symbol, character(1)),
      stringsAsFactors = FALSE
    )
  })

  signal_rows <- Filter(Negate(is.null), signal_rows)
  signal_df <- if (length(signal_rows) == 0L) {
    empty_signal_details_df()
  } else {
    do.call(rbind, signal_rows)
  }

  write.csv(signal_df, file.path(paths$tables_dir, "all_significant_predictor_details.csv"), row.names = FALSE)
  signal_df
}

collect_hypothesis_signals <- function(spec, approach, alpha = 0.10, signal_details = NULL) {
  bundle_grid <- expand.grid(
    model_suffix = report_active_model_suffixes,
    subset_role = c("Victim", "Bystander"),
    stringsAsFactors = FALSE
  )
  bundle_names <- sprintf("%s_%s", substr(bundle_grid$subset_role, 1, 1), bundle_grid$model_suffix)
  bundles <- stats::setNames(
    lapply(seq_len(nrow(bundle_grid)), function(idx) {
      read_model_bundle(spec$id, bundle_grid$model_suffix[idx], approach, bundle_grid$subset_role[idx])
    }),
    bundle_names
  )
  available_bundles <- Filter(function(bundle) isTRUE(bundle$available), bundles)
  if (length(available_bundles) == 0L) {
    if (approach == "CLAD") {
      deferred_flags <- vapply(
        bundles,
        function(bundle) is_clad_bootstrap_deferred(bundle$fit_stats),
        logical(1)
      )
      if (any(deferred_flags)) return("Bootstrap not run")
      sparse_flags <- vapply(
        bundles,
        function(bundle) is_clad_bootstrap_sparse(bundle$fit_stats),
        logical(1)
      )
      if (any(sparse_flags)) return("Bootstrap too sparse")
    }
    return("None")
  }

  if (is.null(signal_details)) {
    signal_details <- collect_hypothesis_signal_details(spec, alpha = alpha)
  }

  signal_df <- signal_details[
    signal_details$hypothesis_id == spec$id &
      signal_details$approach == approach,
    ,
    drop = FALSE
  ]
  label_col <- if ("label_short" %in% names(signal_df)) "label_short" else "label"
  signal_df <- signal_df[order(signal_df$p_value, signal_df[[label_col]]), , drop = FALSE]
  if (nrow(signal_df) == 0L) {
    return("None")
  }

  signal_df <- signal_df[!duplicated(signal_df$canonical_term), , drop = FALSE]
  formatted_terms <- paste0(signal_df[[label_col]], signal_df$symbol)
  paste(formatted_terms, collapse = "; ")
}

collect_hypothesis_family_signals <- function(family_spec, approach, alpha = 0.10, signal_details = NULL, subset_role = NULL) {
  subset_roles <- if (is.null(subset_role)) c("Victim", "Bystander") else subset_role
  bundle_grid <- expand.grid(
    hypothesis_id = family_spec$member_ids,
    model_suffix = report_active_model_suffixes,
    subset_role = subset_roles,
    stringsAsFactors = FALSE
  )
  bundles <- lapply(seq_len(nrow(bundle_grid)), function(idx) {
    read_model_bundle(bundle_grid$hypothesis_id[idx], bundle_grid$model_suffix[idx], approach, bundle_grid$subset_role[idx])
  })
  available_bundles <- Filter(function(bundle) isTRUE(bundle$available), bundles)
  if (length(available_bundles) == 0L) {
    if (approach == "CLAD") {
      deferred_flags <- vapply(
        bundles,
        function(bundle) is_clad_bootstrap_deferred(bundle$fit_stats),
        logical(1)
      )
      if (any(deferred_flags)) return("Bootstrap not run")
      sparse_flags <- vapply(
        bundles,
        function(bundle) is_clad_bootstrap_sparse(bundle$fit_stats),
        logical(1)
      )
      if (any(sparse_flags)) return("Bootstrap too sparse")
    }
    return("None")
  }

  if (is.null(signal_details)) {
    signal_details <- collect_all_hypothesis_signal_details(alpha = alpha)
  }

  signal_df <- signal_details[
    signal_details$hypothesis_family_id == family_spec$id &
      signal_details$approach == approach,
    ,
    drop = FALSE
  ]
  if (!is.null(subset_role)) {
    signal_df <- signal_df[signal_df$subset_role %in% subset_role, , drop = FALSE]
  }
  label_col <- if ("label_short" %in% names(signal_df)) "label_short" else "label"
  signal_df <- signal_df[order(signal_df$p_value, signal_df[[label_col]]), , drop = FALSE]
  if (nrow(signal_df) == 0L) {
    return("None")
  }

  signal_df <- signal_df[!duplicated(signal_df$canonical_term), , drop = FALSE]
  formatted_terms <- paste0(signal_df[[label_col]], signal_df$symbol)
  paste(formatted_terms, collapse = "; ")
}

build_hypothesis_significance_summary_df <- function(subset_role, alpha = 0.10, signal_details = NULL) {
  hypothesis_specs <- get_hypothesis_family_specs(paths = paths)
  if (is.null(signal_details)) {
    signal_details <- collect_all_hypothesis_signal_details(alpha = alpha)
  }
  summary_columns <- list(
    Hypothesis = vapply(hypothesis_specs, function(spec) spec$id, character(1)),
    `Tobit support` = vapply(
      hypothesis_specs,
      function(spec) collect_hypothesis_family_signals(spec, "Tobit", alpha, signal_details = signal_details, subset_role = subset_role),
      character(1)
    )
  )
  if (report_includes_nonparametric()) {
    summary_columns$`Non-parametric support` <- vapply(
      hypothesis_specs,
      function(spec) collect_hypothesis_family_signals(spec, "CLAD", alpha, signal_details = signal_details, subset_role = subset_role),
      character(1)
    )
  }
  as.data.frame(summary_columns, stringsAsFactors = FALSE, check.names = FALSE)
}

write_hypothesis_significance_summary <- function(alpha = 0.10, signal_details = NULL) {
  if (is.null(signal_details)) {
    signal_details <- collect_all_hypothesis_signal_details(alpha = alpha)
  }

  subset_tables <- list(
    Victim = build_hypothesis_significance_summary_df("Victim", alpha = alpha, signal_details = signal_details),
    Bystander = build_hypothesis_significance_summary_df("Bystander", alpha = alpha, signal_details = signal_details)
  )

  combined_export <- do.call(
    rbind,
    lapply(names(subset_tables), function(role_label) {
      export_df <- subset_tables[[role_label]]
      data.frame(Subset = role_label, export_df, stringsAsFactors = FALSE, check.names = FALSE)
    })
  )

  write.csv(combined_export, file.path(paths$tables_dir, "hypothesis_summary.csv"), row.names = FALSE)
  write.csv(subset_tables$Victim, file.path(paths$tables_dir, "hypothesis_summary_victim.csv"), row.names = FALSE)
  write.csv(subset_tables$Bystander, file.path(paths$tables_dir, "hypothesis_summary_bystander.csv"), row.names = FALSE)

  subset_tables
}

format_hypothesis_summary_cell_latex <- function(x) {
  text <- escape_latex(x)
  text <- gsub("; ", paste0(";", "\\newline "), text, fixed = TRUE)
  text <- gsub("None", "None", text, fixed = TRUE)
  text
}

to_latex_wrapped_hypothesis_summary <- function(df, caption, label) {
  if (!is.data.frame(df) || ncol(df) < 2L) return("")

  formatted_df <- df
  formatted_df[] <- lapply(formatted_df, format_hypothesis_summary_cell_latex)
  header <- paste(vapply(names(formatted_df), escape_latex, character(1)), collapse = " & ")
  body <- apply(formatted_df, 1, function(row) paste(row, collapse = " & "))
  caption_text <- escape_latex(caption)
  col_widths <- if (ncol(formatted_df) == 2L) {
    c(0.12, 0.74)
  } else if (ncol(formatted_df) == 3L) {
    c(0.10, 0.38, 0.38)
  } else {
    c(0.12, rep(0.74 / (ncol(formatted_df) - 1L), ncol(formatted_df) - 1L))
  }
  col_spec <- paste(
    vapply(
      col_widths,
      function(width) sprintf(">{\\raggedright\\arraybackslash}p{%.2f\\textwidth}", width),
      character(1)
    ),
    collapse = ""
  )

  c(
    "\\begin{table}[H]",
    "\\centering",
    "{\\fontsize{11}{13}\\selectfont",
    "\\renewcommand{\\arraystretch}{1.15}",
    paste0("\\caption{", caption_text, "}"),
    paste0("\\label{", label, "}"),
    paste0("\\begin{tabular}{", col_spec, "}"),
    "\\toprule",
    paste0(header, " \\\\"),
    "\\midrule",
    paste0(body, " \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "}",
    "\\end{table}"
  )
}

get_abbreviation_note_text <- function() {
  paste0(
    "Abbrev.: ",
    get_predictor_abbreviation_note(),
    "."
  )
}

build_latex_note_block <- function(text) {
  c(
    "\\begin{flushleft}",
    paste0("\\footnotesize\\textit{Note.} ", escape_latex(text)),
    "\\end{flushleft}"
  )
}

build_markdown_note_line <- function(text) {
  paste0("_Note._ ", text)
}

build_predictor_glossary_df <- function() {
  glossary_df <- data.frame(
    `Code / pattern` = c(
      "iri_total",
      "iri_fs, iri_ec, iri_pt, iri_pd",
      "judged_ingroup, judged_outgroup",
      "counterpart_ingroup, counterpart_outgroup",
      "decision_accept",
      "observer_victim_outgroup",
      "h2_negstruct_*",
      "player_victim_outgroup",
      "player_victim_outgroup:h2_negstruct_*",
      "decision_accept:judged_*",
      "iri_*:judged_*",
      "participant_engineering",
      "sex_man",
      "age",
      "economic_status",
      "factor(negotiator_slot)"
    ),
    Compact = c(
      "Emp",
      "FS, EC, PT, PD",
      "N1 In, N1 Out",
      "N2 In, N2 Out",
      "Acc",
      "V Out (Obs)",
      "N1 ..., N2 ...",
      "V Out",
      "V Out x N1 ..., N2 ...",
      "Acc x N1 ...",
      "Emp / FS / EC / PT / PD x N1 ...",
      "Eng part.",
      "Man",
      "Age",
      "SES",
      "Slot 2"
    ),
    Meaning = c(
      "Composite empathy predictor used in Model A.",
      "IRI subscales used in Model B: fantasy, empathic concern, perspective taking, and personal distress.",
      "N1 contrasts relative to the N1 control-labeled baseline.",
      "N2 contrasts relative to the N2 control-labeled baseline.",
      "Accepted harmful deal relative to rejected harmful deal.",
      "Observer-only victim outgroup contrast; excluded from victim-only formulas.",
      "H2 joint N1/N2 structure dummies with reference N1 Ctl, N2 Ctl.",
      "Observer-side player-victim outgroup contrast with player-victim ingroup as the reference.",
      "Bystander-only H2 interaction: whether the negotiator-side structure changes when player and victim are outgroup-aligned.",
      "H3 decision-by-judged-status interaction block.",
      "H3 empathy-by-judged-status interaction block.",
      "Participant faculty contrast.",
      "Sex contrast with woman as the reference.",
      "Participant age in original units.",
      "Economic status in original units.",
      "Negotiator slot contrast with slot 1 as the reference."
    ),
    `Used in` = c(
      "H1/H2/H3 Model A",
      "H1/H2/H3 Model B",
      "H1/H3",
      "H1/H3",
      "H1/H3",
      "H1/H3 Bystander only",
      "H2 Victim and Bystander",
      "H2 Bystander only",
      "H2 Bystander only",
      "H3",
      "H3",
      "H1/H2/H3",
      "H1/H2/H3",
      "H1/H2/H3",
      "H1/H2/H3",
      "H1/H2/H3"
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  if (!report_uses_composite_model()) {
    glossary_df <- glossary_df[glossary_df$`Code / pattern` != "iri_total", , drop = FALSE]
    glossary_df$Compact[glossary_df$`Code / pattern` == "iri_*:judged_*"] <- "FS / EC / PT / PD x N1 ..."
    glossary_df$Meaning[glossary_df$`Code / pattern` == "iri_fs, iri_ec, iri_pt, iri_pd"] <-
      "Active empathy predictors: fantasy, empathic concern, perspective taking, and personal distress."
    glossary_df$`Used in`[glossary_df$`Code / pattern` == "iri_fs, iri_ec, iri_pt, iri_pd"] <- "H1/H2/H3 active model"
  }

  glossary_df
}

build_latex_predictor_glossary_list <- function() {
  glossary_df <- build_predictor_glossary_df()
  c(
    "\\begin{itemize}",
    vapply(seq_len(nrow(glossary_df)), function(idx) {
      paste0(
        "  \\item \\texttt{",
        escape_latex(glossary_df$`Code / pattern`[idx]),
        "} [",
        escape_latex(glossary_df$Compact[idx]),
        "]: ",
        escape_latex(glossary_df$Meaning[idx]),
        " Used in ",
        escape_latex(glossary_df$`Used in`[idx]),
        "."
      )
    }, character(1)),
    "\\end{itemize}"
  )
}

build_markdown_predictor_glossary_list <- function() {
  glossary_df <- build_predictor_glossary_df()
  vapply(seq_len(nrow(glossary_df)), function(idx) {
    sprintf(
      "- `%s` [%s]: %s Used in %s.",
      glossary_df$`Code / pattern`[idx],
      glossary_df$Compact[idx],
      glossary_df$Meaning[idx],
      glossary_df$`Used in`[idx]
    )
  }, character(1))
}

build_subset_formula_lines <- function(spec, model_suffix) {
  victim_rhs <- get_hypothesis_formula_rhs(spec, model_suffix, "Victim")
  bystander_rhs <- get_hypothesis_formula_rhs(spec, model_suffix, "Bystander")

  c(
    paste0("\\textit{Model ", model_suffix, " subset-specific formulas.}"),
    "\\begin{quote}",
    paste0("\\small ", escape_latex(sprintf("Victim: judgement ~ %s", victim_rhs))),
    "",
    paste0("\\small ", escape_latex(sprintf("Bystander: judgement ~ %s", bystander_rhs))),
    "\\end{quote}",
    ""
  )
}

format_support_phrase <- function(row) {
  estimator_label <- if (identical(row$approach, "Tobit")) {
    "the Tobit model"
  } else {
    "the clustered non-parametric model"
  }
  p_text <- format_p_value(row$p_value)
  if (startsWith(p_text, "<")) {
    sprintf("%s (%s, p %s)", estimator_label, row$symbol, sub("^<", "< ", p_text))
  } else {
    sprintf("%s (%s, p = %s)", estimator_label, row$symbol, p_text)
  }
}

summarize_support_phrases <- function(support_rows) {
  collapse_with_and(vapply(seq_len(nrow(support_rows)), function(idx) format_support_phrase(support_rows[idx, , drop = FALSE]), character(1)))
}

build_significance_figure_artifacts <- function(signal_details) {
  if (is.null(signal_details) || nrow(signal_details) == 0L) {
    empty_catalog_columns <- list(
      Hypothesis = character(0),
      Predictor = character(0),
      Figure = character(0),
      FigureType = character(0),
      `Tobit support` = character(0)
    )
    if (report_includes_nonparametric()) {
      empty_catalog_columns$`Non-parametric support` <- character(0)
    }
    empty_catalog <- as.data.frame(empty_catalog_columns, stringsAsFactors = FALSE, check.names = FALSE)
    write.csv(empty_catalog, file.path(paths$tables_dir, "hypothesis_figure_catalog.csv"), row.names = FALSE)
    return(list())
  }

  hypothesis_specs <- get_hypothesis_specs(paths = paths)
  hypothesis_lookup <- stats::setNames(hypothesis_specs, vapply(hypothesis_specs, `[[`, character(1), "id"))
  group_keys <- unique(signal_details[, c("hypothesis_id", "canonical_term")])
  group_order <- order(
    match(group_keys$hypothesis_id, names(hypothesis_lookup)),
    vapply(
      seq_len(nrow(group_keys)),
      function(idx) {
        key_rows <- signal_details[
          signal_details$hypothesis_id == group_keys$hypothesis_id[idx] &
            signal_details$canonical_term == group_keys$canonical_term[idx],
          ,
          drop = FALSE
        ]
        min(key_rows$p_value, na.rm = TRUE)
      },
      numeric(1)
    )
  )
  group_keys <- group_keys[group_order, , drop = FALSE]

  artifacts <- vector("list", nrow(group_keys))
  catalog_rows <- vector("list", nrow(group_keys))

  for (idx in seq_len(nrow(group_keys))) {
    hypothesis_id <- group_keys$hypothesis_id[idx]
    canonical_term <- group_keys$canonical_term[idx]
    spec <- hypothesis_lookup[[hypothesis_id]]
    family_id <- get_hypothesis_family_id(spec)
    family_short_label <- get_hypothesis_family_short_label(spec)
    family_statement <- get_hypothesis_family_statement(spec)
    support_rows <- signal_details[
      signal_details$hypothesis_id == hypothesis_id &
        signal_details$canonical_term == canonical_term,
      ,
      drop = FALSE
    ]
    support_rows <- do.call(
      rbind,
      lapply(
        split(support_rows, support_rows$approach),
        function(df) df[order(df$p_value, df$model_suffix), , drop = FALSE][1, , drop = FALSE]
      )
    )
    rownames(support_rows) <- NULL

    model_data <- read.csv(support_rows$data_path[1], stringsAsFactors = FALSE)
    visual_spec <- build_term_visual_spec(canonical_term, model_data)
    figure_title <- sprintf("%s %s", family_id, label_term(canonical_term))
    figure_file <- build_titled_figure_filename(
      sprintf("figure_sig_%s_%s", hypothesis_id, sanitize_identifier(canonical_term)),
      figure_title
    )
    figure_path <- file.path(paths$figures_dir, figure_file)
    latex_label <- paste0("fig:sig_", hypothesis_id, "_", sanitize_identifier(canonical_term))

    plot_payloads <- lapply(seq_len(nrow(support_rows)), function(row_idx) {
      support_row <- support_rows[row_idx, , drop = FALSE]
      model_fit <- readRDS(file.path(paths$models_dir, sprintf("%s_model.rds", support_row$output_prefix[1])))
      plot_df <- build_significance_plot_data(model_fit, model_data, canonical_term)
      list(
        approach = support_row$approach[1],
        support_row = support_row,
        visual_spec = visual_spec,
        plot_df = plot_df,
        pattern = describe_prediction_pattern(plot_df, visual_spec)
      )
    })

    write_significance_figure(
      figure_path,
      plot_payloads,
      figure_title
    )

    support_phrase <- summarize_support_phrases(support_rows)
    pattern_text <- if (length(plot_payloads) == 1L) {
      plot_payloads[[1]]$pattern
    } else {
      paste0("both estimator panels indicate that ", plot_payloads[[1]]$pattern)
    }

    figure_type <- switch(
      visual_spec$kind,
      continuous_main = "effect plot",
      categorical_main = "grouped prediction plot",
      interaction = "interaction plot",
      "dynamic effect plot"
    )
    caption <- sprintf(
      "%s for %s in %s. The panels show predicted judgments on the observed -9 to 9 scale with 95%% confidence intervals. %s",
      tools::toTitleCase(figure_type),
      label_term(canonical_term),
      family_short_label,
      get_abbreviation_note_text()
    )

    artifacts[[idx]] <- list(
      hypothesis_id = family_id,
      hypothesis_statement = family_statement,
      short_label = family_short_label,
      operational_hypothesis_id = hypothesis_id,
      operational_short_label = spec$short_label,
      canonical_term = canonical_term,
      label = label_term(canonical_term),
      label_short = label_term_compact(canonical_term),
      figure_file = figure_file,
      figure_path = figure_path,
      latex_label = latex_label,
      support_rows = support_rows,
      support_phrase = support_phrase,
      caption = caption,
      pattern_text = pattern_text,
      min_p_value = min(support_rows$p_value, na.rm = TRUE)
    )

    catalog_row <- list(
      Hypothesis = family_id,
      Predictor = label_term_compact(canonical_term),
      Figure = figure_file,
      FigureType = figure_type,
      `Tobit support` = if (any(support_rows$approach == "Tobit")) {
        label_values <- if ("label_short" %in% names(support_rows)) support_rows$label_short else support_rows$label
        paste0(label_values[support_rows$approach == "Tobit"], support_rows$symbol[support_rows$approach == "Tobit"], collapse = "; ")
      } else {
        "None"
      }
    )
    if (report_includes_nonparametric()) {
      catalog_row$`Non-parametric support` <- if (any(support_rows$approach == "CLAD")) {
        label_values <- if ("label_short" %in% names(support_rows)) support_rows$label_short else support_rows$label
        paste0(label_values[support_rows$approach == "CLAD"], support_rows$symbol[support_rows$approach == "CLAD"], collapse = "; ")
      } else {
        "None"
      }
    }
    catalog_rows[[idx]] <- as.data.frame(catalog_row, stringsAsFactors = FALSE, check.names = FALSE)
  }

  write.csv(
    do.call(rbind, catalog_rows),
    file.path(paths$tables_dir, "hypothesis_figure_catalog.csv"),
    row.names = FALSE
  )
  artifacts
}

describe_signal_sample <- function(data_path) {
  if (length(data_path) == 0L || is.na(data_path[1]) || !is.character(data_path[1])) return("analysis sample")
  normalized_path <- normalizePath(data_path[1], winslash = "/", mustWork = FALSE)
  if (grepl("04_judgments_victim\\.csv$", normalized_path)) return("Victim role sample")
  if (grepl("04_judgments_bystander\\.csv$", normalized_path)) return("Bystander role sample")
  if (grepl("04_judgments_accept\\.csv$", normalized_path)) return("accepted-deal sub-sample")
  tools::file_path_sans_ext(basename(data_path[1]))
}

format_support_model_rows <- function(rows, approach = NULL) {
  if (!is.null(approach)) {
    rows <- rows[rows$approach == approach, , drop = FALSE]
  }
  if (nrow(rows) == 0L) return("None")
  label_col <- if ("hypothesis_family_label" %in% names(rows)) "hypothesis_family_label" else "short_label"
  rows <- rows[order(rows$p_value, rows[[label_col]], rows$model_suffix), , drop = FALSE]
  descriptors <- paste0(rows[[label_col]], " Model ", rows$model_suffix, rows$symbol)
  paste(unique(descriptors), collapse = "; ")
}

summarize_supporting_models <- function(rows) {
  label_col <- if ("hypothesis_family_label" %in% names(rows)) "hypothesis_family_label" else "short_label"
  rows <- rows[order(rows$p_value, rows[[label_col]], rows$model_suffix), , drop = FALSE]
  descriptors <- paste0(rows[[label_col]], " Model ", rows$model_suffix, " (", rows$approach, ")")
  collapse_with_and(unique(descriptors))
}

get_supporting_model_descriptors <- function(rows) {
  label_col <- if ("hypothesis_family_label" %in% names(rows)) "hypothesis_family_label" else "short_label"
  rows <- rows[order(rows$p_value, rows[[label_col]], rows$model_suffix), , drop = FALSE]
  unique(paste0(rows[[label_col]], " Model ", rows$model_suffix, " (", rows$approach, ")"))
}

format_supporting_models_latex <- function(descriptors) {
  descriptors <- unique(descriptors[nzchar(descriptors)])
  if (length(descriptors) == 0L) {
    return(escape_latex("No supporting models were available."))
  }
  paste(escape_latex(descriptors), collapse = ";\\newline ")
}

format_supporting_models_markdown <- function(descriptors) {
  descriptors <- unique(descriptors[nzchar(descriptors)])
  if (length(descriptors) == 0L) {
    return("No supporting models were available.")
  }
  paste(descriptors, collapse = ";<br>")
}

build_latex_all_significant_predictor_narrative <- function(artifact) {
  c(
    escape_latex(sprintf("%s is statistically significant in:", artifact$label)),
    "\\begin{itemize}",
    paste0("  \\item ", escape_latex(artifact$supporting_models_list)),
    "\\end{itemize}",
    paste0(
      "Figure \\ref{", artifact$latex_label, "} ",
      escape_latex(sprintf("shows that %s.", artifact$pattern_text))
    )
  )
}

build_markdown_all_significant_predictor_narrative <- function(artifact) {
  c(
    sprintf("%s is statistically significant in:", artifact$label),
    paste0("- ", artifact$supporting_models_list),
    sprintf("The figure below shows that %s.", artifact$pattern_text)
  )
}

build_all_significant_predictor_figure_artifacts <- function(signal_details) {
  if (is.null(signal_details) || nrow(signal_details) == 0L) {
    empty_catalog_columns <- list(
      Sample = character(0),
      Predictor = character(0),
      Figure = character(0),
      FigureType = character(0),
      `Tobit support` = character(0)
    )
    if (report_includes_nonparametric()) {
      empty_catalog_columns$`Non-parametric support` <- character(0)
    }
    empty_catalog_columns$`Supporting models` <- character(0)
    empty_catalog <- as.data.frame(empty_catalog_columns, stringsAsFactors = FALSE, check.names = FALSE)
    write.csv(empty_catalog, file.path(paths$tables_dir, "all_significant_figure_catalog.csv"), row.names = FALSE)
    return(list())
  }

  group_keys <- unique(signal_details[, c("data_path", "canonical_term"), drop = FALSE])
  group_order <- order(
    vapply(seq_len(nrow(group_keys)), function(idx) describe_signal_sample(group_keys$data_path[idx]), character(1)),
    vapply(
      seq_len(nrow(group_keys)),
      function(idx) {
        key_rows <- signal_details[
          signal_details$data_path == group_keys$data_path[idx] &
            signal_details$canonical_term == group_keys$canonical_term[idx],
          ,
          drop = FALSE
        ]
        min(key_rows$p_value, na.rm = TRUE)
      },
      numeric(1)
    )
  )
  group_keys <- group_keys[group_order, , drop = FALSE]

  artifacts <- vector("list", nrow(group_keys))
  catalog_rows <- vector("list", nrow(group_keys))

  for (idx in seq_len(nrow(group_keys))) {
    data_path <- group_keys$data_path[idx]
    canonical_term <- group_keys$canonical_term[idx]
    support_rows_all <- signal_details[
      signal_details$data_path == data_path &
        signal_details$canonical_term == canonical_term,
      ,
      drop = FALSE
    ]

    support_rows <- do.call(
      rbind,
      lapply(
        split(support_rows_all, support_rows_all$approach),
        function(df) df[order(df$p_value, df$short_label, df$model_suffix), , drop = FALSE][1, , drop = FALSE]
      )
    )
    rownames(support_rows) <- NULL

    model_data <- read.csv(data_path, stringsAsFactors = FALSE)
    visual_spec <- build_term_visual_spec(canonical_term, model_data)
    sample_label <- describe_signal_sample(data_path)
    figure_title <- sprintf("%s %s", sample_label, label_term(canonical_term))
    figure_file <- build_titled_figure_filename(
      sprintf(
        "figure_sig_all_%s_%s",
        sanitize_identifier(sample_label),
        sanitize_identifier(canonical_term)
      ),
      figure_title
    )
    figure_path <- file.path(paths$figures_dir, figure_file)
    latex_label <- paste0("fig:sig_all_", sanitize_identifier(sample_label), "_", sanitize_identifier(canonical_term))

    plot_payloads <- lapply(seq_len(nrow(support_rows)), function(row_idx) {
      support_row <- support_rows[row_idx, , drop = FALSE]
      model_fit <- readRDS(file.path(paths$models_dir, sprintf("%s_model.rds", support_row$output_prefix[1])))
      plot_df <- build_significance_plot_data(model_fit, model_data, canonical_term)
      list(
        approach = support_row$approach[1],
        support_row = support_row,
        visual_spec = visual_spec,
        plot_df = plot_df,
        pattern = describe_prediction_pattern(plot_df, visual_spec)
      )
    })

    write_significance_figure(
      figure_path,
      plot_payloads,
      figure_title
    )

    support_phrase <- summarize_support_phrases(support_rows)
    supporting_models_list <- get_supporting_model_descriptors(support_rows_all)
    supporting_models <- summarize_supporting_models(support_rows_all)
    pattern_text <- if (length(plot_payloads) == 1L) {
      plot_payloads[[1]]$pattern
    } else {
      paste0("the estimator panels indicate that ", plot_payloads[[1]]$pattern)
    }

    figure_type <- switch(
      visual_spec$kind,
      continuous_main = "effect plot",
      categorical_main = "grouped prediction plot",
      interaction = "interaction plot",
      "dynamic effect plot"
    )
    caption <- sprintf(
      "%s for %s in the %s. The panels show predicted judgments on the observed -9 to 9 scale with 95%% confidence intervals. %s",
      tools::toTitleCase(figure_type),
      label_term(canonical_term),
      sample_label,
      get_abbreviation_note_text()
    )

    artifacts[[idx]] <- list(
      sample_label = sample_label,
      sample_key = sanitize_identifier(sample_label),
      canonical_term = canonical_term,
      label = label_term(canonical_term),
      label_short = label_term_compact(canonical_term),
      figure_file = figure_file,
      figure_path = figure_path,
      latex_label = latex_label,
      support_rows = support_rows,
      support_rows_all = support_rows_all,
      support_phrase = support_phrase,
      supporting_models_list = supporting_models_list,
      supporting_models = supporting_models,
      caption = caption,
      pattern_text = pattern_text,
      min_p_value = min(support_rows_all$p_value, na.rm = TRUE)
    )

    catalog_row <- list(
      Sample = sample_label,
      Predictor = label_term_compact(canonical_term),
      Figure = figure_file,
      FigureType = figure_type,
      `Tobit support` = format_support_model_rows(support_rows_all, approach = "Tobit")
    )
    if (report_includes_nonparametric()) {
      catalog_row$`Non-parametric support` <- format_support_model_rows(support_rows_all, approach = "CLAD")
    }
    catalog_row$`Supporting models` <- supporting_models
    catalog_rows[[idx]] <- as.data.frame(catalog_row, stringsAsFactors = FALSE, check.names = FALSE)
  }

  write.csv(
    do.call(rbind, catalog_rows),
    file.path(paths$tables_dir, "all_significant_figure_catalog.csv"),
    row.names = FALSE
  )
  artifacts
}

build_latex_significance_figure_narrative <- function(artifact) {
  paste0(
    escape_latex(sprintf("%s is statistically significant in %s. ", artifact$label, artifact$support_phrase)),
    "Figure \\ref{", artifact$latex_label, "} ",
    escape_latex(sprintf("shows that %s.", artifact$pattern_text))
  )
}

build_markdown_significance_figure_narrative <- function(artifact) {
  sprintf(
    "%s is statistically significant in %s. The figure below shows that %s.",
    artifact$label,
    artifact$support_phrase,
    artifact$pattern_text
  )
}

build_latex_all_significant_predictor_figure_section <- function(artifacts) {
  if (length(artifacts) == 0L) return(character(0))

  section_lines <- c(
    "",
    "\\subsection{All Significant Predictors (p < 0.10)}",
    escape_latex(
      if (report_includes_nonparametric()) {
        paste(
          "The following figures extend beyond the hypothesis-target terms and visualize every predictor",
          "that reaches p < 0.10 in the available H1-H3 Tobit or clustered non-parametric models.",
          "This includes significant controls such as age when they clear the threshold."
        )
      } else {
        paste(
          "The following figures extend beyond the hypothesis-target terms and visualize every predictor",
          "that reaches p < 0.10 in the available H1-H3 Tobit models.",
          "This includes significant controls such as age when they clear the threshold."
        )
      }
    ),
    ""
  )

  current_sample <- NULL
  for (artifact in artifacts) {
    if (!identical(current_sample, artifact$sample_key)) {
      section_lines <- c(
        section_lines,
        paste0("\\paragraph{", escape_latex(artifact$sample_label), "}"),
        ""
      )
      current_sample <- artifact$sample_key
    }

    section_lines <- c(
      section_lines,
      build_latex_all_significant_predictor_narrative(artifact),
      "",
      latex_include_graphic(file.path("../figures", artifact$figure_file), artifact$caption, artifact$latex_label),
      ""
    )
  }

  section_lines
}

build_markdown_all_significant_predictor_figure_section <- function(artifacts) {
  if (length(artifacts) == 0L) return(character(0))

  section_lines <- c(
    "## All Significant Predictors (p < .10)",
    if (report_includes_nonparametric()) {
      "The following figures extend beyond the hypothesis-target terms and visualize every predictor that reaches `p < .10` in the available H1-H3 Tobit or clustered non-parametric models. This includes significant controls such as age when they clear the threshold."
    } else {
      "The following figures extend beyond the hypothesis-target terms and visualize every predictor that reaches `p < .10` in the available H1-H3 Tobit models. This includes significant controls such as age when they clear the threshold."
    },
    ""
  )

  current_sample <- NULL
  for (artifact in artifacts) {
    if (!identical(current_sample, artifact$sample_key)) {
      section_lines <- c(section_lines, paste0("### ", artifact$sample_label), "")
      current_sample <- artifact$sample_key
    }

    section_lines <- c(
      section_lines,
      build_markdown_all_significant_predictor_narrative(artifact),
      "",
      sprintf("![%s](../figures/%s)", artifact$caption, artifact$figure_file),
      ""
    )
  }

  section_lines
}

build_latex_significance_figure_section <- function(artifacts) {
  if (length(artifacts) == 0L) return(character(0))

  section_lines <- c(
    "",
    "\\subsection{Significance-Driven Figures}",
    escape_latex(
      if (report_includes_nonparametric()) {
        paste(
          "Only hypothesis-relevant predictors that reach p < 0.10 or better are visualized automatically.",
          "These dynamic figures use the saved Tobit and clustered non-parametric outputs,",
          "and participant id remains only an inference-level clustering unit rather than a substantive explanatory variable."
        )
      } else {
        paste(
          "Only hypothesis-relevant predictors that reach p < 0.10 or better are visualized automatically.",
          "These dynamic figures use the saved Tobit outputs,",
          "and participant id remains only an inference-level clustering unit rather than a substantive explanatory variable."
        )
      }
    ),
    ""
  )

  current_hypothesis <- NULL
  for (artifact in artifacts) {
    if (!identical(current_hypothesis, artifact$hypothesis_id)) {
      section_lines <- c(
        section_lines,
        paste0("\\paragraph{", escape_latex(artifact$short_label), "}"),
        ""
      )
      current_hypothesis <- artifact$hypothesis_id
    }

    section_lines <- c(
      section_lines,
      build_latex_significance_figure_narrative(artifact),
      "",
      latex_include_graphic(file.path("../figures", artifact$figure_file), artifact$caption, artifact$latex_label),
      ""
    )
  }

  section_lines
}

build_markdown_significance_figure_section <- function(artifacts) {
  if (length(artifacts) == 0L) return(character(0))

  section_lines <- c(
    "## Significance-Driven Figures",
    if (report_includes_nonparametric()) {
      "Only hypothesis-relevant predictors that reach at least `p < .10` are visualized automatically. These figures rely on the saved Tobit and clustered non-parametric fits, and `id` remains only an inference-level clustering unit."
    } else {
      "Only hypothesis-relevant predictors that reach at least `p < .10` are visualized automatically. These figures rely on the saved Tobit fits, and `id` remains only an inference-level clustering unit."
    },
    ""
  )

  current_hypothesis <- NULL
  for (artifact in artifacts) {
    if (!identical(current_hypothesis, artifact$hypothesis_id)) {
      section_lines <- c(section_lines, paste0("### ", artifact$short_label), "")
      current_hypothesis <- artifact$hypothesis_id
    }

    section_lines <- c(
      section_lines,
      build_markdown_significance_figure_narrative(artifact),
      "",
      sprintf("![%s](../figures/%s)", artifact$caption, artifact$figure_file),
      ""
    )
  }

  section_lines
}

build_hypothesis_conclusion_items <- function(alpha = 0.10) {
  hypothesis_specs <- get_hypothesis_specs(paths = paths)
  vapply(
    hypothesis_specs,
    function(spec) {
      estimator_summaries <- vapply(
        get_report_approaches(),
        function(approach) summarize_estimator_hypothesis(spec, approach, alpha),
        character(1)
      )
      trimws(paste(
        c(sprintf("%s. Original hypothesis: %s", spec$id, spec$statement), estimator_summaries),
        collapse = " "
      ))
    },
    character(1)
  )
}

hypothesis_signal_details <- collect_all_hypothesis_signal_details()
hypothesis_significance_summary <- write_hypothesis_significance_summary(signal_details = hypothesis_signal_details)
hypothesis_figure_artifacts <- build_significance_figure_artifacts(hypothesis_signal_details)
all_significant_predictor_details <- collect_all_significant_predictor_details()
all_significant_predictor_figure_artifacts <- build_all_significant_predictor_figure_artifacts(all_significant_predictor_details)
hypothesis_conclusion_items <- build_hypothesis_conclusion_items()

build_latex_hypothesis_significance_tables <- function(summary_tables) {
  if (!is.list(summary_tables) || length(summary_tables) == 0L) {
    return("Hypothesis summary unavailable.")
  }

  subset_order <- c("Victim", "Bystander")
  unlist(lapply(subset_order, function(subset_role) {
    subset_df <- summary_tables[[subset_role]]
    if (is.null(subset_df)) return(character(0))
    c(
      paste0("\\paragraph{", subset_role, " subset}"),
      to_latex_wrapped_hypothesis_summary(
        subset_df,
        if (report_includes_nonparametric()) {
          sprintf("Hypothesis-level significance summary for the %s subset across Tobit and cluster-aware non-parametric models.", tolower(subset_role))
        } else {
          sprintf("Hypothesis-level significance summary for the %s subset across Tobit models.", tolower(subset_role))
        },
        sprintf("tab:hypothesis_summary_%s", tolower(subset_role))
      ),
      build_latex_note_block(get_abbreviation_note_text()),
      ""
    )
  }), use.names = FALSE)
}

build_markdown_hypothesis_significance_tables <- function(summary_tables) {
  if (!is.list(summary_tables) || length(summary_tables) == 0L) {
    return("Hypothesis summary unavailable.")
  }

  subset_order <- c("Victim", "Bystander")
  unlist(lapply(subset_order, function(subset_role) {
    subset_df <- summary_tables[[subset_role]]
    if (is.null(subset_df)) return(character(0))
    c(
      paste0("### ", subset_role, " subset"),
      to_markdown_table(subset_df),
      build_markdown_note_line(get_abbreviation_note_text()),
      ""
    )
  }), use.names = FALSE)
}

build_estimator_block <- function(output_prefix, estimator_name, table_caption, subset_role) {
  coef_file <- file.path(paths$models_dir, sprintf("%s_coefficients.csv", output_prefix))
  model_file <- file.path(paths$models_dir, sprintf("%s_model.rds", output_prefix))
  fit_stats <- read_fit_stats(output_prefix)

  if (!file.exists(coef_file) || !file.exists(model_file)) {
    failure_text <- if (!is.null(fit_stats) && nrow(fit_stats) > 0L && fit_stats$Status[1] == "failed") {
      sprintf("%s estimation failed: %s", estimator_name, fit_stats$ErrorMessage[1])
    } else {
      sprintf("%s outputs are missing.", estimator_name)
    }

    return(c(
      paste0("\\paragraph{", estimator_name, "}"),
      "",
      escape_latex(failure_text),
      ""
    ))
  }

  coef_df <- read.csv(coef_file, stringsAsFactors = FALSE)
  model_fit <- if (file.exists(model_file)) readRDS(model_file) else NULL
  inference_pending <- all(is.na(coef_df$std_error)) && all(is.na(coef_df$p_value))
  if (!("p_value_display" %in% names(coef_df))) {
    coef_df$p_value_display <- format_p_value(coef_df$p_value)
  }
  if (!("p_symbol" %in% names(coef_df))) {
    coef_df$p_symbol <- significance_symbol(coef_df$p_value)
  }
  label_col <- if ("label_short" %in% names(coef_df)) "label_short" else "label"
  table_df <- coef_df[, c(label_col, "estimate", "std_error", "p_value_display"), drop = FALSE]
  names(table_df) <- c("Predictor", "Estimate", "Std. Error", "p-value")

  table_latex <- to_latex_table(
    table_df,
    sprintf(
      "%s (%s; %s).",
      sub("\\.$", "", table_caption),
      estimator_name,
      format_sample_description(fit_stats, subset_role = subset_role)
    ),
    sprintf("tab:%s", tolower(output_prefix)),
    digits = 3,
    preserve_font_size = TRUE
  )

  narrative <- if (!is.null(model_fit)) {
    generate_coefficient_narrative(coef_df, model_family = get_model_family(model_fit))
  } else {
    "Interpretation could not be generated because the saved model object is unavailable."
  }
  diagnostic_text <- if (!is.null(model_fit)) {
    get_model_diagnostics(model_fit)
  } else {
    "Diagnostics are unavailable because the saved model object is missing."
  }
  if (!report_includes_nonparametric()) {
    diagnostic_text <- sub(
      " and the report pairs it with a cluster-bootstrap non-parametric censored robustness model.",
      ".",
      diagnostic_text,
      fixed = TRUE
    )
  }
  note_lines <- if (inference_pending) {
    c(
      "",
      escape_latex(sprintf(
        "Inference note: %s",
        coef_df$inference[which.max(!is.na(coef_df$inference))]
      )),
      ""
    )
  } else {
    character(0)
  }

  c(
    paste0("\\paragraph{", estimator_name, "}"),
    "",
    table_latex,
    build_latex_note_block(get_abbreviation_note_text()),
    note_lines,
    "",
    "Interpretation:",
    "",
    escape_latex(narrative),
    "",
    "Diagnostics:",
    "",
    escape_latex(diagnostic_text),
    ""
  )
}

# Helper for rendering Tobit plus non-parametric robustness sections.
build_model_section <- function(hypothesis_id, model_suffix, table_caption) {
  clean_caption <- sub("\\.$", "", table_caption)
  subset_blocks <- lapply(c("Victim", "Bystander"), function(subset_role) {
    output_prefix <- sprintf("%s_%s_%s", hypothesis_id, model_suffix, subset_role)
    block_lines <- c(
      paste0("\\paragraph{", subset_role, " subset}"),
      "",
      build_estimator_block(
        output_prefix,
        "Tobit estimator",
        clean_caption,
        subset_role = subset_role
      )
    )
    if (report_includes_nonparametric()) {
      block_lines <- c(
        block_lines,
        "",
        build_estimator_block(
          paste0(output_prefix, "_CLAD"),
          "Non-parametric robustness estimator",
          clean_caption,
          subset_role = subset_role
        )
      )
    }
    c(block_lines, "")
  })

  unlist(subset_blocks, use.names = FALSE)
}

# 2. BUILD LATEX CONTENT
latex_lines <- c(
  "\\documentclass[11pt]{article}",
  "\\usepackage[margin=1in]{geometry}",
  "\\usepackage[T1]{fontenc}",
  "\\usepackage[utf8]{inputenc}",
  "\\usepackage{amsmath, amssymb, amsfonts}",
  "\\usepackage{graphicx}",
  "\\usepackage{array}",
  "\\usepackage{tabularx}",
  "\\usepackage{booktabs}",
  "\\usepackage{float}",
  "\\usepackage{hyperref}",
  if (report_includes_nonparametric()) {
    "\\title{Scientific Analysis of Moral Judgments using Tobit and Cluster-Aware Non-Parametric Robustness Models}"
  } else {
    "\\title{Scientific Analysis of Moral Judgments using Tobit Models with Four Empathy Constructs}"
  },
  "\\author{Automated Research Pipeline}",
  paste0("\\date{", format(Sys.Date(), "%B %d, %Y"), "}"),
  "\\begin{document}",
  "\\maketitle",
  "",
  "\\section{Dataset and Sample Description}",
  escape_latex(paste(get_dataset_narration(paths$dataset_mode), collapse = " ")),
  "",
  "\\section{Datacard and Variable Definitions}",
  "The following table defines the primary symbols and variables used in the mathematical specifications and hypothesis tests.",
  to_latex_table(get_symbols_dictionary(), "Symbols and Variable Dictionary.", "tab:symbols", escape_math = FALSE),
  escape_latex(paste(
    get_case_configuration_option_label(),
    "retains a victim x judged-negotiator shorthand for descriptive summaries, while the executable hypotheses use explicit negotiator-level structure terms. H2 now uses the judged-plus-counterpart structure directly, and in observer rows it adds the player-victim alignment term and its interaction with that structure."
  )),
  "",
  "\\subsection{Predictor Glossary and Abbreviations}",
  "The regression tables and dynamic figures use compact predictor labels to stay readable. The bullet list below maps those compact labels back to their full meaning and subset-specific interpretation.",
  build_latex_predictor_glossary_list(),
  "",
  "\\subsection{Interpretation of Interaction Terms}",
  "The models herein employ several predefined predictors. It is important to note how interaction terms are interpreted in the context of this behavioral experiment:",
  "\\begin{enumerate}",
  "  \\item \\textbf{Interaction Subsumption:} When an interaction term is statistically significant, it indicates that the effect of one variable depends on the level of the other. Crucially, if the interaction is significant but the constituent main effects are not explicitly significant, their effects are fully subsumed and contextualized by the interaction.",
  "  \\item \\textbf{Continuous by Discrete Interactions:} For terms like \\texttt{iri\\_total:judged\\_outgroup}, a negative coefficient implies that the severity of moral judgment (lower score) induced by higher empathy is steeper (magnified) when evaluating an outgroup negotiator relative to the control-labeled baseline. A positive coefficient would mean empathy makes judgments less severe for that outgroup condition.",
  "  \\item \\textbf{Discrete by Discrete Interactions:} For terms like \\texttt{judged\\_outgroup:decision\\_accept}, a positive coefficient implies that the change in moral judgment when moving from rejecting a deal to accepting a deal is more positive (less morally condemned) for an outgroup negotiator than for the control-labeled baseline condition.",
  "\\end{enumerate}",
  "",
  "\\section{Hypotheses to Test}",
  "\\begin{itemize}",
  vapply(
    report_hypothesis_specs,
    function(spec) {
      paste0(
        "  \\item \\textbf{",
        escape_latex(spec$id),
        " (",
        escape_latex(spec$focus_label),
        "):} ",
        escape_latex(spec$statement)
      )
    },
    character(1)
  ),
  "\\end{itemize}",
  "",
  "\\section{Mathematical Approach and Theoretical Foundations}",
  paste(get_math_foundations(), collapse = "\n"),
  "",
  "\\section{Analysis of Sample Size Impact}",
  paste(get_error_analysis_narration(), collapse = "\n"),
  sprintf("\nBased on the current run, the observed Intraclass Correlation (ICC) is %.3f, with an Effective Sample Size (ESS) of %.1f.", power_results$ICC, power_results$EffectiveN),
  "",
  "\\section{Descriptive Statistics}",
  paste0(
    "The empathy profile of the sample is visualized in Figure \\ref{fig:radar}, showing the average scores ",
    "across the four IRI subscales (Fantasy, Empathic Concern, Perspective Taking, Personal Distress), ",
    "each scored 0\u20134 (scale mean per subscale)."
  ),
  latex_include_graphic(file.path("../figures", figure_radar_file), "IRI subscale averages (radar plot; scale 0--4 per subscale).", "fig:radar", escape = FALSE),
  paste0(
    "Figure \\ref{fig:severity_panels} shows severity distributions pooled across the full analytical sample, ",
    "broken down by N1 group membership (\\textit{group\\_target}: Ingroup, Outgroup, Control). ",
    "Figures \\ref{fig:victim_case_panels} and \\ref{fig:bystander_case_panels} replicate this breakdown ",
    "separately within the victim and bystander subsets. Figure \\ref{fig:accepted_case_panels} adds the ",
    "bystander-subset view by observer\u2013victim group alignment (\\textit{obs\\_group}), and ",
    "Figure \\ref{fig:rejected_case_panels} shows the N2 group panels (\\textit{group\\_other}) ",
    "for the full sample."
  ),
  latex_include_graphic(file.path("../figures", figure_severity_panels_file),
    "Judgment severity by N1 group (\\textit{group\\_target}: Ingroup, Outgroup, Control) --- full analytical sample, scale $-9$ to $9$.",
    "fig:severity_panels", escape = FALSE),
  latex_include_graphic(file.path("../figures", figure_victim_case_panels_file),
    "Victim-subset severity by N1 group (\\textit{group\\_target}), scale $-9$ to $9$.",
    "fig:victim_case_panels", escape = FALSE),
  latex_include_graphic(file.path("../figures", figure_bystander_case_panels_file),
    "Bystander-subset severity by N1 group (\\textit{group\\_target}), scale $-9$ to $9$.",
    "fig:bystander_case_panels", escape = FALSE),
  latex_include_graphic(file.path("../figures", figure_accepted_case_panels_file),
    "Bystander-subset severity by observer--victim group alignment (\\textit{obs\\_group}: Ingroup, Outgroup), scale $-9$ to $9$.",
    "fig:accepted_case_panels", escape = FALSE),
  latex_include_graphic(file.path("../figures", figure_rejected_case_panels_file),
    "Judgment severity by N2 group (\\textit{group\\_other}: Ingroup, Outgroup, Control) --- full analytical sample, scale $-9$ to $9$.",
    "fig:rejected_case_panels", escape = FALSE),
  paste0(
    "When a control-labeled negotiator condition exists, the active hypothesis models treat that control level as the reference category. ",
    "Observer--victim alignment remains binary and therefore keeps ingroup as its reference level."
  ),
  "",
  "\\section{Bi-variate Statistics}",
  "The correlation matrix between the psychometric subscales and the mean moral judgment is presented below.",
  to_latex_table(bivar_cor, "Correlation Matrix: IRI Subscales and Moral Judgment.", "tab:bivar"),
  "",
  "\\section{Estimator Fit Summary}",
  if (report_includes_nonparametric()) {
    "The following table consolidates the fit-status information for the primary Tobit models and the non-parametric robustness branch. In the default pipeline, participant-level cluster bootstrap launches immediately after a converged full-sample non-parametric fit is available; if bootstrap is disabled manually or too few bootstrap refits converge, that status is shown explicitly."
  } else {
    "The following table consolidates the fit-status information for the primary Tobit models used in this report."
  },
  if (report_includes_nonparametric()) {
    escape_latex(sprintf(
      "This run uses %s participant-level bootstrap replicate%s for the non-parametric branch. A bootstrap_failed status means the full-sample CLAD fit converged but none of the attempted bootstrap refits converged; it does not imply that the full non-parametric estimator itself failed to converge.",
      configured_clad_bootstrap_reps,
      if (configured_clad_bootstrap_reps == 1L) "" else "s"
    ))
  } else {
    NULL
  },
  if (!is.null(model_fit_summary)) {
    to_latex_table(
      model_fit_summary[, if (report_includes_nonparametric()) {
        c("Model", "Approach", "Status", "Converged", "Iterations", "BootstrapReplicates", "BootstrapSuccessful", "Observations", "Participants", "ClusterUnit")
      } else {
        c("Model", "Approach", "Status", "Iterations", "Observations", "Participants", "ClusterUnit")
      }],
      if (report_includes_nonparametric()) {
        "Estimator fit summary across Tobit and cluster-aware non-parametric specifications."
      } else {
        "Estimator fit summary across Tobit specifications."
      },
      "tab:model_fit_summary"
    )
  } else {
    "Model fit summary unavailable."
  },
  "",
  "\\subsection{Hypothesis Significance Summary}",
  if (report_includes_nonparametric()) {
    "The following concise tables list only hypothesis-relevant predictors that reached at least p < 0.10, split by victim and bystander subsets, using conventional symbols to indicate strength of evidence (+ p < 0.10, * p < 0.05, ** p < 0.01, *** p < 0.001). If the non-parametric bootstrap is disabled, too sparse, or the censored median fit does not converge, the non-parametric column reports that status instead of inferential symbols. Dynamic figures are generated only for predictors that appear in these tables with at least one significance symbol."
  } else {
    "The following concise tables list only hypothesis-relevant predictors that reached at least p < 0.10 in the available Tobit models, split by victim and bystander subsets, using conventional symbols to indicate strength of evidence (+ p < 0.10, * p < 0.05, ** p < 0.01, *** p < 0.001). Dynamic figures are generated only for predictors that appear in these tables with at least one significance symbol."
  },
  if (!is.null(hypothesis_significance_summary)) {
    build_latex_hypothesis_significance_tables(hypothesis_significance_summary)
  } else {
    "Hypothesis summary unavailable."
  },
  build_latex_significance_figure_section(hypothesis_figure_artifacts),
  build_latex_all_significant_predictor_figure_section(all_significant_predictor_figure_artifacts),
  "",
  "\\subsection{Integrated Hypothesis Conclusions}",
  if (report_includes_nonparametric()) {
    "The following summary restates each original hypothesis and indicates whether the available Tobit estimates and the cluster-aware non-parametric models support it in the current data. Non-parametric conclusions are drawn when the participant-level bootstrap inference is available and are otherwise labeled explicitly."
  } else {
    "The following summary restates each original hypothesis and indicates whether the available Tobit estimates support it in the current data."
  },
  "\\begin{itemize}",
  paste0("\\item ", escape_latex(hypothesis_conclusion_items)),
  "\\end{itemize}",
  "",
  "\\section{Hypothesis Validation and Results}",
  if (report_includes_nonparametric()) {
    "Detailed coefficient tables for each Tobit model, coupled with non-parametric robustness outputs, natural language interpretive narratives, and estimator-specific diagnostics, are provided below. In the default pipeline, converged non-parametric fits immediately attempt participant-level cluster-bootstrap inference; the report labels deferred and sparse-bootstrap cases explicitly when full inference is not available."
  } else {
    "Detailed coefficient tables for each Tobit model, including predictor estimates, standard errors, p-values with conventional significance symbols, and estimator diagnostics for the victim and bystander subsets, are provided below."
  },
  "",
  "\\subsection{H1: Empathy Effect}",
  "This section evaluates H1 separately in the victim and bystander subsets using the four IRI subscales as the active empathy specification: fantasy, empathic concern, perspective taking, and personal distress. The formula retains judged-negotiator status, counterpart status, decision outcome, and participant controls for sex, age, and economic status, while the bystander subset additionally includes the observer-side victim-alignment predictor because it is meaningful only in that subset.",
  "\\subsubsection{Active Empathy-Construct Specification}",
  build_subset_formula_lines(report_h1_spec, "B"),
  build_model_section("H1", "B", "H1 active model: empathy-construct Tobit coefficients."),
  "",
  "\\subsection{H2: Negotiator-Side Relational Structure}",
  "This section estimates H2 separately in the victim and bystander subsets. The dependent variable remains negotiator-specific judgment severity, so each participant contributes two judgment rows per scenario, one for each negotiator. In the victim subset, H2 uses the joint judged-plus-counterpart negotiator structure relative to the victim-player, with the control-labeled N1 plus control-labeled N2 condition as the reference structure. In the bystander subset, the same negotiator-side structure is defined relative to the observing player's faculty, and the model additionally includes the player-victim outgroup term and its interaction with the negotiator-side structure dummies.",
  "Victim-subset equation: $y^*_{isj,Victim} = \\beta_0 + \\beta_1 \\text{Empathy}_i + \\boldsymbol{\\gamma}' \\mathbf{S}^{(V)}_{isj} + \\boldsymbol{\\delta}' \\mathbf{Z}_i + \\epsilon_{isj}$, where $\\mathbf{S}^{(V)}_{isj}$ indexes the judged-plus-counterpart structure dummies and $\\mathbf{Z}_i$ collects participant controls.",
  "Bystander-subset equation: $y^*_{isj,Obs} = \\beta_0 + \\beta_1 \\text{Empathy}_i + \\boldsymbol{\\gamma}' \\mathbf{S}^{(O)}_{isj} + \\eta V_{is} + \\boldsymbol{\\theta}' (\\mathbf{S}^{(O)}_{isj} \\times V_{is}) + \\boldsymbol{\\delta}' \\mathbf{Z}_i + \\epsilon_{isj}$, where $V_{is}$ is the player-victim outgroup indicator.",
  "\\subsubsection{Active Empathy-Construct Specification}",
  build_subset_formula_lines(report_h2_spec, "B"),
  build_model_section("H2", "B", "H2 active model: empathy-construct Tobit coefficients."),
  "",
  "\\subsection{H3: Empathy x Judged-Status Moderation}",
  "This section tests whether empathy slopes differ across judged-negotiator status categories after retaining decision outcome, judged-status x decision terms, counterpart status, and observer-side victim alignment when that predictor is meaningful. As in H1, the victim and bystander subsets use different formulas only where observer-only predictors would otherwise be structurally fixed.",
  "\\subsubsection{Active Empathy-Construct Specification}",
  build_subset_formula_lines(report_h3_spec, "B"),
  build_model_section("H3", "B", "H3 active model: empathy-construct Tobit coefficients."),
  "",
  "\\section{Discussion and Limitations}",
  paste(get_limitations_narration(), collapse = " "),
  "",
  "\\section{Conclusion}",
  "Based on the interval-censored Tobit estimations using the four empathy constructs, empathy and relational judgment structure have been documented together under Option 2 through negotiator-level relational predictors rather than descriptive case labels.",
  "\\end{document}"
)

tex_path <- file.path(paths$report_dir, "tobit_analysis_report.tex")
write_text_file(latex_lines, tex_path)

# Rendering Markdown is temporarily simplified to focus on standardizing the LaTeX/PDF engine.
md_lines <- c(
  if (report_includes_nonparametric()) {
    "# Scientific Analysis of Moral Judgments with Tobit and Cluster-Aware Non-Parametric Robustness Checks"
  } else {
    "# Scientific Analysis of Moral Judgments with Tobit Models and Four Empathy Constructs"
  },
  "",
  "## Dataset Description",
  paste(get_dataset_narration(paths$dataset_mode), collapse = " "),
  "",
  "## Option 2 Relational Case Configuration",
  paste(
    "All hypothesis sections are now interpreted through negotiator-level relational predictors rather than descriptive case labels."
  ),
  "",
  "## Predictor Glossary and Abbreviations",
  "The regression tables and dynamic figures use compact predictor labels to keep long H2 and H3 rows readable. The bullet list below maps those compact labels back to the full meanings used in the manuscript.",
  build_markdown_predictor_glossary_list(),
  "",
  "## Interpretation of Interaction Terms",
  "The models herein employ several predefined predictors. It is important to note how interaction terms are interpreted in the context of this behavioral experiment:",
  "",
  "1. **Interaction Subsumption:** When an interaction term is statistically significant, it indicates that the effect of one variable depends on the level of the other. Crucially, if the interaction is significant but the constituent main effects are not explicitly significant, their effects are fully subsumed and contextualized by the interaction.",
  "2. **Continuous by Discrete Interactions:** For terms like `iri_pt:judged_outgroup`, a negative coefficient implies that the severity of moral judgment (lower score) induced by higher empathy is steeper (magnified) when evaluating an outgroup negotiator relative to the control-labeled baseline. A positive coefficient would mean empathy makes judgments less severe for that outgroup condition.",
  "3. **Discrete by Discrete Interactions:** For terms like `judged_outgroup:decision_accept`, a positive coefficient implies that the change in moral judgment when moving from rejecting a deal to accepting a deal is more positive (less morally condemned) for an outgroup negotiator than for the control-labeled baseline condition.",
  "",
  "## Hypothesis Significance Summary",
  if (report_includes_nonparametric()) {
    "Only hypothesis-relevant predictors with p < 0.10 are shown below, split into victim and bystander subset tables. Symbols follow the rule `+` for p < 0.10, `*` for p < 0.05, `**` for p < 0.01, and `***` for p < 0.001. If bootstrap is disabled for a run, too few non-parametric bootstrap refits succeed, or the non-parametric fit does not converge, the non-parametric column reports that status explicitly. Dynamic figures are generated only for predictors that appear here with at least one significance symbol."
  } else {
    "Only hypothesis-relevant predictors with p < 0.10 in the available Tobit models are shown below, split into victim and bystander subset tables. Symbols follow the rule `+` for p < 0.10, `*` for p < 0.05, `**` for p < 0.01, and `***` for p < 0.001. Dynamic figures are generated only for predictors that appear here with at least one significance symbol."
  },
  build_markdown_hypothesis_significance_tables(hypothesis_significance_summary),
  "",
  build_markdown_significance_figure_section(hypothesis_figure_artifacts),
  "",
  build_markdown_all_significant_predictor_figure_section(all_significant_predictor_figure_artifacts),
  "",
  "## Hypothesis Conclusion Summary",
  if (report_includes_nonparametric()) {
    "Each conclusion below is generated from the current coefficient outputs. Non-parametric statements are interpreted when participant-level cluster-bootstrap inference is available and are otherwise labeled explicitly."
  } else {
    "Each conclusion below is generated from the current Tobit coefficient outputs."
  },
  paste0("- ", hypothesis_conclusion_items),
  "",
  "## PDF Comprehensive Report Generated",
  "Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented Tobit and cluster-aware non-parametric mathematical formulations, the Option 2 relational-variable logic, dual-estimator hypothesis testing, and the algorithmically interpreted natural language coefficients. When the run is dataset-specific, a matching alias such as `tobit_analysis_report_Buca.pdf` is also refreshed.",
  ""
)
write_text_file(md_lines, file.path(paths$report_dir, "tobit_analysis_report.md"))
write_text_file(md_lines, file.path(paths$logs_dir, "dynamic_report.md"))

# 3. RENDERING HELPER (Word and PDF)
render_pdf <- function(tex_file) {
  pdflatex_cmd <- Sys.which("pdflatex")
  if (!nzchar(pdflatex_cmd)) {
    warning("pdflatex not found; skipping PDF render.")
    return(FALSE)
  }

  report_dir <- normalizePath(dirname(tex_file), winslash = "/", mustWork = TRUE)
  tex_name <- basename(tex_file)
  build_jobname <- paste0(tools::file_path_sans_ext(tex_name), "_build")
  pdf_name <- sub("\\.tex$", ".pdf", tex_name)
  log_name <- sub("\\.tex$", ".log", tex_name)
  aux_name <- sub("\\.tex$", ".aux", tex_name)
  out_name <- sub("\\.tex$", ".out", tex_name)

  old_wd <- getwd()
  setwd(report_dir)
  on.exit(setwd(old_wd), add = TRUE)

  latex_args <- c(
    "-interaction=nonstopmode",
    paste0("-jobname=", build_jobname),
    tex_name
  )

  build_statuses <- integer(3)
  for (pass_idx in seq_along(build_statuses)) {
    build_statuses[pass_idx] <- system2(pdflatex_cmd, args = latex_args, stdout = NULL, stderr = NULL)
  }

  build_pdf <- file.path(report_dir, paste0(build_jobname, ".pdf"))
  build_log <- file.path(report_dir, paste0(build_jobname, ".log"))
  build_aux <- file.path(report_dir, paste0(build_jobname, ".aux"))
  build_out <- file.path(report_dir, paste0(build_jobname, ".out"))
  target_pdf <- file.path(report_dir, pdf_name)
  target_log <- file.path(report_dir, log_name)
  target_aux <- file.path(report_dir, aux_name)
  target_out <- file.path(report_dir, out_name)
  build_artifacts <- c(build_pdf, build_log, build_aux, build_out)
  cleanup_build_artifacts <- TRUE
  on.exit(if (cleanup_build_artifacts) unlink(build_artifacts[file.exists(build_artifacts)], force = TRUE), add = TRUE)

  if (file.exists(build_log)) {
    file.copy(build_log, target_log, overwrite = TRUE)
  }
  if (file.exists(build_aux)) {
    file.copy(build_aux, target_aux, overwrite = TRUE)
  }
  if (file.exists(build_out)) {
    file.copy(build_out, target_out, overwrite = TRUE)
  }

  if (!file.exists(build_pdf)) {
    warning(sprintf(
      "pdflatex failed while rendering %s. Inspect %s for details.",
      pdf_name,
      target_log
    ))
    return(FALSE)
  }

  copied <- file.copy(build_pdf, target_pdf, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
  if (copied) {
    if (any(build_statuses != 0L)) {
      warning(sprintf(
        paste(
          "pdflatex reported recoverable issues while rendering %s,",
          "but a PDF was produced and copied successfully.",
          "Inspect %s if you want to clean up the LaTeX warnings."
        ),
        pdf_name,
        target_log
      ))
    }
    return(TRUE)
  }

  fallback_pdf <- file.path(
    report_dir,
    sprintf(
      "%s_updated_%s.pdf",
      tools::file_path_sans_ext(pdf_name),
      format(Sys.time(), "%Y%m%d_%H%M%S")
    )
  )
  fallback_written <- file.copy(build_pdf, fallback_pdf, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
  if (!fallback_written) {
    cleanup_build_artifacts <- FALSE
  }

  warning(sprintf(
    paste(
      "Built a fresh PDF but could not overwrite %s.",
      "This usually means the file is open in another program.",
      "Updated copy saved to %s."
    ),
    target_pdf,
    if (fallback_written) fallback_pdf else build_pdf
  ))
  FALSE
}
render_word <- function(md_file) {
  pandoc_cmd <- Sys.which("pandoc")
  if (!nzchar(pandoc_cmd)) {
    warning("pandoc not found; skipping Word render.")
    return(FALSE)
  }
  old_wd <- getwd(); setwd(dirname(md_file)); on.exit(setwd(old_wd))
  docx_name <- gsub("\\.md$", ".docx", basename(md_file))
  status <- system2(pandoc_cmd, args = c("-s", basename(md_file), "-o", docx_name), stdout = NULL, stderr = NULL)
  if (!identical(status, 0L) || !file.exists(docx_name)) {
    warning(sprintf("Pandoc failed while rendering %s.", docx_name))
    return(FALSE)
  }
  TRUE
}

pdf_rendered <- render_pdf(tex_path)
word_rendered <- render_word(file.path(paths$report_dir, "tobit_analysis_report.md"))
sync_dataset_specific_report_aliases(paths$dataset_mode)

if (pdf_rendered) {
  message("Scientific manuscript expansion complete.")
} else {
  warning("Scientific manuscript generated, but the primary PDF was not refreshed. Review the warnings above.")
}

if (!word_rendered) {
  warning("Word report was not refreshed.")
}
