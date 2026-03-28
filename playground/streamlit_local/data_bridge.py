from __future__ import annotations

from dataclasses import dataclass
import json
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd


IRI_SCALES = {
    "iri_fs": ["FS1", "FS5", "FS7", "FS12", "FS16", "FS20", "FS25"],
    "iri_ec": ["EC2", "EC4", "EC9", "EC14", "EC17", "EC19", "EC24", "EC28"],
    "iri_pt": ["PT3", "PT8", "PT11", "PT15", "PT21", "PT23", "PT26"],
    "iri_pd": ["PD6", "PD10", "PD13", "PD18", "PD22", "PD27"],
}

CASE_CONFIGURATION_LEVELS = [
    "Hum_x_Hum",
    "Hum_x_Ing",
    "Hum_x_Control",
    "Ing_x_Hum",
    "Ing_x_Ing",
    "Ing_x_Control",
]

RAW_SITE_FILES = {
    "Florida": Path("data/raw/data_final_FLORIDA.xlsx"),
    "Bucaramanga": Path("data/raw/data_final_BUC.xlsx"),
}

PROCESSED_PARTICIPANT_FILES = [
    Path("data/processed/participants_scored.csv"),
    Path("data/processed/03_transformed_participants.csv"),
]

BASE_REQUIRED_COLUMNS = {
    "id",
    "age",
    "economic_status",
    "sex",
    "faculty_player",
    "ac1",
    "ac2",
    "treatment",
    "campus",
}

SCENARIO_COLUMNS = [
    column
    for stage in range(1, 11)
    for column in (
        f"faculty_neg_1_s{stage}",
        f"faculty_neg_2_s{stage}",
        f"faculty_victim_s{stage}",
        f"decision_neg1_s{stage}",
        f"decision_neg2_s{stage}",
        f"judgement_compare_s{stage}",
        f"judgement_n1_s{stage}",
        f"judgement_n2_s{stage}",
    )
]

NUMERIC_COLUMNS = list(
    {
        "id",
        "age",
        "economic_status",
        "sex",
        "faculty_player",
        "ac1",
        "ac2",
        "treatment",
        *SCENARIO_COLUMNS,
        *[item for items in IRI_SCALES.values() for item in items],
    }
)


@dataclass
class DatasetBundle:
    data: pd.DataFrame
    metadata: dict[str, Any]


def row_mean_with_floor(
    frame: pd.DataFrame,
    columns: list[str],
    min_non_missing: int,
) -> pd.Series:
    available = frame[columns].notna().sum(axis=1)
    values = frame[columns].mean(axis=1, skipna=True)
    return values.where(available >= min_non_missing, np.nan)


def normalize_site_name(value: Any) -> str | None:
    if pd.isna(value):
        return None
    text = str(value).strip().lower()
    if text in {"floridablanca", "florida"}:
        return "Florida"
    if text in {"bucaramanga", "buc"}:
        return "Bucaramanga"
    return str(value).strip()


def coerce_bool(series: pd.Series) -> pd.Series:
    if pd.api.types.is_bool_dtype(series):
        return series.fillna(False)
    text = series.astype(str).str.strip().str.lower()
    return text.isin({"true", "1", "1.0", "yes"})


def faculty_case_label(value: Any, allow_control: bool = False) -> str | None:
    if pd.isna(value):
        return None
    numeric = int(value)
    if numeric == 1:
        return "Hum"
    if numeric == 2:
        return "Ing"
    if allow_control and numeric == 3:
        return "Control"
    return None


def build_case_configuration(victim_faculty: Any, negotiator_faculty: Any) -> str | None:
    victim_label = faculty_case_label(victim_faculty, allow_control=False)
    negotiator_label = faculty_case_label(negotiator_faculty, allow_control=True)
    if victim_label is None or negotiator_label is None:
        return None
    return f"{victim_label}_x_{negotiator_label}"


def case_configuration_dummy_name(case_label: str) -> str:
    return "case_" + "".join(character if character.isalnum() else "_" for character in case_label.lower()).strip("_")


def has_required_inputs(frame: pd.DataFrame) -> bool:
    needed = BASE_REQUIRED_COLUMNS.union(SCENARIO_COLUMNS)
    return needed.issubset(frame.columns)


