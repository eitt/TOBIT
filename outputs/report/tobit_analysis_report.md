# Scientific Dynamic Report of Moral Judgement under Two-sided Tobit Models

Generated on 2026-04-18 19:24:52.

## Redesign status and estimator note

This run uses `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` as the only analytical source and preserves each imported row as one real judgement observation.

The primary estimator is a two-sided Tobit fitted with `survival::survreg`, using bilateral censoring at `-9` and `9`, participant-cluster robust standard errors through `cluster = id`, and `factor(session)` in every active formula.

## Dataset and sample description

The report uses the consolidated long experimental dataset as the single analytical source.
Each participant contributes 20 judgement rows in principle: ten scenarios multiplied by two target-negotiator evaluations.
Each imported row remains one real judgement observation on the target negotiator, enriched with relational context for N1, N2, victim, and bystander without duplicating rows.
Double counting is prevented because N1 and N2 are reconstructed as contextual attributes inside each existing row rather than by expanding the file into duplicated negotiator-specific observations.
Victim and bystander analyses are estimated separately so that relational coding follows the role-specific logic of the experiment.

The authoritative interpretation is that each player observes ten scenarios and evaluates two negotiators, so the longitudinal file should contain 20 judgement rows per participant. The clustering diagnostic below is consistent with that design.

| metric | value |
| --- | --- |
| participants | 243.000 |
| sessions | 16.000 |
| mean_age | 20.086 |
| women_share | 0.426 |
| engineering_share | 0.568 |

| sample | rows | participants | mean_judgement | sd_judgement |
| --- | --- | --- | --- | --- |
| All | 4860 | 243 | 1.623 | 6.674 |
| Victim | 2430 | 243 | 1.504 | 6.842 |
| Bystander | 2430 | 243 | 1.741 | 6.500 |

## Datacard and symbol dictionary

| symbol | definition |
| --- | --- |
| judgement | Observed moral judgement on the bounded scale from -9 to 9. |
| y* | Latent judgement tendency underlying the censored Tobit observation. |
| iri_fs / iri_ec / iri_pt / iri_pd | IRI empathy dimensions: fantasy, empathic concern, perspective taking, and personal distress. |
| decision_target | Indicator for whether the target negotiator accepted the harmful deal; judgement is directed toward this actor. |
| decision_other | Indicator for whether the other negotiator accepted the harmful deal and may shift judgement of the target through the joint outcome context. |
| victim_N1_group / victim_N2_group | Victim-specific relations to negotiator 1 and negotiator 2, with ingroup defined by faculty coincidence including control-control matches. |
| bystander_victim_group / bystander_N1_group / bystander_N2_group | Bystander-side relational factors for the victim and both negotiators, again using faculty coincidence as ingroup. |
| N1_N2_same_faculty | Context term indicating whether N1 and N2 share faculty membership. |
| factor(session) | Session fixed effects included directly in every fitted formula. |
| cluster = id | Participant-level clustering used for robust standard errors and repeated-measures adjustment. |
| Log(scale) | Estimated Tobit log-scale parameter summarizing latent residual dispersion. |

| checkpoint | value |
| --- | --- |
| base_excel_rows | 4860 |
| processed_import_rows | 4860 |
| processed_judgment_rows | 4860 |
| unique_source_row_numbers | 4860 |
| duplicated_source_row_numbers | 0 |

## Predictor glossary and abbreviation note

| predictor | compact_label | meaning |
| --- | --- | --- |
| iri_fs | FS | Fantasy empathy dimension. |
| iri_ec | EC | Empathic concern empathy dimension. |
| iri_pt | PT | Perspective-taking empathy dimension. |
| iri_pd | PD | Personal-distress empathy dimension. |
| victim_N1_groupingroup | V-N1 In | Victim and N1 are from the same faculty, relative to the ingroup baseline. |
| victim_N1_groupoutgroup | V-N1 Out | Victim and N1 are from different faculties, relative to the ingroup baseline. |
| victim_N2_groupingroup | V-N2 In | Victim and N2 are from the same faculty, relative to the ingroup baseline. |
| victim_N2_groupoutgroup | V-N2 Out | Victim and N2 are from different faculties, relative to the ingroup baseline. |
| bystander_victim_groupoutgroup | B-V Out | Bystander and victim are from different faculties, relative to ingroup. |
| bystander_N1_groupingroup | B-N1 In | Bystander and N1 are from the same faculty, relative to the ingroup baseline. |
| bystander_N1_groupoutgroup | B-N1 Out | Bystander and N1 are from different faculties, relative to the ingroup baseline. |
| bystander_N2_groupingroup | B-N2 In | Bystander and N2 are from the same faculty, relative to the ingroup baseline. |
| bystander_N2_groupoutgroup | B-N2 Out | Bystander and N2 are from different faculties, relative to the ingroup baseline. |
| N1_N2_same_facultysame | SameFac | N1 and N2 share faculty, relative to different-faculty context. |
| iri_fs:victim_N1_groupoutgroup | FS x V-N1 Out | Fantasy slope difference when victim-N1 is outgroup rather than ingroup. |
| iri_ec:victim_N2_groupoutgroup | EC x V-N2 Out | Empathic-concern slope difference when victim-N2 is outgroup rather than ingroup. |
| iri_pt:bystander_victim_groupoutgroup | PT x B-V Out | Perspective-taking slope difference when the bystander-victim relation is outgroup rather than ingroup. |
| iri_pd:bystander_N1_groupoutgroup | PD x B-N1 Out | Personal-distress slope difference when the bystander-N1 relation is outgroup rather than ingroup. |
| decision_target | Target Acc | Target negotiator accepted the harmful deal. |
| decision_other | Other Acc | Other negotiator accepted the harmful deal. |
| decision_target:decision_other | Target x Other | Joint decision effect when both negotiator decisions are considered together. |
| faculty_player_factorEngineering | Eng part. | Participant belongs to Engineering, relative to Humanities. |
| sex_female | Woman | Participant is a woman. |
| age | Age | Participant age. |
| ses | SES | Participant socioeconomic status. |

