# Semantic Conventions

This document defines the active semantic conventions for interpretation and maintenance.

## Dynamic Roles

- `target`: row-dynamic judged negotiator in that observation.
- `other`: row-dynamic counterpart negotiator in that same observation.

## Decision Naming Bridge

- Legacy/intuitive: `accept_target`
- Active operational: `decision_target`

- Legacy/intuitive: `accept_other`
- Active operational: `decision_other`

## Row Mapping Rules

If `target == 1`, the judged actor corresponds to source code `1` and the counterpart to source code `2`.
If `target == 2`, the judged actor corresponds to source code `2` and the counterpart to source code `1`.

In both cases:
- `decision_target` is the judged actor decision in that row.
- `decision_other` is the counterpart decision in that row.
- `target_faculty` and `other_faculty` remain the analytical faculty pair.

## Group Coding

The active grouping logic is based on faculty equality:
- `ingroup` when faculties match
- `outgroup` when faculties differ
- includes `Control == Control` as `ingroup`

## Active Relational Predictors for H2/H3/H5

- `victim_target_group`
- `victim_other_group`
- `bystander_victim_group`
- `bystander_target_group`
- `bystander_other_group`
- `target_other_same_faculty`

## Legacy Audit Fields

- `group_target`
- `group_other`

These are retained for source provenance/audit and are not active relational predictors in H2/H3/H5 formulas.

## Canonical Code Paths

- `R/utils/build_role_relational_variables.R`
- `R/04_generate_variables.R`
- `R/hypotheses/H_formulas.R`

