source("R/00_config.R")
source("R/utils/case_configuration_functions.R")

paths <- get_project_paths()

df <- read.csv(
  file.path(paths$root, "data", "processed", "03_transformed_participants.csv"),
  stringsAsFactors = FALSE
)

decode_negotiator_group_label <- function(x) {
  x_num <- suppressWarnings(as.integer(x))
  ifelse(
    is.na(x_num),
    NA_character_,
    ifelse(
      x_num == 1L,
      "Ingroup",
      ifelse(x_num == 2L, "Outgroup", ifelse(x_num == 0L, "Control", NA_character_))
    )
  )
}

decode_relative_group_code <- function(x) {
  x_num <- suppressWarnings(as.integer(x))
  ifelse(
    is.na(x_num),
    NA_character_,
    ifelse(
      x_num == 1L,
      "In",
      ifelse(x_num == 2L, "Out", ifelse(x_num == 0L, "Cont", NA_character_))
    )
  )
}

decode_observer_victim_group <- function(x) {
  x_num <- suppressWarnings(as.integer(x))
  ifelse(
    is.na(x_num),
    NA_character_,
    ifelse(x_num == 1L, "In", ifelse(x_num == 2L, "Out", NA_character_))
  )
}

normalize_faculty_code <- function(x) {
  x_num <- suppressWarnings(as.integer(x))
  ifelse(
    is.na(x_num),
    NA_integer_,
    ifelse(x_num == 0L, 3L, x_num)
  )
}

relative_group_to_alignment <- function(x) {
  ifelse(
    is.na(x),
    NA_character_,
    ifelse(
      x == "In",
      "ingroup",
      ifelse(x == "Out", "outgroup", ifelse(x == "Cont", "control", NA_character_))
    )
  )
}

safe_row_mean <- function(df_subset) {
  if (ncol(df_subset) == 0L) {
    return(rep(NA_real_, nrow(df_subset)))
  }
  row_sums <- rowSums(df_subset, na.rm = TRUE)
  non_missing <- rowSums(!is.na(df_subset))
  ifelse(non_missing > 0L, row_sums / non_missing, NA_real_)
}

df$role_observer <- ifelse(suppressWarnings(as.integer(df$role)) == 0L, 1L, 0L)
df$role <- ifelse(df$role_observer == 1L, "observer", "victim")
df$analysis_include <- TRUE

df$participant_faculty <- suppressWarnings(as.integer(df$faculty_player))
df$participant_engineering <- as.integer(df$participant_faculty == 2L)
df$sex <- ifelse(df$sex_female == 1L, 1L, 2L)
df$sex_man <- as.integer(df$sex_female == 0L)
df$economic_status <- df$ses
df$iri_total <- safe_row_mean(df[, c("iri_fs", "iri_ec", "iri_pt", "iri_pd"), drop = FALSE])

df$negotiator_slot <- suppressWarnings(as.integer(df$target))

df$group_target_num <- suppressWarnings(as.integer(df$group_target))
df$group_other_num <- suppressWarnings(as.integer(df$group_other))
df$obs_group_num <- suppressWarnings(as.integer(df$obs_group))

df$group_target <- decode_negotiator_group_label(df$group_target_num)
df$group_other <- decode_negotiator_group_label(df$group_other_num)
df$obs_group <- ifelse(
  is.na(df$obs_group_num),
  NA_character_,
  ifelse(df$obs_group_num == 1L, "Ingroup", ifelse(df$obs_group_num == 2L, "Outgroup", NA_character_))
)

df$group_negotiator_judged <- decode_relative_group_code(df$group_target_num)
df$group_negotiator_counterpart <- decode_relative_group_code(df$group_other_num)
df$group_victim <- ifelse(
  df$role_observer == 1L,
  decode_observer_victim_group(df$obs_group_num),
  NA_character_
)

df$group_negotiator1 <- ifelse(
  df$negotiator_slot == 1L,
  df$group_negotiator_judged,
  df$group_negotiator_counterpart
)
df$group_negotiator2 <- ifelse(
  df$negotiator_slot == 1L,
  df$group_negotiator_counterpart,
  df$group_negotiator_judged
)

df$negotiator_alignment <- relative_group_to_alignment(df$group_negotiator_judged)
df$counterpart_alignment <- relative_group_to_alignment(df$group_negotiator_counterpart)