The report keeps compact predictor references in figure captions and narratives, but the glossary above remains the authoritative mapping back to the current pipeline variables.

## Interaction interpretation rules

1. When an interaction is statistically relevant, the main effects should be read as the baseline component of the relationship rather than the whole substantive story.
2. Continuous-by-factor interactions indicate that the empathy slope changes across relational conditions.
3. Factor-by-factor interactions indicate that the joint context differs from what would be expected by adding the two main contrasts independently.
4. The target-by-other decision interaction indicates that the moral meaning of one negotiator's choice depends on what the counterpart did.
5. Session effects are adjustment terms only and are not interpreted as substantive experimental mechanisms.

## H1-H5 hypotheses with role-specific equation summaries

| hypothesis | role | formula_rhs | theoretical_focus |
| --- | --- | --- | --- |
| H1 | Victim | iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session) | Empathy dimensions only, always adjusted by sociodemographics. |
| H1 | Bystander | iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session) | Empathy dimensions only, always adjusted by sociodemographics. |
| H2 | Victim | victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session) | Victim-side ingroup/outgroup structure with the allowed N1 x N2 relational interaction. |
| H2 | Bystander | bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session) | Bystander-side relational structure with explicit bystander-victim, bystander-negotiator, victim-negotiator, and N1/N2 context terms. |
| H3 | Victim | iri_fs + iri_ec + iri_pt + iri_pd + victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:victim_N1_group + iri_fs:victim_N2_group + iri_ec:victim_N1_group + iri_ec:victim_N2_group + iri_pt:victim_N1_group + iri_pt:victim_N2_group + iri_pd:victim_N1_group + iri_pd:victim_N2_group + age + ses + sex_female + faculty_player_factor + factor(session) | Empathy plus victim-side relational structure, including empathy x victim-N1 and empathy x victim-N2 interactions because empathy may depend on negotiator closeness. |
| H3 | Bystander | iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group + iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group + iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group + iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group + age + ses + sex_female + faculty_player_factor + factor(session) | Empathy plus bystander-side relational structure, including empathy x bystander-victim and empathy x bystander-negotiator interactions because empathy may depend on group closeness in the bystander role. |
| H4 | Victim | decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session) | Target and other negotiator decisions with their interaction, plus sociodemographics. |
| H4 | Bystander | decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session) | Target and other negotiator decisions with their interaction, plus sociodemographics. |
| H5 | Victim | iri_fs + iri_ec + iri_pt + iri_pd + victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:victim_N1_group + iri_fs:victim_N2_group + iri_ec:victim_N1_group + iri_ec:victim_N2_group + iri_pt:victim_N1_group + iri_pt:victim_N2_group + iri_pd:victim_N1_group + iri_pd:victim_N2_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session) | Integrated model with empathy, victim-side relations, empathy x group interactions, decisions, and the victim-side relational interaction. |
| H5 | Bystander | iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group + iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group + iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group + iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session) | Integrated model with empathy, bystander-side relations, empathy x group interactions, decisions, and the role-specific relational interactions. |

Any earlier repository note that described negotiator code `0` as a hidden label or that narrowed H3 to additive effects only should now be treated as outdated. The active formulas below are the authoritative specification.

### H1

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session)`

### H2

`Victim`: `victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session)`

### H3

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:victim_N1_group + iri_fs:victim_N2_group + iri_ec:victim_N1_group + iri_ec:victim_N2_group + iri_pt:victim_N1_group + iri_pt:victim_N2_group + iri_pd:victim_N1_group + iri_pd:victim_N2_group + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group + iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group + iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group + iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group + age + ses + sex_female + faculty_player_factor + factor(session)`

### H4

