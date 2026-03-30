# R/hypotheses/H1_test.R
# Hypothesis 1: Empathy Effect under relational controls
# Statement: Higher empathy predicts lower moral-judgment scores for harmful
# decisions after conditioning on the judged negotiator, the counterpart
# negotiator, and observer-side victim alignment.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: iri_total (empathy composite average) or empathy
# subscales
# Relational controls: judged-negotiator status, counterpart-negotiator status,
# and observer-side victim alignment
# Additional controls: role_observer, participant_engineering, sex_man, age,
# economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H1", paths = paths)

message("Testing H1: Empathy effect under judged/counterpart relational controls (Models A and B)")

judgments_accept <- read.csv(spec$data_path, stringsAsFactors = FALSE)

# Model A: Total Empathy
run_estimation_suite(judgments_accept, spec$formula_rhs$A, "H1_A", "H1_A_Total", paths$models_dir)

# Model B: Empathy Subscales
run_estimation_suite(judgments_accept, spec$formula_rhs$B, "H1_B", "H1_B_Constructs", paths$models_dir)

message("H1 test completed. Outputs saved to models/.")
