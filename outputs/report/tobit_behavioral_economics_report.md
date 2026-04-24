# Behavioral-Economics Style Dynamic Report

By Leonardo H. Talero-Sarmiento; Date  2026-04-23 21:26:52.

## Materials and Methods

The active workflow analyzes the Version 2.0 consolidated long dataset as repeated moral judgments. The dependent variable is `judgement`. Each source row remains one analytical observation, and the pipeline encodes role-specific target/other relations and joint decision structure without reshaping the data again.

Primary estimation now uses a two-sided Tobit fitted with `survival::survreg`. The lower and upper observed limits of `judgement` are treated as bilateral censoring points, participant dependence is handled with `cluster = id` and `robust = TRUE`, and session differences are represented with `factor(session)` rather than a claimed random session intercept. Victim and bystander models are estimated separately.

| sample | rows | participants | mean_judgement | sd_judgement |
| --- | --- | --- | --- | --- |
| All | 4860 | 243 | 1.623 | 6.674 |
| Victim | 2430 | 243 | 1.504 | 6.842 |
| Bystander | 2430 | 243 | 1.741 | 6.500 |

## Results

The table below lists the terms that reached at least `p < 0.10` in the primary Tobit models. Empty cells mean that the corresponding hypothesis-role combination did not produce a focal term below that threshold.

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Bystander | None below p < 0.10 |
| H1 | Victim | Empathy: Perspective taking* |
| H2 | Bystander | Victim-target outgroup vs ingroup*; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup* |
| H2 | Victim | None below p < 0.10 |
| H3 | Bystander | Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup* |
| H3 | Victim | Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Empathy: Fantasy x Victim-other outgroup vs ingroup+ |
| H4 | Bystander | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H4 | Victim | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Bystander | Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted*** |
| H5 | Victim | Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-other outgroup vs ingroup+; Target accepted x Other accepted*** |

## Fit Snapshot

| hypothesis | role | model_family | session_handling | dependence_adjustment | lower_censored_n | upper_censored_n | AIC | BIC |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| H1 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11062.708 | 11224.870 |
| H1 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10737.899 | 10900.062 |
| H2 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11065.817 | 11251.146 |
| H2 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10753.897 | 10916.060 |
| H3 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11076.716 | 11354.709 |
| H3 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10748.048 | 10979.709 |
| H4 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11060.312 | 11199.308 |
| H4 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10747.901 | 10886.898 |
| H5 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11076.716 | 11354.709 |
| H5 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10748.048 | 10979.709 |

## Limitations

The repository does not currently fit a production multilevel Tobit with `(1|session)` inside the same estimator used here. To avoid overstating the implemented model, the pipeline encodes session as `factor(session)` and uses participant-cluster robust standard errors by `id`. Control-hidden faculty labels are retained as a separate level instead of being forced into ingroup or outgroup categories.

## Conclusion

The project now centers the experimental design rather than the old aggregated-IRI workflow. `judgement` is the outcome in all inferential models, the participant-level dependence adjustment is explicit, session handling is audited through `factor(session)`, role-specific relational coding differs between victim and bystander, and `accept_target` / `accept_other` are built directly into H4 and H5.

## Compliance Snapshot

| criterion | status | evidence |
| --- | --- | --- |
| a) uses judgement | YES | All formulas model judgement directly. |
| b) repeated structure by id | YES | All fitted Tobit models use participant-cluster robust standard errors through cluster = id. |
| c) session grouping | YES | The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept. |
| d) no double count introduced by the pipeline | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) victim and bystander treated differently | YES | Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander. |
| f) accept_target and accept_other included in H1-H5 | YES | All H1-H5 formulas include accept_target, accept_other, and their interaction as part of the active specification. |
| g) sociodemographics included in every hypothesis model | YES | Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor. |

