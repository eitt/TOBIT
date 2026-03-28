# R/hypotheses/H2a_test.R
# Hypothesis 2a: Relational betrayal comparisons under Option 2
# Statement: Judgments of same-faculty harm should differ from cross-faculty
# harm when we compare explicit victim x negotiator case configurations rather
# than collapsing scenarios into a single same_group_harm indicator.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: explicit betrayal-sample case configurations
# (Hum_x_Hum reference, contrasted against Hum_x_Ing, Ing_x_Hum, and Ing_x_Ing)
# Controls: iri_total or empathy subscales, role_observer,
# participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1) excluding control-label
# scenarios
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H2a: Relational betrayal case comparisons under Option 2 (Models A and B)")

judgments_betrayal <- read.csv(paths$processed_betrayal, stringsAsFactors = FALSE)

betrayal_case_terms <- paste(
  get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = FALSE),
  collapse = " + "
)

# Model A
rhs_a <- paste(
  betrayal_case_terms, "+ iri_total +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_betrayal, rhs_a, "H2a_A", "H2a_A_Total", paths$models_dir)

# Model B
rhs_b <- paste(
  betrayal_case_terms, "+ iri_fs + iri_ec + iri_pt + iri_pd +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_betrayal, rhs_b, "H2a_B", "H2a_B_Constructs", paths$models_dir)

message("H2a test completed. Outputs saved to models/.")
