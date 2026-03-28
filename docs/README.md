# Tobit and Cluster-Aware Non-Parametric Censored Robustness Analysis Pipeline

This repository implements a reproducible, function-oriented R pipeline for analyzing bounded moral judgments using interval-censored Tobit regression plus a distribution-robust non-parametric censored robustness check.

## Project Purpose

The goal is to estimate the causal impact of empathy (IRI) and group identity (faculty affiliation) on moral judgments of negotiators who accept harmful deals.

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
- `outputs/`: Automatically populated artifacts segmented into `tables/`, `figures/`, `models/`, and `logs/`.
- `docs/`: Technical and conceptual documentation (`datacard.md`, `hypotheses.md`, `workflow.md`).

## Execution Order

1. **01_import_data.R** - Validation and ingestion wrapper
2. **02_clean_data.R** - Label recoding and attention check flagging
3. **03_transform_data.R** - Psychometric metric scoring (IRI totals and subscales, kept on raw scales)
4. **04_generate_variables.R** - Matrix restructuring (wide to long) and scenario feature engineering
5. **05_descriptive_statistics.R** - Dataset-wide distributional outputs
6. **Hypothesis tests** - H1 through H3 standalone model runs, each generating Tobit outputs plus the cluster-aware non-parametric robustness fit, which bootstraps by participant immediately after the full-sample fit converges
7. **Bootstrap-only refresh utility** - reruns only the participant-level cluster bootstrap inference for non-parametric fits when you want to refresh those outputs without refitting Tobit

## How to Run the Full Pipeline

### Option 1: Using Windows Helper Scripts (Recommended)

If you are on Windows, you can double-click or run the following files from PowerShell/CMD. They will automatically check for R, ensure you use `Rscript`, and run the entire pipeline:

- `run_pipeline.bat` (Double-click in File Explorer or run in CMD)
- `run_pipeline.ps1` (Run in PowerShell: `.\run_pipeline.ps1`)

### Option 2: Using manual Rscript Command

```powershell
Rscript run_pipeline.R
```

This script handles all sequential evaluations, ensures all processed data tables are rebuilt, installs any missing R packages automatically, and populates the `outputs/` folder.

By default, the main pipeline fits each non-parametric model once and, if that full-sample fit converges, immediately runs participant-level cluster bootstrap inference and overwrites the CLAD tables with cluster-aware standard errors, confidence intervals, and p-values. If too few bootstrap refits converge to support full inference, the saved outputs and report label that state explicitly as sparse bootstrap inference rather than treating the model as fully inferentially usable.

If you want a faster fit-only pass, disable bootstrap first with `options(tobit.clad_run_bootstrap = FALSE)` and then use the refresh utility later.

### Bootstrap-Only Refresh Utility

```powershell
Rscript R/07_run_nonparametric_bootstrap_phase.R
```

This utility updates only the non-parametric outputs, running the participant-level cluster bootstrap for specifications whose full-sample non-parametric fit already converged. You can raise or lower the bootstrap count before running it with `options(tobit.clad_bootstrap_reps = 39L)` in R.

## How to Run a Single Hypothesis

Because each hypothesis script is modular, you can choose to run just one after data preparation is done. Example for Hypothesis 1:

```powershell
Rscript R/hypotheses/H1_test.R
```

## Main Outputs Produced

- **Tables**: `outputs/tables/` generates Letter-width wrapped `.tex` source tables, standard `.csv` aggregations, a concise `hypothesis_summary.csv` significance table, and a `hypothesis_figure_catalog.csv` index of any significance-driven report figures.
- **Figures**: `outputs/figures/` exports accessible 300dpi `.png` histograms, summary maps, and automatic significance-driven report figures for hypothesis-relevant predictors that reach at least `p < .10` in the Tobit or clustered non-parametric model.
- **Models**: `outputs/models/` writes clustered `survreg` Tobit coefficients, cluster-aware non-parametric robustness coefficients, fit summaries, and binary `.rds` fitted engines. For converged non-parametric fits, participant-level cluster-bootstrap inference is generated automatically in the default pipeline.
