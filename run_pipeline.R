# Main orchestrator for the longitudinal Tobit redesign.

message("==========================================")
message("Starting the longitudinal judgement Tobit pipeline")
message("==========================================")

source("R/00_config.R")
ensure_pipeline_dependencies()
paths <- get_project_paths()
removed_outputs <- clear_pipeline_outputs(paths)

message(sprintf(
  "Cleared generated artifacts from: %s",
  paste(names(removed_outputs), collapse = ", ")
))

pipeline_scripts <- c(
  "R/01_import_data.R",
  "R/02_clean_data.R",
  "R/03_transform_data.R",
  "R/04_generate_variables.R",
  "R/05_descriptive_statistics.R",
  "R/hypotheses/H1_test.R",
  "R/hypotheses/H2_test.R",
  "R/hypotheses/H3_test.R",
  "R/hypotheses/H4_test.R",
  "R/hypotheses/H5_test.R",
  "R/06_generate_report.R",
  "R/08_generate_plain_language_report.R",
  "R/09_generate_behavioral_economics_report.R"
)

for (script_path in pipeline_scripts) {
  message(sprintf("--- Running %s ---", script_path))
  source(script_path)
}

message("==========================================")
message("Pipeline finished successfully.")
message("Check data/processed and outputs/ for the redesigned longitudinal Tobit artifacts.")
message("==========================================")
