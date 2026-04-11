# Behavioral-Economics Style Dynamic Report

Generated on 2026-04-11 09:04:59.

## Materials and Methods

The journal-style report uses the pooled analytical file rather than splitting the narrative by source dataset. The analyzed sample contains 243 participants and 4,860 judgment-by-negotiator observations after preprocessing. Each participant contributes two judgments per scenario, one for each negotiator, so the long-format outcome is defined at the judgment-by-negotiator level throughout.

Role-specific estimation remains central to the design, but it is handled within a single narrative. The victim subset contributes 243 participants, whereas the bystander subset contributes 243 participants. In the victim subset, ingroup/outgroup/control coding is defined relative to the victim-player; in the bystander subset, negotiator-side coding is defined relative to the observer and is paired with the observer-victim ingroup/outgroup relation.

To respect journal space constraints, the report uses four compact tables and five figures, with a fifth table added only when the non-parametric robustness branch is enabled. The figure plan prioritizes the two six-panel descriptive subset figures plus one focal figure each for H1, H2, and H3, selected from the dynamic figure catalog by the lowest Tobit p-value among focal predictors. The table plan prioritizes one design table and one compact results table for each hypothesis family.

The bounded outcome is observed judgment severity on the original -9 to 9 scale. The main estimator is a Tobit model with censoring at the observed bounds and cluster-robust inference by participant id. The robustness branch is included only when the active configuration requests both estimators.

$$y_{isn}^{obs} = \min\{9,\max[-9, y_{isn}^{*}]\}$$

