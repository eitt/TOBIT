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
source("R/utils/figure_functions.R")
source("R/utils/significance_figure_functions.R")
source("R/utils/nl_generation.R")
paths <- get_project_paths()
case_examples_latex <- paste(get_case_configuration_example_labels(latex = TRUE), collapse = ", ")

message("Generating Comprehensive Scientific Manuscript (LaTeX/PDF/Word)...")

# 1. LOAD DATA & ASSETS
judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)
power_results <- calc_effective_sample_size(judgments_accept$judgement, judgments_accept$id)
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
    pattern = "^(H1|H2a|H2b|H3)_(A|B)(_CLAD)?_fit_stats\\.csv$",
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

read_model_bundle <- function(hypothesis_id, model_suffix, approach) {
  output_prefix <- paste0(hypothesis_id, "_", model_suffix, if (approach == "CLAD") "_CLAD" else "")
  coef_file <- file.path(paths$models_dir, sprintf("%s_coefficients.csv", output_prefix))
  fit_stats <- read_fit_stats(output_prefix)
  coef_df <- if (file.exists(coef_file)) read.csv(coef_file, stringsAsFactors = FALSE) else NULL

  list(
    hypothesis_id = hypothesis_id,
    model_suffix = model_suffix,
    approach = approach,
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

assess_model_terms <- function(bundle, term_info, expected_direction, alpha = 0.05) {
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

summarize_additional_signals <- function(bundles, excluded_terms, alpha = 0.05, max_terms = 2L) {
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

summarize_estimator_hypothesis <- function(spec, approach, alpha = 0.05) {
  bundles <- list(
    A = read_model_bundle(spec$id, "A", approach),
    B = read_model_bundle(spec$id, "B", approach)
  )
  assessments <- list(
    A = assess_model_terms(bundles$A, spec$model_terms$A, spec$expected_direction, alpha),
    B = assess_model_terms(bundles$B, spec$model_terms$B, spec$expected_direction, alpha)
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

get_hypothesis_specs <- function() {
  accepted_case_terms <- get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = TRUE)
  betrayal_case_terms <- get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = FALSE)
  accepted_total_interactions <- get_case_configuration_interaction_terms(
    "iri_total",
    reference = "Hum_x_Hum",
    include_control = TRUE
  )
  accepted_scale_interactions <- get_case_configuration_interaction_terms(
    c("iri_fs", "iri_ec", "iri_pt", "iri_pd"),
    reference = "Hum_x_Hum",
    include_control = TRUE
  )

  list(
    list(
      id = "H1",
      short_label = "H1: Empathy under explicit case configuration",
      data_path = paths$processed_accept,
      statement = paste(
        "Higher empathy predicts lower moral-judgment scores for harmful decisions after",
        "conditioning on explicit victim x negotiator case configurations."
      ),
      expected_direction = "negative",
      model_terms = list(
        A = list(terms = c("iri_total"), description = "the composite empathy term"),
        B = list(terms = c("iri_fs", "iri_ec", "iri_pt", "iri_pd"), description = "the empathy subscale main effects")
      ),
      exclude_terms = c("iri_total", "iri_fs", "iri_ec", "iri_pt", "iri_pd", accepted_case_terms)
    ),
    list(
      id = "H2a",
      short_label = "H2a: Relational betrayal contrasts",
      data_path = paths$processed_betrayal,
      statement = paste(
        "Same-faculty and cross-faculty betrayal cases are evaluated through explicit",
        "victim x negotiator configurations rather than a single same_group_harm flag."
      ),
      expected_direction = "either",
      model_terms = list(
        A = list(terms = betrayal_case_terms, description = "the betrayal-sample case-configuration contrasts"),
        B = list(terms = betrayal_case_terms, description = "the betrayal-sample case-configuration contrasts")
      ),
      exclude_terms = betrayal_case_terms
    ),
    list(
      id = "H2b",
      short_label = "H2b: Explicit case-configuration contrasts",
      data_path = paths$processed_accept,
      statement = paste(
        "Relational judgments are interpreted through explicit victim x negotiator",
        "case configurations such as Hum_x_Ing, Hum_x_Control, Ing_x_Hum, Ing_x_Ing, and Ing_x_Control."
      ),
      expected_direction = "either",
      model_terms = list(
        A = list(terms = accepted_case_terms, description = "the accepted-sample case-configuration contrasts"),
        B = list(terms = accepted_case_terms, description = "the accepted-sample case-configuration contrasts")
      ),
      exclude_terms = accepted_case_terms
    ),
    list(
      id = "H3",
      short_label = "H3: Empathy x case-configuration moderation",
      data_path = paths$processed_accept,
      statement = paste(
        "The empathy effect may vary across explicit victim x negotiator pairings,",
        "so moderation is modeled through empathy interactions with case-configuration contrasts."
      ),
      expected_direction = "either",
      model_terms = list(
        A = list(
          terms = accepted_total_interactions,
          description = "the composite empathy x case-configuration interactions"
        ),
        B = list(
          terms = accepted_scale_interactions,
          description = "the empathy-dimension x case-configuration interactions"
        )
      ),
      exclude_terms = c(accepted_total_interactions, accepted_scale_interactions)
    )
  )
}

empty_signal_details_df <- function() {
  data.frame(
    hypothesis_id = character(0),
    hypothesis_statement = character(0),
    short_label = character(0),
    data_path = character(0),
    approach = character(0),
    model_suffix = character(0),
    output_prefix = character(0),
    term = character(0),
    canonical_term = character(0),
    label = character(0),
    estimate = numeric(0),
    p_value = numeric(0),
    symbol = character(0),
    stringsAsFactors = FALSE
  )
}

significance_symbol <- function(p_value) {
  if (is.na(p_value)) return("")
  if (p_value < 0.01) return("**")
  if (p_value < 0.05) return("*")
  if (p_value < 0.10) return("+")
  ""
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
    approach = c("Tobit", "CLAD"),
    model_suffix = c("A", "B"),
    stringsAsFactors = FALSE
  )
  target_terms <- unlist(lapply(spec$model_terms, `[[`, "terms"), use.names = FALSE)
  signal_rows <- lapply(seq_len(nrow(bundle_grid)), function(idx) {
    approach <- bundle_grid$approach[idx]
    model_suffix <- bundle_grid$model_suffix[idx]
    bundle <- read_model_bundle(spec$id, model_suffix, approach)
    if (!isTRUE(bundle$available) || is.null(bundle$coef_df) || nrow(bundle$coef_df) == 0L) {
      return(NULL)
    }
    rows <- select_hypothesis_rows(bundle$coef_df, target_terms)
    if (is.null(rows) || nrow(rows) == 0L) return(NULL)
    rows$canonical_term <- vapply(rows$term, canonicalize_term_name, character(1))
    rows <- rows[!is.na(rows$p_value) & rows$p_value < alpha, , drop = FALSE]
    if (nrow(rows) == 0L) return(NULL)

    data.frame(
      hypothesis_id = spec$id,
      hypothesis_statement = spec$statement,
      short_label = spec$short_label,
      data_path = spec$data_path,
      approach = bundle$approach,
      model_suffix = model_suffix,
      output_prefix = bundle$output_prefix,
      term = rows$term,
      canonical_term = rows$canonical_term,
      label = rows$label,
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
  hypothesis_specs <- get_hypothesis_specs()
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
  hypothesis_specs <- get_hypothesis_specs()
  bundle_grid <- expand.grid(
    hypothesis_idx = seq_along(hypothesis_specs),
    approach = c("Tobit", "CLAD"),
    model_suffix = c("A", "B"),
    stringsAsFactors = FALSE
  )

  signal_rows <- lapply(seq_len(nrow(bundle_grid)), function(idx) {
    spec <- hypothesis_specs[[bundle_grid$hypothesis_idx[idx]]]
    bundle <- read_model_bundle(spec$id, bundle_grid$model_suffix[idx], bundle_grid$approach[idx])
    if (!isTRUE(bundle$available) || is.null(bundle$coef_df) || nrow(bundle$coef_df) == 0L) {
      return(NULL)
    }

    rows <- filter_significant_coefficients(bundle$coef_df, alpha = alpha)
    if (is.null(rows) || nrow(rows) == 0L) return(NULL)

    data.frame(
      hypothesis_id = spec$id,
      hypothesis_statement = spec$statement,
      short_label = spec$short_label,
      data_path = spec$data_path,
      approach = bundle$approach,
      model_suffix = bundle_grid$model_suffix[idx],
      output_prefix = bundle$output_prefix,
      term = rows$term,
      canonical_term = rows$canonical_term,
      label = rows$label,
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
  bundles <- list(
    A = read_model_bundle(spec$id, "A", approach),
    B = read_model_bundle(spec$id, "B", approach)
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
  signal_df <- signal_df[order(signal_df$p_value, signal_df$label), , drop = FALSE]
  if (nrow(signal_df) == 0L) {
    return("None")
  }

  signal_df <- signal_df[!duplicated(signal_df$canonical_term), , drop = FALSE]
  formatted_terms <- paste0(signal_df$label, signal_df$symbol)
  paste(formatted_terms, collapse = "; ")
}

write_hypothesis_significance_summary <- function(alpha = 0.10, signal_details = NULL) {
  hypothesis_specs <- get_hypothesis_specs()
  if (is.null(signal_details)) {
    signal_details <- collect_all_hypothesis_signal_details(alpha = alpha)
  }
  summary_df <- data.frame(
    Hypothesis = vapply(hypothesis_specs, function(spec) spec$statement, character(1)),
    `Tobit significant predictors` = vapply(
      hypothesis_specs,
      function(spec) collect_hypothesis_signals(spec, "Tobit", alpha, signal_details = signal_details),
      character(1)
    ),
    `Non-parametric significant predictors` = vapply(
      hypothesis_specs,
      function(spec) collect_hypothesis_signals(spec, "CLAD", alpha, signal_details = signal_details),
      character(1)
    ),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  write.csv(summary_df, file.path(paths$tables_dir, "hypothesis_summary.csv"), row.names = FALSE)
  summary_df
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
    empty_catalog <- data.frame(
      Hypothesis = character(0),
      Predictor = character(0),
      Figure = character(0),
      FigureType = character(0),
      `Tobit support` = character(0),
      `Non-parametric support` = character(0),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    write.csv(empty_catalog, file.path(paths$tables_dir, "hypothesis_figure_catalog.csv"), row.names = FALSE)
    return(list())
  }

  hypothesis_lookup <- stats::setNames(get_hypothesis_specs(), vapply(get_hypothesis_specs(), `[[`, character(1), "id"))
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

    model_data <- read.csv(spec$data_path, stringsAsFactors = FALSE)
    visual_spec <- build_term_visual_spec(canonical_term, model_data)
    figure_file <- sprintf("figure_sig_%s_%s.png", hypothesis_id, sanitize_identifier(canonical_term))
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
      sprintf("%s: %s", spec$id, label_term(canonical_term))
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
      "%s for %s in %s. Support comes from %s. The panels show predicted latent judgments with 95%% confidence intervals.",
      tools::toTitleCase(figure_type),
      label_term(canonical_term),
      spec$short_label,
      support_phrase
    )

    artifacts[[idx]] <- list(
      hypothesis_id = hypothesis_id,
      hypothesis_statement = spec$statement,
      short_label = spec$short_label,
      canonical_term = canonical_term,
      label = label_term(canonical_term),
      figure_file = figure_file,
      figure_path = figure_path,
      latex_label = latex_label,
      support_rows = support_rows,
      support_phrase = support_phrase,
      caption = caption,
      pattern_text = pattern_text,
      min_p_value = min(support_rows$p_value, na.rm = TRUE)
    )

    catalog_rows[[idx]] <- data.frame(
      Hypothesis = spec$statement,
      Predictor = label_term(canonical_term),
      Figure = figure_file,
      FigureType = figure_type,
      `Tobit support` = if (any(support_rows$approach == "Tobit")) {
        paste0(support_rows$label[support_rows$approach == "Tobit"], support_rows$symbol[support_rows$approach == "Tobit"], collapse = "; ")
      } else {
        "None"
      },
      `Non-parametric support` = if (any(support_rows$approach == "CLAD")) {
        paste0(support_rows$label[support_rows$approach == "CLAD"], support_rows$symbol[support_rows$approach == "CLAD"], collapse = "; ")
      } else {
        "None"
      },
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  }

  write.csv(
    do.call(rbind, catalog_rows),
    file.path(paths$tables_dir, "hypothesis_figure_catalog.csv"),
    row.names = FALSE
  )
  artifacts
}

describe_signal_sample <- function(data_path) {
  normalized_path <- normalizePath(data_path, winslash = "/", mustWork = FALSE)
  accepted_path <- normalizePath(paths$processed_accept, winslash = "/", mustWork = FALSE)
  betrayal_path <- normalizePath(paths$processed_betrayal, winslash = "/", mustWork = FALSE)
  judgments_path <- normalizePath(paths$processed_judgments, winslash = "/", mustWork = FALSE)

  if (identical(normalized_path, accepted_path)) {
    return("Accepted-decision sample")
  }
  if (identical(normalized_path, betrayal_path)) {
    return("Betrayal sample")
  }
  if (identical(normalized_path, judgments_path)) {
    return("Full judgment sample")
  }
  tools::file_path_sans_ext(basename(data_path))
}

format_support_model_rows <- function(rows, approach = NULL) {
  if (!is.null(approach)) {
    rows <- rows[rows$approach == approach, , drop = FALSE]
  }
  if (nrow(rows) == 0L) return("None")
  rows <- rows[order(rows$p_value, rows$short_label, rows$model_suffix), , drop = FALSE]
  descriptors <- paste0(rows$short_label, " Model ", rows$model_suffix, rows$symbol)
  paste(unique(descriptors), collapse = "; ")
}

summarize_supporting_models <- function(rows) {
  rows <- rows[order(rows$p_value, rows$short_label, rows$model_suffix), , drop = FALSE]
  descriptors <- paste0(rows$short_label, " Model ", rows$model_suffix, " (", rows$approach, ")")
  collapse_with_and(unique(descriptors))
}

build_all_significant_predictor_figure_artifacts <- function(signal_details) {
  if (is.null(signal_details) || nrow(signal_details) == 0L) {
    empty_catalog <- data.frame(
      Sample = character(0),
      Predictor = character(0),
      Figure = character(0),
      FigureType = character(0),
      `Tobit support` = character(0),
      `Non-parametric support` = character(0),
      `Supporting models` = character(0),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
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
    figure_file <- sprintf(
      "figure_sig_all_%s_%s.png",
      sanitize_identifier(sample_label),
      sanitize_identifier(canonical_term)
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
      sprintf("%s: %s", sample_label, label_term(canonical_term))
    )

    support_phrase <- summarize_support_phrases(support_rows)
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
      "%s for %s in the %s. Statistically significant support appears in %s. The panels show predicted latent judgments with 95%% confidence intervals.",
      tools::toTitleCase(figure_type),
      label_term(canonical_term),
      sample_label,
      supporting_models
    )

    artifacts[[idx]] <- list(
      sample_label = sample_label,
      sample_key = sanitize_identifier(sample_label),
      canonical_term = canonical_term,
      label = label_term(canonical_term),
      figure_file = figure_file,
      figure_path = figure_path,
      latex_label = latex_label,
      support_rows = support_rows,
      support_rows_all = support_rows_all,
      support_phrase = support_phrase,
      supporting_models = supporting_models,
      caption = caption,
      pattern_text = pattern_text,
      min_p_value = min(support_rows_all$p_value, na.rm = TRUE)
    )

    catalog_rows[[idx]] <- data.frame(
      Sample = sample_label,
      Predictor = label_term(canonical_term),
      Figure = figure_file,
      FigureType = figure_type,
      `Tobit support` = format_support_model_rows(support_rows_all, approach = "Tobit"),
      `Non-parametric support` = format_support_model_rows(support_rows_all, approach = "CLAD"),
      `Supporting models` = supporting_models,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
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
      paste(
        "The following figures extend beyond the hypothesis-target terms and visualize every predictor",
        "that reaches p < 0.10 in the available H1-H3 Tobit or clustered non-parametric models.",
        "This includes significant controls such as age when they clear the threshold."
      )
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
      escape_latex(sprintf("%s is statistically significant in %s. Figure \\ref{%s} shows that %s.", artifact$label, artifact$supporting_models, artifact$latex_label, artifact$pattern_text)),
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
    "The following figures extend beyond the hypothesis-target terms and visualize every predictor that reaches `p < .10` in the available H1-H3 Tobit or clustered non-parametric models. This includes significant controls such as age when they clear the threshold.",
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
      sprintf("%s is statistically significant in %s. The figure below shows that %s.", artifact$label, artifact$supporting_models, artifact$pattern_text),
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
      paste(
        "Only hypothesis-relevant predictors that reach p < 0.10 or better are visualized automatically.",
        "These dynamic figures use the saved Tobit and clustered non-parametric outputs,",
        "and participant id remains only an inference-level clustering unit rather than a substantive explanatory variable."
      )
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
    "Only hypothesis-relevant predictors that reach at least `p < .10` are visualized automatically. These figures rely on the saved Tobit and clustered non-parametric fits, and `id` remains only an inference-level clustering unit.",
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

build_hypothesis_conclusion_items <- function(alpha = 0.05) {
  hypothesis_specs <- get_hypothesis_specs()
  vapply(
    hypothesis_specs,
    function(spec) {
      trimws(paste(
        sprintf("%s. Original hypothesis: %s", spec$id, spec$statement),
        summarize_estimator_hypothesis(spec, "Tobit", alpha),
        summarize_estimator_hypothesis(spec, "CLAD", alpha)
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

build_estimator_block <- function(output_prefix, estimator_name, table_caption) {
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
  model_fit <- readRDS(model_file)
  inference_pending <- all(is.na(coef_df$std_error)) && all(is.na(coef_df$p_value))
  table_df <- if (inference_pending) {
    coef_df[, c("label", "estimate", "inference"), drop = FALSE]
  } else {
    coef_df[, c("label", "estimate", "std_error", "p_value"), drop = FALSE]
  }

  table_latex <- to_latex_table(
    table_df,
    table_caption,
    sprintf("tab:%s", tolower(output_prefix)),
    digits = 3
  )

  narrative <- generate_coefficient_narrative(coef_df, model_family = get_model_family(model_fit))
  diagnostic_text <- get_model_diagnostics(model_fit)

  c(
    paste0("\\paragraph{", estimator_name, "}"),
    "",
    table_latex,
    "",
    "\\textbf{Interpretation}",
    "",
    escape_latex(narrative),
    "",
    "\\textbf{Diagnostics}",
    "",
    escape_latex(diagnostic_text),
    ""
  )
}

# Helper for rendering Tobit plus non-parametric robustness sections.
build_model_section <- function(hypothesis_id, model_suffix, table_caption) {
  output_prefix <- sprintf("%s_%s", hypothesis_id, model_suffix)
  clean_caption <- sub("\\.$", "", table_caption)
  c(
    build_estimator_block(
      output_prefix,
      "Tobit Estimator",
      sprintf("%s (Tobit).", clean_caption)
    ),
    "",
    build_estimator_block(
      paste0(output_prefix, "_CLAD"),
      "Non-parametric Robustness Estimator",
      sprintf("%s (cluster-aware non-parametric robustness).", clean_caption)
    )
  )
}

# 2. BUILD LATEX CONTENT
latex_lines <- c(
  "\\documentclass[11pt]{article}",
  "\\usepackage[margin=1in]{geometry}",
  "\\usepackage[T1]{fontenc}",
  "\\usepackage[utf8]{inputenc}",
  "\\usepackage{amsmath, amssymb, amsfonts}",
  "\\usepackage{graphicx}",
  "\\usepackage{booktabs}",
  "\\usepackage{float}",
  "\\usepackage{hyperref}",
  "\\title{Scientific Analysis of Moral Judgments using Tobit and Cluster-Aware Non-Parametric Robustness Models}",
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
  escape_latex(paste(get_case_configuration_option_label(), "frames each judgment as a relational victim x negotiator case. The paired-group structure generates interpretable configurations such as Hum_x_Hum, Hum_x_Ing, Hum_x_Control, Ing_x_Hum, Ing_x_Ing, and Ing_x_Control, with role (Observer/Victim) and decision context (Accept/Reject) available as further conditioning dimensions.")),
  "",
  "\\section{Hypotheses to Test}",
  "\\begin{itemize}",
  "  \\item \\textbf{H1 (Empathy):} Higher empathy predicts lower moral-judgment scores for harmful decisions after conditioning on explicit victim x negotiator case configurations.",
  "  \\item \\textbf{H2a (Relational Betrayal):} Same-faculty and cross-faculty betrayal cases are evaluated through explicit victim x negotiator configurations rather than a single same-group indicator.",
  paste0(
    "  \\item \\textbf{H2b (Case Configuration):} Relational judgments are interpreted through explicit case contrasts such as ",
    case_examples_latex,
    "."
  ),
  "  \\item \\textbf{H3 (Moderation):} The empathy effect may vary across explicit victim x negotiator case configurations.",
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
  "The empathy profile of the sample is visualized in Figure \\ref{fig:radar}, showing the average scores across the four IRI latent variables.",
  latex_include_graphic(file.path("../figures", "figure_03_empathy_radar.png"), "IRI Latent Variable Averages (Radar Plot profile).", "fig:radar"),
  "Judgment severity distributions segmented by experimental conditions are presented in Figure \\ref{fig:dist_panels}.",
  latex_include_graphic(file.path("../figures", "figure_04_severity_panels.png"), "Accepted-decision judgment distributions by explicit victim x negotiator case configuration.", "fig:dist_panels"),
  if (!is.null(case_configuration_summary)) {
    to_latex_table(
      case_configuration_summary,
      "Observed judgment summaries across explicit victim x negotiator case configurations, participant role, and decision context.",
      "tab:case_configuration_summary"
    )
  } else {
    "Case-configuration summary table unavailable."
  },
  "",
  "\\section{Bi-variate Statistics}",
  "The correlation matrix between the psychometric subscales and the mean moral judgment is presented below.",
  to_latex_table(bivar_cor, "Correlation Matrix: IRI Subscales and Moral Judgment.", "tab:bivar"),
  "Visual representations of these relationships are provided in Figure \\ref{fig:bivar_scatters}.",
  latex_include_graphic(file.path("../figures", "figure_05_bivariate_scatters.png"), "Bivariate Scatters: IRI Scales vs. Mean Judgment.", "fig:bivar_scatters"),
  "",
  "\\section{Estimator Fit Summary}",
  "The following table consolidates the fit-status information for the primary Tobit models and the non-parametric robustness branch. In the default pipeline, participant-level cluster bootstrap launches immediately after a converged full-sample non-parametric fit is available; if bootstrap is disabled manually or too few bootstrap refits converge, that status is shown explicitly.",
  if (!is.null(model_fit_summary)) {
    to_latex_table(
      model_fit_summary[, c("Model", "Approach", "Status", "Converged", "Iterations", "BootstrapReplicates", "BootstrapSuccessful", "Observations", "Participants", "ClusterUnit")],
      "Estimator fit summary across Tobit and cluster-aware non-parametric specifications.",
      "tab:model_fit_summary"
    )
  } else {
    "Model fit summary unavailable."
  },
  "",
  "\\subsection{Hypothesis Significance Summary}",
  "The following concise table lists only hypothesis-relevant predictors that reached at least p < 0.10, using conventional symbols to indicate strength of evidence. If the non-parametric bootstrap is disabled, too sparse, or the censored median fit does not converge, the non-parametric column reports that status instead of inferential symbols. Dynamic figures are generated only for predictors that appear in this table with at least one significance symbol.",
  if (!is.null(hypothesis_significance_summary)) {
    to_latex_table(
      hypothesis_significance_summary,
      "Hypothesis-level significance summary across Tobit and cluster-aware non-parametric models.",
      "tab:hypothesis_summary"
    )
  } else {
    "Hypothesis summary unavailable."
  },
  build_latex_significance_figure_section(hypothesis_figure_artifacts),
  build_latex_all_significant_predictor_figure_section(all_significant_predictor_figure_artifacts),
  "",
  "\\subsection{Integrated Hypothesis Conclusions}",
  "The following summary restates each original hypothesis and indicates whether the available Tobit estimates and the cluster-aware non-parametric models support it in the current data. Non-parametric conclusions are drawn when the participant-level bootstrap inference is available and are otherwise labeled explicitly.",
  "\\begin{itemize}",
  paste0("\\item ", escape_latex(hypothesis_conclusion_items)),
  "\\end{itemize}",
  "",
  "\\section{Hypothesis Validation and Results}",
  "Detailed coefficient tables for each Tobit model, coupled with non-parametric robustness outputs, natural language interpretive narratives, and estimator-specific diagnostics, are provided below. In the default pipeline, converged non-parametric fits immediately attempt participant-level cluster-bootstrap inference; the report labels deferred and sparse-bootstrap cases explicitly when full inference is not available.",
  "",
  "\\subsection{H1: Empathy Effect}",
  "This section evaluates the primary effect of empathy on moral judgments while holding explicit victim x negotiator case configurations constant.",
  "\\subsubsection{Model A: Composite Empathy}",
  build_model_section("H1", "A", "H1 Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Empathy Constructs}",
  build_model_section("H1", "B", "H1 Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H2a: Relational Betrayal Contrasts}",
  "This section tests whether same-faculty and cross-faculty betrayal cases differ when they are represented directly as explicit victim x negotiator scenarios.",
  "\\subsubsection{Model A: Composite Empathy Control}",
  build_model_section("H2a", "A", "H2a Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Construct Controls}",
  build_model_section("H2a", "B", "H2a Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H2b: Explicit Case-Configuration Contrasts}",
  "This section examines interpretable victim x negotiator case contrasts directly, replacing isolated outgroup-perpetrator indicators with explicit relational scenarios.",
  "\\subsubsection{Model A: Composite Empathy Control}",
  build_model_section("H2b", "A", "H2b Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Construct Controls}",
  build_model_section("H2b", "B", "H2b Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H3: Interaction Moderation}",
  "This section tests whether empathy is conditioned by explicit case-configuration contrasts rather than by a single outgroup flag.",
  "\\subsubsection{Model A: Composite Empathy Interaction}",
  build_model_section("H3", "A", "H3 Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Constructs Interaction}",
  build_model_section("H3", "B", "H3 Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\section{Discussion and Limitations}",
  paste(get_limitations_narration(), collapse = " "),
  "",
  "\\section{Conclusion}",
  "Based on the combined interval-censored Tobit estimations and the cluster-aware non-parametric robustness workflow, empathy and relational victim x negotiator case configurations have been documented together under Option 2 explicit case-configuration modeling, alongside their theoretical assumptions above.",
  "\\end{document}"
)

tex_path <- file.path(paths$report_dir, "tobit_analysis_report.tex")
write_text_file(latex_lines, tex_path)

# Rendering Markdown is temporarily simplified to focus on standardizing the LaTeX/PDF engine.
md_lines <- c(
  "# Scientific Analysis of Moral Judgments with Tobit and Cluster-Aware Non-Parametric Robustness Checks",
  "",
  "## Dataset Description",
  paste(get_dataset_narration(paths$dataset_mode), collapse = " "),
  "",
  "## Option 2 Relational Case Configuration",
  paste(
    get_case_configuration_option_text(),
    "Role (Observer/Victim) and decision context (Accept/Reject) may further condition these scenarios and are reported explicitly in the descriptive summaries."
  ),
  "",
  "## Hypothesis Significance Summary",
  "Only hypothesis-relevant predictors with p < 0.10 are shown below. Symbols follow the rule `+` for p < 0.10, `*` for p < 0.05, and `**` for p < 0.01. If bootstrap is disabled for a run, too few non-parametric bootstrap refits succeed, or the non-parametric fit does not converge, the non-parametric column reports that status explicitly. Dynamic figures are generated only for predictors that appear here with at least one significance symbol.",
  to_markdown_table(hypothesis_significance_summary),
  "",
  "## Case Configuration Summary",
  if (!is.null(case_configuration_summary)) to_markdown_table(case_configuration_summary) else "Case-configuration summary unavailable.",
  "",
  build_markdown_significance_figure_section(hypothesis_figure_artifacts),
  "",
  build_markdown_all_significant_predictor_figure_section(all_significant_predictor_figure_artifacts),
  "",
  "## Hypothesis Conclusion Summary",
  "Each conclusion below is generated from the current coefficient outputs. Non-parametric statements are interpreted when participant-level cluster-bootstrap inference is available and are otherwise labeled explicitly.",
  paste0("- ", hypothesis_conclusion_items),
  "",
  "## PDF Comprehensive Report Generated",
  "Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented Tobit and cluster-aware non-parametric mathematical formulations, the Option 2 case-configuration logic, dual-estimator hypothesis testing, and the algorithmically interpreted natural language coefficients. When the run is dataset-specific, a matching alias such as `tobit_analysis_report_Buca.pdf` is also refreshed.",
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
