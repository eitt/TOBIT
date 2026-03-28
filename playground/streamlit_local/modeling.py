from __future__ import annotations

from dataclasses import dataclass, field
import itertools
import math
import re

import numpy as np
import pandas as pd
from patsy import PatsyError, dmatrices
from scipy.optimize import minimize
from scipy.stats import chi2, norm


@dataclass(frozen=True)
class VariableSpec:
    key: str
    label: str
    kind: str
    formula_term: str
    help_text: str = ""


CASE_CONFIGURATION_LABELS = {
    "Hum_x_Hum": "Humanities victim x Humanities negotiator",
    "Hum_x_Ing": "Humanities victim x Engineering negotiator",
    "Hum_x_Control": "Humanities victim x Control negotiator",
    "Ing_x_Hum": "Engineering victim x Humanities negotiator",
    "Ing_x_Ing": "Engineering victim x Engineering negotiator",
    "Ing_x_Control": "Engineering victim x Control negotiator",
}


def format_case_configuration(value: str) -> str:
    return CASE_CONFIGURATION_LABELS.get(value, str(value))


def format_case_context_value(value: str) -> str:
    text = str(value)
    parts = text.split("__")
    if len(parts) == 1:
        return format_case_configuration(parts[0])
    if len(parts) == 2:
        return f"{format_case_configuration(parts[0])} ({parts[1]})"
    if len(parts) == 3:
        return f"{format_case_configuration(parts[0])} ({parts[1]}, {parts[2]})"
    return text


PREDICTOR_SPECS: dict[str, VariableSpec] = {
    "iri_total": VariableSpec("iri_total", "Empathy composite (average)", "continuous", "iri_total"),
    "iri_fs": VariableSpec("iri_fs", "Empathy: Fantasy scale", "continuous", "iri_fs"),
    "iri_ec": VariableSpec("iri_ec", "Empathy: Empathic concern", "continuous", "iri_ec"),
    "iri_pt": VariableSpec("iri_pt", "Empathy: Perspective taking", "continuous", "iri_pt"),
    "iri_pd": VariableSpec("iri_pd", "Empathy: Personal distress", "continuous", "iri_pd"),
    "case_configuration": VariableSpec(
        "case_configuration",
        "Case configuration (victim x negotiator)",
        "categorical",
        "C(case_configuration)",
        "Option 2 primary relational factor built from the paired victim and negotiator labels.",
    ),
    "case_configuration_role": VariableSpec(
        "case_configuration_role",
        "Case configuration x role",
        "categorical",
        "C(case_configuration_role)",
        "Relational case configuration further conditioned by Observer versus Victim judgments.",
    ),
    "case_configuration_decision": VariableSpec(
        "case_configuration_decision",
        "Case configuration x decision context",
        "categorical",
        "C(case_configuration_decision)",
        "Relational case configuration further conditioned by Accept versus Reject decisions.",
    ),
    "case_configuration_context": VariableSpec(
        "case_configuration_context",
        "Case configuration x role x decision",
        "categorical",
        "C(case_configuration_context)",
        "Full relational scenario context combining victim x negotiator pairing, role, and decision context.",
    ),
    "perp_outgroup": VariableSpec(
        "perp_outgroup",
        "Legacy isolated indicator: outgroup negotiator (1 = outgroup)",
        "binary",
        "perp_outgroup",
    ),
    "perp_control": VariableSpec(
        "perp_control",
        "Legacy isolated indicator: hidden-label control (1 = control)",
        "binary",
        "perp_control",
    ),
    "victim_outgroup": VariableSpec(
        "victim_outgroup",
        "Legacy isolated indicator: victim outgroup (1 = outgroup)",
        "binary",
        "victim_outgroup",
    ),
    "same_group_harm": VariableSpec(
        "same_group_harm",
        "Legacy isolated indicator: negotiator and victim share faculty",
        "binary",
        "same_group_harm",
    ),
    "decision_accept": VariableSpec(
        "decision_accept",
        "Negotiator accepted harmful deal",
        "binary",
        "decision_accept",
    ),
    "role_observer": VariableSpec(
        "role_observer",
        "Observer role (ref = victim)",
        "binary",
        "role_observer",
    ),
    "participant_engineering": VariableSpec(
        "participant_engineering",
        "Engineering participant (ref = humanities)",
        "binary",
        "participant_engineering",
    ),
    "sex_man": VariableSpec(
        "sex_man",
        "Man (ref = woman / other)",
        "binary",
        "sex_man",
    ),
    "age": VariableSpec("age", "Age", "continuous", "age"),
    "economic_status": VariableSpec(
        "economic_status",
        "Socioeconomic status",
        "continuous",
        "economic_status",
    ),
    "treatment": VariableSpec(
        "treatment",
        "Treatment order",
        "categorical",
        "C(treatment)",
    ),
    "stage": VariableSpec("stage", "Stage", "categorical", "C(stage)"),
    "negotiator_slot": VariableSpec(
        "negotiator_slot",
        "Negotiator slot",
        "categorical",
        "C(negotiator_slot)",
    ),
}

