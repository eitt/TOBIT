source("R/00_config.R")
source("R/utils/figure_functions.R")

paths <- get_project_paths()
participants <- read.csv(paths$processed_participants, stringsAsFactors = FALSE)
judgments_analysis <- read.csv(paths$processed_judgments, stringsAsFactors = FALSE)
judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)
judgments_import <- read.csv(paths$processed_import, stringsAsFactors = FALSE)

participant_summary <- data.frame(
  metric = c(
    "participants",
    "sessions",
    "mean_age",
    "women_share",
    "engineering_share"
  ),
  value = c(
    nrow(participants),
    length(unique(judgments_analysis$session)),
    mean(participants$age, na.rm = TRUE),
    mean(participants$sex == 1, na.rm = TRUE),
    mean(participants$faculty_player == 2, na.rm = TRUE)
  ),
  stringsAsFactors = FALSE
)

judgement_summary <- data.frame(
  sample = c("All", "Victim", "Bystander"),
  rows = c(nrow(judgments_analysis), nrow(judgments_victim), nrow(judgments_bystander)),
  participants = c(
    length(unique(judgments_analysis$id)),
    length(unique(judgments_victim$id)),
    length(unique(judgments_bystander$id))
  ),
  mean_judgement = c(
    mean(judgments_analysis$judgement, na.rm = TRUE),
    mean(judgments_victim$judgement, na.rm = TRUE),
    mean(judgments_bystander$judgement, na.rm = TRUE)
  ),
  sd_judgement = c(
    stats::sd(judgments_analysis$judgement, na.rm = TRUE),
    stats::sd(judgments_victim$judgement, na.rm = TRUE),
    stats::sd(judgments_bystander$judgement, na.rm = TRUE)
  ),
  stringsAsFactors = FALSE
)

decision_summary <- aggregate(
  judgement ~ role_label + decision_pattern,
  data = judgments_analysis,
  FUN = function(x) c(n = length(x), mean = mean(x, na.rm = TRUE))
)
decision_summary <- do.call(data.frame, decision_summary)
names(decision_summary) <- c("role_label", "decision_pattern", "n", "mean_judgement")

group_summary <- data.frame(
  variable = c(
    rep("victim_N1_group", 2),
    rep("victim_N2_group", 2),
    rep("bystander_victim_group", 2),
    rep("bystander_N1_group", 2),
    rep("bystander_N2_group", 2),
    rep("N1_N2_same_faculty", 2)
  ),
  level = c(
    "ingroup", "outgroup",
    "ingroup", "outgroup",
    "ingroup", "outgroup",
    "ingroup", "outgroup",
    "ingroup", "outgroup",
    "different", "same"
  ),
  n = c(
    sum(judgments_analysis$victim_N1_group == "ingroup", na.rm = TRUE),
    sum(judgments_analysis$victim_N1_group == "outgroup", na.rm = TRUE),
    sum(judgments_analysis$victim_N2_group == "ingroup", na.rm = TRUE),
    sum(judgments_analysis$victim_N2_group == "outgroup", na.rm = TRUE),
    sum(judgments_analysis$bystander_victim_group == "ingroup", na.rm = TRUE),
    sum(judgments_analysis$bystander_victim_group == "outgroup", na.rm = TRUE),
    sum(judgments_analysis$bystander_N1_group == "ingroup", na.rm = TRUE),
    sum(judgments_analysis$bystander_N1_group == "outgroup", na.rm = TRUE),
    sum(judgments_analysis$bystander_N2_group == "ingroup", na.rm = TRUE),
    sum(judgments_analysis$bystander_N2_group == "outgroup", na.rm = TRUE),
    sum(judgments_analysis$N1_N2_same_faculty == "different", na.rm = TRUE),
    sum(judgments_analysis$N1_N2_same_faculty == "same", na.rm = TRUE)
  ),
  stringsAsFactors = FALSE
)

missingness_summary <- data.frame(
  variable = names(judgments_analysis),
  missing_n = vapply(judgments_analysis, function(x) sum(is.na(x)), numeric(1)),
  missing_pct = vapply(judgments_analysis, function(x) mean(is.na(x)), numeric(1)),
  stringsAsFactors = FALSE
)

observation_audit <- data.frame(
  checkpoint = c(
    "base_excel_rows",
    "processed_import_rows",
    "processed_judgment_rows",
    "unique_source_row_numbers",
    "duplicated_source_row_numbers"
  ),
  value = c(
    nrow(judgments_import),
    nrow(judgments_import),
    nrow(judgments_analysis),
    length(unique(judgments_analysis$source_row_number)),
    sum(duplicated(judgments_analysis$source_row_number))
  ),
  stringsAsFactors = FALSE
)

participant_mean_judgement <- aggregate(
  judgement ~ id,
  data = judgments_analysis,
  FUN = function(x) mean(x, na.rm = TRUE)
)
participant_mean_judgement <- merge(
  participants,
  participant_mean_judgement,
  by = "id",
  all.x = TRUE
)

correlation_inputs <- participant_mean_judgement[
  ,
  c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "judgement"),
  drop = FALSE
]
correlation_table <- stats::cor(
  correlation_inputs,
  use = "pairwise.complete.obs"
)
correlation_table <- data.frame(
  term = rownames(correlation_table),
  correlation_table,
  row.names = NULL,
  check.names = FALSE,
  stringsAsFactors = FALSE
)

