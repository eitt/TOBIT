# Scientific Analysis of Moral Judgments with Tobit and Cluster-Aware Non-Parametric Robustness Checks

## Dataset Description
The empirical foundation of this project rests on two primary experimental datasets: FLORIDA and BUC.  The sample consists of students from both the Floridablanca and Bucaramanga Campuses.  These datasets capture incentivized moral judgments from distinct socio-economic contexts. Participants were presented  with standardized negotiation scenarios where a negotiator's decision resulted in varying degrees of payoff for  themselves, their own group, and a victim group. Under  Option 2: judgment-level relational modeling , each judgment is treated as relational and linked both to a descriptive victim x negotiator scenario shorthand and to hypothesis-specific predictors for negotiator-side structure, observer-side victim alignment when applicable, and additional relational controls.

## Option 2 Relational Case Configuration
All hypothesis sections are now interpreted through negotiator-level relational predictors rather than descriptive case labels.

## Predictor Glossary and Abbreviations
The regression tables and dynamic figures use compact predictor labels to keep long H2 and H3 rows readable. The bullet list below maps those compact labels back to the full meanings used in the manuscript.
- `iri_total` [Emp]: Composite empathy predictor used in Model A. Used in H1/H2/H3 Model A.
- `iri_fs, iri_ec, iri_pt, iri_pd` [FS, EC, PT, PD]: IRI subscales used in Model B: fantasy, empathic concern, perspective taking, and personal distress. Used in H1/H2/H3 Model B.
- `judged_outgroup, judged_control` [JN Out, JN Ctl]: Judged-negotiator contrasts relative to judged ingroup. Used in H1/H3.
- `counterpart_outgroup, counterpart_control` [CN Out, CN Ctl]: Counterpart-negotiator contrasts relative to counterpart ingroup. Used in H1/H3.
- `decision_accept` [Acc]: Accepted harmful deal relative to rejected harmful deal. Used in H1/H3.
- `observer_victim_outgroup` [V Out (Obs)]: Observer-only victim outgroup contrast; excluded from victim-only formulas. Used in H1/H3 Bystander only.
- `h2_negstruct_*` [JN ..., CN ...]: H2 joint judged/counterpart structure dummies with reference JN In, CN In. Used in H2 Victim and Bystander.
- `player_victim_outgroup` [V Out]: Observer-side player-victim outgroup contrast with player-victim ingroup as the reference. Used in H2 Bystander only.
- `player_victim_outgroup:h2_negstruct_*` [V Out x JN ..., CN ...]: Bystander-only H2 interaction: whether the negotiator-side structure changes when player and victim are outgroup-aligned. Used in H2 Bystander only.
- `decision_accept:judged_*` [Acc x JN ...]: H3 decision-by-judged-status interaction block. Used in H3.
- `iri_*:judged_*` [Emp / FS / EC / PT / PD x JN ...]: H3 empathy-by-judged-status interaction block. Used in H3.
- `participant_engineering` [Eng part.]: Participant faculty contrast. Used in H1/H2/H3.
- `sex_man` [Man]: Sex contrast with woman as the reference. Used in H1/H2/H3.
- `age` [Age]: Participant age in original units. Used in H1/H2/H3.
- `economic_status` [SES]: Economic status in original units. Used in H1/H2/H3.
- `factor(negotiator_slot)` [Slot 2]: Negotiator slot contrast with slot 1 as the reference. Used in H1/H2/H3.

## Interpretation of Interaction Terms
The models herein employ several predefined predictors. It is important to note how interaction terms are interpreted in the context of this behavioral experiment:

1. **Interaction Subsumption:** When an interaction term is statistically significant, it indicates that the effect of one variable depends on the level of the other. Crucially, if the interaction is significant but the constituent main effects are not explicitly significant, their effects are fully subsumed and contextualized by the interaction.
2. **Continuous by Discrete Interactions:** For terms like `iri_total:judged_outgroup`, a negative coefficient implies that the severity of moral judgment (lower score) induced by higher empathy is steeper (magnified) when evaluating an outgroup negotiator compared to an ingroup negotiator. A positive coefficient would mean empathy makes judgments less severe for the outgroup.
3. **Discrete by Discrete Interactions:** For terms like `judged_outgroup:decision_accept`, a positive coefficient implies that the change in moral judgment when moving from rejecting a deal to accepting a deal is more positive (less morally condemned) for an outgroup negotiator than for an ingroup negotiator.

