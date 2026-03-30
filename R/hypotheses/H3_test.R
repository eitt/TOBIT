# R/hypotheses/H3_test.R
# Hypothesis 3: Empathy x judged-negotiator status moderation
# Statement: The empathy effect may vary according to whether the judged
# negotiator is ingroup, outgroup, or control, while decision outcome,
# judged-status x decision terms, the counterpart negotiator, and observer-side
# victim alignment remain in the model.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: empathy x judged-negotiator status interactions
# Controls: main effects for empathy, judged-negotiator status, decision_accept,
# judged-status x decision_accept, counterpart relational terms,
# observer_victim_outgroup, role_observer, participant_engineering, sex_man,
# age, economic_status, slot
# Sample: Full judgment sample
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H3", paths = paths)

message("Testing H3: Empathy x judged-status moderation with decision context retained (Models A and B)")

judgments_analysis <- read.csv(spec$data_path, stringsAsFactors = FALSE)

# Model A
run_estimation_suite(judgments_analysis, spec$formula_rhs$A, "H3_A", "H3_A_Total", paths$models_dir)

# Model B
run_estimation_suite(judgments_analysis, spec$formula_rhs$B, "H3_B", "H3_B_Constructs", paths$models_dir)

message("H3 test completed. Outputs saved to models/.")
