# Hypotheses Overview

This document links each theoretical hypothesis to its executable pipeline scripts under **Option 2: explicit judgment-level case-configuration modeling**.

Option 2 means the analysis does not rely only on separate indicators such as `perp_outgroup` and `victim_outgroup` when the substantive question is relational. Instead, each judgment is represented through an explicit **judgment-level case configuration** that captures the position of the judged negotiator, the counterpart negotiator, the victim, and the participant’s role in the vignette.

## Judgment Unit and Definition of Moral-Judgment Severity

Let:

- `i` = participant identifier
- `s` = vignette / scenario identifier
- `j ∈ {1,2}` = judged negotiator
- `r ∈ {Victim, Bystander}` = participant role in the vignette

The dependent variable is the **severity of moral judgment** toward negotiator `j` in scenario `s`, observed as:

`judgement_{isjr}`

with values bounded between `-9` and `9`, where:

- lower values = **more severe moral condemnation**
- higher values = **greater appropriateness / lower severity**

For each participant-scenario pair, the dataset contains **two judgment observations**, one for each negotiator:

- `judgement_{is1r}` = judgment of negotiator 1
- `judgement_{is2r}` = judgment of negotiator 2

Thus, the same participant and the same vignette produce **two rows**, because each negotiator is evaluated separately. These are not two different scenarios; they are two judgments nested within the same participant-scenario context.

A latent representation is:

`judgement*_{isjr} = X'_{isjr}β + ε_{isjr}`

with observed bounded outcome:

- `judgement_{isjr} = -9` if `judgement*_{isjr} <= -9`
- `judgement_{isjr} = judgement*_{isjr}` if `-9 < judgement*_{isjr} < 9`
- `judgement_{isjr} = 9` if `judgement*_{isjr} >= 9`

This means that **severity is defined at the judgment-by-negotiator level**, not only at the scenario level.

## Role-Dependent Relational Coding

The meaning of ingroup and outgroup depends on the participant’s role in the vignette.

### 1. If the participant is the Victim

When the participant plays the **Victim** role, the participant is the harmed actor. Each judgment evaluates one negotiator’s decision from the victim’s position.

In this role, the relevant relational coding is:

- `group_negotiator1 ∈ {In, Out, Cont}`
- `group_negotiator2 ∈ {In, Out, Cont}`

Here, `In` and `Out` indicate whether each negotiator belongs to the same faculty as the victim-participant. `Cont` indicates a control or unlabeled condition for that negotiator.

Thus, when the participant is the victim, judgment severity depends on how each negotiator is positioned relative to the victim-participant.

### 2. If the participant is a Bystander / Observer

When the participant plays the **Bystander** role, the participant is neither negotiator nor victim. In this case, the vignette is interpreted relative to `faculty_player_obs`, and three relational variables are defined:

- `group_negotiator1 ∈ {In, Out, Cont}`
- `group_negotiator2 ∈ {In, Out, Cont}`
- `group_victim ∈ {In, Out}`

Importantly:

- `group_victim` can be `In` or `Out`, but **never `Cont`**
- the victim is always faculty-labeled relative to the observer
- only negotiators may appear in control / unlabeled (`Cont`) conditions

Therefore, when the participant is a bystander, moral judgment depends on how the participant relates to:

- negotiator 1,
- negotiator 2,
- and the victim,

within the same vignette.

## Judgment-Level Case Configuration

The main modeling unit is not the vignette alone, but the **judgment-level configuration** for the negotiator being evaluated.

For negotiator `j`, define:

`CaseConfig_{isjr}`

This configuration is role-dependent.

### Victim-role judgment configuration

When `r = Victim`, the judgment-level configuration is determined by the judged negotiator’s relation to the victim-participant, while preserving the counterpart negotiator’s role in the same vignette.

A compact representation is:

`CaseConfig_{isj,Victim} = (group_negotiator_j, group_negotiator_-j)`

where each element is in `{In, Out, Cont}`.

### Bystander-role judgment configuration

When `r = Bystander`, the judgment-level configuration is:

`CaseConfig_{isj,Bystander} = (group_negotiator_j, group_negotiator_-j, group_victim)`