For H1, empathy enters through the four IRI dimensions (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`), together with judged-negotiator status, counterpart status, decision outcome, subset-relevant victim alignment, and participant controls.

$$y_{isn}^{*} = \alpha_r + \mathbf{E}_i\beta_r + \mathbf{R}_{isn}\gamma_r + \mathbf{X}_i\delta_r + \varepsilon_{isn}$$

For H2, the victim subset uses the joint judged-counterpart structure directly, whereas the bystander subset augments that structure with the observer-victim relation and their interaction.

$$y_{isn,V}^{*} = \alpha_V + \mathbf{S}_{isn}\theta_V + \mathbf{E}_i\beta_V + \mathbf{X}_i\delta_V + \varepsilon_{isn}$$

$$y_{isn,O}^{*} = \alpha_O + \mathbf{S}_{isn}\theta_O + V_{isn}\lambda_O + (\mathbf{S}_{isn}\times V_{isn})\kappa_O + \mathbf{E}_i\beta_O + \mathbf{X}_i\delta_O + \varepsilon_{isn}$$

For H3, empathy is allowed to interact with judged-negotiator status while decision outcome, judged-status-by-decision terms, counterpart structure, and subset-relevant controls remain in the model.

$$y_{isn}^{*} = \alpha_r + \mathbf{E}_i\beta_r + \mathbf{J}_{isn}\eta_r + A_{isn}\pi_r + (\mathbf{E}_i \times \mathbf{J}_{isn})\rho_r + (A_{isn} \times \mathbf{J}_{isn})\tau_r + \mathbf{C}_{isn}\phi_r + \mathbf{X}_i\delta_r + \varepsilon_{isn}$$

The current configuration estimates Tobit as the main model and does not add the non-parametric robustness branch.

Table 1 reports the pooled design and outcome distribution that anchor the rest of the journal-style summary.

| Sample | Participants | Judgments | Judgments / participant | Mean judgment | SD | % at -9 | % at 9 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Pooled | 243 | 4860 | 20 | 1.62 | 6.67 | 13.9% | 30.2% |
| Victim | 243 | 2430 | 10 | 1.50 | 6.84 | 15.5% | 30.6% |
| Bystander | 243 | 2430 | 10 | 1.74 | 6.50 | 12.3% | 29.8% |

_Note._ Pooled = full analytical long file. Each scenario contributes two judgment observations per participant, one per negotiator. Outcome bounds are the observed censoring points used by the Tobit estimator.

## Results

The descriptive distributions already show why subset-specific estimation matters: the victim and bystander judgment profiles are not identical across the six scenario configurations, even though both are evaluated on the same bounded scale. Figures 1 and 2 therefore retain the subset split at the descriptive level while keeping the narrative pooled and compact.

![Figure 1. Victim-subset judgment distributions across the six explicit case configurations. The histogram scale is fixed at -9 to 9 to match the observed judgment bounds.](../figures/figure_06_victim_subset_judgment_distributions_across_six_case_configurations.png){ width=6.7in }

![Figure 2. Bystander-subset judgment distributions across the six explicit case configurations. The histogram scale is fixed at -9 to 9 to match the observed judgment bounds.](../figures/figure_07_bystander_subset_judgment_distributions_across_six_case_configurations.png){ width=6.7in }

At the reporting threshold, H1 produced focal empathy effects only in the victim subset.
The compact summary in Table 2 focuses on the active four-construct empathy specification. In the victim subset, the strongest focal estimates were
PT (B; b = 1.32, p = 0.010; more positive judgments).
In the bystander subset, the corresponding focal estimates were
not available at the reporting threshold.
The H1 narrative below is generated from the currently saved focal coefficient rows rather than from a fixed template.

| Subset | Model | Predictor | b [95% CI] | p |
| --- | --- | --- | --- | --- |
| Victim | B | PT | 1.32 [0.31, 2.32] | 0.010* |

_Note._ Active empathy specification = FS, EC, PT, PD. N1 = judged negotiator; N2 = counterpart negotiator; V = observer-victim relation; In = ingroup; Out = outgroup; Ctl = control label hidden; Acc = accepted harmful deal. The table is intentionally restricted to focal empathy estimates reported by the dynamic pipeline.

![Figure 3. Selected H1 focal effect (PT). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95% confidence intervals.](../figures/figure_sig_H1_iri_pt_h1_empathy_perspective_taking.png){ width=6.4in }

At the reporting threshold, H2 produced focal relational-structure effects only in the bystander subset.
In the victim subset, the most relevant H2 estimate was
not available at the reporting threshold.
In the bystander subset, the most relevant H2 estimates were
N1 Out, N2 In (B; b = -2.67, p = 0.054; more negative judgments).
This role difference is substantively important because the bystander model adds the player-victim relation and its interaction with negotiator-side structure, whereas the victim model does not require that extra layer.

| Subset | Model | Predictor | b [95% CI] | p |
| --- | --- | --- | --- | --- |
| Bystander | B | N1 Out, N2 In | -2.67 [-5.37, 0.04] | 0.054+ |

_Note._ Active empathy specification = FS, EC, PT, PD. N1 = judged negotiator; N2 = counterpart negotiator; V = observer-victim relation. Only focal H2 structure and observer-side interaction terms are shown.

![Figure 4. Selected H2 relational effect (N1 Out, N2 In). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95% confidence intervals.](../figures/figure_sig_H2_h2_negstruct_j_out_c_in_h2_negotiator_side_structure_n1_outgroup_n2_ingroup_ref_n1_control_label_hidden_n2_control.png){ width=6.4in }

At the reporting threshold, H3 produced focal moderation effects only in the victim subset.
In the victim subset, the leading H3 interactions were
PT x N1-In (B; b = 2.01, p = 0.040; more positive judgments) and PT x N1-Out (B; b = 2.00, p = 0.050; more positive judgments).
In the bystander subset, the leading H3 interactions were
not available at the reporting threshold.
The interaction summary below is generated from the currently saved focal coefficient rows rather than from a fixed template.

| Subset | Model | Predictor | b [95% CI] | p |
| --- | --- | --- | --- | --- |
| Victim | B | PT x N1-In | 2.01 [0.09, 3.93] | 0.040* |
| Victim | B | PT x N1-Out | 2.00 [-0.00, 4.00] | 0.050+ |

_Note._ Active empathy specification = FS, EC, PT, PD. N1 = judged negotiator; N2 = counterpart negotiator; Acc = accepted harmful deal. Only focal H3 empathy-by-judged-status interactions are shown.

![Figure 5. Selected H3 interaction effect (PT x N1-In). Panels show Tobit-predicted judgments on the observed -9 to 9 scale with 95% confidence intervals.](../figures/figure_sig_H3_iri_pt_judged_ingroup_h3_empathy_perspective_taking_x_n1_ingroup.png){ width=6.4in }

Because the active configuration is Tobit-only, the results section reports the main censored-model estimates without a separate robustness table.

## Limitations

Several limitations qualify the interpretation. First, repeated judgments are clustered within participant, and although the pipeline addresses this with participant-level clustered inference, the design still concentrates multiple morally related responses within the same respondent. Second, the bounded outcome requires censoring-aware estimation because the judgment scale piles up at both -9 and 9. Third, ingroup/outgroup/control coding is relational rather than purely individual, so the same participant can appear in different judged-counterpart structures across scenarios. Fourth, subset-specific formulas are a design strength for identification but they also mean that coefficient blocks are not perfectly symmetric across victim and bystander models.

Because the current configuration does not include the non-parametric branch, robustness to alternative censored estimators is not assessed in this report version.

## Conclusion

Across the pooled analytical sample, the clearest behavioral pattern is that empathy-related variation in judgment is conditional on relational context rather than separable from it. Victim judgments show the strongest empathy gradients, bystander judgments retain smaller but still interpretable empathy effects, H2 highlights a narrower set of role-dependent relational contrasts, and H3 indicates that empathy slopes change with judged-negotiator status. In behavioral terms, moral evaluation in this design is jointly shaped by empathic orientation, the judged negotiator's relational position, and the participant's role in the scenario.

