# Data Card

## Base file

`Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx`

## Row meaning

Each row is one observed moral judgment recorded in the experiment.

- The pipeline imports 4,860 rows.
- The prepared analytical file also has 4,860 rows.
- `source_row_number` is preserved to prove that no extra rows were created during preparation.
- In substantive terms, each participant contributes 20 rows in principle: ten scenarios x two target-negotiator judgements.

## Direct source variables used as-is

- `session`
- `id`
- `id_case`
- `stage`
- `role`
- `age`
- `ses`
- `sex_female`
- `faculty_player`
- `iri_fs`
- `iri_ec`
- `iri_pt`
- `iri_pd`
- `target`
- `judgement`
- `decision_target`
- `decision_other`
- `faculty_target`
- `faculty_other`
- `faculty_victim`

## Equivalences and derived context

- `role = 1` is interpreted as `victim`
- `role = 0` is interpreted as `bystander`
- `target` is row-dynamic (`1 = N1`, `2 = N2`) and defines who is judged in that row
- `other` is the counterpart negotiator in that same row context
- In victim rows, when `faculty_victim` is empty in the source file, the pipeline uses `faculty_player` as the victim reference because the participant is the victim in that subset
- `N1_faculty` and `N2_faculty` are reconstructed from `faculty_target` and `faculty_other` without expanding the dataset again
- `N1_decision` and `N2_decision` are reconstructed from `decision_target` and `decision_other` without expanding the dataset again

## Derived variables for the redesign

### Observation audit

- `source_row_number`
  One-to-one imported row index

### Role labels

- `role_label`
  `victim` or `bystander`

- `target_label`
  `N1` or `N2`

### Negotiator context

- `N1_faculty`
- `N2_faculty`
- `N1_decision`
- `N2_decision`

### Role-specific relational variables

- `victim_N1_group`
- `victim_N2_group`
- `bystander_victim_group`
- `bystander_N1_group`
- `bystander_N2_group`
- `N1_N2_same_faculty`

### Decision context

- `decision_pattern`
  Four-value label built from `decision_target` and `decision_other`

## Coding rules

### Decisions

- `decision_target`: `0 = reject`, `1 = accept`
- `decision_other`: `0 = reject`, `1 = accept`
- Historical alias note: legacy wording `accept_target` / `accept_other` corresponds to active operational names `decision_target` / `decision_other`

### Dynamic vs structural semantics

- `target` / `other` are row-dynamic roles
- `N1` / `N2` are structural scenario slots reconstructed per row for relational modeling
- active H2/H3/H5 formulas use reconstructed role-specific relational variables, not `group_target` / `group_other` directly

### Faculty labels

- `faculty_player`: `1 = Humanities`, `2 = Engineering`
- `faculty_target` and `faculty_other`: `0 = Control`, `1 = Humanities`, `2 = Engineering`
- `faculty_victim`: `1 = Humanities`, `2 = Engineering`

### Group coding

- same faculty = `ingroup`
- different faculty = `outgroup`
- `control` with `control` also counts as `ingroup`

This applies to:

- `victim_N1_group`
- `victim_N2_group`
- `bystander_N1_group`
- `bystander_N2_group`
- `N1_N2_same_faculty`

`bystander_victim_group` still uses the same ingroup/outgroup rule, but the victim faculty is explicit in bystander rows, so no additional negotiation-side reconstruction is needed there.

## Double-counting note

`N1_faculty`, `N2_faculty`, `N1_decision`, and `N2_decision` are reconstructed inside each existing row. The pipeline does not create extra N1 rows or N2 rows, so one row remains one observed judgement throughout preparation and modeling.

## Sociodemographics included in all models

- `age`
- `ses`
- `sex_female`
- `faculty_player_factor`

## Main processed files

- `data/processed/judgments_analysis.csv`
- `data/processed/judgments_victim.csv`
- `data/processed/judgments_bystander.csv`
- `data/processed/variable_dictionary.csv`
