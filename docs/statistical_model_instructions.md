# Statistical Model Instructions

## Primary estimator

The redesigned workflow uses a two-sided Tobit fitted through `survival::survreg`.

This choice is driven by the request to keep `judgement` as a bounded response while still respecting repeated measurements from the same participant.

Under the authoritative project specification, each participant contributes 20 judgement rows in principle, corresponding to ten scenarios and two target-negotiator evaluations per scenario.

## Core dependence structure

- Outcome treatment: bilateral censoring at `-9` and `9`
- Participant dependence adjustment: `cluster = id`
- Robust inference: `robust = TRUE`
- Session adjustment in the fitted formula: `factor(session)`

## Why the report says `factor(session)` instead of `(1|session)`

The active production branch does not fit a random-effects Tobit with `(1|session)` inside the same estimator used for the main results.

To avoid misreporting the model, the dynamic report states exactly what is estimated:

- a two-sided Tobit
- participant-cluster robust standard errors by `id`
- explicit session fixed effects through `factor(session)`

This means session-level shifts are adjusted directly, while participant-level non-independence is handled through the robust clustered variance estimator.

## Group coding

The authoritative redesign treats faculty code `0` as the `control` faculty category for negotiators, not as a missing label.

Accordingly:

- ingroup = matching faculties, including `control` with `control`
- outgroup = different faculties
- `target_other_same_faculty` indicates whether the two negotiators share faculty membership

## Rank deficiency

Some role-specific relational formulas contain cells that are not fully supported in every subset. When that happens, the design matrix becomes rank deficient.

The pipeline exports:

- the number of dropped columns
- the dropped column names
- the fitted-session handling flag

so the limitation remains visible in the fit summary.

## Robustness note

The default Tobit branch does not add `factor(id_case)` to every model because that would saturate the design with more than one thousand case dummies and destabilize the interval-censored fit.

Instead, the pipeline writes an explicit robustness note documenting that tradeoff.

## Hypothesis blocks

- H1: empathy dimensions
- H2: role-specific ingroup/outgroup structure
- H3: empathy + role-specific ingroup/outgroup structure + targeted empathy x group interactions
- H4: `decision_target`, `decision_other`, and their interaction
- H5: empathy + role-specific structure + targeted empathy x group interactions + decisions

All five hypotheses include the same sociodemographic adjustment block.

