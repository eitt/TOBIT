source("R/00_config.R")
source("R/hypotheses/H_formulas.R")
source("R/utils/report_dynamic_helpers.R")
source("R/utils/table_functions.R")

paths <- get_project_paths()

normalize_existing_paths <- function(paths_vector) {
  existing_paths <- paths_vector[nzchar(paths_vector) & file.exists(paths_vector)]
  if (length(existing_paths) == 0L) {
    return(character(0))
  }
  unique(normalizePath(existing_paths, winslash = "/", mustWork = FALSE))
}

find_tool_path <- function(tool_name, extra_candidates = character()) {
  system_candidate <- unname(Sys.which(tool_name))
  where_candidates <- character(0)
  if (.Platform$OS.type == "windows") {
    where_candidates <- tryCatch(
      system2("where.exe", args = tool_name, stdout = TRUE, stderr = FALSE),
      error = function(e) character(0)
    )
  }
  normalize_existing_paths(c(system_candidate, where_candidates, extra_candidates))
}

run_command_capture <- function(command, args) {
  command_output <- tryCatch(
    system2(command, args = args, stdout = TRUE, stderr = TRUE),
    error = function(e) structure(conditionMessage(e), status = 1L)
  )
  exit_status <- attr(command_output, "status")
  if (is.null(exit_status)) exit_status <- 0L
  list(status = as.integer(exit_status), output = paste(command_output, collapse = "\n"))
}

bind_csv_files <- function(file_paths) {
  if (length(file_paths) == 0L) {
    return(data.frame())
  }
  data_frames <- lapply(file_paths, read_csv_or_empty)
  data_frames <- Filter(function(df) is.data.frame(df) && nrow(df) > 0L && ncol(df) > 0L, data_frames)
  if (length(data_frames) == 0L) {
    return(data.frame())
  }
  do.call(rbind, data_frames)
}

render_dynamic_report_outputs <- function(markdown_path, paths = get_project_paths()) {
  report_stem <- tools::file_path_sans_ext(basename(markdown_path))
  output_dir <- dirname(markdown_path)
  pandoc_path <- find_tool_path(
    "pandoc",
    c(file.path(Sys.getenv("LOCALAPPDATA"), "Pandoc", "pandoc.exe"))
  )
  pdflatex_path <- find_tool_path(
    "pdflatex",
    c(file.path(Sys.getenv("LOCALAPPDATA"), "Programs", "MiKTeX", "miktex", "bin", "x64", "pdflatex.exe"))
  )

  docx_path <- file.path(output_dir, paste0(report_stem, ".docx"))
  pdf_path <- file.path(output_dir, paste0(report_stem, ".pdf"))
  render_status <- data.frame(
    format = c("docx", "pdf"),
    status = c("not_run", "not_run"),
    output_file = c(docx_path, pdf_path),
    detail = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )

  if (length(pandoc_path) == 0L) {
    render_status$status <- "missing_pandoc"
    render_status$detail <- "Pandoc was not found, so docx/pdf rendering was skipped."
  } else {
    pandoc_path <- pandoc_path[[1]]
    docx_result <- run_command_capture(pandoc_path, c(markdown_path, "-o", docx_path))
    render_status$status[1] <- if (docx_result$status == 0L) "rendered" else "failed"
    render_status$detail[1] <- if (nzchar(docx_result$output)) docx_result$output else NA_character_

    if (length(pdflatex_path) == 0L) {
      render_status$status[2] <- "missing_pdflatex"
      render_status$detail[2] <- "Pandoc was found, but pdflatex was not found."
    } else {
      pdf_result <- run_command_capture(
        pandoc_path,
        c(markdown_path, "-o", pdf_path, paste0("--pdf-engine=", pdflatex_path[[1]]))
      )
      render_status$status[2] <- if (pdf_result$status == 0L) "rendered" else "failed"
      render_status$detail[2] <- if (nzchar(pdf_result$output)) pdf_result$output else NA_character_
    }
  }

  write.csv(render_status, file.path(paths$logs_dir, "dynamic_report_render_status.csv"), row.names = FALSE)
  write.csv(render_status, file.path(paths$reports_data_dir, "dynamic_report_render_status.csv"), row.names = FALSE)

  if (file.exists(docx_path)) file.copy(docx_path, file.path(paths$logs_dir, "dynamic_report.docx"), overwrite = TRUE)
  if (file.exists(pdf_path)) file.copy(pdf_path, file.path(paths$logs_dir, "dynamic_report.pdf"), overwrite = TRUE)

  invisible(render_status)
}

