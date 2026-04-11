# Scientific Analysis of Moral Judgments with Tobit Models and Four Empathy Constructs

## Dataset Description
The empirical foundation of this project rests on two primary experimental datasets: FLORIDA and BUC.  The sample consists of students from both the Floridablanca and Bucaramanga Campuses.  These datasets capture incentivized moral judgments from distinct socio-economic contexts. Participants were presented  with standardized negotiation scenarios where a negotiator's decision resulted in varying degrees of payoff for  themselves, their own group, and a victim group. Under  Option 2: judgment-level relational modeling , each judgment is treated as relational and linked both to a descriptive victim x negotiator scenario shorthand and to hypothesis-specific predictors for N1 (judged negotiator) and N2 (counterpart), observer-side victim alignment when applicable, and additional relational controls.

## Option 2 Relational Case Configuration
All hypothesis sections are now interpreted through negotiator-level relational predictors rather than descriptive case labels.

## Predictor Glossary and Abbreviations
The regression tables and dynamic figures use compact predictor labels to keep long H2 and H3 rows readable. The bullet list below maps those compact labels back to the full meanings used in the manuscript.
- `iri_fs, iri_ec, iri_pt, iri_pd` [FS, EC, PT, PD]: Active empathy predictors: fantasy, empathic concern, perspective taking, and personal distress. Used in H1/H2/H3 active model.
- `judged_ingroup, judged_outgroup` [N1 In, N1 Out]: N1 contrasts relative to the N1 control-labeled baseline. Used in H1/H3.
- `counterpart_ingroup, counterpart_outgroup` [N2 In, N2 Out]: N2 contrasts relative to the N2 control-labeled baseline. Used in H1/H3.
- `decision_accept` [Acc]: Accepted harmful deal relative to rejected harmful deal. Used in H1/H3.
- `observer_victim_outgroup` [V Out (Obs)]: Observer-only victim outgroup contrast; excluded from victim-only formulas. Used in H1/H3 Bystander only.
- `h2_negstruct_*` [N1 ..., N2 ...]: H2 joint N1/N2 structure dummies with reference N1 Ctl, N2 Ctl. Used in H2 Victim and Bystander.
- `player_victim_outgroup` [V Out]: Observer-side player-victim outgroup contrast with player-victim ingroup as the reference. Used in H2 Bystander only.
- `player_victim_outgroup:h2_negstruct_*` [V Out x N1 ..., N2 ...]: Bystander-only H2 interaction: whether the negotiator-side structure changes when player and victim are outgroup-aligned. Used in H2 Bystander only.
- `decision_accept:judged_*` [Acc x N1 ...]: H3 decision-by-judged-status interaction block. Used in H3.
- `iri_*:judged_*` [FS / EC / PT / PD x N1 ...]: H3 empathy-by-judged-status interaction block. Used in H3.
- `participant_engineering` [Eng part.]: Participant faculty contrast. Used in H1/H2/H3.
- `sex_man` [Man]: Sex contrast with woman as the reference. Used in H1/H2/H3.
- `age` [Age]: Participant age in original units. Used in H1/H2/H3.
- `economic_status` [SES]: Economic status in original units. Used in H1/H2/H3.
- `factor(negotiator_slot)` [Slot 2]: Negotiator slot contrast with slot 1 as the reference. Used in H1/H2/H3.

## Interpretation of Interaction Terms
The models herein employ several predefined predictors. It is important to note how interaction terms are interpreted in the context of this behavioral experiment:

1. **Interaction Subsumption:** When an interaction term is statistically significant, it indicates that the effect of one variable depends on the level of the other. Crucially, if the interaction is significant but the constituent main effects are not explicitly significant, their effects are fully subsumed and contextualized by the interaction.
2. **Continuous by Discrete Interactions:** For terms like `iri_pt:judged_outgroup`, a negative coefficient implies that the severity of moral judgment (lower score) induced by higher empathy is steeper (magnified) when evaluating an outgroup negotiator relative to the control-labeled baseline. A positive coefficient would mean empathy makes judgments less severe for that outgroup condition.
3. **Discrete by Discrete Interactions:** For terms like `judged_outgroup:decision_accept`, a positive coefficient implies that the change in moral judgment when moving from rejecting a deal to accepting a deal is more positive (less morally condemned) for an outgroup negotiator than for the control-labeled baseline condition.

## Hypothesis Significance Summary
Only hypothesis-relevant predictors with p < 0.10 in the available Tobit models are shown below, split into victim and bystander subset tables. Symbols follow the rule `+` for p < 0.10, `*` for p < 0.05, `**` for p < 0.01, and `***` for p < 0.001. Dynamic figures are generated only for predictors that appear here with at least one significance symbol.
### Victim subset
| Hypothesis | Tobit support |
| --- | --- |
| H1 | PT* |
| H2 | None |
| H3 | PT x N1-In*; PT x N1-Out+ |
_Note._ Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.

