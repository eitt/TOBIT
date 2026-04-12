# R/hypotheses/H3_test.R
# Hypothesis 3: Empathy x relational-status moderation
# Statement: Empathy slopes may vary across role-specific N1/N2 relational
# status terms. Victim and bystander subsets retain their own relational blocks,
# and empathy interactions are added for prioritized N1/N2 contrasts.
# Dependent Variable: judgement (-9 to 9)
# Independent Variables: empathy x role-specific N1/N2 relational interactions
# Controls: main effects for empathy, role-specific relational terms,
# N1_N2_same_faculty, participant_engineering, sex_man, age, and economic_status
# Sample: Full role-specific samples
# Subset-specific formulas are resolved from hypothesis metadata.
# Specification: Primary mixed-effects estimation with mandatory participant
# random intercept (1 | id); id_case random intercept is added when identifiable.

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H3", paths = paths)

active_model_suffixes <- resolve_active_model_suffixes()
model_label_suffix <- list(
  A = "Total",
  B = "Constructs"
)

message(sprintf(
  "Testing H3: Empathy x role-specific relational-status moderation (active model suffixes: %s)",
  paste(active_model_suffixes, collapse = ", ")
))

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# ---- Victim Subset ----
message("--- Running H3 on Victim Subset ---")
for (model_suffix in active_model_suffixes) {
  run_estimation_suite(
    judgments_victim,
    get_hypothesis_formula_rhs(spec, model_suffix, "Victim"),
    sprintf("H3_%s_Victim", model_suffix),
    sprintf("H3_%s_Victim_%s", model_suffix, model_label_suffix[[model_suffix]]),
    paths$models_dir
  )
}


# ---- Bystander Subset ----
message("--- Running H3 on Bystander Subset ---")
for (model_suffix in active_model_suffixes) {
  run_estimation_suite(
    judgments_bystander,
    get_hypothesis_formula_rhs(spec, model_suffix, "Bystander"),
    sprintf("H3_%s_Bystander", model_suffix),
    sprintf("H3_%s_Bystander_%s", model_suffix, model_label_suffix[[model_suffix]]),
    paths$models_dir
  )
}

message("H3 test completed for both subsets. Outputs saved to models/.")
