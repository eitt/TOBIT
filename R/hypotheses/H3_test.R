# R/hypotheses/H3_test.R
# Hypothesis 3: Empathy x judged-negotiator status moderation
# Statement: The empathy effect may vary according to whether the judged
# negotiator is ingroup, outgroup, or control, while decision outcome,
# judged-status x decision terms, the counterpart negotiator, and observer-side
# victim alignment remain in the model when they are meaningful for the
# subset-specific design.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: empathy x judged-negotiator status interactions
# Controls: main effects for empathy, judged-negotiator status, decision_accept,
# judged-status x decision_accept, counterpart relational terms,
# observer_victim_outgroup when applicable, participant_engineering, sex_man,
# age, economic_status, slot
# Sample: Full role-specific samples
# Subset-specific formulas: the victim subset excludes observer-only predictors
# so structurally fixed terms are not carried into victim-only estimation.
# Specification: Interval-censored clustered Tobit model in the active
# workflow; archived non-parametric utilities remain available but are not run

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
  "Testing H3: Empathy x judged-status moderation with decision context retained (active model suffixes: %s)",
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