def prepare_participant_frame(
    frame: pd.DataFrame,
    source_label: str,
    site_hint: str | None = None,
) -> pd.DataFrame:
    if not has_required_inputs(frame):
        missing = sorted(BASE_REQUIRED_COLUMNS.union(SCENARIO_COLUMNS) - set(frame.columns))
        raise ValueError(f"Participant frame is missing required columns: {', '.join(missing[:12])}")

    df = frame.copy()
    for column in NUMERIC_COLUMNS:
        if column in df.columns:
            df[column] = pd.to_numeric(df[column], errors="coerce")

    campus = df["campus"] if "campus" in df.columns else pd.Series(site_hint, index=df.index)
    if campus.isna().all() and site_hint is not None:
        campus = pd.Series(site_hint, index=df.index)
    site = campus.map(normalize_site_name)
    if site_hint is not None:
        site = site.fillna(site_hint)

    if "attention_pass" not in df.columns:
        attention_pass = df["ac1"].eq(1) & df["ac2"].eq(1)
    else:
        attention_pass = coerce_bool(df["attention_pass"])

    if "valid_treatment" not in df.columns:
        valid_treatment = df["treatment"].isin([1, 2])
    else:
        valid_treatment = coerce_bool(df["valid_treatment"])

    iri_items = [item for items in IRI_SCALES.values() for item in items]
    if "iri_total" not in df.columns or df["iri_total"].isna().all():
        iri_total = row_mean_with_floor(
            df,
            iri_items,
            min_non_missing=int(np.ceil(len(iri_items) * 0.8)),
        )
    else:
        iri_total = df["iri_total"]

    new_columns: dict[str, pd.Series | str] = {
        "campus": campus,
        "site": site,
        "attention_pass": attention_pass,
        "valid_treatment": valid_treatment,
        "iri_total": iri_total,
    }
    for scale_name, scale_items in IRI_SCALES.items():
        if scale_name not in df.columns or df[scale_name].isna().all():
            new_columns[scale_name] = row_mean_with_floor(
                df,
                scale_items,
                min_non_missing=max(1, int(np.floor(len(scale_items) * 0.75))),
            )
        else:
            new_columns[scale_name] = df[scale_name]

    if "analysis_include" not in df.columns:
        analysis_include = attention_pass & iri_total.notna() & valid_treatment
    else:
        existing = coerce_bool(df["analysis_include"])
        rebuilt = attention_pass & iri_total.notna() & valid_treatment
        analysis_include = existing | rebuilt

    new_columns["analysis_include"] = analysis_include
    new_columns["participant_source"] = source_label
    new_columns["participant_key"] = site.fillna("Unknown").astype(str) + ":" + df["id"].astype("Int64").astype(str)
    return df.assign(**new_columns).copy()


def reshape_participants_to_long(participants: pd.DataFrame) -> pd.DataFrame:
    long_rows: list[dict[str, Any]] = []
    records = participants.to_dict(orient="records")

    for row in records:
        treatment = row.get("treatment")
        participant_faculty = row.get("faculty_player")
        site = row.get("site")

        for stage in range(1, 11):
            if treatment == 1:
                role_numeric = 2 if stage <= 5 else 1
            elif treatment == 2:
                role_numeric = 1 if stage <= 5 else 2
            else:
                role_numeric = np.nan

            if pd.isna(role_numeric):
                role = None
            else:
                role = "victim" if int(role_numeric) == 2 else "observer"

            for slot in (1, 2):
                negotiator_col = f"faculty_neg_{slot}_s{stage}"
                victim_col = f"faculty_victim_s{stage}"
                decision_col = f"decision_neg{slot}_s{stage}"
                judgement_col = f"judgement_n{slot}_s{stage}"

                neg_faculty = row.get(negotiator_col)
                victim_faculty = row.get(victim_col)
                judgement = row.get(judgement_col)
                case_configuration = build_case_configuration(victim_faculty, neg_faculty)
                decision_value = row.get(decision_col)
                decision_label = None
                if pd.notna(decision_value):
                    decision_label = "Accept" if int(decision_value) == 1 else "Reject"
                role_label = role.title() if role is not None else None

                if pd.isna(neg_faculty):
                    negotiator_alignment = None
                elif neg_faculty == 3:
                    negotiator_alignment = "control"
                elif neg_faculty == participant_faculty:
                    negotiator_alignment = "ingroup"
                else:
                    negotiator_alignment = "outgroup"

                if pd.isna(neg_faculty) or neg_faculty == 3 or pd.isna(victim_faculty):
                    same_group_harm = np.nan
                else:
                    same_group_harm = int(neg_faculty == victim_faculty)

                long_rows.append(
                    {
                        "participant_key": row["participant_key"],
                        "participant_source": row["participant_source"],
                        "site": site,
                        "campus": row.get("campus"),
                        "id": row.get("id"),
                        "stage": stage,
                        "negotiator_slot": slot,
                        "role": role,
                        "role_observer": int(role == "observer") if role is not None else np.nan,
                        "age": row.get("age"),
                        "economic_status": row.get("economic_status"),
                        "sex": row.get("sex"),
                        "sex_man": int(row.get("sex") == 2) if pd.notna(row.get("sex")) else np.nan,
                        "participant_faculty": participant_faculty,
                        "participant_engineering": (
                            int(participant_faculty == 2) if pd.notna(participant_faculty) else np.nan
                        ),
                        "treatment": treatment,
                        "role_label": role_label,
                        "attention_pass": bool(row.get("attention_pass", False)),
                        "valid_treatment": bool(row.get("valid_treatment", False)),
                        "analysis_include": bool(row.get("analysis_include", False)),
                        "iri_total": row.get("iri_total"),
                        "iri_fs": row.get("iri_fs"),
                        "iri_ec": row.get("iri_ec"),
                        "iri_pt": row.get("iri_pt"),
                        "iri_pd": row.get("iri_pd"),
                        "faculty_negotiator": neg_faculty,
                        "faculty_victim": victim_faculty,
                        "negotiator_alignment": negotiator_alignment,
                        "perp_outgroup": (
                            int(negotiator_alignment == "outgroup")
                            if negotiator_alignment is not None
                            else np.nan
                        ),
                        "perp_control": (
                            int(negotiator_alignment == "control")
                            if negotiator_alignment is not None
                            else np.nan
                        ),
                        "victim_outgroup": (
                            int(victim_faculty != participant_faculty)
                            if pd.notna(victim_faculty) and pd.notna(participant_faculty)
                            else np.nan
                        ),
                        "same_group_harm": same_group_harm,
                        "decision_accept": decision_value,
                        "decision_label": decision_label,
                        "case_configuration": case_configuration,
                        "case_configuration_role": (
                            f"{case_configuration}__{role_label}"
                            if case_configuration is not None and role_label is not None
                            else None
                        ),
                        "case_configuration_decision": (
                            f"{case_configuration}__{decision_label}"
                            if case_configuration is not None and decision_label is not None
                            else None
                        ),
                        "case_configuration_context": (
                            f"{case_configuration}__{role_label}__{decision_label}"
                            if case_configuration is not None and role_label is not None and decision_label is not None
                            else None
                        ),
                        "judgement": judgement,
                        "condemnation": -judgement if pd.notna(judgement) else np.nan,
                    }
                )

    long_df = pd.DataFrame(long_rows)
    if not long_df.empty:
        long_df["case_configuration"] = pd.Categorical(
            long_df["case_configuration"],
            categories=CASE_CONFIGURATION_LEVELS,
            ordered=True,
        )
        for case_label in CASE_CONFIGURATION_LEVELS:
            long_df[case_configuration_dummy_name(case_label)] = (
                long_df["case_configuration"].astype(str).eq(case_label).astype(int)
            )
    long_df = long_df.sort_values(["site", "id", "stage", "negotiator_slot"]).reset_index(drop=True)
    return long_df