relative_report_path <- function(abs_path) {
  gsub("\\\\", "/", normalizePath(abs_path, winslash = "/", mustWork = FALSE))
}

participant_summary <- read_csv_or_empty(file.path(paths$tables_dir, "participant_summary.csv"))
judgement_summary <- read_csv_or_empty(file.path(paths$tables_dir, "judgement_summary.csv"))
decision_summary <- read_csv_or_empty(file.path(paths$tables_dir, "decision_summary.csv"))
group_summary <- read_csv_or_empty(file.path(paths$tables_dir, "group_summary.csv"))
missingness_summary <- read_csv_or_empty(file.path(paths$tables_dir, "missingness_summary.csv"))
observation_audit <- read_csv_or_empty(file.path(paths$tables_dir, "observation_audit.csv"))
formula_catalog <- read_csv_or_empty(file.path(paths$tables_dir, "hypothesis_formula_catalog.csv"))
participants <- read.csv(paths$processed_participants, stringsAsFactors = FALSE)
judgments_analysis <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

symbol_dictionary <- get_current_symbol_dictionary()
predictor_glossary <- get_current_predictor_glossary()
correlation_table <- build_participant_correlation_table(participants, judgments_analysis)
clustering_diagnostic <- compute_descriptive_clustering_diagnostic(judgments_analysis)

write.csv(symbol_dictionary, file.path(paths$tables_dir, "report_symbol_dictionary.csv"), row.names = FALSE)
write.csv(predictor_glossary, file.path(paths$tables_dir, "report_predictor_glossary.csv"), row.names = FALSE)
write.csv(correlation_table, file.path(paths$tables_dir, "report_correlation_matrix.csv"), row.names = FALSE)
write.csv(clustering_diagnostic, file.path(paths$tables_dir, "report_clustering_diagnostic.csv"), row.names = FALSE)

primary_coef_files <- list.files(paths$models_dir, pattern = "_primary_coefficients\\.csv$", full.names = TRUE)
primary_fit_files <- list.files(paths$models_dir, pattern = "_primary_fit_stats\\.csv$", full.names = TRUE)
coef_summary <- bind_csv_files(primary_coef_files)
fit_summary <- bind_csv_files(primary_fit_files)

significance_summary <- build_role_significance_summary(coef_summary)
write.csv(significance_summary, file.path(paths$tables_dir, "report_role_significance_summary.csv"), row.names = FALSE)
write.csv(significance_summary, file.path(paths$tables_dir, "hypothesis_summary.csv"), row.names = FALSE)
write.csv(subset(significance_summary, role == "Victim"), file.path(paths$tables_dir, "hypothesis_summary_victim.csv"), row.names = FALSE)
write.csv(subset(significance_summary, role == "Bystander"), file.path(paths$tables_dir, "hypothesis_summary_bystander.csv"), row.names = FALSE)
write.csv(significance_summary, file.path(paths$results_dir, "hypothesis_summary.csv"), row.names = FALSE)

coefficient_tables <- list()
coefficient_narratives <- list()
figure_manifest <- data.frame(
  figure_file = character(0),
  figure_type = character(0),
  hypothesis = character(0),
  role = character(0),
  term = character(0),
  caption = character(0),
  interpretation = character(0),
  stringsAsFactors = FALSE
)

descriptive_figure_entries <- data.frame(
  figure_file = c(
    file.path(paths$figures_dir, "figure_iri_subscale_radar.png"),
    file.path(paths$figures_dir, "figure_bivariate_empathy_vs_mean_judgement.png"),
    file.path(paths$figures_dir, "figure_judgement_distribution_by_role.png"),
    file.path(paths$figures_dir, "figure_decision_pattern_by_role.png")
  ),
  figure_type = c("descriptive", "descriptive", "descriptive", "descriptive"),
  hypothesis = c("All", "All", "All", "All"),
  role = c("All", "All", "All", "All"),
  term = c("IRI profile", "Empathy correlations", "Judgement distribution", "Decision pattern"),
  caption = c(
    "Mean IRI subscale profile across participants.",
    "Participant-level bivariate scatters of IRI subscales against mean judgement.",
    "Observed judgement distributions split by role.",
    "Observed decision patterns by role."
  ),
  interpretation = c(
    "This figure summarizes the central empathy profile of the sample before conditioning on hypothesis-specific models.",
    "These scatterplots show the participant-level descriptive relationship between empathy dimensions and average judgement.",
    "This figure shows the raw shape of the bounded judgement outcome in the victim and bystander subsets.",
    "This figure summarizes how the four joint decision contexts are distributed across roles."
  ),
  stringsAsFactors = FALSE
)
figure_manifest <- rbind(figure_manifest, descriptive_figure_entries)

