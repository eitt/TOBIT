# R/01_import_data.R
source("R/00_config.R")
paths <- get_project_paths()

message("Importing Full Consolidated Dataset (Version 2.0)...")
df <- readxl::read_excel(file.path(paths$root, "Version 2.0", "consolidado_ALL_2026_04_09_LONG.xlsx"))
df <- as.data.frame(df)

# Check sample mode
configured_sample_fraction <- resolve_dataset_sample_fraction()
configured_sample_seed <- resolve_dataset_sample_seed()
df <- sample_pipeline_dataset(df, sample_fraction = configured_sample_fraction, seed = configured_sample_seed)

write.csv(df, file.path(paths$root, "data", "processed", "01_imported.csv"), row.names = FALSE, na = "")
message("Data successfully imported into 01_imported.csv")
