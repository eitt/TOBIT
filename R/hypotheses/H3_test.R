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
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H3", paths = paths)

message("Testing H3: Empathy x judged-status moderation with decision context retained (Models A and B)")

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# ---- Victim Subset ----
message("--- Running H3 on Victim Subset ---")
# Model A
run_estimation_suite(
  judgments_victim,
  get_hypothesis_formula_rhs(spec, "A", "Victim"),
  "H3_A_Victim",
  "H3_A_Victim_Total",
  paths$models_dir
)

# Model B
run_estimation_suite(
  judgments_victim,
  get_hypothesis_formula_rhs(spec, "B", "Victim"),
  "H3_B_Victim",
  "H3_B_Victim_Constructs",
  paths$models_dir
)


# ---- Bystander Subset ----
message("--- Running H3 on Bystander Subset ---")
# Model A
run_estimation_suite(
  judgments_bystander,
  get_hypothesis_formula_rhs(spec, "A", "Bystander"),
  "H3_A_Bystander",
  "H3_A_Bystander_Total",
  paths$models_dir
)

# Model B
run_estimation_suite(
  judgments_bystander,
  get_hypothesis_formula_rhs(spec, "B", "Bystander"),
  "H3_B_Bystander",
  "H3_B_Bystander_Constructs",
  paths$models_dir
)

message("H3 test completed for both subsets. Outputs saved to models/.")
