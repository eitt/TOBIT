# R/05_descriptive_statistics.R
# Purpose: Generate sample summaries and EDA figures mapped to Version 2.0 Factors.
# Inputs: processed datasets
# Outputs: summary tables and figures
# Dependencies: 00_config.R, transform_functions.R, figure_functions.R, table_functions.R

source("R/00_config.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/transform_functions.R")
source("R/utils/figure_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

participants <- read.csv(paths$processed_participants, stringsAsFactors = FALSE)
judgments_analysis <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# Ensure group factor levels are character for safe subsetting
judgments_analysis$group_target <- as.character(judgments_analysis$group_target)
judgments_analysis$group_other  <- as.character(judgments_analysis$group_other)
judgments_analysis$obs_group    <- as.character(judgments_analysis$obs_group)
judgments_victim$group_target   <- as.character(judgments_victim$group_target)
judgments_victim$group_other    <- as.character(judgments_victim$group_other)
judgments_bystander$group_target <- as.character(judgments_bystander$group_target)
judgments_bystander$group_other  <- as.character(judgments_bystander$group_other)
judgments_bystander$obs_group    <- as.character(judgments_bystander$obs_group)

# 1. Participant Summary
participant_summary <- data.frame(
  Metric = c(
    "Total Judgments", "Mean age", "Women in sample", "Engineering"
  ),
  Value = c(
    nrow(judgments_analysis),
    safe_mean(judgments_analysis$age),
    sum(judgments_analysis$sex_female == 1, na.rm = TRUE),
    sum(judgments_analysis$faculty_player == 2, na.rm = TRUE)
  )
)
write.csv(participant_summary, file.path(paths$tables_dir, "participant_summary.csv"), row.names = FALSE)

# 2. Empathy Summary (IRI subscales scored 0–4)
empathy_summary <- data.frame(
  Scale = c("IRI composite (mean subscale)", "Fantasy (FS)", "Empathic concern (EC)",
            "Perspective taking (PT)", "Personal distress (PD)"),
  Mean = c(
    mean((judgments_analysis$iri_fs + judgments_analysis$iri_ec +
            judgments_analysis$iri_pt + judgments_analysis$iri_pd) / 4, na.rm = TRUE),
    safe_mean(judgments_analysis$iri_fs),
    safe_mean(judgments_analysis$iri_ec),
    safe_mean(judgments_analysis$iri_pt),
    safe_mean(judgments_analysis$iri_pd)
  ),
  SD = c(
    sd((judgments_analysis$iri_fs + judgments_analysis$iri_ec +
          judgments_analysis$iri_pt + judgments_analysis$iri_pd) / 4, na.rm = TRUE),
    safe_sd(judgments_analysis$iri_fs),
    safe_sd(judgments_analysis$iri_ec),
    safe_sd(judgments_analysis$iri_pt),
    safe_sd(judgments_analysis$iri_pd)
  ),
  Min = 0, Max = 4
)
write.csv(empathy_summary, file.path(paths$tables_dir, "empathy_summary.csv"), row.names = FALSE)

# 3. Judgment Summary
judgement_summary <- data.frame(
  Metric = c("Judgments in analysis sample", "Victim judgments", "Bystander judgments",
             "Acceptance rate (Target)"),
  Value = c(nrow(judgments_analysis), nrow(judgments_victim), nrow(judgments_bystander),
            mean(judgments_analysis$decision_target, na.rm = TRUE))
)
write.csv(judgement_summary, file.path(paths$tables_dir, "judgement_summary.csv"), row.names = FALSE)

# Group summary table (Version 2.0 factor counts)
group_summary <- data.frame(
  Variable = c(rep("group_target", 3), rep("group_other", 3), rep("obs_group (bystander)", 2)),
  Level = c("Ingroup", "Outgroup", "Control",
            "Ingroup", "Outgroup", "Control",
            "Ingroup", "Outgroup"),
  N_Analysis = c(
    sum(judgments_analysis$group_target == "Ingroup", na.rm = TRUE),
    sum(judgments_analysis$group_target == "Outgroup", na.rm = TRUE),
    sum(judgments_analysis$group_target == "Control", na.rm = TRUE),
    sum(judgments_analysis$group_other == "Ingroup", na.rm = TRUE),
    sum(judgments_analysis$group_other == "Outgroup", na.rm = TRUE),
    sum(judgments_analysis$group_other == "Control", na.rm = TRUE),
    sum(judgments_bystander$obs_group == "Ingroup", na.rm = TRUE),
    sum(judgments_bystander$obs_group == "Outgroup", na.rm = TRUE)
  )
)
write.csv(group_summary, file.path(paths$tables_dir, "group_summary.csv"), row.names = FALSE)

# Generate Figures
style <- get_plot_style()
judgment_axis_limits <- get_judgment_axis_limits()
judgment_axis_ticks <- get_judgment_axis_ticks()
judgment_hist_breaks <- get_judgment_hist_breaks()
case_levels <- get_case_configuration_levels(include_control = TRUE)

# Age distribution (Figure 01)
open_accessible_png(file.path(paths$figures_dir, get_standard_figure_filename("age")))
apply_accessible_theme()
hist(judgments_analysis$age, breaks = pretty(judgments_analysis$age, n = 8),
     col = style$primary_light, border = style$primary_dark, main = "", xlab = "Age (years)")
dev.off()

# Empathy Radar Plot — IRI subscales range 0–4 (Figure 03)
open_accessible_png(file.path(paths$figures_dir, get_standard_figure_filename("radar")))
apply_accessible_theme()
iri_means <- c(safe_mean(judgments_analysis$iri_fs), safe_mean(judgments_analysis$iri_ec),
               safe_mean(judgments_analysis$iri_pt), safe_mean(judgments_analysis$iri_pd))
iri_labels <- c("FS", "EC", "PT", "PD")
iri_legend <- c("FS: Fantasy", "EC: Empathic concern", "PT: Perspective taking", "PD: Personal distress")
draw_base_radar_plot(values = iri_means, labels = iri_labels,
                     max_scale = 4, min_scale = 0,
                     title = "", legend_text = iri_legend)
dev.off()

# Generate Panel Figure helper
draw_distribution_panel_figure <- function(file_path, panel_values, panel_titles,
                                           figure_title, layout, width, height,
                                           xlab = "Judgment severity",
                                           row_labels = NULL) {
  open_accessible_png(file_path, width = width, height = height)
  apply_accessible_theme()
  outer_left_margin <- if (is.null(row_labels)) 0 else 4.0
  graphics::par(
    mfrow = layout,
    mar = c(4.8, 4.8, 3.2, 1.2),
    oma = c(0, outer_left_margin, 3.0, 0)
  )
  max_freq <- max(vapply(panel_values, function(x) {
    if (length(x) == 0L) return(0)
    hist(x, breaks = judgment_hist_breaks, plot = FALSE)$counts |> max()
  }, numeric(1)), na.rm = TRUE)
  max_freq <- max(1, ceiling(max_freq * 1.15))
  for (idx in seq_along(panel_values)) {
    val <- panel_values[[idx]]
    if (length(val) == 0L) {
      graphics::plot.new()
      graphics::title(main = wrap_title(panel_titles[[idx]], width = 22))
      graphics::text(0.5, 0.5, "No observations available")
      next
    }
    graphics::hist(val, breaks = judgment_hist_breaks,
                   col = style$primary_light, border = style$primary_dark,
                   main = wrap_title(panel_titles[[idx]], width = 22),
                   xlab = xlab,
                   xlim = judgment_axis_limits, ylim = c(0, max_freq),
                   xaxt = "n")
    graphics::axis(1, at = judgment_axis_ticks)
    graphics::abline(v = 0, col = style$grid, lty = 3, lwd = 1.5)
  }
  if (!is.null(row_labels) && length(row_labels) == layout[1]) {
    row_positions <- rev((seq_len(layout[1]) - 0.5) / layout[1])
    for (idx in seq_along(row_labels)) {
      graphics::mtext(
        row_labels[[idx]],
        side = 2,
        outer = TRUE,
        at = row_positions[[idx]],
        line = 1.2,
        las = 0,
        cex = 1.0,
        font = 2
      )
    }
  }
  graphics::mtext(figure_title, outer = TRUE, cex = 1.1, font = 2)
  graphics::par(mfrow = c(1, 1), oma = c(0, 0, 0, 0))
  dev.off()
}

group_levels <- c("Ingroup", "Outgroup", "Control")
decision_levels <- c(1L, 0L)
decision_panel_labels <- c("Accept", "Reject")

extract_case_distribution_panels <- function(df, case_levels, decision_value = NULL) {
  lapply(case_levels, function(case_label) {
    use_idx <- df$case_configuration == case_label
    if (!is.null(decision_value)) {
      use_idx <- use_idx & df$decision_accept == decision_value
    }
    df$judgement[use_idx]
  })
}

draw_case_configuration_by_decision_figure <- function(file_path, df, figure_title,
                                                       width = 15, height = 8) {
  panel_values <- unlist(
    lapply(decision_levels, function(decision_value) {
      extract_case_distribution_panels(df, case_levels, decision_value = decision_value)
    }),
    recursive = FALSE
  )
  panel_titles <- unlist(
    lapply(decision_panel_labels, function(decision_label) {
      paste(decision_label, case_levels, sep = "\n")
    }),
    use.names = FALSE
  )

  draw_distribution_panel_figure(
    file_path = file_path,
    panel_values = panel_values,
    panel_titles = panel_titles,
    figure_title = figure_title,
    layout = c(2, 6),
    width = width,
    height = height,
    row_labels = c("Accepted", "Rejected")
  )
}

draw_bivariate_scatter_figure <- function(file_path, plot_data, width = 12, height = 4.2) {
  scatter_specs <- list(
    list(var = "iri_fs", label = "Fantasy"),
    list(var = "iri_ec", label = "Empathic Concern"),
    list(var = "iri_pt", label = "Perspective Taking"),
    list(var = "iri_pd", label = "Personal Distress")
  )

  open_accessible_png(file_path, width = width, height = height)
  apply_accessible_theme()
  graphics::par(mfrow = c(1, 4), mar = c(4.8, 4.6, 2.0, 1.2), oma = c(0, 0, 2.0, 0))

  for (idx in seq_along(scatter_specs)) {
    spec <- scatter_specs[[idx]]
    x <- plot_data[[spec$var]]
    y <- plot_data$mean_judgement
    complete_idx <- is.finite(x) & is.finite(y)
    x <- x[complete_idx]
    y <- y[complete_idx]

    x_limits <- range(x, na.rm = TRUE)
    x_padding <- max(0.08, diff(x_limits) * 0.08)
    x_limits <- c(x_limits[1] - x_padding, x_limits[2] + x_padding)

    graphics::plot(
      x, y,
      type = "n",
      xlab = spec$label,
      ylab = if (idx == 1L) "Mean Judgment" else "",
      xlim = x_limits,
      ylim = judgment_axis_limits,
      yaxt = "n",
      main = ""
    )
    graphics::axis(2, at = judgment_axis_ticks)
    graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1.5)
    draw_lm_fit_with_confidence_band(
      x = x,
      y = y,
      line_color = style$primary_dark,
      band_alpha = 0.18
    )
    graphics::points(
      jitter(x, amount = 0.04),
      jitter(y, amount = 0.12),
      pch = 16,
      cex = 0.72,
      col = grDevices::adjustcolor(style$primary, alpha.f = 0.60)
    )
  }

  graphics::mtext("IRI scales vs. mean judgment", outer = TRUE, cex = 1.1, font = 2)
  graphics::par(mfrow = c(1, 1), oma = c(0, 0, 0, 0))
  dev.off()
}

