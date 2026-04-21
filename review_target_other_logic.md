# Executive summary

The active pipeline preserves row-level target semantics and does not duplicate observations.

Main findings:

- `accept_target` does not appear in active code, processed tables, model formulas, or current output artifacts. The active predictor is `decision_target` (0 = reject, 1 = accept).
- `target` remains dynamic by row (N1/N2 depending on observation), and `judgement` is consistently interpreted as judgement of that row's target negotiator.
- The N1/N2 variables used in models are reconstructed row-wise from `target` + `faculty_target/faculty_other` and `decision_target/decision_other`.
- `group_target`/`group_other` are retained in data as legacy source fields for audit, but active H2/H3/H5 models use reconstructed role-specific relational variables (`victim_N1_group`, `bystander_N1_group`, etc.), not `group_target`/`group_other` directly.
- There is no evidence of row duplication in current output (`4860` imported rows, `4860` analytical rows, `0` duplicated source row ids).
- Semantic risk still exists at interpretation level: N1/N2 naming can be misread as fixed-row coding unless readers notice the reconstruction logic.

# Answer to question 1: accept_target

Short answer: in the active branch, `accept_target` is not used; the operational variable is `decision_target`.

Evidence:

- No `accept_target` string was found in current repo code or current output files (`R`, `docs`, `outputs/report`, `outputs/data/06_reports`, `outputs/tables`, `outputs/models`).
- H4/H5 formulas explicitly use `decision_target * decision_other` in:
  - `R/hypotheses/H_formulas.R` (line 66 and formula rows at 84-87)
  - `outputs/tables/hypothesis_formula_catalog.csv` (H4/H5 rows)
- Current model output still shows strong significance for `decision_target` in H4/H5 (victim and bystander):
  - `outputs/models/H4_Victim_primary_coefficients.csv`
  - `outputs/models/H4_Bystander_primary_coefficients.csv`
  - `outputs/models/H5_Victim_primary_coefficients.csv`
  - `outputs/models/H5_Bystander_primary_coefficients.csv`
- `outputs/tables/report_role_significance_summary.csv` reports `Target accepted***` for H4 and H5 in both roles.

Interpretation:

- Functionally, the acceptance concept is present and highly active in the models, but under the name `decision_target` rather than `accept_target`.
- With current evidence, this is a naming replacement in active usage (or prior external naming), not an omission of the target-acceptance construct.

# Answer to question 2: group_target/group_other vs N1/N2

Short answer: the dynamic row logic is preserved, but active modeling moved from legacy role-relative fields (`group_target/group_other`) to reconstructed structural context (`N1/N2`) and role-specific relational variables.

What is preserved:

- Row-dynamic `target` semantics are preserved.
- N1/N2 are reconstructed per row using `target` conditionals, not assumed fixed as `target == N1` always.

Core evidence in code:

- `R/utils/build_role_relational_variables.R`:
  - `target_label <- ifelse(target == 1, "N1", "N2")` (line 56)
  - `N1_faculty <- ifelse(target == 1, faculty_target, faculty_other)` (line 63)
  - `N2_faculty <- ifelse(target == 1, faculty_other, faculty_target)` (line 64)
  - `N1_decision <- ifelse(target == 1, decision_target, decision_other)` (line 65)
  - `N2_decision <- ifelse(target == 1, decision_other, decision_target)` (line 66)

What changed semantically in active models:

- H2/H3/H5 do not use `group_target/group_other`; they use reconstructed relations such as `victim_N1_group`, `victim_N2_group`, `bystander_N1_group`, etc. (`R/hypotheses/H_formulas.R`).
- The variable dictionary explicitly marks `group_target/group_other` as legacy audit fields, not main predictors:
  - `R/utils/prepare_consolidated_dataset.R` lines 209-210
  - `data/processed/variable_dictionary.csv` rows for `group_target` and `group_other`

Important nuance:

- `group_target/group_other` in source data are 3-level coded (`0,1,2`, effectively control/ingroup/outgroup), while reconstructed model relations are 2-level (`ingroup/outgroup`) with control-control handled through faculty matching rules.
- So this is not just a cosmetic rename; it is a modeling choice to re-encode relational structure around N1/N2 + role-specific mappings.
- Direct check on `data/processed/judgments_analysis.csv` shows perfect alignment for legacy coding:
  - `group_target`: `0 -> control (1657)`, `1 -> ingroup (1609)`, `2 -> outgroup (1594)`
  - `group_other`: `0 -> control (1657)`, `1 -> ingroup (1609)`, `2 -> outgroup (1594)`

