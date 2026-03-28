from __future__ import annotations

from itertools import combinations
from pathlib import Path

import pandas as pd
import streamlit as st

from data_bridge import load_playground_dataset
from modeling import (
    build_formula,
    build_model_frame,
    coefficient_table,
    fit_tobit_model,
    format_display_value,
    format_predictor_option,
    influence_table,
    interaction_options,
    outcome_candidates,
    predictor_keys,
    predictor_label,
    suggested_mahalanobis_cutoff,
    squared_mahalanobis_distance,
)
from plotting import interaction_plot, predictor_plot


APP_ROOT = Path(__file__).resolve().parent
PROJECT_ROOT = APP_ROOT.parents[1]
DOC_FILES = [
    ("Statistical model notes", PROJECT_ROOT / "docs" / "statistical_model_instructions.md"),
    ("Workflow notes", PROJECT_ROOT / "docs" / "workflow.md"),
    ("Hypothesis notes", PROJECT_ROOT / "docs" / "hypotheses.md"),
    ("Datacard notes", PROJECT_ROOT / "docs" / "datacard.md"),
]

DEFAULT_PREDICTORS = [
    "iri_total",
    "case_configuration",
    "decision_accept",
    "role_observer",
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status",
    "negotiator_slot",
]

LOCAL_NOTE = """
This is a **local exploratory playground** for teaching, inspection, and quick what-if analyses.
It does **not** replace the authoritative R workflow in this repository.

This playground follows **Option 2: explicit case-configuration modeling**. That means the primary relational predictor is the paired victim x negotiator scenario configuration, such as `Hum_x_Hum`, `Hum_x_Ing`, `Hum_x_Control`, `Ing_x_Hum`, `Ing_x_Ing`, or `Ing_x_Control`. Role (`Observer` / `Victim`) and decision context (`Accept` / `Reject`) can further condition those cases.

The Python model here fits a real two-sided censored normal Tobit by maximum likelihood, but it is still lighter than the R production pipeline:

- It does **not** reproduce the R pipeline's participant-cluster robust standard errors.
- It does **not** run the R pipeline's non-parametric CLAD / cluster-bootstrap robustness branch.
- Influence rankings are exploratory and are defined here as the **absolute standardized coefficient magnitude** on the Tobit design matrix.
- The Mahalanobis option is an exploratory row filter on the current model matrix, not an official production exclusion rule.
- Legacy isolated indicators such as `perp_outgroup`, `victim_outgroup`, and `same_group_harm` are still available for comparison, but the playground prioritizes explicit case-configuration factors when the question is relational.
"""


@st.cache_data(show_spinner=False)
def load_bundle():
    bundle = load_playground_dataset(PROJECT_ROOT)
    return bundle.data, bundle.metadata


@st.cache_data(show_spinner=False)
def load_markdown(path: str) -> str:
    return Path(path).read_text(encoding="utf-8")


def apply_filters(
    frame: pd.DataFrame,
    site_choice: str,
    attention_choice: str,
    selected_cases: list[str],
    selected_roles: list[str],
    selected_decisions: list[str],
) -> pd.DataFrame:
    filtered = frame.copy()
    if site_choice == "Florida":
        filtered = filtered[filtered["site"] == "Florida"]
    elif site_choice == "Bucaramanga":
        filtered = filtered[filtered["site"] == "Bucaramanga"]

    if attention_choice == "Keep passers only":
        filtered = filtered[filtered["attention_pass"]]
    elif attention_choice == "Keep non-passers only":
        filtered = filtered[~filtered["attention_pass"]]

    if selected_cases:
        filtered = filtered[filtered["case_configuration"].astype(str).isin(selected_cases)]
    if selected_roles:
        filtered = filtered[filtered["role"].isin(selected_roles)]
    if selected_decisions:
        decision_map = {"Accepted": 1, "Rejected": 0}
        filtered = filtered[filtered["decision_accept"].isin([decision_map[label] for label in selected_decisions])]

    return filtered.reset_index(drop=True)