# Figure 04 — Severity by judged-negotiator group (target) — full sample
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("severity_panels")),
  panel_values = lapply(group_levels,
    function(g) judgments_analysis$judgement[judgments_analysis$group_target == g]),
  panel_titles = paste("N1:", group_levels),
  figure_title = "Judgment severity by N1 group (full sample)",
  layout = c(1, 3), width = 10, height = 6
)

# Figure 05 — Victim subset: severity by N1 group
draw_case_configuration_by_decision_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("victim_case_panels")),
  df = judgments_victim,
  figure_title = "Victim subset — Judgment severity across six case configurations by target decision",
  width = 15,
  height = 8
)

# Figure 06 — Bystander subset: severity by N1 group
draw_case_configuration_by_decision_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("bystander_case_panels")),
  df = judgments_bystander,
  figure_title = "Bystander subset — Judgment severity across six case configurations by target decision",
  width = 15,
  height = 8
)

# Figure 07 — Accepted harmful-deal judgments across six case configurations
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("accepted_case_panels")),
  panel_values = extract_case_distribution_panels(
    judgments_analysis[judgments_analysis$decision_accept == 1L, , drop = FALSE],
    case_levels
  ),
  panel_titles = case_levels,
  figure_title = "Accepted harmful-deal judgments across six case configurations",
  layout = c(1, 6), width = 15, height = 4.2
)