where:

- `group_negotiator_j ∈ {In, Out, Cont}`
- `group_negotiator_-j ∈ {In, Out, Cont}`
- `group_victim ∈ {In, Out}`

This means that two judgments from the same vignette may differ because negotiator 1 and negotiator 2 can occupy different positions relative to the participant, while the victim also has a defined ingroup/outgroup position relative to the observer.

## Accepted Deals and Transgression

The concept of **transgression** is especially relevant in scenarios where the negotiators **accept** the harmful deal. In these accepted-decision cases, severity reflects condemnation of an enacted harmful choice rather than merely a hypothetical or rejected one.

Under this logic, transgression is not defined only by whether a negotiator is ingroup or outgroup in isolation. It depends on the full relational structure of the vignette, including:

- whether the judged negotiator is `In`, `Out`, or `Cont`
- whether the counterpart negotiator is `In`, `Out`, or `Cont`
- whether the victim is `In` or `Out` relative to the observer
- whether the participant is the **Victim** or a **Bystander**

In bystander-role transgression judgments, the observer may or may not share faculty with the victim. Accordingly, severity may vary depending on whether the observer and victim are aligned (`group_victim = In`) or not (`group_victim = Out`). This can be evaluated through interactions between the observer’s faculty position and the ingroup/outgroup structure of the vignette.

For H2 and H3, the executable models therefore retain both accepted and rejected judgments and explicitly include `decision_accept` plus its interaction with the judged negotiator's relational status instead of filtering those hypotheses down to accepted deals only.

## Predictor Revision for H2 and H3

The relational predictor in H2 and H3 is not defined only as a generic case configuration. The key executable predictor block now includes:

- the **ingroup / outgroup / control status of the judged negotiator**
- the **ingroup / outgroup / control status of the counterpart negotiator** as a relational control
- the **decision outcome** (`Accept` / `Reject`)
- the **interaction between judged-negotiator status and decision outcome**
- and, for **Bystander** rows, the victim's ingroup/outgroup position relative to the observer as an additional relational control

In notation:

`judgement*_{isjr} = β0 + β1 Empathy_i + β2 G_{isjr} + β3 A_{is} + β4 (G_{isjr} × A_{is}) + β5 C_{isjr} + ε_{isjr}`

where:

- `G_{isjr}` = ingroup / outgroup / control status of the judged negotiator
- `A_{is}` = decision indicator (`Accept` = 1, `Reject` = 0)
- `G_{isjr} × A_{is}` = interaction between judged-negotiator status and decision outcome
- `C_{isjr}` = additional relational controls, especially the counterpart negotiator and, for bystanders, victim alignment

## Clarification of the Judgment Unit When the Player Is the Victim

When the participant plays the **Victim** role, each vignette still produces **two moral-judgment observations**, because the participant evaluates **each negotiator separately**. Therefore, the same scenario contributes:

- one judgment for **negotiator 1**
- one judgment for **negotiator 2**

In this role, the key relational variables are:

- `group_negotiator1`
- `group_negotiator2`

Each of these can take values in:

- `In`
- `Out`
- `Cont`

Here:

- `In` means that the negotiator belongs to the same faculty as the victim-player,
- `Out` means that the negotiator belongs to a different faculty than the victim-player,
- `Cont` means that the negotiator is in the control / unlabeled condition.

Thus, when the participant is the victim, **judgment severity is defined at the negotiator-specific level**, not only at the vignette level. A single vignette may therefore contain:

- two ingroup negotiators,
- two outgroup negotiators,
- one ingroup and one outgroup negotiator,
- one labeled negotiator and one control negotiator,
- or two control negotiators.

To make this structure explicit, the table below lists the full set of 36 conditions for the **victim-role interpretation**.

## Full Condition Table for the Victim Role

