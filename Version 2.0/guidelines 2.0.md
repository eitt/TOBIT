**Research Question**

> How do empathy and social identity, operationalized as faculty affiliation (Humanities vs. Engineering), jointly influence the severity of moral judgments in an incentivized economic experiment?

The study investigates how empathy and social identity jointly influence the severity of moral judgments when individuals evaluate harmful decisions in an incentivized economic experiment. Social identity is operationalized through academic faculty affiliation (Humanities vs. Engineering), allowing the study to test whether moral condemnation varies across ingroup and outgroup contexts.

**Hypotheses**

The study tests three hypotheses:

**H1 (Empathy effect):** Higher empathy, measured through the composite score of the Interpersonal Reactivity Index (IRI), predicts more severe moral judgments of negotiators’ harmful decisions.

**H2 (Group identity effects):** Two competing hypotheses are tested regarding the effect of social identity on moral judgment severity.

* **H2a (Ingroup betrayal hypothesis):** Harmful actions committed against a member of the same academic faculty (ingroup–ingroup case) will receive more severe moral judgments than actions committed against an outgroup member, because harming one's own group may be perceived as a violation of group norms.
* **H2b (Outgroup derogation hypothesis):** Harmful actions committed by an outgroup perpetrator will receive more severe moral judgments than those committed by an ingroup perpetrator, reflecting a tendency to judge outgroup members more harshly.

**H3 (Empathy × group moderation):** The association between empathy and moral judgment severity will be stronger in outgroup cases than in ingroup cases, meaning that empathy amplifies condemnation particularly when the perpetrator belongs to an outgroup.

**Method**

The study uses a laboratory economic experiment with undergraduate students from the Universidad Industrial de Santander in Colombia. Participants evaluate decision scenarios generated in a pilot stage of a modified bribery game. In the original task, two negotiators decide whether to accept a deal that increases their own payoff while reducing the payoff of a third party (the victim). If at least one negotiator accepts, negotiators receive a higher payoff while the victim receives a lower payoff; if both reject, all players receive equal payoffs.

In the main experiment, participants do not act as negotiators but instead evaluate previously recorded decisions. Each participant evaluates ten scenarios: five in the role of victim and five in the role of observer. After observing the decisions of two negotiators, participants rate the moral appropriateness of each negotiator’s action on a scale ranging from −9 (“acted very badly”) to +9 (“acted very well”). Participants also provide a comparative judgment indicating which negotiator behaved worse.

The experimental manipulation consists of revealing or hiding the academic faculty affiliation of negotiators and victims (Humanities vs. Engineering). This generates ingroup, outgroup, and control conditions. After completing the evaluation task, participants answer the 28 items of the Interpersonal Reactivity Index (IRI), which measures four components of empathy: Fantasy, Empathic Concern, Perspective Taking, and Personal Distress. Analyses use regression and mixed-effects models to account for repeated scenario evaluations nested within participants.

**Codebook** for `consolidado_ALL_2026_04_09_LONG`

Note: Estas serían las nuevas variables. Sobretodo las de "Case structure variables" son las que hablamos hoy que se vuelven como id para cada juicio moral.

Each row represents **one moral judgment** about **one negotiator** within **one stage**.
Each participant contributes **20 rows**: **10 stages × 2 target judgments per stage**.
The dataset is in **long format**.

---

### **Checks and participant-level variables**

`commitment`
Commitment check: initial question included to encourage more candid responses.
Coding: 0 = *I do not commit*, 1 = *Yes, I commit*, 2 = *I cannot promise it*.

`ac1`
Attention check 1.
Coding: wrong = **0**, right = **1**.

`ac2`
Attention check 2.
Coding: wrong = **0**, right = **1**.

`session`
Session in which the data were collected.
Coding: **1** to **16**.

`id`
Participant ID.

`age`
Age in years.

