# Repository Guide

## Active pipeline

The project now runs a longitudinal two-sided Tobit workflow centered on:

- `judgement` as the dependent variable
- `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` as the sole analytical input
- 20 long-format judgement rows per participant in principle
- separate victim and bystander specifications
- participant-level dependence handled with cluster-robust standard errors by `id`
- session adjustment through `factor(session)`
- H1-H5 instead of the earlier empathy-only emphasis
- role-specific group coding where ingroup means matching faculties, including `control` with `control`

## Key folders

- `R/`: executable pipeline scripts
- `R/utils/`: dataset preparation, relational-variable construction, and Tobit helpers
- `R/hypotheses/`: H1-H5 scripts and shared formula catalog
- `data/processed/`: processed analytical datasets used by the pipeline
- `outputs/`: generated tables, figures, model files, logs, and dynamic reports
- `docs/`: source documentation for the active redesign

## Main run order

1. `R/01_import_data.R`
2. `R/02_clean_data.R`
3. `R/03_transform_data.R`
4. `R/04_generate_variables.R`
5. `R/05_descriptive_statistics.R`
6. `R/hypotheses/H1_test.R` through `R/hypotheses/H5_test.R`
7. `R/06_generate_report.R`
8. `R/08_generate_plain_language_report.R`
9. `R/09_generate_behavioral_economics_report.R`

## Main outputs

- `data/processed/judgments_analysis.csv`
- `data/processed/judgments_victim.csv`
- `data/processed/judgments_bystander.csv`
- `outputs/tables/hypothesis_formula_catalog.csv`
- `outputs/tables/hypothesis_summary.csv`
- `outputs/tables/model_fit_summary.csv`
- `outputs/tables/pipeline_compliance_report.csv`
- `outputs/report/tobit_analysis_report.md`
- `outputs/report/tobit_analysis_report.docx`
- `outputs/report/tobit_analysis_report.pdf`
- `outputs/report/tobit_plain_language_guide.md`
- `outputs/report/tobit_behavioral_economics_report.md`

## Compatibility note

`participants_scored.csv` and `03_transformed_participants.csv` are still generated as bridge artifacts so downstream local tools keep finding the expected files, but the authoritative inferential workflow now comes from the longitudinal judgment files and H1-H5 Tobit models.