### Bystander subset
| Hypothesis | Tobit support |
| --- | --- |
| H1 | None |
| H2 | N1 Out, N2 In+ |
| H3 | None |
_Note._ Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.


## Significance-Driven Figures
Only hypothesis-relevant predictors that reach at least `p < .10` are visualized automatically. These figures rely on the saved Tobit fits, and `id` remains only an inference-level clustering unit.

### Empathy Effect

Empathy: Perspective taking is statistically significant in the Tobit model (*, p = 0.010). The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in Empathy Effect. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H1_iri_pt_h1_empathy_perspective_taking.png)

### Negotiator-Side Structure

Negotiator-side structure: N1 outgroup, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) is statistically significant in the Tobit model (+, p = 0.054). The figure below shows that predicted judgment is lower for N1 Out, N2 In than for Ref: N1 Ctl, N2 Ctl.

![Grouped Prediction Plot for Negotiator-side structure: N1 outgroup, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) in Negotiator-Side Structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H2_h2_negstruct_j_out_c_in_h2_negotiator_side_structure_n1_outgroup_n2_ingroup_ref_n1_control_label_hidden_n2_control.png)

### Empathy x Judged Status

Empathy: Perspective taking x N1 ingroup is statistically significant in the Tobit model (*, p = 0.040). The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is N1 In.

![Interaction Plot for Empathy: Perspective taking x N1 ingroup in Empathy x Judged Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H3_iri_pt_judged_ingroup_h3_empathy_perspective_taking_x_n1_ingroup.png)

Empathy: Perspective taking x N1 outgroup is statistically significant in the Tobit model (+, p = 0.050). The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is N1 Out.

![Interaction Plot for Empathy: Perspective taking x N1 outgroup in Empathy x Judged Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H3_iri_pt_judged_outgroup_h3_empathy_perspective_taking_x_n1_outgroup.png)


## All Significant Predictors (p < .10)
The following figures extend beyond the hypothesis-target terms and visualize every predictor that reaches `p < .10` in the available H1-H3 Tobit models. This includes significant controls such as age when they clear the threshold.

### judgments_bystander

Harm Accepted is statistically significant in:
- Empathy Effect Model B (Tobit)
- Empathy x Judged Status Model B (Tobit)
The figure below shows that predicted judgment is lower for Acc than for Rej.

![Grouped Prediction Plot for Harm Accepted in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_decision_accept_judgments_bystander_harm_accepted.png)

Age is statistically significant in:
- Negotiator-Side Structure Model B (Tobit)
- Empathy x Judged Status Model B (Tobit)
- Empathy Effect Model B (Tobit)
The figure below shows that across the observed range, higher Age corresponds to higher predicted judgment.

![Effect Plot for Age in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_age_judgments_bystander_age.png)

N1 outgroup is statistically significant in:
- Empathy x Judged Status Model B (Tobit)
The figure below shows that predicted judgment is lower for N1 Out than for N1 Ctl.

![Grouped Prediction Plot for N1 outgroup in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_judged_outgroup_judgments_bystander_n1_outgroup.png)

N1 ingroup is statistically significant in:
- Empathy x Judged Status Model B (Tobit)
The figure below shows that predicted judgment is lower for N1 In than for N1 Ctl.

![Grouped Prediction Plot for N1 ingroup in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_judged_ingroup_judgments_bystander_n1_ingroup.png)

Negotiator-side structure: N1 outgroup, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) is statistically significant in:
- Negotiator-Side Structure Model B (Tobit)
The figure below shows that predicted judgment is lower for N1 Out, N2 In than for Ref: N1 Ctl, N2 Ctl.

![Grouped Prediction Plot for Negotiator-side structure: N1 outgroup, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_h2_negstruct_j_out_c_in_judgments_bystander_negotiator_side_structure_n1_outgroup_n2_ingroup_ref_n1_control_label.png)

Engineering participant is statistically significant in:
- Empathy Effect Model B (Tobit)
- Empathy x Judged Status Model B (Tobit)
- Negotiator-Side Structure Model B (Tobit)
The figure below shows that predicted judgment is higher for Eng part. than for Hum part..

![Grouped Prediction Plot for Engineering participant in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_participant_engineering_judgments_bystander_engineering_participant.png)

Empathy: Perspective taking is statistically significant in:
- Empathy x Judged Status Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_pt_judgments_bystander_empathy_perspective_taking.png)

### judgments_victim

