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
# Sample: Full role-specific samples excluding scenarios with any control-labeled negotiator
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/hypothesis_metadata.R")
paths <- get_project_paths()
spec <- get_hypothesis_spec("H2a", paths = paths)

message("Testing H2a: Judged-status x decision contrasts without control scenarios (Models A and B)")

judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

judgments_victim_betrayal <- judgments_victim[!is.na(judgments_victim$scenario_has_control) & judgments_victim$scenario_has_control == 0L, , drop = FALSE]
judgments_bystander_betrayal <- judgments_bystander[!is.na(judgments_bystander$scenario_has_control) & judgments_bystander$scenario_has_control == 0L, , drop = FALSE]

# ---- Victim Subset ----
message("--- Running H2a on Victim Subset ---")
# Model A
run_estimation_suite(judgments_victim_betrayal, spec$formula_rhs$A, "H2a_A_Victim", "H2a_A_Victim_Total", paths$models_dir)

# Model B
run_estimation_suite(judgments_victim_betrayal, spec$formula_rhs$B, "H2a_B_Victim", "H2a_B_Victim_Constructs", paths$models_dir)


# ---- Bystander Subset ----
message("--- Running H2a on Bystander Subset ---")
# Model A
run_estimation_suite(judgments_bystander_betrayal, spec$formula_rhs$A, "H2a_A_Bystander", "H2a_A_Bystander_Total", paths$models_dir)

# Model B
run_estimation_suite(judgments_bystander_betrayal, spec$formula_rhs$B, "H2a_B_Bystander", "H2a_B_Bystander_Constructs", paths$models_dir)

message("H2a test completed for both subsets. Outputs saved to models/.")
