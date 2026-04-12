# Scientific Analysis of Moral Judgments with Tobit Random-Intercept Models and Four Empathy Constructs

## Dataset Description
The empirical foundation of this project rests on two primary experimental datasets: FLORIDA and BUC.  The sample consists of students from both the Floridablanca and Bucaramanga Campuses.  These datasets capture incentivized moral judgments from distinct socio-economic contexts. Participants were presented  with standardized negotiation scenarios where a negotiator's decision resulted in varying degrees of payoff for  themselves, their own group, and a victim group. Under  Option 2: judgment-level relational modeling , each judgment is treated as relational and linked both to a descriptive victim x negotiator scenario shorthand and to hypothesis-specific predictors for N1 (judged negotiator) and N2 (counterpart), observer-side victim alignment when applicable, and additional relational controls.

## Primary Estimator in This Run
The primary inferential branch is the Tobit slot with random intercepts: each model includes `(1 | id)`, and when `id_case` is identifiable it also includes `(1 | id_case)`.

## Option 2 Relational Case Configuration
All hypothesis sections are now interpreted through negotiator-level relational predictors rather than descriptive case labels.

## Predictor Glossary and Abbreviations
The regression tables and dynamic figures use compact predictor labels to keep long H2 and H3 rows readable. The bullet list below maps those compact labels back to the full meanings used in the manuscript.
- `iri_fs, iri_ec, iri_pt, iri_pd` [FS, EC, PT, PD]: Active empathy predictors: fantasy, empathic concern, perspective taking, and personal distress. Used in H1/H2/H3 active model.
- `victim_N1_groupIn, victim_N1_groupOut` [V-N1 In, V-N1 Out]: Victim-to-N1 contrasts relative to the control-labeled baseline. Used in H1/H2/H3 Victim and Bystander.
- `victim_N2_groupIn, victim_N2_groupOut` [V-N2 In, V-N2 Out]: Victim-to-N2 contrasts relative to the control-labeled baseline. Used in H1/H2/H3 Victim and Bystander.
- `bystander_N1_groupIn, bystander_N1_groupOut` [B-N1 In, B-N1 Out]: Bystander-to-N1 contrasts relative to the control-labeled baseline. Used in H1/H2/H3 Bystander.
- `bystander_N2_groupIn, bystander_N2_groupOut` [B-N2 In, B-N2 Out]: Bystander-to-N2 contrasts relative to the control-labeled baseline. Used in H1/H2/H3 Bystander.
- `bystander_victim_groupOut` [B-V Out]: Bystander-victim outgroup contrast with bystander-victim ingroup as the reference. Used in H1/H2/H3 Bystander.
- `N1_N2_same_faculty` [SameFac]: Context indicator for whether N1 and N2 belong to the same faculty. Used in H1/H2/H3 Victim and Bystander.
- `victim_N1_group*:victim_N2_group*` [V-N1 x V-N2]: Victim-side N1-by-N2 interaction block. Used in H2/H3 Victim and Bystander.
- `bystander_N1_group*:bystander_N2_group*` [B-N1 x B-N2]: Bystander-side N1-by-N2 interaction block. Used in H2/H3 Bystander.
- `bystander_victim_group*:bystander_N1_group*` [B-V x B-N1]: Bystander-victim by bystander-N1 interaction block. Used in H2/H3 Bystander.
- `bystander_victim_group*:bystander_N2_group*` [B-V x B-N2]: Bystander-victim by bystander-N2 interaction block. Used in H2/H3 Bystander.
- `iri_*:victim_N*_group*` [FS / EC / PT / PD x V-N...]: Empathy-by-victim-side relational interaction block. Used in H3 Victim.
- `iri_*:bystander_N*_group*` [FS / EC / PT / PD x B-N...]: Empathy-by-bystander-side relational interaction block. Used in H3 Bystander.
- `iri_*:bystander_victim_group*` [FS / EC / PT / PD x B-V]: Empathy-by-bystander-victim interaction block. Used in H3 Bystander.
- `participant_engineering` [Eng part.]: Participant faculty contrast. Used in H1/H2/H3.
- `sex_man` [Man]: Sex contrast with woman as the reference. Used in H1/H2/H3.
- `age` [Age]: Participant age in original units. Used in H1/H2/H3.
- `economic_status` [SES]: Economic status in original units. Used in H1/H2/H3.

## Interpretation of Interaction Terms
The models herein employ several predefined predictors. It is important to note how interaction terms are interpreted in the context of this behavioral experiment:

1. Interaction subsumption: when an interaction term is statistically significant, the effect of one variable depends on the other.
2. Continuous-by-discrete interactions: for terms like `iri_pt:victim_N1_groupOut`, a negative coefficient means the empathy slope is more negative under that outgroup condition than under the control-labeled baseline.
3. Discrete-by-discrete interactions: for terms like `bystander_N1_groupOut:bystander_N2_groupOut`, a positive coefficient means the joint relational condition is associated with less severe condemnation than expected from the baseline profile.

## Hypothesis Significance Summary
Only hypothesis-relevant predictors with p < 0.10 in the available Tobit random-intercept models are shown below, split into victim and bystander subset tables. Significance symbols follow plus, one-star, two-star, and three-star thresholds. Dynamic figures are generated only for predictors that appear here with at least one significance symbol.
### Victim subset
| Hypothesis | Tobit (random intercepts) support |
| --- | --- |
| H1 | PT* |
| H2 | None |
| H3 | PT x V-N1 Out*; EC x V-N1 Out* |
_Note._ Abbrev.: EC = empathic concern; PT = perspective taking; N1 = judged negotiator; V-N1 = victim-negotiator 1 relation.

### Bystander subset
| Hypothesis | Tobit (random intercepts) support |
| --- | --- |
| H1 | None |
| H2 | B-V Out*; V-N2 In+; B-N2 Out+; B-N2 In+; B-N1 In x B-N2 In+ |
| H3 | B-N1 Out x FS*; B-V Out x PD+; B-N2 Out x PT+ |
_Note._ Abbrev.: FS = fantasy; PT = perspective taking; PD = personal distress; N1 = judged negotiator; N2 = counterpart negotiator; B-V = bystander-victim relation; V-N2 = victim-negotiator 2 relation; B-N1 = bystander-negotiator 1 relation; B-N2 = bystander-negotiator 2 relation.


## Significance-Driven Figures
Only hypothesis-relevant predictors that reach at least `p < .10` are visualized automatically. These figures rely on the saved Tobit random-intercepts fits, and `id` remains only an inference-level clustering unit.

### Empathy Effect

Empathy: Perspective taking is statistically significant in the Tobit random-intercepts model (*, p = 0.017). The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in Empathy Effect. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H1_iri_pt_h1_empathy_perspective_taking.png)

### Negotiator-Side Structure

Bystander-victim: Outgroup (ref = Ingroup) is statistically significant in the Tobit random-intercepts model (*, p = 0.035). The figure below shows that predicted judgment is lower for B-V Out than for B-V In.

![Grouped Prediction Plot for Bystander-victim: Outgroup (ref = Ingroup) in Negotiator-Side Structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H2_bystander_victim_groupout_h2_bystander_victim_outgroup_ref_ingroup.png)

Victim-N2: Ingroup (ref = Control) is statistically significant in the Tobit random-intercepts model (+, p = 0.071). The figure below shows that predicted judgment is higher for V-N2 In than for V-N2 Ctl.

![Grouped Prediction Plot for Victim-N2: Ingroup (ref = Control) in Negotiator-Side Structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H2_victim_n2_groupin_h2_victim_n2_ingroup_ref_control.png)

Bystander-N2: Outgroup (ref = Control) is statistically significant in the Tobit random-intercepts model (+, p = 0.073). The figure below shows that predicted judgment is lower for B-N2 Out than for B-N2 Ctl.

![Grouped Prediction Plot for Bystander-N2: Outgroup (ref = Control) in Negotiator-Side Structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H2_bystander_n2_groupout_h2_bystander_n2_outgroup_ref_control.png)

Bystander-N2: Ingroup (ref = Control) is statistically significant in the Tobit random-intercepts model (+, p = 0.083). The figure below shows that predicted judgment is lower for B-N2 In than for B-N2 Ctl.

![Grouped Prediction Plot for Bystander-N2: Ingroup (ref = Control) in Negotiator-Side Structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H2_bystander_n2_groupin_h2_bystander_n2_ingroup_ref_control.png)

Bystander-N1: Ingroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) is statistically significant in the Tobit random-intercepts model (+, p = 0.098). The figure below shows that the predicted relationship rises most sharply for bystander_N1_group when the condition is B-N2 Ctl.

![Interaction Plot for Bystander-N1: Ingroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) in Negotiator-Side Structure. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H2_bystander_n1_groupin_bystander_n2_groupin_h2_bystander_n1_ingroup_ref_control_x_bystander_n2_ingroup_ref_control.png)

### Empathy x Relational Status

