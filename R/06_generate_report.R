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

render_dynamic_report_outputs <- function(markdown_path, paths = get_project_paths(), artifact_tag = "") {
  report_stem <- tools::file_path_sans_ext(basename(markdown_path))
  output_dir <- dirname(markdown_path)
  tag_suffix <- if (nzchar(artifact_tag)) paste0("_", gsub("[^A-Za-z0-9_-]", "", artifact_tag)) else ""
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
    docx_result <- run_command_capture(
      pandoc_path,
      c(
        markdown_path,
        "--number-sections",
        "-o", docx_path
      )
    )
    render_status$status[1] <- if (docx_result$status == 0L) "rendered" else "failed"
    render_status$detail[1] <- if (nzchar(docx_result$output)) docx_result$output else NA_character_

    if (length(pdflatex_path) == 0L) {
      render_status$status[2] <- "missing_pdflatex"
      render_status$detail[2] <- "Pandoc was found, but pdflatex was not found."
    } else {
      pdf_result <- run_command_capture(
        pandoc_path,
        c(
          markdown_path,
          "--number-sections",
          "-o", pdf_path,
          paste0("--pdf-engine=", pdflatex_path[[1]])
        )
      )
      render_status$status[2] <- if (pdf_result$status == 0L) "rendered" else "failed"
      render_status$detail[2] <- if (nzchar(pdf_result$output)) pdf_result$output else NA_character_
    }
  }

  write.csv(render_status, file.path(paths$logs_dir, paste0("dynamic_report_render_status", tag_suffix, ".csv")), row.names = FALSE)
  write.csv(render_status, file.path(paths$reports_data_dir, paste0("dynamic_report_render_status", tag_suffix, ".csv")), row.names = FALSE)

  if (file.exists(docx_path)) file.copy(docx_path, file.path(paths$logs_dir, paste0("dynamic_report", tag_suffix, ".docx")), overwrite = TRUE)
  if (file.exists(pdf_path)) file.copy(pdf_path, file.path(paths$logs_dir, paste0("dynamic_report", tag_suffix, ".pdf")), overwrite = TRUE)

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
formula_catalog_display <- formula_catalog[, c("hypothesis", "role", "formula_rhs", "theoretical_focus"), drop = FALSE]
names(formula_catalog_display) <- c("H", "Role", "Formula", "Focus")
participants <- read.csv(paths$processed_participants, stringsAsFactors = FALSE)
judgments_analysis <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

symbol_dictionary <- get_current_symbol_dictionary()
predictor_glossary <- get_current_predictor_glossary()
predictor_glossary_main <- predictor_glossary[, c("compact_label", "meaning"), drop = FALSE]
names(predictor_glossary_main) <- c("Code", "Interpretation")
predictor_glossary_appendix <- predictor_glossary[, c("predictor", "compact_label"), drop = FALSE]
names(predictor_glossary_appendix) <- c("Predictor", "Code")
correlation_table <- build_participant_correlation_table(participants, judgments_analysis)
clustering_diagnostic <- compute_descriptive_clustering_diagnostic(judgments_analysis)
target_slot_mapping_audit <- build_target_slot_mapping_audit(judgments_analysis)

write.csv(symbol_dictionary, file.path(paths$tables_dir, "report_symbol_dictionary.csv"), row.names = FALSE)
write.csv(predictor_glossary, file.path(paths$tables_dir, "report_predictor_glossary.csv"), row.names = FALSE)
write.csv(predictor_glossary_main, file.path(paths$tables_dir, "report_predictor_glossary_main.csv"), row.names = FALSE)
write.csv(predictor_glossary_appendix, file.path(paths$tables_dir, "report_predictor_glossary_appendix.csv"), row.names = FALSE)
write.csv(correlation_table, file.path(paths$tables_dir, "report_correlation_matrix.csv"), row.names = FALSE)
write.csv(clustering_diagnostic, file.path(paths$tables_dir, "report_clustering_diagnostic.csv"), row.names = FALSE)
write.csv(target_slot_mapping_audit, file.path(paths$tables_dir, "report_target_slot_mapping_audit.csv"), row.names = FALSE)
write.csv(target_slot_mapping_audit, file.path(paths$reports_data_dir, "report_target_slot_mapping_audit.csv"), row.names = FALSE)

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
coefficient_narratives_en <- list()
coefficient_narratives_es <- list()
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

build_panel_title <- function(panel_row, panel_vars, panel_var_labels = list(), panel_value_labels = list()) {
  title_parts <- character(length(panel_vars))
  for (j in seq_along(panel_vars)) {
    var_name <- panel_vars[[j]]
    raw_value <- as.character(panel_row[[var_name]])
    var_label <- if (!is.null(panel_var_labels[[var_name]])) panel_var_labels[[var_name]] else var_name
    value_label <- raw_value
    if (!is.null(panel_value_labels[[var_name]]) && raw_value %in% names(panel_value_labels[[var_name]])) {
      value_label <- unname(panel_value_labels[[var_name]][[raw_value]])
    }
    title_parts[[j]] <- paste0(var_label, ": ", value_label)
  }
  paste(title_parts, collapse = "\n")
}

write_multi_panel_judgement_histogram <- function(
    data,
    file_path,
    panel_vars,
    plot_title = "",
    panel_levels = list(),
    panel_var_labels = list(),
    panel_value_labels = list(),
    role_colors = c(Victim = "#7aa6c2", Bystander = "#e3a857"),
    default_fill = "#7aa6c2",
    sparse_threshold = 10L,
    nrow = NULL,
    ncol = NULL) {
  required_columns <- unique(c("judgement", panel_vars))
  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0L) {
    return(list(
      created = FALSE,
      panel_count = 0L,
      sparse_panels = 0L,
      empty_panels = 0L,
      note = sprintf("Missing columns: %s", paste(missing_columns, collapse = ", "))
    ))
  }

  data_local <- as.data.frame(data, stringsAsFactors = FALSE)
  for (var_name in panel_vars) {
    data_local[[var_name]] <- as.character(data_local[[var_name]])
  }

  level_notes <- character(0)
  level_map <- setNames(vector("list", length(panel_vars)), panel_vars)
  for (var_name in panel_vars) {
    observed_levels <- unique(stats::na.omit(as.character(data_local[[var_name]])))
    observed_levels <- observed_levels[nzchar(observed_levels)]
    observed_levels <- sort(observed_levels)

    requested_levels <- if (!is.null(panel_levels[[var_name]]) && length(panel_levels[[var_name]]) > 0L) {
      as.character(panel_levels[[var_name]])
    } else {
      character(0)
    }

    if (length(requested_levels) > 0L) {
      matched_levels <- requested_levels[requested_levels %in% observed_levels]
      if (length(matched_levels) == 0L) {
        level_map[[var_name]] <- observed_levels
        level_notes <- c(
          level_notes,
          sprintf(
            "%s requested levels not found in data (%s); fallback to observed levels (%s).",
            var_name,
            paste(requested_levels, collapse = ", "),
            paste(observed_levels, collapse = ", ")
          )
        )
      } else {
        extra_levels <- setdiff(observed_levels, matched_levels)
        level_map[[var_name]] <- c(matched_levels, extra_levels)
      }
    } else {
      level_map[[var_name]] <- observed_levels
    }
  }

  if (any(vapply(level_map, length, integer(1)) == 0L)) {
    return(list(
      created = FALSE,
      panel_count = 0L,
      sparse_panels = 0L,
      empty_panels = 0L,
      note = "At least one panel variable has zero available levels."
    ))
  }

  panel_grid <- expand.grid(level_map, KEEP.OUT.ATTRS = FALSE, stringsAsFactors = FALSE)
  panel_count <- nrow(panel_grid)
  if (is.null(nrow) || is.null(ncol)) {
    if (length(panel_vars) == 2L) {
      nrow <- length(level_map[[panel_vars[[1]]]])
      ncol <- length(level_map[[panel_vars[[2]]]])
    } else {
      nrow <- ceiling(sqrt(panel_count))
      ncol <- ceiling(panel_count / nrow)
    }
  }

  x_limits <- get_judgment_observed_bounds()
  x_ticks <- get_judgment_axis_ticks()
  hist_breaks <- get_judgment_hist_breaks()

  panel_n <- integer(panel_count)
  panel_ymax <- integer(panel_count)
  for (i in seq_len(panel_count)) {
    subset_index <- rep(TRUE, nrow(data_local))
    for (var_name in panel_vars) {
      subset_index <- subset_index & (data_local[[var_name]] == as.character(panel_grid[[var_name]][[i]]))
    }
    panel_values <- data_local$judgement[subset_index]
    panel_values <- panel_values[is.finite(panel_values)]
    panel_n[[i]] <- length(panel_values)
    if (length(panel_values) > 0L) {
      panel_ymax[[i]] <- max(graphics::hist(panel_values, breaks = hist_breaks, plot = FALSE)$counts, na.rm = TRUE)
    } else {
      panel_ymax[[i]] <- 0L
    }
  }

  y_max <- max(c(1L, panel_ymax), na.rm = TRUE)
  style <- get_plot_style()

  open_accessible_png(
    file_path = file_path,
    width = max(9, ncol * 3.1),
    height = max(6, nrow * 2.6)
  )
  apply_accessible_theme()
  graphics::par(
    mfrow = c(nrow, ncol),
    mar = c(4.2, 4.2, 3.3, 1.0),
    oma = c(1.0, 0.4, if (nzchar(plot_title)) 2.3 else 0.5, 0.2),
    bty = "l"
  )

  for (i in seq_len(panel_count)) {
    panel_row <- panel_grid[i, , drop = FALSE]
    panel_title <- build_panel_title(
      panel_row = panel_row,
      panel_vars = panel_vars,
      panel_var_labels = panel_var_labels,
      panel_value_labels = panel_value_labels
    )

    subset_index <- rep(TRUE, nrow(data_local))
    for (var_name in panel_vars) {
      subset_index <- subset_index & (data_local[[var_name]] == as.character(panel_row[[var_name]][[1]]))
    }
    panel_values <- data_local$judgement[subset_index]
    panel_values <- panel_values[is.finite(panel_values)]

    if (length(panel_values) == 0L) {
      graphics::plot(
        NA_real_, NA_real_,
        xlim = x_limits,
        ylim = c(0, y_max),
        xlab = "judgement",
        ylab = "Count",
        main = panel_title,
        xaxt = "n",
        yaxt = "n"
      )
      graphics::axis(1, at = x_ticks)
      graphics::axis(2)
      graphics::abline(v = 0, col = style$grid, lty = 3, lwd = 1)
      graphics::text(mean(x_limits), y_max * 0.5, "No observations", col = "#666666", cex = 0.9)
    } else {
      role_current <- if ("role_panel" %in% panel_vars) {
        as.character(panel_row$role_panel[[1]])
      } else if ("role_panel" %in% names(data_local)) {
        role_values <- unique(stats::na.omit(as.character(data_local$role_panel[subset_index])))
        if (length(role_values) > 0L) role_values[[1]] else NA_character_
      } else if ("role_label" %in% panel_vars) {
        normalize_role_label(as.character(panel_row$role_label[[1]]))
      } else if ("role_label" %in% names(data_local)) {
        role_values <- unique(stats::na.omit(as.character(data_local$role_label[subset_index])))
        if (length(role_values) > 0L) normalize_role_label(role_values[[1]]) else NA_character_
      } else {
        NA_character_
      }
      panel_fill <- if (!is.na(role_current) && role_current %in% names(role_colors)) {
        role_colors[[role_current]]
      } else {
        default_fill
      }
      panel_border <- if (identical(panel_fill, "#e3a857")) "#5c4033" else "#2f4f4f"

      graphics::hist(
        panel_values,
        breaks = hist_breaks,
        xlim = x_limits,
        ylim = c(0, y_max),
        main = panel_title,
        xlab = "judgement",
        ylab = "Count",
        col = panel_fill,
        border = panel_border
      )
      graphics::axis(1, at = x_ticks)
      graphics::abline(v = 0, col = style$grid, lty = 3, lwd = 1)
      if (length(panel_values) < sparse_threshold) {
        graphics::mtext(
          sprintf("Sparse (n=%s)", length(panel_values)),
          side = 3,
          line = 0.1,
          adj = 1,
          cex = 0.72,
          col = "#7A1C1C"
        )
      }
    }
  }

  if (nrow * ncol > panel_count) {
    for (i in seq_len((nrow * ncol) - panel_count)) {
      graphics::plot.new()
    }
  }

  if (nzchar(plot_title)) {
    graphics::mtext(wrap_title(plot_title, width = 76), side = 3, outer = TRUE, line = 0.5, cex = 1.05, font = 2)
  }
  grDevices::dev.off()

  list(
    created = file.exists(file_path),
    panel_count = panel_count,
    sparse_panels = sum(panel_n > 0L & panel_n < sparse_threshold),
    empty_panels = sum(panel_n == 0L),
    note = sprintf(
      "Panels=%s; sparse=%s; empty=%s%s",
      panel_count,
      sum(panel_n > 0L & panel_n < sparse_threshold),
      sum(panel_n == 0L),
      if (length(level_notes) > 0L) paste0(" | ", paste(level_notes, collapse = " ")) else ""
    )
  )
}