DISPLAY_LABELS = {key: spec.label for key, spec in PREDICTOR_SPECS.items()}

NON_OUTCOME_NUMERIC_EXCLUSIONS = {
    "id",
    "participant_key",
    "attention_pass",
    "analysis_include",
    "valid_treatment",
}

VALUE_LABELS = {
    "case_configuration": CASE_CONFIGURATION_LABELS,
    "perp_outgroup": {0: "Ingroup", 1: "Outgroup"},
    "perp_control": {0: "Shown", 1: "Hidden / control"},
    "victim_outgroup": {0: "Victim ingroup", 1: "Victim outgroup"},
    "same_group_harm": {0: "Cross-faculty harm", 1: "Same-faculty harm"},
    "decision_accept": {0: "Rejected", 1: "Accepted"},
    "role_observer": {0: "Victim", 1: "Observer"},
    "participant_engineering": {0: "Humanities", 1: "Engineering"},
    "sex_man": {0: "Woman / other", 1: "Man"},
    "treatment": {1: "Victim first", 2: "Observer first"},
    "negotiator_slot": {1: "Negotiator 1", 2: "Negotiator 2"},
}


@dataclass
class TobitFitResult:
    formula: str
    outcome: str
    lower_bound: float
    upper_bound: float
    converged: bool
    iterations: int
    log_likelihood: float
    aic: float
    sigma: float
    coefficients: pd.Series
    standard_errors: pd.Series
    z_values: pd.Series
    p_values: pd.Series
    conf_low: pd.Series
    conf_high: pd.Series
    latent_mean: pd.Series
    expected_observed: pd.Series
    design_matrix: pd.DataFrame
    response: pd.Series
    used_data: pd.DataFrame
    left_censored: int
    right_censored: int
    warnings: list[str] = field(default_factory=list)


def predictor_keys() -> list[str]:
    return list(PREDICTOR_SPECS.keys())


def predictor_label(key: str) -> str:
    return PREDICTOR_SPECS[key].label


def predictor_kind(key: str) -> str:
    return PREDICTOR_SPECS[key].kind


def format_predictor_option(key: str) -> str:
    spec = PREDICTOR_SPECS[key]
    return f"{spec.label} [{spec.key}]"


def outcome_candidates(frame: pd.DataFrame) -> list[str]:
    numeric_columns = [
        column
        for column in frame.columns
        if pd.api.types.is_numeric_dtype(frame[column]) and column not in NON_OUTCOME_NUMERIC_EXCLUSIONS
    ]
    numeric_columns = sorted(dict.fromkeys(numeric_columns))
    if "judgement" in numeric_columns:
        numeric_columns.insert(0, numeric_columns.pop(numeric_columns.index("judgement")))
    return numeric_columns


def interaction_options(selected_predictors: list[str]) -> list[tuple[str, str]]:
    return list(itertools.combinations(selected_predictors, 2))


def canonical_pair(pair: tuple[str, str]) -> tuple[str, str]:
    left, right = pair
    return tuple(sorted((left, right)))