def render_source_summary(metadata: dict, filtered: pd.DataFrame) -> None:
    row_count = len(filtered)
    participant_count = filtered["participant_key"].nunique()
    sites = ", ".join(f"{site}: {count}" for site, count in metadata.get("sites", {}).items())

    left, middle, right = st.columns(3)
    left.metric("Rows in current filter", f"{row_count:,}")
    middle.metric("Participants in current filter", f"{participant_count:,}")
    right.metric("Available sites", sites or "Unknown")

    with st.expander("Data bridge details", expanded=False):
        st.markdown(
            "\n".join(
                [
                    "- The app prefers participant-level artifacts already produced by the R pipeline.",
                    "- If the latest processed files only cover one site, the loader reconstructs the missing site locally from the raw Excel file using the same scoring and reshaping rules where practical.",
                    "- The local bridge writes nothing into `data/processed/` or the R pipeline folders.",
                ]
            )
        )
        for note in metadata.get("sources", []):
            st.write(f"- {note}")


def main() -> None:
    st.set_page_config(page_title="TOBIT Local Playground", layout="wide")

    st.markdown(
        """
        <style>
        .hero {
            padding: 1.2rem 1.4rem;
            border-radius: 18px;
            background: linear-gradient(135deg, #f4efe6 0%, #dbe8e2 100%);
            border: 1px solid #c5d3cb;
            margin-bottom: 1rem;
        }
        .hero h1 {
            margin: 0;
            color: #1d3b3a;
            font-size: 2rem;
        }
        .hero p {
            margin: 0.4rem 0 0 0;
            color: #334b4a;
        }
        </style>
        <div class="hero">
            <h1>TOBIT Local Playground</h1>
            <p>Exploratory local Tobit interface for the eit/TOBIT project, designed for teaching and quick model iteration around explicit victim x negotiator case configurations without changing the official R workflow.</p>
        </div>
        """,
        unsafe_allow_html=True,
    )
    st.warning(
        "This playground is local and exploratory. Authoritative results, clustered inference, and the production reporting path still live in the R pipeline, which now treats relational case configurations as the primary substantive scenario representation."
    )

    data, metadata = load_bundle()

    st.sidebar.header("Filters")
    site_choice = st.sidebar.radio(
        "Site / location",
        ["Merged (Florida + Bucaramanga)", "Florida", "Bucaramanga"],
        index=0,
    )
    attention_choice = st.sidebar.radio(
        "Attention check filter",
        ["Keep passers only", "Keep all", "Keep non-passers only"],
        index=0,
    )
    st.sidebar.caption("Option 2 prioritizes explicit victim x negotiator case configurations over isolated outgroup indicators.")
    if pd.api.types.is_categorical_dtype(data["case_configuration"]):
        case_options = [value for value in data["case_configuration"].cat.categories.tolist() if pd.notna(value)]
    else:
        case_options = [value for value in data["case_configuration"].dropna().astype(str).unique().tolist() if value != "nan"]
    selected_cases = st.sidebar.multiselect(
        "Case configurations",
        case_options,
        default=case_options,
    )
    selected_roles = st.sidebar.multiselect(
        "Role",
        ["observer", "victim"],
        default=["observer", "victim"],
    )
    selected_decisions = st.sidebar.multiselect(
        "Decision context",
        ["Accepted", "Rejected"],
        default=["Accepted", "Rejected"],
    )

    filtered = apply_filters(
        data,
        site_choice=site_choice,
        attention_choice=attention_choice,
        selected_cases=selected_cases,
        selected_roles=selected_roles,
        selected_decisions=selected_decisions,
    )

    render_source_summary(metadata, filtered)

    if filtered.empty:
        st.error("The current filters leave no rows to analyze.")
        return

    st.sidebar.header("Model setup")
    outcomes = outcome_candidates(filtered)
    default_outcome = outcomes.index("judgement") if "judgement" in outcomes else 0
    outcome = st.sidebar.selectbox("Dependent variable", outcomes, index=default_outcome)
    predictor_choices = predictor_keys()
    st.sidebar.caption(
        "Primary relational terms are `case_configuration`, `case_configuration_role`, `case_configuration_decision`, and `case_configuration_context`."
    )
    selected_predictors = st.sidebar.multiselect(
        "Tobit predictors",
        predictor_choices,
        default=[key for key in DEFAULT_PREDICTORS if key in predictor_choices],
        format_func=format_predictor_option,
    )

    available_interactions = interaction_options(selected_predictors)
    interaction_label_map = {
        f"{predictor_label(left)} x {predictor_label(right)}": (left, right)
        for left, right in available_interactions
    }
    selected_interaction_labels = st.sidebar.multiselect(
        "Optional interaction terms",
        list(interaction_label_map.keys()),
    )
    selected_interactions = [interaction_label_map[label] for label in selected_interaction_labels]

    formula = None
    model_frame = None
    response = None
    design_matrix = None
    prefit_error = None

    if selected_predictors:
        try:
            formula = build_formula(outcome, selected_predictors, selected_interactions)
            model_frame, response, design_matrix = build_model_frame(formula, filtered)
        except ValueError as exc:
            prefit_error = str(exc)

    default_lower = -9.0 if outcome in {"judgement", "condemnation"} else float(filtered[outcome].min())
    default_upper = 9.0 if outcome in {"judgement", "condemnation"} else float(filtered[outcome].max())
    lower_bound = st.sidebar.number_input(
        "Lower censoring bound",
        value=float(default_lower),
        step=0.5,
        key=f"lower_bound_{outcome}",
    )
    upper_bound = st.sidebar.number_input(
        "Upper censoring bound",
        value=float(default_upper),
        step=0.5,
        key=f"upper_bound_{outcome}",
    )

    st.sidebar.header("Exploratory outlier filter")
    st.sidebar.caption(
        "Mahalanobis filtering uses the current model matrix after dummy coding. It is optional and exploratory."
    )
    enable_mahalanobis = st.sidebar.checkbox("Enable Mahalanobis filter", value=False)
    suggested_cutoff = (
        suggested_mahalanobis_cutoff(design_matrix) if design_matrix is not None else 20.0
    )
    mahalanobis_threshold = st.sidebar.number_input(
        "Squared distance cutoff",
        value=float(round(suggested_cutoff, 3)),
        step=0.5,
        disabled=not enable_mahalanobis,
    )

    st.sidebar.caption(
        "Influence ranking uses the absolute standardized coefficient magnitude on the latent Tobit scale."
    )

    tab_model, tab_plots, tab_notes = st.tabs(["Model", "Plots", "Notes"])

    final_frame = filtered.copy()
    fit_result = None
    model_messages: list[str] = []
    dropped_missing = 0
    removed_mahalanobis = 0

    if formula is None:
        prefit_error = "Select at least one predictor to fit the Tobit model."
    elif prefit_error is None and model_frame is not None and response is not None and design_matrix is not None:
        dropped_missing = len(filtered) - len(model_frame)
        if enable_mahalanobis:
            try:
                distances = squared_mahalanobis_distance(design_matrix)
                keep_mask = distances <= mahalanobis_threshold
                removed_mahalanobis = int((~keep_mask).sum())
                model_frame = model_frame.loc[keep_mask].copy()
                final_frame = model_frame
                model_frame, response, design_matrix = build_model_frame(formula, model_frame)
                model_messages.append(
                    f"Mahalanobis filter removed {removed_mahalanobis} row(s) using a squared-distance cutoff of {mahalanobis_threshold:.3f}."
                )
            except ValueError as exc:
                prefit_error = str(exc)

        if prefit_error is None:
            try:
                fit_result = fit_tobit_model(
                    used_data=model_frame,
                    response=response,
                    design_matrix=design_matrix,
                    formula=formula,
                    lower_bound=float(lower_bound),
                    upper_bound=float(upper_bound),
                )
                final_frame = fit_result.used_data.copy()
                model_messages.extend(fit_result.warnings)
            except ValueError as exc:
                prefit_error = str(exc)

    with tab_model:
        st.subheader("Current specification")
        st.code(formula or "Select predictors to assemble a formula.", language="r")

        summary_cols = st.columns(4)
        summary_cols[0].metric("Filtered rows", f"{len(filtered):,}")
        summary_cols[1].metric("Complete rows", f"{len(model_frame):,}" if model_frame is not None else "0")
        summary_cols[2].metric("Dropped for missingness", f"{dropped_missing:,}")
        summary_cols[3].metric("Mahalanobis removed", f"{removed_mahalanobis:,}")

        inspection_df = (
            filtered.groupby(["case_configuration", "role_label", "decision_label"], observed=True)
            .agg(rows=("judgement", "size"), mean_judgement=("judgement", "mean"))
            .reset_index()
        )
        if not inspection_df.empty:
            inspection_df["case_configuration"] = inspection_df["case_configuration"].astype(str).apply(
                lambda value: format_display_value("case_configuration", value)
            )
            inspection_df = inspection_df.rename(
                columns={
                    "case_configuration": "case_configuration",
                    "role_label": "role",
                    "decision_label": "decision_context",
                    "mean_judgement": "mean_judgement",
                }
            )
            with st.expander("Inspect current case configurations", expanded=False):
                st.caption(
                    "This table mirrors the relational scenario grid by listing each victim x negotiator case together with role and Accept/Reject context."
                )
                st.dataframe(inspection_df, use_container_width=True, hide_index=True)

        if outcome not in {"judgement", "condemnation"}:
            st.info(
                f"`{outcome}` is not the canonical bounded judgement outcome from the R workflow. The fit is exploratory, and the chosen censoring bounds should be checked carefully."
            )

        if prefit_error:
            st.error(prefit_error)
        elif fit_result is not None:
            metric_cols = st.columns(6)
            metric_cols[0].metric("Participants", f"{fit_result.used_data['participant_key'].nunique():,}")
            metric_cols[1].metric("Left-censored", f"{fit_result.left_censored:,}")
            metric_cols[2].metric("Right-censored", f"{fit_result.right_censored:,}")
            metric_cols[3].metric("AIC", f"{fit_result.aic:,.2f}")
            metric_cols[4].metric("LogLik", f"{fit_result.log_likelihood:,.2f}")
            metric_cols[5].metric("Sigma", f"{fit_result.sigma:,.3f}")

            st.caption(
                f"Bounds used in this fit: lower = {fit_result.lower_bound:g}, upper = {fit_result.upper_bound:g}. "
                "The coefficient table is on the latent Tobit scale."
            )

            for message in model_messages:
                st.info(message)

            st.markdown("**Coefficient table**")
            st.dataframe(coefficient_table(fit_result), use_container_width=True, hide_index=True)

            st.markdown("**Most influential predictors**")
            st.caption(
                "Influence is ranked by absolute standardized coefficient magnitude. This is a heuristic for teaching and exploration, not a causal importance estimate."
            )
            st.dataframe(
                influence_table(fit_result).head(12),
                use_container_width=True,
                hide_index=True,
            )

    with tab_plots:
        st.caption(
            "Plots use the current filtered dataset. If the Mahalanobis option is enabled and the model fit succeeds, the plots use the same post-filter rows."
        )
        plot_frame = final_frame if not final_frame.empty else filtered

        plot_predictor_options = selected_predictors or predictor_choices
        predictor_for_plot = st.selectbox(
            "Predictor vs outcome plot",
            plot_predictor_options,
            format_func=format_predictor_option,
        )
        try:
            st.plotly_chart(
                predictor_plot(plot_frame, predictor_for_plot, outcome),
                use_container_width=True,
            )
        except ValueError as exc:
            st.error(str(exc))

        st.markdown("**Interaction visualisation**")
        interaction_choices = selected_interactions or list(combinations(plot_predictor_options, 2))
        if not interaction_choices:
            st.info("Select at least two predictors to view an interaction plot.")
        else:
            interaction_selector = {
                f"{predictor_label(left)} x {predictor_label(right)}": (left, right)
                for left, right in interaction_choices
            }
            selected_plot_interaction = st.selectbox(
                "Pair to visualise",
                list(interaction_selector.keys()),
            )
            interaction_pair = interaction_selector[selected_plot_interaction]
            try:
                st.plotly_chart(
                    interaction_plot(plot_frame, interaction_pair[0], interaction_pair[1], outcome),
                    use_container_width=True,
                )
            except ValueError as exc:
                st.error(str(exc))

    with tab_notes:
        st.markdown(LOCAL_NOTE)
        st.markdown(
            "\n".join(
                [
                    "- Option 2 defines each scenario as a victim x negotiator case configuration so relational questions stay interpretable.",
                    "- The `case_configuration_role`, `case_configuration_decision`, and `case_configuration_context` fields expose the role/decision-conditioned scenario grid directly.",
                    "- The Mahalanobis filter computes squared distance on the current model matrix and drops rows above the chosen cutoff.",
                    "- The default cutoff is the 97.5th percentile of a chi-square reference distribution using the number of non-intercept design columns.",
                    "- The playground fits a real censored-regression likelihood, but it does not reproduce the R pipeline's clustered inference stack.",
                ]
            )
        )
        for title, path in DOC_FILES:
            with st.expander(title, expanded=False):
                st.markdown(load_markdown(str(path)))


if __name__ == "__main__":
    main()
