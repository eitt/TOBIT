# R/hypotheses/H2_test.R
# Hypothesis 2: Relational N1/N2 structure by role
# Statement: Moral judgments vary with explicit role-specific N1/N2 relational
# blocks. Victim models include victim_N1_group * victim_N2_group; bystander
# models include bystander_victim_group plus selective
# bystander_N1_group * bystander_N2_group and victim_N1_group * victim_N2_group
# interactions, with N1_N2_same_faculty as a contextual main effect.
# Dependent Variable: judgement (-9 to 9) at the judgment-by-negotiator level
# Unit note: each participant evaluates two negotiators per scenario, so each
# vignette contributes two judgment observations.
# Specification: Primary mixed-effects estimation with mandatory participant
# random intercept (1 | id); id_case random intercept is added when identifiable.

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H2", paths = paths)

active_model_suffixes <- resolve_active_model_suffixes()
model_label_suffix <- list(
  A = "Total",
  B = "Constructs"
)

message(sprintf(
  "Testing H2: Negotiator-side relational structure separately for Victim and Bystander subsets (active model suffixes: %s)",
  paste(active_model_suffixes, collapse = ", ")
))

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# ---- Victim Subset ----
message("--- Running H2 on Victim Subset ---")
for (model_suffix in active_model_suffixes) {
  run_estimation_suite(
    judgments_victim,
    get_hypothesis_formula_rhs(spec, model_suffix, "Victim"),
    sprintf("H2_%s_Victim", model_suffix),
    sprintf("H2_%s_Victim_%s", model_suffix, model_label_suffix[[model_suffix]]),
    paths$models_dir
  )
}

# ---- Bystander Subset ----
message("--- Running H2 on Bystander Subset ---")
for (model_suffix in active_model_suffixes) {
  run_estimation_suite(
    judgments_bystander,
    get_hypothesis_formula_rhs(spec, model_suffix, "Bystander"),
    sprintf("H2_%s_Bystander", model_suffix),
    sprintf("H2_%s_Bystander_%s", model_suffix, model_label_suffix[[model_suffix]]),
    paths$models_dir
  )
}

message("H2 test completed for both subsets. Outputs saved to models/.")