def build_formula(
    outcome: str,
    selected_predictors: list[str],
    interaction_pairs: list[tuple[str, str]],
) -> str:
    if not selected_predictors:
        raise ValueError("Select at least one predictor before fitting a Tobit model.")

    seen_terms: set[str] = set()
    rhs_terms: list[str] = []
    for predictor in selected_predictors:
        term = PREDICTOR_SPECS[predictor].formula_term
        if term not in seen_terms:
            rhs_terms.append(term)
            seen_terms.add(term)

    for left, right in sorted({canonical_pair(pair) for pair in interaction_pairs}):
        if left == right:
            continue
        interaction_term = (
            f"{PREDICTOR_SPECS[left].formula_term}:{PREDICTOR_SPECS[right].formula_term}"
        )
        if interaction_term not in seen_terms:
            rhs_terms.append(interaction_term)
            seen_terms.add(interaction_term)

    return f"{outcome} ~ {' + '.join(rhs_terms)}"


def build_model_frame(formula: str, frame: pd.DataFrame) -> tuple[pd.DataFrame, pd.Series, pd.DataFrame]:
    try:
        y_matrix, x_matrix = dmatrices(formula, frame, return_type="dataframe", NA_action="drop")
    except PatsyError as exc:
        raise ValueError(f"Unable to build a valid formula from the current selection: {exc}") from exc

    if x_matrix.empty:
        raise ValueError("The current specification produced an empty design matrix.")
    if x_matrix.shape[1] > 60:
        raise ValueError(
            "This specification expands to more than 60 design columns. Trim predictors or interactions for the local playground."
        )
    if np.linalg.matrix_rank(x_matrix.to_numpy()) < x_matrix.shape[1]:
        raise ValueError(
            "The selected predictors create a rank-deficient design matrix. Remove overlapping terms and try again."
        )

    used_data = frame.loc[x_matrix.index].copy()
    response = y_matrix.iloc[:, 0].astype(float)
    return used_data, response, x_matrix.astype(float)


def suggested_mahalanobis_cutoff(design_matrix: pd.DataFrame, quantile: float = 0.975) -> float:
    degrees = max(1, design_matrix.shape[1] - 1)
    return float(chi2.ppf(quantile, df=degrees))


def squared_mahalanobis_distance(design_matrix: pd.DataFrame) -> pd.Series:
    matrix = design_matrix.drop(columns=["Intercept"], errors="ignore").to_numpy(dtype=float)
    if matrix.shape[1] == 0:
        raise ValueError("Mahalanobis filtering needs at least one non-intercept design column.")
    if matrix.shape[0] <= matrix.shape[1]:
        raise ValueError("Mahalanobis filtering needs more rows than design columns.")

    centered = matrix - matrix.mean(axis=0, keepdims=True)
    covariance = np.cov(centered, rowvar=False)
    if np.ndim(covariance) == 0:
        covariance = np.array([[float(covariance)]])
    covariance = np.atleast_2d(covariance)
    ridge = 1e-8 * np.eye(covariance.shape[0])
    inverse = np.linalg.pinv(covariance + ridge)
    distances = np.einsum("ij,jk,ik->i", centered, inverse, centered)
    return pd.Series(distances, index=design_matrix.index, name="mahalanobis_d2")


def _negative_log_likelihood(
    params: np.ndarray,
    design: np.ndarray,
    response: np.ndarray,
    lower: float,
    upper: float,
) -> float:
    beta = params[:-1]
    log_sigma = params[-1]
    sigma = math.exp(log_sigma)
    if not np.isfinite(sigma) or sigma <= 0:
        return np.inf

    mu = design @ beta
    left_mask = response <= lower
    right_mask = response >= upper
    exact_mask = ~(left_mask | right_mask)

    loglike = np.zeros_like(response, dtype=float)
    if exact_mask.any():
        loglike[exact_mask] = norm.logpdf(response[exact_mask], loc=mu[exact_mask], scale=sigma)
    if left_mask.any():
        loglike[left_mask] = norm.logcdf(lower, loc=mu[left_mask], scale=sigma)
    if right_mask.any():
        loglike[right_mask] = norm.logsf(upper, loc=mu[right_mask], scale=sigma)

    if np.any(~np.isfinite(loglike)):
        return np.inf
    return float(-np.sum(loglike))


