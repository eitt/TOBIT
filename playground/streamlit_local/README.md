# TOBIT Local Streamlit Playground

This folder remains a local exploratory app. It is not the authoritative inferential pipeline.

## Current relationship to the main project

- The main repository pipeline now uses the Version 2.0 consolidated long dataset and two-sided Tobit models for H1-H5.
- Session is handled in the main analytical branch through `factor(session)`, while participant dependence is adjusted with cluster-robust standard errors by `id`.
- This playground stays available for local inspection and teaching.
- The app code was intentionally left untouched by the redesign unless compatibility required bridge files.

## What stayed compatible

- `data/processed/participants_scored.csv`
- `data/processed/03_transformed_participants.csv`

The redesigned pipeline still writes those bridge files so the playground can keep finding expected inputs.

## Important scope note

The Streamlit playground is still exploratory. The authoritative results now come from:

- `outputs/report/tobit_analysis_report.md`
- `outputs/report/tobit_analysis_report.docx`
- `outputs/report/tobit_analysis_report.pdf`
- `outputs/report/tobit_plain_language_guide.md`
- `outputs/report/tobit_behavioral_economics_report.md`
- `outputs/tables/pipeline_compliance_report.csv`

## Reused docs

The Notes tab can still display repository documentation from:

- `docs/statistical_model_instructions.md`
- `docs/workflow.md`
- `docs/hypotheses.md`
- `docs/datacard.md`

Those docs now describe the longitudinal H1-H5 Tobit redesign rather than the earlier aggregated-IRI-centered workflow.
