# Hypotheses Overview

This document links each distinct theoretical hypothesis to its executable pipeline test script.

## H1 (Empathy effect)
- **Script**: `R/hypotheses/H1_test.R`
- **Theoretical Expectation**: Higher empathy predicts lower moral-judgment scores for harmful decisions.
- **Dependent Variable**: `judgement` (Bounded score: -9 to 9)
- **Independent Variable**: `iri_total` (Raw empathy composite average)
- **Control Variables**: `perp_outgroup`, `perp_control`, `victim_outgroup`, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `stage` (fixed effect), `negotiator_slot` (fixed effect)
- **Inference Structure**: Tobit uses cluster-robust standard errors by participant `id`; the non-parametric robustness branch first fits the full-sample interval-censored median model and, if it converges, immediately adds participant-level cluster bootstrap inference. In both cases, `id` is only a clustering unit.
- **Outputs Produced**: Tobit outputs (`H1_A_coefficients.csv`, `H1_A_fit_stats.csv`, `H1_A_model.rds`, etc.) plus non-parametric robustness counterparts (`H1_A_CLAD_coefficients.csv`, `H1_A_CLAD_fit_stats.csv`, `H1_A_CLAD_model.rds`, etc.)

## H2a (Ingroup betrayal hypothesis)
- **Script**: `R/hypotheses/H2a_test.R`
- **Theoretical Expectation**: Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Independent Variable**: `same_group_harm` (1 = Negotiator harms victim of the same labeled faculty)
- **Control Variables**: `iri_total`, `perp_outgroup`, `victim_outgroup`, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `stage`, `negotiator_slot`
- **Inference Structure**: Same participant-level clustering rule as H1.
- **Outputs Produced**: Tobit outputs plus non-parametric robustness counterparts for both Model A and Model B.

## H2b (Outgroup derogation hypothesis)
- **Script**: `R/hypotheses/H2b_test.R`
- **Theoretical Expectation**: Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Independent Variable**: `perp_outgroup` (1 = Negotiator belongs to evaluator's outgroup opposing faction)
- **Control Variables**: Same as H1
- **Inference Structure**: Same participant-level clustering rule as H1.
- **Outputs Produced**: Tobit outputs plus non-parametric robustness counterparts for both Model A and Model B.

## H3 (Empathy x group moderation)
- **Script**: `R/hypotheses/H3_test.R`
- **Theoretical Expectation**: The negative association between empathy and moral-judgment scores should be stronger (more negative) in outgroup cases than in ingroup cases.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Independent Variable**: `iri_total * perp_outgroup` (Interaction term using the raw empathy composite and outgroup status)
- **Control Variables**: Same as H1
- **Inference Structure**: Same participant-level clustering rule as H1.
- **Outputs Produced**: Tobit outputs plus non-parametric robustness counterparts for both Model A and Model B.

## Dynamic Summary Table

The reporting pipeline also exports `outputs/tables/hypothesis_summary.csv`, a concise table that lists each hypothesis alongside the hypothesis-relevant predictors that reach at least `p < .10` in the Tobit model and in the cluster-aware non-parametric robustness model. Human-readable predictor labels are used where available, with `+`, `*`, and `**` marking `p < .10`, `p < .05`, and `p < .01`, respectively. If bootstrap is explicitly disabled for a run, too few participant-level bootstrap refits converge, or the non-parametric fit does not converge, the non-parametric column reports that status rather than being interpreted inferentially.

Whenever that table contains at least one significance marker, the dynamic report also generates a matching visualization in `outputs/figures/` and records it in `outputs/tables/hypothesis_figure_catalog.csv`. Continuous predictors receive effect plots, binary or categorical predictors receive grouped prediction plots, and interaction terms receive interaction plots. These report figures always treat `id` only as the clustering unit for inference.