def _approximate_hessian(function, point: np.ndarray, step: float = 1e-4) -> np.ndarray:
    size = len(point)
    hessian = np.zeros((size, size), dtype=float)
    f0 = function(point)

    for i in range(size):
        step_i = step * (abs(point[i]) + 1.0)
        point_plus = point.copy()
        point_minus = point.copy()
        point_plus[i] += step_i
        point_minus[i] -= step_i
        f_plus = function(point_plus)
        f_minus = function(point_minus)
        hessian[i, i] = (f_plus - 2 * f0 + f_minus) / (step_i ** 2)

        for j in range(i + 1, size):
            step_j = step * (abs(point[j]) + 1.0)
            pp = point.copy()
            pm = point.copy()
            mp = point.copy()
            mm = point.copy()
            pp[i] += step_i
            pp[j] += step_j
            pm[i] += step_i
            pm[j] -= step_j
            mp[i] -= step_i
            mp[j] += step_j
            mm[i] -= step_i
            mm[j] -= step_j
            value = (function(pp) - function(pm) - function(mp) + function(mm)) / (4 * step_i * step_j)
            hessian[i, j] = value
            hessian[j, i] = value

    return hessian


def _expected_observed_value(mu: np.ndarray, sigma: float, lower: float, upper: float) -> np.ndarray:
    a = (lower - mu) / sigma
    b = (upper - mu) / sigma
    cdf_a = norm.cdf(a)
    cdf_b = norm.cdf(b)
    pdf_a = norm.pdf(a)
    pdf_b = norm.pdf(b)
    return lower * cdf_a + mu * (cdf_b - cdf_a) + sigma * (pdf_a - pdf_b) + upper * (1 - cdf_b)


def fit_tobit_model(
    used_data: pd.DataFrame,
    response: pd.Series,
    design_matrix: pd.DataFrame,
    formula: str,
    lower_bound: float,
    upper_bound: float,
) -> TobitFitResult:
    if not np.isfinite(lower_bound) or not np.isfinite(upper_bound) or lower_bound >= upper_bound:
        raise ValueError("Censoring bounds must be finite, and the lower bound must be smaller than the upper bound.")

    y = response.to_numpy(dtype=float)
    if np.nanmin(y) < lower_bound - 1e-9 or np.nanmax(y) > upper_bound + 1e-9:
        raise ValueError(
            "The current censoring bounds do not cover the observed outcome range in the filtered data."
        )
    if np.nanstd(y, ddof=1) == 0:
        raise ValueError("The selected dependent variable is constant after filtering, so a Tobit model cannot be estimated.")

    x = design_matrix.to_numpy(dtype=float)
    if len(y) <= x.shape[1] + 2:
        raise ValueError("There are too few complete observations for the selected specification.")

    ols_beta, *_ = np.linalg.lstsq(x, y, rcond=None)
    residuals = y - x @ ols_beta
    sigma_start = max(float(np.std(residuals, ddof=1)), 1e-2)
    initial = np.concatenate([ols_beta, [math.log(sigma_start)]])

    objective = lambda params: _negative_log_likelihood(params, x, y, lower_bound, upper_bound)

    result = minimize(
        objective,
        initial,
        method="BFGS",
        options={"maxiter": 1000, "gtol": 1e-5},
    )
    if not result.success:
        result = minimize(
            objective,
            initial,
            method="L-BFGS-B",
            bounds=[(None, None)] * x.shape[1] + [(math.log(1e-6), None)],
            options={"maxiter": 1000},
        )

    if not result.success:
        raise ValueError(f"The Tobit optimizer did not converge: {result.message}")

    optimum = result.x
    beta = optimum[:-1]
    sigma = math.exp(optimum[-1])
    hessian = _approximate_hessian(objective, optimum)
    covariance = np.linalg.pinv(hessian)
    standard_errors_all = np.sqrt(np.clip(np.diag(covariance), a_min=0, a_max=None))

    coefficient_index = design_matrix.columns
    coefficients = pd.Series(beta, index=coefficient_index, name="estimate")
    standard_errors = pd.Series(standard_errors_all[:-1], index=coefficient_index, name="std_error")
    z_values = coefficients / standard_errors.replace(0, np.nan)
    p_values = 2 * norm.sf(np.abs(z_values))
    conf_low = coefficients - 1.96 * standard_errors
    conf_high = coefficients + 1.96 * standard_errors

    mu = x @ beta
    warnings: list[str] = []
    if len(y) < 8 * x.shape[1]:
        warnings.append(
            "The model has relatively few complete observations per parameter. Treat estimates as exploratory."
        )

    return TobitFitResult(
        formula=formula,
        outcome=response.name or "outcome",
        lower_bound=lower_bound,
        upper_bound=upper_bound,
        converged=bool(result.success),
        iterations=int(getattr(result, "nit", 0) or 0),
        log_likelihood=float(-objective(optimum)),
        aic=float(2 * len(optimum) - 2 * (-objective(optimum))),
        sigma=sigma,
        coefficients=coefficients,
        standard_errors=standard_errors,
        z_values=z_values,
        p_values=pd.Series(p_values, index=coefficient_index, name="p_value"),
        conf_low=conf_low,
        conf_high=conf_high,
        latent_mean=pd.Series(mu, index=design_matrix.index, name="latent_mean"),
        expected_observed=pd.Series(
            _expected_observed_value(mu, sigma, lower_bound, upper_bound),
            index=design_matrix.index,
            name="expected_observed",
        ),
        design_matrix=design_matrix,
        response=response,
        used_data=used_data,
        left_censored=int((y <= lower_bound).sum()),
        right_censored=int((y >= upper_bound).sum()),
        warnings=warnings,
    )