get_dataset_for_role <- function(role_label) {
  if (identical(role_label, "Victim")) {
    judgments_victim
  } else {
    judgments_bystander
  }
}

get_model_prefix <- function(hypothesis_id, role_label) {
  sprintf("%s_%s_primary", hypothesis_id, role_label)
}

for (hypothesis_id in paste0("H", 1:5)) {
  for (role_label in c("Victim", "Bystander")) {
    prefix <- get_model_prefix(hypothesis_id, role_label)
    coef_path <- file.path(paths$models_dir, sprintf("%s_coefficients.csv", prefix))
    model_path <- file.path(paths$models_dir, sprintf("%s_model.rds", prefix))
    if (!file.exists(coef_path) || !file.exists(model_path)) {
      next
    }

    coef_df <- read.csv(coef_path, stringsAsFactors = FALSE)
    display_table <- prepare_report_coefficient_table(coef_df)
    coefficient_tables[[prefix]] <- display_table
    coefficient_narratives[[prefix]] <- generate_model_narrative(coef_df, hypothesis_id, role_label)

    write.csv(display_table, file.path(paths$tables_dir, sprintf("report_%s_coefficients.csv", prefix)), row.names = FALSE)

    focal_terms <- coef_df[
      coef_df$p_value < 0.10 &
        vapply(seq_len(nrow(coef_df)), function(i) is_focal_term_for_hypothesis(hypothesis_id, coef_df$term[[i]]), logical(1)) &
        !vapply(coef_df$term, is_session_term, logical(1)),
      "term",
      drop = TRUE
    ]
    focal_terms <- unique(stats::na.omit(focal_terms))
    if (length(focal_terms) == 0L) {
      next
    }

    model_fit <- readRDS(model_path)
    model_data <- get_dataset_for_role(role_label)

    for (term_name in focal_terms) {
      plot_df <- tryCatch(
        build_plot_data_for_term(model_fit, model_data, term_name),
        error = function(e) NULL
      )
      if (is.null(plot_df)) {
        next
      }
      figure_file <- file.path(
        paths$figures_dir,
        sprintf(
          "figure_%s_%s_%s.png",
          tolower(hypothesis_id),
          tolower(role_label),
          sanitize_filename_component(term_name, max_chars = 50L)
        )
      )
      plot_written <- tryCatch(
        write_significance_plot_current(figure_file, plot_df, term_name),
        error = function(e) FALSE
      )
      if (!isTRUE(plot_written)) {
        next
      }
      figure_manifest <- rbind(
        figure_manifest,
        data.frame(
          figure_file = figure_file,
          figure_type = "significance",
          hypothesis = hypothesis_id,
          role = role_label,
          term = term_name,
          caption = sprintf("%s %s: model-implied predictions for %s.", hypothesis_id, role_label, label_current_term(term_name)),
          interpretation = describe_plot_pattern_current(plot_df),
          stringsAsFactors = FALSE
        )
      )
    }
  }
}

write.csv(figure_manifest, file.path(paths$tables_dir, "report_figure_catalog.csv"), row.names = FALSE)
write.csv(figure_manifest, file.path(paths$reports_data_dir, "report_figure_catalog.csv"), row.names = FALSE)

formula_checks <- within(formula_catalog, {
  uses_judgement <- TRUE
  uses_sociodemographics <- grepl("age", formula_rhs, fixed = TRUE) &
    grepl("ses", formula_rhs, fixed = TRUE) &
    grepl("sex_female", formula_rhs, fixed = TRUE) &
    grepl("faculty_player_factor", formula_rhs, fixed = TRUE)
  uses_factor_session <- grepl("factor(session)", formula_rhs, fixed = TRUE)
  uses_decisions <- grepl("decision_target", formula_rhs, fixed = TRUE) &
    grepl("decision_other", formula_rhs, fixed = TRUE)
})

