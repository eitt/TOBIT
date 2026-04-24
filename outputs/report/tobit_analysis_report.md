---
title: "Working Paper Report of Moral Judgement under Two-sided Tobit Models"
author: "Leonardo H. Talero-Sarmiento"
date: "2026-04-23 20:53:39"
numbersections: true
---

This run uses `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` as the only analytical source and preserves each imported row as one real judgement observation. The production estimator is a two-sided Tobit fitted with `survival::survreg`, using bilateral censoring at `-9` and `9`, participant-cluster robust standard errors through `cluster = id`, and `factor(session)` in every active formula.

# Understanding the modeling strategy

The purpose of the pipeline is to explain how participants assign moral judgement to a focal negotiator within a structured experimental setting. The objective is not limited to describing average responses. Rather, the pipeline is designed to estimate how judgement changes as a function of empathy, group alignment, negotiation decisions, and role-specific relational structure. The outcome of interest is `judgement`, interpreted as the participant's moral evaluation of the target negotiator. Because each participant contributes repeated evaluations across scenarios and targets, the modeling strategy must satisfy three conditions simultaneously: it must preserve one row per real observation, respect the bounded structure of the outcome, and account for within-participant dependence. For these reasons, the production workflow uses a two-sided Tobit model with participant-cluster robust inference and session adjustment.

The need for a Tobit specification follows directly from the nature of the dependent variable. `judgement` is continuous in interpretation but bounded in measurement. Values at the extremes are therefore not ordinary unrestricted observations; they are limits imposed by the response scale. A standard linear model assumes an outcome that can vary freely over the real line, which is inappropriate when responses accumulate at lower and upper boundaries. The Tobit framework addresses this by assuming an underlying latent moral evaluation, denoted here by `y_i^*`, that is only observed through a bounded realized score:

$$
y_i^* = X_i\beta + \varepsilon_i
$$

and

$$
judgement_i = \max(-9, \min(9, y_i^*)).
$$

Under this specification, the model jointly represents three kinds of outcomes: interior continuous values, lower-bound pile-up, and upper-bound pile-up. In this context, censoring does not mean that data are missing. It means that the observed score is recorded at the measurement boundary whenever the latent evaluation would extend beyond the scale. The Tobit model is therefore not a technical convenience but a direct response to the design of the judgement variable itself.

A second methodological challenge arises from the repeated-measures structure of the experiment. Each participant contributes multiple rows, so the observations are not independent. Ignoring this dependence would tend to underestimate standard errors and overstate statistical significance. The current pipeline addresses this issue through participant-cluster robust standard errors using `id` as the clustering variable. Session is also incorporated because different experimental sessions may vary in context, timing, or implementation details. This is handled through `factor(session)`, which absorbs systematic session-level shifts. In the active production branch, session is therefore modeled as a fixed-effect adjustment rather than as a random session intercept. The implemented estimator is best described as a two-sided Tobit with participant-cluster robust inference and session fixed effects.

The predictors are organized into theoretically meaningful blocks. The first block contains empathy dimensions, represented by `iri_fs`, `iri_ec`, `iri_pt`, and `iri_pd`, and provides the basis for H1. The second block captures role-specific ingroup/outgroup structure and underlies H2. The third block incorporates negotiation decisions through `decision_target`, `decision_other`, and their interaction, forming the core of H4. Finally, all models include sociodemographic controls such as age, SES, sex, and player faculty. This structure allows the pipeline to evaluate distinct explanatory mechanisms while preserving a coherent hypothesis architecture.

Interactions are especially important in this design because additive effects alone are unlikely to capture the logic of the experiment. In H3, empathy-by-group interactions test whether the effect of empathy depends on social alignment. In H4 and H5, the interaction between `decision_target` and `decision_other` evaluates whether the moral meaning of one negotiator's decision depends on the counterpart's decision. These interaction terms are theoretically motivated and reflect the fact that moral evaluation is shaped not only by isolated attributes but also by combinations of dispositions, relationships, and actions.

The distinction between victim and bystander roles is central to the entire modeling strategy. Victim models focus on victim-negotiator alignment and therefore operate with a more direct relational structure. Bystander models, by contrast, require a broader map that includes bystander-victim, bystander-negotiator, and victim-negotiator relations. Because these mechanisms differ substantively, the victim and bystander specifications cannot be treated as interchangeable. Role-specific models are therefore necessary both statistically and theoretically.

The five hypothesis families follow naturally from this structure. H1 models `judgement` as a function of empathy and controls. H2 focuses on role-specific group alignment. H3 combines empathy and group structure with theoretically motivated interactions. H4 models judgement as a function of `decision_target`, `decision_other`, and their interaction. H5 integrates all previous components into a single specification. This progression allows the analysis to move from simpler explanations toward a more comprehensive account of moral judgement.

A key principle of the workflow is that one row remains one real target-judgement observation. The pipeline does not duplicate rows into separate pseudo-observations for negotiators, because doing so would artificially inflate the sample size and distort inference. Instead, the relational context involving target, other, victim, and bystander is retained within each existing row. This preserves the integrity of the long-format design while maintaining the proper unit of analysis.

Taken together, the current production strategy has several strengths. It respects the bounded structure of the outcome, preserves the long-format observational design, adjusts inference for repeated observations, controls for session-level heterogeneity, separates victim and bystander mechanisms, and maps directly onto the theoretical architecture of H1 through H5. At the same time, its limitations must also be recognized. The estimator is not a full mixed-effects Tobit with random participant and session intercepts. In addition, sparse role-specific cells may still produce rank-deficient contrasts in interaction-heavy models. For that reason, interpretation should rely on the full combination of coefficient tables and model-implied figures rather than on isolated p-values.

Overall, the current production pipeline is statistically and conceptually aligned with the experiment. It treats bounded continuous moral judgement with a two-sided Tobit model, handles repeated observations through participant-cluster robust inference, adjusts session heterogeneity through fixed effects, and preserves role-specific relational theory within model specification. This makes the present workflow a defensible production framework, while also leaving a clear path for future multilevel Tobit extensions.

# Semantic naming bridge and row-level mapping

Legacy/intuitive naming bridge: `accept_target` -> active operational name `decision_target`; `accept_other` -> active operational name `decision_other`.

Row-level semantics: `target` and `other` are dynamic roles per observation; all active analytical terms in this report are expressed directly in that pair.

**Table 1. Row-level decision mapping from dynamic target/other to legacy structural-slot mappings**

| rule | expected_mapping | rows_in_scope | rows_following_rule | status |
| --- | --- | --- | --- | --- |
| target == 1 | Judged actor = target code 1, counterpart = other code 2; judged decision is `decision_target`, counterpart decision is `decision_other`. | 2430 | 2430 | PASS |
| target == 2 | Judged actor = target code 2, counterpart = other code 1; judged decision is `decision_target`, counterpart decision is `decision_other`. | 2430 | 2430 | PASS |


# Dataset and sample description

