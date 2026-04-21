# Purpose
Create a parallel Spanish version of the dynamic report outputs while preserving the active English workflow and keeping all statistical logic unchanged.

# Files modified
- `R/06_generate_report.R`
- `R/utils/report_dynamic_helpers.R`
- `spanish_dynamic_report_generation.md` (new)

# Strategy used for minimal internationalization
- Kept the existing English report generation path intact.
- Added language-aware helper support in report-text functions (`lang = "en" | "es"`) in `R/utils/report_dynamic_helpers.R`.
- In `R/06_generate_report.R`, kept the English `report_lines` build and added a controlled Spanish parallel build (`report_lines_es`) from the same computed tables, coefficients, formulas, and figures.
- Added a rendering tag option in `render_dynamic_report_outputs()` so Spanish render artifacts can be tracked separately (`*_es`) without replacing English logs.

# What was translated
- Report title and major section headers.
- Methodological prose and explanatory text blocks.
- Semantic bridge/reminder text and row-level mapping explanation.
- Discussion and conclusion sections.
- Figure captions/interpretive narrative shown in the Spanish report.
- Compliance-report markdown companion text (`pipeline_compliance_report_es.md`).

# What intentionally remains in English
- Variable names and model terms (for example: `decision_target`, `decision_other`, `target`, `other`, `N1`, `N2`, `group_target`, `group_other`, `iri_fs`, etc.).
- Model formulas and predictor codes.
- Internal pipeline file/object names and model artifact names.

# Statistical integrity confirmation
No modeling logic was changed.
- No H1-H5 formula changes.
- No estimator changes.
- No coefficient-computation changes.
- No data-transformation changes in the modeling pipeline.
- Numerical tables/figures are sourced from the same computed artifacts.

# Final generated files
Primary Spanish outputs:
- `outputs/report/tobit_analysis_report_es.md`
- `outputs/report/tobit_analysis_report_es.docx`
- `outputs/report/tobit_analysis_report_es.pdf`

Parallel copies in reports data directory:
- `outputs/data/06_reports/tobit_analysis_report_es.md`
- `outputs/data/06_reports/tobit_analysis_report_es.docx`
- `outputs/data/06_reports/tobit_analysis_report_es.pdf`
- `outputs/data/06_reports/longitudinal_mixed_model_analysis_report_es.md`

Additional Spanish companion:
- `outputs/report/pipeline_compliance_report_es.md`
- `outputs/data/06_reports/pipeline_compliance_report_es.md`
