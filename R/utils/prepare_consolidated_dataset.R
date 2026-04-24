# Utility functions to validate and bridge the Version 2.0 consolidated long dataset.

required_long_columns <- function() {
  c(
    "session",
    "id",
    "id_case",
    "stage",
    "role",
    "age",
    "ses",
    "sex_female",
    "faculty_player",
    "iri_fs",
    "iri_ec",
    "iri_pt",
    "iri_pd",
    "target",
    "judgement",
    "decision_target",
    "decision_other",
    "faculty_target",
    "faculty_other",
    "faculty_victim",
    "group_target",
    "group_other",
    "n_match",
    "obs_group"
  )
}

read_consolidated_long_dataset <- function(paths = get_project_paths()) {
  if (!file.exists(paths$base_long_dataset)) {
    stop(
      sprintf("Base dataset not found: %s", paths$base_long_dataset),
      call. = FALSE
    )
  }

  data <- as.data.frame(
    readxl::read_excel(paths$base_long_dataset),
    stringsAsFactors = FALSE
  )
  data$source_row_number <- seq_len(nrow(data))
  data
}

validate_consolidated_long_dataset <- function(data) {
  missing_columns <- setdiff(required_long_columns(), names(data))
  if (length(missing_columns) > 0L) {
    stop(
      sprintf(
        "The consolidated long dataset is missing required columns: %s",
        paste(missing_columns, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  pair_counts <- table(data$id_case)
  if (any(pair_counts != 2L)) {
    stop(
      "Each id_case must appear exactly twice in the base long dataset.",
      call. = FALSE
    )
  }

  invisible(TRUE)
}

coerce_numeric_columns <- function(data, columns) {
  for (column_name in columns) {
    if (column_name %in% names(data)) {
      data[[column_name]] <- suppressWarnings(as.numeric(data[[column_name]]))
    }
  }
  data
}

derive_treatment_from_long <- function(stage_roles) {
  if (length(stage_roles) != 10L) {
    return(NA_integer_)
  }
  if (all(stage_roles[1:5] == 1) && all(stage_roles[6:10] == 0)) {
    return(1L)
  }
  if (all(stage_roles[1:5] == 0) && all(stage_roles[6:10] == 1)) {
    return(2L)
  }
  NA_integer_
}

derive_judgement_compare <- function(judgement_n1, judgement_n2) {
  if (is.na(judgement_n1) || is.na(judgement_n2)) {
    return(NA_integer_)
  }
  if (judgement_n1 < judgement_n2) {
    return(1L)
  }
  if (judgement_n2 < judgement_n1) {
    return(2L)
  }
  3L
}

reconstruct_participant_bridge <- function(long_data) {
  participant_ids <- sort(unique(long_data$id))
  bridge_rows <- vector("list", length(participant_ids))

  for (index in seq_along(participant_ids)) {
    participant_id <- participant_ids[[index]]
    participant_data <- long_data[long_data$id == participant_id, , drop = FALSE]
    participant_data <- participant_data[order(participant_data$stage, participant_data$target), , drop = FALSE]

    stage_roles <- tapply(participant_data$role, participant_data$stage, unique)
    stage_roles <- as.integer(stage_roles[as.character(seq_len(10))])

    row_values <- list(
      session = participant_data$session[[1]],
      id = participant_id,
      age = participant_data$age[[1]],
      economic_status = participant_data$ses[[1]],
      sex = ifelse(
        is.na(participant_data$sex_female[[1]]),
        NA_integer_,
        ifelse(participant_data$sex_female[[1]] == 1, 1L, 2L)
      ),
      faculty_player = participant_data$faculty_player[[1]],
      ac1 = NA_integer_,
      ac2 = NA_integer_,
      treatment = derive_treatment_from_long(stage_roles),
      campus = "Version 2.0",
      attention_pass = TRUE,
      valid_treatment = !is.na(derive_treatment_from_long(stage_roles)),
      analysis_include = TRUE,
      iri_total = mean(
        c(
          participant_data$iri_fs[[1]],
          participant_data$iri_ec[[1]],
          participant_data$iri_pt[[1]],
          participant_data$iri_pd[[1]]
        ),
        na.rm = TRUE
      ),
      iri_fs = participant_data$iri_fs[[1]],
      iri_ec = participant_data$iri_ec[[1]],
      iri_pt = participant_data$iri_pt[[1]],
      iri_pd = participant_data$iri_pd[[1]]
    )

    for (stage_value in seq_len(10)) {
      stage_data <- participant_data[participant_data$stage == stage_value, , drop = FALSE]
      stage_n1 <- stage_data[stage_data$target == 1, , drop = FALSE]
      stage_n2 <- stage_data[stage_data$target == 2, , drop = FALSE]

      row_values[[sprintf("faculty_neg_1_s%s", stage_value)]] <- stage_n1$faculty_target[[1]]
      row_values[[sprintf("faculty_neg_2_s%s", stage_value)]] <- stage_n2$faculty_target[[1]]
      row_values[[sprintf("faculty_victim_s%s", stage_value)]] <- stage_data$faculty_victim[[1]]
      row_values[[sprintf("decision_neg1_s%s", stage_value)]] <- stage_n1$decision_target[[1]]
      row_values[[sprintf("decision_neg2_s%s", stage_value)]] <- stage_n2$decision_target[[1]]
      row_values[[sprintf("judgement_n1_s%s", stage_value)]] <- stage_n1$judgement[[1]]
      row_values[[sprintf("judgement_n2_s%s", stage_value)]] <- stage_n2$judgement[[1]]
      row_values[[sprintf("judgement_compare_s%s", stage_value)]] <- derive_judgement_compare(
        stage_n1$judgement[[1]],
        stage_n2$judgement[[1]]
      )
    }

    bridge_rows[[index]] <- as.data.frame(row_values, stringsAsFactors = FALSE)
  }

  do.call(rbind, bridge_rows)
}

build_variable_dictionary <- function() {
  data.frame(
    variable = c(
      "ses",
      "sex_female",
      "role",
      "target",
      "judgement",
      "decision_target",
      "decision_other",
      "faculty_player",
      "faculty_target",
      "faculty_other",
      "faculty_victim",
      "group_target",
      "group_other",
      "obs_group"
    ),
    source_role = c(
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset",
      "base dataset"
    ),
    mapping_note = c(
      "Used directly as the socioeconomic covariate in all models.",
      "Used directly as the sex covariate in all models: 1 = woman, 0 = man, missing = not reported.",
      "Used directly from the Version 2.0 file: 1 = victim, 0 = bystander.",
      "Row-dynamic judged negotiator code from the source file: 1 or 2.",
      "Observed moral judgement of the row-dynamic target negotiator on the bounded -9 to 9 scale.",
      "Active operational target-decision variable (legacy wording: accept_target): 1 = accept, 0 = reject for the row-dynamic target actor.",
      "Active operational counterpart-decision variable (legacy wording: accept_other): 1 = accept, 0 = reject for the non-target actor in the same row.",
      "Used directly as participant faculty; re-labeled to Humanities / Engineering for modeling.",
      "Used directly as the row-dynamic target faculty field for target/other relational coding.",
      "Used directly as the row-dynamic counterpart faculty field for target/other relational coding.",
      "Used directly; equals faculty_player in victim rows and remains explicit in bystander rows.",
      "Legacy row-relative target-group field from the source file; retained for auditing and provenance, not used directly in active H2/H3/H5 formulas.",
      "Legacy row-relative other-group field from the source file; retained for auditing and provenance, not used directly in active H2/H3/H5 formulas.",
      "Legacy bystander-victim grouping from the source file; retained only for auditing, not as the main H2/H3/H5 predictor."
    ),
    stringsAsFactors = FALSE
  )
}