write.csv(participant_summary, file.path(paths$tables_dir, "participant_summary.csv"), row.names = FALSE)
write.csv(judgement_summary, file.path(paths$tables_dir, "judgement_summary.csv"), row.names = FALSE)
write.csv(decision_summary, file.path(paths$tables_dir, "decision_summary.csv"), row.names = FALSE)
write.csv(group_summary, file.path(paths$tables_dir, "group_summary.csv"), row.names = FALSE)
write.csv(missingness_summary, file.path(paths$tables_dir, "missingness_summary.csv"), row.names = FALSE)
write.csv(observation_audit, file.path(paths$tables_dir, "observation_audit.csv"), row.names = FALSE)
write.csv(correlation_table, file.path(paths$tables_dir, "participant_empathy_judgement_correlation.csv"), row.names = FALSE)

write.csv(participant_summary, file.path(paths$eda_dir, "participant_summary.csv"), row.names = FALSE)
write.csv(judgement_summary, file.path(paths$eda_dir, "judgement_summary.csv"), row.names = FALSE)
write.csv(decision_summary, file.path(paths$eda_dir, "decision_summary.csv"), row.names = FALSE)
write.csv(group_summary, file.path(paths$eda_dir, "group_summary.csv"), row.names = FALSE)
write.csv(missingness_summary, file.path(paths$eda_dir, "missingness_summary.csv"), row.names = FALSE)
write.csv(observation_audit, file.path(paths$eda_dir, "observation_audit.csv"), row.names = FALSE)
write.csv(correlation_table, file.path(paths$eda_dir, "participant_empathy_judgement_correlation.csv"), row.names = FALSE)

open_accessible_png(
  file.path(paths$figures_dir, "figure_iri_subscale_radar.png"),
  width = 7.5,
  height = 7
)
apply_accessible_theme()
draw_base_radar_plot(
  values = c(
    mean(participants$iri_fs, na.rm = TRUE),
    mean(participants$iri_ec, na.rm = TRUE),
    mean(participants$iri_pt, na.rm = TRUE),
    mean(participants$iri_pd, na.rm = TRUE)
  ),
  labels = c("Fantasy", "Empathic concern", "Perspective taking", "Personal distress"),
  max_scale = max(
    c(
      participants$iri_fs,
      participants$iri_ec,
      participants$iri_pt,
      participants$iri_pd
    ),
    na.rm = TRUE
  ),
  min_scale = min(
    c(
      participants$iri_fs,
      participants$iri_ec,
      participants$iri_pt,
      participants$iri_pd
    ),
    na.rm = TRUE
  ),
  title = "Mean IRI subscale profile"
)
dev.off()

open_accessible_png(
  file.path(paths$figures_dir, "figure_bivariate_empathy_vs_mean_judgement.png"),
  width = 11.5,
  height = 8.5
)
apply_accessible_theme()
graphics::par(mfrow = c(2, 2), mar = c(5, 5, 3.5, 1.5), bty = "l")

scatter_specs <- list(
  list(var = "iri_fs", title = "Fantasy vs mean judgement"),
  list(var = "iri_ec", title = "Empathic concern vs mean judgement"),
  list(var = "iri_pt", title = "Perspective taking vs mean judgement"),
  list(var = "iri_pd", title = "Personal distress vs mean judgement")
)

for (spec in scatter_specs) {
  x_values <- participant_mean_judgement[[spec$var]]
  y_values <- participant_mean_judgement$judgement
  graphics::plot(
    x_values,
    y_values,
    pch = 19,
    col = grDevices::adjustcolor(get_plot_style()$primary, alpha.f = 0.55),
    main = wrap_title(spec$title, width = 28),
    xlab = gsub("iri_", "IRI ", spec$var),
    ylab = "Participant mean judgement",
    ylim = get_judgment_observed_bounds()
  )
  graphics::abline(h = 0, col = get_plot_style()$grid, lty = 3, lwd = 1)
  draw_lm_fit_with_confidence_band(
    x_values,
    y_values,
    line_color = get_plot_style()$primary_dark
  )
}
dev.off()

png(file.path(paths$figures_dir, "figure_judgement_distribution_by_role.png"), width = 1400, height = 700)
par(mfrow = c(1, 2))
hist(
  judgments_victim$judgement,
  main = "Victim judgments",
  xlab = "judgement",
  col = "#7aa6c2",
  border = "#2f4f4f"
)
hist(
  judgments_bystander$judgement,
  main = "Bystander judgments",
  xlab = "judgement",
  col = "#e3a857",
  border = "#5c4033"
)
dev.off()

decision_plot_table <- xtabs(~ role_label + decision_pattern, data = judgments_analysis)
png(file.path(paths$figures_dir, "figure_decision_pattern_by_role.png"), width = 1200, height = 700)
barplot(
  t(decision_plot_table),
  beside = TRUE,
  legend.text = TRUE,
  col = c("#56799c", "#8fbc8f"),
  main = "Decision patterns by role",
  ylab = "Number of judgments"
)
dev.off()

message("Descriptive summaries and EDA figures written to outputs/tables, outputs/figures, and outputs/data/02_eda.")