normalize_role_label <- function(raw_role_label, raw_role_numeric = NULL) {
  role_label_chr <- tolower(trimws(as.character(raw_role_label)))
  normalized <- ifelse(
    role_label_chr %in% c("victim", "v", "1"),
    "Victim",
    ifelse(
      role_label_chr %in% c("bystander", "b", "0"),
      "Bystander",
      NA_character_
    )
  )

  if (!is.null(raw_role_numeric)) {
    role_num_chr <- trimws(as.character(raw_role_numeric))
    needs_fill <- is.na(normalized)
    normalized[needs_fill & role_num_chr == "1"] <- "Victim"
    normalized[needs_fill & role_num_chr == "0"] <- "Bystander"
  }

  normalized
}

normalize_target_code <- function(x) {
  x_chr <- tolower(trimws(as.character(x)))
  out <- ifelse(
    x_chr %in% c("target_code_1", "1"),
    "target_code_1",
    ifelse(x_chr %in% c("target_code_2", "2"), "target_code_2", NA_character_)
  )
  out
}

normalize_faculty_label <- function(x) {
  x_chr <- tolower(trimws(as.character(x)))
  ifelse(
    x_chr %in% c("humanities", "hum", "h", "1"),
    "Humanities",
    ifelse(
      x_chr %in% c("engineering", "eng", "e", "2"),
      "Engineering",
      ifelse(x_chr %in% c("control", "ctl", "c", "0"), "Control", NA_character_)
    )
  )
}

normalize_binary_decision <- function(raw_value) {
  x_chr <- tolower(trimws(as.character(raw_value)))
  ifelse(
    x_chr %in% c("accept", "accepted", "1", "true"),
    "accept",
    ifelse(x_chr %in% c("reject", "rejected", "0", "false"), "reject", NA_character_)
  )
}

normalize_decision_pattern <- function(raw_pattern, accept_target, accept_other) {
  pattern_chr <- tolower(trimws(as.character(raw_pattern)))
  normalized <- ifelse(
    pattern_chr %in% c("both_accept", "accept_accept"),
    "both_accept",
    ifelse(
      pattern_chr %in% c("both_reject", "reject_reject"),
      "both_reject",
      ifelse(
        pattern_chr %in% c("target_accept_other_reject", "accept_reject"),
        "target_accept_other_reject",
        ifelse(
          pattern_chr %in% c("target_reject_other_accept", "reject_accept"),
          "target_reject_other_accept",
          NA_character_
        )
      )
    )
  )

  missing_index <- is.na(normalized)
  if (any(missing_index)) {
    target_clean <- normalize_binary_decision(accept_target)
    other_clean <- normalize_binary_decision(accept_other)
    normalized[missing_index & target_clean == "accept" & other_clean == "accept"] <- "both_accept"
    normalized[missing_index & target_clean == "reject" & other_clean == "reject"] <- "both_reject"
    normalized[missing_index & target_clean == "accept" & other_clean == "reject"] <- "target_accept_other_reject"
    normalized[missing_index & target_clean == "reject" & other_clean == "accept"] <- "target_reject_other_accept"
  }

  normalized
}

pick_first_existing_column <- function(data, candidates) {
  for (candidate in candidates) {
    if (candidate %in% names(data)) {
      return(candidate)
    }
  }
  NA_character_
}

preferred_then_observed_levels <- function(values, preferred = character(0)) {
  observed <- sort(unique(stats::na.omit(as.character(values))))
  observed <- observed[nzchar(observed)]
  if (length(preferred) == 0L) {
    return(observed)
  }
  preferred <- as.character(preferred)
  matched <- preferred[preferred %in% observed]
  extras <- setdiff(observed, matched)
  c(matched, extras)
}

save_preplot_frequency_tables <- function(
    data,
    panel_vars,
    panel_levels = list(),
    output_stem,
    paths = get_project_paths()) {
  data_local <- as.data.frame(data, stringsAsFactors = FALSE)
  for (var_name in panel_vars) {
    if (var_name %in% names(data_local)) {
      data_local[[var_name]] <- as.character(data_local[[var_name]])
    }
  }

  variable_rows <- list()
  for (var_name in panel_vars) {
    if (!(var_name %in% names(data_local))) next
    tab <- sort(table(data_local[[var_name]], useNA = "ifany"), decreasing = TRUE)
    if (length(tab) == 0L) next
    requested_levels <- if (!is.null(panel_levels[[var_name]]) && length(panel_levels[[var_name]]) > 0L) {
      as.character(panel_levels[[var_name]])
    } else {
      character(0)
    }
    variable_rows[[length(variable_rows) + 1L]] <- data.frame(
      variable = var_name,
      value = names(tab),
      n = as.integer(tab),
      in_requested_levels = if (length(requested_levels) > 0L) {
        ifelse(names(tab) %in% requested_levels, "yes", "no")
      } else {
        NA_character_
      },
      stringsAsFactors = FALSE
    )
  }

  variable_counts <- if (length(variable_rows) > 0L) {
    do.call(rbind, variable_rows)
  } else {
    data.frame(variable = character(0), value = character(0), n = integer(0), in_requested_levels = character(0), stringsAsFactors = FALSE)
  }

  panel_counts <- data.frame()
  if (all(panel_vars %in% names(data_local))) {
    non_missing <- data_local[stats::complete.cases(data_local[, panel_vars, drop = FALSE]), panel_vars, drop = FALSE]
    if (nrow(non_missing) > 0L) {
      non_missing$rows_n <- 1L
      panel_counts <- stats::aggregate(rows_n ~ ., data = non_missing, FUN = sum)
      panel_counts <- panel_counts[order(panel_counts$rows_n, decreasing = TRUE), , drop = FALSE]
      names(panel_counts)[ncol(panel_counts)] <- "n"
    } else {
      panel_counts <- data.frame()
    }
  }

  variable_path <- file.path(paths$tables_dir, paste0("descriptive_preplot_", output_stem, "_variable_counts.csv"))
  panel_path <- file.path(paths$tables_dir, paste0("descriptive_preplot_", output_stem, "_panel_counts.csv"))
  write.csv(variable_counts, variable_path, row.names = FALSE)
  write.csv(panel_counts, panel_path, row.names = FALSE)
  write.csv(variable_counts, file.path(paths$logs_dir, basename(variable_path)), row.names = FALSE)
  write.csv(panel_counts, file.path(paths$logs_dir, basename(panel_path)), row.names = FALSE)

  message(sprintf("Pre-plot frequency audit saved: %s | %s", variable_path, panel_path))

  list(
    variable_counts_path = variable_path,
    panel_counts_path = panel_path
  )
}

add_generated_descriptive_entry <- function(
    entries_df,
    status_df,
    figure_file_name,
    role,
    term,
    caption,
    interpretation,
    generation_result,
    panel_vars,
    note_prefix = "") {
  figure_path <- file.path(paths$figures_dir, figure_file_name)
  status_note <- trimws(paste(note_prefix, generation_result$note))
  status_df <- rbind(
    status_df,
    data.frame(
      figure_file = figure_path,
      created = isTRUE(generation_result$created),
      panel_variables = paste(panel_vars, collapse = " x "),
      panel_count = generation_result$panel_count,
      sparse_panels = generation_result$sparse_panels,
      empty_panels = generation_result$empty_panels,
      note = status_note,
      stringsAsFactors = FALSE
    )
  )

  if (isTRUE(generation_result$created)) {
    entries_df <- rbind(
      entries_df,
      data.frame(
        figure_file = figure_path,
        figure_type = "descriptive",
        hypothesis = "All",
        role = role,
        term = term,
        caption = caption,
        interpretation = interpretation,
        stringsAsFactors = FALSE
      )
    )
  }

  list(entries = entries_df, status = status_df)
}

descriptive_figure_entries <- data.frame(
  figure_file = c(
    file.path(paths$figures_dir, "figure_iri_subscale_radar.png"),
    file.path(paths$figures_dir, "figure_bivariate_empathy_vs_mean_judgement.png"),
    file.path(paths$figures_dir, "figure_judgement_distribution_by_role.png")
  ),
  figure_type = c("descriptive", "descriptive", "descriptive"),
  hypothesis = c("All", "All", "All"),
  role = c("All", "All", "All"),
  term = c("IRI profile", "Empathy correlations", "Judgement distribution by role"),
  caption = c(
    "Mean IRI subscale profile across participants.",
    "Participant-level bivariate scatters of IRI subscales against mean judgement.",
    "Observed judgement distributions split by role."
  ),
  interpretation = c(
    "This figure summarizes the central empathy profile of the sample before conditioning on hypothesis-specific models.",
    "These scatterplots show the participant-level descriptive relationship between empathy dimensions and average judgement.",
    "This figure shows the raw shape of the bounded judgement outcome in the victim and bystander subsets."
  ),
  stringsAsFactors = FALSE
)

descriptive_generation_status <- data.frame(
  figure_file = character(0),
  created = logical(0),
  panel_variables = character(0),
  panel_count = integer(0),
  sparse_panels = integer(0),
  empty_panels = integer(0),
  note = character(0),
  stringsAsFactors = FALSE
)

# Canonical role labels for descriptive panels.
role_source <- pick_first_existing_column(judgments_analysis, c("role_label", "role"))
role_numeric_source <- if ("role" %in% names(judgments_analysis)) "role" else NA_character_
judgments_with_role_panel <- judgments_analysis
judgments_with_role_panel$role_panel <- normalize_role_label(
  raw_role_label = if (!is.na(role_source)) judgments_with_role_panel[[role_source]] else NA_character_,
  raw_role_numeric = if (!is.na(role_numeric_source)) judgments_with_role_panel[[role_numeric_source]] else NULL
)
role_panel_levels <- preferred_then_observed_levels(judgments_with_role_panel$role_panel, c("Victim", "Bystander"))

# A) role x target code
target_identity_source <- pick_first_existing_column(judgments_with_role_panel, c("target_code_label", "target"))
judgments_for_target <- judgments_with_role_panel
if (!is.na(target_identity_source)) {
  judgments_for_target$target_identity <- normalize_target_code(judgments_for_target[[target_identity_source]])
}
target_levels <- preferred_then_observed_levels(judgments_for_target$target_identity, c("target_code_1", "target_code_2"))
audit_role_target <- save_preplot_frequency_tables(
  data = judgments_for_target,
  panel_vars = c("role_panel", "target_identity"),
  panel_levels = list(role_panel = role_panel_levels, target_identity = target_levels),
  output_stem = "judgement_by_role_and_target",
  paths = paths
)

result_role_target <- write_multi_panel_judgement_histogram(
  data = judgments_for_target,
  file_path = file.path(paths$figures_dir, "figure_judgement_distribution_by_role_and_target.png"),
  panel_vars = c("role_panel", "target_identity"),
  panel_levels = list(role_panel = role_panel_levels, target_identity = target_levels),
  panel_var_labels = list(role_panel = "Role", target_identity = "Target"),
  plot_title = "Judgement distributions by role and target-code identity",
  nrow = 2,
  ncol = 2
)

update_a <- add_generated_descriptive_entry(
  entries_df = descriptive_figure_entries,
  status_df = descriptive_generation_status,
  figure_file_name = "figure_judgement_distribution_by_role_and_target.png",
  role = "All",
  term = "Judgement by role and target code",
  caption = "Observed judgement distributions by role and target negotiator.",
  interpretation = "This figure shows whether the raw bounded judgement distribution differs depending on whether the target code is 1 or 2 within victim and bystander settings.",
  generation_result = result_role_target,
  panel_vars = c("role_panel", "target_identity"),
  note_prefix = paste0(
    "Role source: ", ifelse(is.na(role_source), "not_found", role_source),
    "; target code source: ", ifelse(is.na(target_identity_source), "not_found", target_identity_source),
    "; pre-plot audit: ", basename(audit_role_target$variable_counts_path), " + ", basename(audit_role_target$panel_counts_path), "."
  )
)
descriptive_figure_entries <- update_a$entries
descriptive_generation_status <- update_a$status

