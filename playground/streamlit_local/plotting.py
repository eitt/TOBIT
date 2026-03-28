from __future__ import annotations

import numpy as np
import pandas as pd
import plotly.express as px

from modeling import format_display_value, predictor_kind, predictor_label


def predictor_plot(frame: pd.DataFrame, predictor: str, outcome: str):
    plot_df = frame[[predictor, outcome]].dropna().copy()
    if plot_df.empty:
        raise ValueError("There are no complete rows available for the requested predictor plot.")

    kind = predictor_kind(predictor)
    x_label = predictor_label(predictor)

    if kind == "continuous":
        jitter = np.random.default_rng(42).uniform(-0.15, 0.15, len(plot_df))
        plot_df["outcome_jitter"] = plot_df[outcome] + jitter

        if plot_df[predictor].nunique() > 8:
            bins = min(16, max(6, plot_df[predictor].nunique()))
            plot_df["x_bin"] = pd.qcut(plot_df[predictor], q=bins, duplicates="drop")
            summary = (
                plot_df.groupby("x_bin", observed=True)
                .agg(
                    predictor_mid=(predictor, "mean"),
                    outcome_mean=(outcome, "mean"),
                    count=(outcome, "size"),
                )
                .reset_index(drop=True)
            )
        else:
            summary = (
                plot_df.groupby(predictor, observed=True)
                .agg(
                    predictor_mid=(predictor, "mean"),
                    outcome_mean=(outcome, "mean"),
                    count=(outcome, "size"),
                )
                .reset_index(drop=True)
            )

        fig = px.scatter(
            plot_df,
            x=predictor,
            y="outcome_jitter",
            opacity=0.28,
            labels={predictor: x_label, "outcome_jitter": outcome},
            color_discrete_sequence=["#28536b"],
        )
        fig.add_scatter(
            x=summary["predictor_mid"],
            y=summary["outcome_mean"],
            mode="lines+markers",
            name="Binned mean",
            line={"color": "#c44536", "width": 3},
        )
        fig.update_layout(title=f"{x_label} vs {outcome}")
        return fig

    plot_df["display_value"] = plot_df[predictor].apply(lambda value: format_display_value(predictor, value))
    order = plot_df["display_value"].value_counts().index.tolist()
    fig = px.box(
        plot_df,
        x="display_value",
        y=outcome,
        points="all",
        category_orders={"display_value": order},
        labels={"display_value": x_label, outcome: outcome},
        color_discrete_sequence=["#28536b"],
    )
    fig.update_layout(title=f"{x_label} vs {outcome}", showlegend=False)
    return fig


def interaction_plot(frame: pd.DataFrame, first: str, second: str, outcome: str):
    plot_df = frame[[first, second, outcome]].dropna().copy()
    if plot_df.empty:
        raise ValueError("There are no complete rows available for the requested interaction plot.")

    first_kind = predictor_kind(first)
    second_kind = predictor_kind(second)
    first_label = predictor_label(first)
    second_label = predictor_label(second)

    if first_kind == "continuous" and second_kind == "continuous":
        plot_df["first_bin"] = pd.qcut(plot_df[first], q=min(12, max(5, plot_df[first].nunique())), duplicates="drop")
        plot_df["second_bin"] = pd.qcut(plot_df[second], q=min(12, max(5, plot_df[second].nunique())), duplicates="drop")
        heat = (
            plot_df.groupby(["first_bin", "second_bin"], observed=True)[outcome]
            .mean()
            .reset_index()
        )
        heat["first_bin"] = heat["first_bin"].astype(str)
        heat["second_bin"] = heat["second_bin"].astype(str)
        fig = px.density_heatmap(
            heat,
            x="first_bin",
            y="second_bin",
            z=outcome,
            histfunc="avg",
            color_continuous_scale="Tealgrn",
            labels={"first_bin": first_label, "second_bin": second_label, outcome: f"Mean {outcome}"},
        )
        fig.update_layout(title=f"{first_label} x {second_label}")
        return fig

    if first_kind == "continuous" and second_kind != "continuous":
        continuous, categorical = first, second
    elif second_kind == "continuous" and first_kind != "continuous":
        continuous, categorical = second, first
    else:
        continuous, categorical = None, None

    if continuous is not None:
        line_df = plot_df[[continuous, categorical, outcome]].copy()
        line_df["group"] = line_df[categorical].apply(lambda value: format_display_value(categorical, value))
        bins = min(12, max(5, line_df[continuous].nunique()))
        line_df["x_bin"] = pd.qcut(line_df[continuous], q=bins, duplicates="drop")
        summary = (
            line_df.groupby(["x_bin", "group"], observed=True)
            .agg(x_mid=(continuous, "mean"), outcome_mean=(outcome, "mean"), count=(outcome, "size"))
            .reset_index()
        )
        fig = px.line(
            summary,
            x="x_mid",
            y="outcome_mean",
            color="group",
            markers=True,
            labels={"x_mid": predictor_label(continuous), "outcome_mean": f"Mean {outcome}", "group": predictor_label(categorical)},
            color_discrete_sequence=["#28536b", "#c44536", "#49796b", "#7a5c61"],
        )
        fig.update_layout(title=f"{predictor_label(continuous)} x {predictor_label(categorical)}")
        return fig

    heat_df = plot_df.copy()
    heat_df["first_group"] = heat_df[first].apply(lambda value: format_display_value(first, value))
    heat_df["second_group"] = heat_df[second].apply(lambda value: format_display_value(second, value))
    summary = (
        heat_df.groupby(["first_group", "second_group"], observed=True)[outcome]
        .mean()
        .reset_index()
    )
    fig = px.density_heatmap(
        summary,
        x="first_group",
        y="second_group",
        z=outcome,
        histfunc="avg",
        color_continuous_scale="Tealgrn",
        labels={"first_group": first_label, "second_group": second_label, outcome: f"Mean {outcome}"},
    )
    fig.update_layout(title=f"{first_label} x {second_label}")
    return fig