def load_processed_participants(project_root: Path) -> tuple[pd.DataFrame | None, str | None]:
    for relative_path in PROCESSED_PARTICIPANT_FILES:
        path = project_root / relative_path
        if not path.exists():
            continue

        frame = pd.read_csv(path)
        if not has_required_inputs(frame):
            continue

        prepared = prepare_participant_frame(
            frame,
            source_label=f"processed:{relative_path.as_posix()}",
        )
        return prepared, relative_path.as_posix()

    return None, None


def load_missing_sites_from_raw(
    project_root: Path,
    present_sites: set[str],
) -> tuple[list[pd.DataFrame], list[str]]:
    frames: list[pd.DataFrame] = []
    notes: list[str] = []

    for site, relative_path in RAW_SITE_FILES.items():
        if site in present_sites:
            continue

        path = project_root / relative_path
        if not path.exists():
            continue

        frame = pd.read_excel(path)
        frame["campus"] = site
        prepared = prepare_participant_frame(
            frame,
            source_label=f"raw-fallback:{relative_path.as_posix()}",
            site_hint=site,
        )
        frames.append(prepared)
        notes.append(relative_path.as_posix())

    return frames, notes


def load_playground_dataset(project_root: Path) -> DatasetBundle:
    participants_frames: list[pd.DataFrame] = []
    source_notes: list[str] = []

    processed_frame, processed_note = load_processed_participants(project_root)
    present_sites: set[str] = set()

    if processed_frame is not None:
        participants_frames.append(processed_frame)
        source_notes.append(f"Processed participant artifact: {processed_note}")
        present_sites = set(processed_frame["site"].dropna().unique().tolist())

    raw_fallback_frames, raw_notes = load_missing_sites_from_raw(project_root, present_sites)
    participants_frames.extend(raw_fallback_frames)
    source_notes.extend([f"Raw fallback used for missing site: {note}" for note in raw_notes])

    if not participants_frames:
        raise FileNotFoundError(
            "No usable participant-level data were found in data/processed or data/raw."
        )

    participants = pd.concat(participants_frames, ignore_index=True)
    participants = participants.drop_duplicates(subset=["site", "id"], keep="first")
    long_df = reshape_participants_to_long(participants)

    site_counts = long_df.groupby("site")["participant_key"].nunique().to_dict()
    metadata = {
        "participant_rows": int(len(participants)),
        "judgement_rows": int(len(long_df)),
        "sites": site_counts,
        "sources": source_notes,
        "attention_pass_rows": int(long_df["attention_pass"].sum()),
        "analysis_include_rows": int(long_df["analysis_include"].sum()),
    }
    return DatasetBundle(data=long_df, metadata=metadata)


def write_local_snapshot(bundle: DatasetBundle, output_dir: Path) -> tuple[Path, Path]:
    output_dir.mkdir(parents=True, exist_ok=True)
    csv_path = output_dir / "judgments_playground.csv"
    json_path = output_dir / "judgments_playground_metadata.json"
    bundle.data.to_csv(csv_path, index=False)
    json_path.write_text(json.dumps(bundle.metadata, indent=2), encoding="utf-8")
    return csv_path, json_path
