# Statistical Model Instructions

## Why Tobit is Being Used
The primary dependent variable, `judgement`, is arbitrarily bounded strictly between `-9` and `9` within the evaluation framework. A severe pile-up of outcomes commonly occurs at these extremes. Standard OLS regression severely underestimates actual effect magnitudes when observations pile at dataset limits because it treats these hard bounds as standard continuous values rather than censored indicators. The interval-censored Tobit model resolves this limitation by acknowledging the probability of a latent scale $y^{*}$ existing independently beyond the observable threshold.

## Censoring Assumptions
- Observations mapped to exactly `-9` are recognized as **left-censored**. (The model incorporates limits resolving $y^{*} \leq -9$).
- Observations mapped to exactly `9` are recognized as **right-censored**. (The model constructs constraints resolving $y^{*} \geq 9$).
- Valid interior values between $-9 < y < 9$ are cleanly treated as exact.
- Residual distributions remain classically normal (Gaussian).

## Estimation Strategy
The pipeline estimates likelihoods adopting horizontal bounds through `survival::survreg()`. To properly structure the interval parameters (`type = "interval2"` under the framework), `fit_clustered_tobit` inside `R/utils/model_functions.R` abstracts the variable derivation:
- Generates `lower_endpoint`
- Generates `upper_endpoint`
This handles data prep uniformly before model convergence.

## Standard Errors 
All estimation blocks natively adjust parameter variance around clustered groupings based on standard participant IDs. This corrects potential issues seen in repeated-measure evaluations stemming from one rater generating 10 subsequent evaluations (`robust = TRUE`).

## Model Output Specifications 
- Tables evaluate statistical distinction utilizing the strict $p < 0.05$ limitation.
- For coefficient magnitude referencing, models output log-likelihood scaling metrics and estimate coefficients via native standard-deviation interactions (`iri_total_z`). For psychometric models, transforming latent inputs into Z-score intervals permits intuitive comparative effect-sizing (i.e., A one standard deviation positive lift in empathy results in ... unit shift).
- Generated figures, regression matrices, LaTeX tabular formats, and `.rds` memory dumps accommodate rigid publication (Letter Width page optimized boundaries, eliminating PDF margin cut-off failures seen previously).