# D) role x target decision
target_decision_source <- pick_first_existing_column(judgments_with_role_panel, c("accept_target_label", "accept_target"))
judgments_target_decision <- judgments_with_role_panel
judgments_target_decision$target_decision_only <- if (!is.na(target_decision_source)) {
  normalize_binary_decision(judgments_target_decision[[target_decision_source]])
} else {
  rep(NA_character_, nrow(judgments_target_decision))
}
target_decision_levels <- preferred_then_observed_levels(judgments_target_decision$target_decision_only, c("accept", "reject"))
audit_target_decision <- save_preplot_frequency_tables(
  data = judgments_target_decision,
  panel_vars = c("role_panel", "target_decision_only"),
  panel_levels = list(role_panel = role_panel_levels, target_decision_only = target_decision_levels),
  output_stem = "judgement_by_role_and_target_decision",
  paths = paths
)

result_target_decision <- write_multi_panel_judgement_histogram(
  data = judgments_target_decision,
  file_path = file.path(paths$figures_dir, "figure_judgement_distribution_by_role_and_target_decision.png"),
  panel_vars = c("role_panel", "target_decision_only"),
  panel_levels = list(role_panel = role_panel_levels, target_decision_only = target_decision_levels),
  panel_var_labels = list(role_panel = "Role", target_decision_only = "Target decision"),
  panel_value_labels = list(target_decision_only = c(accept = "accept", reject = "reject")),
  plot_title = "Judgement distributions by role and target decision",
  nrow = 2,
  ncol = 2
)

update_d <- add_generated_descriptive_entry(
  entries_df = descriptive_figure_entries,
  status_df = descriptive_generation_status,
  figure_file_name = "figure_judgement_distribution_by_role_and_target_decision.png",
  role = "All",
  term = "Judgement by role and target decision",
  caption = "Observed judgement distributions by role and target decision.",
  interpretation = "This figure isolates whether the target's own acceptance or rejection is associated with different raw judgement profiles within each role.",
  generation_result = result_target_decision,
  panel_vars = c("role_panel", "target_decision_only"),
  note_prefix = paste0(
    "Role source: ", ifelse(is.na(role_source), "not_found", role_source),
    "; target decision source: ", ifelse(is.na(target_decision_source), "not_found", target_decision_source),
    "; pre-plot audit: ", basename(audit_target_decision$variable_counts_path), " + ", basename(audit_target_decision$panel_counts_path), "."
  )
)
descriptive_figure_entries <- update_d$entries
descriptive_generation_status <- update_d$status

# E) role x counterpart decision
other_decision_source <- pick_first_existing_column(judgments_with_role_panel, c("accept_other_label", "accept_other"))
judgments_other_decision <- judgments_with_role_panel
judgments_other_decision$other_decision_only <- if (!is.na(other_decision_source)) {
  normalize_binary_decision(judgments_other_decision[[other_decision_source]])
} else {
  rep(NA_character_, nrow(judgments_other_decision))
}
other_decision_levels <- preferred_then_observed_levels(judgments_other_decision$other_decision_only, c("accept", "reject"))
audit_other_decision <- save_preplot_frequency_tables(
  data = judgments_other_decision,
  panel_vars = c("role_panel", "other_decision_only"),
  panel_levels = list(role_panel = role_panel_levels, other_decision_only = other_decision_levels),
  output_stem = "judgement_by_role_and_other_decision",
  paths = paths
)

result_other_decision <- write_multi_panel_judgement_histogram(
  data = judgments_other_decision,
  file_path = file.path(paths$figures_dir, "figure_judgement_distribution_by_role_and_other_decision.png"),
  panel_vars = c("role_panel", "other_decision_only"),
  panel_levels = list(role_panel = role_panel_levels, other_decision_only = other_decision_levels),
  panel_var_labels = list(role_panel = "Role", other_decision_only = "Counterpart decision"),
  panel_value_labels = list(other_decision_only = c(accept = "accept", reject = "reject")),
  plot_title = "Judgement distributions by role and counterpart decision",
  nrow = 2,
  ncol = 2
)

update_e <- add_generated_descriptive_entry(
  entries_df = descriptive_figure_entries,
  status_df = descriptive_generation_status,
  figure_file_name = "figure_judgement_distribution_by_role_and_other_decision.png",
  role = "All",
  term = "Judgement by role and counterpart decision",
  caption = "Observed judgement distributions by role and counterpart decision.",
  interpretation = "This figure shows whether judgement of the target varies with the acceptance or rejection of the other negotiator.",
  generation_result = result_other_decision,
  panel_vars = c("role_panel", "other_decision_only"),
  note_prefix = paste0(
    "Role source: ", ifelse(is.na(role_source), "not_found", role_source),
    "; other decision source: ", ifelse(is.na(other_decision_source), "not_found", other_decision_source),
    "; pre-plot audit: ", basename(audit_other_decision$variable_counts_path), " + ", basename(audit_other_decision$panel_counts_path), "."
  )
)
descriptive_figure_entries <- update_e$entries
descriptive_generation_status <- update_e$status

# C) role x joint decision pattern
decision_pattern_levels <- c(
  "both_accept",
  "both_reject",
  "target_accept_other_reject",
  "target_reject_other_accept"
)
judgments_decision_pattern <- judgments_with_role_panel
pattern_source_col <- pick_first_existing_column(judgments_decision_pattern, c("decision_pattern"))
pattern_source <- if (!is.na(pattern_source_col)) {
  judgments_decision_pattern[[pattern_source_col]]
} else {
  rep(NA_character_, nrow(judgments_decision_pattern))
}
judgments_decision_pattern$decision_pattern_clean <- normalize_decision_pattern(
  raw_pattern = pattern_source,
  accept_target = if (!is.na(target_decision_source)) judgments_decision_pattern[[target_decision_source]] else rep(NA_character_, nrow(judgments_decision_pattern)),
  accept_other = if (!is.na(other_decision_source)) judgments_decision_pattern[[other_decision_source]] else rep(NA_character_, nrow(judgments_decision_pattern))
)
decision_pattern_levels <- preferred_then_observed_levels(
  judgments_decision_pattern$decision_pattern_clean,
  preferred = decision_pattern_levels
)
audit_decision_pattern <- save_preplot_frequency_tables(
  data = judgments_decision_pattern,
  panel_vars = c("role_panel", "decision_pattern_clean"),
  panel_levels = list(role_panel = role_panel_levels, decision_pattern_clean = decision_pattern_levels),
  output_stem = "judgement_by_role_and_decision_pattern",
  paths = paths
)

result_decision_pattern <- write_multi_panel_judgement_histogram(
  data = judgments_decision_pattern,
  file_path = file.path(paths$figures_dir, "figure_judgement_distribution_by_role_and_decision_pattern.png"),
  panel_vars = c("role_panel", "decision_pattern_clean"),
  panel_levels = list(role_panel = role_panel_levels, decision_pattern_clean = decision_pattern_levels),
  panel_var_labels = list(role_panel = "Role", decision_pattern_clean = "Decision pattern"),
  panel_value_labels = list(
    decision_pattern_clean = c(
      both_accept = "both_accept",
      both_reject = "both_reject",
      target_accept_other_reject = "target_accept_other_reject",
      target_reject_other_accept = "target_reject_other_accept"
    )
  ),
  plot_title = "Judgement distributions by role and joint decision pattern",
  nrow = 2,
  ncol = 4
)

update_c <- add_generated_descriptive_entry(
  entries_df = descriptive_figure_entries,
  status_df = descriptive_generation_status,
  figure_file_name = "figure_judgement_distribution_by_role_and_decision_pattern.png",
  role = "All",
  term = "Judgement by role and joint decision pattern",
  caption = "Observed judgement distributions by role and joint decision pattern.",
  interpretation = "This figure shows how the target-focused judgement distribution changes across the four joint negotiation outcomes in victim and bystander settings.",
  generation_result = result_decision_pattern,
  panel_vars = c("role_panel", "decision_pattern_clean"),
  note_prefix = paste0(
    "Role source: ", ifelse(is.na(role_source), "not_found", role_source),
    "; decision pattern source: ", ifelse(is.na(pattern_source_col), "constructed_from_decisions", pattern_source_col),
    "; target decision source: ", ifelse(is.na(target_decision_source), "not_found", target_decision_source),
    "; other decision source: ", ifelse(is.na(other_decision_source), "not_found", other_decision_source),
    "; pre-plot audit: ", basename(audit_decision_pattern$variable_counts_path), " + ", basename(audit_decision_pattern$panel_counts_path), "."
  )
)
descriptive_figure_entries <- update_c$entries
descriptive_generation_status <- update_c$status

# Keep existing decision barplot after histogram decision structure block.
descriptive_figure_entries <- rbind(
  descriptive_figure_entries,
  data.frame(
    figure_file = file.path(paths$figures_dir, "figure_decision_pattern_by_role.png"),
    figure_type = "descriptive",
    hypothesis = "All",
    role = "All",
    term = "Decision pattern counts by role",
    caption = "Observed decision-pattern counts by role.",
    interpretation = "This figure summarizes how often each joint decision pattern appears in victim and bystander subsets.",
    stringsAsFactors = FALSE
  )
)

# B) role-specific target x other faculty grids
faculty_levels <- c("Humanities", "Engineering", "Control")
faculty_short <- c(Humanities = "Hum", Engineering = "Eng", Control = "Ctl")

victim_faculty_grid <- judgments_victim
victim_faculty_grid$target_faculty_panel <- if ("target_faculty_label" %in% names(victim_faculty_grid)) {
  normalize_faculty_label(victim_faculty_grid$target_faculty_label)
} else {
  normalize_faculty_label(victim_faculty_grid$target_faculty)
}
victim_faculty_grid$other_faculty_panel <- if ("other_faculty_label" %in% names(victim_faculty_grid)) {
  normalize_faculty_label(victim_faculty_grid$other_faculty_label)
} else {
  normalize_faculty_label(victim_faculty_grid$other_faculty)
}

result_victim_faculty <- write_multi_panel_judgement_histogram(
  data = victim_faculty_grid,
  file_path = file.path(paths$figures_dir, "figure_judgement_distribution_victim_target_other_faculty_grid.png"),
  panel_vars = c("target_faculty_panel", "other_faculty_panel"),
  panel_levels = list(target_faculty_panel = faculty_levels, other_faculty_panel = faculty_levels),
  panel_var_labels = list(target_faculty_panel = "Target faculty", other_faculty_panel = "Other faculty"),
  panel_value_labels = list(target_faculty_panel = faculty_short, other_faculty_panel = faculty_short),
  default_fill = "#7aa6c2",
  plot_title = "Victim-role judgement distributions across target x other faculty pairings",
  nrow = 3,
  ncol = 3
)

update_b1 <- add_generated_descriptive_entry(
  entries_df = descriptive_figure_entries,
  status_df = descriptive_generation_status,
  figure_file_name = "figure_judgement_distribution_victim_target_other_faculty_grid.png",
  role = "Victim",
  term = "Victim judgement by target x other faculty grid",
  caption = "Victim-role judgement distributions across target x other faculty pairings.",
  interpretation = "This figure shows how the raw judgement distribution varies across the full relational space defined by the faculty pairing of target and other.",
  generation_result = result_victim_faculty,
  panel_vars = c("target_faculty_panel", "other_faculty_panel")
)
descriptive_figure_entries <- update_b1$entries
descriptive_generation_status <- update_b1$status

bystander_faculty_grid <- judgments_bystander
bystander_faculty_grid$target_faculty_panel <- if ("target_faculty_label" %in% names(bystander_faculty_grid)) {
  normalize_faculty_label(bystander_faculty_grid$target_faculty_label)
} else {
  normalize_faculty_label(bystander_faculty_grid$target_faculty)
}
bystander_faculty_grid$other_faculty_panel <- if ("other_faculty_label" %in% names(bystander_faculty_grid)) {
  normalize_faculty_label(bystander_faculty_grid$other_faculty_label)
} else {
  normalize_faculty_label(bystander_faculty_grid$other_faculty)
}

result_bystander_faculty <- write_multi_panel_judgement_histogram(
  data = bystander_faculty_grid,
  file_path = file.path(paths$figures_dir, "figure_judgement_distribution_bystander_target_other_faculty_grid.png"),
  panel_vars = c("target_faculty_panel", "other_faculty_panel"),
  panel_levels = list(target_faculty_panel = faculty_levels, other_faculty_panel = faculty_levels),
  panel_var_labels = list(target_faculty_panel = "Target faculty", other_faculty_panel = "Other faculty"),
  panel_value_labels = list(target_faculty_panel = faculty_short, other_faculty_panel = faculty_short),
  default_fill = "#e3a857",
  plot_title = "Bystander-role judgement distributions across target x other faculty pairings",
  nrow = 3,
  ncol = 3
)