| Condition | negotiator1 | negotiator2 | victim | faculty_player_obs | group_negotiator1 | group_negotiator2 |
|---|---|---|---|---|---|---|
| 1 | Hum | Hum | Hum | Hum | In | In |
| 2 | Hum | Hum | Hum | Ing | Out | Out |
| 3 | Hum | Hum | Ing | Ing | Out | Out |
| 4 | Hum | Hum | Ing | Hum | In | In |
| 5 | Ing | Ing | Hum | Hum | Out | Out |
| 6 | Ing | Ing | Hum | Ing | In | In |
| 7 | Ing | Ing | Ing | Ing | In | In |
| 8 | Ing | Ing | Ing | Hum | Out | Out |
| 9 | Hum | Ing | Hum | Hum | In | Out |
| 10 | Hum | Ing | Hum | Ing | Out | In |
| 11 | Hum | Ing | Ing | Ing | Out | In |
| 12 | Hum | Ing | Ing | Hum | In | Out |
| 13 | Ing | Hum | Hum | Hum | Out | In |
| 14 | Ing | Hum | Hum | Ing | In | Out |
| 15 | Ing | Hum | Ing | Ing | In | Out |
| 16 | Ing | Hum | Ing | Hum | Out | In |
| 17 | Cont | Cont | Hum | Hum | Cont | Cont |
| 18 | Cont | Cont | Hum | Ing | Cont | Cont |
| 19 | Cont | Cont | Ing | Ing | Cont | Cont |
| 20 | Cont | Cont | Ing | Hum | Cont | Cont |
| 21 | Cont | Ing | Hum | Hum | Cont | Out |
| 22 | Cont | Ing | Hum | Ing | Cont | In |
| 23 | Cont | Ing | Ing | Ing | Cont | In |
| 24 | Cont | Ing | Ing | Hum | Cont | Out |
| 25 | Ing | Cont | Hum | Hum | Out | Cont |
| 26 | Ing | Cont | Hum | Ing | In | Cont |
| 27 | Ing | Cont | Ing | Ing | In | Cont |
| 28 | Ing | Cont | Ing | Hum | Out | Cont |
| 29 | Hum | Cont | Hum | Hum | In | Cont |
| 30 | Hum | Cont | Hum | Ing | Out | Cont |
| 31 | Hum | Cont | Ing | Ing | Out | Cont |
| 32 | Hum | Cont | Ing | Hum | In | Cont |
| 33 | Cont | Hum | Hum | Hum | Cont | In |
| 34 | Cont | Hum | Hum | Ing | Cont | Out |
| 35 | Cont | Hum | Ing | Ing | Cont | Out |
| 36 | Cont | Hum | Ing | Hum | Cont | In |

## Interpretation for the Hypotheses

Under the victim role, the severity of moral judgment should be interpreted as a function of the **joint position of both negotiators relative to the victim-player**. This means that hypotheses about ingroup and outgroup effects should not rely on a single binary label only. Instead, they should recognize that each vignette may contain:

- two ingroup negotiators,
- two outgroup negotiators,
- mixed ingroup–outgroup pairs,
- mixed labeled–control pairs,
- or fully control-based conditions.

Accordingly, all hypotheses involving relational group structure should be formulated at the **judgment-by-negotiator level**, while recognizing that each vignette embeds a broader two-negotiator configuration.

## H1 (Main effect of empathy)

- **Script**: `R/hypotheses/H1_test.R`
- **Alternative Hypothesis (H1)**: Empathy will be significantly associated with moral-judgment severity. Specifically, higher empathy will predict lower appropriateness ratings of the negotiators’ decisions.
- **Null Hypothesis (H0₁)**: Empathy will not be significantly associated with moral-judgment severity.
- **Dependent Variable**: `judgement` (bounded score: -9 to 9)
- **Primary Terms**: `iri_total` in Model A; `iri_fs`, `iri_ec`, `iri_pt`, and `iri_pd` in Model B
- **Interpretive Focus**: The empathy effect is evaluated at the **judgment level**, not merely at the vignette level. Each participant-vignette pair contributes two judgments, one per negotiator, and the empathy effect is estimated after conditioning on judged-negotiator status, counterpart-negotiator status, and observer-side victim alignment.
- **Additional Controls**: `judged_outgroup`, `judged_control`, `counterpart_outgroup`, `counterpart_control`, `group_victim` where relevant, role indicators, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Tobit uses cluster-robust standard errors by participant `id`; the non-parametric robustness branch uses interval-censored median regression with participant-level cluster-aware bootstrap inference. In both cases, `id` is only a clustering unit, and repeated judgments from the same participant are not treated as fully independent draws.

