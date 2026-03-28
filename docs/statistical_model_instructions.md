# Statistical Model Instructions

## Why Tobit is Being Used
The primary dependent variable, `judgement`, is arbitrarily bounded strictly between `-9` and `9` within the evaluation framework. A severe pile-up of outcomes commonly occurs at these extremes. Standard OLS regression severely underestimates actual effect magnitudes when observations pile at dataset limits because it treats these hard bounds as standard continuous values rather than censored indicators. The interval-censored Tobit model resolves this limitation by acknowledging the probability of a latent scale $y^{*}$ existing independently beyond the observable threshold.

## Why the Non-Parametric Robustness Model Has Been Added
Because the Tobit likelihood relies on a Gaussian latent-error assumption, the project also estimates a distribution-robust censored median specification. In practice, this is implemented as interval-censored median quantile regression (`p = 0.5`) so the censoring structure is respected while the estimator becomes less sensitive to non-normal latent disturbances and heavy-tailed behavior.

## Censoring Assumptions
- Observations mapped to exactly `-9` are recognized as **left-censored**. (The model incorporates limits resolving $y^{*} \leq -9$).
- Observations mapped to exactly `9` are recognized as **right-censored**. (The model constructs constraints resolving $y^{*} \geq 9$).
- Valid interior values between $-9 < y < 9$ are cleanly treated as exact.
- Residual distributions remain classically normal (Gaussian) only for the Tobit branch; the non-parametric branch relaxes that assumption.

## Estimation Strategy
The pipeline now estimates two complementary families:

- **Tobit** via `survival::survreg()`, using interval bounds through `type = "interval2"`.
- **Non-parametric robustness** via `ctqr::ctqr()` at `p = 0.5`, also using `type = "interval2"` after internally shifting the bounded response to a positive scale required by the censored quantile routine.

Both branches share the same endpoint preparation inside `R/utils/model_functions.R`:
- Generates `lower_endpoint`
- Generates `upper_endpoint`
This handles data prep uniformly before model convergence.

## Standard Errors 
The Tobit branch natively adjusts parameter variance around clustered participant IDs (`robust = TRUE`). This corrects potential issues seen in repeated-measure evaluations stemming from one rater generating multiple subsequent evaluations.

The non-parametric branch treats `id` as the clustering unit for inference, not as a predictor or random effect. Its workflow is intentionally staged internally:

- First, fit the full-sample interval-censored median model.
- If that model does not converge, stop and report the robustness fit as non-converged.
- If that model does converge, the default pipeline immediately runs participant-level cluster bootstrap inference:

- Resample unique `id` values with replacement.
- Retain every repeated observation from each sampled participant.
- Refit the interval-censored median model on each bootstrap sample.
- Compute bootstrap standard errors and percentile confidence intervals from the bootstrap distribution, then summarize p-values from the bootstrap standard errors on a normal-approximation scale.

If too few participant-level bootstrap refits converge to sustain full inference, the pipeline now labels that result explicitly as sparse bootstrap inference rather than treating the non-parametric branch as a full inferential confirmation.

This means repeated observations from the same participant are not treated as independent draws in the robustness analysis.

In the default pipeline, the bootstrap step follows automatically after each converged non-parametric fit, so the saved CLAD tables contain cluster-aware inferential summaries. If you want a faster fit-only pass, set `options(tobit.clad_run_bootstrap = FALSE)` before running and later invoke `R/07_run_nonparametric_bootstrap_phase.R` to fill in the bootstrap-based inference. The bootstrap repetition count can always be overridden with `options(tobit.clad_bootstrap_reps = ...)`.

## Model Output Specifications 
- Tables evaluate statistical distinction using both conventional thresholds in coefficient tables and a concise hypothesis summary table that reports only hypothesis-relevant predictors reaching at least $p < 0.10$.
- Figures are generated automatically only for hypothesis-relevant predictors that reach at least $p < 0.10$ in the Tobit model or the clustered non-parametric robustness model; continuous effects receive marginal prediction lines with confidence bands, binary or categorical effects receive grouped prediction plots, and interaction terms receive interaction plots.
- For coefficient magnitude referencing, both Tobit and non-parametric models estimate coefficients using raw predictor values. Psychometric predictors such as `iri_total` and the IRI subscales remain on their original scale, so coefficients should be interpreted per one-unit change on those native measures.
- Generated figures, regression matrices, estimator fit summaries, LaTeX tabular formats, `.rds` memory dumps, and the concise hypothesis summary table accommodate rigid publication while preserving the original Tobit results and adding the cluster-aware non-parametric robustness branch. In these figures, `id` is used only to account for within-participant dependence in inference and is never treated as a substantive explanatory variable.
