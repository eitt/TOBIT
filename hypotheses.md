**Research Question**

> How do empathy and social identity, operationalized through faculty affiliation, shape moral judgments of negotiators' decisions in an incentivized economic experiment?

The final dataset is organized at two analytical levels. The raw file stores one row per participant, but each participant evaluates ten scenarios and provides two numerical judgments per scenario, one for each negotiator. For hypothesis testing, the relevant unit of analysis is therefore the **negotiator-level judgment** after reshaping the data to long format.

The numerical moral-judgment outcome is observed on its original bounded scale:

- `-9` = acted very badly
- `0` = neutral midpoint
- `9` = acted very well

Lower values therefore indicate **harsher moral condemnation**, while higher values indicate more favorable evaluations. Because the outcome is bounded at `-9` and `9`, the main model is specified as a Tobit regression on the raw judgment scale rather than on a transformed severity index.

**Statistical Model**

Let \( y_{ij}^{*} \) denote the latent moral-judgment propensity for negotiator-level evaluation \( j \) by participant \( i \). The observed outcome \( y_{ij} \) is censored at the scale limits:

\[
y_{ij} =
\begin{cases}
-9, & \text{if } y_{ij}^{*} \leq -9 \\
y_{ij}^{*}, & \text{if } -9 < y_{ij}^{*} < 9 \\
9, & \text{if } y_{ij}^{*} \geq 9
\end{cases}
\]

The main harmful-decision Tobit specification is:

\[
y_{ij}^{*} =
\beta_0
+ \beta_1 \,\text{IRI}_{i}
+ \beta_2 \,\text{OutgroupPerp}_{ij}
+ \beta_3 \,\text{ControlPerp}_{ij}
+ \beta_4 \,\text{VictimOutgroup}_{ij}
+ \beta_5 \,(\text{IRI}_{i} \times \text{OutgroupPerp}_{ij})
+ \beta_6 \,(\text{IRI}_{i} \times \text{ControlPerp}_{ij})
+ \boldsymbol{\gamma}' \mathbf{X}_{ij}
+ \varepsilon_{ij}
\]

where:

- \( \text{IRI}_{i} \) is the standardized empathy composite (`iri_total_z`);
- \( \text{OutgroupPerp}_{ij} \) is `perp_outgroup`;
- \( \text{ControlPerp}_{ij} \) is `perp_control`;
- \( \text{VictimOutgroup}_{ij} \) is `victim_outgroup`;
- \( \mathbf{X}_{ij} \) includes observer role, participant faculty, sex, age, socioeconomic status, stage fixed effects, and negotiator-slot fixed effects;
- \( \varepsilon_{ij} \sim \mathcal{N}(0,\sigma^2) \).

For the ingroup-betrayal test, the restricted harmful-decision model replaces the control-label term with a same-group-harm indicator:

\[
y_{ij}^{*} =
\alpha_0
+ \alpha_1 \,\text{IRI}_{i}
+ \alpha_2 \,\text{SameGroupHarm}_{ij}
+ \alpha_3 \,\text{OutgroupPerp}_{ij}
+ \alpha_4 \,\text{VictimOutgroup}_{ij}
+ \boldsymbol{\delta}' \mathbf{X}_{ij}
+ u_{ij}
\]

where \( \text{SameGroupHarm}_{ij} \) corresponds to `same_group_harm`.

**Substantive Hypotheses**

The study tests three substantive expectations.

**H1 (Empathy effect):** Higher empathy, measured through the composite Interpersonal Reactivity Index (IRI) score, predicts **lower** moral-judgment scores for harmful decisions, meaning harsher condemnation of negotiators who accept the victim-harming deal.

**H2 (Group identity effects):** Two competing identity-based mechanisms are evaluated.

- **H2a (Ingroup betrayal hypothesis):** Harmful decisions should receive **lower** moral-judgment scores when the negotiator harms a victim from the same labeled faculty (`same_group_harm = 1`) than when the harm is directed across faculty lines.
- **H2b (Outgroup derogation hypothesis):** Harmful decisions should receive **lower** moral-judgment scores when the perpetrator belongs to the evaluator's outgroup (`perp_outgroup = 1`) than when the perpetrator belongs to the evaluator's ingroup.

**H3 (Empathy x group moderation):** The negative association between empathy and moral-judgment scores should be stronger in outgroup cases than in ingroup cases. On the raw `-9` to `9` scale, this implies a **negative interaction** between empathy and outgroup perpetrator status.

**Hypotheses in LaTeX**

These are the directional statistical hypotheses implied by the Tobit specifications.

**H1 (Empathy effect)**

\[
H_{0}^{(1)}: \beta_1 \geq 0
\]

\[
H_{A}^{(1)}: \beta_1 < 0
\]

**H2a (Ingroup betrayal)**

\[
H_{0}^{(2a)}: \alpha_2 \geq 0
\]

\[
H_{A}^{(2a)}: \alpha_2 < 0
\]

**H2b (Outgroup derogation)**

\[
H_{0}^{(2b)}: \beta_2 \geq 0
\]

\[
H_{A}^{(2b)}: \beta_2 < 0
\]

**H3 (Empathy x outgroup moderation)**

\[
H_{0}^{(3)}: \beta_5 \geq 0
\]

\[
H_{A}^{(3)}: \beta_5 < 0
\]

If two-sided tests are preferred for reporting, the same hypotheses can be written as:

\[
H_{0}: \theta = 0
\qquad \text{versus} \qquad
H_{A}: \theta \neq 0
\]

where \( \theta \in \{\beta_1, \alpha_2, \beta_2, \beta_5\} \), and the theoretical expectation is given by the sign restrictions above.

**Method and Operationalization**

Participants are undergraduate students from the Universidad Industrial de Santander in Colombia. Each participant evaluates ten previously recorded bribery-game scenarios and rates each negotiator on the bounded `-9` to `9` moral-judgment scale. Five evaluations occur in the victim role and five in the observer role, with role order determined by the treatment sequence. The column treatment indicates the treatment condition for each participant. The value 1 2 and 3 indicate the treatment condition for each participant. 
- `1` = Victim first, observer second
- `2` = Observer first, victim second
- `0` = Drop these observations and record teh process during the EDA
Thus, create a varaible called role_s{i} where i indicate the stage,  generating 9 variables. As an example, if treatment = 1, and stage between 1 and 5, then the role is = 2, and between stage 6 and 10, then the role is = 1. Now if tratment = 2, and stage between 1 and 5, then the role is = 1, and between stage 6 and 10, then the role is = 2. (generate the needed variables)

The dataset includes:

- participant-level variables: age, sex, socioeconomic status, faculty affiliation, attention checks, and IRI items;
- scenario-level variables: negotiator faculty labels, victim faculty labels, negotiator decisions, comparative judgments, and numerical moral judgments.

For the Tobit analyses:

- the main hypothesis models focus on observations where the negotiator accepted the harmful deal (`decision_accept = 1`);
- repeated observations within participants are handled with participant-clustered inference;
- hidden faculty labels remain a control condition;
- the raw bounded judgment variable is censored at `-9` and `9`.