Harm Accepted is statistically significant in:
- Empathy Effect Model B (Tobit)
- Empathy x Judged Status Model B (Tobit)
The figure below shows that predicted judgment is lower for Acc than for Rej.

![Grouped Prediction Plot for Harm Accepted in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_decision_accept_judgments_victim_harm_accepted.png)

Empathy: Perspective taking is statistically significant in:
- Negotiator-Side Structure Model B (Tobit)
- Empathy Effect Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pt_judgments_victim_empathy_perspective_taking.png)

Empathy: Perspective taking x N1 ingroup is statistically significant in:
- Empathy x Judged Status Model B (Tobit)
The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is N1 In.

![Interaction Plot for Empathy: Perspective taking x N1 ingroup in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pt_judged_ingroup_judgments_victim_empathy_perspective_taking_x_n1_ingroup.png)

Empathy: Perspective taking x N1 outgroup is statistically significant in:
- Empathy x Judged Status Model B (Tobit)
The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is N1 Out.

![Interaction Plot for Empathy: Perspective taking x N1 outgroup in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pt_judged_outgroup_judgments_victim_empathy_perspective_taking_x_n1_outgroup.png)

Engineering participant is statistically significant in:
- Negotiator-Side Structure Model B (Tobit)
The figure below shows that predicted judgment is higher for Eng part. than for Hum part..

![Grouped Prediction Plot for Engineering participant in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 = judged negotiator; N2 = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_participant_engineering_judgments_victim_engineering_participant.png)


## Hypothesis Conclusion Summary
Each conclusion below is generated from the current Tobit coefficient outputs.
- H1. Original hypothesis: Empathy dimensions are associated with moral judgment severity after conditioning on judged-negotiator status, counterpart status, decision outcome, and observer-side victim alignment when applicable. Victim subset: Tobit conclusion: the available models point in the opposite direction of the hypothesis. Model B points in the opposite direction through Empathy: Perspective taking with a positive association (p = 0.010). Additional statistically significant signals include Harm Accepted with a negative association (p < 0.001) and Empathy: Perspective taking with a positive association (p = 0.010). Bystander subset: Tobit conclusion: the available models do not support the hypothesis. Model B does not support the hypothesis; none of four empathy dimensions are statistically significant, and the closest signal is Empathy: Perspective taking with a positive association (p = 0.163). Additional statistically significant signals include Harm Accepted with a negative association (p < 0.001) and Age with a positive association (p = 0.005).
- H2. Original hypothesis: Moral judgments vary with the joint judged-plus-counterpart negotiator structure, and in the bystander subset that structure may also depend on player-victim alignment. Victim subset: Tobit conclusion: the available models do not support the hypothesis. Model B does not support the hypothesis; none of negotiator-side structure contrasts are statistically significant, and the closest signal is Negotiator-side structure: N1 control label hidden, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) with a negative association (p = 0.227). Additional statistically significant signals include Empathy: Perspective taking with a positive association (p = 0.003) and Engineering participant with a positive association (p = 0.065). Bystander subset: Tobit conclusion: the available models support the hypothesis. Model B supports the hypothesis through Negotiator-side structure: N1 outgroup, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) with a negative association (p = 0.054). Additional statistically significant signals include Age with a positive association (p < 0.001) and Negotiator-side structure: N1 outgroup, N2 ingroup (ref = N1 control label hidden, N2 control label hidden) with a negative association (p = 0.054).
- H3. Original hypothesis: The empathy effect depends on the judged negotiator's ingroup, outgroup, or control status after retaining decision context and relational controls. Victim subset: Tobit conclusion: the available models support the hypothesis. Model B supports the hypothesis through Empathy: Perspective taking x N1 ingroup with a positive association (p = 0.040) and Empathy: Perspective taking x N1 outgroup with a positive association (p = 0.050). Additional statistically significant signals include Harm Accepted with a negative association (p < 0.001) and Empathy: Perspective taking x N1 ingroup with a positive association (p = 0.040). Bystander subset: Tobit conclusion: the available models do not support the hypothesis. Model B does not support the hypothesis; none of empathy-by-judged-status interactions are statistically significant, and the closest signal is Empathy: Perspective taking x N1 ingroup with a negative association (p = 0.111). Additional statistically significant signals include Harm Accepted with a negative association (p < 0.001) and Age with a positive association (p = 0.004).

## PDF Comprehensive Report Generated
Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented Tobit and cluster-aware non-parametric mathematical formulations, the Option 2 relational-variable logic, dual-estimator hypothesis testing, and the algorithmically interpreted natural language coefficients. When the run is dataset-specific, a matching alias such as `tobit_analysis_report_Buca.pdf` is also refreshed.

