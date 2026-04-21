# Contributing Guide

Thank you for contributing to TOBIT.

## Scope

This repository contains a finalized analytical pipeline for longitudinal two-sided Tobit modeling of moral judgement.

Contributions should preserve:
- active H1-H5 formula definitions,
- active estimator choices,
- row-level observational semantics,
- reproducibility of default pipeline outputs.

## Getting Started

1. Clone the repository.
2. Install required R packages (`readxl`, `survival`).
3. Run:

```r
source("run_pipeline.R", encoding = "UTF-8")
```

## Contribution Types

Preferred:
- documentation improvements,
- reproducibility/tooling improvements,
- bug fixes that do not alter intended model logic,
- tests/audits for data semantics and pipeline consistency.

High-impact changes (require explicit maintainer approval):
- estimator changes,
- H1-H5 formula changes,
- changes to semantic definitions (`target/other` vs `N1/N2`),
- changes affecting published numerical results.

## Style and Safety Rules

- Keep variable names and model terms in English.
- Preserve active semantic conventions documented in `docs/semantic_conventions.md`.
- Do not remove legacy files without documenting migration implications.
- Do not commit local environment folders or temporary artifacts.

## Pull Request Checklist

- [ ] Pipeline runs end-to-end with `run_pipeline.R`.
- [ ] No unintended statistical/model changes.
- [ ] Documentation updated if behavior or outputs changed.
- [ ] Legacy/active status updated in `docs/repository_map.md` if relevant.
- [ ] Changelog entry added.

## Reporting Issues

When opening an issue, include:
- script path(s),
- expected vs observed behavior,
- reproducible steps,
- relevant output/log file paths.
