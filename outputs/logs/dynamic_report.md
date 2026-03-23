# Dynamic Analysis Report

*Generated autonomously on: 2026-03-23 12:35:40*

## Statistical Power and Clustered Variance
The dataset features extensive repeated measures (569 observations across 58 participants). The Intraclass Correlation Coefficient (ICC) of the primary moral judgments was calculated at 0.493. Consequently, the Design Effect inflating the variance is 5.34, yielding an Effective Sample Size (ESS) of 106.5 independent observations. This ESS governs the true statistical power for hypothesis detection in the clustered design.

## Hypothesis Evaluations

### H1: Empathy Effect
> *Higher empathy predicts lower moral-judgment scores for harmful decisions.*

Testing H1 (Term: iri_total_z). Coefficient estimate: -0.788 (p = 0.457). **HYPOTHESIS NOT SUPPORTED.** The effect was either strictly non-significant (p >= .05) or in the contrary direction.

### H2a: Ingroup Betrayal Effect
> *Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.*

Testing H2a (Term: same_group_harm). Coefficient estimate: -1.341 (p = 0.087). **HYPOTHESIS NOT SUPPORTED.** The effect was either strictly non-significant (p >= .05) or in the contrary direction.

### H2b: Outgroup Derogation Effect
> *Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.*

Testing H2b (Term: perp_outgroup). Coefficient estimate: 0.082 (p = 0.906). **HYPOTHESIS NOT SUPPORTED.** The effect was either strictly non-significant (p >= .05) or in the contrary direction.

### H3: Empathy x Group Moderation Effect
> *The negative association between empathy and moral-judgment scores should be stronger in outgroup cases than in ingroup cases.*

Testing H3 (Term: iri_total_z:perp_outgroup). Coefficient estimate: -0.450 (p = 0.583). **HYPOTHESIS NOT SUPPORTED.** The effect was either strictly non-significant (p >= .05) or in the contrary direction.

## Diagnostic Notes
These textual conclusions dynamically map against the newest iteration of output coefficients generated in the `outputs/models/` directory.
