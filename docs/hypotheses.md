# Hypotheses Overview

## Outcome and unit

- Outcome: `judgement`
- Imported unit: one recorded moral judgment per row
- The pipeline preserves that row count one-to-one
- Each participant contributes 20 rows in principle: ten scenarios x two target-negotiator evaluations
- `judgement` is directed toward the target negotiator named in the row, but some hypotheses also use the other negotiator's decision to explain that target-directed evaluation
- `target`/`other` are row-dynamic roles; `N1`/`N2` are structural slots reconstructed per row for relational terms

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
  victim_N1_group + victim_N2_group +
  victim_N1_group:victim_N2_group +
  N1_N2_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  bystander_victim_group +
  bystander_N1_group + bystander_N2_group +
  victim_N1_group + victim_N2_group +
  bystander_N1_group:bystander_N2_group +
  victim_N1_group:victim_N2_group +
  N1_N2_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## H3

### Victim

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  victim_N1_group + victim_N2_group +
  victim_N1_group:victim_N2_group +
  iri_fs:victim_N1_group + iri_fs:victim_N2_group +
  iri_ec:victim_N1_group + iri_ec:victim_N2_group +
  iri_pt:victim_N1_group + iri_pt:victim_N2_group +
  iri_pd:victim_N1_group + iri_pd:victim_N2_group +
  N1_N2_same_faculty +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  bystander_victim_group +
  bystander_N1_group + bystander_N2_group +
  victim_N1_group + victim_N2_group +
  bystander_N1_group:bystander_N2_group +
  victim_N1_group:victim_N2_group +
  iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group +
  iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group +
  iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group +
  iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group +
  N1_N2_same_faculty +
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
  victim_N1_group + victim_N2_group +
  victim_N1_group:victim_N2_group +
  iri_fs:victim_N1_group + iri_fs:victim_N2_group +
  iri_ec:victim_N1_group + iri_ec:victim_N2_group +
  iri_pt:victim_N1_group + iri_pt:victim_N2_group +
  iri_pd:victim_N1_group + iri_pd:victim_N2_group +
  N1_N2_same_faculty +
  decision_target * decision_other +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

### Bystander

```r
survival::Surv(lower_endpoint, upper_endpoint, type = "interval2") ~
  iri_fs + iri_ec + iri_pt + iri_pd +
  bystander_victim_group +
  bystander_N1_group + bystander_N2_group +
  victim_N1_group + victim_N2_group +
  bystander_N1_group:bystander_N2_group +
  victim_N1_group:victim_N2_group +
  iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group +
  iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group +
  iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group +
  iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group +
  N1_N2_same_faculty +
  decision_target * decision_other +
  age + ses + sex_female + faculty_player_factor +
  factor(session)
```

## Coding notes

- `decision_target`: `0 = reject`, `1 = accept`
- `decision_other`: `0 = reject`, `1 = accept`
- Historical alias note: legacy wording `accept_target` / `accept_other` maps to active names `decision_target` / `decision_other`
- `victim_N1_group`, `victim_N2_group`, `bystander_N1_group`, `bystander_N2_group`:
  - `ingroup`
  - `outgroup`
- ingroup is defined by faculty coincidence, including `control` with `control`
- `bystander_victim_group`:
  - `ingroup`
  - `outgroup`
- `N1_N2_same_faculty`:
  - `same`
  - `different`
- `group_target` / `group_other` remain legacy source fields for audit/provenance and are not used directly in active H2/H3/H5 formulas

## Documentation note

Earlier notes that treated negotiator faculty code `0` as `control_hidden` or described H3 as additive-only are outdated. The active specification now treats `0` as the `control` faculty category and uses targeted empathy x group interactions in H3 and H5.
