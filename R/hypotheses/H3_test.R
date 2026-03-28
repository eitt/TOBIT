# R/hypotheses/H3_test.R
# Hypothesis 3: Empathy x case-configuration moderation under Option 2
# Statement: The empathy effect may vary across explicit victim x negotiator
# pairings, so moderation is modeled directly through empathy interactions with
# case configurations such as Hum_x_Ing, Hum_x_Control, Ing_x_Hum, Ing_x_Ing,
# and Ing_x_Control.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: empathy x explicit case-configuration interactions
# Controls: main effects for empathy, explicit case configurations,
# role_observer, participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model plus
# cluster-bootstrap non-parametric robustness check

source("R/00_config.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H3: Empathy x case-configuration moderation under Option 2 (Models A and B)")

judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

accepted_case_terms <- get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = TRUE)
accepted_case_rhs <- paste(accepted_case_terms, collapse = " + ")
accepted_total_interactions <- paste(
  get_case_configuration_interaction_terms("iri_total", reference = "Hum_x_Hum", include_control = TRUE),
  collapse = " + "
)
accepted_scale_interactions <- paste(
  get_case_configuration_interaction_terms(
    c("iri_fs", "iri_ec", "iri_pt", "iri_pd"),
    reference = "Hum_x_Hum",
    include_control = TRUE
  ),
  collapse = " + "
)

# Model A
rhs_a <- paste(
  "iri_total +", accepted_case_rhs, "+", accepted_total_interactions, "+",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_a, "H3_A", "H3_A_Total", paths$models_dir)

# Model B
rhs_b <- paste(
  "iri_fs + iri_ec + iri_pt + iri_pd +", accepted_case_rhs, "+", accepted_scale_interactions, "+",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_b, "H3_B", "H3_B_Constructs", paths$models_dir)

message("H3 test completed. Outputs saved to models/.")
