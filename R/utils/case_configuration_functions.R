# R/utils/case_configuration_functions.R
# Purpose: Centralize Option 2 explicit case-configuration logic so the
# pipeline, report, and local playground all refer to the same relational
# scenario structure.
# Dependencies: None
#
# LEGACY NOTE:
# This module remains available for backward compatibility utilities. The
# active production branch now expresses analytical predictors directly in
# target/other semantics.

get_case_configuration_option_label <- function() {
  "Option 2: judgment-level relational modeling"
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
  paste(
    "Option 2 replaces isolated ingroup/outgroup indicators with explicit",
    "judgment-level relational variables built from the paired-group structure",
    "of each judgment. The analytic hypothesis models decompose that structure",
    "into judged-negotiator status, counterpart-negotiator status, observer-side",
    "victim alignment when applicable, and hypothesis-specific interaction blocks."
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

normalize_role_label <- function(role_value) {
  role_chr <- trimws(as.character(role_value))
  role_chr[is.na(role_value)] <- NA_character_

  ifelse(
    is.na(role_chr),
    NA_character_,
    ifelse(
      tolower(role_chr) %in% c("observer", "1"),
      "Observer",
      ifelse(
        tolower(role_chr) %in% c("victim", "0", "2"),
        "Victim",
        NA_character_
      )
    )
  )
}

get_relative_group_levels <- function(include_control = TRUE) {
  if (isTRUE(include_control)) {
    return(c("In", "Out", "Cont"))
  }
  c("In", "Out")
}

build_relative_group <- function(actor_faculty, reference_faculty, allow_control = TRUE) {
  actor_faculty <- as.integer(actor_faculty)
  reference_faculty <- as.integer(reference_faculty)

  ifelse(
    is.na(actor_faculty) | is.na(reference_faculty),
    NA_character_,
    ifelse(
      isTRUE(allow_control) & actor_faculty == 3L,
      "Cont",
      ifelse(actor_faculty == reference_faculty, "In", "Out")
    )
  )
}

build_analytic_case_configuration <- function(role, judged_group, counterpart_group, victim_group = NA_character_) {
  role_label <- normalize_role_label(role)
  target_length <- max(length(role_label), length(judged_group), length(counterpart_group), length(victim_group))

  role_label <- rep_len(role_label, target_length)
  judged_group <- rep_len(as.character(judged_group), target_length)
  counterpart_group <- rep_len(as.character(counterpart_group), target_length)
  victim_group <- rep_len(as.character(victim_group), target_length)

  vapply(
    seq_len(target_length),
    function(idx) {
      role_i <- role_label[idx]
      judged_i <- judged_group[idx]
      counterpart_i <- counterpart_group[idx]
      victim_i <- victim_group[idx]

      if (is.na(role_i) || is.na(judged_i) || is.na(counterpart_i)) {
        return(NA_character_)
      }

      if (identical(role_i, "Victim")) {
        return(paste("Victim", paste0("J_", judged_i), paste0("C_", counterpart_i), sep = "__"))
      }

      if (is.na(victim_i)) {
        return(NA_character_)
      }

      paste("Observer", paste0("J_", judged_i), paste0("C_", counterpart_i), paste0("V_", victim_i), sep = "__")
    },
    character(1)
  )
}

get_analytic_case_configuration_levels <- function(include_control = TRUE) {
  negotiator_levels <- get_relative_group_levels(include_control = include_control)
  victim_levels <- get_relative_group_levels(include_control = FALSE)

  victim_configs <- as.vector(
    outer(
      negotiator_levels,
      negotiator_levels,
      function(judged, counterpart) paste("Victim", paste0("J_", judged), paste0("C_", counterpart), sep = "__")
    )
  )
  observer_base <- as.vector(
    outer(
      negotiator_levels,
      negotiator_levels,
      function(judged, counterpart) paste(paste0("J_", judged), paste0("C_", counterpart), sep = "__")
    )
  )
  observer_configs <- as.vector(
    outer(
      observer_base,
      victim_levels,
      function(base, victim) paste("Observer", base, paste0("V_", victim), sep = "__")
    )
  )

  c(victim_configs, observer_configs)
}

analytic_case_configuration_dummy_name <- function(configuration_label) {
  paste0("acfg_", gsub("[^A-Za-z0-9]+", "_", tolower(configuration_label)))
}

get_analytic_case_configuration_dummy_names <- function(include_control = TRUE) {
  levels <- get_analytic_case_configuration_levels(include_control = include_control)
  stats::setNames(
    vapply(levels, analytic_case_configuration_dummy_name, character(1)),
    levels
  )
}

get_analytic_case_configuration_term_names <- function(
    reference = "Victim__J_In__C_In",
    include_control = TRUE) {
  dummy_map <- get_analytic_case_configuration_dummy_names(include_control = include_control)
  if (!(reference %in% names(dummy_map))) {
    stop(sprintf("Unknown analytic case-configuration reference level '%s'.", reference), call. = FALSE)
  }
  unname(dummy_map[names(dummy_map) != reference])
}

get_analytic_case_configuration_term_map <- function(
    reference = "Victim__J_In__C_In",
    include_control = TRUE) {
  dummy_map <- get_analytic_case_configuration_dummy_names(include_control = include_control)
  if (!(reference %in% names(dummy_map))) {
    stop(sprintf("Unknown analytic case-configuration reference level '%s'.", reference), call. = FALSE)
  }
  dummy_map[names(dummy_map) != reference]
}

get_analytic_case_configuration_interaction_terms <- function(
    base_terms,
    reference = "Victim__J_In__C_In",
    include_control = TRUE) {
  rel_terms <- get_analytic_case_configuration_term_names(
    reference = reference,
    include_control = include_control
  )
  as.vector(outer(base_terms, rel_terms, paste, sep = ":"))
}

label_relative_group <- function(group_code) {
  switch(
    as.character(group_code),
    In = "ingroup",
    Out = "outgroup",
    Cont = "control label hidden",
    group_code
  )
}

label_analytic_case_configuration <- function(configuration_label) {
  parts <- strsplit(configuration_label, "__", fixed = TRUE)[[1]]
  if (length(parts) < 3L) return(configuration_label)

  role_label <- parts[1]
  judged_group <- sub("^J_", "", parts[2])
  counterpart_group <- sub("^C_", "", parts[3])

  if (identical(role_label, "Victim")) {
    return(sprintf(
      "Victim role: N1 %s, N2 %s",
      label_relative_group(judged_group),
      label_relative_group(counterpart_group)
    ))
  }

  if (length(parts) != 4L) return(configuration_label)

  victim_group <- sub("^V_", "", parts[4])
  sprintf(
    "Observer role: N1 %s, N2 %s, victim %s",
    label_relative_group(judged_group),
    label_relative_group(counterpart_group),
    label_relative_group(victim_group)
  )
}

label_analytic_case_configuration_term <- function(term) {
  dummy_map <- get_analytic_case_configuration_dummy_names(include_control = TRUE)
  matched_level <- names(dummy_map)[match(term, unname(dummy_map))]
  if (length(matched_level) == 1L && !is.na(matched_level)) {
    return(paste("Judgment configuration:", label_analytic_case_configuration(matched_level)))
  }
  term
}

get_h2_negotiator_structure_levels <- function(include_control = TRUE) {
  negotiator_levels <- get_relative_group_levels(include_control = include_control)
  as.vector(
    outer(
      negotiator_levels,
      negotiator_levels,
      function(judged, counterpart) paste0("J_", judged, "__C_", counterpart)
    )
  )
}

build_h2_negotiator_structure <- function(judged_group, counterpart_group) {
  target_length <- max(length(judged_group), length(counterpart_group))
  judged_group <- rep_len(as.character(judged_group), target_length)
  counterpart_group <- rep_len(as.character(counterpart_group), target_length)

  vapply(
    seq_len(target_length),
    function(idx) {
      judged_i <- judged_group[idx]
      counterpart_i <- counterpart_group[idx]
      if (is.na(judged_i) || is.na(counterpart_i)) {
        return(NA_character_)
      }
      paste0("J_", judged_i, "__C_", counterpart_i)
    },
    character(1)
  )
}

h2_negotiator_structure_dummy_name <- function(structure_label) {
  paste0("h2_negstruct_", gsub("[^A-Za-z0-9]+", "_", tolower(structure_label)))
}

get_h2_negotiator_structure_dummy_names <- function(
    reference = "J_Cont__C_Cont",
    include_control = TRUE) {
  levels <- get_h2_negotiator_structure_levels(include_control = include_control)
  dummy_map <- stats::setNames(
    vapply(levels, h2_negotiator_structure_dummy_name, character(1)),
    levels
  )
  if (!(reference %in% names(dummy_map))) {
    stop(sprintf("Unknown H2 negotiator-structure reference level '%s'.", reference), call. = FALSE)
  }
  dummy_map[names(dummy_map) != reference]
}

get_h2_negotiator_structure_term_names <- function(
    reference = "J_Cont__C_Cont",
    include_control = TRUE) {
  unname(get_h2_negotiator_structure_dummy_names(
    reference = reference,
    include_control = include_control
  ))
}

label_h2_negotiator_structure <- function(structure_label) {
  parts <- strsplit(structure_label, "__", fixed = TRUE)[[1]]
  if (length(parts) != 2L) {
    return(structure_label)
  }

  judged_group <- sub("^J_", "", parts[1])
  counterpart_group <- sub("^C_", "", parts[2])
  sprintf(
    "N1 %s, N2 %s",
    label_relative_group(judged_group),
    label_relative_group(counterpart_group)
  )
}

label_h2_negotiator_structure_term <- function(term) {
  dummy_map <- get_h2_negotiator_structure_dummy_names(include_control = TRUE)
  matched_level <- names(dummy_map)[match(term, unname(dummy_map))]
  if (length(matched_level) == 1L && !is.na(matched_level)) {
    return(paste(
      "Negotiator-side structure:",
      sprintf(
        "%s (ref = N1 control label hidden, N2 control label hidden)",
        label_h2_negotiator_structure(matched_level)
      )
    ))
  }
  term
}

add_h2_relational_structure_columns <- function(
    df,
    judged_col = "group_negotiator_judged",
    counterpart_col = "group_negotiator_counterpart",
    victim_col = "group_victim",
    role_col = "role") {
  required_cols <- c(judged_col, counterpart_col, victim_col, role_col)
  missing_cols <- required_cols[!(required_cols %in% names(df))]
  if (length(missing_cols) > 0L) {
    stop(
      sprintf("Columns required for H2 relational structure are missing: %s", paste(missing_cols, collapse = ", ")),
      call. = FALSE
    )
  }

  role_label <- normalize_role_label(df[[role_col]])
  df$h2_negotiator_structure <- build_h2_negotiator_structure(df[[judged_col]], df[[counterpart_col]])
  df$player_victim_alignment <- ifelse(
    role_label == "Observer",
    ifelse(df[[victim_col]] == "Out", "Out", ifelse(df[[victim_col]] == "In", "In", NA_character_)),
    NA_character_
  )
  df$player_victim_outgroup <- ifelse(
    role_label == "Observer" & df$player_victim_alignment == "Out",
    1L,
    ifelse(role_label == "Observer" & df$player_victim_alignment == "In", 0L, NA_integer_)
  )

  dummy_map <- get_h2_negotiator_structure_dummy_names(include_control = TRUE)
  for (structure_label in names(dummy_map)) {
    df[[dummy_map[[structure_label]]]] <- as.integer(df$h2_negotiator_structure == structure_label)
  }

  df
}

add_analytic_case_configuration_columns <- function(
    df,
    config_col = "analytic_case_configuration",
    decision_col = "decision_accept") {
  if (!(config_col %in% names(df))) {
    stop(sprintf("Column '%s' is missing from the data.", config_col), call. = FALSE)
  }

  decision_label <- if (decision_col %in% names(df)) {
    ifelse(df[[decision_col]] == 1L, "Accept", "Reject")
  } else {
    rep(NA_character_, nrow(df))
  }

  df$analytic_case_configuration_decision <- ifelse(
    is.na(df[[config_col]]) | is.na(decision_label),
    NA_character_,
    paste(df[[config_col]], decision_label, sep = "__")
  )
  df$analytic_case_configuration_context <- df$analytic_case_configuration_decision

  dummy_map <- get_analytic_case_configuration_dummy_names(include_control = TRUE)
  for (configuration_label in names(dummy_map)) {
    df[[dummy_map[[configuration_label]]]] <- as.integer(df[[config_col]] == configuration_label)
  }

  df
}