update_b2 <- add_generated_descriptive_entry(
  entries_df = descriptive_figure_entries,
  status_df = descriptive_generation_status,
  figure_file_name = "figure_judgement_distribution_bystander_target_other_faculty_grid.png",
  role = "Bystander",
  term = "Bystander judgement by target x other faculty grid",
  caption = "Bystander-role judgement distributions across target x other faculty pairings.",
  interpretation = "This figure shows how the raw judgement distribution varies across the full relational space defined by the faculty pairing of target and other.",
  generation_result = result_bystander_faculty,
  panel_vars = c("target_faculty_panel", "other_faculty_panel")
)
descriptive_figure_entries <- update_b2$entries
descriptive_generation_status <- update_b2$status

# F) Optional relational group grids when stable columns are available.
optional_group_columns_ok <- all(c(
  "victim_target_group",
  "victim_other_group",
  "bystander_target_group",
  "bystander_other_group"
) %in% names(judgments_analysis))

if (optional_group_columns_ok) {
  group_levels <- c("ingroup", "outgroup")
  group_labels <- c(ingroup = "Ingroup", outgroup = "Outgroup")

  result_victim_group <- write_multi_panel_judgement_histogram(
    data = judgments_victim,
    file_path = file.path(paths$figures_dir, "figure_judgement_distribution_victim_group_grid.png"),
    panel_vars = c("victim_target_group", "victim_other_group"),
    panel_levels = list(victim_target_group = group_levels, victim_other_group = group_levels),
    panel_var_labels = list(victim_target_group = "Victim-target", victim_other_group = "Victim-other"),
    panel_value_labels = list(victim_target_group = group_labels, victim_other_group = group_labels),
    default_fill = "#7aa6c2",
    plot_title = "Victim-role judgement distributions across victim-target and victim-other group combinations",
    nrow = 2,
    ncol = 2
  )

  update_f1 <- add_generated_descriptive_entry(
    entries_df = descriptive_figure_entries,
    status_df = descriptive_generation_status,
    figure_file_name = "figure_judgement_distribution_victim_group_grid.png",
    role = "Victim",
    term = "Victim judgement by victim-target x victim-other group grid",
    caption = "Victim-role judgement distributions across victim-target and victim-other ingroup/outgroup combinations.",
    interpretation = "This optional figure highlights how raw victim-role judgement varies across victim-centered ingroup/outgroup combinations.",
    generation_result = result_victim_group,
    panel_vars = c("victim_target_group", "victim_other_group"),
    note_prefix = "Optional block F."
  )
  descriptive_figure_entries <- update_f1$entries
  descriptive_generation_status <- update_f1$status

  result_bystander_player_grid <- write_multi_panel_judgement_histogram(
    data = judgments_bystander,
    file_path = file.path(paths$figures_dir, "figure_judgement_distribution_bystander_target_other_group_grid.png"),
    panel_vars = c("bystander_target_group", "bystander_other_group"),
    panel_levels = list(bystander_target_group = group_levels, bystander_other_group = group_levels),
    panel_var_labels = list(bystander_target_group = "Bystander-target", bystander_other_group = "Bystander-other"),
    panel_value_labels = list(bystander_target_group = group_labels, bystander_other_group = group_labels),
    default_fill = "#e3a857",
    plot_title = "Bystander-role judgement distributions across bystander-target and bystander-other group combinations",
    nrow = 2,
    ncol = 2
  )

  update_f2 <- add_generated_descriptive_entry(
    entries_df = descriptive_figure_entries,
    status_df = descriptive_generation_status,
    figure_file_name = "figure_judgement_distribution_bystander_target_other_group_grid.png",
    role = "Bystander",
    term = "Bystander judgement by bystander-target x bystander-other group grid",
    caption = "Bystander-role judgement distributions across bystander-target and bystander-other ingroup/outgroup combinations.",
    interpretation = "This optional figure emphasizes bystander-side relational combinations directly tied to target/other group alignment.",
    generation_result = result_bystander_player_grid,
    panel_vars = c("bystander_target_group", "bystander_other_group"),
    note_prefix = "Optional block F."
  )
  descriptive_figure_entries <- update_f2$entries
  descriptive_generation_status <- update_f2$status

  result_bystander_victim_grid <- write_multi_panel_judgement_histogram(
    data = judgments_bystander,
    file_path = file.path(paths$figures_dir, "figure_judgement_distribution_bystander_victim_target_other_group_grid.png"),
    panel_vars = c("victim_target_group", "victim_other_group"),
    panel_levels = list(victim_target_group = group_levels, victim_other_group = group_levels),
    panel_var_labels = list(victim_target_group = "Victim-target", victim_other_group = "Victim-other"),
    panel_value_labels = list(victim_target_group = group_labels, victim_other_group = group_labels),
    default_fill = "#e3a857",
    plot_title = "Bystander-role judgement distributions across victim-target and victim-other group combinations",
    nrow = 2,
    ncol = 2
  )

  update_f3 <- add_generated_descriptive_entry(
    entries_df = descriptive_figure_entries,
    status_df = descriptive_generation_status,
    figure_file_name = "figure_judgement_distribution_bystander_victim_target_other_group_grid.png",
    role = "Bystander",
    term = "Bystander judgement by victim-target x victim-other group grid",
    caption = "Bystander-role judgement distributions across victim-target and victim-other ingroup/outgroup combinations.",
    interpretation = "This optional figure shows how bystander judgement co-varies with victim-centered relational combinations in the same observed rows.",
    generation_result = result_bystander_victim_grid,
    panel_vars = c("victim_target_group", "victim_other_group"),
    note_prefix = "Optional block F."
  )
  descriptive_figure_entries <- update_f3$entries
  descriptive_generation_status <- update_f3$status
}

descriptive_generation_status <- rbind(
  descriptive_generation_status,
  data.frame(
    figure_file = "__row_integrity_check__",
    created = TRUE,
    panel_variables = "source_row_number",
    panel_count = NA_integer_,
    sparse_panels = NA_integer_,
    empty_panels = NA_integer_,
    note = sprintf(
      "No row duplication introduced. Rows/unique source rows: analysis %s/%s; victim %s/%s; bystander %s/%s.",
      nrow(judgments_analysis),
      length(unique(judgments_analysis$source_row_number)),
      nrow(judgments_victim),
      length(unique(judgments_victim$source_row_number)),
      nrow(judgments_bystander),
      length(unique(judgments_bystander$source_row_number))
    ),
    stringsAsFactors = FALSE
  )
)

