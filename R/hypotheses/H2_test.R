# R/hypotheses/H2_test.R
# Hypothesis 2: Negotiator-side relational structure
# Statement: Moral judgments vary with the joint ingroup/outgroup/control
# structure of the judged negotiator and the counterpart negotiator. In the
# bystander subset, that judgment-level structure also interacts with the
# player-victim ingroup/outgroup relation.
# Dependent Variable: judgement (-9 to 9) at the judgment-by-negotiator level
# Unit note: each participant evaluates two negotiators per scenario, so each
# vignette contributes two judgment observations.
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H2", paths = paths)

message("Testing H2: Negotiator-side relational structure separately for Victim and Bystander subsets (Models A and B)")

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

# ---- Victim Subset ----
message("--- Running H2 on Victim Subset ---")
run_estimation_suite(
  judgments_victim,
  get_hypothesis_formula_rhs(spec, "A", "Victim"),
  "H2_A_Victim",
  "H2_A_Victim_Total",
  paths$models_dir
)
run_estimation_suite(
  judgments_victim,
  get_hypothesis_formula_rhs(spec, "B", "Victim"),
  "H2_B_Victim",
  "H2_B_Victim_Constructs",
  paths$models_dir
)

# ---- Bystander Subset ----
message("--- Running H2 on Bystander Subset ---")
run_estimation_suite(
  judgments_bystander,
  get_hypothesis_formula_rhs(spec, "A", "Bystander"),
  "H2_A_Bystander",
  "H2_A_Bystander_Total",
  paths$models_dir
)
run_estimation_suite(
  judgments_bystander,
  get_hypothesis_formula_rhs(spec, "B", "Bystander"),
  "H2_B_Bystander",
  "H2_B_Bystander_Constructs",
  paths$models_dir
)

message("H2 test completed for both subsets. Outputs saved to models/.")
