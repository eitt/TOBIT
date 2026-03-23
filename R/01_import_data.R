# R/01_import_data.R
# Purpose: Import raw data and validate column structure.
# Inputs: raw Excel dataset.
# Outputs: 01_imported.csv
# Dependencies: 00_config.R, io_functions.R
# Execution Order: 2

source("R/00_config.R")
source("R/utils/io_functions.R")

paths <- get_project_paths()

# 1. Load Data based on Selection
if (paths$dataset_mode == "FLORIDA") {
  message("Importing Dataset: FLORIDA CAMPUS")
  df <- read_source_data(paths$raw_florida)
  df$campus <- "Floridablanca"
} else if (paths$dataset_mode == "BUC") {
  message("Importing Dataset: BUCARAMANGA CAMPUS")
  df <- read_source_data(paths$raw_buc)
  df$campus <- "Bucaramanga"
} else {
  message("Importing Dataset: BOTH CAMPUSES (Florida & Bucaramanga)")
  data_flo <- read_source_data(paths$raw_florida)
  data_flo$campus <- "Floridablanca"
  data_buc <- read_source_data(paths$raw_buc)
  data_buc$campus <- "Bucaramanga"
  df <- rbind(data_flo, data_buc)
}

# 2. Structural Validation
validate_raw_tobit_structure <- function(data) {
  # Simple internal validator
  if (!is.data.frame(data)) stop("Input is not a data frame.")
  if (nrow(data) == 0) stop("Input data is empty.")
}
validate_raw_tobit_structure(df)

participant_vars <- c("id", "commitment", "age", "economic_status", "sex", "faculty_player", "ac1", "ac2", "treatment")
empathy_vars <- c(
  "FS1", "EC2", "PT3", "EC4", "FS5", "PD6", "FS7", "PT8", "EC9", "PD10",
  "PT11", "FS12", "PD13", "EC14", "PT15", "FS16", "EC17", "PD18", "EC19",
  "FS20", "PT21", "PD22", "PT23", "EC24", "FS25", "PT26", "PD27", "EC28"
)
scenario_vars <- unlist(lapply(1:10, function(stage) {
  c(
    sprintf("faculty_neg_1_s%d", stage),
    sprintf("faculty_neg_2_s%d", stage),
    sprintf("faculty_victim_s%d", stage),
    sprintf("decision_neg1_s%d", stage),
    sprintf("decision_neg2_s%d", stage),
    sprintf("judgement_compare_s%d", stage),
    sprintf("judgement_n1_s%d", stage),
    sprintf("judgement_n2_s%d", stage)
  )
}))
required_vars <- c(participant_vars, empathy_vars, scenario_vars)
missing_vars <- setdiff(required_vars, names(df))

if (length(missing_vars) > 0L) {
  stop("Missing required columns: ", paste(missing_vars, collapse = ", "))
}

message("Validation passed. Saving step to 01_imported.csv.")
write.csv(df, file.path(paths$root, "data", "processed", "01_imported.csv"), row.names = FALSE, na = "")
