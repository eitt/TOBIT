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
- `target` is row-dynamic (`1` or `2`) and defines who is judged in that row
- `other` is the counterpart negotiator in that same row context
- In victim rows, when `faculty_victim` is empty in the source file, the pipeline uses `faculty_player` as the victim reference because the participant is the victim in that subset
- `target_faculty` and `other_faculty` are reconstructed from `faculty_target` and `faculty_other` without expanding the dataset again
- Source-file decision columns `decision_target` and `decision_other` are retained for compatibility, and the active analytical aliases are `accept_target` and `accept_other`

## Derived variables for the redesign

### Observation audit

- `source_row_number`
  One-to-one imported row index

### Role labels

- `role_label`
  `victim` or `bystander`

- `target_code_label`
  `target_code_1` or `target_code_2`

### Negotiator context

- `target_faculty`
- `other_faculty`

### Role-specific relational variables

- `victim_target_group`
- `victim_other_group`
- `bystander_victim_group`
- `bystander_target_group`
- `bystander_other_group`
- `target_other_same_faculty`

### Decision context

- `decision_pattern`
  Four-value label built from `accept_target` and `accept_other`

## Coding rules

### Decisions

- `accept_target`: `0 = reject`, `1 = accept`
- `accept_other`: `0 = reject`, `1 = accept`
- Source compatibility note: legacy/source columns `decision_target` / `decision_other` map to active operational names `accept_target` / `accept_other`

### Dynamic semantics

- `target` / `other` are row-dynamic roles
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

- `victim_target_group`
- `victim_other_group`
- `bystander_target_group`
- `bystander_other_group`
- `target_other_same_faculty`

`bystander_victim_group` still uses the same ingroup/outgroup rule, but the victim faculty is explicit in bystander rows, so no additional negotiation-side reconstruction is needed there.

## Double-counting note

`target_faculty` and `other_faculty` are kept inside each existing row. The pipeline does not create extra negotiator rows, so one row remains one observed judgement throughout preparation and modeling.

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


