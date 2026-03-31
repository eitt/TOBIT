# R/05_descriptive_statistics.R
# Purpose: Generate sample summaries and EDA figures.
# Inputs: processed datasets
# Outputs: summary tables and figures
# Dependencies: 00_config.R, transform_functions.R, figure_functions.R, table_functions.R
# Execution Order: 6

source("R/00_config.R")
source("R/utils/transform_functions.R")
source("R/utils/figure_functions.R")
source("R/utils/table_functions.R")
source("R/utils/case_configuration_functions.R")
paths <- get_project_paths()

participants <- read.csv(paths$processed_participants, stringsAsFactors = FALSE)
judgments_analysis <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
# H1-H3 subsets
judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# 1. Participant Summary
analysis_participants <- participants[participants$analysis_include, , drop = FALSE]
participant_summary <- data.frame(
  Metric = c(
    "Participants in workbook", "Participants passing attention checks", "Participants in primary analysis",
    "Mean age", "Women in sample", "Men in sample", "Humanities", "Engineering"
  ),
  Value = c(
    nrow(participants), sum(participants$attention_pass, na.rm = TRUE), nrow(analysis_participants),
    safe_mean(analysis_participants$age), sum(analysis_participants$sex == 1, na.rm = TRUE),
    sum(analysis_participants$sex == 2, na.rm = TRUE), sum(analysis_participants$faculty_player == 1, na.rm = TRUE),
    sum(analysis_participants$faculty_player == 2, na.rm = TRUE)
  )
)
write.csv(participant_summary, file.path(paths$tables_dir, "participant_summary.csv"), row.names = FALSE)

# 2. Empathy Summary
empathy_summary <- data.frame(
  Scale = c("IRI total", "Fantasy", "Empathic concern", "Perspective taking", "Personal distress"),
  Mean = c(safe_mean(analysis_participants$iri_total), safe_mean(analysis_participants$iri_fs),
           safe_mean(analysis_participants$iri_ec), safe_mean(analysis_participants$iri_pt),
           safe_mean(analysis_participants$iri_pd)),
  SD = c(safe_sd(analysis_participants$iri_total), safe_sd(analysis_participants$iri_fs),
         safe_sd(analysis_participants$iri_ec), safe_sd(analysis_participants$iri_pt),
         safe_sd(analysis_participants$iri_pd))
)
write.csv(empathy_summary, file.path(paths$tables_dir, "empathy_summary.csv"), row.names = FALSE)

# 3. Judgment Summary
judgement_summary <- data.frame(
  Metric = c("Judgments in analysis sample", "Victim judgments", "Bystander judgments",
             "Acceptance rate", "Left-censored share at -9", "Right-censored share at 9"),
  Value = c(nrow(judgments_analysis), nrow(judgments_victim), nrow(judgments_bystander),
            mean(judgments_analysis$decision_accept, na.rm = TRUE),
            mean(judgments_analysis$judgement == -9, na.rm = TRUE),
            mean(judgments_analysis$judgement == 9, na.rm = TRUE))
)
write.csv(judgement_summary, file.path(paths$tables_dir, "judgement_summary.csv"), row.names = FALSE)

# 4. Relational-status summary
relational_status_summary <- summarise_group(
  judgments_analysis[!is.na(judgments_analysis$group_negotiator_judged), , drop = FALSE],
  group_vars = c("group_negotiator_judged", "group_negotiator_counterpart", "group_victim", "role", "decision_accept"),
  outcome = "judgement"
)
write.csv(relational_status_summary, file.path(paths$tables_dir, "relational_status_summary.csv"), row.names = FALSE)

# Generate Figures
style <- get_plot_style()
judgment_axis_limits <- get_judgment_axis_limits()
judgment_hist_breaks <- get_judgment_hist_breaks()
figure_age_file <- get_standard_figure_filename("age")
figure_empathy_file <- get_standard_figure_filename("empathy")
figure_radar_file <- get_standard_figure_filename("radar")
figure_severity_panels_file <- get_standard_figure_filename("severity_panels")
figure_bivariate_scatters_file <- get_standard_figure_filename("bivariate_scatters")
figure_victim_case_panels_file <- get_standard_figure_filename("victim_case_panels")
figure_bystander_case_panels_file <- get_standard_figure_filename("bystander_case_panels")
figure_accepted_case_panels_file <- get_standard_figure_filename("accepted_case_panels")
figure_rejected_case_panels_file <- get_standard_figure_filename("rejected_case_panels")

