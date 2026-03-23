# Tobit Analysis Pipeline

This repository implements a reproducible, function-oriented R pipeline for analyzing bounded moral judgments using Tobit regression models.

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
- `R/hypotheses/`: Isolated Tobit estimation scripts for each distinct hypothesis (`H1_test.R`, `H2a_test.R`, etc.).
- `outputs/`: Automatically populated artifacts segmented into `tables/`, `figures/`, `models/`, and `logs/`.
- `docs/`: Technical and conceptual documentation (`datacard.md`, `hypotheses.md`, `workflow.md`).

## Execution Order

1. **01_import_data.R** - Validation and ingestion wrapper
2. **02_clean_data.R** - Label recoding and attention check flagging
3. **03_transform_data.R** - Psychometric metric scoring (IRI totals and z-scores)
4. **04_generate_variables.R** - Matrix restructuring (wide to long) and scenario feature engineering
5. **05_descriptive_statistics.R** - Dataset-wide distributional outputs
6. **Hypothesis tests** - H1 through H3 standalone model runs

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

## How to Run a Single Hypothesis

Because each hypothesis script is modular, you can choose to run just one after data preparation is done. Example for Hypothesis 1:

```powershell
Rscript R/hypotheses/H1_test.R
```

## Main Outputs Produced

- **Tables**: `outputs/tables/` generates Letter-width wrapped `.tex` source tables and standard `.csv` aggregations.
- **Figures**: `outputs/figures/` exports accessible 300dpi `.png` histograms and summary maps.
- **Models**: `outputs/models/` writes clustered `survreg` coefficients, model specifications, and binary `.rds` fitted engines.
