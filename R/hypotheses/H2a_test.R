# R/hypotheses/H2a_test.R
# Hypothesis 2a: Ingroup Betrayal Effect
# Statement: Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: same_group_harm (1 = same faculty, 0 = different)
# Controls: iri_total, perp_outgroup, victim_outgroup, role_observer, 
#           participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1) excluding hidden label controls
# Specification: Interval-censored clustered Tobit model plus
#                cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H2a: Ingroup Betrayal Effect (Models A and B)")

judgments_betrayal <- read.csv(paths$processed_betrayal, stringsAsFactors = FALSE)

# Model A
rhs_a <- paste(
  "same_group_harm + iri_total + perp_outgroup + victim_outgroup +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_betrayal, rhs_a, "H2a_A", "H2a_A_Total", paths$models_dir)

# Model B
rhs_b <- paste(
  "same_group_harm + iri_fs + iri_ec + iri_pt + iri_pd + perp_outgroup + victim_outgroup +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_betrayal, rhs_b, "H2a_B", "H2a_B_Constructs", paths$models_dir)

message("H2a test completed. Outputs saved to models/.")
