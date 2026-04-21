# Semantic Conventions

This document defines the active semantic conventions for interpretation and maintenance.

## Dynamic vs Structural Roles

- `target`: row-dynamic judged negotiator in that observation.
- `other`: row-dynamic counterpart negotiator in that same observation.
- `N1` / `N2`: structural scenario slots reconstructed inside each row for relational modeling.

Important: `target` is not a fixed alias of `N1`, and `other` is not a fixed alias of `N2`.

## Decision Naming Bridge

- Legacy/intuitive: `accept_target`
- Active operational: `decision_target`

- Legacy/intuitive: `accept_other`
- Active operational: `decision_other`

## Reconstruction Rules (Per Row)

If `target == 1`:
- `N1_decision = decision_target`
- `N2_decision = decision_other`
- `N1_faculty = faculty_target`
- `N2_faculty = faculty_other`

If `target == 2`:
- `N1_decision = decision_other`
- `N2_decision = decision_target`
- `N1_faculty = faculty_other`
- `N2_faculty = faculty_target`

## Group Coding

The active grouping logic is based on faculty equality:
- `ingroup` when faculties match
- `outgroup` when faculties differ
- includes `Control == Control` as `ingroup`

## Active Relational Predictors for H2/H3/H5

- `victim_N1_group`
- `victim_N2_group`
- `bystander_victim_group`
- `bystander_N1_group`
- `bystander_N2_group`
- `N1_N2_same_faculty`

## Legacy Audit Fields

- `group_target`
- `group_other`

These are retained for source provenance/audit and are not active relational predictors in H2/H3/H5 formulas.

## Canonical Code Paths

- `R/utils/build_role_relational_variables.R`
- `R/04_generate_variables.R`
- `R/hypotheses/H_formulas.R`
