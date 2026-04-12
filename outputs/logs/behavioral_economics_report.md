# Behavioral-Economics Style Dynamic Report

Generated on 2026-04-11 22:02:12.

## Materials and Methods

The journal-style report uses the pooled analytical file rather than splitting the narrative by source dataset. The analyzed sample contains 243 participants and 4,860 judgment-by-negotiator observations after preprocessing. Each participant contributes two judgments per scenario, one for each negotiator, so the long-format outcome is defined at the judgment-by-negotiator level throughout.

Role-specific estimation remains central to the design, but it is handled within a single narrative. The victim subset contributes 243 participants, whereas the bystander subset contributes 243 participants. In the victim subset, ingroup/outgroup/control coding is defined relative to the victim-player; in the bystander subset, negotiator-side coding is defined relative to the observer and is paired with the observer-victim ingroup/outgroup relation.

To respect journal space constraints, the report uses four compact tables and five figures, with a fifth table added only when the non-parametric robustness branch is enabled. The figure plan prioritizes the two role-specific descriptive figures, each split into accepted-versus-rejected rows across the six explicit case configurations, plus one focal figure each for H1, H2, and H3, selected from the dynamic figure catalog by the lowest Tobit p-value among focal predictors. The table plan prioritizes one design table and one compact results table for each hypothesis family.

The bounded outcome is observed judgment severity on the original -9 to 9 scale. The main estimator is a Tobit model with censoring at the observed bounds and cluster-robust inference by participant id. The robustness branch is included only when the active configuration requests both estimators.

$$
\begin{aligned}
y_{isn}^{obs} &= \min\{9,\max[-9, y_{isn}^{*}]\}
\end{aligned}
$$