The report uses the consolidated long experimental dataset as the single analytical source.
Each participant contributes 20 judgement rows in principle: ten scenarios multiplied by two target-negotiator evaluations.
Each imported row remains one real judgement observation on the target negotiator, enriched with relational context for target, other, victim, and bystander without duplicating rows.
Double counting is prevented because target and other remain contextual attributes inside each existing row rather than by expanding the file into duplicated negotiator-specific observations.
Victim and bystander analyses are estimated separately so that relational coding follows the role-specific logic of the experiment.

The authoritative interpretation is that each player observes ten scenarios and evaluates two negotiators, so the longitudinal file should contain 20 judgement rows per participant. The clustering diagnostic below is consistent with that design.

**Table 2. Participant summary**

| metric | value |
| --- | --- |
| participants | 243.000 |
| sessions | 16.000 |
| mean_age | 20.086 |
| women_share | 0.426 |
| engineering_share | 0.568 |

**Table 3. Judgement summary**

| sample | rows | participants | mean_judgement | sd_judgement |
| --- | --- | --- | --- | --- |
| All | 4860 | 243 | 1.623 | 6.674 |
| Victim | 2430 | 243 | 1.504 | 6.842 |
| Bystander | 2430 | 243 | 1.741 | 6.500 |


# Datacard and symbol dictionary

**Table 4. Datacard symbol dictionary**

| symbol | definition |
| --- | --- |
| judgement | Observed moral judgement on the bounded scale from -9 to 9. |
| y* | Latent judgement tendency underlying the censored Tobit observation. |
| iri_fs / iri_ec / iri_pt / iri_pd | IRI empathy dimensions: fantasy, empathic concern, perspective taking, and personal distress. |
| target (row-dynamic) | Judged negotiator in that row; this role is dynamic and determined by the row-level `target` code. |
| other (row-dynamic counterpart) | Counterpart negotiator in that same row context (the non-target actor). |
| target / other (analytical pair) | Analytical target/other pair used for relational modeling without fixed structural negotiator identities. |
| decision_target | Indicator for whether the row-dynamic target negotiator accepted the harmful deal; active operational name for legacy wording accept_target. |
| decision_other | Indicator for whether the row-dynamic other negotiator accepted the harmful deal; active operational name for legacy wording accept_other. |
| victim_target_group / victim_other_group | Victim-specific relations to target and other, with ingroup defined by faculty coincidence including control-control matches. |
| bystander_victim_group / bystander_target_group / bystander_other_group | Bystander-side relational factors for the victim and both negotiators, again using faculty coincidence as ingroup. |
| group_target / group_other (legacy audit) | Legacy source grouping fields retained for provenance checks; not used directly in active H2/H3/H5 formulas. |
| target_other_same_faculty | Context term indicating whether target and other share faculty membership. |
| factor(session) | Session fixed effects included directly in every fitted formula. |
| cluster = id | Participant-level clustering used for robust standard errors and repeated-measures adjustment. |
| Log(scale) | Estimated Tobit log-scale parameter summarizing latent residual dispersion. |

**Table 5. Observation audit**

| checkpoint | value |
| --- | --- |
| base_excel_rows | 4860 |
| processed_import_rows | 4860 |
| processed_judgment_rows | 4860 |
| unique_source_row_numbers | 4860 |
| duplicated_source_row_numbers | 0 |


# Predictor glossary

**Table 6. Predictor glossary (reader version)**

| Code | Interpretation |
| --- | --- |
| FS | Fantasy empathy dimension. |
| EC | Empathic concern empathy dimension. |
| PT | Perspective-taking empathy dimension. |
| PD | Personal-distress empathy dimension. |
| V-Tgt In | Victim and target are from the same faculty. |
| V-Tgt Out | Victim and target are from different faculties. |
| V-Oth In | Victim and other are from the same faculty. |
| V-Oth Out | Victim and other are from different faculties. |
| B-V Out | Bystander and victim are from different faculties. |
| B-Tgt In | Bystander and target are from the same faculty. |
| B-Tgt Out | Bystander and target are from different faculties. |
| B-Oth In | Bystander and other are from the same faculty. |
| B-Oth Out | Bystander and other are from different faculties. |
| SameFac | Target and other share faculty membership. |
| FS x V-Tgt Out | Fantasy slope difference when victim-target is outgroup rather than ingroup. |
| EC x V-Oth Out | Empathic-concern slope difference when victim-other is outgroup rather than ingroup. |
| PT x B-V Out | Perspective-taking slope difference when the bystander-victim relation is outgroup rather than ingroup. |
| PD x B-Tgt Out | Personal-distress slope difference when the bystander-target relation is outgroup rather than ingroup. |
| Target Acc | Row-dynamic target negotiator accepted the harmful deal (legacy wording: accept_target). |
| Other Acc | Row-dynamic counterpart negotiator accepted the harmful deal (legacy wording: accept_other). |
| Target x Other | Joint decision effect when both negotiator decisions are considered together. |
| Eng part. | Participant belongs to Engineering, relative to Humanities. |
| Woman | Participant is a woman. |
| Age | Participant age. |
| SES | Participant socioeconomic status. |


Note. Group contrasts are interpreted against the ingroup baseline unless explicitly stated otherwise.

The report keeps compact predictor references in figure captions and narratives, but the glossary above remains the authoritative mapping back to the current pipeline variables.

# Interaction interpretation rules

1. When an interaction is statistically relevant, the main effects should be read as the baseline component of the relationship rather than the whole substantive story.
2. Continuous-by-factor interactions indicate that the empathy slope changes across relational conditions.
3. Factor-by-factor interactions indicate that the joint context differs from what would be expected by adding the two main contrasts independently.
4. The target-by-other decision interaction indicates that the moral meaning of one negotiator's choice depends on what the counterpart did.
5. Session effects are adjustment terms only and are not interpreted as substantive experimental mechanisms.

# H1-H5 hypotheses with role-specific equation summaries

