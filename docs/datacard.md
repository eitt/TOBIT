# **Codebook & Pipeline Transformations – `data_final_FLORIDA`**

## **0. Pipeline Data Transformations**

The `datacard.md` documentation details how original survey measures flow dynamically through the function-oriented R scripts to populate statistical models. The structured transformations include:

- **Filtering:** Erroneous tracking flags (`ac1` & `ac2`) are parsed via `R/02_clean_data.R`.
- **Psychometric Missing Data & Scoring:** Handled within `R/03_transform_data.R`. Classical IRI responses are summarized by 80% completeness thresholds (`row_mean_with_floor`) providing aggregate scale derivations. `iri_total` and the IRI subscales are retained on their original response scale; no predictor z-score normalization is applied.
- **Data Matrix Reshaping:** Raw matrices maintain wide row configurations per participant. The `R/04_generate_variables.R` function shifts inputs logically grouping 10 repeated scenarios into vertical clusters (`judgements`). Under Option 2, the long data now exposes explicit negotiator-level relational variables for the judged negotiator, the counterpart negotiator, and, for observer rows, the victim alignment relative to the participant; older case-label fields remain only for backward compatibility.

## **1. Dataset Overview**

- Each **row** represents **one participant**.
- The dataset includes:
  - **Sociodemographic variables**
  - **Attention checks**
  - **IRI empathy items renamed by subscale**
  - **Treatment order**
  - **Scenario-level experimental variables for 10 stages (`s1` to `s10`)**

---

## **2. Sociodemographic Variables**

- **Participant ID (`id`)**  
  Consecutive identifier assigned to each participant.

- **Commitment check (`commitment`)**  
  Initial question included to encourage more candid responses.

  **Coding**
  - `0` = I do not commit
  - `1` = Yes, I commit
  - `2` = I cannot promise it

- **Age (`age`)**  
  Age in completed years.

- **Socioeconomic status (`economic_status`)**  
  Socioeconomic stratum based on DANE categories.

  **Coding**
  - `0` = Rural
  - `1` = Stratum 1
  - `2` = Stratum 2
  - `3` = Stratum 3
  - `4` = Stratum 4
  - `5` = Stratum 5
  - `6` = Stratum 6

- **Sex assigned at birth (`sex`)**

  **Coding**
  - `0` = I prefer not to say
  - `1` = Woman
  - `2` = Man
  - `3` = Intersex

- **Participant faculty affiliation (`faculty_player`)**

  **Coding**
  - `1` = Humanities
  - `2` = Engineering

---

## **3. Attention Checks**

- **Attention check 1 (`ac1`)**

  **Coding**
  - `0` = Wrong
  - `1` = Right

- **Attention check 2 (`ac2`)**

  **Coding**
  - `0` = Wrong
  - `1` = Right

---

## **4. Psychological Variables (IRI)**

**Important note**

- Reverse-worded items were already recoded correctly before this final dataset was created.
- Items are scored from **0 to 4**.
- Higher values indicate **higher empathy**.

### **IRI Subscales**

- **FS** = Fantasy
- **EC** = Empathic Concern
- **PT** = Perspective Taking
- **PD** = Personal Distress

### **IRI Item Structure**

```text
FS1
EC2
PT3
EC4
FS5
PD6
FS7
PT8
EC9
PD10
PT11
FS12
PD13
EC14
PT15
FS16
EC17
PD18
EC19
FS20
PT21
PD22
PT23
EC24
FS25
PT26
PD27
EC28
```

---

## **5. Treatment Variable**

- **Treatment order (`treatment`)**

Each participant evaluates **10 scenarios**:
- **5 as victim**
- **5 as observer**

To balance order effects, participants are randomly assigned to one of two sequences.

**Coding**
- `1` = Victim first, observer second (stages 1-5 = 2, stages 6-10 = 1)
- `2` = Observer first, victim second (stages 1-5 = 1, stages 6-10 = 2)
- `0` = Dropped from analytical dataset (used only for EDA purposes).

Using this treatment logic, 10 stage-specific variables (`role_s1` through `role_s10`) are programmatically populated to track the role the participant occupied in that specific scenario.

---

## **6. Scenario-Level Variables**

Each participant evaluates **10 stages (`s1` to `s10`)**.

In each stage, the variables are ordered as follows:

```text
role_sX
faculty_neg_1_sX
faculty_neg_2_sX
faculty_victim_sX
decision_neg1_sX
decision_neg2_sX
judgement_compare_sX
judgement_n1_sX
judgement_n2_sX
```