# Data semantics expected

Expected conceptual semantics (aligned with your criteria):

- `target` is dynamic by row and points to the judged negotiator in that row.
- `judgement` is the participant's moral judgement of that row's `target`.
- `decision_target` is the decision of the row's judged negotiator.
- `decision_other` is the decision of the counterpart negotiator in that same case-row context.
- `target/other` are row-dynamic roles.
- `N1/N2` are fixed structural negotiator slots within a scenario.

Observed implementation in active code:

- The pipeline keeps dynamic `target/other` at row level, then reconstructs fixed-slot N1/N2 context inside each row (without row duplication) for role-specific modeling.

# Trace of variables across the repository

| Variable/original concept | Current name in code/output | File(s) | How it is used | Risk or ambiguity detected |
|---|---|---|---|---|
| Row-dynamic target slot | `target` + `target_label` | `R/utils/build_role_relational_variables.R`, `data/processed/judgments_analysis.csv` | `target_label` created as N1/N2; drives row-wise N1/N2 reconstruction | Low technical risk; interpretation risk if reader assumes N1 fixed by row |
| Outcome judgement on row target | `judgement` | `R/utils/mixed_model_functions.R`, `R/hypotheses/H_formulas.R`, outputs reports | Dependent variable in all H1-H5 Tobit models | Low |
| Target decision (accept/reject) | `decision_target` | `R/hypotheses/H_formulas.R`, `R/utils/mixed_model_functions.R`, model CSVs | H4/H5 main and interaction term | Low |
| Other negotiator decision | `decision_other` | Same as above | H4/H5 main and interaction term | Low |
| Historical/expected name for target acceptance | `accept_target` | Not found in active tree/output | Not used in current branch | Medium communication risk (naming discontinuity) |
| Legacy group for row target | `group_target` | Source schema, `prepare_consolidated_dataset`, processed data | Retained for audit only; not used in active H2/H3/H5 formulas | Medium semantic confusion risk |
| Legacy group for row other | `group_other` | Same as above | Retained for audit only; not used in active H2/H3/H5 formulas | Medium semantic confusion risk |
| Structural negotiator faculty context | `N1_faculty`, `N2_faculty` | `build_role_relational_variables.R` | Reconstructed from target/other fields per row | Low if documented |
| Structural negotiator decisions | `N1_decision`, `N2_decision` | `build_role_relational_variables.R` | Reconstructed from row-dynamic decision fields per row | Low if documented |
| Active relational predictors | `victim_N1_group`, `victim_N2_group`, `bystander_*`, `N1_N2_same_faculty` | `build_role_relational_variables.R`, `H_formulas.R` | Main H2/H3/H5 relational blocks | Medium interpretive risk vs legacy `group_target/group_other` naming |
| Legacy modeling utilities (not active pipeline path) | `model_functions.R` mappings for `group_target/group_other` etc. | `R/utils/model_functions.R` | Appears legacy and unsourced by `run_pipeline.R` | High confusion risk if read as active logic |

# Detailed findings by file

## `run_pipeline.R`

- Active execution path is explicit and linear: import -> clean -> transform -> variable generation -> descriptive -> H1-H5 -> dynamic report -> auxiliary reports.
- No direct call to legacy `R/utils/model_functions.R` in this pipeline entrypoint.

## `R/01_import_data.R`

- Imports `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx`.
- Validates required columns and preserves `source_row_number`.

## `R/utils/prepare_consolidated_dataset.R`

- Requires source columns including `target`, `judgement`, `decision_target`, `decision_other`, `group_target`, `group_other`.
- `build_variable_dictionary()` labels `group_target/group_other` as legacy audit fields, not main active H2/H3/H5 predictors.
- `reconstruct_participant_bridge()` uses `target==1/2` to reconstruct stage-level N1/N2 participant summary fields.

## `R/04_generate_variables.R`

- Calls `build_role_relational_variables()` to produce `judgments_analysis`, victim subset, bystander subset.
- Appends derived dictionary entries explicitly documenting N1/N2 reconstruction from target/other fields.

