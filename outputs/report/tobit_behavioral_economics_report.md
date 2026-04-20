# Behavioral-Economics Style Dynamic Report

By Leonardo H. Talero-Sarmiento; Date  2026-04-19 21:09:20.

## Materials and Methods

The active workflow analyzes the Version 2.0 consolidated long dataset as repeated moral judgments. The dependent variable is `judgement`. Each source row remains one analytical observation, and the pipeline reconstructs the N1/N2 context, role-specific ingroup/outgroup relations, and joint decision structure without reshaping the data again.

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
| H1 | Victim | Empathy: Perspective taking** |
| H2 | Bystander | Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+ |
| H2 | Victim | None below p < 0.10 |
| H3 | Bystander | Empathy: Empathic concern+; Empathy: Personal distress+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+; Empathy: Fantasy x Bystander-victim outgroup vs ingroup+; Empathy: Personal distress x Bystander-victim outgroup vs ingroup* |
| H3 | Victim | Empathy: Fantasy*; Empathy: Perspective taking+ |
| H4 | Bystander | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H4 | Victim | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Bystander | Victim-N1 outgroup vs ingroup*; Victim-N2 outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted*** |
| H5 | Victim | Empathy: Fantasy*; Victim-N2 outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-N1 outgroup vs ingroup+; Target accepted x Other accepted*** |

## Fit Snapshot

| hypothesis | role | model_family | session_handling | dependence_adjustment | lower_censored_n | upper_censored_n | AIC | BIC |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| H1 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 12558.780 | 12703.568 |
| H1 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 12280.557 | 12425.345 |
| H2 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 12557.426 | 12725.380 |
| H2 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 12297.645 | 12442.433 |
| H3 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 12569.153 | 12829.772 |
| H3 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 12296.035 | 12510.321 |
| H4 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11060.312 | 11199.308 |
| H4 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10747.901 | 10886.898 |
| H5 | Bystander | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 300 | 723 | 11080.219 | 11358.212 |
| H5 | Victim | Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id | 377 | 744 | 10749.255 | 10980.916 |

## Limitations

The repository does not currently fit a production multilevel Tobit with `(1|session)` inside the same estimator used here. To avoid overstating the implemented model, the pipeline encodes session as `factor(session)` and uses participant-cluster robust standard errors by `id`. Control-hidden faculty labels are retained as a separate level instead of being forced into ingroup or outgroup categories.

## Conclusion

The project now centers the experimental design rather than the old aggregated-IRI workflow. `judgement` is the outcome in all inferential models, the participant-level dependence adjustment is explicit, session handling is audited through `factor(session)`, role-specific relational coding differs between victim and bystander, and `decision_target` / `decision_other` are built directly into H4 and H5.

## Compliance Snapshot

| criterion | status | evidence |
| --- | --- | --- |
| a) uses judgement | YES | All formulas model judgement directly. |
| b) repeated structure by id | YES | All fitted Tobit models use participant-cluster robust standard errors through cluster = id. |
| c) session grouping | YES | The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept. |
| d) no double count introduced by the pipeline | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) victim and bystander treated differently | YES | Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander. |
| f) decision_target and decision_other included where required | YES | H4 and H5 both include decision_target, decision_other, and their interaction. |
| g) sociodemographics included in every hypothesis model | YES | Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor. |

