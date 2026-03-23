# R/hypotheses/H1_test.R
# Hypothesis 1: Empathy Effect
# Statement: Higher empathy predicts lower moral-judgment scores for harmful decisions.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: iri_total (empathy composite average)
# Controls: perp_outgroup, perp_control, victim_outgroup, role_observer, 
#           participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H1: Empathy Effect (Models A and B)")

judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

# Model A: Total Empathy
rhs_a <- paste(
  "iri_total + perp_outgroup + perp_control + victim_outgroup +",
  "iri_total:perp_outgroup + iri_total:perp_control +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
fit_a <- fit_clustered_tobit(judgments_accept, rhs_a)

write.csv(extract_model_table(fit_a), file.path(paths$models_dir, "H1_A_coefficients.csv"), row.names = FALSE)
saveRDS(fit_a, file.path(paths$models_dir, "H1_A_model.rds"))
write.csv(extract_model_stats(fit_a, judgments_accept, "H1_A_Total"), file.path(paths$models_dir, "H1_A_fit_stats.csv"), row.names = FALSE)

# Model B: Empathy Subscales
rhs_b <- paste(
  "iri_fs + iri_ec + iri_pt + iri_pd + perp_outgroup + perp_control + victim_outgroup +",
  "iri_fs:perp_outgroup + iri_ec:perp_outgroup + iri_pt:perp_outgroup + iri_pd:perp_outgroup +",
  "iri_fs:perp_control + iri_ec:perp_control + iri_pt:perp_control + iri_pd:perp_control +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
fit_b <- fit_clustered_tobit(judgments_accept, rhs_b)

write.csv(extract_model_table(fit_b), file.path(paths$models_dir, "H1_B_coefficients.csv"), row.names = FALSE)
saveRDS(fit_b, file.path(paths$models_dir, "H1_B_model.rds"))
write.csv(extract_model_stats(fit_b, judgments_accept, "H1_B_Constructs"), file.path(paths$models_dir, "H1_B_fit_stats.csv"), row.names = FALSE)

message("H1 test completed. Outputs saved to models/.")
