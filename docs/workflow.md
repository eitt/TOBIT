# Workflow Logic

## Overview

The active workflow no longer reshapes a participant-wide file into a new negotiator-level dataset. Instead, it imports the already longitudinal Version 2.0 file, validates it, preserves each source row, adds role-specific relational variables, and fits H1-H5 two-sided Tobit models.

Each participant is expected to contribute 20 rows in the long file: ten scenarios multiplied by two target-negotiator judgements. The workflow preserves that structure instead of rebuilding it from a wide file.

## Execution sequence

### 1. Import

`R/01_import_data.R`

- Reads `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx`
- Verifies required columns
- Adds `source_row_number`
- Writes `data/processed/01_imported.csv`

### 2. Cleaning

`R/02_clean_data.R`

- Sorts and preserves the imported rows
- Writes `data/processed/02_cleaned.csv`
- Writes a cleaning audit confirming row preservation

### 3. Participant bridge

`R/03_transform_data.R`

- Reconstructs a participant-level wide bridge from the long dataset
- Keeps compatibility artifacts:
  - `data/processed/03_transformed_participants.csv`
  - `data/processed/participants_scored.csv`
- Writes the first version of the variable dictionary

### 4. Relational-variable construction

`R/04_generate_variables.R`

- Builds target/other faculty and relational context from each existing row
- Keeps one row as one real target-directed judgement observation, so target/other remain contextual roles rather than duplicated records
- Builds:
  - `victim_target_group`
  - `victim_other_group`
  - `bystander_victim_group`
  - `bystander_target_group`
  - `bystander_other_group`
  - `target_other_same_faculty`
  - `decision_pattern`
- Splits:
  - `judgments_analysis.csv`
  - `judgments_victim.csv`
  - `judgments_bystander.csv`
- Writes the H1-H5 formula catalog

### 5. Descriptive outputs

`R/05_descriptive_statistics.R`

- Produces participant, judgment, decision, missingness, and group summaries
- Writes observation-audit tables
- Generates basic EDA figures

### 6. H1-H5 estimation

`R/hypotheses/H1_test.R` through `R/hypotheses/H5_test.R`

- Estimate victim and bystander models separately
- Use `judgement` as the response in all cases
- Interpret `judgement` as the moral evaluation of the target negotiator while allowing `accept_target` and `accept_other` to explain that evaluation jointly
- Convert `judgement` into bilateral Tobit endpoints through `lower_endpoint` and `upper_endpoint`
- Fit `survival::survreg` with participant-cluster robust standard errors by `id`
- Represent session with `factor(session)` in every active formula
- Use role-specific ingroup/outgroup definitions, with ingroup defined by matching faculties including `control` with `control`
- Let H3 and H5 test targeted empathy x ingroup/outgroup interactions rather than only additive empathy terms
- Export a robustness note explaining why `factor(id_case)` is not run by default in the Tobit branch

### 7. Reporting

- `R/06_generate_report.R`
- `R/08_generate_plain_language_report.R`
- `R/09_generate_behavioral_economics_report.R`

These scripts assemble the fit summaries, hypothesis summaries, compliance checklist, and final dynamic reports. The main analytical report is written in markdown and then rendered to `docx` and `pdf` when Pandoc and LaTeX are available locally.

## Output structure

The pipeline writes both the traditional output folders and compatibility subfolders under `outputs/data/`:

- `01_harmonized`
- `02_eda`
- `03_sem`
- `04_qca`
- `05_clustering`
- `06_reports`

These are used as staging folders for the redesigned artifacts, not as a return to the old analytical logic.


