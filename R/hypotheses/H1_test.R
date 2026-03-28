# R/hypotheses/H1_test.R
# Hypothesis 1: Empathy Effect under Option 2 explicit case configuration
# Statement: Higher empathy predicts lower moral-judgment scores for harmful
# decisions after conditioning on explicit victim x negotiator case
# configurations such as Hum_x_Hum, Hum_x_Ing, Hum_x_Control, Ing_x_Hum,
# Ing_x_Ing, and Ing_x_Control.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: iri_total (empathy composite average) or empathy
# subscales
# Relational controls: explicit case-configuration indicators with Hum_x_Hum as
# the reference scenario
# Additional controls: role_observer, participant_engineering, sex_man, age,
# economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H1: Empathy Effect under Option 2 explicit case configurations (Models A and B)")

judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

accepted_case_terms <- paste(
  get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = TRUE),
  collapse = " + "
)

# Model A: Total Empathy
rhs_a <- paste(
  "iri_total +", accepted_case_terms, "+",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_a, "H1_A", "H1_A_Total", paths$models_dir)

# Model B: Empathy Subscales
rhs_b <- paste(
  "iri_fs + iri_ec + iri_pt + iri_pd +", accepted_case_terms, "+",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_b, "H1_B", "H1_B_Constructs", paths$models_dir)

message("H1 test completed. Outputs saved to models/.")
