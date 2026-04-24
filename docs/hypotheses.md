# Hypotheses Overview

## Outcome and unit

- Outcome: `judgement`
- Imported unit: one recorded moral judgment per row
- The pipeline preserves that row count one-to-one
- Each participant contributes 20 rows in principle: ten scenarios x two target-negotiator evaluations
- `judgement` is directed toward the target negotiator named in the row, but some hypotheses also use the other negotiator's decision to explain that target-directed evaluation
- `target`/`other` are row-dynamic roles and the active relational pair used throughout the formulas

## Core covariates in every model

- `age`
- `ses`
- `sex_female`
- `faculty_player_factor`

## Estimation structure

- Estimator: two-sided Tobit through `survival::survreg`
- Bilateral censoring:
  - lower side: `judgement <= -9`
  - upper side: `judgement >= 9`
- Participant dependence adjustment: `cluster = id`, `robust = TRUE`
- Session adjustment in every active formula: `factor(session)`
- Default robustness note: `factor(id_case)` is documented but not run by default because the saturated Tobit would be unstable

## H1

### Victim

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## H2

### Victim

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  victim_target_group + victim_other_group +
  victim_target_group:victim_other_group +
  target_other_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  bystander_victim_group +
  bystander_target_group + bystander_other_group +
  victim_target_group + victim_other_group +
  bystander_target_group:bystander_other_group +
  victim_target_group:victim_other_group +
  target_other_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## H3

### Victim

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  victim_target_group + victim_other_group +
  victim_target_group:victim_other_group +
  iri_fs:victim_target_group + iri_fs:victim_other_group +
  iri_ec:victim_target_group + iri_ec:victim_other_group +
  iri_pt:victim_target_group + iri_pt:victim_other_group +
  iri_pd:victim_target_group + iri_pd:victim_other_group +
  target_other_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  bystander_victim_group +
  bystander_target_group + bystander_other_group +
  victim_target_group + victim_other_group +
  bystander_target_group:bystander_other_group +
  victim_target_group:victim_other_group +
  iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group +
  iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group +
  iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group +
  iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group +
  target_other_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## H4

### Victim

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  decision_target * decision_other +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  decision_target * decision_other +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## H5

### Victim

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  victim_target_group + victim_other_group +
  victim_target_group:victim_other_group +
  iri_fs:victim_target_group + iri_fs:victim_other_group +
  iri_ec:victim_target_group + iri_ec:victim_other_group +
  iri_pt:victim_target_group + iri_pt:victim_other_group +
  iri_pd:victim_target_group + iri_pd:victim_other_group +
  target_other_same_faculty +
  decision_target * decision_other +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  bystander_victim_group +
  bystander_target_group + bystander_other_group +
  victim_target_group + victim_other_group +
  bystander_target_group:bystander_other_group +
  victim_target_group:victim_other_group +
  iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group +
  iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group +
  iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group +
  iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group +
  target_other_same_faculty +
  decision_target * decision_other +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## Coding notes

- `decision_target`: `0 = reject`, `1 = accept`
- `decision_other`: `0 = reject`, `1 = accept`
- Historical alias note: legacy wording `accept_target` / `accept_other` maps to active names `decision_target` / `decision_other`
- `victim_target_group`, `victim_other_group`, `bystander_target_group`, `bystander_other_group`:
  - `ingroup`
  - `outgroup`
- ingroup is defined by faculty coincidence, including `control` with `control`
- `bystander_victim_group`:
  - `ingroup`
  - `outgroup`
- `target_other_same_faculty`:
  - `same`
  - `different`
- `group_target` / `group_other` remain legacy source fields for audit/provenance and are not used directly in active H2/H3/H5 formulas

## Documentation note

Earlier notes that treated negotiator faculty code `0` as `control_hidden` or described H3 as additive-only are outdated. The active specification now treats `0` as the `control` faculty category and uses targeted empathy x group interactions in H3 and H5.

