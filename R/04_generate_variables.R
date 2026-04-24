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
    "target_code_label",
    "target_faculty",
    "other_faculty",
    "victim_target_group",
    "victim_other_group",
    "bystander_victim_group",
    "bystander_target_group",
    "bystander_other_group",
    "target_other_same_faculty",
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
    "all rows",
    "all rows",
    "all rows"
  ),
  mapping_note = c(
    "One-to-one row identifier copied from the Excel import to prove that the preparation stage does not create new observations.",
    "Role decoded from the source file: victim or bystander.",
    "Target slot code from the source file (`target`): `target_code_1` or `target_code_2`.",
    "Faculty of the row-dynamic target negotiator (copied from faculty_target).",
    "Faculty of the row-dynamic counterpart negotiator (copied from faculty_other).",
    "Victim-to-target relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Victim-to-other relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Bystander-to-victim relation: ingroup or outgroup.",
    "Bystander-to-target relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Bystander-to-other relation: ingroup when faculties match, including control-control; outgroup otherwise.",
    "Contextual target/other faculty relation: same when faculties match, including control-control; different otherwise.",
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
