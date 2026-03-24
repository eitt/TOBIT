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
- Derives complex identity indicators: `perp_outgroup`, `perp_control`, `same_group_harm`.
- Splits the long data into `judgments_analysis.csv` (full sample), `judgments_accept_only.csv` (restricted to H1, H2b, H3 models), and `judgments_betrayal_only.csv` (restricted for H2a).

### 5. Descriptive Statistics (`R/05_descriptive_statistics.R`)
- Implements grouped summaries using strict missing-value safety functions (`safe_mean`, `safe_sd`).
- Generates histograms and plots matching high-contrast aesthetic requirements.
- Generates `empathy_summary.csv`, `participant_summary.csv`, and `judgement_summary.csv`.

### 6. Run Hypothesis-Specific Models (`R/hypotheses/*`)
Each of the 4 hypotheses has its own isolated script that sets up its explicit bounded-outcome formula, estimates a clustered Tobit model using interval boundaries (-9 and 9), then fits a CLAD robustness companion as interval-censored median regression. Each script logs execution and writes both sets of model artifacts for publication:

- `H1_test.R`: Uses `iri_total` targeting the Empathy Effect and writes `H1_A*`, `H1_B*`, `H1_A_CLAD*`, and `H1_B_CLAD*`.
- `H2a_test.R`: Uses `same_group_harm` targeting Ingroup Betrayal and writes the corresponding Tobit and CLAD outputs.
- `H2b_test.R`: Uses `perp_outgroup` targeting Outgroup Derogation and writes the corresponding Tobit and CLAD outputs.
- `H3_test.R`: Uses `iri_total:perp_outgroup` highlighting Moderation and writes the corresponding Tobit and CLAD outputs.

### 7. Export Tables and Figures (`Outputs directory`)

- Figures are sent to `outputs/figures/`.
- Regression coefficients, fit summaries, CLAD robustness artifacts, and LaTeX representations are sent to `outputs/models/` and `outputs/tables/`.

### 8. Dynamic Reporting (`R/06_generate_report.R`)

- Automates clustered statistical power analysis estimating the Intraclass Correlation Coefficient (ICC) and translating repeated measures into an Effective Sample Size (ESS).
- Reads the output tables natively, summarizes fit information across Tobit and CLAD, and renders both estimators in the final report for H1-H3.
- Writes a compiled narrative markdown report to `outputs/logs/dynamic_report.md`.

This guarantees reproducibility from a fresh R session without requiring workspace state. All steps communicate securely through the artifacts generated in `data/processed/`.