## Hypothesis Significance Summary
Only hypothesis-relevant predictors with p < 0.10 in the available Tobit models are shown below, split into victim and bystander subset tables. Symbols follow the rule `+` for p < 0.10, `*` for p < 0.05, `**` for p < 0.01, and `***` for p < 0.001. Dynamic figures are generated only for predictors that appear here with at least one significance symbol.
### Victim subset
| Hypothesis | Tobit support |
| --- | --- |
| H1 | PT***; EC***; PD** |
| H2 | JN Ctl, CN In+ |
| H3 | Emp x JN Out*; Emp x JN Ctl*; EC x JN Out+ |
_Note._ Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.

### Bystander subset
| Hypothesis | Tobit support |
| --- | --- |
| H1 | EC*; PT*; PD* |
| H2 | JN Out, CN In+ |
| H3 | Emp x JN Ctl*; PD x JN Out* |
_Note._ Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.


## Significance-Driven Figures
Only hypothesis-relevant predictors that reach at least `p < .10` are visualized automatically. These figures rely on the saved Tobit fits, and `id` remains only an inference-level clustering unit.

### H1: Empathy under relational controls

Empathy: Perspective taking is statistically significant in the Tobit model (***, p < 0.001). The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in H1: Empathy under relational controls. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H1_iri_pt_h1_empathy_perspective_taking.png)

Empathy: Empathic concern is statistically significant in the Tobit model (***, p < 0.001). The figure below shows that across the observed range, higher Empathy: Empathic concern corresponds to lower predicted judgment.

![Effect Plot for Empathy: Empathic concern in H1: Empathy under relational controls. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H1_iri_ec_h1_empathy_empathic_concern.png)

Empathy: Personal distress is statistically significant in the Tobit model (**, p = 0.004). The figure below shows that across the observed range, higher Empathy: Personal distress corresponds to higher predicted judgment.

![Effect Plot for Empathy: Personal distress in H1: Empathy under relational controls. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H1_iri_pd_h1_empathy_personal_distress.png)

### H2: Negotiator-side relational structure

Negotiator-side structure: judged negotiator outgroup, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) is statistically significant in the Tobit model (+, p = 0.065). The figure below shows that predicted judgment is lower for JN Out, CN In than for Ref: JN In, CN In.

![Grouped Prediction Plot for Negotiator-side structure: judged negotiator outgroup, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) in H2: Negotiator-side relational structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H2_h2_negstruct_j_out_c_in_h2_negotiator_side_structure_judged_negotiator_outgroup_counterpart_negotiator_ingroup_ref.png)

Negotiator-side structure: judged negotiator control label hidden, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) is statistically significant in the Tobit model (+, p = 0.087). The figure below shows that predicted judgment is lower for JN Ctl, CN In than for Ref: JN In, CN In.

![Grouped Prediction Plot for Negotiator-side structure: judged negotiator control label hidden, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) in H2: Negotiator-side relational structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H2_h2_negstruct_j_cont_c_in_h2_negotiator_side_structure_judged_negotiator_control_label_hidden_counterpart_negotiator.png)

### H3: Empathy x judged-status moderation

Empathy x judged negotiator control label hidden is statistically significant in the Tobit model (*, p = 0.015). The figure below shows that the predicted relationship rises most sharply for Empathy composite (average) when the condition is JN Ctl.

![Interaction Plot for Empathy x judged negotiator control label hidden in H3: Empathy x judged-status moderation. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H3_iri_total_judged_control_h3_empathy_x_judged_negotiator_control_label_hidden.png)

Personal distress x judged negotiator outgroup is statistically significant in the Tobit model (*, p = 0.021). The figure below shows that the predicted relationship rises most sharply for Empathy: Personal distress when the condition is JN Out.

![Interaction Plot for Personal distress x judged negotiator outgroup in H3: Empathy x judged-status moderation. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H3_iri_pd_judged_outgroup_h3_personal_distress_x_judged_negotiator_outgroup.png)

Empathy x judged negotiator outgroup is statistically significant in the Tobit model (*, p = 0.028). The figure below shows that the predicted relationship rises most sharply for Empathy composite (average) when the condition is JN In.

![Interaction Plot for Empathy x judged negotiator outgroup in H3: Empathy x judged-status moderation. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H3_iri_total_judged_outgroup_h3_empathy_x_judged_negotiator_outgroup.png)

