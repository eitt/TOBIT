source("R/00_config.R")
source("R/utils/prepare_consolidated_dataset.R")
source("R/utils/build_role_relational_variables.R")
source("R/hypotheses/H_formulas.R")

paths <- get_project_paths()
judgments_clean <- read.csv(paths$processed_clean, stringsAsFactors = FALSE)

judgments_analysis <- build_role_relational_variables(judgments_clean)
judgments_victim <- judgments_analysis[judgments_analysis$role_label == "victim", , drop = FALSE]
judgments_bystander <- judgments_analysis[judgments_analysis$role_label == "bystander", , drop = FALSE]

derived_dictionary <- data.frame(
  variable = c(
    "source_row_number",
    "role_label",
    "target_label",
    "N1_faculty",
    "N2_faculty",
    "N1_decision",
    "N2_decision",
    "victim_N1_group",
    "victim_N2_group",
    "bystander_victim_group",
    "bystander_N1_group",
    "bystander_N2_group",
    "N1_N2_same_faculty",
    "decision_pattern",
    "faculty_player_factor"
  ),
  source_role = c(
    "all rows",
    "all rows",
    "all rows",
    "all rows",
    "all rows",
    "all rows",
    "all rows",
    "victim and bystander",
    "victim and bystander",
    "bystander only",
    "bystander only",
    "bystander only",
    "all rows",
    "all rows",
    "all rows"
  ),
  mapping_note = c(
    "One-to-one row identifier copied from the Excel import to prove that the preparation stage does not create new observations.",
    "Role decoded from the source file: victim or bystander.",
    "Label for the judged negotiator in the current source row: N1 or N2.",
    "Faculty of negotiator 1 reconstructed from faculty_target/faculty_other without reshaping the data again.",
    "Faculty of negotiator 2 reconstructed from faculty_target/faculty_other without reshaping the data again.",
    "Decision of negotiator 1 reconstructed from decision_target/decision_other without reshaping the data again.",
    "Decision of negotiator 2 reconstructed from decision_target/decision_other without reshaping the data again.",
    "Victim-to-N1 relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Victim-to-N2 relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Bystander-to-victim relation: ingroup or outgroup.",
    "Bystander-to-N1 relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Bystander-to-N2 relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Contextual N1/N2 faculty relation: same when faculties match, including control-control; different otherwise.",
    "Observed joint decision configuration from decision_target and decision_other, retaining the four target/other accept-reject combinations.",
    "Participant faculty factor used in all models."
  ),
  stringsAsFactors = FALSE
)

variable_dictionary <- rbind(
  read.csv(paths$processed_dictionary, stringsAsFactors = FALSE),
  derived_dictionary
)

write.csv(judgments_analysis, paths$processed_judgments, row.names = FALSE, na = "")
write.csv(judgments_victim, paths$processed_victim, row.names = FALSE, na = "")
write.csv(judgments_bystander, paths$processed_bystander, row.names = FALSE, na = "")
write.csv(variable_dictionary, paths$processed_dictionary, row.names = FALSE)

write.csv(
  judgments_analysis,
  file.path(paths$harmonized_dir, "04_judgments_analysis_prepared.csv"),
  row.names = FALSE,
  na = ""
)
write.csv(
  judgments_victim,
  file.path(paths$harmonized_dir, "04_judgments_victim_prepared.csv"),
  row.names = FALSE,
  na = ""
)
write.csv(
  judgments_bystander,
  file.path(paths$harmonized_dir, "04_judgments_bystander_prepared.csv"),
  row.names = FALSE,
  na = ""
)
write.csv(
  variable_dictionary,
  file.path(paths$harmonized_dir, "04_variable_dictionary.csv"),
  row.names = FALSE
)

write_formula_catalog(paths)

message(sprintf(
  "Prepared %s analytical rows, preserving the %s original source rows one-to-one.",
  nrow(judgments_analysis),
  nrow(judgments_clean)
))
