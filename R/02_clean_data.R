# R/02_clean_data.R
# Placeholder - Data is already clean from Phase 1. Pass through.
source("R/00_config.R")
paths <- get_project_paths()
df <- read.csv(file.path(paths$root, "data", "processed", "01_imported.csv"), stringsAsFactors = FALSE)
write.csv(df, file.path(paths$root, "data", "processed", "02_cleaned.csv"), row.names = FALSE, na = "")