## H2 (Main effect of relational group membership)

- **Operational Scripts**: `R/hypotheses/H2a_test.R` and `R/hypotheses/H2b_test.R`
- **Alternative Hypothesis (H2)**: Moral-judgment severity will differ significantly as a function of the judged negotiator's relational group status and decision outcome. Specifically, appropriateness ratings will vary across ingroup, outgroup, and control status of the judged negotiator, and those contrasts will differ between accepted and rejected harmful deals once the counterpart negotiator and, for bystanders, victim alignment are held constant.
- **Null Hypothesis (H0₂)**: Moral-judgment severity will not differ significantly as a function of judged-negotiator relational status, decision outcome, or their interaction.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Primary Terms**: `G_{isjr}`, `A_{is}`, and `G_{isjr} × A_{is}`
- **Interpretive Focus**: The main relational contrast is the status of the **judged negotiator**. In Victim-role rows, ingroup/outgroup/control is defined relative to the victim-player. In Bystander-role rows, ingroup/outgroup/control is defined relative to the observing participant, while the victim's relation to that observer is retained separately through `group_victim`. The counterpart negotiator remains in the model as an additional relational control rather than being collapsed into the same main effect as the judged negotiator.
- **Additional Controls**: `iri_total` or empathy subscales, counterpart-negotiator status, `group_victim` where relevant, role indicators, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Same participant-level clustering rule as H1.

## H3 (Empathy × relational group membership interaction)

- **Script**: `R/hypotheses/H3_test.R`
- **Alternative Hypothesis (H3)**: The association between empathy and moral-judgment severity will vary significantly as a function of the judged negotiator's relational group status. Specifically, the empathy slope will differ across ingroup, outgroup, and control status of the judged negotiator after retaining decision outcome, the judged-status × decision interaction, and the additional relational controls.
- **Null Hypothesis (H0₃)**: The association between empathy and moral-judgment severity will not differ significantly across judged-negotiator relational-status categories.
- **Dependent Variable**: `judgement` (-9 to 9)
- **Primary Terms**: `iri_total × G_{isjr}` in Model A; empathy-subscale × `G_{isjr}` terms in Model B
- **Interpretive Focus**: Moderation is evaluated at the **judgment level**, so empathy can have different associations with severity depending on whether the judged negotiator is ingroup, outgroup, or control. Decision outcome and the judged-status × decision block stay in the specification, while the counterpart negotiator and, for bystanders, victim alignment remain as additional relational controls.
- **Additional Controls**: main effects for empathy, judged-negotiator status, `decision_accept`, judged-status × decision terms, counterpart-negotiator status, `group_victim` where relevant, role indicators, `participant_engineering`, `sex_man`, `age`, `economic_status`, `negotiator_slot`
- **Inference Structure**: Same participant-level clustering rule as H1.

## Dynamic Summary Table

The reporting pipeline exports `outputs/tables/hypothesis_summary.csv`, a concise table that lists each hypothesis alongside the hypothesis-relevant predictors that reach at least `p < .10` in the Tobit model and in the cluster-aware non-parametric robustness model.

Under this updated definition, significant predictors should be interpreted as **judgment-level relational effects**. These may include:

- the participant’s relation to the judged negotiator
- the judged-negotiator status × `Accept/Reject` interaction
- the participant’s relation to the counterpart negotiator
- the participant’s relation to the victim, when the participant is a bystander
- role-dependent contrasts between Victim and Bystander conditions
- or empathy × judged-status interactions

Whenever that table contains at least one significance marker, the dynamic report also generates a matching visualization in `outputs/figures/` and records it in `outputs/tables/hypothesis_figure_catalog.csv`. Continuous predictors receive effect plots, categorical relational-status predictors receive grouped prediction plots, and interaction terms receive interaction plots. These report figures always treat `id` only as the clustering unit for inference.