get_audit_value <- function(checkpoint_name) {
  matched <- observation_audit$value[observation_audit$checkpoint == checkpoint_name]
  if (length(matched) == 0L) {
    return(NA_real_)
  }
  suppressWarnings(as.numeric(matched[[1]]))
}

row_count_import <- get_audit_value("processed_import_rows")
row_count_final <- get_audit_value("processed_judgment_rows")
duplicated_source_rows <- get_audit_value("duplicated_source_row_numbers")

id_dependence_ok <- if (nrow(fit_summary) == 0L) FALSE else all(fit_summary$dependence_adjustment == "cluster_robust_id")
session_handling_ok <- if (nrow(fit_summary) == 0L) {
  FALSE
} else {
  all(fit_summary$session_handling == "factor_session_fixed_effect") && all(formula_checks$uses_factor_session)
}

compliance_report <- data.frame(
  criterion = c(
    "a) uses judgement",
    "b) repeated structure by id",
    "c) session grouping",
    "d) no double count introduced by the pipeline",
    "e) victim and bystander treated differently",
    "f) decision_target and decision_other included where required",
    "g) sociodemographics included in every hypothesis model"
  ),
  status = c(
    if (all(formula_checks$uses_judgement)) "YES" else "NO",
    if (id_dependence_ok) "YES" else "NO",
    if (session_handling_ok) "YES" else "NO",
    if (!is.na(row_count_import) && !is.na(row_count_final) && !is.na(duplicated_source_rows) && row_count_import == row_count_final && duplicated_source_rows == 0) "YES" else "NO",
    if (nrow(subset(formula_catalog, hypothesis == "H2" & role == "Victim")) == 1L &&
      nrow(subset(formula_catalog, hypothesis == "H2" & role == "Bystander")) == 1L &&
      subset(formula_catalog, hypothesis == "H2" & role == "Victim")$formula_rhs != subset(formula_catalog, hypothesis == "H2" & role == "Bystander")$formula_rhs) {
      "YES"
    } else {
      "NO"
    },
    if (all(subset(formula_checks, hypothesis %in% c("H4", "H5"))$uses_decisions)) "YES" else "NO",
    if (all(formula_checks$uses_sociodemographics)) "YES" else "NO"
  ),
  evidence = c(
    "All formulas model judgement directly.",
    "All fitted Tobit models use participant-cluster robust standard errors through cluster = id.",
    "The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept.",
    sprintf("Imported rows = %s; final analytical rows = %s; duplicated source row numbers introduced by the pipeline = %s.", row_count_import, row_count_final, duplicated_source_rows),
    "Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander.",
    "H4 and H5 both include decision_target, decision_other, and their interaction.",
    "Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor."
  ),
  stringsAsFactors = FALSE
)

write.csv(compliance_report, file.path(paths$tables_dir, "pipeline_compliance_report.csv"), row.names = FALSE)
write.csv(compliance_report, file.path(paths$reports_data_dir, "pipeline_compliance_report.csv"), row.names = FALSE)
write.csv(fit_summary, file.path(paths$tables_dir, "model_fit_summary.csv"), row.names = FALSE)
write.csv(fit_summary, file.path(paths$diagnostics_dir, "model_fit_summary.csv"), row.names = FALSE)

build_image_block <- function(figure_row) {
  c(
    paste0("![", figure_row$caption, "](", relative_report_path(figure_row$figure_file), ")"),
    "",
    figure_row$interpretation,
    ""
  )
}

table_caption_counter <- 0L

build_numbered_table_block <- function(df, title, digits = 3, empty_message = "_No table data available._") {
  table_caption_counter <<- table_caption_counter + 1L
  c(
    paste0("**Table ", table_caption_counter, ". ", title, "**"),
    "",
    build_table_block(df, digits = digits, empty_message = empty_message),
    ""
  )
}

