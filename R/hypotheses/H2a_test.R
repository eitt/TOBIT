# R/hypotheses/H2a_test.R
# Hypothesis 2a: Judged-negotiator status x decision contrasts without control
# Statement: Moral judgments should differ as a function of the judged
# negotiator's ingroup versus outgroup status, and that relational contrast
# should vary across Accept versus Reject decisions after controlling for the
# counterpart negotiator and observer-side victim alignment.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: judged-negotiator outgroup status, decision_accept,
# and judged-status x decision_accept in the non-control sample
# Controls: iri_total or empathy subscales, counterpart_outgroup,
# observer_victim_outgroup, role_observer, participant_engineering, sex_man,
# age, economic_status, slot
# Sample: Full judgment sample excluding scenarios with any control-labeled
# negotiator
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H2a", paths = paths)

message("Testing H2a: Judged-status x decision contrasts without control scenarios (Models A and B)")

judgments_betrayal <- read.csv(spec$data_path, stringsAsFactors = FALSE)

# Model A
run_estimation_suite(judgments_betrayal, spec$formula_rhs$A, "H2a_A", "H2a_A_Total", paths$models_dir)

# Model B
run_estimation_suite(judgments_betrayal, spec$formula_rhs$B, "H2a_B", "H2a_B_Constructs", paths$models_dir)

message("H2a test completed. Outputs saved to models/.")