`Victim`: `decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

### H5

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:victim_N1_group + iri_fs:victim_N2_group + iri_ec:victim_N1_group + iri_ec:victim_N2_group + iri_pt:victim_N1_group + iri_pt:victim_N2_group + iri_pd:victim_N1_group + iri_pd:victim_N2_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group + iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group + iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group + iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## Mathematical foundations

The primary estimator is a two-sided Tobit fitted with `survival::survreg`.

$$y_i = \max(-9, \min(9, y_i^*))$$

$$y_i^* = \beta_0 + X_i\beta + \delta_{session(i)} + \varepsilon_i$$

where `factor(session)` supplies session fixed effects and cluster-robust standard errors are computed at the participant level through `cluster = id` with `robust = TRUE`.
This report therefore treats session as an implemented fixed-effect adjustment, not as a random intercept.

In this production branch, `factor(session)` is reported instead of `(1|session)` because the fitted estimator is a two-sided Tobit with session fixed effects and participant-cluster robust standard errors. The report does not claim a random session intercept that was not actually estimated.

## Dependence and effective sample size diagnostic

The following clustering diagnostic is descriptive. It summarizes within-participant dependence in the observed data and should not be read as evidence that the fitted estimator included participant random intercepts.

| metric | value |
| --- | --- |
| participants | 243.000 |
| observations | 4860.000 |
| average_observations_per_id | 20.000 |
| icc_descriptive | 0.134 |
| design_effect | 3.537 |
| effective_sample_size | 1373.909 |

Because the target of inference is repeated judgement within participant, the effective-sample-size table is a descriptive clustering diagnostic only; it does not replace the model-based dependence adjustment through `cluster = id` and `factor(session)`.

## Descriptive statistics and figures

| role_label | decision_pattern | n | mean_judgement |
| --- | --- | --- | --- |
| bystander | both_accept | 604 | -2.785 |
| victim | both_accept | 610 | -3.167 |
| bystander | both_reject | 690 | 7.086 |
| victim | both_reject | 662 | 7.062 |
| bystander | target_accept_other_reject | 568 | -3.155 |
| victim | target_accept_other_reject | 579 | -3.803 |
| bystander | target_reject_other_accept | 568 | 4.958 |
| victim | target_reject_other_accept | 579 | 5.378 |

| variable | level | n |
| --- | --- | --- |
| victim_N1_group | ingroup | 1682 |
| victim_N1_group | outgroup | 3178 |
| victim_N2_group | ingroup | 1578 |
| victim_N2_group | outgroup | 3282 |
| bystander_victim_group | ingroup | 1212 |
| bystander_victim_group | outgroup | 1218 |
| bystander_N1_group | ingroup | 812 |
| bystander_N1_group | outgroup | 1618 |
| bystander_N2_group | ingroup | 798 |
| bystander_N2_group | outgroup | 1632 |
| N1_N2_same_faculty | different | 3276 |
| N1_N2_same_faculty | same | 1584 |

| term | iri_fs | iri_ec | iri_pt | iri_pd | judgement |
| --- | --- | --- | --- | --- | --- |
| iri_fs | 1.000 | 0.409 | 0.154 | 0.282 | 0.051 |
| iri_ec | 0.409 | 1.000 | 0.482 | 0.219 | -0.017 |
| iri_pt | 0.154 | 0.482 | 1.000 | -0.177 | 0.111 |
| iri_pd | 0.282 | 0.219 | -0.177 | 1.000 | -0.046 |
| judgement | 0.051 | -0.017 | 0.111 | -0.046 | 1.000 |

The group summary and the formulas above use role-specific ingroup/outgroup coding. Ingroup is defined by faculty coincidence, including `control` with `control`, while outgroup means non-matching faculties.

![Mean IRI subscale profile across participants.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_iri_subscale_radar.png)

This figure summarizes the central empathy profile of the sample before conditioning on hypothesis-specific models.

![Participant-level bivariate scatters of IRI subscales against mean judgement.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_bivariate_empathy_vs_mean_judgement.png)

These scatterplots show the participant-level descriptive relationship between empathy dimensions and average judgement.

![Observed judgement distributions split by role.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role.png)

This figure shows the raw shape of the bounded judgement outcome in the victim and bystander subsets.

![Observed decision patterns by role.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_decision_pattern_by_role.png)

This figure summarizes how the four joint decision contexts are distributed across roles.

## Estimator fit summary

| hypothesis | role | variant | model_family | session_handling | dependence_adjustment | n_obs | n_participants | lower_censored_n | upper_censored_n | AIC | BIC | sigma | dropped_columns |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| H1 | Bystander | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 300 | 723 | 12558.780 | 12703.568 | 10.264 | 0 |
| H1 | Victim | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 377 | 744 | 12280.557 | 12425.345 | 11.564 | 0 |
| H2 | Bystander | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 300 | 723 | 12557.426 | 12725.380 | 10.242 | 0 |
| H2 | Victim | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 377 | 744 | 12297.645 | 12442.433 | 11.607 | 0 |
| H3 | Bystander | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 300 | 723 | 12569.153 | 12829.772 | 10.193 | 0 |
| H3 | Victim | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 377 | 744 | 12296.035 | 12510.321 | 11.541 | 0 |
| H4 | Bystander | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 300 | 723 | 11060.312 | 11199.308 | 6.917 | 0 |
| H4 | Victim | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 377 | 744 | 10747.901 | 10886.898 | 7.626 | 0 |
| H5 | Bystander | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 300 | 723 | 11080.219 | 11358.212 | 6.876 | 0 |
| H5 | Victim | primary | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 2420 | 243 | 377 | 744 | 10749.255 | 10980.916 | 7.570 | 0 |

## Hypothesis significance summary by role

### Victim

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Victim | Empathy: Perspective taking** |
| H2 | Victim | None below p < 0.10 |
| H3 | Victim | Empathy: Fantasy*; Empathy: Perspective taking+ |
| H4 | Victim | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Victim | Empathy: Fantasy*; Victim-N2 outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-N1 outgroup vs ingroup+; Target accepted x Other accepted*** |

### Bystander

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Bystander | None below p < 0.10 |
| H2 | Bystander | Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+ |
| H3 | Bystander | Empathy: Empathic concern+; Empathy: Personal distress+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+; Empathy: Fantasy x Bystander-victim outgroup vs ingroup+; Empathy: Personal distress x Bystander-victim outgroup vs ingroup* |
| H4 | Bystander | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Bystander | Victim-N1 outgroup vs ingroup*; Victim-N2 outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted*** |

## Significance-driven figures

### H1 Victim: Empathy: Perspective taking

![H1 Victim: model-implied predictions for Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h1_victim_iri_pt.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H2 Bystander: Bystander-N2 outgroup vs ingroup

![H2 Bystander: model-implied predictions for Bystander-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_bystander_n2_groupoutgroup.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H2 Bystander: Victim-N1 outgroup vs ingroup

![H2 Bystander: model-implied predictions for Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_n1_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H2 Bystander: Victim-N2 outgroup vs ingroup

![H2 Bystander: model-implied predictions for Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_n2_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H2 Bystander: Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup

![H2 Bystander: model-implied predictions for Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_bystander_n1_groupoutgroup_bystander_n2_groupoutgr.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H2 Bystander: Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup

![H2 Bystander: model-implied predictions for Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_n1_groupoutgroup_victim_n2_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H3 Victim: Empathy: Fantasy

![H3 Victim: model-implied predictions for Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_fs.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H3 Victim: Empathy: Perspective taking

![H3 Victim: model-implied predictions for Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_pt.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H3 Bystander: Empathy: Empathic concern

![H3 Bystander: model-implied predictions for Empathy: Empathic concern.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_ec.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H3 Bystander: Empathy: Personal distress

![H3 Bystander: model-implied predictions for Empathy: Personal distress.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_pd.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H3 Bystander: Victim-N1 outgroup vs ingroup

![H3 Bystander: model-implied predictions for Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_n1_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H3 Bystander: Victim-N2 outgroup vs ingroup

![H3 Bystander: model-implied predictions for Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_n2_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H3 Bystander: Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup

![H3 Bystander: model-implied predictions for Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_bystander_n1_groupoutgroup_bystander_n2_groupoutgr.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H3 Bystander: Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup

![H3 Bystander: model-implied predictions for Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_n1_groupoutgroup_victim_n2_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H3 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H3 Bystander: model-implied predictions for Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_fs_bystander_victim_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H3 Bystander: Empathy: Personal distress x Bystander-victim outgroup vs ingroup

![H3 Bystander: model-implied predictions for Empathy: Personal distress x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_pd_bystander_victim_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H4 Victim: Target accepted

![H4 Victim: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H4 Victim: Other negotiator accepted

![H4 Victim: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H4 Victim: Target accepted x Other accepted

![H4 Victim: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_target_decision_other.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H4 Bystander: Target accepted

![H4 Bystander: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H4 Bystander: Other negotiator accepted

![H4 Bystander: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H4 Bystander: Target accepted x Other accepted

![H4 Bystander: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_target_decision_other.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H5 Victim: Empathy: Fantasy

![H5 Victim: model-implied predictions for Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H5 Victim: Victim-N2 outgroup vs ingroup

![H5 Victim: model-implied predictions for Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_victim_n2_groupoutgroup.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H5 Victim: Target accepted

![H5 Victim: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H5 Victim: Other negotiator accepted

![H5 Victim: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H5 Victim: Empathy: Fantasy x Victim-N1 outgroup vs ingroup

![H5 Victim: model-implied predictions for Empathy: Fantasy x Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs_victim_n1_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H5 Victim: Target accepted x Other accepted

![H5 Victim: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_target_decision_other.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H5 Bystander: Victim-N1 outgroup vs ingroup

![H5 Bystander: model-implied predictions for Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_n1_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H5 Bystander: Victim-N2 outgroup vs ingroup

![H5 Bystander: model-implied predictions for Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_n2_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

### H5 Bystander: Target accepted

![H5 Bystander: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H5 Bystander: Other negotiator accepted

![H5 Bystander: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

### H5 Bystander: Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup

![H5 Bystander: model-implied predictions for Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_n1_groupoutgroup_victim_n2_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H5 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H5 Bystander: model-implied predictions for Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_iri_fs_bystander_victim_groupoutgroup.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

### H5 Bystander: Target accepted x Other accepted

![H5 Bystander: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_target_decision_other.png)

The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile.

## Full coefficient tables and interpretation summary

### H1 Victim coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -0.874 | 3.297 | -7.337 | 5.589 | 0.791 |
| Empathy: Fantasy | 0.644 | 0.524 | -0.383 | 1.672 | 0.219 |
| Empathy: Empathic concern | -0.850 | 0.751 | -2.322 | 0.623 | 0.258 |
| Empathy: Perspective taking | 1.773 | 0.614 | 0.570 | 2.975 | 0.004** |
| Empathy: Personal distress | 0.035 | 0.588 | -1.117 | 1.188 | 0.952 |
| Age | -0.025 | 0.133 | -0.285 | 0.235 | 0.850 |
| Socioeconomic status | 0.451 | 0.344 | -0.224 | 1.126 | 0.190 |
| Woman participant | 0.211 | 0.812 | -1.380 | 1.803 | 0.795 |
| Participant faculty: Engineering vs Humanities | 1.352 | 0.803 | -0.222 | 2.925 | 0.092+ |
| Tobit log-scale | 2.448 | 0.057 | 2.336 | 2.560 | <0.001*** |

The H1 Victim model shows focal evidence for one hypothesis terms. Empathy: Perspective taking is associated with higher predicted judgement (estimate = 1.77, p = 0.004**). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H1 Bystander coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -3.438 | 3.171 | -9.654 | 2.777 | 0.278 |
| Empathy: Fantasy | 0.111 | 0.446 | -0.763 | 0.984 | 0.804 |
| Empathy: Empathic concern | -0.859 | 0.638 | -2.110 | 0.391 | 0.178 |
| Empathy: Perspective taking | 0.573 | 0.560 | -0.524 | 1.671 | 0.306 |
| Empathy: Personal distress | 0.167 | 0.561 | -0.934 | 1.267 | 0.766 |
| Age | 0.361 | 0.103 | 0.160 | 0.563 | <0.001*** |
| Socioeconomic status | 0.491 | 0.299 | -0.096 | 1.078 | 0.101 |
| Woman participant | -0.810 | 0.704 | -2.190 | 0.569 | 0.250 |
| Participant faculty: Engineering vs Humanities | 1.005 | 0.626 | -0.222 | 2.232 | 0.109 |
| Tobit log-scale | 2.329 | 0.057 | 2.217 | 2.440 | <0.001*** |

In the H1 Bystander model, no focal hypothesis term reached p < 0.10. The report therefore retains the coefficient table for auditability but does not attach a significance-driven substantive interpretation beyond the descriptive prediction plots.

### H2 Victim coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 2.846 | 3.504 | -4.023 | 9.715 | 0.417 |
| Victim-N1 outgroup vs ingroup | -0.232 | 1.364 | -2.905 | 2.441 | 0.865 |
| Victim-N2 outgroup vs ingroup | -0.424 | 1.310 | -2.992 | 2.144 | 0.746 |
| N1/N2 same faculty vs different | 0.359 | 0.849 | -1.305 | 2.023 | 0.672 |
| Age | -0.020 | 0.133 | -0.281 | 0.241 | 0.881 |
| Socioeconomic status | 0.525 | 0.358 | -0.176 | 1.227 | 0.142 |
| Woman participant | 0.327 | 0.764 | -1.171 | 1.824 | 0.669 |
| Participant faculty: Engineering vs Humanities | 1.526 | 0.817 | -0.076 | 3.128 | 0.062+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 0.133 | 1.792 | -3.379 | 3.646 | 0.941 |
| Tobit log-scale | 2.452 | 0.057 | 2.340 | 2.563 | <0.001*** |

In the H2 Victim model, no focal hypothesis term reached p < 0.10. The report therefore retains the coefficient table for auditability but does not attach a significance-driven substantive interpretation beyond the descriptive prediction plots.

### H2 Bystander coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -2.381 | 3.001 | -8.263 | 3.501 | 0.428 |
| Bystander-victim outgroup vs ingroup | -0.315 | 0.495 | -1.285 | 0.656 | 0.525 |
| Bystander-N1 outgroup vs ingroup | 1.132 | 1.078 | -0.980 | 3.245 | 0.294 |
| Bystander-N2 outgroup vs ingroup | 2.085 | 1.120 | -0.110 | 4.280 | 0.063+ |
| Victim-N1 outgroup vs ingroup | -2.168 | 1.227 | -4.573 | 0.237 | 0.077+ |
| Victim-N2 outgroup vs ingroup | -2.331 | 1.214 | -4.710 | 0.049 | 0.055+ |
| N1/N2 same faculty vs different | 0.786 | 0.831 | -0.844 | 2.416 | 0.344 |
| Age | 0.325 | 0.101 | 0.126 | 0.524 | 0.001** |
| Socioeconomic status | 0.466 | 0.299 | -0.120 | 1.052 | 0.119 |
| Woman participant | -0.902 | 0.661 | -2.198 | 0.394 | 0.173 |
| Participant faculty: Engineering vs Humanities | 1.064 | 0.646 | -0.202 | 2.331 | 0.099+ |
| Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup | -2.359 | 1.401 | -5.104 | 0.386 | 0.092+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 2.884 | 1.578 | -0.210 | 5.977 | 0.068+ |
| Tobit log-scale | 2.326 | 0.057 | 2.215 | 2.438 | <0.001*** |

The H2 Bystander model shows focal evidence for 5 hypothesis terms. Victim-N2 outgroup vs ingroup is associated with lower predicted judgement (estimate = -2.33, p = 0.055+). Bystander-N2 outgroup vs ingroup is associated with higher predicted judgement (estimate = 2.08, p = 0.063+). Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup is associated with higher predicted judgement (estimate = 2.88, p = 0.068+). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H3 Victim coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -4.295 | 4.224 | -12.574 | 3.984 | 0.309 |
| Empathy: Fantasy | 2.044 | 0.859 | 0.360 | 3.727 | 0.017* |
| Empathy: Empathic concern | -0.137 | 1.104 | -2.302 | 2.027 | 0.901 |
| Empathy: Perspective taking | 1.678 | 0.980 | -0.242 | 3.598 | 0.087+ |
| Empathy: Personal distress | -0.416 | 1.038 | -2.451 | 1.619 | 0.689 |
| Victim-N1 outgroup vs ingroup | 1.415 | 2.894 | -4.257 | 7.087 | 0.625 |
| Victim-N2 outgroup vs ingroup | 2.983 | 3.200 | -3.288 | 9.255 | 0.351 |
| N1/N2 same faculty vs different | 0.297 | 0.845 | -1.360 | 1.954 | 0.725 |
| Age | -0.025 | 0.132 | -0.284 | 0.235 | 0.853 |
| Socioeconomic status | 0.472 | 0.344 | -0.203 | 1.146 | 0.171 |
| Woman participant | 0.248 | 0.817 | -1.352 | 1.849 | 0.761 |
| Participant faculty: Engineering vs Humanities | 1.519 | 0.812 | -0.073 | 3.110 | 0.061+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 0.328 | 1.780 | -3.161 | 3.816 | 0.854 |
| Empathy: Fantasy x Victim-N1 outgroup vs ingroup | -0.829 | 0.752 | -2.302 | 0.644 | 0.270 |
| Empathy: Fantasy x Victim-N2 outgroup vs ingroup | -1.132 | 0.883 | -2.863 | 0.599 | 0.200 |
| Empathy: Empathic concern x Victim-N1 outgroup vs ingroup | 0.380 | 1.113 | -1.802 | 2.562 | 0.733 |
| Empathy: Empathic concern x Victim-N2 outgroup vs ingroup | -1.357 | 1.116 | -3.544 | 0.831 | 0.224 |
| Empathy: Perspective taking x Victim-N1 outgroup vs ingroup | -0.388 | 1.042 | -2.430 | 1.653 | 0.709 |
| Empathy: Perspective taking x Victim-N2 outgroup vs ingroup | 0.482 | 1.152 | -1.777 | 2.740 | 0.676 |
| Empathy: Personal distress x Victim-N1 outgroup vs ingroup | -0.049 | 0.958 | -1.926 | 1.828 | 0.959 |
| Empathy: Personal distress x Victim-N2 outgroup vs ingroup | 0.573 | 0.928 | -1.245 | 2.391 | 0.537 |
| Tobit log-scale | 2.446 | 0.057 | 2.334 | 2.558 | <0.001*** |

The H3 Victim model shows focal evidence for 2 hypothesis terms. Empathy: Fantasy is associated with higher predicted judgement (estimate = 2.04, p = 0.017*). Empathy: Perspective taking is associated with higher predicted judgement (estimate = 1.68, p = 0.087+). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H3 Bystander coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 2.237 | 4.049 | -5.698 | 10.173 | 0.581 |
| Empathy: Fantasy | 1.337 | 0.928 | -0.482 | 3.155 | 0.150 |
| Empathy: Empathic concern | -2.025 | 1.209 | -4.395 | 0.344 | 0.094+ |
| Empathy: Perspective taking | 0.002 | 1.030 | -2.017 | 2.022 | 0.998 |
| Empathy: Personal distress | -1.516 | 0.910 | -3.300 | 0.269 | 0.096+ |
| Bystander-victim outgroup vs ingroup | -3.515 | 2.601 | -8.612 | 1.583 | 0.177 |
| Bystander-N1 outgroup vs ingroup | -1.442 | 2.871 | -7.070 | 4.185 | 0.615 |
| Bystander-N2 outgroup vs ingroup | -0.129 | 2.740 | -5.499 | 5.241 | 0.963 |
| Victim-N1 outgroup vs ingroup | -2.124 | 1.215 | -4.505 | 0.256 | 0.080+ |
| Victim-N2 outgroup vs ingroup | -2.317 | 1.216 | -4.701 | 0.066 | 0.057+ |
| N1/N2 same faculty vs different | 0.826 | 0.820 | -0.781 | 2.434 | 0.314 |
| Age | 0.353 | 0.103 | 0.152 | 0.554 | <0.001*** |
| Socioeconomic status | 0.418 | 0.295 | -0.160 | 0.996 | 0.157 |
| Woman participant | -0.791 | 0.696 | -2.155 | 0.574 | 0.256 |
| Participant faculty: Engineering vs Humanities | 0.868 | 0.625 | -0.357 | 2.093 | 0.165 |
| Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup | -2.421 | 1.405 | -5.174 | 0.331 | 0.085+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 2.833 | 1.574 | -0.252 | 5.918 | 0.072+ |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.335 | 0.759 | -2.823 | 0.152 | 0.078+ |
| Empathy: Fantasy x Bystander-N1 outgroup vs ingroup | -0.947 | 0.780 | -2.476 | 0.582 | 0.225 |
| Empathy: Fantasy x Bystander-N2 outgroup vs ingroup | 0.016 | 0.856 | -1.663 | 1.694 | 0.985 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 1.081 | 1.084 | -1.043 | 3.206 | 0.318 |
| Empathy: Empathic concern x Bystander-N1 outgroup vs ingroup | 1.081 | 1.022 | -0.922 | 3.085 | 0.290 |
| Empathy: Empathic concern x Bystander-N2 outgroup vs ingroup | -0.073 | 1.135 | -2.298 | 2.152 | 0.949 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.142 | 0.900 | -1.623 | 1.906 | 0.875 |
| Empathy: Perspective taking x Bystander-N1 outgroup vs ingroup | 0.355 | 1.034 | -1.672 | 2.381 | 0.732 |
| Empathy: Perspective taking x Bystander-N2 outgroup vs ingroup | 0.348 | 0.960 | -1.534 | 2.230 | 0.717 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 1.647 | 0.770 | 0.138 | 3.155 | 0.032* |
| Empathy: Personal distress x Bystander-N1 outgroup vs ingroup | 0.501 | 0.827 | -1.120 | 2.122 | 0.545 |
| Empathy: Personal distress x Bystander-N2 outgroup vs ingroup | 0.948 | 0.788 | -0.597 | 2.493 | 0.229 |
| Tobit log-scale | 2.322 | 0.057 | 2.210 | 2.433 | <0.001*** |

The H3 Bystander model shows focal evidence for 8 hypothesis terms. Empathy: Personal distress x Bystander-victim outgroup vs ingroup is associated with higher predicted judgement (estimate = 1.65, p = 0.032*). Victim-N2 outgroup vs ingroup is associated with lower predicted judgement (estimate = -2.32, p = 0.057+). Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup is associated with higher predicted judgement (estimate = 2.83, p = 0.072+). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H4 Victim coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 9.771 | 2.575 | 4.723 | 14.819 | <0.001*** |
| Target accepted | -16.984 | 1.072 | -19.086 | -14.882 | <0.001*** |
| Other negotiator accepted | -3.951 | 0.705 | -5.332 | -2.570 | <0.001*** |
| Age | 0.042 | 0.102 | -0.158 | 0.242 | 0.681 |
| Socioeconomic status | 0.284 | 0.273 | -0.251 | 0.819 | 0.298 |
| Woman participant | 0.464 | 0.548 | -0.611 | 1.539 | 0.398 |
| Participant faculty: Engineering vs Humanities | 1.364 | 0.595 | 0.197 | 2.531 | 0.022* |
| Target accepted x Other accepted | 4.558 | 0.772 | 3.044 | 6.071 | <0.001*** |
| Tobit log-scale | 2.032 | 0.051 | 1.932 | 2.132 | <0.001*** |

The H4 Victim model shows focal evidence for 3 hypothesis terms. Target accepted is associated with lower predicted judgement (estimate = -16.98, p = <0.001***). Target accepted x Other accepted is associated with higher predicted judgement (estimate = 4.56, p = <0.001***). Other negotiator accepted is associated with lower predicted judgement (estimate = -3.95, p = <0.001***). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H4 Bystander coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 7.699 | 2.718 | 2.371 | 13.026 | 0.005** |
| Target accepted | -15.354 | 0.967 | -17.249 | -13.459 | <0.001*** |
| Other negotiator accepted | -4.262 | 0.662 | -5.559 | -2.965 | <0.001*** |
| Age | 0.164 | 0.094 | -0.020 | 0.349 | 0.081+ |
| Socioeconomic status | 0.206 | 0.246 | -0.276 | 0.689 | 0.402 |
| Woman participant | 0.098 | 0.543 | -0.967 | 1.164 | 0.856 |
| Participant faculty: Engineering vs Humanities | 1.174 | 0.515 | 0.165 | 2.183 | 0.023* |
| Target accepted x Other accepted | 4.849 | 0.769 | 3.342 | 6.357 | <0.001*** |
| Tobit log-scale | 1.934 | 0.050 | 1.835 | 2.033 | <0.001*** |

The H4 Bystander model shows focal evidence for 3 hypothesis terms. Target accepted is associated with lower predicted judgement (estimate = -15.35, p = <0.001***). Other negotiator accepted is associated with lower predicted judgement (estimate = -4.26, p = <0.001***). Target accepted x Other accepted is associated with higher predicted judgement (estimate = 4.85, p = <0.001***). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H5 Victim coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 4.069 | 3.411 | -2.617 | 10.755 | 0.233 |
| Empathy: Fantasy | 1.469 | 0.656 | 0.184 | 2.755 | 0.025* |
| Empathy: Empathic concern | 0.420 | 0.899 | -1.342 | 2.183 | 0.640 |
| Empathy: Perspective taking | 1.168 | 0.766 | -0.334 | 2.670 | 0.127 |
| Empathy: Personal distress | -0.316 | 0.716 | -1.719 | 1.087 | 0.659 |
| Victim-N1 outgroup vs ingroup | 1.766 | 1.806 | -1.774 | 5.305 | 0.328 |
| Victim-N2 outgroup vs ingroup | 4.155 | 2.198 | -0.153 | 8.462 | 0.059+ |
| N1/N2 same faculty vs different | -0.299 | 0.574 | -1.424 | 0.826 | 0.603 |
| Target accepted | -16.910 | 1.071 | -19.010 | -14.810 | <0.001*** |
| Other negotiator accepted | -3.881 | 0.699 | -5.251 | -2.512 | <0.001*** |
| Age | 0.016 | 0.100 | -0.180 | 0.212 | 0.870 |
| Socioeconomic status | 0.219 | 0.267 | -0.305 | 0.743 | 0.412 |
| Woman participant | 0.444 | 0.572 | -0.677 | 1.564 | 0.438 |
| Participant faculty: Engineering vs Humanities | 1.495 | 0.610 | 0.299 | 2.690 | 0.014* |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | -0.161 | 1.217 | -2.547 | 2.224 | 0.894 |
| Empathy: Fantasy x Victim-N1 outgroup vs ingroup | -0.826 | 0.468 | -1.744 | 0.091 | 0.077+ |
| Empathy: Fantasy x Victim-N2 outgroup vs ingroup | -0.632 | 0.578 | -1.764 | 0.500 | 0.274 |
| Empathy: Empathic concern x Victim-N1 outgroup vs ingroup | -0.045 | 0.684 | -1.386 | 1.296 | 0.948 |
| Empathy: Empathic concern x Victim-N2 outgroup vs ingroup | -0.784 | 0.849 | -2.447 | 0.879 | 0.356 |
| Empathy: Perspective taking x Victim-N1 outgroup vs ingroup | -0.058 | 0.596 | -1.227 | 1.111 | 0.922 |
| Empathy: Perspective taking x Victim-N2 outgroup vs ingroup | -0.276 | 0.742 | -1.731 | 1.179 | 0.710 |
| Empathy: Personal distress x Victim-N1 outgroup vs ingroup | 0.026 | 0.572 | -1.095 | 1.147 | 0.964 |
| Empathy: Personal distress x Victim-N2 outgroup vs ingroup | -0.139 | 0.541 | -1.199 | 0.921 | 0.797 |
| Target accepted x Other accepted | 4.445 | 0.762 | 2.950 | 5.939 | <0.001*** |
| Tobit log-scale | 2.024 | 0.051 | 1.924 | 2.124 | <0.001*** |

The H5 Victim model shows focal evidence for 6 hypothesis terms. Target accepted is associated with lower predicted judgement (estimate = -16.91, p = <0.001***). Target accepted x Other accepted is associated with higher predicted judgement (estimate = 4.44, p = <0.001***). Other negotiator accepted is associated with lower predicted judgement (estimate = -3.88, p = <0.001***). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

### H5 Bystander coefficient table

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 10.158 | 3.366 | 3.561 | 16.756 | 0.003** |
| Empathy: Fantasy | 0.737 | 0.674 | -0.583 | 2.058 | 0.274 |
| Empathy: Empathic concern | -0.705 | 0.860 | -2.391 | 0.981 | 0.412 |
| Empathy: Perspective taking | -0.680 | 0.731 | -2.112 | 0.753 | 0.352 |
| Empathy: Personal distress | -0.178 | 0.699 | -1.549 | 1.192 | 0.799 |
| Bystander-victim outgroup vs ingroup | -1.983 | 1.951 | -5.807 | 1.840 | 0.309 |
| Bystander-N1 outgroup vs ingroup | -0.272 | 1.921 | -4.037 | 3.494 | 0.887 |
| Bystander-N2 outgroup vs ingroup | -1.351 | 1.831 | -4.939 | 2.237 | 0.461 |
| Victim-N1 outgroup vs ingroup | -1.543 | 0.774 | -3.061 | -0.026 | 0.046* |
| Victim-N2 outgroup vs ingroup | -1.589 | 0.759 | -3.076 | -0.103 | 0.036* |
| N1/N2 same faculty vs different | -0.105 | 0.564 | -1.210 | 1.001 | 0.853 |
| Target accepted | -15.384 | 0.962 | -17.270 | -13.498 | <0.001*** |
| Other negotiator accepted | -4.305 | 0.665 | -5.609 | -3.001 | <0.001*** |
| Age | 0.184 | 0.097 | -0.006 | 0.375 | 0.058+ |
| Socioeconomic status | 0.168 | 0.248 | -0.317 | 0.654 | 0.497 |
| Woman participant | 0.040 | 0.557 | -1.051 | 1.132 | 0.942 |
| Participant faculty: Engineering vs Humanities | 1.064 | 0.516 | 0.053 | 2.075 | 0.039* |
| Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup | -1.307 | 1.011 | -3.289 | 0.675 | 0.196 |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 2.410 | 1.069 | 0.315 | 4.505 | 0.024* |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.143 | 0.507 | -2.137 | -0.149 | 0.024* |
| Empathy: Fantasy x Bystander-N1 outgroup vs ingroup | 0.119 | 0.515 | -0.890 | 1.127 | 0.818 |
| Empathy: Fantasy x Bystander-N2 outgroup vs ingroup | -0.133 | 0.580 | -1.270 | 1.004 | 0.818 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 0.698 | 0.812 | -0.894 | 2.289 | 0.390 |
| Empathy: Empathic concern x Bystander-N1 outgroup vs ingroup | -0.033 | 0.666 | -1.338 | 1.272 | 0.960 |
| Empathy: Empathic concern x Bystander-N2 outgroup vs ingroup | -0.162 | 0.786 | -1.703 | 1.378 | 0.836 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.649 | 0.618 | -0.561 | 1.860 | 0.293 |
| Empathy: Perspective taking x Bystander-N1 outgroup vs ingroup | 0.542 | 0.662 | -0.756 | 1.840 | 0.413 |
| Empathy: Perspective taking x Bystander-N2 outgroup vs ingroup | 0.714 | 0.682 | -0.624 | 2.051 | 0.296 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 0.605 | 0.608 | -0.588 | 1.798 | 0.320 |
| Empathy: Personal distress x Bystander-N1 outgroup vs ingroup | -0.191 | 0.567 | -1.302 | 0.919 | 0.736 |
| Empathy: Personal distress x Bystander-N2 outgroup vs ingroup | 0.626 | 0.541 | -0.434 | 1.685 | 0.247 |
| Target accepted x Other accepted | 4.891 | 0.791 | 3.340 | 6.442 | <0.001*** |
| Tobit log-scale | 1.928 | 0.050 | 1.830 | 2.026 | <0.001*** |

The H5 Bystander model shows focal evidence for 7 hypothesis terms. Target accepted is associated with lower predicted judgement (estimate = -15.38, p = <0.001***). Other negotiator accepted is associated with lower predicted judgement (estimate = -4.31, p = <0.001***). Target accepted x Other accepted is associated with higher predicted judgement (estimate = 4.89, p = <0.001***). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

## Compliance checklist

| criterion | status | evidence |
| --- | --- | --- |
| a) uses judgement | YES | All formulas model judgement directly. |
| b) repeated structure by id | YES | All fitted Tobit models use participant-cluster robust standard errors through cluster = id. |
| c) session grouping | YES | The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept. |
| d) no double count introduced by the pipeline | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) victim and bystander treated differently | YES | Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander. |
| f) decision_target and decision_other included where required | YES | H4 and H5 both include decision_target, decision_other, and their interaction. |
| g) sociodemographics included in every hypothesis model | YES | Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor. |

## Corrections relative to outdated notes

The current production branch supersedes earlier notes that treated the negotiator `0` code as `control_hidden`, narrowed H3 to additive-only empathy terms, or implied that the main estimator used `(1|session)`. The repository now documents the implemented estimator and the authoritative role-specific design directly.

## Limitations

The production branch does not fit a full multilevel Tobit with explicit random participant and session intercepts inside the same estimator.
Sparse relational cells can produce rank-deficient design matrices, so some interaction contrasts are dropped automatically and reported as such.
The dynamic figures visualize model-implied predictions from the saved primary Tobit fits and should be interpreted jointly with the coefficient tables rather than as standalone causal effects.

## Discussion

The empathy results speak to a mechanism in which moral judgement is not only a response to outcomes but also to dispositional social sensitivity. When empathy slopes vary across ingroup and outgroup relations, the findings support the original theoretical expectation that empathic orientation is filtered through perceived social closeness rather than operating as a uniform moral amplifier.

The ingroup/outgroup results matter because the experiment embeds judgement in a relational structure with two negotiators and role-dependent social ties. Victim and bystander models are therefore not interchangeable. In the victim role, the central question is how the judged negotiator and the counterpart relate to the harmed person. In the bystander role, the participant is socially external to the harm event, so judgement can depend on a broader map that includes bystander-victim, bystander-negotiator, and victim-negotiator alignments.

The decision terms sharpen the moral interpretation of the target-focused outcome. `decision_target` captures what the judged negotiator did, `decision_other` captures the counterpart's choice, and their interaction tests whether the meaning of one decision changes when the other negotiator accepts or rejects. This is substantively important because moral evaluations of the target can respond both to individual action and to the joint negotiation outcome.

Practically, the results speak to negotiation ethics and third-party evaluation. If moral judgement shifts with empathy, faculty closeness, and joint decision patterns, then perceived fairness in harmful negotiations is shaped by both dispositional and relational context. That has implications for how observers assign blame, excuse strategic behavior, or infer responsibility from coordinated action.

Methodologically, the active estimator is a two-sided Tobit with participant-cluster robust standard errors and session fixed effects. This is an honest production choice for a bounded repeated-measures outcome because it preserves the Tobit structure for `judgement`, adjusts within-participant dependence through clustering by `id`, and controls for session-level shifts through `factor(session)`. At the same time, it is not equivalent to a fully mixed Tobit with random participant and session intercepts, so dependence is handled through robust inference plus fixed-effects adjustment rather than a full hierarchical likelihood.

The main limitations follow directly from that estimator choice and from the sparsity of some relational cells. The production branch does not estimate a full mixed Tobit, some interaction contrasts may be dropped in rank-deficient subsets, and any substantive reading should remain tied to the coefficient tables and model-implied figures rather than to isolated p-values. Future work should compare these production estimates against stable multilevel censored models, test alternative role-specific interaction sets, and examine whether the same theoretical patterns replicate under additional institutional or cultural contexts.

## Final audit note

The project now faithfully reflects the authoritative design in its production branch: `judgement` is the outcome, the long file remains the single source, one row remains one real observation, role-specific group definitions are used, `decision_target` and `decision_other` are modeled where required, and repeated measurements are handled through participant-cluster robust inference with `factor(session)`.

No rank-deficiency warning remained in the saved fit summary for this run.

Estimator limitation: the production estimator is still a two-sided Tobit with `factor(session)` and participant-cluster robust standard errors by `id`, not a full mixed-effects Tobit with random participant and session intercepts.

## Conclusion

The active workflow now reproduces a scientific dynamic report structure while remaining faithful to the implemented estimator: two-sided Tobit, `factor(session)`, participant-cluster robust inference by `id`, no row duplication, and full H1-H5 coverage across victim and bystander specifications.

