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
paths <- get_project_paths()

participants <- read.csv(paths$processed_participants, stringsAsFactors = FALSE)
judgments_analysis <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

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
  Metric = c("Judgments in analysis sample", "Harmful decisions in primary model sample",
             "Acceptance rate", "Left-censored share at -9", "Right-censored share at 9"),
  Value = c(nrow(judgments_analysis), nrow(judgments_accept),
            mean(judgments_analysis$decision_accept, na.rm = TRUE),
            mean(judgments_accept$judgement == -9, na.rm = TRUE),
            mean(judgments_accept$judgement == 9, na.rm = TRUE))
)
write.csv(judgement_summary, file.path(paths$tables_dir, "judgement_summary.csv"), row.names = FALSE)

# Generate Figures
style <- get_plot_style()

# Age distribution
open_accessible_png(file.path(paths$figures_dir, "figure_01_age.png"))
apply_accessible_theme()
hist(analysis_participants$age, breaks = pretty(analysis_participants$age, n=8), 
     col = style$primary_light, border = style$primary_dark, main = "Age distribution", xlab = "Age (years)")
dev.off()

# Empathy distribution
open_accessible_png(file.path(paths$figures_dir, "figure_02_empathy.png"))
apply_accessible_theme()
hist(analysis_participants$iri_total, breaks = pretty(analysis_participants$iri_total, n=8), 
     col = style$primary_light, border = style$primary_dark, main = "Empathy composite distribution", xlab = "IRI composite")
dev.off()

# Empathy Radar Plot
open_accessible_png(file.path(paths$figures_dir, "figure_03_empathy_radar.png"))
apply_accessible_theme()
iri_means <- c(safe_mean(analysis_participants$iri_fs), safe_mean(analysis_participants$iri_ec), 
               safe_mean(analysis_participants$iri_pt), safe_mean(analysis_participants$iri_pd))
iri_labels <- c("FS", "EC", "PT", "PD")
iri_legend <- c("FS: Fantasy", "EC: Empathic concern", "PT: Perspective taking", "PD: Personal distress")
draw_base_radar_plot(values = iri_means, labels = iri_labels, max_scale = 5, min_scale = 1, 
                     title = "IRI Latent Variable Averages", legend_text = iri_legend)
dev.off()

# Severity by Condition Sub-Panels (H1-H3 contexts)
open_accessible_png(file.path(paths$figures_dir, "figure_04_severity_panels.png"), width = 10, height = 5)
apply_accessible_theme()
graphics::par(mfrow = c(1, 2))

ingroup_judg <- judgments_accept$judgement[!is.na(judgments_accept$perp_outgroup) & judgments_accept$perp_outgroup == 0]
outgroup_judg <- judgments_accept$judgement[!is.na(judgments_accept$perp_outgroup) & judgments_accept$perp_outgroup == 1]
max_freq <- max(table(cut(ingroup_judg, breaks=10)), table(cut(outgroup_judg, breaks=10))) * 1.5

hist(ingroup_judg, breaks = pretty(judgments_accept$judgement, n=10), 
     col = grDevices::adjustcolor(style$primary_light, alpha.f=0.7), border = style$primary_dark, 
     main = "Ingroup Perpetrator", xlab = "Judgment Severity", ylim = c(0, max_freq))

hist(outgroup_judg, breaks = pretty(judgments_accept$judgement, n=10), 
     col = grDevices::adjustcolor(style$primary_dark, alpha.f=0.7), border = style$primary, 
     main = "Outgroup Perpetrator", xlab = "Judgment Severity", ylim = c(0, max_freq))

graphics::par(mfrow = c(1, 1))
dev.off()

# Bi-variate Statistics (Correlations)
iri_vars <- c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "iri_total")
# Aggregated judgment mean per participant for correlation
part_judg_means <- aggregate(judgement ~ id, data = judgments_accept, FUN = mean, na.rm = TRUE)
analysis_data_bivar <- merge(analysis_participants[, c("id", iri_vars)], part_judg_means, by = "id")

# Create correlation matrix
bivar_cor <- cor(analysis_data_bivar[, c(iri_vars, "judgement")], use = "complete.obs")
# Label terms for the table
rownames(bivar_cor) <- colnames(bivar_cor) <- c("Fantasy", "Empathic Concern", "Perspective Taking", "Personal Distress", "Total IRI", "Mean Judgment")

# Save bi-variate table
write.csv(bivar_cor, file.path(paths$tables_dir, "bivariate_correlations.csv"))

# Optional: Simple scatter for Bivariate section
open_accessible_png(file.path(paths$figures_dir, "figure_05_bivariate_scatters.png"), width = 10, height = 4)
graphics::par(mfrow = c(1, 4))
for (v in iri_vars[1:4]) {
  v_label <- c("Fantasy", "Empathic Concern", "Perspective Taking", "Personal Distress")[which(iri_vars == v)]
  plot(analysis_data_bivar[[v]], analysis_data_bivar$judgement, 
       pch = 16, col = style$primary, alpha=0.5,
       main = v_label, xlab = "Scale Value", ylab = "Mean Judgment")
  graphics::abline(stats::lm(judgement ~ analysis_data_bivar[[v]], data = analysis_data_bivar), col = "red", lwd = 2)
}
graphics::par(mfrow = c(1, 1))
dev.off()
