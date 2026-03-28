# Hypotheses Overview

This document links each theoretical hypothesis to its executable pipeline script under **Option 2: explicit case-configuration modeling**.

Option 2 means the analysis does not rely only on separate indicators such as `perp_outgroup` and `victim_outgroup` when the question is relational. Instead, each judgment is represented through an explicit victim x negotiator case configuration. The victim label appears first and the judged negotiator appears second, yielding scenario factors such as:

- `Hum_x_Hum`
- `Hum_x_Ing`
- `Hum_x_Control`
- `Ing_x_Hum`
- `Ing_x_Ing`
- `Ing_x_Control`

Role (`Observer` / `Victim`) and decision context (`Accept` / `Reject`) may further condition these scenarios through `case_configuration_role`, `case_configuration_decision`, and `case_configuration_context`.

## H1 (Empathy under explicit case configuration)
- **Script**: `R/hypotheses/H1_test.R`
- **Theoretical Expectation**: Higher empathy predicts lower moral-judgment scores for harmful decisions after conditioning on explicit victim x negotiator case configurations.
- **Dependent Variable**: `judgement` (bounded score: -9 to 9)
- **Primary Terms**: `iri_total` in Model A; `iri_fs`, `iri_ec`, `iri_pt`, and `iri_pd` in Model B
- **Relational Controls**: accepted-sample case-configuration contrasts relative to `Hum_x_Hum`
- **Additional Controls**: `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Tobit uses cluster-robust standard errors by participant `id`; the non-parametric robustness branch first fits the full-sample interval-censored median model and, if it converges, immediately adds participant-level cluster bootstrap inference. In both cases, `id` is only a clustering unit.

## H2a (Relational betrayal contrasts)
- **Script**: `R/hypotheses/H2a_test.R`
- **Theoretical Expectation**: Same-faculty and cross-faculty betrayal cases should be compared through explicit victim x negotiator configurations rather than a single `same_group_harm` indicator.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Primary Terms**: betrayal-sample case contrasts relative to `Hum_x_Hum`, namely `Hum_x_Ing`, `Ing_x_Hum`, and `Ing_x_Ing`
- **Additional Controls**: `iri_total` or empathy subscales, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Same participant-level clustering rule as H1.

## H2b (Explicit case-configuration contrasts)
- **Script**: `R/hypotheses/H2b_test.R`
- **Theoretical Expectation**: Judgments should be interpreted through explicit relational contrasts such as `Hum_x_Ing`, `Hum_x_Control`, `Ing_x_Hum`, `Ing_x_Ing`, and `Ing_x_Control`, not through a single outgroup-perpetrator indicator.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Primary Terms**: accepted-sample case contrasts relative to `Hum_x_Hum`
- **Additional Controls**: `iri_total` or empathy subscales, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Same participant-level clustering rule as H1.

## H3 (Empathy x case-configuration moderation)
- **Script**: `R/hypotheses/H3_test.R`
- **Theoretical Expectation**: The empathy effect may vary across explicit victim x negotiator pairings, so moderation is tested through empathy x case-configuration interactions.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Primary Terms**: `iri_total` x accepted-sample case contrasts in Model A; empathy-subscale x accepted-sample case contrasts in Model B
- **Additional Controls**: main effects for empathy and case configuration, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Same participant-level clustering rule as H1.

## Dynamic Summary Table

The reporting pipeline exports `outputs/tables/hypothesis_summary.csv`, a concise table that lists each hypothesis alongside the hypothesis-relevant predictors that reach at least `p < .10` in the Tobit model and in the cluster-aware non-parametric robustness model. Under Option 2, those significant predictors are explicit case-configuration terms or empathy x case-configuration interactions whenever the hypothesis is relational.

Whenever that table contains at least one significance marker, the dynamic report also generates a matching visualization in `outputs/figures/` and records it in `outputs/tables/hypothesis_figure_catalog.csv`. Continuous predictors receive effect plots, categorical case-configuration factors receive grouped prediction plots, and interaction terms receive interaction plots. These report figures always treat `id` only as the clustering unit for inference.
