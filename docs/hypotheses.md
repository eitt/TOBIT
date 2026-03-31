# Hypotheses Overview

This document links each theoretical hypothesis to the executable pipeline scripts under Option 2: judgment-level relational modeling.

Option 2 means the analysis is defined at the judgment-by-negotiator level. Each participant evaluates two negotiators per scenario, so each participant-scenario pair contributes two judgment observations.

## Judgment Unit and Moral-Judgment Severity

Let:

- `i` = participant
- `s` = scenario
- `j in {1, 2}` = judged negotiator
- `r in {Victim, Bystander}` = participant role in that scenario

The dependent variable is:

- `judgement_{isjr}`

It is observed on the bounded scale `-9` to `9`.

- Lower values mean more severe condemnation.
- Higher values mean greater appropriateness / lower severity.

For each participant-scenario pair:

- `judgement_{is1r}` = judgment of negotiator 1
- `judgement_{is2r}` = judgment of negotiator 2

Thus the same vignette contributes two judgment rows because each negotiator is evaluated separately.

The Tobit and non-parametric censored models treat this as a bounded judgment outcome:

- `judgement = -9` when the latent judgment is at or below the lower bound
- `judgement = 9` when the latent judgment is at or above the upper bound
- interior values are treated as exact

## Role-Dependent Relational Coding

The meaning of ingroup and outgroup depends on the participant role.

### Victim subset

When the participant is the victim, ingroup/outgroup/control is defined relative to the victim-player.

The core relational pieces are:

- `group_negotiator_judged in {In, Out, Cont}`
- `group_negotiator_counterpart in {In, Out, Cont}`

### Bystander subset

When the participant is an observer, ingroup/outgroup/control for negotiators is defined relative to `faculty_player`, and the victim is also coded relative to that same player.

The core relational pieces are:

- `group_negotiator_judged in {In, Out, Cont}`
- `group_negotiator_counterpart in {In, Out, Cont}`
- `group_victim in {In, Out}`

Only negotiators can be `Cont`. The victim is always coded only as `In` or `Out`.

## Generated Relational Variables Used in the Code

The preprocessing pipeline creates these H2-relevant variables in `R/04_generate_variables.R`:

- `h2_negotiator_structure`
  Joint structure of the judged negotiator and the counterpart negotiator within the same judgment row.
- `player_victim_alignment`
  Observer-side victim relation to the player (`In` or `Out`).
- `player_victim_outgroup`
  Binary version of the player-victim relation for the bystander H2 interaction.
- `faculty_player_obs`
  Alias for the observing player's faculty in observer rows, kept explicit so the bystander-side H2 coding is easy to audit.

The reference structure for `h2_negotiator_structure` is:

- `J_In__C_In`

meaning judged negotiator ingroup and counterpart negotiator ingroup.

## H1

- Script: `R/hypotheses/H1_test.R`
- Dependent variable: `judgement`
- Main idea: empathy predicts judgment severity after conditioning on judged-negotiator status, counterpart status, decision outcome, and observer-side victim alignment when applicable.
- Estimation: separate models for the `Victim` and `Bystander` subsets with subset-specific formulas

H1 always retains the sociodemographic controls:

- `sex_man`
- `age`
- `economic_status`

Victim-subset H1 keeps:

- `judged_outgroup`
- `judged_control`
- `counterpart_outgroup`
- `counterpart_control`
- `decision_accept`
- `participant_engineering`
- `sex_man`
- `age`
- `economic_status`
- `factor(negotiator_slot)`

Bystander-subset H1 keeps the same block plus:

- `observer_victim_outgroup`

This means H1 no longer carries observer-only predictors into victim-only models.

## H2

- Script: `R/hypotheses/H2_test.R`
- Dependent variable: `judgement`
- Estimation: separate models for the `Victim` and `Bystander` subsets
- Judgment unit: one row per judged negotiator, so every scenario contributes two H2 observations

### H2 in the Victim subset

The victim-subset H2 model tests whether judgment severity varies with the joint ingroup/outgroup/control structure of:

- the judged negotiator
- the counterpart negotiator

relative to the victim-player.

Victim-subset equation:

```text
judgement*_{isj,Victim} = beta0 + beta1 * Empathy_i + gamma' * S^(V)_{isj} + delta' * Z_i + error
```

where:

- `S^(V)_{isj}` = dummies for `h2_negotiator_structure`
- `Z_i` = participant controls

In the executable code:

- Model A adds `iri_total`
- Model B replaces that with `iri_fs + iri_ec + iri_pt + iri_pd`
- Both models retain `participant_engineering`, `sex_man`, `age`, `economic_status`, and `factor(negotiator_slot)`

### H2 in the Bystander subset

The bystander-subset H2 model tests whether judgment severity varies with:

1. the negotiator-side structure of the judged negotiator plus the counterpart negotiator
2. the ingroup/outgroup relation between the player and the victim
3. the interaction between those two relational components

Bystander-subset equation:

```text
judgement*_{isj,Obs} = beta0 + beta1 * Empathy_i + gamma' * S^(O)_{isj} + eta * V_{is} + theta' * (S^(O)_{isj} x V_{is}) + delta' * Z_i + error
```

where:

- `S^(O)_{isj}` = bystander-side dummies for `h2_negotiator_structure`
- `V_{is}` = `player_victim_outgroup`
- `Z_i` = participant controls

In the executable code:

- Model A adds `iri_total`
- Model B replaces that with `iri_fs + iri_ec + iri_pt + iri_pd`
- Both models retain `participant_engineering`, `sex_man`, `age`, `economic_status`, and `factor(negotiator_slot)`

### Interpretation of H2

H2 is no longer a judged-status-by-decision hypothesis.

It is now a relational-structure hypothesis:

- In `Victim`, H2 compares joint judged-plus-counterpart structures relative to the victim-player.
- In `Bystander`, H2 compares those same joint negotiator structures and asks whether their effect changes when the player and victim are aligned versus misaligned.

## H3

- Script: `R/hypotheses/H3_test.R`
- Dependent variable: `judgement`
- Main idea: empathy slopes vary across judged-negotiator status after retaining the judged-status, decision, judged-status-by-decision, and relational-control block
- Estimation: separate models for the `Victim` and `Bystander` subsets with subset-specific formulas

H3 still uses:

- `judged_outgroup`
- `judged_control`
- `decision_accept`
- `decision_accept:judged_outgroup`
- `decision_accept:judged_control`
- empathy-by-judged-status interactions

In addition:

- both subsets retain `counterpart_outgroup`, `counterpart_control`, `participant_engineering`, `sex_man`, `age`, `economic_status`, and `factor(negotiator_slot)`
- only the bystander subset retains `observer_victim_outgroup`

So, as with H1, H3 avoids carrying observer-only predictors into victim-only estimation.

## Dynamic Report and Summary Tables

The dynamic report and exported hypothesis summary tables are generated from the saved model outputs and the hypothesis metadata in `R/utils/hypothesis_metadata.R`.

For the updated H2 definition, the summary tables and figures can now surface:

- negotiator-side structure contrasts from `h2_negstruct_*`
- `player_victim_outgroup`
- `player_victim_outgroup:h2_negstruct_*` interactions

This keeps the H2 tables, figures, and narrative aligned with the actual subset-specific formulas used by the pipeline.

## Compact Labels in Tables and Figures

The dynamic report shortens predictor labels inside regression tables and figures so H2 and H3 remain readable. The main conventions are:

- `JN` = judged negotiator
- `CN` = counterpart negotiator
- `V` = victim-side player-victim relation in observer models
- `Vic` = victim subset
- `Obs` = bystander / observer subset
- `In`, `Out`, `Ctl` = ingroup, outgroup, control label hidden
- `Acc`, `Rej` = accepted or rejected harmful deal
- `FS`, `EC`, `PT`, `PD` = the four IRI subscales
- `SES` = economic status

The auto report includes a predictor glossary table and repeats the abbreviation note immediately below each regression table.