`ses`
Socioeconomic status based on DANE categories.
Coding: 0 = rural, 1 = stratum 1, 2 = stratum 2, 3 = stratum 3, 4 = stratum 4, 5 = stratum 5, 6 = stratum 6.

`sex_female`
Sex dummy variable.
Coding: woman = **1**, man = **0**, prefer not to say = missing.

`faculty_player`
Faculty affiliation of the participant.
Coding: Humanities = **1**, Engineering = **2**.

---

### **Case structure variables**

`stage`
Stage in which the judgment was recorded.
Coding: **1** to **10**.

`id_case`
Case identifier, composed of participant ID + stage.
Example: *1s1* = participant 1, stage 1.

`role`
Role in the scenario.
Coding: victim = **1**, bystander = **0**.

---

### **IRI items**

`FS1`
IRI item 1, Fantasy.

`EC2`
IRI item 2, Empathic Concern.

`PT3`
IRI item 3, Perspective Taking.

`EC4`
IRI item 4, Empathic Concern.

`FS5`
IRI item 5, Fantasy.

`PD6`
IRI item 6, Personal Distress.

`FS7`
IRI item 7, Fantasy.

`PT8`
IRI item 8, Perspective Taking.

`EC9`
IRI item 9, Empathic Concern.

`PD10`
IRI item 10, Personal Distress.

`PT11`
IRI item 11, Perspective Taking.

`FS12`
IRI item 12, Fantasy.

`PD13`
IRI item 13, Personal Distress.

`EC14`
IRI item 14, Empathic Concern.

`PT15`
IRI item 15, Perspective Taking.

`FS16`
IRI item 16, Fantasy.

`PD17`
IRI item 17, Personal Distress.

`EC18`
IRI item 18, Empathic Concern.

`PD19`
IRI item 19, Personal Distress.

`EC20`
IRI item 20, Empathic Concern.

`PT21`
IRI item 21, Perspective Taking.

`EC22`
IRI item 22, Empathic Concern.

`FS23`
IRI item 23, Fantasy.

`PD24`
IRI item 24, Personal Distress.

`PT25`
IRI item 25, Perspective Taking.

`FS26`
IRI item 26, Fantasy.

`PD27`
IRI item 27, Personal Distress.

`PT28`
IRI item 28, Perspective Taking.

---

### **IRI subscales**

`iri_fs`
Mean score for the **Fantasy** subscale.
Computed from FS1, FS5, FS7, FS12, FS16, FS23, and FS26.

`iri_ec`
Mean score for the **Empathic Concern** subscale.
Computed from EC2, EC4, EC9, EC14, EC18, EC20, and EC22.

`iri_pt`
Mean score for the **Perspective Taking** subscale.
Computed from PT3, PT8, PT11, PT15, PT21, PT25, and PT28.

`iri_pd`
Mean score for the **Personal Distress** subscale.
Computed from PD6, PD10, PD13, PD17, PD19, PD24, and PD27.

---

### **Judgment variables**

`target`
Target of the moral judgment.
Coding: Negotiator 1 = **1**, Negotiator 2 = **2**.

`judgement`
Moral judgment of the target negotiator on a scale from **-9** to **9**.
Higher values indicate a more positive evaluation.

`decision_target`
Decision made by the target negotiator.
Coding: reject = **0**, accept = **1**.

`decision_other`
Decision made by the other negotiator in the same stage.
Coding: reject = **0**, accept = **1**.

---

### **Faculty and group variables**

`faculty_target`
Faculty affiliation of the target negotiator.
Coding: control = **0**, Humanities = **1**, Engineering = **2**.

`faculty_other`
Faculty affiliation of the other negotiator in the same stage.
Coding: control = **0**, Humanities = **1**, Engineering = **2**.

`faculty_victim`
Faculty affiliation of the victim, only applicable when `role = 0`.
Coding: Humanities = **1**, Engineering = **2**.

