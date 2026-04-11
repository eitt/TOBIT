# run_pipeline.R
# Main Orchestrator Script for the TOBIT Pipeline
# Executes the function-oriented project pipeline sequentially.

message("==========================================")
message("Starting the TOBIT Pipeline")
message("--- Checking Environmental Requirements ---")

# --- User Configuration ---
# Choose which dataset to analyze: "FLORIDA", "BUC", or "BOTH"
dataset_mode <- "BOTH"

# Ensure project structure & dependencies
source("R/00_config.R")
apply_pipeline_runtime_options(
  dataset_mode = dataset_mode,
  pipeline_mode = "Tobit",
  skip_tobit_refit = FALSE,
  active_model_suffixes = "B"
)
message(sprintf("Configured active empathy specification(s): %s", paste(resolve_active_model_suffixes(), collapse = ", ")))
message("Configured estimator branch: Tobit only")
message(sprintf(
  "Configured participant-level raw-data sample fraction: %.1f%% (seed %s)",
  100 * resolve_dataset_sample_fraction(),
  resolve_dataset_sample_seed()
))
paths <- get_project_paths()

if (!ensure_pipeline_dependencies()) {
  stop("Environmental requirements not met. Please check the logs above.", call. = FALSE)
}
removed_output_entries <- clear_pipeline_outputs(paths)
message(sprintf(
  "Cleared previous outputs before the fresh run: tables=%s, figures=%s, models=%s, logs=%s, report=%s",
  removed_output_entries[["tables"]],
  removed_output_entries[["figures"]],
  removed_output_entries[["models"]],
  removed_output_entries[["logs"]],
  removed_output_entries[["report"]]
))
message("--- Preparation Complete ---")
message("==========================================")

# Core Pipeline Sequencer
pipeline_scripts <- c(
  "R/01_import_data.R",
  "R/02_clean_data.R",
  "R/03_transform_data.R",
  "R/04_generate_variables.R",
  "R/05_descriptive_statistics.R"
)

for (script in pipeline_scripts) {
  message(sprintf("\n--- Running %s ---", script))
  source(script)
}

# Run Hypothesis Tests
hypothesis_scripts <- c(
  "R/hypotheses/H1_test.R",
  "R/hypotheses/H2_test.R",
  "R/hypotheses/H3_test.R"
)

message("\n==========================================")
message("Starting Hypothesis Testing (Tobit only, four empathy constructs)")
message("==========================================")

for (script in hypothesis_scripts) {
  message(sprintf("\n--- Running %s ---", script))
  source(script)
}

message("\n==========================================")
message("Starting Dynamic Report Generation")
message("==========================================")

source("R/06_generate_report.R")
source("R/08_generate_plain_language_report.R")
source("R/09_generate_behavioral_economics_report.R")

message("\n==========================================")
message("Pipeline Finished Successfully!")
message("Check the 'outputs/' directory for tables, figures, models, and generated reports.")
message("Check the 'data/processed/' directory for the clean analytical datasets.")
message("==========================================")
