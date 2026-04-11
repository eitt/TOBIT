# R/03_transform_data.R
# Placeholder - Data is already transformed from Phase 1. Pass through.
source("R/00_config.R")
paths <- get_project_paths()
df <- read.csv(file.path(paths$root, "data", "processed", "02_cleaned.csv"), stringsAsFactors = FALSE)
write.csv(df, file.path(paths$root, "data", "processed", "03_transformed_participants.csv"), row.names = FALSE, na = "")
