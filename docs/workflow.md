# Workflow Logic

This document explains the sequential logic of the TOBIT data analysis pipeline. The project is designed with a strict function-oriented structure and avoids object-oriented complexity.

## Execution Sequence

The pipeline can be executed completely via the `run_pipeline.R` master orchestrator, which sequentially runs the following scripts:

### 1. Data Import (`R/01_import_data.R`)
- Loads configuration paths and safely identifies the Python Excel fallback script if `readxl` is missing.
- Reads `data_final_FLORIDA.xlsx` from `data/raw/`.
- Validates that all required columns are present.
- Exports the `data/processed/01_imported.csv` file.

### 2. Data Cleaning (`R/02_clean_data.R`)
- Ingests `01_imported.csv`.
- Fixes factor labels for sex, faculty, and treatment groups.
- Evaluates attention check results (`ac1` and `ac2`).
- Saves the step to `02_cleaned.csv`.

### 3. Data Transformation (`R/03_transform_data.R`)
- Loads psychological item variables.
- Uses `row_mean_with_floor` to score the four Interpersonal Reactivity Index (IRI) subscales and the final composite.
- Retains the IRI composite and subscale predictors on their original scales; no z-score normalization is applied to predictors.
- Configures the `analysis_include` filter flag based on attention checks and missing values.
- Exports `03_transformed_participants.csv`.

### 4. Variable Generation (`R/04_generate_variables.R`)
- Reshapes the wide format (participant-level) into long-format (negotiator-level).
- Each participant contributes 10 stages x 2 negotiators = 20 judgment rows.
- Derives legacy identity indicators such as `perp_outgroup`, `perp_control`, and `same_group_harm` for backward comparison.
- Derives the **Option 2 explicit case-configuration variables**:
  - `case_configuration`
  - `case_configuration_role`
  - `case_configuration_decision`
  - `case_configuration_context`
- The core relational case is built with the victim group first and the judged negotiator second, yielding interpretable pairings such as `Hum_x_Hum`, `Hum_x_Ing`, `Hum_x_Control`, `Ing_x_Hum`, `Ing_x_Ing`, and `Ing_x_Control`.
- Splits the long data into `judgments_analysis.csv` (full sample), `judgments_accept_only.csv` (restricted to H1, H2b, H3 models), and `judgments_betrayal_only.csv` (restricted for H2a).

### 5. Descriptive Statistics (`R/05_descriptive_statistics.R`)
- Implements grouped summaries using strict missing-value safety functions (`safe_mean`, `safe_sd`).
- Generates histograms and plots matching high-contrast aesthetic requirements.
- Generates `empathy_summary.csv`, `participant_summary.csv`, `judgement_summary.csv`, and `case_configuration_summary.csv`.

### 6. Run Hypothesis-Specific Models (`R/hypotheses/*`)
Each of the 4 hypotheses has its own isolated script that sets up its explicit bounded-outcome formula, estimates a clustered Tobit model using interval boundaries (-9 and 9), then fits a non-parametric robustness companion as interval-censored median regression. The non-parametric branch first fits the full sample once and, if that fit converges, immediately launches participant-level cluster bootstrap inference by resampling ids with replacement while retaining all repeated observations from each sampled participant. Repeated observations from the same participant are therefore handled inferentially in both branches, with `id` serving only as the clustering unit. If too few bootstrap refits converge, the workflow carries that forward as a sparse-bootstrap status rather than presenting the non-parametric branch as fully inferential.

- `H1_test.R`: Uses empathy plus explicit case-configuration controls to estimate the empathy effect under Option 2.
- `H2a_test.R`: Uses explicit betrayal-sample case contrasts (`Hum_x_Hum`, `Hum_x_Ing`, `Ing_x_Hum`, `Ing_x_Ing`) instead of a single `same_group_harm` flag.
- `H2b_test.R`: Uses explicit accepted-sample case contrasts (`Hum_x_Control`, `Hum_x_Ing`, `Ing_x_Hum`, `Ing_x_Ing`, `Ing_x_Control`) instead of a single `perp_outgroup` flag.
- `H3_test.R`: Uses empathy x case-configuration interactions to test moderation directly on relational scenarios.

### 7. Export Tables and Figures (`Outputs directory`)

- Figures are sent to `outputs/figures/`.
- Regression coefficients, fit summaries, non-parametric robustness artifacts, and LaTeX representations are sent to `outputs/models/` and `outputs/tables/`.

### 7. Bootstrap-Only Refresh Utility (`R/07_run_nonparametric_bootstrap_phase.R`)

- Sets the pipeline into bootstrap-only mode for the non-parametric branch.
- Skips Tobit refits so only the non-parametric outputs are refreshed.
- Runs participant-level cluster bootstrap inference only for specifications whose full-sample non-parametric fit converged.
- Regenerates the report after the bootstrap-enhanced robustness outputs are saved.
- If too few participant-level bootstrap refits converge, the refreshed outputs are marked as sparse bootstrap inference.
- The central bootstrap default currently lives in `R/00_config.R` and is set to `1` for debugging. Restore `get_default_clad_bootstrap_reps()` to `10L` for the usual inference run.

### 8. Dynamic Reporting (`R/06_generate_report.R`)

- Automates clustered statistical power analysis estimating the Intraclass Correlation Coefficient (ICC) and translating repeated measures into an Effective Sample Size (ESS).
- Reads the output tables natively, detects hypothesis-relevant empathy and case-configuration predictors that reach at least `p < .10`, generates the most suitable dynamic figure for each such predictor, then also generates an additional figure set for every significant predictor below `p < .10` in the H-model families, including significant controls such as `age`.
- The report now states Option 2 explicitly, documents the origin of the case-configuration variable, and includes descriptive summaries of scenario x role x decision combinations.
- Writes compiled narrative markdown reports to `outputs/report/tobit_analysis_report.md` and `outputs/logs/dynamic_report.md`.

This guarantees reproducibility from a fresh R session without requiring workspace state. All steps communicate securely through the artifacts generated in `data/processed/`.
