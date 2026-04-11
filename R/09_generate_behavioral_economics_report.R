# R/09_generate_behavioral_economics_report.R
# Purpose: Build a compact behavioral-economics-style dynamic report focused on
# Materials and Methods, Results, Limitations, and Conclusion.

source("R/00_config.R")
source("R/utils/io_functions.R")
source("R/utils/table_functions.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
source("R/utils/figure_functions.R")

paths <- get_project_paths()
active_model_suffixes <- resolve_active_model_suffixes()

report_pipeline_mode <- toupper(trimws(as.character(
  getOption("tobit.pipeline_mode", get_default_pipeline_mode())
)))
if (!(report_pipeline_mode %in% c("TOBIT", "BOTH"))) {
  report_pipeline_mode <- "TOBIT"
}

report_includes_nonparametric <- function() {
  identical(report_pipeline_mode, "BOTH")
}

message("Generating Compact Behavioral-Economics Journal Report (Markdown/Word)...")

read_csv_if_exists <- function(path) {
  if (!file.exists(path)) {
    return(NULL)
  }
  read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
}

format_count_value <- function(x) {
  if (length(x) == 0L || is.na(x[1])) return("NA")
  format(as.integer(x[1]), big.mark = ",", scientific = FALSE, trim = TRUE)
}

format_decimal <- function(x, digits = 2L) {
  if (length(x) == 0L || is.na(x[1])) return("NA")
  formatC(x[1], digits = digits, format = "f")
}

format_percent <- function(x, digits = 1L) {
  if (length(x) == 0L || is.na(x[1])) return("NA")
  paste0(formatC(100 * x[1], digits = digits, format = "f"), "%")
}

format_p_display <- function(p) {
  if (length(p) == 0L || is.na(p[1])) return("NA")
  format_p_value_with_symbol(p[1])
}

format_p_clause <- function(p_value) {
  p_text <- format_p_value(p_value)
  if (startsWith(p_text, "<")) {
    return(paste("p", sub("^<", "< ", p_text)))
  }
  paste("p =", p_text)
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

sync_dataset_specific_report_aliases <- function(dataset_mode, base_stem, log_stem = NULL) {
  report_alias_stem <- get_dataset_specific_stem(base_stem, dataset_mode)
  if (!is.null(report_alias_stem)) {
    for (ext in c(".md", ".docx")) {
      copy_if_present(
        file.path(paths$report_dir, paste0(base_stem, ext)),
        file.path(paths$report_dir, paste0(report_alias_stem, ext))
      )
    }
  }

  if (!is.null(log_stem)) {
    log_alias_stem <- get_dataset_specific_stem(log_stem, dataset_mode)
    if (!is.null(log_alias_stem)) {
      copy_if_present(
        file.path(paths$logs_dir, paste0(log_stem, ".md")),
        file.path(paths$logs_dir, paste0(log_alias_stem, ".md"))
      )
    }
  }

  invisible(TRUE)
}

render_word <- function(md_file) {
  pandoc_cmd <- Sys.which("pandoc")
  if (!nzchar(pandoc_cmd)) {
    warning("pandoc not found; skipping journal-style Word render.")
    return(FALSE)
  }

  report_dir <- normalizePath(dirname(md_file), winslash = "/", mustWork = TRUE)
  md_name <- basename(md_file)
  target_docx <- file.path(report_dir, sub("\\.md$", ".docx", md_name))
  build_docx <- file.path(report_dir, sub("\\.md$", "_build.docx", md_name))

  old_wd <- getwd()
  setwd(report_dir)
  on.exit(setwd(old_wd), add = TRUE)
  on.exit(if (file.exists(build_docx)) unlink(build_docx, force = TRUE), add = TRUE)

  status <- system2(
    pandoc_cmd,
    args = c("-s", md_name, "-o", basename(build_docx)),
    stdout = NULL,
    stderr = NULL
  )

  if (!identical(status, 0L) || !file.exists(build_docx)) {
    warning(sprintf("Pandoc failed while rendering %s.", basename(target_docx)))
    return(FALSE)
  }

  copied <- file.copy(build_docx, target_docx, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
  if (copied) {
    return(TRUE)
  }

  fallback_docx <- file.path(
    report_dir,
    sprintf(
      "%s_updated_%s.docx",
      tools::file_path_sans_ext(basename(target_docx)),
      format(Sys.time(), "%Y%m%d_%H%M%S")
    )
  )
  fallback_written <- file.copy(build_docx, fallback_docx, overwrite = TRUE, copy.mode = TRUE, copy.date = TRUE)
  warning(sprintf(
    paste(
      "Built a fresh Word file but could not overwrite %s.",
      "This usually means the file is open in another program.",
      "Updated copy saved to %s."
    ),
    target_docx,
    if (fallback_written) fallback_docx else build_docx
  ))
  FALSE
}

build_markdown_table_block <- function(df, note = NULL, digits = 3L) {
  block <- to_markdown_table(df, digits = digits)
  if (!is.null(note) && nzchar(note)) {
    block <- c(block, "", paste0("_Note._ ", note))
  }
  c(block, "")
}

build_figure_markdown <- function(file_name, caption, width = "6.7in") {
  figure_path <- file.path("../figures", file_name)
  c(
    sprintf("![%s](%s){ width=%s }", caption, figure_path, width),
    ""
  )
}

read_fit_stats <- function(output_prefix) {
  stats_file <- file.path(paths$models_dir, sprintf("%s_fit_stats.csv", output_prefix))
  if (!file.exists(stats_file)) return(NULL)
  read.csv(stats_file, stringsAsFactors = FALSE)
}

read_coefficients <- function(output_prefix) {
  coef_file <- file.path(paths$models_dir, sprintf("%s_coefficients.csv", output_prefix))
  if (!file.exists(coef_file)) return(NULL)
  read.csv(coef_file, stringsAsFactors = FALSE)
}

collect_focal_rows <- function(hypothesis_id, model_suffixes = active_model_suffixes, subset_roles = c("Victim", "Bystander")) {
  hypothesis_id <- toupper(trimws(hypothesis_id))
  signal_df <- read_csv_if_exists(file.path(paths$tables_dir, "hypothesis_signal_details.csv"))

  if (!is.null(signal_df) && nrow(signal_df) > 0L) {
    rows <- signal_df[
      signal_df$hypothesis_family_id == hypothesis_id &
        signal_df$approach == "Tobit" &
        signal_df$model_suffix %in% model_suffixes &
        signal_df$subset_role %in% subset_roles,
      ,
      drop = FALSE
    ]
    if (nrow(rows) > 0L) {
      rows$conf_low <- NA_real_
      rows$conf_high <- NA_real_
      for (idx in seq_len(nrow(rows))) {
        coef_df <- read_coefficients(rows$output_prefix[idx])
        if (is.null(coef_df) || nrow(coef_df) == 0L) next
        matched <- coef_df[coef_df$term == rows$term[idx], , drop = FALSE]
        if (nrow(matched) == 0L) {
          matched <- coef_df[coef_df$term == rows$canonical_term[idx], , drop = FALSE]
        }
        if (nrow(matched) == 0L && "canonical_term" %in% names(coef_df)) {
          matched <- coef_df[coef_df$canonical_term == rows$canonical_term[idx], , drop = FALSE]
        }
        if (nrow(matched) == 0L) next
        rows$conf_low[idx] <- matched$conf_low[1]
        rows$conf_high[idx] <- matched$conf_high[1]
      }
      return(rows)
    }
  }

  fallback_rows <- list()
  idx <- 1L
  for (model_suffix in model_suffixes) {
    for (subset_role in subset_roles) {
      output_prefix <- sprintf("%s_%s_%s", hypothesis_id, model_suffix, subset_role)
      coef_df <- read_coefficients(output_prefix)
      if (is.null(coef_df) || nrow(coef_df) == 0L) next

      focal_mask <- switch(
        hypothesis_id,
        H1 = coef_df$term %in% c("iri_total", "iri_fs", "iri_ec", "iri_pt", "iri_pd"),
        H2 = grepl("^h2_negstruct_|^player_victim_outgroup(:|$)", coef_df$term),
        H3 = grepl(":", coef_df$term) & grepl("^iri_|:judged_", coef_df$term),
        rep(FALSE, nrow(coef_df))
      )
      coef_df <- coef_df[focal_mask, , drop = FALSE]
      if (nrow(coef_df) == 0L) next
      coef_df <- coef_df[order(coef_df$p_value), , drop = FALSE]
      coef_df <- head(coef_df, 3L)
      coef_df$hypothesis_family_id <- hypothesis_id
      coef_df$subset_role <- subset_role
      coef_df$model_suffix <- model_suffix
      coef_df$model_label <- model_suffix
      coef_df$label_short <- if ("label_short" %in% names(coef_df)) coef_df$label_short else coef_df$label
      fallback_rows[[idx]] <- coef_df
      idx <- idx + 1L
    }
  }

  if (length(fallback_rows) == 0L) {
    return(NULL)
  }

  do.call(rbind, fallback_rows)
}

prepare_result_table <- function(rows, max_rows = NULL) {
  if (is.null(rows) || nrow(rows) == 0L) {
    return(data.frame(
      Subset = "NA",
      Model = "NA",
      Predictor = "No focal estimates were available",
      `b [95% CI]` = "NA",
      p = "NA",
      stringsAsFactors = FALSE,
      check.names = FALSE
    ))
  }

  if (!("conf_low" %in% names(rows))) {
    rows$conf_low <- NA_real_
  }
  if (!("conf_high" %in% names(rows))) {
    rows$conf_high <- NA_real_
  }

  rows <- rows[order(factor(rows$subset_role, levels = c("Victim", "Bystander")), rows$p_value), , drop = FALSE]
  if (!is.null(max_rows) && nrow(rows) > max_rows) {
    rows <- rows[seq_len(max_rows), , drop = FALSE]
  }

  data.frame(
    Subset = rows$subset_role,
    Model = rows$model_suffix,
    Predictor = rows$label_short,
    `b [95% CI]` = vapply(seq_len(nrow(rows)), function(idx) {
      sprintf(
        "%s [%s, %s]",
        format_decimal(rows$estimate[idx], digits = 2L),
        format_decimal(rows$conf_low[idx], digits = 2L),
        format_decimal(rows$conf_high[idx], digits = 2L)
      )
    }, character(1)),
    p = vapply(rows$p_value, format_p_display, character(1)),
    stringsAsFactors = FALSE,
    check.names = FALSE
  )
}

summarize_subset_top_rows <- function(rows, subset_role, max_rows = 3L) {
  if (is.null(rows) || nrow(rows) == 0L) return(NULL)
  subset_rows <- rows[rows$subset_role == subset_role, , drop = FALSE]
  if (nrow(subset_rows) == 0L) return(NULL)
  subset_rows <- subset_rows[order(subset_rows$p_value), , drop = FALSE]
  subset_rows <- head(subset_rows, max_rows)

  descriptors <- apply(subset_rows, 1, function(row) {
    direction <- if (is.na(as.numeric(row[["estimate"]]))) {
      "uncertain direction"
    } else if (as.numeric(row[["estimate"]]) < 0) {
      "more negative judgments"
    } else {
      "more positive judgments"
    }
    sprintf(
      "%s (%s; b = %s, %s; %s)",
      row[["label_short"]],
      row[["model_suffix"]],
      format_decimal(as.numeric(row[["estimate"]]), digits = 2L),
      format_p_clause(as.numeric(row[["p_value"]])),
      direction
    )
  })

  if (length(descriptors) == 1L) return(descriptors)
  if (length(descriptors) == 2L) return(paste(descriptors, collapse = " and "))
  paste(paste(descriptors[-length(descriptors)], collapse = ", "), descriptors[length(descriptors)], sep = ", and ")
}

count_unique_signals <- function(rows, subset_role = NULL) {
  if (is.null(rows) || nrow(rows) == 0L) return(0L)
  if (!is.null(subset_role)) {
    rows <- rows[rows$subset_role == subset_role, , drop = FALSE]
  }
  if (nrow(rows) == 0L) return(0L)
  key_col <- if ("canonical_term" %in% names(rows)) "canonical_term" else "term"
  length(unique(rows[[key_col]]))
}

build_family_signal_intro <- function(family_label, rows, focal_label) {
  victim_n <- count_unique_signals(rows, "Victim")
  bystander_n <- count_unique_signals(rows, "Bystander")

  if (victim_n == 0L && bystander_n == 0L) {
    return(sprintf(
      "At the reporting threshold, %s produced no focal %s in either subset.",
      family_label,
      focal_label
    ))
  }

  if (victim_n > 0L && bystander_n > 0L) {
    density_text <- if (victim_n > bystander_n) {
      "Signals were denser in the victim subset."
    } else if (bystander_n > victim_n) {
      "Signals were denser in the bystander subset."
    } else {
      "Signal density was similar across subsets."
    }
    return(sprintf(
      "At the reporting threshold, %s produced focal %s in both subsets. %s",
      family_label,
      focal_label,
      density_text
    ))
  }

  if (victim_n > 0L) {
    return(sprintf(
      "At the reporting threshold, %s produced focal %s only in the victim subset.",
      family_label,
      focal_label
    ))
  }

  sprintf(
    "At the reporting threshold, %s produced focal %s only in the bystander subset.",
    family_label,
    focal_label
  )
}

select_hypothesis_figure <- function(hypothesis_id) {
  catalog <- read_csv_if_exists(file.path(paths$tables_dir, "hypothesis_figure_catalog.csv"))
  signal_df <- read_csv_if_exists(file.path(paths$tables_dir, "hypothesis_signal_details.csv"))
  if (is.null(catalog) || is.null(signal_df) || nrow(catalog) == 0L || nrow(signal_df) == 0L) {
    return(NULL)
  }

  family_rows <- signal_df[
    signal_df$hypothesis_family_id == hypothesis_id &
      signal_df$approach == "Tobit",
    ,
    drop = FALSE
  ]
  if (nrow(family_rows) == 0L) return(NULL)
  family_rows <- family_rows[order(family_rows$p_value), , drop = FALSE]

  for (predictor in family_rows$label_short) {
    matched <- catalog[catalog$Hypothesis == hypothesis_id & catalog$Predictor == predictor, , drop = FALSE]
    if (nrow(matched) == 0L) next
    figure_name <- matched$Figure[1]
    figure_path <- file.path(paths$figures_dir, figure_name)
    if (file.exists(figure_path)) {
      return(list(
        predictor = predictor,
        file_name = figure_name,
        figure_type = matched$FigureType[1]
      ))
    }
  }

  NULL
}

build_sample_table <- function(pooled_df, victim_df, bystander_df) {
  sample_specs <- list(
    list(label = "Pooled", data = pooled_df),
    list(label = "Victim", data = victim_df),
    list(label = "Bystander", data = bystander_df)
  )

  rows <- lapply(sample_specs, function(spec) {
    df <- spec$data
    if (is.null(df) || nrow(df) == 0L) {
      return(data.frame(
        Sample = spec$label,
        Participants = NA_integer_,
        Judgments = NA_integer_,
        `Judgments / participant` = NA_real_,
        `Mean judgment` = NA_real_,
        SD = NA_real_,
        `% at -9` = NA_real_,
        `% at 9` = NA_real_,
        stringsAsFactors = FALSE,
        check.names = FALSE
      ))
    }

    participant_n <- length(unique(df$id))
    judgment_n <- nrow(df)

    data.frame(
      Sample = spec$label,
      Participants = participant_n,
      Judgments = judgment_n,
      `Judgments / participant` = round(judgment_n / participant_n, 2),
      `Mean judgment` = round(mean(df$judgement, na.rm = TRUE), 2),
      SD = round(stats::sd(df$judgement, na.rm = TRUE), 2),
      `% at -9` = round(mean(df$judgement == -9, na.rm = TRUE), 3),
      `% at 9` = round(mean(df$judgement == 9, na.rm = TRUE), 3),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  })

  sample_df <- do.call(rbind, rows)
  sample_df$`% at -9` <- vapply(sample_df$`% at -9`, format_percent, character(1), digits = 1L)
  sample_df$`% at 9` <- vapply(sample_df$`% at 9`, format_percent, character(1), digits = 1L)
  sample_df
}

build_robustness_table <- function() {
  victim_summary <- read_csv_if_exists(file.path(paths$tables_dir, "hypothesis_summary_victim.csv"))
  bystander_summary <- read_csv_if_exists(file.path(paths$tables_dir, "hypothesis_summary_bystander.csv"))
  if (is.null(victim_summary) || is.null(bystander_summary)) return(NULL)
  if (!("Non-parametric support" %in% names(victim_summary)) || !("Non-parametric support" %in% names(bystander_summary))) {
    return(NULL)
  }

  hypotheses <- unique(c(victim_summary$Hypothesis, bystander_summary$Hypothesis))
  hypotheses <- hypotheses[order(hypotheses)]

  rows <- lapply(hypotheses, function(hyp) {
    victim_row <- victim_summary[victim_summary$Hypothesis == hyp, , drop = FALSE]
    bystander_row <- bystander_summary[bystander_summary$Hypothesis == hyp, , drop = FALSE]
    data.frame(
      Hypothesis = hyp,
      `Victim Tobit` = if (nrow(victim_row)) victim_row$`Tobit support`[1] else "NA",
      `Victim NP` = if (nrow(victim_row)) victim_row$`Non-parametric support`[1] else "NA",
      `Bystander Tobit` = if (nrow(bystander_row)) bystander_row$`Tobit support`[1] else "NA",
      `Bystander NP` = if (nrow(bystander_row)) bystander_row$`Non-parametric support`[1] else "NA",
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  })

  do.call(rbind, rows)
}

participants_df <- read_csv_if_exists(paths$processed_participants)
judgments_df <- read_csv_if_exists(paths$processed_judgments)
victim_df <- read_csv_if_exists(paths$processed_victim)
bystander_df <- read_csv_if_exists(paths$processed_bystander)

participant_n <- if (is.null(judgments_df)) NA_integer_ else length(unique(judgments_df$id))
judgment_n <- if (is.null(judgments_df)) NA_integer_ else nrow(judgments_df)
victim_participant_n <- if (is.null(victim_df)) NA_integer_ else length(unique(victim_df$id))
bystander_participant_n <- if (is.null(bystander_df)) NA_integer_ else length(unique(bystander_df$id))

h1_rows <- collect_focal_rows("H1")
h2_rows <- collect_focal_rows("H2")
h3_rows <- collect_focal_rows("H3")

h1_table <- prepare_result_table(h1_rows, max_rows = 10L)
h2_table <- prepare_result_table(h2_rows, max_rows = 10L)
h3_table <- prepare_result_table(h3_rows, max_rows = 10L)
sample_table <- build_sample_table(judgments_df, victim_df, bystander_df)
robustness_table <- if (report_includes_nonparametric()) build_robustness_table() else NULL

h1_victim_text <- summarize_subset_top_rows(h1_rows, "Victim", max_rows = 3L)
h1_bystander_text <- summarize_subset_top_rows(h1_rows, "Bystander", max_rows = 3L)
h2_victim_text <- summarize_subset_top_rows(h2_rows, "Victim", max_rows = 2L)
h2_bystander_text <- summarize_subset_top_rows(h2_rows, "Bystander", max_rows = 3L)
h3_victim_text <- summarize_subset_top_rows(h3_rows, "Victim", max_rows = 3L)
h3_bystander_text <- summarize_subset_top_rows(h3_rows, "Bystander", max_rows = 3L)

h1_intro_text <- build_family_signal_intro("H1", h1_rows, "empathy effects")
h2_intro_text <- build_family_signal_intro("H2", h2_rows, "relational-structure effects")
h3_intro_text <- build_family_signal_intro("H3", h3_rows, "moderation effects")

h1_figure <- select_hypothesis_figure("H1")
h2_figure <- select_hypothesis_figure("H2")
h3_figure <- select_hypothesis_figure("H3")

figure_victim_case_panels_file <- get_standard_figure_filename("victim_case_panels")
figure_bystander_case_panels_file <- get_standard_figure_filename("bystander_case_panels")

robustness_sentence <- if (report_includes_nonparametric()) {
  "Because the current configuration requests both estimators, the report also summarizes the non-parametric censored robustness branch alongside the Tobit results."
} else {
  "The current configuration estimates Tobit as the main model and does not add the non-parametric robustness branch."
}

results_robustness_paragraph <- if (report_includes_nonparametric() && !is.null(robustness_table)) {
  "The non-parametric branch largely serves as a robustness screen rather than a second full results section. Table 5 therefore reports concordance at the hypothesis-summary level instead of duplicating full coefficient output."
} else {
  "Because the active configuration is Tobit-only, the results section reports the main censored-model estimates without a separate robustness table."
}

report_title <- "Behavioral-Economics Style Dynamic Report"
report_stem <- "tobit_behavioral_economics_report"
report_path <- file.path(paths$report_dir, paste0(report_stem, ".md"))
log_path <- file.path(paths$logs_dir, "behavioral_economics_report.md")

md_lines <- c(
  paste0("# ", report_title),
  "",
  sprintf("Generated on %s.", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  "## Materials and Methods",
  "",
  sprintf(
    paste(
      "The journal-style report uses the pooled analytical file rather than splitting the narrative by source dataset.",
      "The analyzed sample contains %s participants and %s judgment-by-negotiator observations after preprocessing.",
      "Each participant contributes two judgments per scenario, one for each negotiator, so the long-format outcome is defined at the judgment-by-negotiator level throughout."
    ),
    format_count_value(participant_n),
    format_count_value(judgment_n)
  ),
  "",
  sprintf(
    paste(
      "Role-specific estimation remains central to the design, but it is handled within a single narrative.",
      "The victim subset contributes %s participants, whereas the bystander subset contributes %s participants.",
      "In the victim subset, ingroup/outgroup/control coding is defined relative to the victim-player; in the bystander subset, negotiator-side coding is defined relative to the observer and is paired with the observer-victim ingroup/outgroup relation."
    ),
    format_count_value(victim_participant_n),
    format_count_value(bystander_participant_n)
  ),
  "",
  "To respect journal space constraints, the report uses four compact tables and five figures, with a fifth table added only when the non-parametric robustness branch is enabled. The figure plan prioritizes the two six-panel descriptive subset figures plus one focal figure each for H1, H2, and H3, selected from the dynamic figure catalog by the lowest Tobit p-value among focal predictors. The table plan prioritizes one design table and one compact results table for each hypothesis family.",
  "",
  "The bounded outcome is observed judgment severity on the original -9 to 9 scale. The main estimator is a Tobit model with censoring at the observed bounds and cluster-robust inference by participant id. The robustness branch is included only when the active configuration requests both estimators.",
  "",
  "$$y_{isn}^{obs} = \\min\\{9,\\max[-9, y_{isn}^{*}]\\}$$",
  "",
  "For H1, empathy enters through the four IRI dimensions (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`), together with judged-negotiator status, counterpart status, decision outcome, subset-relevant victim alignment, and participant controls.",
  "",
  "$$y_{isn}^{*} = \\alpha_r + \\mathbf{E}_i\\beta_r + \\mathbf{R}_{isn}\\gamma_r + \\mathbf{X}_i\\delta_r + \\varepsilon_{isn}$$",
  "",
  "For H2, the victim subset uses the joint judged-counterpart structure directly, whereas the bystander subset augments that structure with the observer-victim relation and their interaction.",
  "",
  "$$y_{isn,V}^{*} = \\alpha_V + \\mathbf{S}_{isn}\\theta_V + \\mathbf{E}_i\\beta_V + \\mathbf{X}_i\\delta_V + \\varepsilon_{isn}$$",
  "",
  "$$y_{isn,O}^{*} = \\alpha_O + \\mathbf{S}_{isn}\\theta_O + V_{isn}\\lambda_O + (\\mathbf{S}_{isn}\\times V_{isn})\\kappa_O + \\mathbf{E}_i\\beta_O + \\mathbf{X}_i\\delta_O + \\varepsilon_{isn}$$",
  "",
  "For H3, empathy is allowed to interact with judged-negotiator status while decision outcome, judged-status-by-decision terms, counterpart structure, and subset-relevant controls remain in the model.",
  "",
  "$$y_{isn}^{*} = \\alpha_r + \\mathbf{E}_i\\beta_r + \\mathbf{J}_{isn}\\eta_r + A_{isn}\\pi_r + (\\mathbf{E}_i \\times \\mathbf{J}_{isn})\\rho_r + (A_{isn} \\times \\mathbf{J}_{isn})\\tau_r + \\mathbf{C}_{isn}\\phi_r + \\mathbf{X}_i\\delta_r + \\varepsilon_{isn}$$",
  "",
  robustness_sentence,
  "",
  "Table 1 reports the pooled design and outcome distribution that anchor the rest of the journal-style summary.",
  "",
  build_markdown_table_block(
    sample_table,
    note = paste(
      "Pooled = full analytical long file.",
      "Each scenario contributes two judgment observations per participant, one per negotiator.",
      "Outcome bounds are the observed censoring points used by the Tobit estimator."
    ),
    digits = 2L
  ),
  "## Results",
  "",
  "The descriptive distributions already show why subset-specific estimation matters: the victim and bystander judgment profiles are not identical across the six scenario configurations, even though both are evaluated on the same bounded scale. Figures 1 and 2 therefore retain the subset split at the descriptive level while keeping the narrative pooled and compact.",
  "",
  build_figure_markdown(
    figure_victim_case_panels_file,
    "Figure 1. Victim-subset judgment distributions across the six explicit case configurations. The histogram scale is fixed at -9 to 9 to match the observed judgment bounds.",
    width = "6.7in"
  ),
  build_figure_markdown(
    figure_bystander_case_panels_file,
    "Figure 2. Bystander-subset judgment distributions across the six explicit case configurations. The histogram scale is fixed at -9 to 9 to match the observed judgment bounds.",
    width = "6.7in"
  ),
  h1_intro_text,
  "The compact summary in Table 2 focuses on the active four-construct empathy specification. In the victim subset, the strongest focal estimates were",
  if (!is.null(h1_victim_text)) paste0(h1_victim_text, ".") else "not available at the reporting threshold.",
  "In the bystander subset, the corresponding focal estimates were",
  if (!is.null(h1_bystander_text)) paste0(h1_bystander_text, ".") else "not available at the reporting threshold.",
  "The H1 narrative below is generated from the currently saved focal coefficient rows rather than from a fixed template.",
  "",
  build_markdown_table_block(
    h1_table,
    note = paste(
      "Active empathy specification = FS, EC, PT, PD.",
      "N1 = judged negotiator; N2 = counterpart negotiator; V = observer-victim relation; In = ingroup; Out = outgroup; Ctl = control label hidden; Acc = accepted harmful deal.",
      "The table is intentionally restricted to focal empathy estimates reported by the dynamic pipeline."
    ),
    digits = 2L
  ),
  if (!is.null(h1_figure)) build_figure_markdown(
    h1_figure$file_name,
    sprintf(
      "Figure 3. Selected H1 focal effect (%s). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95%% confidence intervals.",
      h1_figure$predictor
    ),
    width = "6.4in"
  ) else character(0),
  h2_intro_text,
  "In the victim subset, the most relevant H2 estimate was",
  if (!is.null(h2_victim_text)) paste0(h2_victim_text, ".") else "not available at the reporting threshold.",
  "In the bystander subset, the most relevant H2 estimates were",
  if (!is.null(h2_bystander_text)) paste0(h2_bystander_text, ".") else "not available at the reporting threshold.",
  "This role difference is substantively important because the bystander model adds the player-victim relation and its interaction with negotiator-side structure, whereas the victim model does not require that extra layer.",
  "",
  build_markdown_table_block(
    h2_table,
    note = paste(
      "Active empathy specification = FS, EC, PT, PD.",
      "N1 = judged negotiator; N2 = counterpart negotiator; V = observer-victim relation.",
      "Only focal H2 structure and observer-side interaction terms are shown."
    ),
    digits = 2L
  ),
  if (!is.null(h2_figure)) build_figure_markdown(
    h2_figure$file_name,
    sprintf(
      "Figure 4. Selected H2 relational effect (%s). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95%% confidence intervals.",
      h2_figure$predictor
    ),
    width = "6.4in"
  ) else character(0),
  h3_intro_text,
  "In the victim subset, the leading H3 interactions were",
  if (!is.null(h3_victim_text)) paste0(h3_victim_text, ".") else "not available at the reporting threshold.",
  "In the bystander subset, the leading H3 interactions were",
  if (!is.null(h3_bystander_text)) paste0(h3_bystander_text, ".") else "not available at the reporting threshold.",
  "The interaction summary below is generated from the currently saved focal coefficient rows rather than from a fixed template.",
  "",
  build_markdown_table_block(
    h3_table,
    note = paste(
      "Active empathy specification = FS, EC, PT, PD.",
      "N1 = judged negotiator; N2 = counterpart negotiator; Acc = accepted harmful deal.",
      "Only focal H3 empathy-by-judged-status interactions are shown."
    ),
    digits = 2L
  ),
  if (!is.null(h3_figure)) build_figure_markdown(
    h3_figure$file_name,
    sprintf(
      "Figure 5. Selected H3 interaction effect (%s). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95%% confidence intervals.",
      h3_figure$predictor
    ),
    width = "6.4in"
  ) else character(0),
  results_robustness_paragraph,
  "",
  if (!is.null(robustness_table)) build_markdown_table_block(
    robustness_table,
    note = paste(
      "NP = non-parametric robustness branch.",
      "Entries summarize hypothesis-level support rather than duplicating coefficient tables."
    ),
    digits = 2L
  ) else character(0),
  "## Limitations",
  "",
  "Several limitations qualify the interpretation. First, repeated judgments are clustered within participant, and although the pipeline addresses this with participant-level clustered inference, the design still concentrates multiple morally related responses within the same respondent. Second, the bounded outcome requires censoring-aware estimation because the judgment scale piles up at both -9 and 9. Third, ingroup/outgroup/control coding is relational rather than purely individual, so the same participant can appear in different judged-counterpart structures across scenarios. Fourth, subset-specific formulas are a design strength for identification but they also mean that coefficient blocks are not perfectly symmetric across victim and bystander models.",
  "",
  if (report_includes_nonparametric()) {
    "The robustness branch adds a useful non-parametric check, but it remains more fragile than the Tobit estimator because censored median regression with participant-level bootstrap inference can be sparse or unstable in some specifications. For that reason, the journal-style report treats it as corroborating evidence rather than as a co-equal primary estimator."
  } else {
    "Because the current configuration does not include the non-parametric branch, robustness to alternative censored estimators is not assessed in this report version."
  },
  "",
  "## Conclusion",
  "",
  "Across the pooled analytical sample, the clearest behavioral pattern is that empathy-related variation in judgment is conditional on relational context rather than separable from it. Victim judgments show the strongest empathy gradients, bystander judgments retain smaller but still interpretable empathy effects, H2 highlights a narrower set of role-dependent relational contrasts, and H3 indicates that empathy slopes change with judged-negotiator status. In behavioral terms, moral evaluation in this design is jointly shaped by empathic orientation, the judged negotiator's relational position, and the participant's role in the scenario.",
  ""
)

write_text_file(md_lines, report_path)
write_text_file(md_lines, log_path)
word_rendered <- render_word(report_path)
sync_dataset_specific_report_aliases(paths$dataset_mode, report_stem, "behavioral_economics_report")

if (word_rendered) {
  message("Behavioral-economics journal report complete.")
} else {
  warning("Behavioral-economics journal report markdown generated, but the primary Word file was not refreshed.")
}