where **`sX` refers to `s1` through `s10`**.

---

### **6.1 Procedural Role**
Variables:
- `role_s1` to `role_s10`

**Coding**
- `1` = Observer
- `2` = Victim

---

## **7. Coding of Scenario-Level Variables**

### **7.1 Faculty of Negotiator 1**
Variables:
- `faculty_neg_1_s1` to `faculty_neg_1_s10`

### **7.2 Faculty of Negotiator 2**
Variables:
- `faculty_neg_2_s1` to `faculty_neg_2_s10`

**Coding for both negotiator faculty variables**
- `1` = Humanities
- `2` = Engineering
- `3` = Control (no faculty label shown)

---

### **7.3 Faculty of Victim**
Variables:
- `faculty_victim_s1` to `faculty_victim_s10`

**Coding**
- `1` = Humanities
- `2` = Engineering

---

### **7.4 Decision of Negotiator 1**
Variables:
- `decision_neg1_s1` to `decision_neg1_s10`

### **7.5 Decision of Negotiator 2**
Variables:
- `decision_neg2_s1` to `decision_neg2_s10`

**Coding for both decision variables**
- `0` = Reject
- `1` = Accept

---

### **7.6 Comparative Moral Judgment**
Variables:
- `judgement_compare_s1` to `judgement_compare_s10`

**Coding**
- `1` = Negotiator 1 acted worse
- `2` = Negotiator 2 acted worse
- `3` = Both acted equally

---

### **7.7 Numerical Moral Judgment for Negotiator 1**
Variables:
- `judgement_n1_s1` to `judgement_n1_s10`

### **7.8 Numerical Moral Judgment for Negotiator 2**
Variables:
- `judgement_n2_s1` to `judgement_n2_s10`

**Scale**
- `-9` = Acted very badly
- `0` = Neutral midpoint
- `9` = Acted very well

---

## **8. Dataset Structure**

- Each **row** = one participant
- Each participant evaluates **10 scenarios**
- Each scenario includes **2 negotiators**
- Therefore, each participant provides:
  - **10 comparative judgments**
  - **10 ratings for Negotiator 1**
  - **10 ratings for Negotiator 2**

This means the dataset is currently in **wide format**, with repeated scenario-level variables stored across columns.

---

## **8.1 Construction of the Dependent Variable in the Long Data**

The models do **not** use one single outcome per scenario. They use a negotiator-level long-format outcome built in `R/04_generate_variables.R`.

For each participant and each stage `sX`, the source file contains two numerical judgment columns:

- `judgement_n1_sX` = moral judgment of Negotiator 1
- `judgement_n2_sX` = moral judgment of Negotiator 2

During the wide-to-long reshaping step:

- one long row is created for `negotiator_slot = 1`
- one long row is created for `negotiator_slot = 2`
- the corresponding source value is copied into the long-format variable `judgement`

Therefore, each participant-stage pair contributes **two dependent-variable observations**, one per judged negotiator.

In compact form:

```text
judgement = judgement_n1_sX when negotiator_slot = 1
judgement = judgement_n2_sX when negotiator_slot = 2
```

The analytical dependent variable used in the Tobit and CLAD models is:

- `judgement`
  Negotiator-specific moral judgment on the observed bounded scale from `-9` to `9`

The pipeline also creates:

- `condemnation = -judgement`
  A sign-flipped convenience variable where larger values indicate stronger condemnation, but the current hypothesis scripts use `judgement` itself as the primary dependent variable.

This means the dependent variable is defined at the **judgment-by-negotiator level**, not only at the participant-stage or vignette level.

---

## **8.2 Option 2 Relational Variables in the Long Data**

After `R/04_generate_variables.R` reshapes the data to the negotiator-level long format, the analytical datasets add:

- `case_configuration`
  Victim x negotiator relational scenario label, for example `Hum_x_Ing`.
- `case_configuration_role`
  The explicit case configuration further conditioned by `Observer` or `Victim`.
- `case_configuration_decision`
  The explicit case configuration further conditioned by `Accept` or `Reject`.
- `case_configuration_context`
  The full scenario context combining victim x negotiator pairing, role, and decision context.
- `analytic_case_configuration`
  Role-dependent judgment configuration. Victim rows encode judged negotiator plus counterpart negotiator; observer rows additionally encode victim alignment relative to the participant.
- `analytic_case_configuration_decision`
  The role-dependent analytic configuration further conditioned by `Accept` or `Reject`.