\begingroup
\setlength{\tabcolsep}{2pt}
\scriptsize
\begin{longtable}{@{}>{\raggedright\arraybackslash\hspace{0pt}}p{0.06\textwidth}>{\raggedright\arraybackslash\hspace{0pt}}p{0.12\textwidth}>{\raggedright\arraybackslash\hspace{0pt}}p{0.58\textwidth}>{\raggedright\arraybackslash\hspace{0pt}}p{0.24\textwidth}@{}}
\caption{H1-H5 role-specific formulas and theoretical focus.}\label{tbl-formula-catalog}\\
\toprule
H & Role & Formula & Focus \\
\midrule
\endfirsthead
\toprule
H & Role & Formula & Focus \\
\midrule
\endhead
H1 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy dimensions only, always adjusted by sociodemographics. \\
H1 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy dimensions only, always adjusted by sociodemographics. \\
H2 & Victim & victim\_target\_group  +  victim\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Victim-side ingroup/outgroup structure with the allowed target x other relational interaction. \\
H2 & Bystander & bystander\_victim\_group  +  bystander\_target\_group  +  bystander\_other\_group  +  victim\_target\_group  +  victim\_other\_group  +  bystander\_target\_group : bystander\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Bystander-side relational structure with explicit bystander-victim, bystander-target, bystander-other, and target/other context terms. \\
H3 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  victim\_target\_group  +  victim\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : victim\_target\_group  +  iri\_fs : victim\_other\_group  +  iri\_ec : victim\_target\_group  +  iri\_ec : victim\_other\_group  +  iri\_pt : victim\_target\_group  +  iri\_pt : victim\_other\_group  +  iri\_pd : victim\_target\_group  +  iri\_pd : victim\_other\_group  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy plus victim-side relational structure, including empathy x victim-target and empathy x victim-other interactions because empathy may depend on negotiator closeness. \\
H3 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  bystander\_victim\_group  +  bystander\_target\_group  +  bystander\_other\_group  +  victim\_target\_group  +  victim\_other\_group  +  bystander\_target\_group : bystander\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : bystander\_victim\_group  +  iri\_fs : bystander\_target\_group  +  iri\_fs : bystander\_other\_group  +  iri\_ec : bystander\_victim\_group  +  iri\_ec : bystander\_target\_group  +  iri\_ec : bystander\_other\_group  +  iri\_pt : bystander\_victim\_group  +  iri\_pt : bystander\_target\_group  +  iri\_pt : bystander\_other\_group  +  iri\_pd : bystander\_victim\_group  +  iri\_pd : bystander\_target\_group  +  iri\_pd : bystander\_other\_group  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy plus bystander-side relational structure, including empathy x bystander-victim and empathy x bystander-target/other interactions because empathy may depend on group closeness in the bystander role. \\
H4 & Victim & decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Target and other negotiator decisions with their interaction, plus sociodemographics. \\
H4 & Bystander & decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Target and other negotiator decisions with their interaction, plus sociodemographics. \\
H5 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  victim\_target\_group  +  victim\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : victim\_target\_group  +  iri\_fs : victim\_other\_group  +  iri\_ec : victim\_target\_group  +  iri\_ec : victim\_other\_group  +  iri\_pt : victim\_target\_group  +  iri\_pt : victim\_other\_group  +  iri\_pd : victim\_target\_group  +  iri\_pd : victim\_other\_group  +  decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Integrated model with empathy, victim-side relations, empathy x group interactions, decisions, and the victim-side target/other interaction. \\
H5 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  bystander\_victim\_group  +  bystander\_target\_group  +  bystander\_other\_group  +  victim\_target\_group  +  victim\_other\_group  +  bystander\_target\_group : bystander\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : bystander\_victim\_group  +  iri\_fs : bystander\_target\_group  +  iri\_fs : bystander\_other\_group  +  iri\_ec : bystander\_victim\_group  +  iri\_ec : bystander\_target\_group  +  iri\_ec : bystander\_other\_group  +  iri\_pt : bystander\_victim\_group  +  iri\_pt : bystander\_target\_group  +  iri\_pt : bystander\_other\_group  +  iri\_pd : bystander\_victim\_group  +  iri\_pd : bystander\_target\_group  +  iri\_pd : bystander\_other\_group  +  decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Integrated model with empathy, bystander-side relations, empathy x group interactions, decisions, and role-specific target/other relational interactions. \\
\bottomrule
\end{longtable}
\endgroup

Any earlier repository note that treated negotiator code `0` as anything other than the explicit control category, or that narrowed H3 to additive effects only, should now be treated as outdated. The active formulas below are the authoritative specification.

## H1

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session)`

## H2

`Victim`: `victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session)`

## H3

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:victim_target_group + iri_fs:victim_other_group + iri_ec:victim_target_group + iri_ec:victim_other_group + iri_pt:victim_target_group + iri_pt:victim_other_group + iri_pd:victim_target_group + iri_pd:victim_other_group + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group + iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group + iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group + iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group + age + ses + sex_female + faculty_player_factor + factor(session)`

## H4

