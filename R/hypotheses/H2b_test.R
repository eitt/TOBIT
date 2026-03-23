# R/hypotheses/H2b_test.R
# Hypothesis 2b: Outgroup Derogation Effect
# Statement: Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: perp_outgroup (1 = outgroup negotiator, 0 = ingroup)
# Controls: iri_total, perp_control, victim_outgroup, role_observer, 
#           participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1)
# Specification: Interval-censored clustered Tobit model

source("R/00_config.R")
source("R/utils/model_functions.R")
source("R/utils/table_functions.R")
paths <- get_project_paths()

message("Testing H2b: Outgroup Derogation Effect (Models A and B)")

judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)

# Model A
rhs_a <- paste(
  "perp_outgroup + iri_total + perp_control + victim_outgroup +",
  "iri_total:perp_outgroup + iri_total:perp_control +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
fit_a <- fit_clustered_tobit(judgments_accept, rhs_a)

write.csv(extract_model_table(fit_a), file.path(paths$models_dir, "H2b_A_coefficients.csv"), row.names = FALSE)
saveRDS(fit_a, file.path(paths$models_dir, "H2b_A_model.rds"))
write.csv(extract_model_stats(fit_a, judgments_accept, "H2b_A_Total"), file.path(paths$models_dir, "H2b_A_fit_stats.csv"), row.names = FALSE)

# Model B
rhs_b <- paste(
  "perp_outgroup + iri_fs + iri_ec + iri_pt + iri_pd + perp_control + victim_outgroup +",
  "iri_fs:perp_outgroup + iri_ec:perp_outgroup + iri_pt:perp_outgroup + iri_pd:perp_outgroup +",
  "iri_fs:perp_control + iri_ec:perp_control + iri_pt:perp_control + iri_pd:perp_control +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
fit_b <- fit_clustered_tobit(judgments_accept, rhs_b)

write.csv(extract_model_table(fit_b), file.path(paths$models_dir, "H2b_B_coefficients.csv"), row.names = FALSE)
saveRDS(fit_b, file.path(paths$models_dir, "H2b_B_model.rds"))
write.csv(extract_model_stats(fit_b, judgments_accept, "H2b_B_Constructs"), file.path(paths$models_dir, "H2b_B_fit_stats.csv"), row.names = FALSE)

message("H2b test completed. Outputs saved to models/.")
