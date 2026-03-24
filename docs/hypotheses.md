# Hypotheses Overview

This document links each distinct theoretical hypothesis to its executable pipeline test script.

## H1 (Empathy effect)
- **Script**: `R/hypotheses/H1_test.R`
- **Theoretical Expectation**: Higher empathy predicts lower moral-judgment scores for harmful decisions.
- **Dependent Variable**: `judgement` (Bounded score: -9 to 9)
- **Independent Variable**: `iri_total` (Raw empathy composite average)
- **Control Variables**: `perp_outgroup`, `perp_control`, `victim_outgroup`, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `stage` (fixed effect), `negotiator_slot` (fixed effect)
- **Outputs Produced**: Tobit outputs (`H1_A_coefficients.csv`, `H1_A_fit_stats.csv`, `H1_A_model.rds`, etc.) plus CLAD robustness counterparts (`H1_A_CLAD_coefficients.csv`, `H1_A_CLAD_fit_stats.csv`, `H1_A_CLAD_model.rds`, etc.)

## H2a (Ingroup betrayal hypothesis)
- **Script**: `R/hypotheses/H2a_test.R`
- **Theoretical Expectation**: Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Independent Variable**: `same_group_harm` (1 = Negotiator harms victim of the same labeled faculty)
- **Control Variables**: `iri_total`, `perp_outgroup`, `victim_outgroup`, `role_observer`, `participant_engineering`, `sex_man`, `age`, `economic_status`, `stage`, `negotiator_slot`
- **Outputs Produced**: Tobit outputs plus CLAD robustness counterparts for both Model A and Model B.

## H2b (Outgroup derogation hypothesis)
- **Script**: `R/hypotheses/H2b_test.R`
- **Theoretical Expectation**: Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Independent Variable**: `perp_outgroup` (1 = Negotiator belongs to evaluator's outgroup opposing faction)
- **Control Variables**: Same as H1
- **Outputs Produced**: Tobit outputs plus CLAD robustness counterparts for both Model A and Model B.

## H3 (Empathy x group moderation)
- **Script**: `R/hypotheses/H3_test.R`
- **Theoretical Expectation**: The negative association between empathy and moral-judgment scores should be stronger (more negative) in outgroup cases than in ingroup cases.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Independent Variable**: `iri_total * perp_outgroup` (Interaction term using the raw empathy composite and outgroup status)
- **Control Variables**: Same as H1
- **Outputs Produced**: Tobit outputs plus CLAD robustness counterparts for both Model A and Model B.
