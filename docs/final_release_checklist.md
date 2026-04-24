# Final Release Checklist

Use this checklist before publishing a tagged public release.

## Pipeline and Model Integrity

- [ ] `run_pipeline.R` executes end-to-end on a clean environment.
- [ ] H1-H5 formulas match `R/hypotheses/H_formulas.R` active definitions.
- [ ] No unintended changes in estimator logic (`survival::survreg` two-sided Tobit branch).
- [ ] Role-specific relational semantics remain aligned with `docs/semantic_conventions.md`.

## Data and Semantics

- [ ] Input source path is documented and available.
- [ ] `target/other` semantics are explicitly documented as the only analytical frame.
- [ ] Decision naming bridge (`decision_target` -> `accept_target`, `decision_other` -> `accept_other`) is documented.
- [ ] Legacy audit variables (`group_target`, `group_other`) status is clear.

## Documentation Quality

- [ ] Root `README.md` reflects active pipeline state.
- [ ] `docs/repository_map.md` reflects active vs legacy script status.
- [ ] `docs/pipeline_overview.md` and `docs/semantic_conventions.md` are current.
- [ ] `CHANGELOG.md` updated for release.

## Release Metadata

- [ ] `LICENSE` present and correct.
- [ ] `CITATION.cff` present and current.
- [ ] `CONTRIBUTING.md` present.

## Artifact Policy

- [ ] `.gitignore` excludes local/temp artifacts but keeps intended deliverables.
- [ ] Expected output families are documented (English and Spanish report variants).

## Final Validation

- [ ] `repository_finalization_report.md` updated for this release cycle.
- [ ] No statistical logic/formula changes were introduced by documentation-only updates.