draw_distribution_panel_figure <- function(
    file_path,
    panel_values,
    panel_titles,
    figure_title,
    layout,
    width,
    height) {
  open_accessible_png(file_path, width = width, height = height)
  apply_accessible_theme()
  graphics::par(
    mfrow = layout,
    mar = c(4.8, 4.8, 3.2, 1.2),
    oma = c(0, 0, 3.0, 0)
  )

  max_freq <- max(vapply(panel_values, function(x) {
    finite_x <- x[is.finite(x)]
    if (length(finite_x) == 0L) return(0)
    hist(finite_x, breaks = judgment_hist_breaks, plot = FALSE)$counts |> max()
  }, numeric(1)), na.rm = TRUE)
  max_freq <- max(1, ceiling(max_freq * 1.15))

  for (idx in seq_along(panel_values)) {
    values <- panel_values[[idx]]
    values <- values[is.finite(values)]
    if (length(values) == 0L) {
      graphics::plot.new()
      graphics::title(main = wrap_title(panel_titles[[idx]], width = 22))
      graphics::text(0.5, 0.5, "No observations available")
      next
    }

    graphics::hist(
      values,
      breaks = judgment_hist_breaks,
      col = grDevices::adjustcolor(style$primary_light, alpha.f = 0.8),
      border = style$primary_dark,
      main = wrap_title(panel_titles[[idx]], width = 22),
      xlab = "Judgment severity",
      ylab = "Frequency",
      xlim = judgment_axis_limits,
      ylim = c(0, max_freq)
    )
    graphics::abline(v = 0, col = style$grid, lty = 3, lwd = 1.5)
  }

  graphics::par(mfrow = c(1, 1), oma = c(0, 0, 0, 0))
  dev.off()
}

# Age distribution
open_accessible_png(file.path(paths$figures_dir, figure_age_file))
apply_accessible_theme()
hist(analysis_participants$age, breaks = pretty(analysis_participants$age, n=8), 
     col = style$primary_light, border = style$primary_dark, main = "", xlab = "Age (years)")
dev.off()

# Empathy distribution
open_accessible_png(file.path(paths$figures_dir, figure_empathy_file))
apply_accessible_theme()
hist(analysis_participants$iri_total, breaks = pretty(analysis_participants$iri_total, n=8), 
     col = style$primary_light, border = style$primary_dark, main = "", xlab = "IRI composite")
dev.off()

# Empathy Radar Plot
open_accessible_png(file.path(paths$figures_dir, figure_radar_file))
apply_accessible_theme()
iri_means <- c(safe_mean(analysis_participants$iri_fs), safe_mean(analysis_participants$iri_ec), 
               safe_mean(analysis_participants$iri_pt), safe_mean(analysis_participants$iri_pd))
iri_labels <- c("FS", "EC", "PT", "PD")
iri_legend <- c("FS: Fantasy", "EC: Empathic concern", "PT: Perspective taking", "PD: Personal distress")
draw_base_radar_plot(values = iri_means, labels = iri_labels, max_scale = 4, min_scale = 0,
                     title = "", legend_text = iri_legend)
dev.off()

# Severity by Judged-Status Panels
judged_levels <- c("In", "Out", "Cont")
judged_panel_values <- lapply(judged_levels, function(group_level) {
  judgments_analysis$judgement[judgments_analysis$group_negotiator_judged == group_level]
})
draw_distribution_panel_figure(
  file.path(paths$figures_dir, figure_severity_panels_file),
  panel_values = judged_panel_values,
  panel_titles = vapply(judged_levels, function(group_level) {
    sprintf("Judged status: %s", label_relative_group(group_level))
  }, character(1)),
  figure_title = "Judgment distributions by judged negotiator status",
  layout = c(3, 1),
  width = 6,
  height = 10
)

