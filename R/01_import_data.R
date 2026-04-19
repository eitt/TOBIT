source("R/00_config.R")
source("R/utils/prepare_consolidated_dataset.R")

paths <- get_project_paths()

message("Importing the Version 2.0 consolidated long dataset...")
judgments_raw <- read_consolidated_long_dataset(paths)
validate_consolidated_long_dataset(judgments_raw)

numeric_columns <- setdiff(required_long_columns(), "id_case")
judgments_raw <- coerce_numeric_columns(judgments_raw, numeric_columns)
judgments_raw <- judgments_raw[order(judgments_raw$source_row_number), , drop = FALSE]

write.csv(judgments_raw, paths$processed_import, row.names = FALSE, na = "")
write.csv(
  judgments_raw,
  file.path(paths$harmonized_dir, "01_source_long_snapshot.csv"),
  row.names = FALSE,
  na = ""
)

message(sprintf(
  "Imported %s rows from %s without creating new observations.",
  nrow(judgments_raw),
  basename(paths$base_long_dataset)
))
