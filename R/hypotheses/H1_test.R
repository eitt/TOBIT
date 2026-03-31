# R/hypotheses/H1_test.R
# Hypothesis 1: Empathy Effect under relational controls
# Statement: Higher empathy predicts lower moral-judgment scores for harmful
# decisions after conditioning on judged-negotiator status, counterpart
# status, decision outcome, and observer-side victim alignment when applicable.
# Dependent Variable: judgement (-9 to 9)
# Empathy predictors: Model A uses iri_total; Model B uses iri_fs, iri_ec,
# iri_pt, and iri_pd in both victim and bystander subsets
# Relational predictors: judged_outgroup/judged_control,
# counterpart_outgroup/counterpart_control, decision_accept, and
# observer_victim_outgroup when applicable
# Additional controls: participant_engineering, sex_man, age,
# economic_status, and factor(negotiator_slot)
# Sample: Full role-specific samples (Victim and Bystander)
# Subset-specific formulas: observer-side victim alignment is retained only in
# the bystander subset so structurally fixed predictors are not carried into the
# victim-only models.
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H1", paths = paths)

message("Testing H1: Empathy effect under judged/counterpart relational controls (Models A and B)")

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# ---- Victim Subset ----
message("--- Running H1 on Victim Subset ---")
# Model A: Total Empathy
run_estimation_suite(
  judgments_victim,
  get_hypothesis_formula_rhs(spec, "A", "Victim"),
  "H1_A_Victim",
  "H1_A_Victim_Total",
  paths$models_dir
)

# Model B: Empathy Subscales
run_estimation_suite(
  judgments_victim,
  get_hypothesis_formula_rhs(spec, "B", "Victim"),
  "H1_B_Victim",
  "H1_B_Victim_Constructs",
  paths$models_dir
)


# ---- Bystander Subset ----
message("--- Running H1 on Bystander Subset ---")
# Model A: Total Empathy
run_estimation_suite(
  judgments_bystander,
  get_hypothesis_formula_rhs(spec, "A", "Bystander"),
  "H1_A_Bystander",
  "H1_A_Bystander_Total",
  paths$models_dir
)

# Model B: Empathy Subscales
run_estimation_suite(
  judgments_bystander,
  get_hypothesis_formula_rhs(spec, "B", "Bystander"),
  "H1_B_Bystander",
  "H1_B_Bystander_Constructs",
  paths$models_dir
)

message("H1 test completed for both subsets. Outputs saved to models/.")
