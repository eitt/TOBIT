source("R/00_config.R")

paths <- get_project_paths()
judgments_clean <- read.csv(paths$processed_import, stringsAsFactors = FALSE)

judgments_clean <- judgments_clean[
  order(judgments_clean$id, judgments_clean$stage, judgments_clean$target),
  ,
  drop = FALSE
]

write.csv(judgments_clean, paths$processed_clean, row.names = FALSE, na = "")
write.csv(
  data.frame(
    imported_rows = nrow(judgments_clean),
    unique_source_rows = length(unique(judgments_clean$source_row_number)),
    duplicated_source_rows = sum(duplicated(judgments_clean$source_row_number)),
    stringsAsFactors = FALSE
  ),
  file.path(paths$harmonized_dir, "02_cleaning_audit.csv"),
  row.names = FALSE
)

message("The consolidated long dataset passed through cleaning with row-level preservation intact.")
