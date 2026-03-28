# run_pipeline.R
# Main Orchestrator Script for the TOBIT Pipeline
# Executes the function-oriented project pipeline sequentially.

message("==========================================")
message("Starting the TOBIT + Cluster-Aware Non-Parametric Robustness Analysis Pipeline")
message("--- Checking Environmental Requirements ---")

# --- User Configuration ---
# Choose which dataset to analyze: "FLORIDA", "BUC", or "BOTH"
dataset_mode <- "BUC"

# Ensure project structure & dependencies
source("R/00_config.R")
apply_pipeline_runtime_options(
  dataset_mode = dataset_mode,
  run_bootstrap = TRUE,
  skip_tobit_refit = FALSE
)
paths <- get_project_paths()

if (!ensure_pipeline_dependencies()) {
  stop("Environmental requirements not met. Please check the logs above.", call. = FALSE)
}
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
  "R/hypotheses/H2a_test.R",
  "R/hypotheses/H2b_test.R",
  "R/hypotheses/H3_test.R"
)

message("\n==========================================")
message("Starting Hypothesis Testing (Tobit + Cluster-Aware Non-Parametric Robustness)")
message("==========================================")

for (script in hypothesis_scripts) {
  message(sprintf("\n--- Running %s ---", script))
  source(script)
}

message("\n==========================================")
message("Starting Dynamic Report Generation")
message("==========================================")

source("R/06_generate_report.R")

message("\n==========================================")
message("Pipeline Finished Successfully!")
message("Check the 'outputs/' directory for tables, figures, models, and generated reports.")
message("Check the 'data/processed/' directory for the clean analytical datasets.")
message("==========================================")