# Bi-variate Statistics (Correlations)
iri_vars <- c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "iri_total")
# Aggregated judgment mean per participant for correlation
part_judg_means <- aggregate(judgement ~ id, data = judgments_analysis, FUN = mean, na.rm = TRUE)
analysis_data_bivar <- merge(analysis_participants[, c("id", iri_vars)], part_judg_means, by = "id")

# Create correlation matrix
bivar_cor <- cor(analysis_data_bivar[, c(iri_vars, "judgement")], use = "complete.obs")
# Label terms for the table
rownames(bivar_cor) <- colnames(bivar_cor) <- c("Fantasy", "Empathic Concern", "Perspective Taking", "Personal Distress", "Total IRI", "Mean Judgment")

# Save bi-variate table
write.csv(bivar_cor, file.path(paths$tables_dir, "bivariate_correlations.csv"))

# Optional: Simple scatter for Bivariate section
open_accessible_png(file.path(paths$figures_dir, figure_bivariate_scatters_file), width = 10, height = 4)
apply_accessible_theme()
graphics::par(mfrow = c(1, 4))
for (v in iri_vars[1:4]) {
  v_label <- c("Fantasy", "Empathic Concern", "Perspective Taking", "Personal Distress")[which(iri_vars == v)]
  if (v %in% names(analysis_data_bivar)) {
    x_values <- analysis_data_bivar[[v]]
    y_values <- analysis_data_bivar$judgement
    plot(
      x_values,
      y_values,
      pch = 16,
      col = grDevices::adjustcolor(style$primary, alpha.f = 0.55),
      main = "",
      xlab = v_label,
      ylab = "Mean Judgment",
      ylim = judgment_axis_limits
    )
    graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1.5)
    try(draw_lm_fit_with_confidence_band(x_values, y_values, line_color = style$primary_dark), silent = TRUE)
  }
}
graphics::par(mfrow = c(1, 1))
dev.off()

case_configuration_levels <- get_case_configuration_levels(include_control = TRUE)
case_panel_titles <- vapply(case_configuration_levels, function(case_val) {
  sprintf("%s", case_val)
}, character(1))

# Plot: Figure 04-style severity panels by explicit case configuration (Victim)
draw_distribution_panel_figure(
  file.path(paths$figures_dir, figure_victim_case_panels_file),
  panel_values = lapply(case_configuration_levels, function(case_val) {
    judgments_victim$judgement[judgments_victim$case_configuration == case_val]
  }),
  panel_titles = case_panel_titles,
  figure_title = "Victim subset: judgment distributions across the six explicit victim x negotiator case configurations",
  layout = c(2, 3),
  width = 12,
  height = 8
)

# Plot: Figure 04-style severity panels by explicit case configuration (Bystander)
draw_distribution_panel_figure(
  file.path(paths$figures_dir, figure_bystander_case_panels_file),
  panel_values = lapply(case_configuration_levels, function(case_val) {
    judgments_bystander$judgement[judgments_bystander$case_configuration == case_val]
  }),
  panel_titles = case_panel_titles,
  figure_title = "Bystander subset: judgment distributions across the six explicit victim x negotiator case configurations",
  layout = c(2, 3),
  width = 12,
  height = 8
)

# Plot: Six-panel severity histograms when the harmful deal is accepted
draw_distribution_panel_figure(
  file.path(paths$figures_dir, figure_accepted_case_panels_file),
  panel_values = lapply(case_configuration_levels, function(case_val) {
    judgments_analysis$judgement[
      judgments_analysis$case_configuration == case_val &
        judgments_analysis$decision_accept == 1
    ]
  }),
  panel_titles = case_panel_titles,
  figure_title = "Agreement judgments across the six explicit victim x negotiator case configurations",
  layout = c(2, 3),
  width = 12,
  height = 8
)

# Plot: Six-panel severity histograms when the harmful deal is rejected
draw_distribution_panel_figure(
  file.path(paths$figures_dir, figure_rejected_case_panels_file),
  panel_values = lapply(case_configuration_levels, function(case_val) {
    judgments_analysis$judgement[
      judgments_analysis$case_configuration == case_val &
        judgments_analysis$decision_accept == 0
    ]
  }),
  panel_titles = case_panel_titles,
  figure_title = "Disagreement judgments across the six explicit victim x negotiator case configurations",
  layout = c(2, 3),
  width = 12,
  height = 8
)
