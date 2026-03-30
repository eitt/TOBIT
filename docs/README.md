# Tobit and Cluster-Aware Non-Parametric Censored Robustness Analysis Pipeline

This repository implements a reproducible, function-oriented R pipeline for analyzing bounded moral judgments using interval-censored Tobit regression plus a distribution-robust non-parametric censored robustness check.

The project now adopts **Option 2: judgment-level relational modeling** across the full workflow. The executable models use explicit negotiator-level predictors for judged-negotiator status, counterpart status, observer-side victim alignment, and, where required by the hypothesis, decision outcome (`Accept` / `Reject`) and its interaction with judged-negotiator status.

## Project Purpose

The goal is to estimate the impact of empathy (IRI) and relational structure on moral judgments of negotiators who accept or reject harmful deals using negotiator-level ingroup/outgroup/control predictors.

## Data Sources

The primary inputs are located in `data/raw/`:

- `data_final_FLORIDA.xlsx`
- `data_final_BUC.xlsx`

## Repository Structure

The project has been reorganized into a strict function-oriented architecture:

- `data/`: Contains `raw/` inputs and `processed/` analytical datasets.
- `R/`: Contains step-by-step data preparation scripts (`01_import_data.R` to `05_descriptive_statistics.R`).
- `R/utils/`: Safe, modular, and shared utilities for IO, transformation, modeling, and output formatting.
- `R/hypotheses/`: Hypothesis estimation scripts that fit both the primary Tobit model and the non-parametric robustness companion for each specification (`H1_test.R`, `H2a_test.R`, etc.).
- `R/07_run_nonparametric_bootstrap_phase.R`: Bootstrap-only refresh utility that updates only the non-parametric outputs with participant-level cluster bootstrap inference and then refreshes the report without refitting Tobit.
- `R/08_generate_plain_language_report.R`: Companion report generator that writes a simpler study guide covering the data card, hypothesis wording, variable creation rules, and regression codings.
- `outputs/`: Automatically populated artifacts segmented into `tables/`, `figures/`, `models/`, and `logs/`.
- `docs/`: Technical and conceptual documentation (`datacard.md`, `hypotheses.md`, `workflow.md`).

## Execution Order

1. **01_import_data.R** - Validation and ingestion wrapper
2. **02_clean_data.R** - Label recoding and attention check flagging
3. **03_transform_data.R** - Psychometric metric scoring (IRI totals and subscales, kept on raw scales)
4. **04_generate_variables.R** - Matrix restructuring (wide to long) and scenario feature engineering, including Option 2 negotiator-level relational variables
5. **05_descriptive_statistics.R** - Dataset-wide distributional outputs
6. **Hypothesis tests** - H1 through H3 standalone model runs, each generating Tobit outputs plus the cluster-aware non-parametric robustness fit, using judged-status, decision, and relational-control terms rather than descriptive case labels
7. **Bootstrap-only refresh utility** - reruns only the participant-level cluster bootstrap inference for non-parametric fits when you want to refresh those outputs without refitting Tobit
8. **Plain-language guide** - generated after the main report so the project also exports a simpler explanation of the data card, hypotheses, variable creation, and model codings

## How to Run the Full Pipeline

### Option 1: Using Windows Helper Scripts (Recommended)

If you are on Windows, you can double-click or run the following files from PowerShell/CMD. They will automatically check for R, ensure you use `Rscript`, and run the entire pipeline:

- `run_pipeline.bat` (Double-click in File Explorer or run in CMD)
- `run_pipeline.ps1` (Run in PowerShell: `.\run_pipeline.ps1`)

### Manual Rscript Command

```powershell
Rscript run_pipeline.R
```

This script handles all sequential evaluations, ensures all processed data tables are rebuilt, installs any missing R packages automatically, clears the existing generated artifacts under `outputs/` at the start of the run, and then repopulates the `outputs/` folder from scratch.

For quicker test cycles, the import step now applies a reproducible random participant-level sample by default. The central default in `R/00_config.R` is `10%` of the imported dataset with a fixed seed. Set `options(tobit.dataset_sample_fraction = 1)` (or `100`) when you want to keep the full dataset.

By default, the main pipeline fits each non-parametric model once and, if that full-sample fit converges, immediately runs participant-level cluster bootstrap inference and overwrites the CLAD tables with cluster-aware standard errors, confidence intervals, and p-values. If too few bootstrap refits converge to support full inference, the saved outputs and report label that state explicitly as sparse bootstrap inference rather than treating the model as fully inferentially usable.

The central bootstrap default is currently `10` replicates in `R/00_config.R` via `get_default_clad_bootstrap_reps()`. Change that single value there if you want a different default for future runs.

If you want a faster fit-only pass, disable bootstrap first with `options(tobit.clad_run_bootstrap = FALSE)` and then use the refresh utility later.

### Bootstrap-Only Refresh Utility

```powershell
Rscript R/07_run_nonparametric_bootstrap_phase.R
```

This utility updates only the non-parametric outputs, running the participant-level cluster bootstrap for specifications whose full-sample non-parametric fit already converged. You can override the central default temporarily with `options(tobit.clad_bootstrap_reps = ...)` in R, but the repository debug default currently comes from `R/00_config.R`.

## How to Run a Single Hypothesis

Because each hypothesis script is modular, you can choose to run just one after data preparation is done. Example for Hypothesis 1:

```powershell
Rscript R/hypotheses/H1_test.R
```

## Main Outputs Produced

- **Tables**: `outputs/tables/` generates Letter-width wrapped `.tex` source tables, standard `.csv` aggregations, a concise `hypothesis_summary.csv` significance table keyed to hypothesis-relevant relational terms, a `hypothesis_figure_catalog.csv` index of hypothesis-target figures, and an `all_significant_figure_catalog.csv` index covering every predictor below `p < .10` in the H-model families.
- **Figures**: `outputs/figures/` exports accessible 300dpi `.png` histograms, summary maps, hypothesis-target figures, and broader significant-predictor figures for controls and interactions such as `age` when they reach at least `p < .10` in the Tobit or clustered non-parametric model.
- **Models**: `outputs/models/` writes clustered `survreg` Tobit coefficients, cluster-aware non-parametric robustness coefficients, fit summaries, and binary `.rds` fitted engines. For converged non-parametric fits, participant-level cluster-bootstrap inference is generated automatically in the default pipeline.
- **Reports**: `outputs/report/` now includes both the main technical report and a simpler companion file, `tobit_plain_language_guide.md` (plus `.docx` when Pandoc is available).
