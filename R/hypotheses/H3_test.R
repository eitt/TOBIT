# R/hypotheses/H3_test.R
# Hypothesis 3: Empathy x Group Moderation
# Statement: The negative association between empathy and moral-judgment scores 
#            should be stronger in outgroup cases than in ingroup cases.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: iri_total * perp_outgroup (Interaction)
# Controls: perp_control, victim_outgroup, role_observer, 
#           participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H3: Empathy x Group Moderation Effect (Models A and B)")

judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

# Model A
rhs_a <- paste(
  "iri_total * perp_outgroup + perp_control + victim_outgroup +",
  "iri_total:perp_control +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_a, "H3_A", "H3_A_Total", paths$models_dir)

# Model B
rhs_b <- paste(
  "iri_fs * perp_outgroup + iri_ec * perp_outgroup + iri_pt * perp_outgroup + iri_pd * perp_outgroup +",
  "perp_control + victim_outgroup +",
  "iri_fs:perp_control + iri_ec:perp_control + iri_pt:perp_control + iri_pd:perp_control +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
run_estimation_suite(judgments_accept, rhs_b, "H3_B", "H3_B_Constructs", paths$models_dir)

message("H3 test completed. Outputs saved to models/.")
