# R/06_generate_report.R
# Purpose: Dynamically generate a full scientific manuscript (Markdown, LaTeX, PDF, Word)
# incorporating theoretical foundations, bivariate stats, power analysis, 
# dynamic NLP coefficient interpretations, and normality tests.
# Execution Order: 7

source("R/00_config.R")
source("R/utils/io_functions.R")
source("R/utils/power_functions.R")
source("R/utils/table_functions.R")
source("R/utils/narrative_functions.R")
source("R/utils/model_functions.R")
source("R/utils/nl_generation.R")
paths <- get_project_paths()

message("Generating Comprehensive Scientific Manuscript (LaTeX/PDF/Word)...")

# 1. LOAD DATA & ASSETS
judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)
power_results <- calc_effective_sample_size(judgments_accept$judgement, judgments_accept$id)
bivar_cor <- read.csv(file.path(paths$tables_dir, "bivariate_correlations.csv"), row.names = 1, check.names = FALSE)

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

  fit_rows <- lapply(fit_files, read.csv, stringsAsFactors = FALSE)
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

is_fit_usable <- function(fit_stats, approach) {
  if (is.null(fit_stats) || nrow(fit_stats) == 0L) return(FALSE)
  status_value <- tolower(trimws(as.character(fit_stats$Status[1])))
  if (status_value != "completed") return(FALSE)
  if (approach == "CLAD") return(coerce_fit_flag(fit_stats$Converged[1]))
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

  if (bundle$approach == "CLAD" && !coerce_fit_flag(bundle$fit_stats$Converged[1])) {
    iteration_text <- if (!is.na(bundle$fit_stats$Iterations[1])) {
      sprintf(" after %s iterations", bundle$fit_stats$Iterations[1])
    } else {
      ""
    }
    return(paste0("the CLAD optimization did not converge", iteration_text))
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
  if (expected_direction == "negative") return(estimates < 0)
  estimates > 0
}

describe_effect_short <- function(row) {
  sprintf(
    "%s with a %s association (p = %s)",
    row$label[1],
    if (row$estimate[1] > 0) "positive" else "negative",
    format_p_value(row$p_value[1])
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
        "Model %s does not support the hypothesis; %s is %s but not statistically significant (p = %s).",
        bundle$model_suffix,
        closest_row$label[1],
        if (closest_row$estimate[1] > 0) "positive" else "negative",
        format_p_value(closest_row$p_value[1])
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
      return("CLAD conclusion: no converged CLAD model is available, so the robustness check is inconclusive for this hypothesis.")
    }
    return("Tobit conclusion: Tobit outputs are unavailable for this hypothesis.")
  }

  available_statuses <- vapply(
    assessments[names(assessments)[available_flags]],
    function(assessment) assessment$status,
    character(1)
  )
  approach_label <- if (approach == "CLAD") "CLAD conclusion" else "Tobit conclusion"
  partial_availability_note <- if (approach == "CLAD" && sum(available_flags) < length(available_flags)) {
    "Only converged CLAD specifications are interpreted here."
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
  list(
    list(
      id = "H1",
      statement = "Higher empathy predicts lower moral-judgment scores for harmful decisions.",
      expected_direction = "negative",
      model_terms = list(
        A = list(terms = c("iri_total"), description = "the composite empathy term"),
        B = list(terms = c("iri_fs", "iri_ec", "iri_pt", "iri_pd"), description = "the empathy subscale main effects")
      ),
      exclude_terms = c("iri_total", "iri_fs", "iri_ec", "iri_pt", "iri_pd")
    ),
    list(
      id = "H2a",
      statement = "Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.",
      expected_direction = "negative",
      model_terms = list(
        A = list(terms = c("same_group_harm"), description = "the same-group-harm term"),
        B = list(terms = c("same_group_harm"), description = "the same-group-harm term")
      ),
      exclude_terms = c("same_group_harm")
    ),
    list(
      id = "H2b",
      statement = "Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.",
      expected_direction = "negative",
      model_terms = list(
        A = list(terms = c("perp_outgroup"), description = "the outgroup-perpetrator term"),
        B = list(terms = c("perp_outgroup"), description = "the outgroup-perpetrator term")
      ),
      exclude_terms = c("perp_outgroup")
    ),
    list(
      id = "H3",
      statement = "The empathy effect is stronger in outgroup cases than in ingroup cases.",
      expected_direction = "negative",
      model_terms = list(
        A = list(terms = c("iri_total:perp_outgroup"), description = "the composite empathy x outgroup interaction"),
        B = list(
          terms = c("iri_fs:perp_outgroup", "iri_ec:perp_outgroup", "iri_pt:perp_outgroup", "iri_pd:perp_outgroup"),
          description = "the empathy-dimension x outgroup interactions"
        )
      ),
      exclude_terms = c("iri_total:perp_outgroup", "iri_fs:perp_outgroup", "iri_ec:perp_outgroup", "iri_pt:perp_outgroup", "iri_pd:perp_outgroup")
    )
  )
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

  table_latex <- to_latex_table(
    coef_df[, c("label", "estimate", "std_error", "p_value")],
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

# Helper for rendering Tobit plus CLAD robustness sections.
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
      "CLAD Robustness Estimator",
      sprintf("%s (CLAD robustness).", clean_caption)
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
  "\\title{Scientific Analysis of Moral Judgments using Tobit and CLAD Models}",
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
  "",
  "\\section{Hypotheses to Test}",
  "\\begin{itemize}",
  "  \\item \\textbf{H1 (Empathy):} Higher empathy predicts lower moral-judgment scores for harmful decisions.",
  "  \\item \\textbf{H2a (Betrayal):} Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.",
  "  \\item \\textbf{H2b (Outgroup):} Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.",
  "  \\item \\textbf{H3 (Moderation):} The empathy effect is stronger in outgroup cases.",
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
  latex_include_graphic(file.path("../figures", "figure_04_severity_panels.png"), "Judgment Severity Distribution (Ingroup vs. Outgroup).", "fig:dist_panels"),
  "",
  "\\section{Bi-variate Statistics}",
  "The correlation matrix between the psychometric subscales and the mean moral judgment is presented below.",
  to_latex_table(bivar_cor, "Correlation Matrix: IRI Subscales and Moral Judgment.", "tab:bivar"),
  "Visual representations of these relationships are provided in Figure \\ref{fig:bivar_scatters}.",
  latex_include_graphic(file.path("../figures", "figure_05_bivariate_scatters.png"), "Bivariate Scatters: IRI Scales vs. Mean Judgment.", "fig:bivar_scatters"),
  "",
  "\\section{Estimator Fit Summary}",
  "The following table consolidates the fit-status information for the primary Tobit models and the added CLAD robustness checks.",
  if (!is.null(model_fit_summary)) {
    to_latex_table(
      model_fit_summary[, c("Model", "Approach", "Status", "Converged", "Iterations", "Observations", "Participants", "LowerBoundCensored", "UpperBoundCensored")],
      "Estimator fit summary across Tobit and CLAD specifications.",
      "tab:model_fit_summary"
    )
  } else {
    "Model fit summary unavailable."
  },
  "",
  "\\subsection{Integrated Hypothesis Conclusions}",
  "The following summary restates each original hypothesis and indicates whether the available Tobit estimates and the converged CLAD robustness models support it in the current data.",
  "\\begin{itemize}",
  paste0("\\item ", escape_latex(hypothesis_conclusion_items)),
  "\\end{itemize}",
  "",
  "\\section{Hypothesis Validation and Results}",
  "Detailed coefficient tables for each Tobit model, coupled with CLAD robustness replications, natural language interpretive narratives, and estimator-specific diagnostics, are provided below.",
  "",
  "\\subsection{H1: Empathy Effect}",
  "This section evaluates the primary effect of empathy on moral judgments.",
  "\\subsubsection{Model A: Composite Empathy}",
  build_model_section("H1", "A", "H1 Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Empathy Constructs}",
  build_model_section("H1", "B", "H1 Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H2a: Ingroup Betrayal}",
  "This section tests whether harm directed at the perpetrator's own group is judged differently.",
  "\\subsubsection{Model A: Composite Empathy Control}",
  build_model_section("H2a", "A", "H2a Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Construct Controls}",
  build_model_section("H2a", "B", "H2a Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H2b: Outgroup Derogation}",
  "This section examines the difference in judgment when the perpetrator is an outgroup member compared to an ingroup member.",
  "\\subsubsection{Model A: Composite Empathy Control}",
  build_model_section("H2b", "A", "H2b Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Construct Controls}",
  build_model_section("H2b", "B", "H2b Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H3: Interaction Moderation}",
  "This section tests the interaction and moderation between absolute empathy dimensions and the outgroup status of the perpetrator.",
  "\\subsubsection{Model A: Composite Empathy Interaction}",
  build_model_section("H3", "A", "H3 Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Constructs Interaction}",
  build_model_section("H3", "B", "H3 Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\section{Discussion and Limitations}",
  paste(get_limitations_narration(), collapse = " "),
  "",
  "\\section{Conclusion}",
  "Based on the combined interval-censored Tobit estimations and CLAD robustness checks, the structural effects of empathy, group dynamics, and betrayal have been documented alongside their theoretical assumptions above.",
  "\\end{document}"
)

tex_path <- file.path(paths$report_dir, "tobit_analysis_report.tex")
write_text_file(latex_lines, tex_path)

# Rendering Markdown is temporarily simplified to focus on standardizing the LaTeX/PDF engine.
md_lines <- c(
  "# Scientific Analysis of Moral Judgments with Tobit and CLAD Robustness Checks",
  "",
  "## Dataset Description",
  paste(get_dataset_narration(paths$dataset_mode), collapse = " "),
  "",
  "## Hypothesis Conclusion Summary",
  "Each conclusion below is generated from the current coefficient outputs, with CLAD statements restricted to models that completed with convergence.",
  paste0("- ", hypothesis_conclusion_items),
  "",
  "## PDF Comprehensive Report Generated",
  "Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented Tobit and CLAD mathematical formulations, dual-estimator hypothesis testing, and the algorithmically interpreted natural language coefficients.",
  ""
)
write_text_file(md_lines, file.path(paths$report_dir, "tobit_analysis_report.md"))

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

  if (any(build_statuses != 0L) || !file.exists(build_pdf)) {
    warning(sprintf(
      "pdflatex failed while rendering %s. Inspect %s for details.",
      pdf_name,
      target_log
    ))
    return(FALSE)
  }

  copied <- file.copy(build_pdf, target_pdf, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
  if (copied) {
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

if (pdf_rendered) {
  message("Scientific manuscript expansion complete.")
} else {
  warning("Scientific manuscript generated, but the primary PDF was not refreshed. Review the warnings above.")
}

if (!word_rendered) {
  warning("Word report was not refreshed.")
}
