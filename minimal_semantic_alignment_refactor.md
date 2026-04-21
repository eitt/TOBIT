# Purpose

Apply a minimal, controlled, and auditable semantic-alignment refactor so that naming and documentation clearly distinguish row-dynamic target/other roles from reconstructed structural N1/N2 slots, without changing the active statistical logic.

# Scope of the minimal refactor

This refactor only updates documentation, labels, comments, and audit tables.

Included:

- Clarified active naming (`decision_target`/`decision_other`) versus legacy wording (`accept_target`/`accept_other`)
- Clarified row-dynamic (`target`/`other`) versus structural (`N1`/`N2`) semantics
- Clarified legacy audit status of `group_target`/`group_other`
- Added a small mapping-audit artifact for target-to-slot decision reconstruction
- Marked legacy utility path to prevent semantic confusion

Excluded:

- No formula changes
- No estimator changes
- No H1-H5 structural changes
- No row-level data transformation logic changes

# Files changed

1. `R/utils/build_role_relational_variables.R`
2. `R/utils/prepare_consolidated_dataset.R`
3. `R/utils/report_dynamic_helpers.R`
4. `R/06_generate_report.R`
5. `docs/datacard.md`
6. `docs/hypotheses.md`
7. `R/utils/model_functions.R`

New file:

8. `minimal_semantic_alignment_refactor.md`

# What was clarified

- Added explicit comments that `target` is row-dynamic and N1/N2 are reconstructed structural slots per row.
- Added explicit alias note that legacy `accept_target`/`accept_other` corresponds to active `decision_target`/`decision_other`.
- Expanded base variable dictionary coverage to include `target`, `judgement`, `decision_target`, and `decision_other` with semantic notes.
- Refined `group_target` and `group_other` dictionary notes as legacy row-relative provenance fields not directly used in active H2/H3/H5 formulas.
- Updated report symbol dictionary and glossary definitions to reduce naming ambiguity.
- Added report audit table logic (`build_target_slot_mapping_audit`) with explicit rules:
  - if `target == 1`: `N1_decision = decision_target`, `N2_decision = decision_other`
  - if `target == 2`: `N1_decision = decision_other`, `N2_decision = decision_target`
- Inserted terminology and semantic notes in the dynamic report build (`R/06_generate_report.R`).
- Marked `R/utils/model_functions.R` as legacy/non-active path for the current production branch.

# What was intentionally not changed

- No changes to `R/hypotheses/H_formulas.R`.
- No changes to model estimation functions used by active H1-H5 execution (`R/utils/mixed_model_functions.R`).
- No changes to run order in `run_pipeline.R`.
- No changes to predictor sets, interactions, censoring bounds, clustering, or session handling.
- No deletion of legacy columns from source/processed datasets.

# Risk assessment

Overall risk: low.

Why low:

- Changes are documentation-facing and audit-facing.
- Core statistical code paths and formulas are untouched.
- Added audit table is read-only and derived from already generated processed data.

Residual operational risk:

- Runtime verification via `Rscript` could not be executed in this shell session because `Rscript` was not available in PATH at execution time.

# Remaining legacy elements

- `R/utils/model_functions.R` remains in repository for backward compatibility and historical tooling.
- It still contains older term mappings and wording patterns that are not authoritative for the current active pipeline branch.
- Legacy source fields (`group_target`, `group_other`, `obs_group`) remain present for audit/provenance and compatibility.

# Suggested future refactor (not executed)

1. Introduce a dedicated semantic registry file (single source of truth) for variable aliases and active/legacy status.
2. Add an automated post-processing audit test that fails when target-to-slot reconstruction checks do not pass.
3. Move legacy utilities into an explicit `legacy/` namespace or add lint checks preventing accidental active-path imports.
4. Standardize human-readable labels across all report generators from one shared helper.