- `analytic_case_configuration_context`
  Alias for the role-dependent analytic configuration conditioned by the judged negotiator's decision context.
- `group_negotiator_judged`
  Judged negotiator relation to the role-relevant reference actor (`In`, `Out`, `Cont`).
- `group_negotiator_counterpart`
  Counterpart negotiator relation to the role-relevant reference actor (`In`, `Out`, `Cont`).
- `group_victim`
  Observer-side victim relation to the participant (`In` or `Out`; not used for victim-role rows).
- `judged_outgroup`
  Dummy equal to `1` when the judged negotiator is outgroup relative to the role-relevant reference actor.
- `judged_control`
  Dummy equal to `1` when the judged negotiator is in the control / unlabeled condition.
- `counterpart_outgroup`
  Dummy equal to `1` when the counterpart negotiator is outgroup.
- `counterpart_control`
  Dummy equal to `1` when the counterpart negotiator is in the control / unlabeled condition.
- `observer_victim_outgroup`
  Dummy equal to `1` only for observer-role rows where the victim is outgroup relative to the participant.
- `h2_negotiator_structure`
  Joint H2 predictor encoding the judged negotiator and the counterpart negotiator within the same judgment row (reference `J_In__C_In`).
- `player_victim_alignment`
  Observer-side victim relation to the player recoded explicitly for H2 (`In` or `Out`).
- `player_victim_outgroup`
  Dummy equal to `1` only for observer-role rows where the player and victim are outgroup relative to each other.

For H1 and descriptive summaries, the compact `case_configuration` shorthand remains useful. For H2, the executable models now use the explicit `h2_negotiator_structure` block and, in observer rows, `player_victim_outgroup` plus its interaction with that structure. H3 continues to use judged-negotiator status, `decision_accept`, the judged-status x decision interaction, and the additional relational controls above. Legacy isolated indicators such as `perp_outgroup`, `victim_outgroup`, and `same_group_harm` remain available for backward comparison only.

---

## **8.3 Hypothesis-Specific Analytical Subsets**

The executable hypotheses in `docs/hypotheses.md` map onto the processed long-format datasets as follows:

- **H1 (`R/hypotheses/H1_test.R`)**
  Uses `data/processed/judgments_accept_only.csv`. The core modeled terms are `iri_total` in Model A or `iri_fs`, `iri_ec`, `iri_pt`, and `iri_pd` in Model B, plus the relational controls `judged_outgroup`, `judged_control`, `counterpart_outgroup`, `counterpart_control`, `observer_victim_outgroup`, and `role_observer`.

- **H2 (`R/hypotheses/H2_test.R`)**
  Uses `data/processed/judgments_victim.csv` and `data/processed/judgments_bystander.csv`. In the victim subset, the core modeled terms are the `h2_negstruct_*` dummies derived from the judged-plus-counterpart structure. In the bystander subset, the core modeled terms are the same `h2_negstruct_*` dummies, `player_victim_outgroup`, and the `player_victim_outgroup:h2_negstruct_*` interactions. Both H2 models retain empathy controls and the participant controls `participant_engineering`, `sex_man`, `age`, `economic_status`, and `factor(negotiator_slot)`.

- **H3 (`R/hypotheses/H3_test.R`)**
  Uses `data/processed/judgments_analysis.csv`. The core modeled terms are empathy x judged-status interactions (`iri_total` in Model A; empathy-subscale terms in Model B), while also retaining judged status, `decision_accept`, judged-status x decision interactions, counterpart status, and observer-side victim alignment.

This mapping matters because the dynamic report, significance summary tables, and generated figures all read these same processed subsets and term definitions when deciding which coefficients are hypothesis-relevant.

---

## **9. Variables by Analytical Level**

### **Participant-level variables**

```text
id
commitment
age
economic_status
sex
faculty_player
ac1
ac2
FS1
EC2
PT3
EC4
FS5
PD6
FS7
PT8
EC9
PD10
PT11
FS12
PD13
EC14
PT15
FS16
EC17
PD18
EC19
FS20
PT21
PD22
PT23
EC24
FS25
PT26
PD27
EC28
treatment
```

### **Scenario-level variables**

```text
faculty_neg_1_sX
faculty_neg_2_sX
faculty_victim_sX
decision_neg1_sX
decision_neg2_sX
judgement_compare_sX
judgement_n1_sX
judgement_n2_sX
```

where **`sX` refers to stages `s1` to `s10`**.