`group_target`
Group relation between participant and target negotiator.
Coding: control = **0**, ingroup = **1**, outgroup = **2**.

`group_other`
Group relation between participant and the other negotiator.
Coding: control = **0**, ingroup = **1**, outgroup = **2**.

`obs_group`
Group relation between participant and victim, only applicable when `role = 0`.
Coding: ingroup = **1**, outgroup = **2**.

`n_match`
Whether Negotiator 1 and Negotiator 2 match in faculty affiliation.
Coding: no = **0**, yes = **1**.

# preliminary data-cleaning

```python
import pandas as pd
import numpy as np
import shutil

# =========================================================
# 1. ARCHIVOS
# =========================================================
input_file = "/content/consolidado_ALL_2026_04_09.xlsx"
backup_file = "/content/consolidado_ALL_2026_04_09_BACKUP_BRUTO.xlsx"
output_file = "/content/consolidado_ALL_2026_04_09_WIDE_CLEAN.xlsx"

# Backup del archivo bruto
shutil.copy(input_file, backup_file)

# Leer archivo
df = pd.read_excel(input_file)

print("Archivo leído correctamente.")
print("Dimensiones iniciales:", df.shape)

# =========================================================
# 2. RENOMBRAR VARIABLES 1:1
# =========================================================
rename_dict = {
    "economic_status": "ses",
    "sex": "sex_original"
}

for s in range(1, 11):
    rename_dict[f"juicio_n1_s{s}"] = f"judgement_n1_s{s}"
    rename_dict[f"juicio_n2_s{s}"] = f"judgement_n2_s{s}"

df = df.rename(columns=rename_dict)

# =========================================================
# 3. RENOMBRAR ÍTEMS IRI CON LA NUEVA CLAVE CORRECTA
# =========================================================
iri_rename_map = {
    "I1": "FS1",
    "I2": "EC2",
    "I3": "PT3",
    "I4": "EC4",
    "I5": "FS5",
    "I6": "PD6",
    "I7": "FS7",
    "I8": "PT8",
    "I9": "EC9",
    "I10": "PD10",
    "I11": "PT11",
    "I12": "FS12",
    "I13": "PD13",
    "I14": "EC14",
    "I15": "PT15",
    "I16": "FS16",
    "I17": "PD17",
    "I18": "EC18",
    "I19": "PD19",
    "I20": "EC20",
    "I21": "PT21",
    "I22": "EC22",
    "I23": "FS23",
    "I24": "PD24",
    "I25": "PT25",
    "I26": "FS26",
    "I27": "PD27",
    "I28": "PT28"
}

missing_iri = [c for c in iri_rename_map if c not in df.columns]
if missing_iri:
    raise ValueError(f"Faltan estas columnas IRI: {missing_iri}")

df = df.rename(columns=iri_rename_map)

# =========================================================
# 4. RECODIFICAR SEXO Y CREAR sex_female
# =========================================================
# sex original:
# 1 = mujer
# 2 = hombre
# 0 = prefiero no decir -> vacío
def recode_sex_female(x):
    if pd.isna(x):
        return np.nan
    try:
        x = int(x)
    except:
        return np.nan
    if x == 1:
        return 1
    elif x == 2:
        return 0
    elif x == 0:
        return np.nan
    return np.nan

df["sex_female"] = df["sex_original"].apply(recode_sex_female)

# =========================================================
# 5. RECODIFICAR TEXTO A NUMÉRICO
# =========================================================
decision_map = {
    "accept": 1,
    "reject": 0,
    "Accept": 1,
    "Reject": 0
}

faculty_map = {
    "hum": 1,
    "ing": 2,
    "control": 0,
    "Hum": 1,
    "Ing": 2,
    "Control": 0
}

for s in range(1, 11):
    for col in [f"decision_neg1_s{s}", f"decision_neg2_s{s}"]:
        if col in df.columns:
            df[col] = df[col].replace(decision_map)

    for col in [f"faculty_neg_1_s{s}", f"faculty_neg_2_s{s}", f"faculty_victim_s{s}"]:
        if col in df.columns:
            df[col] = df[col].replace(faculty_map)

# =========================================================
# 6. CREAR PROMEDIOS DE SUBESCALAS IRI
# =========================================================
fs_cols = ["FS1", "FS5", "FS7", "FS12", "FS16", "FS23", "FS26"]
ec_cols = ["EC2", "EC4", "EC9", "EC14", "EC18", "EC20", "EC22"]
pt_cols = ["PT3", "PT8", "PT11", "PT15", "PT21", "PT25", "PT28"]
pd_cols = ["PD6", "PD10", "PD13", "PD17", "PD19", "PD24", "PD27"]

df["iri_fs"] = df[fs_cols].mean(axis=1, skipna=True)
df["iri_ec"] = df[ec_cols].mean(axis=1, skipna=True)
df["iri_pt"] = df[pt_cols].mean(axis=1, skipna=True)
df["iri_pd"] = df[pd_cols].mean(axis=1, skipna=True)

# =========================================================
# 7. CONVERTIR VARIABLES ANALÍTICAS A NUMÉRICAS
# =========================================================
analytic_cols = [
    "session", "id", "ac1", "ac2", "age", "commitment", "ses",
    "faculty_player", "sex_original", "sex_female", "order",
    "iri_fs", "iri_ec", "iri_pt", "iri_pd"
]

analytic_cols += list(iri_rename_map.values())

for s in range(1, 11):
    analytic_cols += [
        f"decision_neg1_s{s}",
        f"decision_neg2_s{s}",
        f"faculty_neg_1_s{s}",
        f"faculty_neg_2_s{s}",
        f"faculty_victim_s{s}",
        f"judgement_n1_s{s}",
        f"judgement_n2_s{s}"
    ]

analytic_cols = [c for c in analytic_cols if c in df.columns]

for col in analytic_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")

# =========================================================
# 8. REORDENAR COLUMNAS
# =========================================================
base_cols = [
    "session", "id",
    "FS1", "EC2", "PT3", "EC4", "FS5", "PD6", "FS7", "PT8", "EC9", "PD10",
    "PT11", "FS12", "PD13", "EC14", "PT15", "FS16", "PD17", "EC18", "PD19",
    "EC20", "PT21", "EC22", "FS23", "PD24", "PT25", "FS26", "PD27", "PT28",
    "ac1", "ac2", "age", "commitment"
]

stage_cols = []
for prefix in ["decision_neg1", "decision_neg2", "faculty_neg_1", "faculty_neg_2", "faculty_victim", "judgement_n1", "judgement_n2"]:
    for s in range(1, 11):
        col = f"{prefix}_s{s}"
        if col in df.columns:
            stage_cols.append(col)

tail_cols = [
    "ses", "faculty_player", "sex_original", "sex_female",
    "iri_fs", "iri_ec", "iri_pt", "iri_pd", "order"
]

ordered_cols = [c for c in base_cols if c in df.columns] + \
               stage_cols + \
               [c for c in tail_cols if c in df.columns]

remaining_cols = [c for c in df.columns if c not in ordered_cols]
df = df[ordered_cols + remaining_cols]

# =========================================================
# 9. EXPORTAR
# =========================================================
df.to_excel(output_file, index=False)

print("Listo.")
print("Backup bruto guardado en:", backup_file)
print("Archivo limpio ancho guardado en:", output_file)
print("Dimensiones finales:", df.shape)
print(df.head())

import pandas as pd
import numpy as np

# =========================================================
# 1. ARCHIVOS
# =========================================================
input_file = "/content/consolidado_ALL_2026_04_09_WIDE_CLEAN.xlsx"
output_file = "/content/consolidado_ALL_2026_04_09_LONG.xlsx"

df = pd.read_excel(input_file)

print("Archivo ancho limpio leído correctamente.")
print("Dimensiones iniciales:", df.shape)

# =========================================================
# 2. FUNCIONES AUXILIARES
# =========================================================
def get_role(order, stage):
    """
    role:
    victim = 1
    bystander = 0
    """
    if pd.isna(order):
        return np.nan

    if order == 1:
        return 1 if stage <= 5 else 0
    elif order == 2:
        return 0 if stage <= 5 else 1
    else:
        return np.nan

def get_group(faculty_x, faculty_player):
    """
    faculty:
    1 = hum
    2 = ing
    0 = control

    group:
    1 = ingroup
    2 = outgroup
    0 = control
    """
    if pd.isna(faculty_x):
        return np.nan

    try:
        faculty_x = int(faculty_x)
    except:
        return np.nan

    if faculty_x == 0:
        return 0

    if pd.isna(faculty_player):
        return np.nan

    try:
        faculty_player = int(faculty_player)
    except:
        return np.nan

    if faculty_x == faculty_player:
        return 1
    else:
        return 2

def get_n_match(f1, f2):
    if pd.isna(f1) or pd.isna(f2):
        return np.nan
    try:
        f1 = int(f1)
        f2 = int(f2)
    except:
        return np.nan
    return 1 if f1 == f2 else 0

# =========================================================
# 3. CREAR FORMATO LARGO
# =========================================================
long_rows = []

for _, row in df.iterrows():
    player_id = row["id"]
    session = row["session"]
    order = row["order"]
    faculty_player = row["faculty_player"]

    for stage in range(1, 11):
        role = get_role(order, stage)
        id_case = f"{int(player_id)}s{stage}"

        # variables del stage
        faculty_neg_1 = row.get(f"faculty_neg_1_s{stage}", np.nan)
        faculty_neg_2 = row.get(f"faculty_neg_2_s{stage}", np.nan)
        faculty_victim = row.get(f"faculty_victim_s{stage}", np.nan)
        decision_neg1 = row.get(f"decision_neg1_s{stage}", np.nan)
        decision_neg2 = row.get(f"decision_neg2_s{stage}", np.nan)
        judgement_n1 = row.get(f"judgement_n1_s{stage}", np.nan)
        judgement_n2 = row.get(f"judgement_n2_s{stage}", np.nan)

        n_match = get_n_match(faculty_neg_1, faculty_neg_2)

        # obs_group solo aplica cuando role = bystander
        if role == 0:
            obs_group = get_group(faculty_victim, faculty_player)
            faculty_victim_value = faculty_victim
        else:
            obs_group = np.nan
            faculty_victim_value = np.nan

        # -------------------------------------------------
        # Fila 1: target = n1
        # -------------------------------------------------
        long_rows.append({
            "session": session,
            "id": player_id,
            "id_case": id_case,
            "stage": stage,
            "role": role,
            "age": row.get("age", np.nan),
            "ses": row.get("ses", np.nan),
            "sex_female": row.get("sex_female", np.nan),
            "faculty_player": faculty_player,
            "iri_fs": row.get("iri_fs", np.nan),
            "iri_ec": row.get("iri_ec", np.nan),
            "iri_pt": row.get("iri_pt", np.nan),
            "iri_pd": row.get("iri_pd", np.nan),
            "target": 1,
            "judgement": judgement_n1,
            "decision_target": decision_neg1,
            "decision_other": decision_neg2,
            "faculty_target": faculty_neg_1,
            "faculty_other": faculty_neg_2,
            "faculty_victim": faculty_victim_value,
            "group_target": get_group(faculty_neg_1, faculty_player),
            "group_other": get_group(faculty_neg_2, faculty_player),
            "n_match": n_match,
            "obs_group": obs_group
        })

        # -------------------------------------------------
        # Fila 2: target = n2
        # -------------------------------------------------
        long_rows.append({
            "session": session,
            "id": player_id,
            "id_case": id_case,
            "stage": stage,
            "role": role,
            "age": row.get("age", np.nan),
            "ses": row.get("ses", np.nan),
            "sex_female": row.get("sex_female", np.nan),
            "faculty_player": faculty_player,
            "iri_fs": row.get("iri_fs", np.nan),
            "iri_ec": row.get("iri_ec", np.nan),
            "iri_pt": row.get("iri_pt", np.nan),
            "iri_pd": row.get("iri_pd", np.nan),
            "target": 2,
            "judgement": judgement_n2,
            "decision_target": decision_neg2,
            "decision_other": decision_neg1,
            "faculty_target": faculty_neg_2,
            "faculty_other": faculty_neg_1,
            "faculty_victim": faculty_victim_value,
            "group_target": get_group(faculty_neg_2, faculty_player),
            "group_other": get_group(faculty_neg_1, faculty_player),
            "n_match": n_match,
            "obs_group": obs_group
        })

df_long = pd.DataFrame(long_rows)

# =========================================================
# 4. CONVERTIR VARIABLES A NUMÉRICO
# =========================================================
numeric_cols = [
    "session", "id", "stage", "role", "age", "ses", "sex_female",
    "faculty_player", "iri_fs", "iri_ec", "iri_pt", "iri_pd",
    "target", "judgement", "decision_target", "decision_other",
    "faculty_target", "faculty_other", "faculty_victim",
    "group_target", "group_other", "n_match", "obs_group"
]

for col in numeric_cols:
    if col in df_long.columns:
        df_long[col] = pd.to_numeric(df_long[col], errors="coerce")

# =========================================================
# 5. ORDENAR COLUMNAS
# =========================================================
final_cols = [
    "session", "id", "id_case", "stage", "role",
    "age", "ses", "sex_female", "faculty_player",
    "iri_fs", "iri_ec", "iri_pt", "iri_pd",
    "target", "judgement",
    "decision_target", "decision_other",
    "faculty_target", "faculty_other", "faculty_victim",
    "group_target", "group_other", "n_match", "obs_group"
]

df_long = df_long[final_cols]

# =========================================================
# 6. ORDENAR FILAS
# =========================================================
df_long = df_long.sort_values(by=["id", "stage", "target"]).reset_index(drop=True)

# =========================================================
# 7. EXPORTAR
# =========================================================
df_long.to_excel(output_file, index=False)

print("Listo.")
print("Archivo largo guardado en:", output_file)
print("Dimensiones finales:", df_long.shape)
print(df_long.head(12))
```