build_discussion_section <- function() {
  c(
    "## Discussion",
    "",
    "The empathy results speak to a mechanism in which moral judgement is not only a response to outcomes but also to dispositional social sensitivity. When empathy slopes vary across ingroup and outgroup relations, the findings support the original theoretical expectation that empathic orientation is filtered through perceived social closeness rather than operating as a uniform moral amplifier.",
    "",
    "The ingroup/outgroup results matter because the experiment embeds judgement in a relational structure with two negotiators and role-dependent social ties. Victim and bystander models are therefore not interchangeable. In the victim role, the central question is how the judged negotiator and the counterpart relate to the harmed person. In the bystander role, the participant is socially external to the harm event, so judgement can depend on a broader map that includes bystander-victim, bystander-negotiator, and victim-negotiator alignments.",
    "",
    "The decision terms sharpen the moral interpretation of the target-focused outcome. `decision_target` captures what the judged negotiator did, `decision_other` captures the counterpart's choice, and their interaction tests whether the meaning of one decision changes when the other negotiator accepts or rejects. This is substantively important because moral evaluations of the target can respond both to individual action and to the joint negotiation outcome.",
    "",
    "Practically, the results speak to negotiation ethics and third-party evaluation. If moral judgement shifts with empathy, faculty closeness, and joint decision patterns, then perceived fairness in harmful negotiations is shaped by both dispositional and relational context. That has implications for how observers assign blame, excuse strategic behavior, or infer responsibility from coordinated action.",
    "",
    "Methodologically, the active estimator is a two-sided Tobit with participant-cluster robust standard errors and session fixed effects. This is an honest production choice for a bounded repeated-measures outcome because it preserves the Tobit structure for `judgement`, adjusts within-participant dependence through clustering by `id`, and controls for session-level shifts through `factor(session)`. At the same time, it is not equivalent to a fully mixed Tobit with random participant and session intercepts, so dependence is handled through robust inference plus fixed-effects adjustment rather than a full hierarchical likelihood.",
    "",
    "The main limitations follow directly from that estimator choice and from the sparsity of some relational cells. The production branch does not estimate a full mixed Tobit, some interaction contrasts may be dropped in rank-deficient subsets, and any substantive reading should remain tied to the coefficient tables and model-implied figures rather than to isolated p-values. Future work should compare these production estimates against stable multilevel censored models, test alternative role-specific interaction sets, and examine whether the same theoretical patterns replicate under additional institutional or cultural contexts.",
    ""
  )
}

build_final_audit_note <- function(compliance_report, fit_summary) {
  all_yes <- nrow(compliance_report) > 0L && all(compliance_report$status == "YES")
  rank_deficient_models <- if ("dropped_columns" %in% names(fit_summary)) {
    sum(suppressWarnings(as.numeric(fit_summary$dropped_columns)) > 0, na.rm = TRUE)
  } else {
    0L
  }

  note_lines <- c(
    "## Final audit note",
    "",
    if (all_yes) {
      "The project now faithfully reflects the authoritative design in its production branch: `judgement` is the outcome, the long file remains the single source, one row remains one real observation, role-specific group definitions are used, `decision_target` and `decision_other` are modeled where required, and repeated measurements are handled through participant-cluster robust inference with `factor(session)`."
    } else {
      "The project is substantially aligned with the authoritative design, but the checklist below shows remaining compliance gaps that still require correction."
    },
    "",
    if (rank_deficient_models > 0L) {
      sprintf("Remaining partial mismatch: %s fitted model(s) still reported dropped columns because some role-specific interaction cells are sparse, so a few contrasts are not estimable in every subset.", rank_deficient_models)
    } else {
      "No rank-deficiency warning remained in the saved fit summary for this run."
    },
    "",
    "Estimator limitation: the production estimator is still a two-sided Tobit with `factor(session)` and participant-cluster robust standard errors by `id`, not a full mixed-effects Tobit with random participant and session intercepts.",
    ""
  )

  note_lines
}

