# R/hypotheses/H2_test.R
# Hypothesis 2: Negotiator-side relational structure
# Statement: Moral judgments vary with the joint ingroup/outgroup/control
# structure of the judged negotiator and the counterpart negotiator. In the
# bystander subset, that judgment-level structure also interacts with the
# player-victim ingroup/outgroup relation.
# Dependent Variable: judgement (-9 to 9) at the judgment-by-negotiator level
# Unit note: each participant evaluates two negotiators per scenario, so each
# vignette contributes two judgment observations.
# Specification: Interval-censored clustered Tobit model in the active
# workflow; archived non-parametric utilities remain available but are not run

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
