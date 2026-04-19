source("R/00_config.R")
source("R/utils/prepare_consolidated_dataset.R")

paths <- get_project_paths()
judgments_clean <- read.csv(paths$processed_clean, stringsAsFactors = FALSE)

participant_bridge <- reconstruct_participant_bridge(judgments_clean)
dictionary_base <- build_variable_dictionary()

write.csv(participant_bridge, paths$processed_transformed, row.names = FALSE, na = "")
write.csv(participant_bridge, paths$processed_participants, row.names = FALSE, na = "")
write.csv(dictionary_base, paths$processed_dictionary, row.names = FALSE)
write.csv(
  participant_bridge,
  file.path(paths$harmonized_dir, "03_participant_bridge.csv"),
  row.names = FALSE,
  na = ""
)

message(sprintf(
  "Participant bridge written for %s participants to preserve downstream compatibility.",
  nrow(participant_bridge)
))
