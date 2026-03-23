# R/hypotheses/H2a_test.R
# Hypothesis 2a: Ingroup Betrayal Effect
# Statement: Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.
# Dependent Variable: judgement (-9 to 9)
# Independent Variable: same_group_harm (1 = same faculty, 0 = different)
# Controls: iri_total, perp_outgroup, victim_outgroup, role_observer, 
#           participant_engineering, sex_man, age, economic_status, slot
# Sample: Accepted decisions (decision_accept = 1) excluding hidden label controls
# Specification: Interval-censored clustered Tobit model

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
fit_a <- fit_clustered_tobit(judgments_betrayal, rhs_a)

write.csv(extract_model_table(fit_a), file.path(paths$models_dir, "H2a_A_coefficients.csv"), row.names = FALSE)
saveRDS(fit_a, file.path(paths$models_dir, "H2a_A_model.rds"))
write.csv(extract_model_stats(fit_a, judgments_betrayal, "H2a_A_Total"), file.path(paths$models_dir, "H2a_A_fit_stats.csv"), row.names = FALSE)

# Model B
rhs_b <- paste(
  "same_group_harm + iri_fs + iri_ec + iri_pt + iri_pd + perp_outgroup + victim_outgroup +",
  "role_observer + participant_engineering + sex_man + age + economic_status +",
  "factor(negotiator_slot)"
)
fit_b <- fit_clustered_tobit(judgments_betrayal, rhs_b)

write.csv(extract_model_table(fit_b), file.path(paths$models_dir, "H2a_B_coefficients.csv"), row.names = FALSE)
saveRDS(fit_b, file.path(paths$models_dir, "H2a_B_model.rds"))
write.csv(extract_model_stats(fit_b, judgments_betrayal, "H2a_B_Constructs"), file.path(paths$models_dir, "H2a_B_fit_stats.csv"), row.names = FALSE)

message("H2a test completed. Outputs saved to models/.")