df$faculty_target_norm <- normalize_faculty_code(df$faculty_target)
df$faculty_other_norm <- normalize_faculty_code(df$faculty_other)
df$faculty_negotiator1 <- ifelse(
  df$negotiator_slot == 1L,
  df$faculty_target_norm,
  df$faculty_other_norm
)
df$faculty_negotiator2 <- ifelse(
  df$negotiator_slot == 1L,
  df$faculty_other_norm,
  df$faculty_target_norm
)
df$faculty_negotiator <- ifelse(
  df$negotiator_slot == 1L,
  df$faculty_negotiator1,
  df$faculty_negotiator2
)
df$faculty_counterpart_negotiator <- ifelse(
  df$negotiator_slot == 1L,
  df$faculty_negotiator2,
  df$faculty_negotiator1
)
df$faculty_victim <- ifelse(
  df$role_observer == 1L,
  normalize_faculty_code(df$faculty_victim),
  df$participant_faculty
)

df$decision_target <- suppressWarnings(as.integer(df$decision_target))
df$decision_other <- suppressWarnings(as.integer(df$decision_other))
df$decision_accept <- ifelse(
  df$negotiator_slot == 1L,
  df$decision_target,
  df$decision_other
)
df$counterpart_decision_accept <- ifelse(
  df$negotiator_slot == 1L,
  df$decision_other,
  df$decision_target
)

df$judged_ingroup <- as.integer(df$group_negotiator_judged == "In")
df$judged_outgroup <- as.integer(df$group_negotiator_judged == "Out")
df$judged_control <- as.integer(df$group_negotiator_judged == "Cont")
df$counterpart_ingroup <- as.integer(df$group_negotiator_counterpart == "In")
df$counterpart_outgroup <- as.integer(df$group_negotiator_counterpart == "Out")
df$counterpart_control <- as.integer(df$group_negotiator_counterpart == "Cont")
df$observer_victim_outgroup <- ifelse(
  df$role_observer == 1L & df$group_victim == "Out",
  1L,
  ifelse(df$role_observer == 1L & df$group_victim == "In", 0L, NA_integer_)
)

df$negotiator1_outgroup <- as.integer(df$group_negotiator1 == "Out")
df$negotiator1_control <- as.integer(df$group_negotiator1 == "Cont")
df$negotiator2_outgroup <- as.integer(df$group_negotiator2 == "Out")
df$negotiator2_control <- as.integer(df$group_negotiator2 == "Cont")

df$perp_outgroup <- df$judged_outgroup
df$perp_control <- df$judged_control
df$victim_outgroup <- ifelse(is.na(df$observer_victim_outgroup), 0L, df$observer_victim_outgroup)
df$same_group_harm <- ifelse(
  df$role_observer == 1L,
  as.integer(df$group_negotiator_judged == df$group_victim),
  as.integer(df$group_negotiator_judged == "In")
)

df$case_configuration <- build_case_configuration(df$faculty_victim, df$faculty_negotiator)
df <- add_case_configuration_columns(
  df,
  victim_col = "faculty_victim",
  negotiator_col = "faculty_negotiator",
  role_col = "role",
  decision_col = "decision_accept"
)

df$analytic_case_configuration <- build_analytic_case_configuration(
  role = df$role,
  judged_group = df$group_negotiator_judged,
  counterpart_group = df$group_negotiator_counterpart,
  victim_group = df$group_victim
)
df <- add_analytic_case_configuration_columns(
  df,
  config_col = "analytic_case_configuration",
  decision_col = "decision_accept"
)
df <- add_h2_relational_structure_columns(
  df,
  judged_col = "group_negotiator_judged",
  counterpart_col = "group_negotiator_counterpart",
  victim_col = "group_victim",
  role_col = "role"
)

df$scenario_has_control <- as.integer(
  df$group_negotiator1 == "Cont" |
    df$group_negotiator2 == "Cont"
)
df$condemnation <- -df$judgement

drop_cols <- c("group_target_num", "group_other_num", "obs_group_num", "faculty_target_norm", "faculty_other_norm")
df <- df[, setdiff(names(df), drop_cols), drop = FALSE]

judgments_analysis <- df
judgments_victim <- judgments_analysis[judgments_analysis$role == "victim", , drop = FALSE]
judgments_bystander <- judgments_analysis[judgments_analysis$role == "observer", , drop = FALSE]

write.csv(judgments_analysis, paths$processed_judgments, row.names = FALSE, na = "")
write.csv(judgments_victim, paths$processed_victim, row.names = FALSE, na = "")
write.csv(judgments_bystander, paths$processed_bystander, row.names = FALSE, na = "")

message(sprintf(
  "Files generated successfully: %s total rows, %s victim rows, %s bystander rows.",
  nrow(judgments_analysis),
  nrow(judgments_victim),
  nrow(judgments_bystander)
))
