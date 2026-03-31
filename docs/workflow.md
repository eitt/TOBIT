# Workflow Logic

This document explains the sequential logic of the TOBIT data analysis pipeline. The project is designed with a strict function-oriented structure and avoids object-oriented complexity.

## Execution Sequence

The pipeline can be executed completely via the `run_pipeline.R` master orchestrator, which sequentially runs the following scripts:

Before the analytical steps begin, `run_pipeline.R` clears the existing generated artifacts inside `outputs/tables/`, `outputs/figures/`, `outputs/models/`, `outputs/logs/`, and `outputs/report/` so each fresh full run writes a clean set of outputs.

### 1. Data Import (`R/01_import_data.R`)
- Loads configuration paths and safely identifies the Python Excel fallback script if `readxl` is missing.
- Reads `data_final_FLORIDA.xlsx` from `data/raw/`.
- Validates that all required columns are present.
- Applies a reproducible random participant-level sample after validation. The default from `R/00_config.R` is `10%` of the imported dataset for quicker test runs, but this can be overridden back to the full dataset.
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
- Builds the dependent variable `judgement` by copying `judgement_n1_sX` into the long row where `negotiator_slot = 1` and `judgement_n2_sX` into the long row where `negotiator_slot = 2`.
- The pipeline also creates `condemnation = -judgement`, but the current hypothesis scripts use `judgement` as the modeled bounded outcome.
- Derives legacy identity indicators such as `perp_outgroup`, `perp_control`, and `same_group_harm` for backward comparison.
- Derives legacy **case-configuration variables** for backward compatibility:
  - `case_configuration`
  - `case_configuration_role`
  - `case_configuration_decision`
  - `case_configuration_context`
- These shorthand variables are retained only for compatibility with older descriptive artifacts; the executable hypotheses now rely on the negotiator-level relational predictors below.
- Derives the **judgment-level relational predictors** used directly in H2 and H3:
  - `group_negotiator_judged`
  - `group_negotiator_counterpart`
  - `group_victim`
  - `judged_outgroup`
  - `judged_control`
  - `counterpart_outgroup`
  - `counterpart_control`
  - `observer_victim_outgroup`
  - `h2_negotiator_structure`
  - `player_victim_alignment`
  - `player_victim_outgroup`
- These variables encode the judged negotiator's ingroup/outgroup/control status, the counterpart negotiator's corresponding status, and, for observer rows, whether the victim is ingroup or outgroup relative to the participant. `h2_negotiator_structure` makes the judged-plus-counterpart configuration explicit for H2.
- Splits the long data into `judgments_analysis.csv` (full sample), `judgments_victim.csv` (victim subset), `judgments_bystander.csv` (observer subset), and `judgments_accept_only.csv` (accepted-decision subset used by H1).

### 5. Descriptive Statistics (`R/05_descriptive_statistics.R`)
- Implements grouped summaries using strict missing-value safety functions (`safe_mean`, `safe_sd`).
- Generates histograms and plots matching high-contrast aesthetic requirements.
- Generates `empathy_summary.csv`, `participant_summary.csv`, `judgement_summary.csv`, and the remaining descriptive summary tables.

### 6. Run Hypothesis-Specific Models (`R/hypotheses/*`)
Each of the 3 hypothesis families has its own isolated script that sets up its explicit bounded-outcome formula, estimates a clustered Tobit model using interval boundaries (-9 and 9), then fits a non-parametric robustness companion as interval-censored median regression. The non-parametric branch first fits the full sample once and, if that fit converges, immediately launches participant-level cluster bootstrap inference by resampling ids with replacement while retaining all repeated observations from each sampled participant. Repeated observations from the same participant are therefore handled inferentially in both branches, with `id` serving only as the clustering unit. If too few bootstrap refits converge, the workflow carries that forward as a sparse-bootstrap status rather than presenting the non-parametric branch as fully inferential.

- `H1_test.R`: Uses empathy plus accepted-sample judged-negotiator, counterpart, and observer-side victim relational controls to estimate the empathy effect under Option 2.
- `H2_test.R`: Uses `h2_negotiator_structure` in both subsets. In the victim subset, H2 tests the judged-plus-counterpart structure directly. In the bystander subset, it additionally includes `player_victim_outgroup` and the interaction between `player_victim_outgroup` and the negotiator-side structure block.
- `H3_test.R`: Uses empathy x judged-negotiator-status interactions while retaining decision outcome, judged-status x decision terms, counterpart status, and observer-side victim alignment.

### 7. Export Tables and Figures (`Outputs directory`)

- Figures are sent to `outputs/figures/`.
- Regression coefficients, fit summaries, non-parametric robustness artifacts, and LaTeX representations are sent to `outputs/models/` and `outputs/tables/`.

### 7. Bootstrap-Only Refresh Utility (`R/07_run_nonparametric_bootstrap_phase.R`)

- Sets the pipeline into bootstrap-only mode for the non-parametric branch.
- Skips Tobit refits so only the non-parametric outputs are refreshed.
- Runs participant-level cluster bootstrap inference only for specifications whose full-sample non-parametric fit converged.
- Regenerates the report after the bootstrap-enhanced robustness outputs are saved.
- If too few participant-level bootstrap refits converge, the refreshed outputs are marked as sparse bootstrap inference.
- The central bootstrap default currently lives in `R/00_config.R` and is set to `10`. Change `get_default_clad_bootstrap_reps()` there if you want a different default.

### 8. Dynamic Reporting (`R/06_generate_report.R`)

- Automates clustered statistical power analysis estimating the Intraclass Correlation Coefficient (ICC) and translating repeated measures into an Effective Sample Size (ESS).
- Reads the output tables natively, detects hypothesis-relevant empathy and relational predictors that reach at least `p < .10`, generates the most suitable dynamic figure for each such predictor, then also generates an additional figure set for every significant predictor below `p < .10` in the H-model families, including significant controls such as `age`.
- The report now states Option 2 explicitly and centers the hypothesis sections on negotiator-level relational predictors rather than descriptive case labels.
- Writes compiled narrative markdown reports to `outputs/report/tobit_analysis_report.md` and `outputs/logs/dynamic_report.md`.

### 9. Journal-Style Dynamic Reporting (`R/09_generate_behavioral_economics_report.R`)

- Builds an additional compact report in a behavioral-economics article style with only four sections: Materials and Methods, Results, Limitations, and Conclusion.
- Uses the pooled analytical narrative only, while still reporting victim and bystander estimates inside the same article flow.
- Enforces a compact output plan: one design table, one concise result table per hypothesis family, and a robustness table only when the non-parametric branch is enabled.
- Reuses the 300-DPI figure assets already generated by the pipeline and selects one focal H1, H2, and H3 figure dynamically from the significance catalog.
- Writes the journal report to `outputs/report/tobit_behavioral_economics_report.md`, renders `outputs/report/tobit_behavioral_economics_report.docx`, and mirrors the markdown to `outputs/logs/behavioral_economics_report.md`.

This guarantees reproducibility from a fresh R session without requiring workspace state. All steps communicate securely through the artifacts generated in `data/processed/`.
