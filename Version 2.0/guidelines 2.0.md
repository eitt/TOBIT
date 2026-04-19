# Version 2.0 Guidelines

## Base dataset

The redesign uses only:

`Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx`

## Analytical unit

- Each imported row is one recorded moral judgment.
- Each participant contributes 20 rows in principle: ten scenarios multiplied by two target-negotiator evaluations.
- The pipeline preserves those rows one-to-one through `source_row_number`.
- No additional long reshaping is performed.
- This avoids introducing new double counting during preparation.

## Outcome

- Primary dependent variable: `judgement`
- Observed scale: `-9` to `9`
- Lower values = harsher condemnation
- Higher values = more positive evaluation
- Active estimator: two-sided Tobit with bilateral censoring at the observed scale limits

## Repeated-measures structure

- Participants evaluate multiple stages, so observations are not independent.
- The active Tobit branch handles participant dependence with cluster-robust standard errors by `id`.
- Session is modeled as `factor(session)` in every fitted formula.
- The report explicitly explains `factor(session)` instead of `(1|session)` because the production pipeline is not fitting a random-effects Tobit with a session intercept.
- The pipeline also exports a robustness note explaining why `factor(id_case)` is not run by default in the saturated Tobit specification.

## Two-negotiator context

- `N1` and `N2` are contextual entities, not extra sample-size multipliers created by the pipeline.
- The source file already contains one judgment per row, plus the contextual information needed to reconstruct N1 and N2.
- `judgement` is the evaluation of the target negotiator named in that row.
- `decision_target` and `decision_other` remain row-specific and preserve the four core decision patterns:
  - both accept
  - both reject
  - target accepts / other rejects
  - target rejects / other accepts

## Role-specific ingroup / outgroup logic

### Victim models

The active variables are:

- `victim_N1_group`
- `victim_N2_group`
- `N1_N2_same_faculty`

`victim_N1_group * victim_N2_group` is the only default relational interaction block.

For H3 and H5, the active specification also tests targeted empathy x victim-N1 and empathy x victim-N2 interactions.

### Bystander models

The active variables are:

- `bystander_victim_group`
- `bystander_N1_group`
- `bystander_N2_group`
- `victim_N1_group`
- `victim_N2_group`
- `N1_N2_same_faculty`

The first interaction blocks considered are:

- `bystander_N1_group * bystander_N2_group`
- `victim_N1_group * victim_N2_group`

No default interaction with `N1_N2_same_faculty` is added.

For H3 and H5, the active specification also tests targeted empathy x bystander-victim and empathy x bystander-negotiator interactions.

## Faculty coding

Negotiator faculty code `0` is treated as the `control` faculty category. Therefore:

- humanities with humanities = ingroup
- engineering with engineering = ingroup
- control with control = ingroup
- different categories = outgroup

## Hypothesis families

- H1: empathy dimensions only + sociodemographics
- H2: role-specific ingroup/outgroup structure + sociodemographics
- H3: empathy + role-specific ingroup/outgroup structure + targeted empathy x group interactions + allowed relational interactions + sociodemographics
- H4: `decision_target`, `decision_other`, and their interaction + sociodemographics
- H5: empathy + role-specific ingroup/outgroup structure + targeted empathy x group interactions + decisions + allowed interactions + sociodemographics

## Sociodemographics included in all models

- `age`
- `ses`
- `sex_female`
- `faculty_player_factor`

## Main implementation note

The repository now prioritizes a longitudinal Tobit workflow. The older aggregated-IRI logic is no longer the main analytical path.