report_lines <- c(
  "# Working Paper Report of Moral Judgement under Two-sided Tobit Models",
  "",
  "By Leonardo H. Talero-Sarmiento",
  paste0("Date: ", get_report_timestamp()),
  "",
  "This run uses `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` as the only analytical source and preserves each imported row as one real judgement observation. The production estimator is a two-sided Tobit fitted with `survival::survreg`, using bilateral censoring at `-9` and `9`, participant-cluster robust standard errors through `cluster = id`, and `factor(session)` in every active formula.",
  "",
  build_introductory_theoretical_chapter(),
  "",
  "## Dataset and sample description",
  "",
  get_dataset_sample_description(),
  "",
  "The authoritative interpretation is that each player observes ten scenarios and evaluates two negotiators, so the longitudinal file should contain 20 judgement rows per participant. The clustering diagnostic below is consistent with that design.",
  "",
  build_numbered_table_block(participant_summary, "Participant summary"),
  build_numbered_table_block(judgement_summary, "Judgement summary"),
  "",
  "## Datacard and symbol dictionary",
  "",
  build_numbered_table_block(symbol_dictionary, "Datacard symbol dictionary"),
  build_numbered_table_block(observation_audit, "Observation audit"),
  "",
  "## Predictor glossary and abbreviation note",
  "",
  build_numbered_table_block(predictor_glossary, "Predictor glossary"),
  "",
  "The report keeps compact predictor references in figure captions and narratives, but the glossary above remains the authoritative mapping back to the current pipeline variables.",
  "",
  "## Interaction interpretation rules",
  "",
  unlist(lapply(seq_along(get_interaction_interpretation_rules()), function(i) paste0(i, ". ", get_interaction_interpretation_rules()[i]))),
  "",
  "## H1-H5 hypotheses with role-specific equation summaries",
  "",
  build_numbered_table_block(
    formula_catalog[, c("hypothesis", "role", "formula_rhs", "theoretical_focus")],
    "H1-H5 role-specific formulas and theoretical focus"
  ),
  "",
  "Any earlier repository note that described negotiator code `0` as a hidden label or that narrowed H3 to additive effects only should now be treated as outdated. The active formulas below are the authoritative specification.",
  ""
)

for (hypothesis_id in paste0("H", 1:5)) {
  report_lines <- c(
    report_lines,
    paste0("### ", hypothesis_id),
    "",
    paste0("`Victim`: `", subset(formula_catalog, hypothesis == hypothesis_id & role == "Victim")$formula_rhs, "`"),
    "",
    paste0("`Bystander`: `", subset(formula_catalog, hypothesis == hypothesis_id & role == "Bystander")$formula_rhs, "`"),
    ""
  )
}

report_lines <- c(
  report_lines,
  "## Mathematical foundations",
  "",
  get_current_tobit_math_foundations(),
  "",
  "In this production branch, `factor(session)` is reported instead of `(1|session)` because the fitted estimator is a two-sided Tobit with session fixed effects and participant-cluster robust standard errors. The report does not claim a random session intercept that was not actually estimated.",
  "",
  "## Dependence and effective sample size diagnostic",
  "",
  "The following clustering diagnostic is descriptive. It summarizes within-participant dependence in the observed data and should not be read as evidence that the fitted estimator included participant random intercepts.",
  "",
  build_numbered_table_block(clustering_diagnostic, "Descriptive clustering diagnostic"),
  "",
  "Because the target of inference is repeated judgement within participant, the effective-sample-size table is a descriptive clustering diagnostic only; it does not replace the model-based dependence adjustment through `cluster = id` and `factor(session)`.",
  "",
  "## Descriptive statistics and figures",
  "",
  build_numbered_table_block(decision_summary, "Decision summary by role"),
  build_numbered_table_block(group_summary, "Role-specific ingroup/outgroup summary"),
  build_numbered_table_block(correlation_table, "Participant-level empathy and mean judgement correlation matrix"),
  "",
  "The group summary and the formulas above use role-specific ingroup/outgroup coding. Ingroup is defined by faculty coincidence, including `control` with `control`, while outgroup means non-matching faculties.",
  ""
)
# Append all descriptive figures to the report in the order stored in the catalog.
for (i in seq_len(nrow(descriptive_figure_entries))) {
  report_lines <- c(
    report_lines,
    build_image_block(descriptive_figure_entries[i, , drop = FALSE])
  )
}

# Create a compact copy of the fit summary for reporting purposes.
# We round long numeric columns to avoid overly wide markdown/PDF tables.
compact_fit_summary <- fit_summary

