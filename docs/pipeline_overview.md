# Pipeline Overview

## Purpose

The TOBIT pipeline produces reproducible longitudinal moral judgement analyses using a two-sided Tobit framework with role-specific relational predictors.

## Active Analytical Core

- Outcome: `judgement`
- Dynamic decision predictors: `decision_target`, `decision_other`
- Dynamic row roles: `target`, `other`
- Analytical pair: `target`, `other`
- Role-specific relational predictors for H2/H3/H5
- Session adjustment: `factor(session)`
- Participant dependence adjustment: cluster-robust inference by `id`

## Script Flow

Default execution (via `run_pipeline.R`):

1. import source data
2. clean while preserving rows
3. build participant-level bridge artifacts
4. construct relational variables and split role datasets
5. compute descriptive statistics and figures
6. estimate H1-H5 (Victim and Bystander)
7. generate dynamic analytical reports
8. generate plain-language and behavioral-economics companion reports

## Input

- `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx`

## Key Generated Data

- `data/processed/judgments_analysis.csv`
- `data/processed/judgments_victim.csv`
- `data/processed/judgments_bystander.csv`
- `outputs/tables/hypothesis_formula_catalog.csv`

## Key Reports

English dynamic report:
- `outputs/report/tobit_analysis_report.md`
- `outputs/report/tobit_analysis_report.docx`
- `outputs/report/tobit_analysis_report.pdf`

Spanish dynamic report (parallel):
- `outputs/report/tobit_analysis_report_es.md`
- `outputs/report/tobit_analysis_report_es.docx`
- `outputs/report/tobit_analysis_report_es.pdf`

## Reproducibility Notes

- The orchestrator clears generated artifacts before a new run.
- One imported row remains one real judgement observation.
- Legacy audit variables are retained for traceability but not used directly as active H2/H3/H5 relational predictors.