## Modeling strategy

Note: Esto es lo que haríamos con el dataset "consolidado_ALL_2026_04_09_LONG.xlsx

We estimated **six multilevel regression models** using `judgement` as the dependent variable. Models were estimated separately for observations in which participants evaluated scenarios as **victims** (`role = 1`) and as **bystanders** (`role = 0`).

Because each participant contributed repeated judgments, and because each participant-stage combination (`id_case`) contained **two paired judgments**, all models included a random intercept for **participant** and a random intercept for **case**. In addition, all models controlled for the structural position of the judged negotiator using `factor(target)`, where `target = 1` indicates judgments about Negotiator 1 and `target = 2` indicates judgments about Negotiator 2.

Thus, in all models:

* `judgement` is the dependent variable
* `age`, `ses`, `sex_female`, and `faculty_player` are included as sociodemographic controls
* `factor(target)` is included as a case-structure control
* `(1 | id)` accounts for repeated observations within participants
* `(1 | id_case)` accounts for the pairing of the two judgments within the same stage

---

## H1. Empathy subscales and moral judgment

For H1, the goal is to estimate whether the four empathy subscales predict moral judgment severity. Because this hypothesis is not about group identity, group variables are not included. However, the model includes the decisions of both negotiators, since judgments may depend on both the target’s decision and the other negotiator’s decision.

