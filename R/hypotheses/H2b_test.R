# R/hypotheses/H2b_test.R
# Hypothesis 2b: Explicit case-configuration contrasts under Option 2
# Statement: Judgments should be interpreted through explicit relational case
# configurations such as Hum_x_Ing, Hum_x_Control, Ing_x_Hum, Ing_x_Ing, and
# Ing_x_Control rather than through a single outgroup-perpetrator indicator.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: explicit victim x negotiator case configurations with
# Hum_x_Hum as the reference scenario
# Controls: iri_total or empathy subscales, role_observer,
# participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H2b: Explicit case-configuration contrasts under Option 2 (Models A and B)")

judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

accepted_case_terms <- paste(
  get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = TRUE),
  collapse = " + "
)

# Model A
rhs_a <- paste(
  accepted_case_terms, "+ iri_total +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_a, "H2b_A", "H2b_A_Total", paths$models_dir)

# Model B
rhs_b <- paste(
  accepted_case_terms, "+ iri_fs + iri_ec + iri_pt + iri_pd +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_b, "H2b_B", "H2b_B_Constructs", paths$models_dir)

message("H2b test completed. Outputs saved to models/.")