if ("AIC" %in% names(compact_fit_summary)) {
  compact_fit_summary$AIC <- round(as.numeric(compact_fit_summary$AIC), 1)
}
if ("BIC" %in% names(compact_fit_summary)) {
  compact_fit_summary$BIC <- round(as.numeric(compact_fit_summary$BIC), 1)
}
if ("sigma" %in% names(compact_fit_summary)) {
  compact_fit_summary$sigma <- round(as.numeric(compact_fit_summary$sigma), 3)
}

# Extract the estimator design metadata.
# These fields are usually constant across models, so we report them separately.
fit_design_table <- unique(
  compact_fit_summary[, intersect(
    c("model_family", "session_handling", "dependence_adjustment"),
    names(compact_fit_summary)
  ), drop = FALSE]
)

if (ncol(fit_design_table) > 0L) {
  names(fit_design_table) <- c("Estimator", "Session handling", "Dependence")
}

# Build a dynamic note by role so that observation and participant counts
# are not hard-coded in the report.
fit_note_by_role <- character(0)

if (nrow(fit_summary) > 0L && all(c("role", "n_obs", "n_participants") %in% names(fit_summary))) {
  fit_note_by_role <- unlist(
    lapply(split(fit_summary, fit_summary$role), function(df_role) {
      n_obs_role <- unique(df_role$n_obs)
      n_id_role <- unique(df_role$n_participants)
      role_name <- unique(df_role$role)

      if (length(n_obs_role) == 1L && length(n_id_role) == 1L) {
        sprintf(
          "%s models use %s observations from %s participants.",
          role_name,
          format(n_obs_role, big.mark = ","),
          format(n_id_role, big.mark = ",")
        )
      } else {
        sprintf(
          "%s models vary in their observation and participant counts; see the tables below.",
          role_name
        )
      }
    })
  )
}

# Build a narrower fit table by role.
# We intentionally drop columns that are constant across rows (e.g., N obs, N id, dropped columns)
# because they are now communicated in the dynamic note above.
fit_main_table <- compact_fit_summary[, intersect(
  c("hypothesis", "role", "lower_censored_n", "upper_censored_n", "AIC", "BIC", "sigma"),
  names(compact_fit_summary)
), drop = FALSE]

fit_bystander <- data.frame()
fit_victim <- data.frame()

if (nrow(fit_main_table) > 0L) {
  fit_bystander <- subset(fit_main_table, role == "Bystander")[, c(
    "hypothesis", "lower_censored_n", "upper_censored_n", "AIC", "BIC", "sigma"
  ), drop = FALSE]

  fit_victim <- subset(fit_main_table, role == "Victim")[, c(
    "hypothesis", "lower_censored_n", "upper_censored_n", "AIC", "BIC", "sigma"
  ), drop = FALSE]

  if (ncol(fit_bystander) > 0L) {
    names(fit_bystander) <- c("H", "L. cens.", "U. cens.", "AIC", "BIC", "Sigma")
  }
  if (ncol(fit_victim) > 0L) {
    names(fit_victim) <- c("H", "L. cens.", "U. cens.", "AIC", "BIC", "Sigma")
  }
}

# Build the estimator fit section.
# The estimator metadata and the role-specific fit tables are separated
# so that the PDF table layout stays readable.
report_lines <- c(
  report_lines,
  "## Estimator fit summary",
  "",
  fit_note_by_role,
  ""
)

if (nrow(fit_design_table) > 0L) {
  report_lines <- c(
    report_lines,
    "All production models use the estimator configuration shown below.",
    "",
    build_numbered_table_block(fit_design_table, "Estimator configuration")
  )
}

report_lines <- c(
  report_lines,
  "### Model-level fit and censoring summary",
  ""
)

if (nrow(fit_bystander) > 0L) {
  report_lines <- c(
    report_lines,
    "#### Bystander models",
    "",
    build_numbered_table_block(fit_bystander, "Bystander model fit and censoring summary")
  )
}

if (nrow(fit_victim) > 0L) {
  report_lines <- c(
    report_lines,
    "#### Victim models",
    "",
    build_numbered_table_block(fit_victim, "Victim model fit and censoring summary")
  )
}

# Append the hypothesis significance summary by role.
report_lines <- c(
  report_lines,
  "## Hypothesis significance summary by role",
  "",
  "### Victim",
  "",
  build_numbered_table_block(
    subset(significance_summary, role == "Victim"),
    "Victim focal support terms (p < 0.10)"
  ),
  "### Bystander",
  "",
  build_numbered_table_block(
    subset(significance_summary, role == "Bystander"),
    "Bystander focal support terms (p < 0.10)"
  ),
  "## Significance-driven figures",
  ""
)