### H1a. Victim model

```r
judgement ~ iri_fs + iri_ec + iri_pt + iri_pd +
            decision_target + decision_other +
            age + ses + sex_female + faculty_player +
            factor(target) +
            (1 | id) + (1 | id_case)
```

### H1a. Victim model

```r
judgement ~ iri_fs + iri_ec + iri_pt + iri_pd +
            decision_target + decision_other +
            age + ses + sex_female + faculty_player +
            factor(target) +
            (1 | id) + (1 | id_case)
```

---

## H2. Group identity and moral judgment

For H2, the goal is to estimate whether group identity predicts moral judgment severity. These models exclude empathy variables and focus on the group relation between the participant and the target negotiator, as well as the group relation with the other negotiator. The decisions of both negotiators are still included as controls, since judgments depend on what each negotiator did.

For bystanders, the model also includes `obs_group`, which captures whether the victim belongs to the participant’s ingroup or outgroup.

### H2a. Victim model

```r
judgement ~ factor(group_target) + factor(group_other) +
            decision_target + decision_other +
            age + ses + sex_female + faculty_player +
            factor(target) +
            (1 | id) + (1 | id_case)
```

### H2b. Bystander model

```r
judgement ~ factor(group_target) + factor(group_other) + factor(obs_group) +
            decision_target + decision_other +
            age + ses + sex_female + faculty_player +
            factor(target) +
            (1 | id) + (1 | id_case)
```

