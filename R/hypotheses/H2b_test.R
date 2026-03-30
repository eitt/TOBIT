# R/hypotheses/H2b_test.R
# Hypothesis 2b: Judged-negotiator status x decision contrasts with control
# Statement: Moral judgments should differ as a function of the judged
# negotiator's ingroup, outgroup, or control status, and that relational
# contrast should vary across Accept versus Reject decisions after controlling
# for the counterpart negotiator and observer-side victim alignment.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: judged-negotiator outgroup/control status,
# decision_accept, and judged-status x decision_accept
# Controls: iri_total or empathy subscales, counterpart_outgroup,
# counterpart_control, observer_victim_outgroup, role_observer,
# participant_engineering, sex_man, age, economic_status, slot
# Sample: Full judgment sample
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H2b", paths = paths)

message("Testing H2b: Judged-status x decision contrasts with control included (Models A and B)")

judgments_analysis <- read.csv(spec$data_path, stringsAsFactors = FALSE)

# Model A
run_estimation_suite(judgments_analysis, spec$formula_rhs$A, "H2b_A", "H2b_A_Total", paths$models_dir)

# Model B
run_estimation_suite(judgments_analysis, spec$formula_rhs$B, "H2b_B", "H2b_B_Constructs", paths$models_dir)

message("H2b test completed. Outputs saved to models/.")
