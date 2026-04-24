# How To Read The New Models

## Direction of coefficients

The outcome is `judgement`.

- Negative coefficient: movement toward harsher condemnation
- Positive coefficient: movement toward a more positive evaluation

Because the model is a two-sided Tobit, the coefficients describe pressure on the latent judgment tendency while the observed scale remains bounded between `-9` and `9`.

## Reference logic

### Relational factors

- `victim_target_group`
- `victim_other_group`
- `bystander_target_group`
- `bystander_other_group`

In the authoritative redesign, ingroup means faculty coincidence, including `control` with `control`. So a coefficient like `victim_other_groupoutgroup` compares outgroup against the ingroup baseline.

### Bystander-victim relation

`bystander_victim_groupoutgroup` compares outgroup against ingroup.

### Target/Other context

`target_other_same_facultysame` compares same-faculty against different-faculty.

## Decision effects

- `decision_target`
  Effect of the judged negotiator accepting rather than rejecting
- `decision_other`
  Effect of the other negotiator accepting rather than rejecting
- `decision_target:decision_other`
  Extra effect when both decisions are considered jointly

## Role-specific interpretation

### Victim models

Read `victim_target_group` and `victim_other_group` as the victim's relation to each negotiator separately.

### Bystander models

Read:

- `bystander_victim_group`
- `bystander_target_group`
- `bystander_other_group`
- `victim_target_group`
- `victim_other_group`

as separate pieces of the same social context.

## Repeated-measures note

The inferential target is not a set of independent rows. The pipeline keeps the original repeated observations, estimates a two-sided Tobit, adjusts participant dependence with cluster-robust standard errors by `id`, and includes `factor(session)` directly in the fitted formula.

The dynamic report uses `factor(session)` on purpose. It does not claim `(1|session)` because that is not the model actually estimated in the active Tobit branch.

Each participant contributes 20 judgement rows in principle: ten scenarios times two target-negotiator evaluations. The pipeline preserves those rows and keeps target/other context inside each existing row instead of duplicating observations.