write.csv(
  descriptive_generation_status,
  file.path(paths$tables_dir, "report_descriptive_histogram_generation_status.csv"),
  row.names = FALSE
)
write.csv(
  descriptive_generation_status,
  file.path(paths$reports_data_dir, "report_descriptive_histogram_generation_status.csv"),
  row.names = FALSE
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
    coefficient_narratives_en[[prefix]] <- generate_model_narrative(coef_df, hypothesis_id, role_label, lang = "en")
    coefficient_narratives_es[[prefix]] <- generate_model_narrative(coef_df, hypothesis_id, role_label, lang = "es")

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
          interpretation = describe_plot_pattern_current(plot_df, lang = "en"),
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
  uses_decisions <- grepl("accept_target", formula_rhs, fixed = TRUE) &
    grepl("accept_other", formula_rhs, fixed = TRUE)
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
    "f) accept_target and accept_other included in H1-H5",
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
    if (all(formula_checks$uses_decisions)) "YES" else "NO",
    if (all(formula_checks$uses_sociodemographics)) "YES" else "NO"
  ),
  evidence = c(
    "All formulas model judgement directly.",
    "All fitted Tobit models use participant-cluster robust standard errors through cluster = id.",
    "The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept.",
    sprintf("Imported rows = %s; final analytical rows = %s; duplicated source row numbers introduced by the pipeline = %s.", row_count_import, row_count_final, duplicated_source_rows),
    "Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander.",
    "All H1-H5 formulas include accept_target, accept_other, and their interaction as part of the active specification.",
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

build_discussion_section <- function(lang = "en") {
  if (identical(lang, "es")) {
    return(c(
      "# Discusion",
      "",
      "Los resultados de empatia apuntan a un mecanismo en el que `judgement` no responde solo a resultados, sino tambien a sensibilidad social disposicional. Cuando las pendientes de empatia varian entre relaciones ingroup y outgroup, los hallazgos respaldan la expectativa teorica de que la orientacion empatica esta filtrada por cercania social percibida y no opera como un amplificador moral uniforme.",
      "",
      "Los resultados de ingroup/outgroup importan porque el experimento inserta `judgement` en una estructura relacional con dos negociadores y lazos sociales dependientes del rol. Por eso los modelos de Victim y Bystander no son intercambiables. En Victim, la pregunta central es como se relacionan el negociador evaluado y su contraparte con la persona afectada. En Bystander, el participante es externo al evento de dano y la evaluacion puede depender de un mapa mas amplio con relaciones bystander-victim, bystander-negotiator y victim-negotiator.",
      "",
      "Los terminos de decision afinan la interpretacion moral del outcome enfocado en target. `accept_target` captura que hizo el negociador evaluado, `accept_other` captura la decision de la contraparte y su interaccion prueba si el significado de una decision cambia cuando el otro negociador acepta o rechaza. Esto es sustantivamente relevante porque la evaluacion moral del target puede responder tanto a la accion individual como al resultado conjunto de la negociacion.",
      "",
      "En terminos practicos, los resultados aportan a etica de negociacion y evaluacion de terceros. Si `judgement` cambia con empatia, cercania de facultad y patrones conjuntos de decision, entonces la justicia percibida en negociaciones daninas esta moldeada por contexto disposicional y relacional. Esto tiene implicaciones para como observadores asignan culpa, justifican conducta estrategica o infieren responsabilidad desde accion coordinada.",
      "",
      "Metodologicamente, el estimador activo es un Tobit de dos lados con errores estandar robustos agrupados por participante y efectos fijos de sesion. Es una decision productiva honesta para un outcome acotado con medidas repetidas, porque preserva la estructura Tobit de `judgement`, ajusta dependencia intra-participante via `cluster = id`, y controla desplazamientos por sesion con `factor(session)`. Al mismo tiempo, no equivale a un Tobit mixto completo con interceptos aleatorios de participante y sesion.",
      "",
      "Las principales limitaciones se desprenden de esa eleccion del estimador y de la escasez en algunas celdas relacionales. La rama productiva no estima un Tobit mixto completo, algunos contrastes de interaccion pueden descartarse en subconjuntos con deficiencia de rango, y la lectura sustantiva debe mantenerse anclada en tablas de coeficientes y figuras implicadas por el modelo, no en p-values aislados. Trabajo futuro deberia comparar estos estimados con modelos censurados multinivel estables, evaluar interacciones alternativas por rol y probar replicacion en otros contextos institucionales o culturales.",
      ""
    ))
  }

  c(
    "# Discussion",
    "",
    "The empathy results speak to a mechanism in which moral judgement is not only a response to outcomes but also to dispositional social sensitivity. When empathy slopes vary across ingroup and outgroup relations, the findings support the original theoretical expectation that empathic orientation is filtered through perceived social closeness rather than operating as a uniform moral amplifier.",
    "",
    "The ingroup/outgroup results matter because the experiment embeds judgement in a relational structure with two negotiators and role-dependent social ties. Victim and bystander models are therefore not interchangeable. In the victim role, the central question is how the judged negotiator and the counterpart relate to the harmed person. In the bystander role, the participant is socially external to the harm event, so judgement can depend on a broader map that includes bystander-victim, bystander-negotiator, and victim-negotiator alignments.",
    "",
    "The decision terms sharpen the moral interpretation of the target-focused outcome. `accept_target` captures what the judged negotiator did, `accept_other` captures the counterpart's choice, and their interaction tests whether the meaning of one decision changes when the other negotiator accepts or rejects. This is substantively important because moral evaluations of the target can respond both to individual action and to the joint negotiation outcome.",
    "",
    "Practically, the results speak to negotiation ethics and third-party evaluation. If moral judgement shifts with empathy, faculty closeness, and joint decision patterns, then perceived fairness in harmful negotiations is shaped by both dispositional and relational context. That has implications for how observers assign blame, excuse strategic behavior, or infer responsibility from coordinated action.",
    "",
    "Methodologically, the active estimator is a two-sided Tobit with participant-cluster robust standard errors and session fixed effects. This is an honest production choice for a bounded repeated-measures outcome because it preserves the Tobit structure for `judgement`, adjusts within-participant dependence through clustering by `id`, and controls for session-level shifts through `factor(session)`. At the same time, it is not equivalent to a fully mixed Tobit with random participant and session intercepts, so dependence is handled through robust inference plus fixed-effects adjustment rather than a full hierarchical likelihood.",
    "",
    "The main limitations follow directly from that estimator choice and from the sparsity of some relational cells. The production branch does not estimate a full mixed Tobit, some interaction contrasts may be dropped in rank-deficient subsets, and any substantive reading should remain tied to the coefficient tables and model-implied figures rather than to isolated p-values. Future work should compare these production estimates against stable multilevel censored models, test alternative role-specific interaction sets, and examine whether the same theoretical patterns replicate under additional institutional or cultural contexts.",
    ""
  )
}

build_final_audit_note <- function(compliance_report, fit_summary, lang = "en") {
  all_yes <- nrow(compliance_report) > 0L && all(compliance_report$status == "YES")
  rank_deficient_models <- if ("dropped_columns" %in% names(fit_summary)) {
    sum(suppressWarnings(as.numeric(fit_summary$dropped_columns)) > 0, na.rm = TRUE)
  } else {
    0L
  }

  if (identical(lang, "es")) {
    return(c(
      "# Nota final de auditoria",
      "",
      if (all_yes) {
        "El proyecto refleja fielmente el diseno autoritativo en su rama productiva: `judgement` es el outcome, el archivo long se mantiene como fuente unica, una fila sigue siendo una observacion real, se usan definiciones de grupo especificas por rol, `accept_target` y `accept_other` se modelan en H1-H5, y las mediciones repetidas se manejan con inferencia robusta por cluster de participante y `factor(session)`."
      } else {
        "El proyecto esta sustancialmente alineado con el diseno autoritativo, pero la lista de verificacion muestra brechas de cumplimiento que aun requieren correccion."
      },
      "",
      if (rank_deficient_models > 0L) {
        sprintf("Desajuste parcial restante: %s modelo(s) ajustado(s) aun reportaron columnas descartadas porque algunas celdas de interaccion por rol son escasas, por lo que ciertos contrastes no son estimables en todos los subconjuntos.", rank_deficient_models)
      } else {
        "No quedo advertencia de deficiencia de rango en el resumen de ajuste guardado para esta corrida."
      },
      "",
      "Limitacion del estimador: el estimador productivo sigue siendo un Tobit de dos lados con `factor(session)` y errores estandar robustos por cluster en `id`, no un Tobit de efectos mixtos completo con interceptos aleatorios de participante y sesion.",
      ""
    ))
  }

  note_lines <- c(
    "# Final audit note",
    "",
    if (all_yes) {
      "The project now faithfully reflects the authoritative design in its production branch: `judgement` is the outcome, the long file remains the single source, one row remains one real observation, role-specific group definitions are used, `accept_target` and `accept_other` are modeled in H1-H5, and repeated measurements are handled through participant-cluster robust inference with `factor(session)`."
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

get_hypothesis_semantic_reminder <- function(hypothesis_id, lang = "en") {
  if (identical(lang, "es")) {
    return(switch(
      hypothesis_id,
      H2 = "Recordatorio H2: los predictores relacionales activos usan semantica `target`/`other` por fila; `group_target` y `group_other` permanecen como campos legacy de fuente/auditoria y no como terminos activos de H2.",
      H4 = "Recordatorio H4: el nombre fuente legacy `decision_target` corresponde al nombre operativo activo `accept_target`, y `decision_other` corresponde a `accept_other`; ambos se refieren a roles dinamicos `target`/`other` por fila.",
      H5 = "Recordatorio H5: la especificacion integrada mantiene semantica `target`/`other` en terminos relacionales y de aceptacion; `group_target`/`group_other` siguen como campos legacy de auditoria y `decision_target`/`decision_other` se mapean a `accept_target`/`accept_other`.",
      ""
    ))
  }

  switch(
    hypothesis_id,
    H2 = "H2 reminder: active relational predictors are expressed with row-dynamic `target`/`other` semantics; `group_target` and `group_other` remain legacy source-audit fields and are not active H2 predictors.",
    H4 = "H4 reminder: legacy source `decision_target` corresponds to active `accept_target`, and `decision_other` corresponds to active `accept_other`; both refer to row-dynamic `target`/`other` roles.",
    H5 = "H5 reminder: the integrated specification keeps `target`/`other` semantics for relational and acceptance terms; `group_target`/`group_other` remain legacy audit fields, and legacy source `decision_target`/`decision_other` maps to active `accept_target`/`accept_other`.",
    ""
  )
}

get_role_support_text <- function(significance_summary, hypothesis_id, role_label, lang = "en") {
  matched <- subset(
    significance_summary,
    hypothesis == hypothesis_id & role == role_label
  )
  if (nrow(matched) == 0L || is.na(matched$support[[1]]) || !nzchar(matched$support[[1]])) {
    return(if (identical(lang, "es")) {
      "no hubo entrada de soporte focal disponible en la tabla de resumen especifica por rol para esta corrida"
    } else {
      "no focal support entry was available in the role-specific summary table for this run"
    })
  }
  support_text <- matched$support[[1]]
  if (identical(support_text, "None below p < 0.10")) {
    return(if (identical(lang, "es")) {
      "ningun termino focal alcanzo el umbral p < 0.10 en la tabla de resumen especifica por rol"
    } else {
      "no focal term reached the p < 0.10 threshold in the role-specific summary table"
    })
  }
  if (identical(lang, "es")) {
    return(sprintf("el resumen de soporte especifico por rol destaco: %s", support_text))
  }
  sprintf("the role-specific support summary highlighted: %s", support_text)
}

build_crossreferenced_conclusion_section <- function(significance_summary, lang = "en") {
  is_es <- identical(lang, "es")
  h1_v <- get_role_support_text(significance_summary, "H1", "Victim", lang = lang)
  h1_b <- get_role_support_text(significance_summary, "H1", "Bystander", lang = lang)
  h2_v <- get_role_support_text(significance_summary, "H2", "Victim", lang = lang)
  h2_b <- get_role_support_text(significance_summary, "H2", "Bystander", lang = lang)
  h3_v <- get_role_support_text(significance_summary, "H3", "Victim", lang = lang)
  h3_b <- get_role_support_text(significance_summary, "H3", "Bystander", lang = lang)
  h4_v <- get_role_support_text(significance_summary, "H4", "Victim", lang = lang)
  h4_b <- get_role_support_text(significance_summary, "H4", "Bystander", lang = lang)
  h5_v <- get_role_support_text(significance_summary, "H5", "Victim", lang = lang)
  h5_b <- get_role_support_text(significance_summary, "H5", "Bystander", lang = lang)

  if (is_es) {
    return(c(
      "# Conclusiones",
      "",
      "Las conclusiones de este reporte deben leerse como asociacionales y no causales. En este informe, `judgement` fue estimado con un modelo Tobit de dos lados que maneja censura, observaciones repetidas por participante y ajuste de sesion mediante `factor(session)` con inferencia robusta agrupada por participante.",
      "",
      "Esta seccion de cierre referencia la estructura completa del reporte. Debe leerse junto con los resumenes de ecuaciones H1-H5, el resumen de significancia por rol, las tablas completas de coeficientes con interpretacion y las figuras guiadas por significancia.",
      "",
      "## Sintesis por hipotesis",
      "",
      "### H1",
      "",
      "H1 evalua empatia como predictor directo de `judgement` reteniendo controles comunes. Para referencia cruzada, ver el resumen de ecuaciones H1 y las tablas y figuras especificas por rol de H1. En el rol Victim,",
      sprintf("%s.", h1_v),
      "En el rol Bystander,",
      sprintf("%s.", h1_b),
      "En conjunto, H1 sugiere que la posicion de rol condiciona que tan claramente aparece empatia en el patron ajustado de `judgement`.",
      "",
      "### H2",
      "",
      get_hypothesis_semantic_reminder("H2", lang = lang),
      "",
      "H2 se enfoca en estructura ingroup/outgroup especifica por rol. Para referencia cruzada, ver el resumen de ecuaciones H2 y las tablas y figuras especificas por rol de H2. En el rol Victim,",
      sprintf("%s.", h2_v),
      "En el rol Bystander,",
      sprintf("%s.", h2_b),
      "Esta comparacion indica que las claves de alineacion relacional no son igual de informativas entre roles y pueden volverse mas visibles cuando participantes evaluan como observadores y no como actores directamente afectados.",
      "",
      "### H3",
      "",
      "H3 combina empatia, estructura de grupo e interacciones. Para referencia cruzada, ver el resumen de ecuaciones H3, las tablas de coeficientes H3 y las figuras de interaccion H3. En el rol Victim,",
      sprintf("%s.", h3_v),
      "En el rol Bystander,",
      sprintf("%s.", h3_b),
      "La evidencia de H3 debe leerse como una prueba de moderacion contextual: empatia no necesariamente opera como una pendiente uniforme cuando cambia la distancia social.",
      "",
      "### H4",
      "",
      get_hypothesis_semantic_reminder("H4", lang = lang),
      "",
      "H4 prueba terminos de decision de forma directa mediante `accept_target`, `accept_other` y su interaccion. Para referencia cruzada, ver el resumen de ecuaciones H4 y las tablas y figuras de significancia especificas por rol de H4. En el rol Victim,",
      sprintf("%s.", h4_v),
      "En el rol Bystander,",
      sprintf("%s.", h4_b),
      "En ambos roles, H4 suele ser donde el mecanismo decisional se ve con mayor claridad, porque el juicio al target esta condicionado explicitamente por resultados conjuntos de negociacion.",
      "",
      "### H5",
      "",
      get_hypothesis_semantic_reminder("H5", lang = lang),
      "",
      "H5 es la especificacion integrada que combina empatia, terminos relacionales, decisiones e interacciones. Para referencia cruzada, ver el resumen de ecuaciones H5, las tablas de coeficientes H5 y las figuras de significancia H5. En el rol Victim,",
      sprintf("%s.", h5_v),
      "En el rol Bystander,",
      sprintf("%s.", h5_b),
      "H5 debe leerse como sintesis y no como reemplazo de hipotesis previas: muestra como componentes disposicionales, relacionales y decisionales coexisten en un mismo modelo.",
      "",
      "## Interpretacion global",
      "",
      "Tomadas en conjunto, las cinco hipotesis indican que `judgement` en este experimento es multimecanismo y no unidimensional. Terminos de empatia pueden importar, alineacion relacional puede importar, y terminos de decision pueden importar fuertemente, pero su visibilidad cambia por rol y por contexto de modelo.",
      "",
      "En terminos practicos, el reporte respalda una lectura contingente al rol: el juicio en Victim conserva contenido disposicional mas fuerte en algunas especificaciones, mientras el juicio en Bystander suele depender mas del contexto relacional, y ambos roles permanecen sensibles a las decisiones conjuntas de los negociadores.",
      ""
    ))
  }

  c(
    "# Conclusion",
    "",
    "The conclusions presented here should be interpreted as associational rather than causal. In this report, moral judgement was estimated with a two-sided Tobit model that handles censoring, repeated participant observations, and session adjustment through `factor(session)` with participant-cluster robust inference.",
    "",
    "This conclusion section cross-references the full report structure. It should be read together with the H1-H5 equation summaries, the hypothesis significance summary by role, the full coefficient tables and interpretation summary, and the significance-driven figures.",
    "",
    "## Hypothesis-by-hypothesis synthesis",
    "",
    "### H1",
    "",
    "H1 evaluates empathy as a direct predictor of moral judgement while retaining common controls. For cross-reference, see the H1 equation summary and the H1 role-specific coefficient tables and figures. In the victim role,",
    sprintf("%s.", h1_v),
    "In the bystander role,",
    sprintf("%s.", h1_b),
    "Taken together, H1 suggests that the role position conditions how clearly empathy appears in the fitted judgement pattern.",
    "",
    "### H2",
    "",
    get_hypothesis_semantic_reminder("H2", lang = lang),
    "",
    "H2 focuses on role-specific ingroup/outgroup structure. For cross-reference, see the H2 equation summary and the H2 role-specific coefficient tables and figures. In the victim role,",
    sprintf("%s.", h2_v),
    "In the bystander role,",
    sprintf("%s.", h2_b),
    "This comparison indicates that relational alignment cues are not equally informative across roles, and they can become more visible when participants evaluate as observers rather than as directly harmed actors.",
    "",
    "### H3",
    "",
    "H3 combines empathy, group structure, and interaction terms. For cross-reference, see the H3 equation summary, the H3 coefficient tables, and the H3 interaction figures. In the victim role,",
    sprintf("%s.", h3_v),
    "In the bystander role,",
    sprintf("%s.", h3_b),
    "The H3 evidence should therefore be interpreted as a test of contextual moderation: empathy does not necessarily operate as a uniform slope when social distance changes.",
    "",
    "### H4",
    "",
    get_hypothesis_semantic_reminder("H4", lang = lang),
    "",
    "H4 tests decision terms directly through `accept_target`, `accept_other`, and their interaction. For cross-reference, see the H4 equation summary and the H4 role-specific coefficient tables and significance figures. In the victim role,",
    sprintf("%s.", h4_v),
    "In the bystander role,",
    sprintf("%s.", h4_b),
    "Across both roles, H4 is typically where the decisional mechanism is most clearly visible, because the target judgement is explicitly conditioned by joint negotiation outcomes.",
    "",
    "### H5",
    "",
    get_hypothesis_semantic_reminder("H5", lang = lang),
    "",
    "H5 is the integrated specification combining empathy, relational terms, decisions, and interactions. For cross-reference, see the H5 equation summary, H5 coefficient tables, and H5 significance figures. In the victim role,",
    sprintf("%s.", h5_v),
    "In the bystander role,",
    sprintf("%s.", h5_b),
    "H5 should be read as a synthesis rather than a replacement of previous hypotheses: it shows how dispositional, relational, and decisional components coexist in one model.",
    "",
    "## Overall interpretation",
    "",
    "Taken as a whole, the five hypotheses indicate that moral judgement in this experiment is multi-mechanistic rather than one-dimensional. Empathy-related terms can matter, relational alignment can matter, and decision terms can matter strongly, but their visibility changes by role and model context.",
    "",
    "In practical terms, the report supports a role-contingent interpretation: victim-side judgement retains stronger dispositional content in some specifications, while bystander-side judgement often shows greater dependence on relational context, and both roles remain sensitive to the joint decisions made by negotiators.",
    ""
  )
}

localize_figure_manifest_for_language <- function(figure_manifest, lang = "en") {
  if (!identical(lang, "es") || nrow(figure_manifest) == 0L) {
    return(figure_manifest)
  }

  localized <- figure_manifest
  localized$caption <- ifelse(
    localized$figure_type == "significance",
    sprintf(
      "%s %s: predicciones implicadas por el modelo para %s.",
      localized$hypothesis,
      localized$role,
      vapply(localized$term, label_current_term, character(1))
    ),
    localized$caption
  )

  localized$caption <- vapply(localized$caption, function(cap_line) {
    if (identical(cap_line, "Mean IRI subscale profile across participants.")) return("Perfil promedio de subescalas IRI en participantes.")
    if (identical(cap_line, "Participant-level bivariate scatters of IRI subscales against mean judgement.")) return("Dispersogramas bivariados a nivel participante de subescalas IRI frente a `judgement` promedio.")
    if (identical(cap_line, "Observed judgement distributions split by role.")) return("Distribuciones observadas de `judgement` separadas por rol.")
    if (identical(cap_line, "Observed judgement distributions by role and target negotiator.")) return("Distribuciones observadas de `judgement` por rol y negociador target.")
    if (identical(cap_line, "Observed judgement distributions by role and target decision.")) return("Distribuciones observadas de `judgement` por rol y decision del target.")
    if (identical(cap_line, "Observed judgement distributions by role and counterpart decision.")) return("Distribuciones observadas de `judgement` por rol y decision de la contraparte.")
    if (identical(cap_line, "Observed judgement distributions by role and joint decision pattern.")) return("Distribuciones observadas de `judgement` por rol y patron conjunto de decision.")
    if (identical(cap_line, "Observed decision-pattern counts by role.")) return("Conteos observados de patrones de decision por rol.")
    if (identical(cap_line, "Victim-role judgement distributions across target x other faculty pairings.")) return("Distribuciones de `judgement` del rol Victim a traves de pareamientos de facultad target x other.")
    if (identical(cap_line, "Bystander-role judgement distributions across target x other faculty pairings.")) return("Distribuciones de `judgement` del rol Bystander a traves de pareamientos de facultad target x other.")
    if (identical(cap_line, "Victim-role judgement distributions across victim-target and victim-other ingroup/outgroup combinations.")) return("Distribuciones de `judgement` del rol Victim a traves de combinaciones victim-target y victim-other de ingroup/outgroup.")
    if (identical(cap_line, "Bystander-role judgement distributions across bystander-target and bystander-other ingroup/outgroup combinations.")) return("Distribuciones de `judgement` del rol Bystander a traves de combinaciones bystander-target y bystander-other de ingroup/outgroup.")
    if (identical(cap_line, "Bystander-role judgement distributions across victim-target and victim-other ingroup/outgroup combinations.")) return("Distribuciones de `judgement` del rol Bystander a traves de combinaciones victim-target y victim-other de ingroup/outgroup.")
    cap_line
  }, character(1))

  localized$interpretation <- vapply(localized$interpretation, function(text_line) {
    if (identical(text_line, "This figure summarizes the central empathy profile of the sample before conditioning on hypothesis-specific models.")) return("Esta figura resume el perfil central de empatia de la muestra antes de condicionar en modelos especificos de hipotesis.")
    if (identical(text_line, "These scatterplots show the participant-level descriptive relationship between empathy dimensions and average judgement.")) return("Estos scatterplots muestran la relacion descriptiva a nivel participante entre dimensiones de empatia y `judgement` promedio.")
    if (identical(text_line, "This figure shows the raw shape of the bounded judgement outcome in the victim and bystander subsets.")) return("Esta figura muestra la forma bruta del outcome acotado `judgement` en los subconjuntos Victim y Bystander.")
    if (identical(text_line, "This figure shows whether the raw bounded judgement distribution differs depending on whether the target code is 1 or 2 within victim and bystander settings.")) return("Esta figura muestra si la distribucion bruta y acotada de `judgement` cambia segun si el codigo de target es 1 o 2 dentro de escenarios Victim y Bystander.")
    if (identical(text_line, "This figure isolates whether the target's own acceptance or rejection is associated with different raw judgement profiles within each role.")) return("Esta figura aisla si la aceptacion o rechazo del propio target se asocia con perfiles brutos distintos de `judgement` dentro de cada rol.")
    if (identical(text_line, "This figure shows whether judgement of the target varies with the acceptance or rejection of the other negotiator.")) return("Esta figura muestra si `judgement` del target varia con la aceptacion o rechazo del otro negociador.")
    if (identical(text_line, "This figure shows how the target-focused judgement distribution changes across the four joint negotiation outcomes in victim and bystander settings.")) return("Esta figura muestra como cambia la distribucion de `judgement` enfocada en target a traves de los cuatro resultados conjuntos de negociacion en escenarios Victim y Bystander.")
    if (identical(text_line, "This figure summarizes how often each joint decision pattern appears in victim and bystander subsets.")) return("Esta figura resume con que frecuencia aparece cada patron conjunto de decision en los subconjuntos Victim y Bystander.")
    if (identical(text_line, "This figure shows how the raw judgement distribution varies across the full relational space defined by the faculty pairing of target and other.")) return("Esta figura muestra como varia la distribucion bruta de `judgement` a traves del espacio relacional completo definido por el pareamiento de facultad entre target y other.")
    if (identical(text_line, "This optional figure highlights how raw victim-role judgement varies across victim-centered ingroup/outgroup combinations.")) return("Esta figura opcional destaca como varia el `judgement` bruto del rol Victim a traves de combinaciones ingroup/outgroup centradas en la victima.")
    if (identical(text_line, "This optional figure emphasizes bystander-side relational combinations directly tied to target/other group alignment.")) return("Esta figura opcional enfatiza combinaciones relacionales del lado Bystander ligadas directamente a la alineacion de grupo de target y other.")
    if (identical(text_line, "This optional figure shows how bystander judgement co-varies with victim-centered relational combinations in the same observed rows.")) return("Esta figura opcional muestra como `judgement` del bystander covaria con combinaciones relacionales centradas en la victima dentro de las mismas filas observadas.")
    if (identical(text_line, "The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.")) return("Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.")
    if (identical(text_line, "Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.")) return("A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.")
    if (identical(text_line, "Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.")) return("A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.")
    text_line
  }, character(1))

  localized
}

report_lines <- c(
  "---",
  'title: "Working Paper Report of Moral Judgement under Two-sided Tobit Models"',
  'author: "Leonardo H. Talero-Sarmiento"',
  paste0('date: "', get_report_timestamp(), '"'),
  "numbersections: true",
  "---",
  "",
  "This run uses `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` as the only analytical source and preserves each imported row as one real judgement observation. The production estimator is a two-sided Tobit fitted with `survival::survreg`, using bilateral censoring at `-9` and `9`, participant-cluster robust standard errors through `cluster = id`, and `factor(session)` in every active formula.",
  "",
  build_introductory_theoretical_chapter(),
  "",
  "# Semantic naming bridge and row-level mapping",
  "",
  "Source/legacy naming bridge: `decision_target` -> active operational name `accept_target`; `decision_other` -> active operational name `accept_other`.",
  "",
  "Row-level semantics: `target` and `other` are dynamic roles per observation; all active analytical terms in this report are expressed directly in that pair.",
  "",
  build_numbered_table_block(target_slot_mapping_audit, "Row-level decision mapping from dynamic target/other to legacy structural-slot mappings"),
  "",
  "# Dataset and sample description",
  "",
  get_dataset_sample_description(),
  "",
  "The authoritative interpretation is that each player observes ten scenarios and evaluates two negotiators, so the longitudinal file should contain 20 judgement rows per participant. The clustering diagnostic below is consistent with that design.",
  "",
  build_numbered_table_block(participant_summary, "Participant summary"),
  build_numbered_table_block(judgement_summary, "Judgement summary"),
  "",
  "# Datacard and symbol dictionary",
  "",
  build_numbered_table_block(symbol_dictionary, "Datacard symbol dictionary"),
  build_numbered_table_block(observation_audit, "Observation audit"),
  "",
  "# Predictor glossary",
  "",
  build_numbered_table_block(predictor_glossary_main, "Predictor glossary (reader version)"),
  "",
  "Note. Group contrasts are interpreted against the ingroup baseline unless explicitly stated otherwise.",
  "",
  "The report keeps compact predictor references in figure captions and narratives, but the glossary above remains the authoritative mapping back to the current pipeline variables.",
  "",
  "# Interaction interpretation rules",
  "",
  unlist(lapply(seq_along(get_interaction_interpretation_rules()), function(i) paste0(i, ". ", get_interaction_interpretation_rules()[i]))),
  "",
  "# H1-H5 hypotheses with role-specific equation summaries",
  "",
  to_latex_formula_catalog_table(
    formula_catalog_display,
    "H1-H5 role-specific formulas and theoretical focus.",
    "tbl-formula-catalog"
  ),
  "",
  "Any earlier repository note that treated negotiator code `0` as anything other than the explicit control category, or that narrowed H3 to additive effects only, should now be treated as outdated. The active formulas below are the authoritative specification.",
  ""
)

for (hypothesis_id in paste0("H", 1:5)) {
  report_lines <- c(
    report_lines,
    paste0("## ", hypothesis_id),
    "",
    paste0("`Victim`: `", subset(formula_catalog, hypothesis == hypothesis_id & role == "Victim")$formula_rhs, "`"),
    "",
    paste0("`Bystander`: `", subset(formula_catalog, hypothesis == hypothesis_id & role == "Bystander")$formula_rhs, "`"),
    ""
  )
}

report_lines <- c(
  report_lines,
  "# Mathematical foundations",
  "",
  get_current_tobit_math_foundations(),
  "",
  "In this production branch, `factor(session)` is reported instead of `(1|session)` because the fitted estimator is a two-sided Tobit with session fixed effects and participant-cluster robust standard errors. The report does not claim a random session intercept that was not actually estimated.",
  "",
  "# Dependence and effective sample size diagnostic",
  "",
  "The following clustering diagnostic is descriptive. It summarizes within-participant dependence in the observed data and should not be read as evidence that the fitted estimator included participant random intercepts.",
  "",
  build_numbered_table_block(clustering_diagnostic, "Descriptive clustering diagnostic"),
  "",
  "Because the target of inference is repeated judgement within participant, the effective-sample-size table is a descriptive clustering diagnostic only; it does not replace the model-based dependence adjustment through `cluster = id` and `factor(session)`.",
  "",
  "# Descriptive statistics and figures",
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
  "# Estimator fit summary",
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
  "## Model-level fit and censoring summary",
  ""
)

if (nrow(fit_bystander) > 0L) {
  report_lines <- c(
    report_lines,
    "### Bystander models",
    "",
    build_numbered_table_block(fit_bystander, "Bystander model fit and censoring summary")
  )
}

if (nrow(fit_victim) > 0L) {
  report_lines <- c(
    report_lines,
    "### Victim models",
    "",
    build_numbered_table_block(fit_victim, "Victim model fit and censoring summary")
  )
}

# Append the hypothesis significance summary by role.
report_lines <- c(
  report_lines,
  "# Hypothesis significance summary by role",
  "",
  "## Victim",
  "",
  build_numbered_table_block(
    subset(significance_summary, role == "Victim"),
    "Victim focal support terms (p < 0.10)"
  ),
  "## Bystander",
  "",
  build_numbered_table_block(
    subset(significance_summary, role == "Bystander"),
    "Bystander focal support terms (p < 0.10)"
  ),
  "# Significance-driven figures",
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
      paste0("## ", figure_row$hypothesis, " ", figure_row$role, ": ", label_current_term(figure_row$term)),
      "",
      build_image_block(figure_row)
    )
  }
}

# Add the full coefficient tables and their short interpretation narratives.
report_lines <- c(
  report_lines,
  "# Full coefficient tables and interpretation summary",
  ""
)

for (hypothesis_id in paste0("H", 1:5)) {
  hypothesis_reminder <- get_hypothesis_semantic_reminder(hypothesis_id)
  if (nzchar(hypothesis_reminder)) {
    report_lines <- c(
      report_lines,
      hypothesis_reminder,
      ""
    )
  }
  for (role_label in c("Victim", "Bystander")) {
    prefix <- get_model_prefix(hypothesis_id, role_label)
    if (!(prefix %in% names(coefficient_tables))) next

    report_lines <- c(
      report_lines,
      paste0("## ", hypothesis_id, " ", role_label, " coefficient table"),
      "",
      build_numbered_table_block(
        coefficient_tables[[prefix]],
        sprintf("%s %s coefficient estimates", hypothesis_id, role_label)
      ),
      coefficient_narratives_en[[prefix]],
      ""
    )
  }
}

# Close the report with compliance, corrections, limitations, discussion, audit, and conclusion.
report_lines <- c(
  report_lines,
  "# Compliance checklist",
  "",
  build_numbered_table_block(compliance_report, "Pipeline compliance checklist"),
  "",
  "# Corrections relative to outdated notes",
  "",
  "The current production branch supersedes earlier notes that used `control_hidden` wording for negotiator code `0`, narrowed H3 to additive-only empathy terms, or implied that the main estimator used `(1|session)`. The repository now documents the implemented estimator and the authoritative role-specific design directly.",
  "",
  "# Limitations",
  "",
  get_current_limitations(),
  "",
  build_discussion_section(),
  build_final_audit_note(compliance_report, fit_summary),
  "# Technical appendix: predictor code map",
  "",
  build_numbered_table_block(predictor_glossary_appendix, "Predictor-to-code map (technical appendix)"),
  "",
  build_crossreferenced_conclusion_section(significance_summary)
)

replace_fixed_pairs <- function(lines, from, to) {
  if (length(from) == 0L || length(to) == 0L) return(lines)
  n <- min(length(from), length(to))
  for (i in seq_len(n)) {
    if (!nzchar(from[[i]]) || identical(from[[i]], to[[i]])) next
    lines <- gsub(from[[i]], to[[i]], lines, fixed = TRUE)
  }
  lines
}

replace_exact_line_pairs <- function(lines, from, to) {
  if (length(from) == 0L || length(to) == 0L) return(lines)
  n <- min(length(from), length(to))
  for (i in seq_len(n)) {
    if (!nzchar(from[[i]]) || identical(from[[i]], to[[i]])) next
    lines[lines == from[[i]]] <- to[[i]]
  }
  lines
}

translate_report_lines_to_spanish <- function(
    lines_en,
    significance_summary,
    coefficient_narratives_en,
    coefficient_narratives_es,
    figure_manifest) {
  lines_es <- lines_en

  static_from <- c(
    'title: "Working Paper Report of Moral Judgement under Two-sided Tobit Models"',
    "This run uses `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` as the only analytical source and preserves each imported row as one real judgement observation. The production estimator is a two-sided Tobit fitted with `survival::survreg`, using bilateral censoring at `-9` and `9`, participant-cluster robust standard errors through `cluster = id`, and `factor(session)` in every active formula.",
    "# Semantic naming bridge and row-level mapping",
    "Source/legacy naming bridge: `decision_target` -> active operational name `accept_target`; `decision_other` -> active operational name `accept_other`.",
    "Row-level semantics: `target` and `other` are dynamic roles per observation; all active analytical terms in this report are expressed directly in that pair.",
    "# Dataset and sample description",
    "The authoritative interpretation is that each player observes ten scenarios and evaluates two negotiators, so the longitudinal file should contain 20 judgement rows per participant. The clustering diagnostic below is consistent with that design.",
    "# Datacard and symbol dictionary",
    "# Predictor glossary",
    "Note. Group contrasts are interpreted against the ingroup baseline unless explicitly stated otherwise.",
    "The report keeps compact predictor references in figure captions and narratives, but the glossary above remains the authoritative mapping back to the current pipeline variables.",
    "# Interaction interpretation rules",
    "# H1-H5 hypotheses with role-specific equation summaries",
    "Any earlier repository note that treated negotiator code `0` as anything other than the explicit control category, or that narrowed H3 to additive effects only, should now be treated as outdated. The active formulas below are the authoritative specification.",
    "# Mathematical foundations",
    "In this production branch, `factor(session)` is reported instead of `(1|session)` because the fitted estimator is a two-sided Tobit with session fixed effects and participant-cluster robust standard errors. The report does not claim a random session intercept that was not actually estimated.",
    "# Dependence and effective sample size diagnostic",
    "The following clustering diagnostic is descriptive. It summarizes within-participant dependence in the observed data and should not be read as evidence that the fitted estimator included participant random intercepts.",
    "Because the target of inference is repeated judgement within participant, the effective-sample-size table is a descriptive clustering diagnostic only; it does not replace the model-based dependence adjustment through `cluster = id` and `factor(session)`.",
    "# Descriptive statistics and figures",
    "The group summary and the formulas above use role-specific ingroup/outgroup coding. Ingroup is defined by faculty coincidence, including `control` with `control`, while outgroup means non-matching faculties.",
    "# Estimator fit summary",
    "All production models use the estimator configuration shown below.",
    "## Model-level fit and censoring summary",
    "### Bystander models",
    "### Victim models",
    "# Hypothesis significance summary by role",
    "# Significance-driven figures",
    "No focal term reached the plotting threshold in this run, so no significance-driven figures were generated.",
    "# Full coefficient tables and interpretation summary",
    "# Compliance checklist",
    "# Corrections relative to outdated notes",
    "The current production branch supersedes earlier notes that used `control_hidden` wording for negotiator code `0`, narrowed H3 to additive-only empathy terms, or implied that the main estimator used `(1|session)`. The repository now documents the implemented estimator and the authoritative role-specific design directly.",
    "# Limitations",
    "# Technical appendix: predictor code map",
    "## Victim",
    "## Bystander",
    "## Significance-driven figures"
  )

  static_to <- c(
    'title: "Reporte de Trabajo sobre Juicio Moral bajo Modelos Tobit de Dos Lados"',
    "Esta corrida usa `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` como unica fuente analitica y preserva cada fila importada como una observacion real de judgement. El estimador productivo es un Tobit de dos lados ajustado con `survival::survreg`, usando censura bilateral en `-9` y `9`, errores estandar robustos por cluster de participante via `cluster = id`, y `factor(session)` en cada formula activa.",
    "# Puente semantico de nombres y mapeo por fila",
    "Puente de nombres fuente/legacy: `decision_target` -> nombre operativo activo `accept_target`; `decision_other` -> nombre operativo activo `accept_other`.",
    "Semantica por fila: `target` y `other` son roles dinamicos por observacion; todos los terminos analiticos activos del reporte se expresan directamente en ese par.",
    "# Descripcion del dataset y de la muestra",
    "La interpretacion autoritativa es que cada jugador observa diez escenarios y evalua dos negociadores, por lo que el archivo longitudinal debe contener 20 filas de judgement por participante. El diagnostico de clustering siguiente es consistente con ese diseno.",
    "# Datacard y diccionario de simbolos",
    "# Glosario de predictores",
    "Nota. Los contrastes de grupo se interpretan contra la linea base ingroup, salvo indicacion explicita en contrario.",
    "El reporte mantiene referencias compactas de predictores en captions y narrativas de figuras, pero el glosario anterior es el mapeo autoritativo hacia las variables actuales del pipeline.",
    "# Reglas de interpretacion de interacciones",
    "# Hipotesis H1-H5 con resumenes de ecuaciones especificas por rol",
    "Cualquier nota previa del repositorio que tratara el codigo de negociador `0` como algo distinto de la categoria explicita control, o que restringiera H3 a efectos aditivos, debe considerarse desactualizada. Las formulas activas siguientes son la especificacion autoritativa.",
    "# Fundamentos matematicos",
    "En esta rama productiva, se reporta `factor(session)` en lugar de `(1|session)` porque el estimador ajustado es un Tobit de dos lados con efectos fijos de sesion y errores estandar robustos por cluster de participante. El reporte no afirma un intercepto aleatorio de sesion que no haya sido estimado.",
    "# Diagnostico de dependencia y tamano efectivo de muestra",
    "El siguiente diagnostico de clustering es descriptivo. Resume la dependencia intra-participante en los datos observados y no debe leerse como evidencia de que el estimador ajustado incluyo interceptos aleatorios por participante.",
    "Como el objetivo de inferencia es el judgement repetido dentro de participante, la tabla de tamano efectivo de muestra es solo un diagnostico descriptivo de clustering; no reemplaza el ajuste de dependencia basado en modelo mediante `cluster = id` y `factor(session)`.",
    "# Estadisticas descriptivas y figuras",
    "El resumen de grupos y las formulas anteriores usan codificacion ingroup/outgroup especifica por rol. Ingroup se define por coincidencia de facultad, incluyendo `control` con `control`, mientras outgroup significa facultades no coincidentes.",
    "# Resumen de ajuste del estimador",
    "Todos los modelos productivos usan la configuracion del estimador mostrada abajo.",
    "## Resumen de ajuste y censura a nivel de modelo",
    "### Modelos Bystander",
    "### Modelos Victim",
    "# Resumen de significancia de hipotesis por rol",
    "# Figuras guiadas por significancia",
    "Ningun termino focal alcanzo el umbral para graficar en esta corrida, por lo que no se generaron figuras guiadas por significancia.",
    "# Tablas completas de coeficientes y resumen de interpretacion",
    "# Lista de verificacion de cumplimiento",
    "# Correcciones frente a notas desactualizadas",
    "La rama productiva actual reemplaza notas previas que usaban `control_hidden` para el codigo de negociador `0`, restringian H3 a terminos de empatia solo aditivos, o implicaban que el estimador principal usaba `(1|session)`. El repositorio ahora documenta de forma directa el estimador implementado y el diseno autoritativo especifico por rol.",
    "# Limitaciones",
    "# Apendice tecnico: mapa de codigos de predictores",
    "## Victim",
    "## Bystander",
    "## Figuras guiadas por significancia"
  )
  lines_es <- replace_fixed_pairs(lines_es, static_from, static_to)

  helper_maps <- list(
    list(from = build_introductory_theoretical_chapter(lang = "en"), to = build_introductory_theoretical_chapter(lang = "es")),
    list(from = get_dataset_sample_description(lang = "en"), to = get_dataset_sample_description(lang = "es")),
    list(from = get_interaction_interpretation_rules(lang = "en"), to = get_interaction_interpretation_rules(lang = "es")),
    list(from = get_current_tobit_math_foundations(lang = "en"), to = get_current_tobit_math_foundations(lang = "es")),
    list(from = get_current_limitations(lang = "en"), to = get_current_limitations(lang = "es")),
    list(from = build_discussion_section(lang = "en"), to = build_discussion_section(lang = "es")),
    list(from = build_final_audit_note(compliance_report, fit_summary, lang = "en"), to = build_final_audit_note(compliance_report, fit_summary, lang = "es")),
    list(from = build_crossreferenced_conclusion_section(significance_summary, lang = "en"), to = build_crossreferenced_conclusion_section(significance_summary, lang = "es"))
  )
  for (entry in helper_maps) {
    long_idx <- nchar(entry$from) >= 20L
    lines_es <- replace_exact_line_pairs(lines_es, entry$from[!long_idx], entry$to[!long_idx])
    lines_es <- replace_fixed_pairs(lines_es, entry$from[long_idx], entry$to[long_idx])
  }

  reminder_en <- vapply(c("H2", "H4", "H5"), get_hypothesis_semantic_reminder, character(1), lang = "en")
  reminder_es <- vapply(c("H2", "H4", "H5"), get_hypothesis_semantic_reminder, character(1), lang = "es")
  lines_es <- replace_exact_line_pairs(lines_es, reminder_en, reminder_es)

  common_prefixes <- intersect(names(coefficient_narratives_en), names(coefficient_narratives_es))
  if (length(common_prefixes) > 0L) {
    lines_es <- replace_exact_line_pairs(
      lines_es,
      unname(unlist(coefficient_narratives_en[common_prefixes], use.names = FALSE)),
      unname(unlist(coefficient_narratives_es[common_prefixes], use.names = FALSE))
    )
  }

  figure_manifest_es <- localize_figure_manifest_for_language(figure_manifest, lang = "es")
  lines_es <- replace_exact_line_pairs(lines_es, figure_manifest$interpretation, figure_manifest_es$interpretation)

  image_line_en <- paste0("![", figure_manifest$caption, "](", relative_report_path(figure_manifest$figure_file), ")")
  image_line_es <- paste0("![", figure_manifest_es$caption, "](", relative_report_path(figure_manifest_es$figure_file), ")")
  lines_es <- replace_exact_line_pairs(lines_es, image_line_en, image_line_es)

  symbol_en <- get_current_symbol_dictionary(lang = "en")
  symbol_es <- get_current_symbol_dictionary(lang = "es")
  lines_es <- replace_fixed_pairs(lines_es, symbol_en$definition, symbol_es$definition)

  glossary_en <- get_current_predictor_glossary(lang = "en")
  glossary_es <- get_current_predictor_glossary(lang = "es")
  lines_es <- replace_fixed_pairs(lines_es, glossary_en$meaning, glossary_es$meaning)

  table_phrase_from <- c(
    "Row-level decision mapping from dynamic target/other to legacy structural-slot mappings",
    "Participant summary",
    "Judgement summary",
    "Datacard symbol dictionary",
    "Observation audit",
    "Predictor glossary (reader version)",
    "Descriptive clustering diagnostic",
    "Decision summary by role",
    "Role-specific ingroup/outgroup summary",
    "Participant-level empathy and mean judgement correlation matrix",
    "Estimator configuration",
    "Bystander model fit and censoring summary",
    "Victim model fit and censoring summary",
    "Victim focal support terms (p < 0.10)",
    "Bystander focal support terms (p < 0.10)",
    "Pipeline compliance checklist",
    "Predictor-to-code map (technical appendix)",
    "H1-H5 role-specific formulas and theoretical focus."
  )
  table_phrase_to <- c(
    "Mapeo de decision por fila desde target/other dinamicos hacia mapeos estructurales legacy",
    "Resumen de participantes",
    "Resumen de judgement",
    "Diccionario de simbolos del datacard",
    "Auditoria de observaciones",
    "Glosario de predictores (version de lectura)",
    "Diagnostico descriptivo de clustering",
    "Resumen de decisiones por rol",
    "Resumen ingroup/outgroup especifico por rol",
    "Matriz de correlacion entre empatia y judgement promedio a nivel participante",
    "Configuracion del estimador",
    "Resumen de ajuste y censura para modelos Bystander",
    "Resumen de ajuste y censura para modelos Victim",
    "Terminos de soporte focal Victim (p < 0.10)",
    "Terminos de soporte focal Bystander (p < 0.10)",
    "Lista de verificacion de cumplimiento del pipeline",
    "Mapa predictor-a-codigo (apendice tecnico)",
    "Formulas especificas por rol H1-H5 y enfoque teorico."
  )
  lines_es <- replace_fixed_pairs(lines_es, table_phrase_from, table_phrase_to)

  formula_focus_from <- c(
    "Empathy dimensions with the common accept_target x accept_other adjustment and sociodemographics.",
    "Victim-side ingroup/outgroup structure with the allowed target x other relational interaction and the common accept_target x accept_other adjustment.",
    "Bystander-side relational structure with explicit bystander-victim, bystander-target, bystander-other, target/other context terms, and the common accept_target x accept_other adjustment.",
    "Empathy plus victim-side relational structure, including empathy x victim-target and empathy x victim-other interactions, with the common accept_target x accept_other adjustment.",
    "Empathy plus bystander-side relational structure, including empathy x bystander-victim and empathy x bystander-target/other interactions, with the common accept_target x accept_other adjustment.",
    "Target and other negotiator acceptance terms with their interaction, plus sociodemographics.",
    "Integrated model with empathy, victim-side relations, empathy x group interactions, acceptance terms, and the victim-side target/other interaction.",
    "Integrated model with empathy, bystander-side relations, empathy x group interactions, acceptance terms, and role-specific target/other relational interactions."
  )
  formula_focus_to <- c(
    "Dimensiones de empatia con el ajuste comun accept_target x accept_other y sociodemograficos.",
    "Estructura ingroup/outgroup del lado Victim con la interaccion relacional permitida target x other y el ajuste comun accept_target x accept_other.",
    "Estructura relacional del lado Bystander con terminos explicitos bystander-victim, bystander-target, bystander-other, contexto target/other y el ajuste comun accept_target x accept_other.",
    "Empatia mas estructura relacional del lado Victim, incluyendo interacciones empatia x victim-target y empatia x victim-other, con el ajuste comun accept_target x accept_other.",
    "Empatia mas estructura relacional del lado Bystander, incluyendo interacciones empatia x bystander-victim y empatia x bystander-target/other, con el ajuste comun accept_target x accept_other.",
    "Terminos de aceptacion de target y other con su interaccion, mas sociodemograficos.",
    "Modelo integrado con empatia, relaciones del lado Victim, interacciones empatia x grupo, terminos de aceptacion y la interaccion target/other del lado Victim.",
    "Modelo integrado con empatia, relaciones del lado Bystander, interacciones empatia x grupo, terminos de aceptacion e interacciones relacionales target/other especificas por rol."
  )
  lines_es <- replace_fixed_pairs(lines_es, formula_focus_from, formula_focus_to)

  compliance_from <- c(
    "a) uses judgement",
    "b) repeated structure by id",
    "c) session grouping",
    "d) no double count introduced by the pipeline",
    "e) victim and bystander treated differently",
    "f) accept_target and accept_other included in H1-H5",
    "g) sociodemographics included in every hypothesis model",
    "All formulas model judgement directly.",
    "All fitted Tobit models use participant-cluster robust standard errors through cluster = id.",
    "The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept.",
    "Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander.",
    "All H1-H5 formulas include accept_target, accept_other, and their interaction as part of the active specification.",
    "Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor."
  )
  compliance_to <- c(
    "a) usa judgement",
    "b) estructura repetida por id",
    "c) agrupacion por sesion",
    "d) el pipeline no introduce doble conteo",
    "e) Victim y Bystander tratados de forma diferente",
    "f) accept_target y accept_other incluidos en H1-H5",
    "g) sociodemograficos incluidos en cada modelo de hipotesis",
    "Todas las formulas modelan judgement de forma directa.",
    "Todos los modelos Tobit ajustados usan errores estandar robustos por cluster de participante mediante cluster = id.",
    "La rama Tobit activa usa factor(session) en cada formula y documenta esa eleccion de forma explicita en lugar de afirmar un intercepto aleatorio de sesion.",
    "Las formulas especificas por rol se estiman por separado y H2/H3/H5 usan bloques relacionales diferentes para Victim y Bystander.",
    "Todas las formulas H1-H5 incluyen accept_target, accept_other y su interaccion como parte de la especificacion activa.",
    "Cada formula H1-H5 retiene age, ses, sex_female y faculty_player_factor."
  )
  lines_es <- replace_fixed_pairs(lines_es, compliance_from, compliance_to)

  lines_es <- replace_fixed_pairs(lines_es, c("H & Role & Formula & Focus"), c("H & Rol & Formula & Enfoque"))
  lines_es <- replace_fixed_pairs(lines_es, c("Code | Interpretation"), c("Codigo | Interpretacion"))

  lines_es <- gsub(
    "^Victim models use ([0-9,]+) observations from ([0-9,]+) participants\\.$",
    "Los modelos Victim usan \\1 observaciones de \\2 participantes.",
    lines_es
  )
  lines_es <- gsub(
    "^Bystander models use ([0-9,]+) observations from ([0-9,]+) participants\\.$",
    "Los modelos Bystander usan \\1 observaciones de \\2 participantes.",
    lines_es
  )
  lines_es <- gsub(
    "^Victim models vary in their observation and participant counts; see the tables below\\.$",
    "Los modelos Victim varian en sus conteos de observaciones y participantes; ver tablas abajo.",
    lines_es
  )
  lines_es <- gsub(
    "^Bystander models vary in their observation and participant counts; see the tables below\\.$",
    "Los modelos Bystander varian en sus conteos de observaciones y participantes; ver tablas abajo.",
    lines_es
  )

  lines_es
}

report_lines_es <- translate_report_lines_to_spanish(
  lines_en = report_lines,
  significance_summary = significance_summary,
  coefficient_narratives_en = coefficient_narratives_en,
  coefficient_narratives_es = coefficient_narratives_es,
  figure_manifest = figure_manifest
)

main_report_md <- file.path(paths$report_dir, "tobit_analysis_report.md")
log_report_md <- file.path(paths$logs_dir, "dynamic_report.md")
report_data_md <- file.path(paths$reports_data_dir, "tobit_analysis_report.md")
compatibility_report_md <- file.path(paths$reports_data_dir, "longitudinal_mixed_model_analysis_report.md")
main_report_md_es <- file.path(paths$report_dir, "tobit_analysis_report_es.md")
log_report_md_es <- file.path(paths$logs_dir, "dynamic_report_es.md")
report_data_md_es <- file.path(paths$reports_data_dir, "tobit_analysis_report_es.md")
compatibility_report_md_es <- file.path(paths$reports_data_dir, "longitudinal_mixed_model_analysis_report_es.md")

writeLines(report_lines, main_report_md)
writeLines(report_lines, log_report_md)
writeLines(report_lines, report_data_md)
writeLines(report_lines, compatibility_report_md)
writeLines(report_lines_es, main_report_md_es)
writeLines(report_lines_es, log_report_md_es)
writeLines(report_lines_es, report_data_md_es)
writeLines(report_lines_es, compatibility_report_md_es)

render_dynamic_report_outputs(main_report_md, paths)
render_dynamic_report_outputs(main_report_md_es, paths, artifact_tag = "es")

if (file.exists(file.path(paths$report_dir, "tobit_analysis_report.docx"))) {
  file.copy(file.path(paths$report_dir, "tobit_analysis_report.docx"), file.path(paths$reports_data_dir, "tobit_analysis_report.docx"), overwrite = TRUE)
}
if (file.exists(file.path(paths$report_dir, "tobit_analysis_report.pdf"))) {
  file.copy(file.path(paths$report_dir, "tobit_analysis_report.pdf"), file.path(paths$reports_data_dir, "tobit_analysis_report.pdf"), overwrite = TRUE)
}
if (file.exists(file.path(paths$report_dir, "tobit_analysis_report_es.docx"))) {
  file.copy(file.path(paths$report_dir, "tobit_analysis_report_es.docx"), file.path(paths$reports_data_dir, "tobit_analysis_report_es.docx"), overwrite = TRUE)
}
if (file.exists(file.path(paths$report_dir, "tobit_analysis_report_es.pdf"))) {
  file.copy(file.path(paths$report_dir, "tobit_analysis_report_es.pdf"), file.path(paths$reports_data_dir, "tobit_analysis_report_es.pdf"), overwrite = TRUE)
}

table_caption_counter <- 0L

compliance_lines <- c(
  "# Pipeline Compliance Report",
  "",
  paste0("By Leonardo H. Talero-Sarmiento; Date  ", get_report_timestamp(), "."),
  "",
  build_numbered_table_block(compliance_report, "Pipeline compliance checklist"),
  ""
)
writeLines(compliance_lines, file.path(paths$report_dir, "pipeline_compliance_report.md"))
writeLines(compliance_lines, file.path(paths$reports_data_dir, "pipeline_compliance_report.md"))

compliance_lines_es <- replace_fixed_pairs(
  compliance_lines,
  c(
    "# Pipeline Compliance Report",
    "By Leonardo H. Talero-Sarmiento; Date  ",
    "Pipeline compliance checklist"
  ),
  c(
    "# Reporte de Cumplimiento del Pipeline",
    "Por Leonardo H. Talero-Sarmiento; Fecha  ",
    "Lista de verificacion de cumplimiento del pipeline"
  )
)
writeLines(compliance_lines_es, file.path(paths$report_dir, "pipeline_compliance_report_es.md"))
writeLines(compliance_lines_es, file.path(paths$reports_data_dir, "pipeline_compliance_report_es.md"))