# Figure 08 — Rejected harmful-deal judgments across six case configurations
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("rejected_case_panels")),
  panel_values = extract_case_distribution_panels(
    judgments_analysis[judgments_analysis$decision_accept == 0L, , drop = FALSE],
    case_levels
  ),
  panel_titles = case_levels,
  figure_title = "Rejected harmful-deal judgments across six case configurations",
  layout = c(1, 6), width = 15, height = 4.2
)

# Bi-variate Statistics (Correlations)
iri_vars <- c("iri_fs", "iri_ec", "iri_pt", "iri_pd")
part_judg_means <- aggregate(judgement ~ id, data = judgments_analysis, FUN = mean, na.rm = TRUE)
analysis_data_bivar <- merge(participants[, c("id", iri_vars)], part_judg_means, by = "id")
names(analysis_data_bivar)[names(analysis_data_bivar) == "judgement"] <- "mean_judgement"
bivar_cor <- cor(analysis_data_bivar[, c(iri_vars, "mean_judgement")], use = "complete.obs")
rownames(bivar_cor) <- colnames(bivar_cor) <-
  c("Fantasy", "Empathic Concern", "Perspective Taking", "Personal Distress", "Mean Judgment")
write.csv(bivar_cor, file.path(paths$tables_dir, "bivariate_correlations.csv"))

draw_bivariate_scatter_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("bivariate_scatters")),
  plot_data = analysis_data_bivar
)

message("Descriptive statistics generated successfully.")