Empathy: Perspective taking x Victim-N1: Outgroup (ref = Control) is statistically significant in the Tobit random-intercepts model (*, p = 0.014). The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is V-N1 Out.

![Interaction Plot for Empathy: Perspective taking x Victim-N1: Outgroup (ref = Control) in Empathy x Relational Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H3_iri_pt_victim_n1_groupout_h3_empathy_perspective_taking_x_victim_n1_outgroup_ref_control.png)

Empathy: Empathic concern x Victim-N1: Outgroup (ref = Control) is statistically significant in the Tobit random-intercepts model (*, p = 0.036). The figure below shows that the predicted relationship falls most sharply for Empathy: Empathic concern when the condition is V-N1 Out.

![Interaction Plot for Empathy: Empathic concern x Victim-N1: Outgroup (ref = Control) in Empathy x Relational Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H3_iri_ec_victim_n1_groupout_h3_empathy_empathic_concern_x_victim_n1_outgroup_ref_control.png)

Bystander-N1: Outgroup (ref = Control) x Empathy: Fantasy scale is statistically significant in the Tobit random-intercepts model (*, p = 0.039). The figure below shows that the predicted relationship falls most sharply for Empathy: Fantasy scale when the condition is B-N1 Out.

![Interaction Plot for Bystander-N1: Outgroup (ref = Control) x Empathy: Fantasy scale in Empathy x Relational Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H3_bystander_n1_groupout_iri_fs_h3_bystander_n1_outgroup_ref_control_x_empathy_fantasy_scale.png)

Bystander-victim: Outgroup (ref = Ingroup) x Empathy: Personal distress is statistically significant in the Tobit random-intercepts model (+, p = 0.064). The figure below shows that the predicted relationship rises most sharply for Empathy: Personal distress when the condition is B-V Out.

![Interaction Plot for Bystander-victim: Outgroup (ref = Ingroup) x Empathy: Personal distress in Empathy x Relational Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H3_bystander_victim_groupout_iri_pd_h3_bystander_victim_outgroup_ref_ingroup_x_empathy_personal_distress.png)

Bystander-N2: Outgroup (ref = Control) x Empathy: Perspective taking is statistically significant in the Tobit random-intercepts model (+, p = 0.084). The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is B-N2 Ctl.

![Interaction Plot for Bystander-N2: Outgroup (ref = Control) x Empathy: Perspective taking in Empathy x Relational Status. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_H3_bystander_n2_groupout_iri_pt_h3_bystander_n2_outgroup_ref_control_x_empathy_perspective_taking.png)


## All Significant Predictors (p < .10)
The following figures extend beyond the hypothesis-target terms and visualize every predictor that reaches `p < .10` in the available H1-H3 Tobit random-intercepts models. This includes significant controls such as age when they clear the threshold.

### judgments_bystander

Age is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
- Negotiator-Side Structure Model B (Tobit random-intercepts)
- Empathy Effect Model B (Tobit random-intercepts)
The figure below shows that across the observed range, higher Age corresponds to higher predicted judgment.

![Effect Plot for Age in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_age_judgments_bystander_age.png)

Bystander-victim: Outgroup (ref = Ingroup) is statistically significant in:
- Negotiator-Side Structure Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is lower for B-V Out than for B-V In.

![Grouped Prediction Plot for Bystander-victim: Outgroup (ref = Ingroup) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_victim_groupout_judgments_bystander_bystander_victim_outgroup_ref_ingroup.png)

Bystander-N1: Outgroup (ref = Control) x Empathy: Fantasy scale is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship falls most sharply for Empathy: Fantasy scale when the condition is B-N1 Out.

![Interaction Plot for Bystander-N1: Outgroup (ref = Control) x Empathy: Fantasy scale in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n1_groupout_iri_fs_judgments_bystander_bystander_n1_outgroup_ref_control_x_empathy_fantasy_scale.png)

Empathy: Perspective taking is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_iri_pt_judgments_bystander_empathy_perspective_taking.png)

Bystander-N2: Ingroup (ref = Control) is statistically significant in:
- Empathy Effect Model B (Tobit random-intercepts)
- Negotiator-Side Structure Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is lower for B-N2 In than for B-N2 Ctl.

![Grouped Prediction Plot for Bystander-N2: Ingroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n2_groupin_judgments_bystander_bystander_n2_ingroup_ref_control.png)

Bystander-N1: Ingroup (ref = Control) is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
- Empathy Effect Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is higher for B-N1 In than for B-N1 Ctl.

