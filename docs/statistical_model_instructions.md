# Statistical Model Instructions

## Why Tobit is Being Used
The primary dependent variable, `judgement`, is arbitrarily bounded strictly between `-9` and `9` within the evaluation framework. A severe pile-up of outcomes commonly occurs at these extremes. Standard OLS regression severely underestimates actual effect magnitudes when observations pile at dataset limits because it treats these hard bounds as standard continuous values rather than censored indicators. The interval-censored Tobit model resolves this limitation by acknowledging the probability of a latent scale $y^{*}$ existing independently beyond the observable threshold.

## Why CLAD Has Been Added
Because the Tobit likelihood relies on a Gaussian latent-error assumption, the project now also estimates a CLAD robustness specification. In practice, this is implemented as interval-censored median quantile regression (`p = 0.5`) so the censoring structure is respected while the estimator becomes less sensitive to non-normal latent disturbances and heavy-tailed behavior.

## Censoring Assumptions
- Observations mapped to exactly `-9` are recognized as **left-censored**. (The model incorporates limits resolving $y^{*} \leq -9$).
- Observations mapped to exactly `9` are recognized as **right-censored**. (The model constructs constraints resolving $y^{*} \geq 9$).
- Valid interior values between $-9 < y < 9$ are cleanly treated as exact.
- Residual distributions remain classically normal (Gaussian).

## Estimation Strategy
The pipeline now estimates two complementary families:

- **Tobit** via `survival::survreg()`, using interval bounds through `type = "interval2"`.
- **CLAD robustness** via `ctqr::ctqr()` at `p = 0.5`, also using `type = "interval2"` after internally shifting the bounded response to a positive scale required by the censored quantile routine.

Both branches share the same endpoint preparation inside `R/utils/model_functions.R`:
- Generates `lower_endpoint`
- Generates `upper_endpoint`
This handles data prep uniformly before model convergence.

## Standard Errors 
The Tobit branch natively adjusts parameter variance around clustered participant IDs (`robust = TRUE`). This corrects potential issues seen in repeated-measure evaluations stemming from one rater generating 10 subsequent evaluations.

The CLAD branch contributes robustness against non-normality, but its current variance estimates come from the `ctqr` asymptotic covariance matrix rather than participant-clustered sandwich corrections. It should therefore be interpreted as a complementary robustness analysis rather than a drop-in replacement for the clustered Tobit specification.

## Model Output Specifications 
- Tables evaluate statistical distinction utilizing the strict $p < 0.05$ limitation.
- For coefficient magnitude referencing, both Tobit and CLAD models estimate coefficients using raw predictor values. Psychometric predictors such as `iri_total` and the IRI subscales remain on their original scale, so coefficients should be interpreted per one-unit change on those native measures.
- Generated figures, regression matrices, estimator fit summaries, LaTeX tabular formats, and `.rds` memory dumps accommodate rigid publication while preserving the original Tobit results and adding the CLAD robustness branch.
