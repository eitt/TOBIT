# R/utils/case_configuration_functions.R
# Purpose: Centralize Option 2 explicit case-configuration logic so the
# pipeline, report, and local playground all refer to the same relational
# scenario structure.
# Dependencies: None

get_case_configuration_option_label <- function() {
  "Option 2: explicit case-configuration modeling"
}

format_case_configuration_example <- function(case_label, latex = FALSE) {
  if (!isTRUE(latex)) return(case_label)
  paste0("\\texttt{", gsub("_", "\\\\_", case_label), "}")
}

get_case_configuration_example_labels <- function(latex = FALSE) {
  vapply(
    get_case_configuration_levels(include_control = TRUE),
    format_case_configuration_example,
    character(1),
    latex = latex
  )
}

get_case_configuration_option_text <- function(latex = FALSE) {
  example_text <- paste(get_case_configuration_example_labels(latex = latex), collapse = ", ")
  paste(
    "Option 2 replaces isolated ingroup/outgroup indicators with explicit",
    "relational case configurations built from the paired-group structure of",
    "each judgment. The current project records the victim group first and the",
    sprintf("judged negotiator label second, so configurations such as %s refer", example_text),
    "to victim x negotiator combinations rather than detached attributes."
  )
}

faculty_case_label <- function(x, allow_control = FALSE) {
  if (!isTRUE(allow_control)) {
    return(ifelse(
      is.na(x),
      NA_character_,
      ifelse(
        x == 1L,
        "Hum",
        ifelse(x == 2L, "Ing", NA_character_)
      )
    ))
  }

  ifelse(
    is.na(x),
    NA_character_,
    ifelse(
      x == 1L,
      "Hum",
      ifelse(
        x == 2L,
        "Ing",
        ifelse(x == 3L, "Control", NA_character_)
      )
    )
  )
}

get_case_configuration_levels <- function(include_control = TRUE) {
  levels <- c("Hum_x_Hum", "Hum_x_Ing", "Hum_x_Control", "Ing_x_Hum", "Ing_x_Ing", "Ing_x_Control")
  if (include_control) {
    return(levels)
  }
  levels[!grepl("Control", levels, fixed = TRUE)]
}

build_case_configuration <- function(victim_faculty, negotiator_faculty) {
  victim_label <- faculty_case_label(victim_faculty, allow_control = FALSE)
  negotiator_label <- faculty_case_label(negotiator_faculty, allow_control = TRUE)
  ifelse(
    is.na(victim_label) | is.na(negotiator_label),
    NA_character_,
    paste(victim_label, negotiator_label, sep = "_x_")
  )
}

case_configuration_dummy_name <- function(case_label) {
  paste0("case_", gsub("[^A-Za-z0-9]+", "_", tolower(case_label)))
}

get_case_configuration_dummy_names <- function(include_control = TRUE) {
  stats::setNames(
    vapply(get_case_configuration_levels(include_control = include_control), case_configuration_dummy_name, character(1)),
    get_case_configuration_levels(include_control = include_control)
  )
}

get_case_configuration_term_names <- function(reference = "Hum_x_Hum", include_control = TRUE) {
  dummy_map <- get_case_configuration_dummy_names(include_control = include_control)
  if (!(reference %in% names(dummy_map))) {
    stop(sprintf("Unknown case-configuration reference level '%s'.", reference), call. = FALSE)
  }
  unname(dummy_map[names(dummy_map) != reference])
}

get_case_configuration_term_map <- function(reference = "Hum_x_Hum", include_control = TRUE) {
  dummy_map <- get_case_configuration_dummy_names(include_control = include_control)
  if (!(reference %in% names(dummy_map))) {
    stop(sprintf("Unknown case-configuration reference level '%s'.", reference), call. = FALSE)
  }
  dummy_map[names(dummy_map) != reference]
}

get_case_configuration_interaction_terms <- function(base_terms, reference = "Hum_x_Hum", include_control = TRUE) {
  rel_terms <- get_case_configuration_term_names(reference = reference, include_control = include_control)
  as.vector(outer(base_terms, rel_terms, paste, sep = ":"))
}

add_case_configuration_columns <- function(
    df,
    victim_col = "faculty_victim",
    negotiator_col = "faculty_negotiator",
    role_col = "role",
    decision_col = "decision_accept") {
  if (!(victim_col %in% names(df)) || !(negotiator_col %in% names(df))) {
    stop("The victim and negotiator columns required for case configuration are missing.", call. = FALSE)
  }

  case_configuration <- build_case_configuration(df[[victim_col]], df[[negotiator_col]])
  role_label <- if (role_col %in% names(df)) {
    ifelse(df[[role_col]] == "observer" | df[[role_col]] == 1L, "Observer", "Victim")
  } else {
    rep(NA_character_, nrow(df))
  }
  decision_label <- if (decision_col %in% names(df)) {
    ifelse(df[[decision_col]] == 1L, "Accept", "Reject")
  } else {
    rep(NA_character_, nrow(df))
  }

  df$case_configuration <- case_configuration
  df$case_configuration_role <- ifelse(
    is.na(case_configuration) | is.na(role_label),
    NA_character_,
    paste(case_configuration, role_label, sep = "__")
  )
  df$case_configuration_decision <- ifelse(
    is.na(case_configuration) | is.na(decision_label),
    NA_character_,
    paste(case_configuration, decision_label, sep = "__")
  )
  df$case_configuration_context <- ifelse(
    is.na(case_configuration) | is.na(role_label) | is.na(decision_label),
    NA_character_,
    paste(case_configuration, role_label, decision_label, sep = "__")
  )

  dummy_map <- get_case_configuration_dummy_names(include_control = TRUE)
  for (case_label in names(dummy_map)) {
    df[[dummy_map[[case_label]]]] <- as.integer(df$case_configuration == case_label)
  }

  df
}
