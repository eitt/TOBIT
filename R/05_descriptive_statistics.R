# R/05_descriptive_statistics.R
# Purpose: Generate sample summaries and EDA figures mapped to Version 2.0 Factors.
# Inputs: processed datasets
# Outputs: summary tables and figures
# Dependencies: 00_config.R, transform_functions.R, figure_functions.R, table_functions.R

source("R/00_config.R")
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
judgment_hist_breaks <- get_judgment_hist_breaks()

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
                                           figure_title, layout, width, height) {
  open_accessible_png(file_path, width = width, height = height)
  apply_accessible_theme()
  graphics::par(mfrow = layout, mar = c(4.8, 4.8, 3.2, 1.2), oma = c(0, 0, 3.0, 0))
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
                   xlab = "Judgment severity",
                   xlim = judgment_axis_limits, ylim = c(0, max_freq))
    graphics::abline(v = 0, col = style$grid, lty = 3, lwd = 1.5)
  }
  graphics::mtext(figure_title, outer = TRUE, cex = 1.1, font = 2)
  graphics::par(mfrow = c(1, 1), oma = c(0, 0, 0, 0))
  dev.off()
}

group_levels <- c("Ingroup", "Outgroup", "Control")

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
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("victim_case_panels")),
  panel_values = lapply(group_levels,
    function(g) judgments_victim$judgement[judgments_victim$group_target == g]),
  panel_titles = paste("N1:", group_levels),
  figure_title = "Victim subset — Judgment severity by N1 group",
  layout = c(1, 3), width = 10, height = 6
)

# Figure 06 — Bystander subset: severity by N1 group
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("bystander_case_panels")),
  panel_values = lapply(group_levels,
    function(g) judgments_bystander$judgement[judgments_bystander$group_target == g]),
  panel_titles = paste("N1:", group_levels),
  figure_title = "Bystander subset — Judgment severity by N1 group",
  layout = c(1, 3), width = 10, height = 6
)

# Figure 07 — Bystander subset: severity by observer-group alignment (obs_group)
obs_levels <- c("Ingroup", "Outgroup")
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("accepted_case_panels")),
  panel_values = lapply(obs_levels,
    function(g) judgments_bystander$judgement[judgments_bystander$obs_group == g]),
  panel_titles = paste("Observer-victim alignment:", obs_levels),
  figure_title = "Bystander subset — Judgment severity by observer-group alignment",
  layout = c(1, 2), width = 8, height = 6
)

# Figure 08 — Full sample: severity by N2 group (group_other)
draw_distribution_panel_figure(
  file.path(paths$figures_dir, get_standard_figure_filename("rejected_case_panels")),
  panel_values = lapply(group_levels,
    function(g) judgments_analysis$judgement[judgments_analysis$group_other == g]),
  panel_titles = paste("N2:", group_levels),
  figure_title = "Judgment severity by N2 group (full sample)",
  layout = c(1, 3), width = 10, height = 6
)

message("Descriptive statistics generated successfully.")

# Bi-variate Statistics (Correlations)
iri_vars <- c("iri_fs", "iri_ec", "iri_pt", "iri_pd")
part_judg_means <- aggregate(judgement ~ id, data = judgments_analysis, FUN = mean, na.rm = TRUE)
analysis_data_bivar <- merge(participants[, c("id", iri_vars)], part_judg_means, by = "id")
bivar_cor <- cor(analysis_data_bivar[, c(iri_vars, "judgement")], use = "complete.obs")
rownames(bivar_cor) <- colnames(bivar_cor) <-
  c("Fantasy", "Empathic Concern", "Perspective Taking", "Personal Distress", "Mean Judgment")
write.csv(bivar_cor, file.path(paths$tables_dir, "bivariate_correlations.csv"))
