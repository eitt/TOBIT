# TOBIT Local Streamlit Playground

This folder contains a local-only exploratory playground for the `eit/TOBIT` project.
It is intentionally isolated from the main R workflow and is not a replacement for the authoritative analysis pipeline.

The playground now follows **Option 2: explicit case-configuration modeling**.
Instead of relying only on isolated indicators such as `perp_outgroup` or `victim_outgroup`, it treats each judgment as a relational victim x negotiator case, for example:

- `Hum_x_Hum`
- `Hum_x_Ing`
- `Hum_x_Control`
- `Ing_x_Hum`
- `Ing_x_Ing`
- `Ing_x_Control`

These are generated from the paired-group structure of the scenarios with the victim group listed first and the judged negotiator listed second. Role (`Observer` / `Victim`) and decision context (`Accept` / `Reject`) can further condition those case configurations through `case_configuration_role`, `case_configuration_decision`, and `case_configuration_context`.

## What it does

- Loads the processed participant-level data from the R project whenever possible.
- Falls back to a local Python bridge for missing sites when the latest processed files only cover one campus.
- Lets you filter by site, attention checks, explicit case configurations, role, decision context, and an optional Mahalanobis-distance rule.
- Fits a real two-sided Tobit model in Python with user-specified censoring bounds.
- Lets you choose the dependent variable, predictors, and optional interaction terms interactively.
- Prioritizes explicit case-configuration factors for relational questions while still exposing the legacy isolated indicators for comparison.
- Ranks "most influential" terms using absolute standardized coefficient magnitude on the latent Tobit scale.
- Includes adaptive plots for single predictors and interactions, including direct visualizations of case configurations and their role-conditioned combinations.

## Important caveats

- This app is for exploration and teaching.
- The R pipeline remains authoritative for production reporting in this repository.
- Option 2 is authoritative for relational interpretation in this playground: the substantive default is the explicit case configuration, not the legacy isolated outgroup indicators.
- The Python playground fits a real censored-regression likelihood, but it does not reproduce the R pipeline's participant-cluster robust standard errors.
- The Python playground does not implement the R pipeline's CLAD / cluster-bootstrap robustness branch.
- The Mahalanobis filter is an exploratory outlier screen applied to the current model matrix after dummy coding. It is not an official exclusion rule.
- The role/decision-conditioned case fields are useful for teaching and inspection, but the exact clustered inference and report-generation logic still belong to the R workflow.
- The influence ranking is a heuristic. It is defined here as:
  `abs(beta_j) * sd(X_j) / sd(y)`
  where `beta_j` is the Tobit coefficient for a design-matrix column.

## One-file start

The easiest option on any cloned copy of the repo is:

```powershell
python launch_playground.py
```

That single file will:

- create `playground/streamlit_local/.venv` if needed
- install or refresh the Python packages in `requirements.txt`
- launch the Streamlit app locally

You can also forward Streamlit args:

```powershell
python launch_playground.py -- --server.port 8502
```

If you want to force a clean reinstall:

```powershell
python launch_playground.py --reinstall
```

## Manual install

From this folder:

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
streamlit run app.py
```

If you prefer `cmd.exe`:

```cmd
python -m venv .venv
.venv\Scripts\activate.bat
pip install -r requirements.txt
streamlit run app.py
```

## Optional helper script

If you want the bridge to write a local dataset snapshot inside this folder:

```powershell
python scripts/build_local_dataset.py
```

This writes:

- `playground/streamlit_local/data/judgments_playground.csv`
- `playground/streamlit_local/data/judgments_playground_metadata.json`

These files are local playground artifacts only.

## Data-loading behavior

The app prefers existing R artifacts first:

- `data/processed/participants_scored.csv`
- `data/processed/03_transformed_participants.csv`

If those files do not contain both sites, the playground reconstructs the missing site locally from:

- `data/raw/data_final_FLORIDA.xlsx`
- `data/raw/data_final_BUC.xlsx`

The bridge mirrors the core R logic where practical:

- attention-pass flag from `ac1 == 1 & ac2 == 1`
- IRI composite and subscales using the same completeness thresholds
- long-format judgement reshaping
- Option 2 relational variables:
  `case_configuration`, `case_configuration_role`, `case_configuration_decision`, and `case_configuration_context`
- legacy derived variables retained for comparison:
  `perp_outgroup`, `perp_control`, `victim_outgroup`, and `same_group_harm`

## Reused project documentation

The app reads and displays these repository docs directly inside the Notes tab:

- `docs/statistical_model_instructions.md`
- `docs/workflow.md`
- `docs/hypotheses.md`
- `docs/datacard.md`

Those remain the best source for the R workflow's methodological framing.