## `R/utils/build_role_relational_variables.R`

- Key semantic bridge from row-dynamic target/other to fixed-slot N1/N2 context.
- Uses `ifelse(target == 1, ..., ...)` reconstruction for faculty and decisions.
- Creates role-specific group predictors used in modeling.
- Creates `decision_pattern` from `decision_target` + `decision_other`.

## `R/hypotheses/H_formulas.R`

- H4/H5 use `decision_target * decision_other`.
- H2/H3/H5 use role-specific reconstructed relational variables (N1/N2 based), not `group_target/group_other`.

## `R/utils/mixed_model_functions.R`

- Active Tobit estimation utility used by `H1_test.R` to `H5_test.R`.
- Term labeling maps `decision_target` to `Target accepted` and `decision_other` to `Other negotiator accepted`.
- No `accept_target` variable path.

## `R/05_descriptive_statistics.R`

- Uses `decision_pattern` and reconstructed relational variables for summaries.
- Does not build active inferential summaries from `group_target/group_other`.

## `R/06_generate_report.R` and `R/utils/report_dynamic_helpers.R`

- Dynamic report text and symbol dictionary reinforce active semantics:
  - `judgement` on target actor
  - `decision_target` and `decision_other`
  - N1/N2 context reconstructed within rows
- Report formulas and figures align with active H1-H5 catalog.

## `data/processed/variable_dictionary.csv`

- Confirms explicit audit-only status for `group_target` and `group_other`.
- Confirms derived role-specific/N1-N2 variables used in analysis.

## `outputs/tables/hypothesis_formula_catalog.csv`

- Current output formulas include `decision_target`/`decision_other`.
- No `accept_target` and no direct `group_target/group_other` in H1-H5 active formulas.

## `R/utils/model_functions.R` (legacy)

- Contains older mapping logic and labels involving `group_target/group_other` and "control label hidden" wording.
- Not in active `run_pipeline.R` execution path, but present in repo and can confuse conceptual reading.

# Consistency assessment

Overall assessment: observation-by-observation target logic is preserved in the active branch.

Evidence summary:

- Row preservation: import rows = analysis rows = `4860`; duplicated source rows = `0` (`outputs/tables/observation_audit.csv`).
- Case pairing preserved: each `id_case` appears exactly 2 times in processed analysis data.
- Reconstruction consistency checks on current processed file:
  - `target==1`: `N1_decision==decision_target` and `N2_decision==decision_other` for all rows.
  - `target==2`: `N1_decision==decision_other` and `N2_decision==decision_target` for all rows.
  - Same zero-mismatch result for `N1_faculty/N2_faculty` mapping from `faculty_target/faculty_other`.

Conclusion:

- No evidence that active code incorrectly freezes `target` to N1 or `other` to N2.
- Active semantic shift is at predictor design level (legacy role-relative groups -> reconstructed role-specific N1/N2 relational blocks), not at row-target identity assignment.

# Potential semantic risks before any refactor

- N1/N2 labels in tables and formulas may be interpreted as fixed row identities rather than reconstructed context if not read with datacard notes.
- Coexistence of legacy `group_target/group_other` columns and active reconstructed predictors can lead analysts to assume they are interchangeable when they are not.
- Legacy unused code (`R/utils/model_functions.R`) includes outdated language (e.g., control-hidden wording) that can contradict active documentation.
- Absence of explicit `accept_target -> decision_target` alias note in final report can create confusion for readers expecting historical naming.
- Active recoding of relational groups to ingroup/outgroup (with control-control handling) may not match expectations of users who think in original 3-level source coding.

# Recommendation

Technical recommendation before any refactor:

1. Keep the active row-dynamic target logic as-is (it is internally consistent and auditable).
2. Add a short explicit semantic bridge note in report metadata and docs: `accept_target` (legacy naming) corresponds to active `decision_target`.
3. Add one small audit table in outputs showing row-level equivalence checks (`target` vs reconstructed `N1/N2` decisions/faculties) to reduce interpretation risk.
4. Mark legacy files (especially `R/utils/model_functions.R`) as non-active or archive-deprecated to prevent conceptual drift.
5. If you need strict continuity with `group_target/group_other` semantics, decide explicitly whether models should remain in reconstructed N1/N2 relational space or return to row-relative target/other group predictors; do not mix both narratives implicitly.