Empathic concern x judged negotiator outgroup is statistically significant in the Tobit model (+, p = 0.053). The figure below shows that the predicted relationship falls most sharply for Empathy: Empathic concern when the condition is JN Out.

![Interaction Plot for Empathic concern x judged negotiator outgroup in H3: Empathy x judged-status moderation. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_H3_iri_ec_judged_outgroup_h3_empathic_concern_x_judged_negotiator_outgroup.png)


## All Significant Predictors (p < .10)
The following figures extend beyond the hypothesis-target terms and visualize every predictor that reaches `p < .10` in the available H1-H3 Tobit models. This includes significant controls such as age when they clear the threshold.

### judgments_bystander

Negotiator accepted harmful deal is statistically significant in:
- H1: Empathy under relational controls Model A (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
- H3: Empathy x judged-status moderation Model A (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that predicted judgment is lower for Acc than for Rej.

![Grouped Prediction Plot for Negotiator accepted harmful deal in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_decision_accept_judgments_bystander_negotiator_accepted_harmful_deal.png)

Age is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
- H2: Negotiator-side relational structure Model A (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that across the observed range, higher Age corresponds to higher predicted judgment.

![Effect Plot for Age in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_age_judgments_bystander_age.png)

Empathy: Empathic concern is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Empathic concern corresponds to lower predicted judgment.

![Effect Plot for Empathy: Empathic concern in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_ec_judgments_bystander_empathy_empathic_concern.png)

Judged negotiator control label hidden (ref = ingroup) is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that predicted judgment is lower for JN Ctl than for JN In.

![Grouped Prediction Plot for Judged negotiator control label hidden (ref = ingroup) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_judged_control_judgments_bystander_judged_negotiator_control_label_hidden_ref_ingroup.png)

Empathy: Personal distress is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Personal distress corresponds to higher predicted judgment.

![Effect Plot for Empathy: Personal distress in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_pd_judgments_bystander_empathy_personal_distress.png)

Empathy x judged negotiator control label hidden is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that the predicted relationship rises most sharply for Empathy composite (average) when the condition is JN Ctl.

![Interaction Plot for Empathy x judged negotiator control label hidden in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_total_judged_control_judgments_bystander_empathy_x_judged_negotiator_control_label_hidden.png)

Engineering participant (ref = humanities) is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
- H1: Empathy under relational controls Model A (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
- H2: Negotiator-side relational structure Model A (Tobit)
- H2: Negotiator-side relational structure Model B (Tobit)
The figure below shows that predicted judgment is higher for Eng part. than for Hum part..

![Grouped Prediction Plot for Engineering participant (ref = humanities) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_participant_engineering_judgments_bystander_engineering_participant_ref_humanities.png)

Personal distress x judged negotiator outgroup is statistically significant in:
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that the predicted relationship rises most sharply for Empathy: Personal distress when the condition is JN Out.

![Interaction Plot for Personal distress x judged negotiator outgroup in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_pd_judged_outgroup_judgments_bystander_personal_distress_x_judged_negotiator_outgroup.png)

Empathy: Perspective taking is statistically significant in:
- H1: Empathy under relational controls Model B (Tobit)
- H2: Negotiator-side relational structure Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_pt_judgments_bystander_empathy_perspective_taking.png)

Negotiator-side structure: judged negotiator outgroup, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) is statistically significant in:
- H2: Negotiator-side relational structure Model A (Tobit)
- H2: Negotiator-side relational structure Model B (Tobit)
The figure below shows that predicted judgment is lower for JN Out, CN In than for Ref: JN In, CN In.

![Grouped Prediction Plot for Negotiator-side structure: judged negotiator outgroup, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_bystander_h2_negstruct_j_out_c_in_judgments_bystander_negotiator_side_structure_judged_negotiator_outgroup_counterpart_negot.png)

### judgments_victim

Negotiator accepted harmful deal is statistically significant in:
- H1: Empathy under relational controls Model B (Tobit)
- H1: Empathy under relational controls Model A (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that predicted judgment is lower for Acc than for Rej.

![Grouped Prediction Plot for Negotiator accepted harmful deal in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_decision_accept_judgments_victim_negotiator_accepted_harmful_deal.png)

Empathy: Perspective taking is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pt_judgments_victim_empathy_perspective_taking.png)

Empathy: Empathic concern is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Empathic concern corresponds to lower predicted judgment.

![Effect Plot for Empathy: Empathic concern in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_ec_judgments_victim_empathy_empathic_concern.png)

Empathy: Personal distress is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that across the observed range, higher Empathy: Personal distress corresponds to higher predicted judgment.

![Effect Plot for Empathy: Personal distress in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pd_judgments_victim_empathy_personal_distress.png)

Engineering participant (ref = humanities) is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
- H1: Empathy under relational controls Model A (Tobit)
- H3: Empathy x judged-status moderation Model B (Tobit)
- H1: Empathy under relational controls Model B (Tobit)
- H2: Negotiator-side relational structure Model A (Tobit)
- H2: Negotiator-side relational structure Model B (Tobit)
The figure below shows that predicted judgment is higher for Eng part. than for Hum part..

![Grouped Prediction Plot for Engineering participant (ref = humanities) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_participant_engineering_judgments_victim_engineering_participant_ref_humanities.png)

Judged negotiator outgroup (ref = ingroup) is statistically significant in:
- H3: Empathy x judged-status moderation Model B (Tobit)
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that predicted judgment is lower for JN Out than for JN In.

![Grouped Prediction Plot for Judged negotiator outgroup (ref = ingroup) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_judged_outgroup_judgments_victim_judged_negotiator_outgroup_ref_ingroup.png)

Empathy composite (average) is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that across the observed range, higher Empathy composite (average) corresponds to higher predicted judgment.

![Effect Plot for Empathy composite (average) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_total_judgments_victim_empathy_composite_average.png)

Empathy x judged negotiator outgroup is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that the predicted relationship rises most sharply for Empathy composite (average) when the condition is JN In.

![Interaction Plot for Empathy x judged negotiator outgroup in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_total_judged_outgroup_judgments_victim_empathy_x_judged_negotiator_outgroup.png)

Empathy x judged negotiator control label hidden is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that the predicted relationship rises most sharply for Empathy composite (average) when the condition is JN In.

![Interaction Plot for Empathy x judged negotiator control label hidden in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_total_judged_control_judgments_victim_empathy_x_judged_negotiator_control_label_hidden.png)

Empathic concern x judged negotiator outgroup is statistically significant in:
- H3: Empathy x judged-status moderation Model B (Tobit)
The figure below shows that the predicted relationship falls most sharply for Empathy: Empathic concern when the condition is JN Out.

![Interaction Plot for Empathic concern x judged negotiator outgroup in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_ec_judged_outgroup_judgments_victim_empathic_concern_x_judged_negotiator_outgroup.png)

Judged negotiator control label hidden (ref = ingroup) is statistically significant in:
- H3: Empathy x judged-status moderation Model A (Tobit)
The figure below shows that predicted judgment is lower for JN Ctl than for JN In.

![Grouped Prediction Plot for Judged negotiator control label hidden (ref = ingroup) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_judged_control_judgments_victim_judged_negotiator_control_label_hidden_ref_ingroup.png)

Socioeconomic status is statistically significant in:
- H2: Negotiator-side relational structure Model A (Tobit)
- H2: Negotiator-side relational structure Model B (Tobit)
The figure below shows that predicted judgment is higher for Socioeconomic status 5 than for Socioeconomic status 0.

![Grouped Prediction Plot for Socioeconomic status in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_economic_status_judgments_victim_socioeconomic_status.png)

Negotiator-side structure: judged negotiator control label hidden, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) is statistically significant in:
- H2: Negotiator-side relational structure Model B (Tobit)
The figure below shows that predicted judgment is lower for JN Ctl, CN In than for Ref: JN In, CN In.

![Grouped Prediction Plot for Negotiator-side structure: judged negotiator control label hidden, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: Emp = empathy composite; FS / EC / PT / PD = IRI subscales; JN = judged negotiator; CN = counterpart negotiator; V = victim-side player-victim relation in observer models; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; Acc / Rej = accepted / rejected harmful deal; SES = economic status.](../figures/figure_sig_all_judgments_victim_h2_negstruct_j_cont_c_in_judgments_victim_negotiator_side_structure_judged_negotiator_control_label_hidden_counterp.png)


## Hypothesis Conclusion Summary
Each conclusion below is generated from the current Tobit coefficient outputs.
- H1. Original hypothesis: Within the victim and bystander subsets, higher empathy predicts lower moral-judgment scores for harmful decisions after conditioning on judged-negotiator status, counterpart status, decision outcome, observer-side victim alignment when applicable, and participant controls. Victim subset: Tobit conclusion: the evidence is mixed but offers partial support for the hypothesis. Model A does not support the hypothesis; Empathy composite (average) is positive but not statistically significant (p = 0.513). Model B supports the hypothesis through Empathy: Empathic concern with a negative association (p < 0.001). Additional statistically significant signals include Negotiator accepted harmful deal with a negative association (p < 0.001) and Engineering participant (ref = humanities) with a positive association (p = 0.005). Bystander subset: Tobit conclusion: the evidence is mixed but offers partial support for the hypothesis. Model A does not support the hypothesis; Empathy composite (average) is negative but not statistically significant (p = 0.952). Model B supports the hypothesis through Empathy: Empathic concern with a negative association (p = 0.045). Additional statistically significant signals include Negotiator accepted harmful deal with a negative association (p < 0.001) and Engineering participant (ref = humanities) with a positive association (p = 0.015).
- H2. Original hypothesis: Moral-judgment severity should vary with the judgment-level ingroup/outgroup/control structure of the judged and counterpart negotiators. In the bystander subset, that negotiator-side structure should further depend on whether the player and the victim share faculty or not. Victim subset: Tobit conclusion: the available models do not support the hypothesis. Model A does not support the hypothesis; none of the negotiator-side ingroup/outgroup/control structure dummies in the victim subset are statistically significant, and the closest signal is Negotiator-side structure: judged negotiator control label hidden, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) with a negative association (p = 0.121). Model B does not support the hypothesis; none of the negotiator-side ingroup/outgroup/control structure dummies in the victim subset are statistically significant, and the closest signal is Negotiator-side structure: judged negotiator control label hidden, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) with a negative association (p = 0.087). Additional statistically significant signals include Empathy: Perspective taking with a positive association (p < 0.001) and Empathy: Empathic concern with a negative association (p < 0.001). Bystander subset: Tobit conclusion: the available models do not support the hypothesis. Model A does not support the hypothesis; none of the negotiator-side structure, player-victim outgroup term, and their interaction in the bystander subset are statistically significant, and the closest signal is Negotiator-side structure: judged negotiator outgroup, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) with a negative association (p = 0.065). Model B does not support the hypothesis; none of the negotiator-side structure, player-victim outgroup term, and their interaction in the bystander subset are statistically significant, and the closest signal is Negotiator-side structure: judged negotiator outgroup, counterpart negotiator ingroup (ref = judged negotiator ingroup, counterpart negotiator ingroup) with a negative association (p = 0.087). Additional statistically significant signals include Age with a positive association (p = 0.001) and Empathy: Empathic concern with a negative association (p = 0.001).
- H3. Original hypothesis: The empathy effect may vary according to whether the judged negotiator is ingroup, outgroup, or control, while decision outcome and the additional relational controls remain explicitly modeled. Victim subset: Tobit conclusion: the evidence is mixed but offers partial support for the hypothesis. Model A supports the hypothesis through Empathy x judged negotiator outgroup with a negative association (p = 0.028) and Empathy x judged negotiator control label hidden with a negative association (p = 0.043). Model B does not support the hypothesis; none of the empathy-dimension x judged-negotiator relational-status interactions are statistically significant, and the closest signal is Empathic concern x judged negotiator outgroup with a negative association (p = 0.053). Additional statistically significant signals include Negotiator accepted harmful deal with a negative association (p < 0.001) and Empathy: Perspective taking with a positive association (p < 0.001). Bystander subset: Tobit conclusion: the available models support the hypothesis. Model A supports the hypothesis through Empathy x judged negotiator control label hidden with a positive association (p = 0.015). Model B supports the hypothesis through Personal distress x judged negotiator outgroup with a positive association (p = 0.021). Additional statistically significant signals include Negotiator accepted harmful deal with a negative association (p < 0.001) and Judged negotiator control label hidden (ref = ingroup) with a negative association (p = 0.010).

## PDF Comprehensive Report Generated
Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented Tobit and cluster-aware non-parametric mathematical formulations, the Option 2 relational-variable logic, dual-estimator hypothesis testing, and the algorithmically interpreted natural language coefficients. When the run is dataset-specific, a matching alias such as `tobit_analysis_report_Buca.pdf` is also refreshed.