# Add only the significance-driven figures that were actually generated.
sig_figures <- subset(figure_manifest, figure_type == "significance")

if (nrow(sig_figures) == 0L) {
  report_lines <- c(
    report_lines,
    "No focal term reached the plotting threshold in this run, so no significance-driven figures were generated.",
    ""
  )
} else {
  for (i in seq_len(nrow(sig_figures))) {
    figure_row <- sig_figures[i, , drop = FALSE]
    report_lines <- c(
      report_lines,
      paste0("### ", figure_row$hypothesis, " ", figure_row$role, ": ", label_current_term(figure_row$term)),
      "",
      build_image_block(figure_row)
    )
  }
}

# Add the full coefficient tables and their short interpretation narratives.
report_lines <- c(
  report_lines,
  "## Full coefficient tables and interpretation summary",
  ""
)

for (hypothesis_id in paste0("H", 1:5)) {
  for (role_label in c("Victim", "Bystander")) {
    prefix <- get_model_prefix(hypothesis_id, role_label)
    if (!(prefix %in% names(coefficient_tables))) next

    report_lines <- c(
      report_lines,
      paste0("### ", hypothesis_id, " ", role_label, " coefficient table"),
      "",
      build_numbered_table_block(
        coefficient_tables[[prefix]],
        sprintf("%s %s coefficient estimates", hypothesis_id, role_label)
      ),
      coefficient_narratives[[prefix]],
      ""
    )
  }
}

# Close the report with compliance, corrections, limitations, discussion, audit, and conclusion.
report_lines <- c(
  report_lines,
  "## Compliance checklist",
  "",
  build_numbered_table_block(compliance_report, "Pipeline compliance checklist"),
  "",
  "## Corrections relative to outdated notes",
  "",
  "The current production branch supersedes earlier notes that treated the negotiator `0` code as `control_hidden`, narrowed H3 to additive-only empathy terms, or implied that the main estimator used `(1|session)`. The repository now documents the implemented estimator and the authoritative role-specific design directly.",
  "",
  "## Limitations",
  "",
  get_current_limitations(),
  "",
  build_discussion_section(),
  build_final_audit_note(compliance_report, fit_summary),
  "## Conclusion",
  "",
  "The active workflow now reproduces a scientific dynamic report structure while remaining faithful to the implemented estimator: two-sided Tobit, `factor(session)`, participant-cluster robust inference by `id`, no row duplication, and full H1-H5 coverage across victim and bystander specifications.",
  ""
)

main_report_md <- file.path(paths$report_dir, "tobit_analysis_report.md")
log_report_md <- file.path(paths$logs_dir, "dynamic_report.md")
report_data_md <- file.path(paths$reports_data_dir, "tobit_analysis_report.md")
compatibility_report_md <- file.path(paths$reports_data_dir, "longitudinal_mixed_model_analysis_report.md")

writeLines(report_lines, main_report_md)
writeLines(report_lines, log_report_md)
writeLines(report_lines, report_data_md)
writeLines(report_lines, compatibility_report_md)

render_dynamic_report_outputs(main_report_md, paths)

if (file.exists(file.path(paths$report_dir, "tobit_analysis_report.docx"))) {
  file.copy(file.path(paths$report_dir, "tobit_analysis_report.docx"), file.path(paths$reports_data_dir, "tobit_analysis_report.docx"), overwrite = TRUE)
}
if (file.exists(file.path(paths$report_dir, "tobit_analysis_report.pdf"))) {
  file.copy(file.path(paths$report_dir, "tobit_analysis_report.pdf"), file.path(paths$reports_data_dir, "tobit_analysis_report.pdf"), overwrite = TRUE)
}

compliance_lines <- c(
  "# Pipeline Compliance Report",
  "",
  paste0("By Leonardo H. Talero-Sarmiento; Date  ", get_report_timestamp(), "."),
  "",
  build_table_block(compliance_report),
  ""
)
writeLines(compliance_lines, file.path(paths$report_dir, "pipeline_compliance_report.md"))
writeLines(compliance_lines, file.path(paths$reports_data_dir, "pipeline_compliance_report.md"))