![Grouped Prediction Plot for Bystander-N1: Ingroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n1_groupin_judgments_bystander_bystander_n1_ingroup_ref_control.png)

Victim-N2: Ingroup (ref = Control) is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
- Negotiator-Side Structure Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is higher for V-N2 In than for V-N2 Ctl.

![Grouped Prediction Plot for Victim-N2: Ingroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_victim_n2_groupin_judgments_bystander_victim_n2_ingroup_ref_control.png)

Bystander-victim: Outgroup (ref = Ingroup) x Empathy: Personal distress is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship rises most sharply for Empathy: Personal distress when the condition is B-V Out.

![Interaction Plot for Bystander-victim: Outgroup (ref = Ingroup) x Empathy: Personal distress in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_victim_groupout_iri_pd_judgments_bystander_bystander_victim_outgroup_ref_ingroup_x_empathy_personal_distress.png)

Bystander-N2: Outgroup (ref = Control) is statistically significant in:
- Negotiator-Side Structure Model B (Tobit random-intercepts)
- Empathy Effect Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is lower for B-N2 Out than for B-N2 Ctl.

![Grouped Prediction Plot for Bystander-N2: Outgroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n2_groupout_judgments_bystander_bystander_n2_outgroup_ref_control.png)

Bystander-N2: Outgroup (ref = Control) x Empathy: Perspective taking is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is B-N2 Ctl.

![Interaction Plot for Bystander-N2: Outgroup (ref = Control) x Empathy: Perspective taking in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n2_groupout_iri_pt_judgments_bystander_bystander_n2_outgroup_ref_control_x_empathy_perspective_taking.png)

Bystander-N1: Outgroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship rises most sharply for bystander_N1_group when the condition is B-N2 In.

![Interaction Plot for Bystander-N1: Outgroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n1_groupout_bystander_n2_groupin_judgments_bystander_bystander_n1_outgroup_ref_control_x_bystander_n2_ingroup_ref_control.png)

Bystander-N1: Outgroup (ref = Control) is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is higher for B-N1 Out than for B-N1 Ctl.

![Grouped Prediction Plot for Bystander-N1: Outgroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n1_groupout_judgments_bystander_bystander_n1_outgroup_ref_control.png)

Bystander-N1: Ingroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) is statistically significant in:
- Negotiator-Side Structure Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship rises most sharply for bystander_N1_group when the condition is B-N2 Ctl.

![Interaction Plot for Bystander-N1: Ingroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) in the judgments_bystander. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_bystander_bystander_n1_groupin_bystander_n2_groupin_judgments_bystander_bystander_n1_ingroup_ref_control_x_bystander_n2_ingroup_ref_control.png)

### judgments_victim

Empathy: Perspective taking x Victim-N1: Outgroup (ref = Control) is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship rises most sharply for Empathy: Perspective taking when the condition is V-N1 Out.

![Interaction Plot for Empathy: Perspective taking x Victim-N1: Outgroup (ref = Control) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pt_victim_n1_groupout_judgments_victim_empathy_perspective_taking_x_victim_n1_outgroup_ref_control.png)

Empathy: Perspective taking is statistically significant in:
- Empathy Effect Model B (Tobit random-intercepts)
- Negotiator-Side Structure Model B (Tobit random-intercepts)
The figure below shows that across the observed range, higher Empathy: Perspective taking corresponds to higher predicted judgment.

![Effect Plot for Empathy: Perspective taking in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_pt_judgments_victim_empathy_perspective_taking.png)

Empathy: Empathic concern x Victim-N1: Outgroup (ref = Control) is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
The figure below shows that the predicted relationship falls most sharply for Empathy: Empathic concern when the condition is V-N1 Out.

![Interaction Plot for Empathy: Empathic concern x Victim-N1: Outgroup (ref = Control) in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_victim_iri_ec_victim_n1_groupout_judgments_victim_empathy_empathic_concern_x_victim_n1_outgroup_ref_control.png)

Engineering participant is statistically significant in:
- Empathy x Relational Status Model B (Tobit random-intercepts)
- Empathy Effect Model B (Tobit random-intercepts)
- Negotiator-Side Structure Model B (Tobit random-intercepts)
The figure below shows that predicted judgment is higher for Eng part. than for Hum part..

