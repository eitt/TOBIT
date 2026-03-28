# R/07_run_nonparametric_bootstrap_phase.R
# Purpose: Bootstrap-only refresh utility that updates participant-level
# cluster-bootstrap inference for the non-parametric censored robustness models
# without refitting the Tobit branch.
# Execution Order: Optional rerun utility

message("==========================================")
message("Starting Non-Parametric Bootstrap Refresh")
message("==========================================")

source("R/00_config.R")

# Reuse the current dataset mode unless the caller overrides it first.
dataset_mode <- getOption("tobit.dataset_mode", default = "BUC")
options(tobit.dataset_mode = dataset_mode)

# This phase updates only the non-parametric robustness outputs.
options(tobit.clad_run_bootstrap = TRUE)
options(tobit.skip_tobit_refit = TRUE)

# Increase or decrease this option before sourcing the script if needed.
if (is.null(getOption("tobit.clad_bootstrap_reps"))) {
  options(tobit.clad_bootstrap_reps = 39L)
}

hypothesis_scripts <- c(
  "R/hypotheses/H1_test.R",
  "R/hypotheses/H2a_test.R",
  "R/hypotheses/H2b_test.R",
  "R/hypotheses/H3_test.R"
)

for (script in hypothesis_scripts) {
  message(sprintf("\n--- Running bootstrap refresh for %s ---", script))
  source(script)
}

message("\n--- Regenerating report with refreshed non-parametric bootstrap outputs ---")
source("R/06_generate_report.R")

message("==========================================")
message("Non-parametric bootstrap refresh complete.")
message("Updated non-parametric coefficients, fit summaries, and report artifacts are available in outputs/.")
message("==========================================")