---

## H3. Combined effect of empathy and group identity

For H3, the goal is to estimate whether the association between empathy and moral judgment depends on group identity. These models include both empathy and group variables, as well as their interactions.

The most theoretically central interaction is between each empathy subscale and `group_target`, because the main question is whether empathy changes the way participants judge a negotiator depending on whether that negotiator is ingroup, outgroup, or control.

As in H2, `group_other` is retained as a control for the social composition of the full scenario, and in bystander models `obs_group` is included as an additional contextual variable.

### H3a. Victim model

```r
judgement ~ iri_fs + iri_ec + iri_pt + iri_pd +
            factor(group_target) + factor(group_other) +
            iri_fs:factor(group_target) +
            iri_ec:factor(group_target) +
            iri_pt:factor(group_target) +
            iri_pd:factor(group_target) +
            decision_target + decision_other +
            age + ses + sex_female + faculty_player +
            factor(target) +
            (1 | id) + (1 | id_case)
```

### H3b. Bystander model

```r
judgement ~ iri_fs + iri_ec + iri_pt + iri_pd +
            factor(group_target) + factor(group_other) + factor(obs_group) +
            iri_fs:factor(group_target) +
            iri_ec:factor(group_target) +
            iri_pt:factor(group_target) +
            iri_pd:factor(group_target) +
            decision_target + decision_other +
            age + ses + sex_female + faculty_player +
            factor(target) +
            (1 | id) + (1 | id_case)
```

---

## How the case-structure variables are used

With the new long-format dataset, the case-structure variables play different roles in the models:

* `role` is used to **split the sample**, so it does not appear as a predictor inside the six models.
* `target` is included as `factor(target)` to control for any systematic difference between judging Negotiator 1 and Negotiator 2.
* `id_case` is included as a **random intercept**, because the two judgments within the same stage are paired and share the same scenario context.
* `id` is included as a **random intercept**, because each participant contributes repeated judgments across multiple stages.

We do not include `stage` as an additional fixed effect in these main models, because `id_case` already captures the within-stage pairing, and splitting by `role` accounts for the main design distinction between victim and bystander observations.

## Reference categories

To facilitate interpretation, the following reference categories are recommended:

* `group_target`: **ingroup**
* `group_other`: **ingroup**
* `obs_group`: **ingroup**
* `target`: **Negotiator 1**

With this coding, the coefficients for **outgroup** and **control** can be interpreted as deviations from the ingroup condition.