def prettify_term(term: str) -> str:
    if term == "Intercept":
        return "Intercept"

    parts = term.split(":")
    return " x ".join(_prettify_single_part(part) for part in parts)


def _prettify_single_part(part: str) -> str:
    match = re.match(r"C\((?P<name>[^)]+)\)\[T\.(?P<level>.+)\]", part)
    if match:
        name = match.group("name")
        level = match.group("level")
        if name == "stage":
            return f"Stage {level} vs ref"
        if name == "negotiator_slot":
            return f"Negotiator {level} vs ref"
        if name == "treatment":
            return f"Treatment {level} vs ref"
        return f"{DISPLAY_LABELS.get(name, name)}: {format_display_value(name, level)} vs ref"
    return DISPLAY_LABELS.get(part, part)


def coefficient_table(result: TobitFitResult) -> pd.DataFrame:
    table = pd.DataFrame(
        {
            "term": result.coefficients.index,
            "label": [prettify_term(term) for term in result.coefficients.index],
            "estimate": result.coefficients.values,
            "std_error": result.standard_errors.values,
            "z_value": result.z_values.values,
            "p_value": result.p_values.values,
            "conf_low": result.conf_low.values,
            "conf_high": result.conf_high.values,
        }
    )
    return table


def influence_table(result: TobitFitResult) -> pd.DataFrame:
    y_sd = float(result.response.std(ddof=1))
    rows: list[dict[str, float | str]] = []

    for column in result.design_matrix.columns:
        if column == "Intercept":
            continue
        x_sd = float(result.design_matrix[column].std(ddof=1))
        estimate = float(result.coefficients[column])
        if not np.isfinite(x_sd) or x_sd == 0 or not np.isfinite(y_sd) or y_sd == 0:
            score = abs(estimate)
        else:
            score = abs(estimate) * x_sd / y_sd
        rows.append(
            {
                "term": column,
                "label": prettify_term(column),
                "estimate": estimate,
                "influence_score": score,
                "abs_z_value": abs(float(result.z_values[column])) if np.isfinite(result.z_values[column]) else np.nan,
            }
        )

    influence = pd.DataFrame(rows).sort_values(
        ["influence_score", "abs_z_value"],
        ascending=[False, False],
    )
    influence["rank"] = np.arange(1, len(influence) + 1)
    return influence[["rank", "label", "influence_score", "estimate", "abs_z_value"]]


def format_display_value(variable: str, value: float | int | str) -> str:
    mapping = VALUE_LABELS.get(variable)
    if pd.isna(value):
        return "Missing"
    if variable == "case_configuration":
        return format_case_configuration(str(value))
    if variable in {"case_configuration_role", "case_configuration_decision", "case_configuration_context"}:
        return format_case_context_value(str(value))
    if mapping is None:
        return str(value)
    try:
        numeric_value = int(float(value))
    except (TypeError, ValueError):
        return mapping.get(str(value), str(value))
    return mapping.get(numeric_value, mapping.get(str(value), str(value)))


def format_binary_value(variable: str, value: float | int | str) -> str:
    return format_display_value(variable, value)
