# Repository Map

This map identifies active, auxiliary, and legacy/non-default paths for the final public repository state.

## Active Entry Points

- `run_pipeline.R` (default orchestrator)
- `run_pipeline.ps1` (PowerShell wrapper)
- `run_pipeline.bat` (batch wrapper)

## Active Pipeline Scripts (Default Order)

1. `R/01_import_data.R`
2. `R/02_clean_data.R`
3. `R/03_transform_data.R`
4. `R/04_generate_variables.R`
5. `R/05_descriptive_statistics.R`
6. `R/hypotheses/H1_test.R`
7. `R/hypotheses/H2_test.R`
8. `R/hypotheses/H3_test.R`
9. `R/hypotheses/H4_test.R`
10. `R/hypotheses/H5_test.R`
11. `R/06_generate_report.R`
12. `R/08_generate_plain_language_report.R`
13. `R/09_generate_behavioral_economics_report.R`

## Active Core Modules

- `R/utils/prepare_consolidated_dataset.R`
- `R/utils/build_role_relational_variables.R`
- `R/utils/model_functions.R`
- `R/utils/report_dynamic_helpers.R`
- `R/utils/table_functions.R`
- `R/hypotheses/H_formulas.R`

## Auxiliary (Active but Support-Oriented)

- `docs/` methodological and semantic documentation
- `outputs/tables/` audit and summary CSVs
- `outputs/report/` rendered reports
- `outputs/figures/`, `outputs/models/`, `outputs/logs/`

## Legacy / Non-Default Paths (Retained for Traceability)

- `R/hypotheses/H2a_test.R`
- `R/hypotheses/H2b_test.R`
- `R/07_run_nonparametric_bootstrap_phase.R`
- root ad-hoc support files (`debug*.R`, `script*.py`, `py_updater.py`) 

These files are not executed by the default `run_pipeline.R` flow.

## Data and Output Directories

- Input source: `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx`
- Processed data: `data/processed/`
- Generated artifacts: `outputs/`

## Semantic Priority References

- `docs/semantic_conventions.md`
- `docs/hypotheses.md`
- `docs/datacard.md`
