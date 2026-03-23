# R/02_clean_data.R
# Purpose: Recode demographics, apply validity checks, handle missing values.
# Inputs: 01_imported.csv
# Outputs: 02_cleaned.csv
# Dependencies: 00_config.R
# Execution Order: 3

source("R/00_config.R")
paths <- get_project_paths()

df <- read.csv(file.path(paths$root, "data", "processed", "01_imported.csv"), stringsAsFactors = FALSE)

# Generate labels for socio-demographics
df$sex_label <- ifelse(df$sex == 2, "Man", "Woman")
df$faculty_player_label <- ifelse(df$faculty_player == 2, "Engineering", "Humanities")
df$treatment_label <- ifelse(df$treatment == 2, "Observer first", "Victim first")

# Apply attention check filtering flags
df$attention_pass <- df$ac1 == 1 & df$ac2 == 1
df$valid_treatment <- df$treatment %in% c(1, 2)

write.csv(df, file.path(paths$root, "data", "processed", "02_cleaned.csv"), row.names = FALSE, na = "")
