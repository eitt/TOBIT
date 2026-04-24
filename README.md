# TOBIT: Longitudinal Moral Judgement Pipeline

This repository implements a reproducible analytical pipeline for moral judgement modeling in a structured negotiation experiment.

The active production workflow uses a two-sided Tobit strategy on longitudinal judgement data, with role-specific relational predictors and hypothesis-driven model blocks (H1-H5).

## Project Context

The project studies how participants assign moral judgement to a focal negotiator under repeated observations.

Core design points:

- Outcome: `judgement` (bounded scale, modeled as two-sided censored outcome).
- Observational structure: one imported row remains one real target-judgement observation.
- Role-specific logic: Victim and Bystander models are estimated separately.
- Hypothesis architecture: H1-H5, from empathy and group alignment to decision and integrated models.
- Relational terms: reconstructed per row from dynamic target/other roles.

## Active Pipeline Status

The current active branch is defined by:

- `judgement` as the modeled outcome in all hypothesis models.
- Active operational decision names: `accept_target`, `accept_other`.
- Source compatibility names retained as legacy columns: `decision_target`, `decision_other`.
- Row-dynamic role semantics: `target` and `other` are dynamic per observation.
- Dynamic-role semantics: `target` and `other` are the analytical pair inside each row.
- `group_target` and `group_other` are retained as legacy/audit source fields and are **not** the active H2/H3/H5 relational predictors.

## Repository Structure

```text
TOBIT/
+- R/
  +- 00_config.R
  +- 01_import_data.R ... 06_generate_report.R
  +- 08_generate_plain_language_report.R
  +- 09_generate_behavioral_economics_report.R
  +- hypotheses/
  +- H1_test.R ... H5_test.R (active)
  +- H2a_test.R, H2b_test.R (legacy/non-default)
  +- H_formulas.R
  +- utils/
  +- build_role_relational_variables.R
  +- prepare_consolidated_dataset.R
  +- report/table/model helper modules
+- data/
  +- processed/ (pipeline-generated analytical datasets)
+- outputs/
  +- figures/
  +- models/
  +- tables/
  +- logs/
  +- report/ (dynamic reports)
+- docs/
  +- repository_map.md
  +- pipeline_overview.md
  +- semantic_conventions.md
  +- final_release_checklist.md
  +- existing methodological docs
+- run_pipeline.R
+- run_pipeline.ps1
+- run_pipeline.bat
+- Version 2.0/ (source dataset directory)
```

## How To Run

Primary entrypoint:

```r
source("run_pipeline.R", encoding = "UTF-8")
```

Default active order (from `run_pipeline.R`):

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

## Requirements

- R (project tested with modern R 4.x).
- Required packages (checked by `ensure_pipeline_dependencies()`):
  - `readxl`
  - `survival`
- Optional for DOCX/PDF rendering:
  - `pandoc`
  - LaTeX engine (e.g., MiKTeX `pdflatex`)

## Main Outputs

Core analytical datasets:

- `data/processed/judgments_analysis.csv`
- `data/processed/judgments_victim.csv`
- `data/processed/judgments_bystander.csv`

Core analytical reporting outputs (English):

- `outputs/report/tobit_analysis_report.md`
- `outputs/report/tobit_analysis_report.docx`
- `outputs/report/tobit_analysis_report.pdf`

Parallel Spanish dynamic reporting outputs:

- `outputs/report/tobit_analysis_report_es.md`
- `outputs/report/tobit_analysis_report_es.docx`
- `outputs/report/tobit_analysis_report_es.pdf`

Additional report families:

- `outputs/report/tobit_plain_language_guide.md`
- `outputs/report/tobit_behavioral_economics_report.md`

Audit-oriented outputs:

- `outputs/tables/hypothesis_formula_catalog.csv`
- `outputs/tables/hypothesis_summary.csv`
- `outputs/tables/model_fit_summary.csv`
- `outputs/tables/pipeline_compliance_report.csv`
- `auditoria_codificacion_ingroup_outgroup_es.md`

## Semantic Notes (Critical)

- Source/legacy column `decision_target` -> active analytical name `accept_target`.
- Source/legacy column `decision_other` -> active analytical name `accept_other`.
- `target`/`other`: row-dynamic actor roles.
- `target`/`other`: row-dynamic analytical roles used for relational context.
- `group_target`/`group_other`: retained for source audit/provenance, not active relational predictors in H2/H3/H5.

## Active vs Legacy Paths

Active/default path is the orchestrator `run_pipeline.R` and its script list.

Legacy or non-default elements that remain in repository for traceability:

- `R/hypotheses/H2a_test.R`
- `R/hypotheses/H2b_test.R`
- `R/07_run_nonparametric_bootstrap_phase.R` (not part of default run order)
- ad-hoc local debug/support files in repository root (`debug*.R`, `script*.py`, etc.)

These are retained to avoid breaking local historical workflows but are not part of the final default pipeline run order.

## Documentation Index

See:

- `docs/repository_map.md`
- `docs/pipeline_overview.md`
- `docs/semantic_conventions.md`
- `docs/final_release_checklist.md`

## Language Convention

Official project language is English. Some audit/report artifacts are intentionally generated in Spanish as parallel deliverables.

## License, Citation, Contact

- License: see `LICENSE`.
- Citation metadata: see `CITATION.cff`.
- Project maintainer/contact should be maintained in `CITATION.cff` and release notes.


