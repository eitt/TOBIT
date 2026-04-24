# Purpose

This migration updates the active analytical pipeline so that `accept_target` and `accept_other` are the operational decision names, while preserving compatibility with source columns `decision_target` and `decision_other`.

# Files modified

## Core pipeline and formulas
- `R/utils/build_role_relational_variables.R`
- `R/hypotheses/H_formulas.R`
- `R/04_generate_variables.R`
- `R/utils/mixed_model_functions.R`

## Report generation and semantics
- `R/utils/report_dynamic_helpers.R`
- `R/06_generate_report.R`
- `R/08_generate_plain_language_report.R`
- `R/09_generate_behavioral_economics_report.R`

## Documentation
- `README.md`
- `docs/datacard.md`
- `docs/hypotheses.md`
- `docs/pipeline_overview.md`
- `docs/semantic_conventions.md`
- `docs/statistical_model_instructions.md`
- `docs/final_release_checklist.md`

# Compatibility decision (`decision_*` -> `accept_*`)

- Source dataset compatibility is preserved.
- Source columns remain available: `decision_target`, `decision_other`.
- Active analytical aliases are created early:
  - `accept_target = decision_target`
  - `accept_other = decision_other`
- Active formulas, model outputs, glossaries, and report narratives now use `accept_target` / `accept_other`.
- `decision_pattern` is retained as a compatibility-friendly derived name, but now derives from `accept_target` and `accept_other`.

# H1-H5 formulas before and after

## Before (active pre-migration)
- H1: empathy block + controls
- H2: relational block + controls
- H3: empathy + relational + interactions + controls
- H4: `decision_target * decision_other` + controls
- H5: integrated block + `decision_target * decision_other` + controls

## After (active now)
- H1: empathy block + `accept_target * accept_other` + controls
- H2: relational block + `accept_target * accept_other` + controls
- H3: empathy + relational + interactions + `accept_target * accept_other` + controls
- H4: `accept_target * accept_other` + controls
- H5: integrated block + `accept_target * accept_other` + controls

# Changes in English and Spanish reports

Both dynamic reports now consistently show:
- `accept_target` and `accept_other` as active names
- formulas H1-H5 with `accept_target * accept_other`
- semantic bridge text: source legacy `decision_target` / `decision_other` -> active `accept_target` / `accept_other`
- updated H2/H4/H5 semantic reminders with the new naming bridge

Regenerated outputs include:
- `outputs/report/tobit_analysis_report.md`, `.docx`, `.pdf`
- `outputs/report/tobit_analysis_report_es.md`, `.docx`, `.pdf`

# Changes in tables, glossaries, and technical outputs

Updated layers include:
- formula catalog (`hypothesis_formula_catalog.csv`)
- model fit summary (`model_fit_summary.csv`)
- coefficient tables and labels
- report symbol dictionary and predictor glossary
- compliance checklist text and checks

The compliance criterion now verifies `accept_target` and `accept_other` across all H1-H5 formulas, not only H4/H5.

# Plotting, focal terms, and interpretation helpers

- Model term labeling now maps `accept_target`, `accept_other`, and `accept_target:accept_other`.
- Significance figures and captions now reference `accept_*` terms.
- Report interpretation helpers and semantic bridge sections were updated to avoid mixed active/legacy naming.

# What was intentionally kept intact

The migration did **not** change:
- outcome definition (`judgement`)
- estimator family (two-sided Tobit via `survival::survreg`)
- censoring bounds (`-9`, `9`)
- participant-cluster robust inference (`cluster = id`)
- session adjustment (`factor(session)`)
- role split (`Victim` / `Bystander`)
- target/other relational construction logic

# Pending minor items

- Legacy/non-default utility paths remain in the repository for traceability and may still contain historical naming conventions.
- They are not part of the active default run order (`run_pipeline.R`).

# Final verification

- Pipeline execution: successful end-to-end via `run_pipeline.R`.
- Formula check: all H1-H5 role formulas include `accept_target * accept_other`.
- Model check: all saved model formulas include `accept_target` and `accept_other`.
- Report check: English and Spanish dynamic reports reflect active `accept_*` naming and legacy `decision_*` compatibility notes.