`Victim`: `decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## H5

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:victim_target_group + iri_fs:victim_other_group + iri_ec:victim_target_group + iri_ec:victim_other_group + iri_pt:victim_target_group + iri_pt:victim_other_group + iri_pd:victim_target_group + iri_pd:victim_other_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group + iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group + iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group + iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

# Mathematical foundations

The primary estimator is a two-sided Tobit fitted with `survival::survreg`.

$$y_i = \max(-9, \min(9, y_i^*))$$

$$y_i^* = \beta_0 + X_i\beta + \delta_{session(i)} + \varepsilon_i$$

where `factor(session)` supplies session fixed effects and cluster-robust standard errors are computed at the participant level through `cluster = id` with `robust = TRUE`.
This report therefore treats session as an implemented fixed-effect adjustment, not as a random intercept.

In this production branch, `factor(session)` is reported instead of `(1|session)` because the fitted estimator is a two-sided Tobit with session fixed effects and participant-cluster robust standard errors. The report does not claim a random session intercept that was not actually estimated.

# Dependence and effective sample size diagnostic

The following clustering diagnostic is descriptive. It summarizes within-participant dependence in the observed data and should not be read as evidence that the fitted estimator included participant random intercepts.

**Table 7. Descriptive clustering diagnostic**

| metric | value |
| --- | --- |
| participants | 243.000 |
| observations | 4860.000 |
| average_observations_per_id | 20.000 |
| icc_descriptive | 0.134 |
| design_effect | 3.537 |
| effective_sample_size | 1373.909 |


Because the target of inference is repeated judgement within participant, the effective-sample-size table is a descriptive clustering diagnostic only; it does not replace the model-based dependence adjustment through `cluster = id` and `factor(session)`.

# Descriptive statistics and figures

**Table 8. Decision summary by role**

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

**Table 9. Role-specific ingroup/outgroup summary**

| variable | level | n |
| --- | --- | --- |
| victim_target_group | ingroup | 1630 |
| victim_target_group | outgroup | 3230 |
| victim_other_group | ingroup | 1630 |
| victim_other_group | outgroup | 3230 |
| bystander_victim_group | ingroup | 1212 |
| bystander_victim_group | outgroup | 1218 |
| bystander_target_group | ingroup | 805 |
| bystander_target_group | outgroup | 1625 |
| bystander_other_group | ingroup | 805 |
| bystander_other_group | outgroup | 1625 |
| target_other_same_faculty | different | 3276 |
| target_other_same_faculty | same | 1584 |

**Table 10. Participant-level empathy and mean judgement correlation matrix**

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

![Observed judgement distributions by role and target negotiator.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_target.png)

This figure shows whether the raw bounded judgement distribution differs depending on whether the target code is 1 or 2 within victim and bystander settings.

![Observed judgement distributions by role and target decision.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_target_decision.png)

This figure isolates whether the target's own acceptance or rejection is associated with different raw judgement profiles within each role.

![Observed judgement distributions by role and counterpart decision.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_other_decision.png)

This figure shows whether judgement of the target varies with the acceptance or rejection of the other negotiator.

![Observed judgement distributions by role and joint decision pattern.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_decision_pattern.png)

This figure shows how the target-focused judgement distribution changes across the four joint negotiation outcomes in victim and bystander settings.

![Observed decision-pattern counts by role.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_decision_pattern_by_role.png)

This figure summarizes how often each joint decision pattern appears in victim and bystander subsets.

![Victim-role judgement distributions across target x other faculty pairings.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_victim_target_other_faculty_grid.png)

This figure shows how the raw judgement distribution varies across the full relational space defined by the faculty pairing of target and other.

![Bystander-role judgement distributions across target x other faculty pairings.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_target_other_faculty_grid.png)

This figure shows how the raw judgement distribution varies across the full relational space defined by the faculty pairing of target and other.

![Victim-role judgement distributions across victim-target and victim-other ingroup/outgroup combinations.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_victim_group_grid.png)

This optional figure highlights how raw victim-role judgement varies across victim-centered ingroup/outgroup combinations.

![Bystander-role judgement distributions across bystander-target and bystander-other ingroup/outgroup combinations.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_target_other_group_grid.png)

This optional figure emphasizes bystander-side relational combinations directly tied to target/other group alignment.

![Bystander-role judgement distributions across victim-target and victim-other ingroup/outgroup combinations.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_victim_target_other_group_grid.png)

This optional figure shows how bystander judgement co-varies with victim-centered relational combinations in the same observed rows.

# Estimator fit summary

Bystander models use 2,420 observations from 243 participants.
Victim models use 2,420 observations from 243 participants.

All production models use the estimator configuration shown below.

**Table 11. Estimator configuration**

| Estimator | Session handling | Dependence |
| --- | --- | --- |
| Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id |

## Model-level fit and censoring summary

### Bystander models

**Table 12. Bystander model fit and censoring summary**

| H | L. cens. | U. cens. | AIC | BIC | Sigma |
| --- | --- | --- | --- | --- | --- |
| H1 | 300 | 723 | 12558.800 | 12703.600 | 10.264 |
| H2 | 300 | 723 | 12558.800 | 12726.800 | 10.247 |
| H3 | 300 | 723 | 12570.000 | 12830.700 | 10.195 |
| H4 | 300 | 723 | 11060.300 | 11199.300 | 6.917 |
| H5 | 300 | 723 | 11076.700 | 11354.700 | 6.867 |

### Victim models

**Table 13. Victim model fit and censoring summary**

| H | L. cens. | U. cens. | AIC | BIC | Sigma |
| --- | --- | --- | --- | --- | --- |
| H1 | 377 | 744 | 12280.600 | 12425.300 | 11.564 |
| H2 | 377 | 744 | 12297.300 | 12442.100 | 11.606 |
| H3 | 377 | 744 | 12294.700 | 12509.000 | 11.537 |
| H4 | 377 | 744 | 10747.900 | 10886.900 | 7.626 |
| H5 | 377 | 744 | 10748.000 | 10979.700 | 7.566 |

# Hypothesis significance summary by role

## Victim

**Table 14. Victim focal support terms (p < 0.10)**

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Victim | Empathy: Perspective taking** |
| H2 | Victim | None below p < 0.10 |
| H3 | Victim | Empathy: Fantasy*; Empathy: Perspective taking+ |
| H4 | Victim | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Victim | Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-other outgroup vs ingroup+; Target accepted x Other accepted*** |

## Bystander

**Table 15. Bystander focal support terms (p < 0.10)**

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Bystander | None below p < 0.10 |
| H2 | Bystander | Bystander-target outgroup vs ingroup+; Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup+ |
| H3 | Bystander | Empathy: Empathic concern+; Empathy: Personal distress+; Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup+; Empathy: Fantasy x Bystander-victim outgroup vs ingroup+; Empathy: Personal distress x Bystander-victim outgroup vs ingroup* |
| H4 | Bystander | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Bystander | Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted*** |

# Significance-driven figures

## H1 Victim: Empathy: Perspective taking

![H1 Victim: model-implied predictions for Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h1_victim_iri_pt.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H2 Bystander: Bystander-target outgroup vs ingroup

![H2 Bystander: model-implied predictions for Bystander-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_bystander_target_groupoutgroup.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H2 Bystander: Victim-target outgroup vs ingroup

![H2 Bystander: model-implied predictions for Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_target_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H2 Bystander: Victim-other outgroup vs ingroup

![H2 Bystander: model-implied predictions for Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_other_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H2 Bystander: Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup

![H2 Bystander: model-implied predictions for Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_bystander_target_groupoutgroup_bystander_other_gro.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H2 Bystander: Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup

![H2 Bystander: model-implied predictions for Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_target_groupoutgroup_victim_other_groupoutg.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H3 Victim: Empathy: Fantasy

![H3 Victim: model-implied predictions for Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_fs.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H3 Victim: Empathy: Perspective taking

![H3 Victim: model-implied predictions for Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_pt.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H3 Bystander: Empathy: Empathic concern

![H3 Bystander: model-implied predictions for Empathy: Empathic concern.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_ec.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H3 Bystander: Empathy: Personal distress

![H3 Bystander: model-implied predictions for Empathy: Personal distress.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_pd.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H3 Bystander: Victim-target outgroup vs ingroup

![H3 Bystander: model-implied predictions for Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_target_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H3 Bystander: Victim-other outgroup vs ingroup

![H3 Bystander: model-implied predictions for Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_other_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H3 Bystander: Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup

![H3 Bystander: model-implied predictions for Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_bystander_target_groupoutgroup_bystander_other_gro.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H3 Bystander: Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup

![H3 Bystander: model-implied predictions for Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_target_groupoutgroup_victim_other_groupoutg.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H3 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H3 Bystander: model-implied predictions for Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_fs_bystander_victim_groupoutgroup.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H3 Bystander: Empathy: Personal distress x Bystander-victim outgroup vs ingroup

![H3 Bystander: model-implied predictions for Empathy: Personal distress x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_pd_bystander_victim_groupoutgroup.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H4 Victim: Target accepted

![H4 Victim: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H4 Victim: Other negotiator accepted

![H4 Victim: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H4 Victim: Target accepted x Other accepted

![H4 Victim: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_target_decision_other.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H4 Bystander: Target accepted

![H4 Bystander: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H4 Bystander: Other negotiator accepted

![H4 Bystander: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H4 Bystander: Target accepted x Other accepted

![H4 Bystander: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_target_decision_other.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H5 Victim: Empathy: Fantasy

![H5 Victim: model-implied predictions for Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H5 Victim: Victim-target outgroup vs ingroup

![H5 Victim: model-implied predictions for Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_victim_target_groupoutgroup.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H5 Victim: Target accepted

![H5 Victim: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H5 Victim: Other negotiator accepted

![H5 Victim: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H5 Victim: Empathy: Fantasy x Victim-other outgroup vs ingroup

![H5 Victim: model-implied predictions for Empathy: Fantasy x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs_victim_other_groupoutgroup.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H5 Victim: Target accepted x Other accepted

![H5 Victim: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_target_decision_other.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H5 Bystander: Victim-target outgroup vs ingroup

![H5 Bystander: model-implied predictions for Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_target_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H5 Bystander: Victim-other outgroup vs ingroup

![H5 Bystander: model-implied predictions for Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_other_groupoutgroup.png)

Across the displayed contrast, the model implies higher predicted judgement toward the right-hand side of the plot.

## H5 Bystander: Target accepted

![H5 Bystander: model-implied predictions for Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_target.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H5 Bystander: Other negotiator accepted

![H5 Bystander: model-implied predictions for Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_other.png)

Across the displayed contrast, the model implies lower predicted judgement toward the right-hand side of the plot.

## H5 Bystander: Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup

![H5 Bystander: model-implied predictions for Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_target_groupoutgroup_victim_other_groupoutg.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H5 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H5 Bystander: model-implied predictions for Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_iri_fs_bystander_victim_groupoutgroup.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

## H5 Bystander: Target accepted x Other accepted

![H5 Bystander: model-implied predictions for Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_target_decision_other.png)

The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile.

# Full coefficient tables and interpretation summary

## H1 Victim coefficient table

**Table 16. H1 Victim coefficient estimates**

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

## H1 Bystander coefficient table

**Table 17. H1 Bystander coefficient estimates**

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

H2 reminder: active relational predictors are expressed with row-dynamic `target`/`other` semantics; `group_target` and `group_other` remain legacy source-audit fields and are not active H2 predictors.

## H2 Victim coefficient table

**Table 18. H2 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 2.851 | 3.501 | -4.011 | 9.713 | 0.415 |
| Victim-target outgroup vs ingroup | -0.565 | 1.297 | -3.107 | 1.977 | 0.663 |
| Victim-other outgroup vs ingroup | -0.104 | 1.311 | -2.674 | 2.466 | 0.937 |
| Target/other same faculty vs different | 0.359 | 0.849 | -1.305 | 2.022 | 0.673 |
| Age | -0.020 | 0.133 | -0.280 | 0.241 | 0.883 |
| Socioeconomic status | 0.523 | 0.357 | -0.176 | 1.223 | 0.143 |
| Woman participant | 0.330 | 0.762 | -1.162 | 1.823 | 0.665 |
| Participant faculty: Engineering vs Humanities | 1.528 | 0.817 | -0.073 | 3.128 | 0.061+ |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 0.145 | 1.789 | -3.361 | 3.651 | 0.935 |
| Tobit log-scale | 2.452 | 0.057 | 2.340 | 2.563 | <0.001*** |

In the H2 Victim model, no focal hypothesis term reached p < 0.10. The report therefore retains the coefficient table for auditability but does not attach a significance-driven substantive interpretation beyond the descriptive prediction plots.

## H2 Bystander coefficient table

**Table 19. H2 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -2.430 | 2.995 | -8.300 | 3.441 | 0.417 |
| Bystander-victim outgroup vs ingroup | -0.332 | 0.496 | -1.304 | 0.640 | 0.504 |
| Bystander-target outgroup vs ingroup | 1.830 | 1.079 | -0.285 | 3.945 | 0.090+ |
| Bystander-other outgroup vs ingroup | 1.399 | 1.059 | -0.676 | 3.474 | 0.186 |
| Victim-target outgroup vs ingroup | -2.425 | 1.214 | -4.804 | -0.045 | 0.046* |
| Victim-other outgroup vs ingroup | -2.100 | 1.172 | -4.397 | 0.197 | 0.073+ |
| Target/other same faculty vs different | 0.783 | 0.833 | -0.849 | 2.416 | 0.347 |
| Age | 0.333 | 0.101 | 0.135 | 0.530 | <0.001*** |
| Socioeconomic status | 0.463 | 0.300 | -0.125 | 1.052 | 0.123 |
| Woman participant | -0.935 | 0.662 | -2.232 | 0.363 | 0.158 |
| Participant faculty: Engineering vs Humanities | 1.064 | 0.648 | -0.205 | 2.334 | 0.100 |
| Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup | -2.367 | 1.403 | -5.117 | 0.382 | 0.091+ |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 2.904 | 1.587 | -0.208 | 6.015 | 0.067+ |
| Tobit log-scale | 2.327 | 0.057 | 2.216 | 2.438 | <0.001*** |

The H2 Bystander model shows focal evidence for 5 hypothesis terms. Victim-target outgroup vs ingroup is associated with lower predicted judgement (estimate = -2.42, p = 0.046*). Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup is associated with higher predicted judgement (estimate = 2.90, p = 0.067+). Victim-other outgroup vs ingroup is associated with lower predicted judgement (estimate = -2.10, p = 0.073+). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

## H3 Victim coefficient table

**Table 20. H3 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -4.180 | 4.204 | -12.420 | 4.061 | 0.320 |
| Empathy: Fantasy | 1.966 | 0.849 | 0.303 | 3.629 | 0.021* |
| Empathy: Empathic concern | -0.167 | 1.103 | -2.328 | 1.994 | 0.880 |
| Empathy: Perspective taking | 1.669 | 0.966 | -0.223 | 3.562 | 0.084+ |
| Empathy: Personal distress | -0.329 | 1.032 | -2.352 | 1.695 | 0.750 |
| Victim-target outgroup vs ingroup | 2.193 | 2.617 | -2.937 | 7.322 | 0.402 |
| Victim-other outgroup vs ingroup | 2.060 | 2.618 | -3.071 | 7.190 | 0.431 |
| Target/other same faculty vs different | 0.292 | 0.845 | -1.365 | 1.949 | 0.730 |
| Age | -0.020 | 0.133 | -0.280 | 0.240 | 0.878 |
| Socioeconomic status | 0.451 | 0.346 | -0.227 | 1.129 | 0.192 |
| Woman participant | 0.252 | 0.814 | -1.343 | 1.847 | 0.757 |
| Participant faculty: Engineering vs Humanities | 1.491 | 0.807 | -0.091 | 3.073 | 0.065+ |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 0.396 | 1.769 | -3.071 | 3.863 | 0.823 |
| Empathy: Fantasy x Victim-target outgroup vs ingroup | -0.874 | 0.699 | -2.244 | 0.496 | 0.211 |
| Empathy: Fantasy x Victim-other outgroup vs ingroup | -1.021 | 0.890 | -2.766 | 0.724 | 0.251 |
| Empathy: Empathic concern x Victim-target outgroup vs ingroup | 0.196 | 0.935 | -1.637 | 2.028 | 0.834 |
| Empathy: Empathic concern x Victim-other outgroup vs ingroup | -1.159 | 1.160 | -3.432 | 1.115 | 0.318 |
| Empathy: Perspective taking x Victim-target outgroup vs ingroup | -0.950 | 0.849 | -2.615 | 0.714 | 0.263 |
| Empathy: Perspective taking x Victim-other outgroup vs ingroup | 1.051 | 0.822 | -0.559 | 2.661 | 0.201 |
| Empathy: Personal distress x Victim-target outgroup vs ingroup | 0.445 | 0.708 | -0.943 | 1.834 | 0.529 |
| Empathy: Personal distress x Victim-other outgroup vs ingroup | 0.014 | 0.946 | -1.839 | 1.867 | 0.988 |
| Tobit log-scale | 2.446 | 0.057 | 2.334 | 2.557 | <0.001*** |

The H3 Victim model shows focal evidence for 2 hypothesis terms. Empathy: Fantasy is associated with higher predicted judgement (estimate = 1.97, p = 0.021*). Empathy: Perspective taking is associated with higher predicted judgement (estimate = 1.67, p = 0.084+). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

## H3 Bystander coefficient table

**Table 21. H3 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 2.256 | 4.031 | -5.644 | 10.157 | 0.576 |
| Empathy: Fantasy | 1.297 | 0.932 | -0.528 | 3.123 | 0.164 |
| Empathy: Empathic concern | -2.012 | 1.196 | -4.355 | 0.331 | 0.092+ |
| Empathy: Perspective taking | 0.017 | 1.022 | -1.987 | 2.021 | 0.987 |
| Empathy: Personal distress | -1.514 | 0.896 | -3.271 | 0.243 | 0.091+ |
| Bystander-victim outgroup vs ingroup | -3.841 | 2.586 | -8.909 | 1.227 | 0.137 |
| Bystander-target outgroup vs ingroup | -0.922 | 2.783 | -6.376 | 4.532 | 0.740 |
| Bystander-other outgroup vs ingroup | -0.601 | 2.884 | -6.255 | 5.052 | 0.835 |
| Victim-target outgroup vs ingroup | -2.386 | 1.209 | -4.756 | -0.015 | 0.049* |
| Victim-other outgroup vs ingroup | -2.054 | 1.164 | -4.336 | 0.228 | 0.078+ |
| Target/other same faculty vs different | 0.839 | 0.822 | -0.772 | 2.450 | 0.307 |
| Age | 0.359 | 0.101 | 0.161 | 0.558 | <0.001*** |
| Socioeconomic status | 0.397 | 0.295 | -0.181 | 0.976 | 0.178 |
| Woman participant | -0.819 | 0.699 | -2.190 | 0.552 | 0.242 |
| Participant faculty: Engineering vs Humanities | 0.871 | 0.623 | -0.350 | 2.091 | 0.162 |
| Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup | -2.344 | 1.396 | -5.079 | 0.391 | 0.093+ |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 2.810 | 1.585 | -0.297 | 5.917 | 0.076+ |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.401 | 0.755 | -2.881 | 0.080 | 0.064+ |
| Empathy: Fantasy x Bystander-target outgroup vs ingroup | -0.032 | 0.684 | -1.374 | 1.309 | 0.962 |
| Empathy: Fantasy x Bystander-other outgroup vs ingroup | -0.833 | 0.662 | -2.131 | 0.465 | 0.208 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 1.094 | 1.068 | -1.000 | 3.188 | 0.306 |
| Empathy: Empathic concern x Bystander-target outgroup vs ingroup | -0.239 | 0.807 | -1.821 | 1.343 | 0.767 |
| Empathy: Empathic concern x Bystander-other outgroup vs ingroup | 1.236 | 0.866 | -0.461 | 2.933 | 0.153 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.238 | 0.884 | -1.494 | 1.970 | 0.788 |
| Empathy: Perspective taking x Bystander-target outgroup vs ingroup | 0.839 | 0.852 | -0.831 | 2.510 | 0.325 |
| Empathy: Perspective taking x Bystander-other outgroup vs ingroup | -0.192 | 0.834 | -1.827 | 1.443 | 0.818 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 1.743 | 0.771 | 0.233 | 3.254 | 0.024* |
| Empathy: Personal distress x Bystander-target outgroup vs ingroup | 0.824 | 0.696 | -0.540 | 2.187 | 0.237 |
| Empathy: Personal distress x Bystander-other outgroup vs ingroup | 0.585 | 0.766 | -0.916 | 2.087 | 0.445 |
| Tobit log-scale | 2.322 | 0.057 | 2.211 | 2.433 | <0.001*** |

The H3 Bystander model shows focal evidence for 8 hypothesis terms. Empathy: Personal distress x Bystander-victim outgroup vs ingroup is associated with higher predicted judgement (estimate = 1.74, p = 0.024*). Victim-target outgroup vs ingroup is associated with lower predicted judgement (estimate = -2.39, p = 0.049*). Empathy: Fantasy x Bystander-victim outgroup vs ingroup is associated with lower predicted judgement (estimate = -1.40, p = 0.064+). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

H4 reminder: legacy `accept_target` corresponds to active `decision_target`, and legacy `accept_other` corresponds to active `decision_other`; both refer to row-dynamic `target`/`other` roles.

## H4 Victim coefficient table

**Table 22. H4 Victim coefficient estimates**

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

## H4 Bystander coefficient table

**Table 23. H4 Bystander coefficient estimates**

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

H5 reminder: the integrated specification keeps `target`/`other` semantics for relational and decision terms; `group_target`/`group_other` remain legacy audit fields, and legacy `accept_target`/`accept_other` map to active `decision_target`/`decision_other`.

## H5 Victim coefficient table

**Table 24. H5 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 4.125 | 3.402 | -2.543 | 10.793 | 0.225 |
| Empathy: Fantasy | 1.470 | 0.647 | 0.202 | 2.738 | 0.023* |
| Empathy: Empathic concern | 0.395 | 0.899 | -1.367 | 2.156 | 0.661 |
| Empathy: Perspective taking | 1.145 | 0.759 | -0.342 | 2.632 | 0.131 |
| Empathy: Personal distress | -0.291 | 0.712 | -1.686 | 1.103 | 0.682 |
| Victim-target outgroup vs ingroup | 3.844 | 1.817 | 0.282 | 7.406 | 0.034* |
| Victim-other outgroup vs ingroup | 2.012 | 1.962 | -1.833 | 5.858 | 0.305 |
| Target/other same faculty vs different | -0.301 | 0.574 | -1.425 | 0.824 | 0.600 |
| Target accepted | -16.908 | 1.071 | -19.008 | -14.809 | <0.001*** |
| Other negotiator accepted | -3.881 | 0.699 | -5.251 | -2.512 | <0.001*** |
| Age | 0.018 | 0.100 | -0.178 | 0.214 | 0.856 |
| Socioeconomic status | 0.216 | 0.268 | -0.309 | 0.741 | 0.420 |
| Woman participant | 0.453 | 0.572 | -0.668 | 1.573 | 0.428 |
| Participant faculty: Engineering vs Humanities | 1.481 | 0.605 | 0.294 | 2.668 | 0.014* |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | -0.160 | 1.214 | -2.539 | 2.220 | 0.895 |
| Empathy: Fantasy x Victim-target outgroup vs ingroup | -0.453 | 0.519 | -1.470 | 0.564 | 0.382 |
| Empathy: Fantasy x Victim-other outgroup vs ingroup | -1.004 | 0.569 | -2.118 | 0.111 | 0.077+ |
| Empathy: Empathic concern x Victim-target outgroup vs ingroup | -0.178 | 0.683 | -1.517 | 1.161 | 0.794 |
| Empathy: Empathic concern x Victim-other outgroup vs ingroup | -0.635 | 0.803 | -2.209 | 0.940 | 0.429 |
| Empathy: Perspective taking x Victim-target outgroup vs ingroup | -0.787 | 0.610 | -1.982 | 0.408 | 0.197 |
| Empathy: Perspective taking x Victim-other outgroup vs ingroup | 0.470 | 0.647 | -0.799 | 1.739 | 0.468 |
| Empathy: Personal distress x Victim-target outgroup vs ingroup | -0.282 | 0.477 | -1.218 | 0.654 | 0.555 |
| Empathy: Personal distress x Victim-other outgroup vs ingroup | 0.152 | 0.618 | -1.059 | 1.363 | 0.806 |
| Target accepted x Other accepted | 4.448 | 0.765 | 2.949 | 5.947 | <0.001*** |
| Tobit log-scale | 2.024 | 0.051 | 1.924 | 2.124 | <0.001*** |

The H5 Victim model shows focal evidence for 6 hypothesis terms. Target accepted is associated with lower predicted judgement (estimate = -16.91, p = <0.001***). Target accepted x Other accepted is associated with higher predicted judgement (estimate = 4.45, p = <0.001***). Other negotiator accepted is associated with lower predicted judgement (estimate = -3.88, p = <0.001***). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

## H5 Bystander coefficient table

**Table 25. H5 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 10.174 | 3.376 | 3.556 | 16.791 | 0.003** |
| Empathy: Fantasy | 0.752 | 0.667 | -0.556 | 2.060 | 0.260 |
| Empathy: Empathic concern | -0.726 | 0.849 | -2.389 | 0.938 | 0.393 |
| Empathy: Perspective taking | -0.677 | 0.730 | -2.107 | 0.754 | 0.354 |
| Empathy: Personal distress | -0.147 | 0.690 | -1.499 | 1.205 | 0.831 |
| Bystander-victim outgroup vs ingroup | -1.920 | 1.934 | -5.712 | 1.871 | 0.321 |
| Bystander-target outgroup vs ingroup | -1.273 | 1.812 | -4.824 | 2.277 | 0.482 |
| Bystander-other outgroup vs ingroup | -0.383 | 1.807 | -3.923 | 3.158 | 0.832 |
| Victim-target outgroup vs ingroup | -1.941 | 0.763 | -3.438 | -0.445 | 0.011* |
| Victim-other outgroup vs ingroup | -1.217 | 0.736 | -2.659 | 0.225 | 0.098+ |
| Target/other same faculty vs different | -0.111 | 0.563 | -1.214 | 0.992 | 0.844 |
| Target accepted | -15.382 | 0.961 | -17.265 | -13.499 | <0.001*** |
| Other negotiator accepted | -4.267 | 0.664 | -5.570 | -2.965 | <0.001*** |
| Age | 0.182 | 0.097 | -0.008 | 0.372 | 0.061+ |
| Socioeconomic status | 0.159 | 0.246 | -0.324 | 0.642 | 0.520 |
| Woman participant | 0.055 | 0.556 | -1.034 | 1.144 | 0.921 |
| Participant faculty: Engineering vs Humanities | 1.072 | 0.515 | 0.062 | 2.082 | 0.038* |
| Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup | -1.287 | 1.012 | -3.270 | 0.697 | 0.204 |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 2.437 | 1.062 | 0.356 | 4.519 | 0.022* |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.130 | 0.509 | -2.128 | -0.133 | 0.026* |
| Empathy: Fantasy x Bystander-target outgroup vs ingroup | 0.348 | 0.470 | -0.574 | 1.269 | 0.460 |
| Empathy: Fantasy x Bystander-other outgroup vs ingroup | -0.381 | 0.451 | -1.264 | 0.503 | 0.399 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 0.666 | 0.809 | -0.920 | 2.252 | 0.410 |
| Empathy: Empathic concern x Bystander-target outgroup vs ingroup | -0.532 | 0.563 | -1.634 | 0.571 | 0.344 |
| Empathy: Empathic concern x Bystander-other outgroup vs ingroup | 0.378 | 0.640 | -0.876 | 1.631 | 0.555 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.664 | 0.610 | -0.531 | 1.860 | 0.276 |
| Empathy: Perspective taking x Bystander-target outgroup vs ingroup | 0.802 | 0.559 | -0.293 | 1.898 | 0.151 |
| Empathy: Perspective taking x Bystander-other outgroup vs ingroup | 0.444 | 0.595 | -0.722 | 1.609 | 0.456 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 0.597 | 0.605 | -0.590 | 1.783 | 0.324 |
| Empathy: Personal distress x Bystander-target outgroup vs ingroup | 0.491 | 0.444 | -0.379 | 1.361 | 0.269 |
| Empathy: Personal distress x Bystander-other outgroup vs ingroup | -0.084 | 0.494 | -1.053 | 0.885 | 0.866 |
| Target accepted x Other accepted | 4.884 | 0.793 | 3.330 | 6.437 | <0.001*** |
| Tobit log-scale | 1.927 | 0.050 | 1.828 | 2.025 | <0.001*** |

The H5 Bystander model shows focal evidence for 7 hypothesis terms. Target accepted is associated with lower predicted judgement (estimate = -15.38, p = <0.001***). Other negotiator accepted is associated with lower predicted judgement (estimate = -4.27, p = <0.001***). Target accepted x Other accepted is associated with higher predicted judgement (estimate = 4.88, p = <0.001***). Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative.

# Compliance checklist

**Table 26. Pipeline compliance checklist**

| criterion | status | evidence |
| --- | --- | --- |
| a) uses judgement | YES | All formulas model judgement directly. |
| b) repeated structure by id | YES | All fitted Tobit models use participant-cluster robust standard errors through cluster = id. |
| c) session grouping | YES | The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept. |
| d) no double count introduced by the pipeline | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) victim and bystander treated differently | YES | Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander. |
| f) decision_target and decision_other included where required | YES | H4 and H5 both include decision_target, decision_other, and their interaction. |
| g) sociodemographics included in every hypothesis model | YES | Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor. |


# Corrections relative to outdated notes

The current production branch supersedes earlier notes that used `control_hidden` wording for negotiator code `0`, narrowed H3 to additive-only empathy terms, or implied that the main estimator used `(1|session)`. The repository now documents the implemented estimator and the authoritative role-specific design directly.

# Limitations

The production branch does not fit a full multilevel Tobit with explicit random participant and session intercepts inside the same estimator.
Sparse relational cells can produce rank-deficient design matrices, so some interaction contrasts are dropped automatically and reported as such.
The dynamic figures visualize model-implied predictions from the saved primary Tobit fits and should be interpreted jointly with the coefficient tables rather than as standalone causal effects.

# Discussion

The empathy results speak to a mechanism in which moral judgement is not only a response to outcomes but also to dispositional social sensitivity. When empathy slopes vary across ingroup and outgroup relations, the findings support the original theoretical expectation that empathic orientation is filtered through perceived social closeness rather than operating as a uniform moral amplifier.

The ingroup/outgroup results matter because the experiment embeds judgement in a relational structure with two negotiators and role-dependent social ties. Victim and bystander models are therefore not interchangeable. In the victim role, the central question is how the judged negotiator and the counterpart relate to the harmed person. In the bystander role, the participant is socially external to the harm event, so judgement can depend on a broader map that includes bystander-victim, bystander-negotiator, and victim-negotiator alignments.

The decision terms sharpen the moral interpretation of the target-focused outcome. `decision_target` captures what the judged negotiator did, `decision_other` captures the counterpart's choice, and their interaction tests whether the meaning of one decision changes when the other negotiator accepts or rejects. This is substantively important because moral evaluations of the target can respond both to individual action and to the joint negotiation outcome.

Practically, the results speak to negotiation ethics and third-party evaluation. If moral judgement shifts with empathy, faculty closeness, and joint decision patterns, then perceived fairness in harmful negotiations is shaped by both dispositional and relational context. That has implications for how observers assign blame, excuse strategic behavior, or infer responsibility from coordinated action.

Methodologically, the active estimator is a two-sided Tobit with participant-cluster robust standard errors and session fixed effects. This is an honest production choice for a bounded repeated-measures outcome because it preserves the Tobit structure for `judgement`, adjusts within-participant dependence through clustering by `id`, and controls for session-level shifts through `factor(session)`. At the same time, it is not equivalent to a fully mixed Tobit with random participant and session intercepts, so dependence is handled through robust inference plus fixed-effects adjustment rather than a full hierarchical likelihood.

The main limitations follow directly from that estimator choice and from the sparsity of some relational cells. The production branch does not estimate a full mixed Tobit, some interaction contrasts may be dropped in rank-deficient subsets, and any substantive reading should remain tied to the coefficient tables and model-implied figures rather than to isolated p-values. Future work should compare these production estimates against stable multilevel censored models, test alternative role-specific interaction sets, and examine whether the same theoretical patterns replicate under additional institutional or cultural contexts.

# Final audit note

The project now faithfully reflects the authoritative design in its production branch: `judgement` is the outcome, the long file remains the single source, one row remains one real observation, role-specific group definitions are used, `decision_target` and `decision_other` are modeled where required, and repeated measurements are handled through participant-cluster robust inference with `factor(session)`.

No rank-deficiency warning remained in the saved fit summary for this run.

Estimator limitation: the production estimator is still a two-sided Tobit with `factor(session)` and participant-cluster robust standard errors by `id`, not a full mixed-effects Tobit with random participant and session intercepts.

# Technical appendix: predictor code map

**Table 27. Predictor-to-code map (technical appendix)**

| Predictor | Code |
| --- | --- |
| iri_fs | FS |
| iri_ec | EC |
| iri_pt | PT |
| iri_pd | PD |
| victim_target_groupingroup | V-Tgt In |
| victim_target_groupoutgroup | V-Tgt Out |
| victim_other_groupingroup | V-Oth In |
| victim_other_groupoutgroup | V-Oth Out |
| bystander_victim_groupoutgroup | B-V Out |
| bystander_target_groupingroup | B-Tgt In |
| bystander_target_groupoutgroup | B-Tgt Out |
| bystander_other_groupingroup | B-Oth In |
| bystander_other_groupoutgroup | B-Oth Out |
| target_other_same_facultysame | SameFac |
| iri_fs:victim_target_groupoutgroup | FS x V-Tgt Out |
| iri_ec:victim_other_groupoutgroup | EC x V-Oth Out |
| iri_pt:bystander_victim_groupoutgroup | PT x B-V Out |
| iri_pd:bystander_target_groupoutgroup | PD x B-Tgt Out |
| decision_target | Target Acc |
| decision_other | Other Acc |
| decision_target:decision_other | Target x Other |
| faculty_player_factorEngineering | Eng part. |
| sex_female | Woman |
| age | Age |
| ses | SES |


# Conclusion

The conclusions presented here should be interpreted as associational rather than causal. In this report, moral judgement was estimated with a two-sided Tobit model that handles censoring, repeated participant observations, and session adjustment through `factor(session)` with participant-cluster robust inference.

This conclusion section cross-references the full report structure. It should be read together with the H1-H5 equation summaries, the hypothesis significance summary by role, the full coefficient tables and interpretation summary, and the significance-driven figures.

## Hypothesis-by-hypothesis synthesis

### H1

H1 evaluates empathy as a direct predictor of moral judgement while retaining common controls. For cross-reference, see the H1 equation summary and the H1 role-specific coefficient tables and figures. In the victim role,
the role-specific support summary highlighted: Empathy: Perspective taking**.
In the bystander role,
no focal term reached the p < 0.10 threshold in the role-specific summary table.
Taken together, H1 suggests that the role position conditions how clearly empathy appears in the fitted judgement pattern.

### H2

H2 reminder: active relational predictors are expressed with row-dynamic `target`/`other` semantics; `group_target` and `group_other` remain legacy source-audit fields and are not active H2 predictors.

H2 focuses on role-specific ingroup/outgroup structure. For cross-reference, see the H2 equation summary and the H2 role-specific coefficient tables and figures. In the victim role,
no focal term reached the p < 0.10 threshold in the role-specific summary table.
In the bystander role,
the role-specific support summary highlighted: Bystander-target outgroup vs ingroup+; Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup+.
This comparison indicates that relational alignment cues are not equally informative across roles, and they can become more visible when participants evaluate as observers rather than as directly harmed actors.

### H3

H3 combines empathy, group structure, and interaction terms. For cross-reference, see the H3 equation summary, the H3 coefficient tables, and the H3 interaction figures. In the victim role,
the role-specific support summary highlighted: Empathy: Fantasy*; Empathy: Perspective taking+.
In the bystander role,
the role-specific support summary highlighted: Empathy: Empathic concern+; Empathy: Personal distress+; Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup+; Empathy: Fantasy x Bystander-victim outgroup vs ingroup+; Empathy: Personal distress x Bystander-victim outgroup vs ingroup*.
The H3 evidence should therefore be interpreted as a test of contextual moderation: empathy does not necessarily operate as a uniform slope when social distance changes.

### H4

H4 reminder: legacy `accept_target` corresponds to active `decision_target`, and legacy `accept_other` corresponds to active `decision_other`; both refer to row-dynamic `target`/`other` roles.

H4 tests decision terms directly through `decision_target`, `decision_other`, and their interaction. For cross-reference, see the H4 equation summary and the H4 role-specific coefficient tables and significance figures. In the victim role,
the role-specific support summary highlighted: Target accepted***; Other negotiator accepted***; Target accepted x Other accepted***.
In the bystander role,
the role-specific support summary highlighted: Target accepted***; Other negotiator accepted***; Target accepted x Other accepted***.
Across both roles, H4 is typically where the decisional mechanism is most clearly visible, because the target judgement is explicitly conditioned by joint negotiation outcomes.

### H5

H5 reminder: the integrated specification keeps `target`/`other` semantics for relational and decision terms; `group_target`/`group_other` remain legacy audit fields, and legacy `accept_target`/`accept_other` map to active `decision_target`/`decision_other`.

H5 is the integrated specification combining empathy, relational terms, decisions, and interactions. For cross-reference, see the H5 equation summary, H5 coefficient tables, and H5 significance figures. In the victim role,
the role-specific support summary highlighted: Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-other outgroup vs ingroup+; Target accepted x Other accepted***.
In the bystander role,
the role-specific support summary highlighted: Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted***.
H5 should be read as a synthesis rather than a replacement of previous hypotheses: it shows how dispositional, relational, and decisional components coexist in one model.

## Overall interpretation

Taken as a whole, the five hypotheses indicate that moral judgement in this experiment is multi-mechanistic rather than one-dimensional. Empathy-related terms can matter, relational alignment can matter, and decision terms can matter strongly, but their visibility changes by role and model context.

In practical terms, the report supports a role-contingent interpretation: victim-side judgement retains stronger dispositional content in some specifications, while bystander-side judgement often shows greater dependence on relational context, and both roles remain sensitive to the joint decisions made by negotiators.

