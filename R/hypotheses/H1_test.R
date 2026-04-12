# R/hypotheses/H1_test.R
# Hypothesis 1: Empathy effect under role-specific relational controls
# Statement: Empathy dimensions are associated with moral-judgment severity
# after conditioning on role-specific N1/N2 relational predictors and the
# N1_N2_same_faculty contextual term.
# Dependent Variable: judgement (-9 to 9)
# Empathy predictors: Active workflow uses iri_fs, iri_ec, iri_pt, and iri_pd
# in both victim and bystander subsets
# Relational predictors: victim_N1_group, victim_N2_group, and
# N1_N2_same_faculty in Victim; bystander_victim_group, bystander_N1_group,
# bystander_N2_group, victim_N1_group, victim_N2_group, and N1_N2_same_faculty
# in Bystander
# Additional controls: participant_engineering, sex_man, age,
# economic_status
# Sample: Full role-specific samples (Victim and Bystander)
# Subset-specific formulas are resolved from hypothesis metadata.
# Specification: Primary mixed-effects estimation with mandatory participant
# random intercept (1 | id); id_case random intercept is added when identifiable.

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H1", paths = paths)

active_model_suffixes <- resolve_active_model_suffixes()
model_label_suffix <- list(
  A = "Total",
  B = "Constructs"
)

message(sprintf(
  "Testing H1: Empathy effect under role-specific N1/N2 relational controls (active model suffixes: %s)",
  paste(active_model_suffixes, collapse = ", ")
))

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# ---- Victim Subset ----
message("--- Running H1 on Victim Subset ---")
for (model_suffix in active_model_suffixes) {
  run_estimation_suite(
    judgments_victim,
    get_hypothesis_formula_rhs(spec, model_suffix, "Victim"),
    sprintf("H1_%s_Victim", model_suffix),
    sprintf("H1_%s_Victim_%s", model_suffix, model_label_suffix[[model_suffix]]),
    paths$models_dir
  )
}


# ---- Bystander Subset ----
message("--- Running H1 on Bystander Subset ---")
for (model_suffix in active_model_suffixes) {
  run_estimation_suite(
    judgments_bystander,
    get_hypothesis_formula_rhs(spec, model_suffix, "Bystander"),
    sprintf("H1_%s_Bystander", model_suffix),
    sprintf("H1_%s_Bystander_%s", model_suffix, model_label_suffix[[model_suffix]]),
    paths$models_dir
  )
}

message("H1 test completed for both subsets. Outputs saved to models/.")