For H1, empathy enters through the four IRI dimensions (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`), together with judged-negotiator status, counterpart status, decision outcome, subset-relevant victim alignment, and participant controls.

$$
\begin{aligned}
y_{isn}^{*} &= \alpha_r + \mathbf{E}_i\beta_r + \mathbf{R}_{isn}\gamma_r \\
&\quad +\ \mathbf{X}_i\delta_r + \varepsilon_{isn}
\end{aligned}
$$


For H2, the victim subset uses the joint judged-counterpart structure directly, whereas the bystander subset augments that structure with the observer-victim relation and their interaction.

$$
\begin{aligned}
y_{isn,V}^{*} &= \alpha_V + \mathbf{S}_{isn}\theta_V + \mathbf{E}_i\beta_V \\
&\quad +\ \mathbf{X}_i\delta_V + \varepsilon_{isn}
\end{aligned}
$$


$$
\begin{aligned}
y_{isn,O}^{*} &= \alpha_O + \mathbf{S}_{isn}\theta_O + V_{isn}\lambda_O \\
&\quad +\ (\mathbf{S}_{isn}\times V_{isn})\kappa_O + \mathbf{E}_i\beta_O \\
&\quad +\ \mathbf{X}_i\delta_O + \varepsilon_{isn}
\end{aligned}
$$


For H3, empathy is allowed to interact with judged-negotiator status while decision outcome, judged-status-by-decision terms, counterpart structure, and subset-relevant controls remain in the model.

$$
\begin{aligned}
y_{isn}^{*} &= \alpha_r + \mathbf{E}_i\beta_r + \mathbf{J}_{isn}\eta_r + A_{isn}\pi_r \\
&\quad +\ (\mathbf{E}_i \times \mathbf{J}_{isn})\rho_r + (A_{isn} \times \mathbf{J}_{isn})\tau_r \\
&\quad +\ \mathbf{C}_{isn}\phi_r + \mathbf{X}_i\delta_r + \varepsilon_{isn}
\end{aligned}
$$


The current configuration estimates Tobit as the main model and does not add the non-parametric robustness branch.

Table 1 reports the pooled design and outcome distribution that anchor the rest of the journal-style summary.

| Sample | Participants | Judgments | Judgments / participant | Mean judgment | SD | % at -9 | % at 9 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Pooled | 243 | 4860 | 20 | 1.62 | 6.67 | 13.9% | 30.2% |
| Victim | 243 | 2430 | 10 | 1.50 | 6.84 | 15.5% | 30.6% |
| Bystander | 243 | 2430 | 10 | 1.74 | 6.50 | 12.3% | 29.8% |

_Note._ Displayed samples: Pooled, Victim, Bystander. Each scenario contributes two judgment observations per participant, one per negotiator. Outcome bounds are the observed censoring points used by the Tobit estimator.

## Results

The descriptive distributions already show why subset-specific estimation matters: the victim and bystander judgment profiles are not identical across the six scenario configurations, and the accept-versus-reject split adds another visible layer of structure even though both subsets are evaluated on the same bounded scale. Figures 1 and 2 therefore retain both the subset split and the decision split at the descriptive level while keeping the narrative pooled and compact.

![Figure 1. Victim-subset judgment distributions across the six explicit case configurations, with separate rows for accepted and rejected harmful deals. The histogram scale is fixed at -9 to 9 to match the observed judgment bounds.](../figures/figure_06_victim_subset_judgment_distributions_across_six_case_configurations.png){ width=6.7in }

![Figure 2. Bystander-subset judgment distributions across the six explicit case configurations, with separate rows for accepted and rejected harmful deals. The histogram scale is fixed at -9 to 9 to match the observed judgment bounds.](../figures/figure_07_bystander_subset_judgment_distributions_across_six_case_configurations.png){ width=6.7in }

At the reporting threshold, H1 produced focal empathy effects only in the victim subset.
The compact summary in Table 2 focuses on the active four-construct empathy specification. In the victim subset, the strongest focal estimates were
PT (B; b = 0.86, p = 0.017; more positive judgments).
In the bystander subset, the corresponding focal estimates were
not available at the reporting threshold.
The H1 narrative below is generated from the currently saved focal coefficient rows rather than from a fixed template.

| Subset | Model | Predictor | b [95% CI] | p |
| --- | --- | --- | --- | --- |
| Victim | B | PT | 0.86 [0.15, 1.57] | 0.017* |

_Note._ The table is intentionally restricted to focal empathy estimates reported by the dynamic pipeline. Subset(s) shown: Victim. Model suffix(es) shown: B. Displayed predictors: PT. Abbrev.: PT = perspective taking.

![Figure 3. Selected H1 focal effect (PT). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95% confidence intervals.](../figures/figure_sig_H1_iri_pt_h1_empathy_perspective_taking.png){ width=6.4in }

At the reporting threshold, H2 produced focal relational-structure effects only in the bystander subset.
In the victim subset, the most relevant H2 estimate was
not available at the reporting threshold.
In the bystander subset, the most relevant H2 estimates were
B-V Out (B; b = -1.34, p = 0.035; more negative judgments), V-N2 In (B; b = 1.51, p = 0.071; more positive judgments), and B-N2 Out (B; b = -1.05, p = 0.073; more negative judgments).
This role difference is substantively important because the bystander model adds the player-victim relation and its interaction with negotiator-side structure, whereas the victim model does not require that extra layer.

| Subset | Model | Predictor | b [95% CI] | p |
| --- | --- | --- | --- | --- |
| Bystander | B | B-V Out | -1.34 [-2.59, -0.09] | 0.035* |
| Bystander | B | V-N2 In | 1.51 [-0.13, 3.15] | 0.071+ |
| Bystander | B | B-N2 Out | -1.05 [-2.19, 0.10] | 0.073+ |
| Bystander | B | B-N2 In | -1.94 [-4.12, 0.25] | 0.083+ |
| Bystander | B | B-N1 In x B-N2 In | -1.73 [-3.78, 0.32] | 0.098+ |

_Note._ Only focal H2 structure and observer-side interaction terms are shown. Subset(s) shown: Bystander. Model suffix(es) shown: B. Displayed predictors: B-V Out, B-N2 In, B-N2 Out, V-N2 In, B-N1 In x B-N2 In. Abbrev.: N1 = judged negotiator; N2 = counterpart negotiator; B-V = bystander-victim relation; V-N2 = victim-negotiator 2 relation; B-N1 = bystander-negotiator 1 relation; B-N2 = bystander-negotiator 2 relation.

![Figure 4. Selected H2 relational effect (B-V Out). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95% confidence intervals.](../figures/figure_sig_H2_bystander_victim_groupout_h2_bystander_victim_outgroup_ref_ingroup.png){ width=6.4in }

At the reporting threshold, H3 produced focal moderation effects in both subsets. Signals were denser in the bystander subset.
In the victim subset, the leading H3 interactions were
PT x V-N1 Out (B; b = 1.60, p = 0.014; more positive judgments) and EC x V-N1 Out (B; b = -1.49, p = 0.036; more negative judgments).
In the bystander subset, the leading H3 interactions were
B-N1 Out x FS (B; b = -0.98, p = 0.039; more negative judgments), B-V Out x PD (B; b = 0.88, p = 0.064; more positive judgments), and B-N2 Out x PT (B; b = -1.12, p = 0.084; more negative judgments).
The interaction summary below is generated from the currently saved focal coefficient rows rather than from a fixed template.

| Subset | Model | Predictor | b [95% CI] | p |
| --- | --- | --- | --- | --- |
| Victim | B | PT x V-N1 Out | 1.60 [0.33, 2.87] | 0.014* |
| Victim | B | EC x V-N1 Out | -1.49 [-2.87, -0.10] | 0.036* |
| Bystander | B | B-N1 Out x FS | -0.98 [-1.90, -0.05] | 0.039* |
| Bystander | B | B-V Out x PD | 0.88 [-0.05, 1.81] | 0.064+ |
| Bystander | B | B-N2 Out x PT | -1.12 [-2.39, 0.15] | 0.084+ |

_Note._ Only focal H3 empathy-by-judged-status interactions are shown. Subset(s) shown: Victim, Bystander. Model suffix(es) shown: B. Displayed predictors: EC x V-N1 Out, PT x V-N1 Out, B-V Out x PD, B-N1 Out x FS, B-N2 Out x PT. Abbrev.: FS = fantasy; EC = empathic concern; PT = perspective taking; PD = personal distress; N1 = judged negotiator; N2 = counterpart negotiator; B-V = bystander-victim relation; V-N1 = victim-negotiator 1 relation; B-N1 = bystander-negotiator 1 relation; B-N2 = bystander-negotiator 2 relation.

![Figure 5. Selected H3 interaction effect (PT x V-N1 Out). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95% confidence intervals.](../figures/figure_sig_H3_iri_pt_victim_n1_groupout_h3_empathy_perspective_taking_x_victim_n1_outgroup_ref_control.png){ width=6.4in }

Because the active configuration is Tobit-only, the results section reports the main censored-model estimates without a separate robustness table.

## Limitations

Several limitations qualify the interpretation. First, repeated judgments are clustered within participant, and although the pipeline addresses this with participant-level clustered inference, the design still concentrates multiple morally related responses within the same respondent. Second, the bounded outcome requires censoring-aware estimation because the judgment scale piles up at both -9 and 9. Third, ingroup/outgroup/control coding is relational rather than purely individual, so the same participant can appear in different judged-counterpart structures across scenarios. Fourth, subset-specific formulas are a design strength for identification but they also mean that coefficient blocks are not perfectly symmetric across victim and bystander models.

Because the current configuration does not include the non-parametric branch, robustness to alternative censored estimators is not assessed in this report version.

## Conclusion

Across the pooled analytical sample, the clearest behavioral pattern is that empathy-related variation in judgment is conditional on relational context rather than separable from it. Victim judgments show the strongest empathy gradients, bystander judgments retain smaller but still interpretable empathy effects, H2 highlights a narrower set of role-dependent relational contrasts, and H3 indicates that empathy slopes change with judged-negotiator status. In behavioral terms, moral evaluation in this design is jointly shaped by empathic orientation, the judged negotiator's relational position, and the participant's role in the scenario.