![Grouped Prediction Plot for Engineering participant in the judgments_victim. The panels show predicted judgments on the observed -9 to 9 scale with 95% confidence intervals. Abbrev.: FS / EC / PT / PD = IRI subscales; N1 / N2 = negotiator 1 / negotiator 2; B-V = bystander-victim relation; V-N1 / V-N2 = victim-negotiator relations; B-N1 / B-N2 = bystander-negotiator relations; Vic / Obs = victim / observer subset; In / Out / Ctl = ingroup / outgroup / control label hidden; SameFac = N1 and N2 same faculty; SES = economic status.](../figures/figure_sig_all_judgments_victim_participant_engineering_judgments_victim_engineering_participant.png)


## Hypothesis Conclusion Summary
Each conclusion below is generated from the current Tobit random-intercept coefficient outputs.
- H1. Original hypothesis: Empathy dimensions are associated with moral judgment severity after conditioning on role-specific N1/N2 relational predictors and the N1-N2 same-faculty context term. Victim subset: Tobit (random intercepts) conclusion: the available models point in the opposite direction of the hypothesis. Model B points in the opposite direction through Empathy: Perspective taking with a positive association (p = 0.017). Additional statistically significant signals include Empathy: Perspective taking with a positive association (p = 0.017) and Engineering participant with a positive association (p = 0.073). Bystander subset: Tobit (random intercepts) conclusion: the available models do not support the hypothesis. Model B does not support the hypothesis; none of four empathy dimensions are statistically significant, and the closest signal is Empathy: Empathic concern with a negative association (p = 0.144). Additional statistically significant signals include Age with a positive association (p = 0.002) and Bystander-N2: Ingroup (ref = Control) with a negative association (p = 0.054).
- H2. Original hypothesis: Moral judgments vary with explicit N1/N2 relational structure and with the participant role. Bystander models retain participant-victim alignment and selective pairwise interactions. Victim subset: Tobit (random intercepts) conclusion: the available models do not support the hypothesis. Model B does not support the hypothesis; none of victim-side N1/N2 relational structure and interaction are statistically significant, and the closest signal is Victim-N1: Ingroup (ref = Control) x Victim-N2: Outgroup (ref = Control) with a positive association (p = 0.169). Additional statistically significant signals include Empathy: Perspective taking with a positive association (p = 0.019) and Engineering participant with a positive association (p = 0.073). Bystander subset: Tobit (random intercepts) conclusion: the available models support the hypothesis. Model B supports the hypothesis through Bystander-victim: Outgroup (ref = Ingroup) with a negative association (p = 0.035), Victim-N2: Ingroup (ref = Control) with a positive association (p = 0.071), Bystander-N2: Outgroup (ref = Control) with a negative association (p = 0.073), Bystander-N2: Ingroup (ref = Control) with a negative association (p = 0.083), and Bystander-N1: Ingroup (ref = Control) x Bystander-N2: Ingroup (ref = Control) with a negative association (p = 0.098). Additional statistically significant signals include Age with a positive association (p = 0.002) and Bystander-victim: Outgroup (ref = Ingroup) with a negative association (p = 0.035).
- H3. Original hypothesis: The empathy effect depends on N1/N2 relational status indicators within each role-specific model while retaining relational controls and participant-level random intercepts. Victim subset: Tobit (random intercepts) conclusion: the available models support the hypothesis. Model B supports the hypothesis through Empathy: Perspective taking x Victim-N1: Outgroup (ref = Control) with a positive association (p = 0.014) and Empathy: Empathic concern x Victim-N1: Outgroup (ref = Control) with a negative association (p = 0.036). Additional statistically significant signals include Empathy: Perspective taking x Victim-N1: Outgroup (ref = Control) with a positive association (p = 0.014) and Empathy: Empathic concern x Victim-N1: Outgroup (ref = Control) with a negative association (p = 0.036). Bystander subset: Tobit (random intercepts) conclusion: the available models support the hypothesis. Model B supports the hypothesis through Bystander-N1: Outgroup (ref = Control) x Empathy: Fantasy scale with a negative association (p = 0.039), Bystander-victim: Outgroup (ref = Ingroup) x Empathy: Personal distress with a positive association (p = 0.064), and Bystander-N2: Outgroup (ref = Control) x Empathy: Perspective taking with a negative association (p = 0.084). Additional statistically significant signals include Age with a positive association (p = 0.002) and Bystander-N1: Outgroup (ref = Control) x Empathy: Fantasy scale with a negative association (p = 0.039).

## PDF Comprehensive Report Generated
Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented Tobit random-intercept and cluster-aware non-parametric mathematical formulations, the Option 2 relational-variable logic, dual-estimator hypothesis testing, and the algorithmically interpreted natural language coefficients. When the run is dataset-specific, a matching alias such as `tobit_analysis_report_Buca.pdf` is also refreshed.

