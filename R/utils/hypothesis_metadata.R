# R/utils/hypothesis_metadata.R
# Purpose: Centralize hypothesis metadata so model runners, tables, and
# reports stay aligned with the active Option 2 formulas.

source("R/utils/case_configuration_functions.R")

resolve_subset_component <- function(component, subset_role = NULL) {
  if (is.null(subset_role) || is.null(component) || !is.list(component)) {
    return(component)
  }
  if (!is.null(names(component)) && subset_role %in% names(component)) {
    return(component[[subset_role]])
  }
  component
}

get_hypothesis_primary_terms <- function(spec, model_suffix, subset_role = NULL) {
  resolve_subset_component(spec$primary_terms[[model_suffix]], subset_role = subset_role)
}

get_hypothesis_model_terms <- function(spec, model_suffix, subset_role = NULL) {
  resolve_subset_component(spec$model_terms[[model_suffix]], subset_role = subset_role)
}

get_hypothesis_formula_rhs <- function(spec, model_suffix, subset_role = NULL) {
  resolve_subset_component(spec$formula_rhs[[model_suffix]], subset_role = subset_role)
}

build_plain_code_equations <- function(
    victim_rhs_A = NULL,
    bystander_rhs_A = NULL,
    victim_rhs_B = NULL,
    bystander_rhs_B = NULL) {
  lines <- character(0)
  if (!is.null(victim_rhs_A) && !is.null(bystander_rhs_A)) {
    lines <- c(
      lines,
      sprintf("Modelo A Victima: judgement ~ %s", victim_rhs_A),
      sprintf("Modelo A Observador: judgement ~ %s", bystander_rhs_A)
    )
  }
  if (!is.null(victim_rhs_B) && !is.null(bystander_rhs_B)) {
    lines <- c(
      lines,
      sprintf("Modelo B Victima: judgement ~ %s", victim_rhs_B),
      sprintf("Modelo B Observador: judgement ~ %s", bystander_rhs_B)
    )
  }
  lines
}

get_hypothesis_specs <- function(paths = get_project_paths()) {
  controls <- c(
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status"
  )

  empathy_vars_A <- c("iri_total")
  empathy_vars_B <- c("iri_fs", "iri_ec", "iri_pt", "iri_pd")

  group3_terms <- function(var_name) {
    paste0(var_name, c("In", "Out"))
  }

  group3_interaction_terms <- function(var_a, var_b) {
    as.vector(outer(
      group3_terms(var_a),
      group3_terms(var_b),
      paste,
      sep = ":"
    ))
  }

  group2_group3_interaction_terms <- function(group2_var, group3_var) {
    paste0(group2_var, "Out:", group3_terms(group3_var))
  }

  empathy_by_group_terms <- function(empathy_terms, group_terms) {
    as.vector(outer(empathy_terms, group_terms, paste, sep = ":"))
  }

  victim_base_predictors <- c(
    "victim_N1_group",
    "victim_N2_group",
    "N1_N2_same_faculty"
  )
  bystander_base_predictors <- c(
    "bystander_victim_group",
    "bystander_N1_group",
    "bystander_N2_group",
    "victim_N1_group",
    "victim_N2_group",
    "N1_N2_same_faculty"
  )

  h1_victim_rhs_A <- paste(c(empathy_vars_A, victim_base_predictors, controls), collapse = " + ")
  h1_victim_rhs_B <- paste(c(empathy_vars_B, victim_base_predictors, controls), collapse = " + ")
  h1_bystander_rhs_A <- paste(c(empathy_vars_A, bystander_base_predictors, controls), collapse = " + ")
  h1_bystander_rhs_B <- paste(c(empathy_vars_B, bystander_base_predictors, controls), collapse = " + ")

  h2_victim_rhs_A <- paste(
    c(
      empathy_vars_A,
      "victim_N1_group * victim_N2_group",
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )
  h2_victim_rhs_B <- paste(
    c(
      empathy_vars_B,
      "victim_N1_group * victim_N2_group",
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )
  h2_bystander_rhs_A <- paste(
    c(
      empathy_vars_A,
      "bystander_victim_group",
      "bystander_N1_group * bystander_N2_group",
      "bystander_victim_group:bystander_N1_group",
      "bystander_victim_group:bystander_N2_group",
      "victim_N1_group * victim_N2_group",
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )
  h2_bystander_rhs_B <- paste(
    c(
      empathy_vars_B,
      "bystander_victim_group",
      "bystander_N1_group * bystander_N2_group",
      "bystander_victim_group:bystander_N1_group",
      "bystander_victim_group:bystander_N2_group",
      "victim_N1_group * victim_N2_group",
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )

  h2_victim_terms <- c(
    group3_terms("victim_N1_group"),
    group3_terms("victim_N2_group"),
    group3_interaction_terms("victim_N1_group", "victim_N2_group"),
    "N1_N2_same_faculty"
  )
  h2_bystander_terms <- c(
    "bystander_victim_groupOut",
    group3_terms("bystander_N1_group"),
    group3_terms("bystander_N2_group"),
    group3_terms("victim_N1_group"),
    group3_terms("victim_N2_group"),
    group3_interaction_terms("bystander_N1_group", "bystander_N2_group"),
    group2_group3_interaction_terms("bystander_victim_group", "bystander_N1_group"),
    group2_group3_interaction_terms("bystander_victim_group", "bystander_N2_group"),
    group3_interaction_terms("victim_N1_group", "victim_N2_group"),
    "N1_N2_same_faculty"
  )

  h3_victim_group_terms <- c(
    group3_terms("victim_N1_group"),
    group3_terms("victim_N2_group")
  )
  h3_bystander_group_terms <- c(
    "bystander_victim_groupOut",
    group3_terms("bystander_N1_group"),
    group3_terms("bystander_N2_group"),
    group3_terms("victim_N1_group"),
    group3_terms("victim_N2_group")
  )
  h3_victim_interactions_A <- empathy_by_group_terms(empathy_vars_A, h3_victim_group_terms)
  h3_victim_interactions_B <- empathy_by_group_terms(empathy_vars_B, h3_victim_group_terms)
  h3_victim_formula_interactions_A <- c(
    paste(empathy_vars_A, "victim_N1_group", sep = ":"),
    paste(empathy_vars_A, "victim_N2_group", sep = ":")
  )
  h3_victim_formula_interactions_B <- c(
    paste(empathy_vars_B, "victim_N1_group", sep = ":"),
    paste(empathy_vars_B, "victim_N2_group", sep = ":")
  )
  h3_bystander_interaction_groups <- c(
    "bystander_victim_groupOut",
    group3_terms("bystander_N1_group"),
    group3_terms("bystander_N2_group")
  )
  h3_bystander_interactions_A <- empathy_by_group_terms(empathy_vars_A, h3_bystander_interaction_groups)
  h3_bystander_interactions_B <- empathy_by_group_terms(empathy_vars_B, h3_bystander_interaction_groups)
  h3_bystander_formula_interactions_A <- c(
    paste(empathy_vars_A, "bystander_victim_group", sep = ":"),
    paste(empathy_vars_A, "bystander_N1_group", sep = ":"),
    paste(empathy_vars_A, "bystander_N2_group", sep = ":")
  )
  h3_bystander_formula_interactions_B <- c(
    paste(empathy_vars_B, "bystander_victim_group", sep = ":"),
    paste(empathy_vars_B, "bystander_N1_group", sep = ":"),
    paste(empathy_vars_B, "bystander_N2_group", sep = ":")
  )

  h3_victim_rhs_A <- paste(
    c(
      empathy_vars_A,
      "victim_N1_group",
      "victim_N2_group",
      "victim_N1_group:victim_N2_group",
      h3_victim_formula_interactions_A,
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )
  h3_victim_rhs_B <- paste(
    c(
      empathy_vars_B,
      "victim_N1_group",
      "victim_N2_group",
      "victim_N1_group:victim_N2_group",
      h3_victim_formula_interactions_B,
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )
  h3_bystander_rhs_A <- paste(
    c(
      empathy_vars_A,
      "bystander_victim_group",
      "bystander_N1_group",
      "bystander_N2_group",
      "victim_N1_group",
      "victim_N2_group",
      "bystander_N1_group:bystander_N2_group",
      "bystander_victim_group:bystander_N1_group",
      "bystander_victim_group:bystander_N2_group",
      "victim_N1_group:victim_N2_group",
      h3_bystander_formula_interactions_A,
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )
  h3_bystander_rhs_B <- paste(
    c(
      empathy_vars_B,
      "bystander_victim_group",
      "bystander_N1_group",
      "bystander_N2_group",
      "victim_N1_group",
      "victim_N2_group",
      "bystander_N1_group:bystander_N2_group",
      "bystander_victim_group:bystander_N1_group",
      "bystander_victim_group:bystander_N2_group",
      "victim_N1_group:victim_N2_group",
      h3_bystander_formula_interactions_B,
      "N1_N2_same_faculty",
      controls
    ),
    collapse = " + "
  )

  list(
    list(
      id = "H1",
      family_id = "H1",
      short_label = "Empathy Effect",
      statement = paste(
        "Empathy dimensions are associated with moral judgment severity after",
        "conditioning on role-specific N1/N2 relational predictors and the",
        "N1-N2 same-faculty context term."
      ),
      expected_direction = "negative",
      primary_terms = list(
        A = empathy_vars_A,
        B = empathy_vars_B
      ),
      model_terms = list(
        A = list(
          Victim = list(terms = empathy_vars_A, description = "composite empathy"),
          Bystander = list(terms = empathy_vars_A, description = "composite empathy")
        ),
        B = list(
          Victim = list(terms = empathy_vars_B, description = "four empathy dimensions"),
          Bystander = list(terms = empathy_vars_B, description = "four empathy dimensions")
        )
      ),
      formula_rhs = list(
        A = list(Victim = h1_victim_rhs_A, Bystander = h1_bystander_rhs_A),
        B = list(Victim = h1_victim_rhs_B, Bystander = h1_bystander_rhs_B)
      ),
      exclude_terms = c("(Intercept)"),
      plain_title = "H1",
      plain_question = paste(
        "Si las dimensiones de empatia se relacionan con la severidad del juicio",
        "moral cuando controlamos los predictores relacionales de N1 y N2",
        "segun el rol del participante."
      ),
      plain_sample = "Se estima por separado en Victima y Observador, con una fila por respuesta y sin duplicar observaciones.",
      plain_equation = "Juicio moral ~ empatia + predictores relacionales por rol (N1, N2, victima) + N1_N2_same_faculty + controles + (1 | id) + [opcional (1 | id_case)]",
      plain_code_equations = build_plain_code_equations(
        victim_rhs_A = h1_victim_rhs_A,
        bystander_rhs_A = h1_bystander_rhs_A,
        victim_rhs_B = h1_victim_rhs_B,
        bystander_rhs_B = h1_bystander_rhs_B
      ),
      plain_term_note = paste(
        "Todas las estimaciones inferenciales incluyen intercepto aleatorio",
        "por participante `(1 | id)`; cuando `id_case` identifica pares",
        "repetidos por caso, tambien se agrega `(1 | id_case)`."
      )
    ),
    list(
      id = "H2",
      family_id = "H2",
      short_label = "Negotiator-Side Structure",
      statement = paste(
        "Moral judgments vary with explicit N1/N2 relational structure and",
        "with the participant role. Bystander models retain participant-victim",
        "alignment and selective pairwise interactions."
      ),
      expected_direction = "relational",
      primary_terms = list(
        A = list(Victim = h2_victim_terms, Bystander = h2_bystander_terms),
        B = list(Victim = h2_victim_terms, Bystander = h2_bystander_terms)
      ),
      model_terms = list(
        A = list(
          Victim = list(terms = h2_victim_terms, description = "victim-side N1/N2 relational structure and interaction"),
          Bystander = list(
            terms = h2_bystander_terms,
            description = "bystander-victim alignment plus bystander-victim x bystander-N1/N2 and N1/N2 joint relational structure"
          )
        ),
        B = list(
          Victim = list(terms = h2_victim_terms, description = "victim-side N1/N2 relational structure and interaction"),
          Bystander = list(
            terms = h2_bystander_terms,
            description = "bystander-victim alignment plus bystander-victim x bystander-N1/N2 and N1/N2 joint relational structure"
          )
        )
      ),
      formula_rhs = list(
        A = list(Victim = h2_victim_rhs_A, Bystander = h2_bystander_rhs_A),
        B = list(Victim = h2_victim_rhs_B, Bystander = h2_bystander_rhs_B)
      ),
      exclude_terms = c("(Intercept)"),
      plain_title = "H2",
      plain_question = paste(
        "Si el juicio cambia segun la estructura relacional explicita entre",
        "N1, N2 y la victima segun el rol (Victima u Observador)."
      ),
      plain_sample = "Se estima por separado en Victima y Observador, con una fila por respuesta y sin duplicar observaciones.",
      plain_equation = paste(
        "Juicio moral ~ estructura relacional de N1 y N2",
        "(+ alineacion observador-victima e interacciones selectivas en Observador)",
        "+ empatia + controles + (1 | id) + [opcional (1 | id_case)]"
      ),
      plain_code_equations = build_plain_code_equations(
        victim_rhs_A = h2_victim_rhs_A,
        bystander_rhs_A = h2_bystander_rhs_A,
        victim_rhs_B = h2_victim_rhs_B,
        bystander_rhs_B = h2_bystander_rhs_B
      ),
      plain_term_note = paste(
        "N1_N2_same_faculty entra primero como efecto principal contextual;",
        "en Observador tambien se incluyen interacciones bystander-victima x bystander-N1/N2;",
        "no se agregan interacciones con N1_N2_same_faculty salvo justificacion teorica explicita."
      )
    ),
    list(
      id = "H3",
      family_id = "H3",
      short_label = "Empathy x Relational Status",
      statement = paste(
        "The empathy effect depends on N1/N2 relational status indicators",
        "within each role-specific model while retaining relational controls",
        "and participant-level random intercepts."
      ),
      expected_direction = "either",
      primary_terms = list(
        A = list(Victim = h3_victim_interactions_A, Bystander = h3_bystander_interactions_A),
        B = list(Victim = h3_victim_interactions_B, Bystander = h3_bystander_interactions_B)
      ),
      model_terms = list(
        A = list(
          Victim = list(terms = h3_victim_interactions_A, description = "composite-empathy by victim-side N1/N2 interactions"),
          Bystander = list(terms = h3_bystander_interactions_A, description = "composite-empathy by bystander-victim and bystander-side N1/N2 interactions")
        ),
        B = list(
          Victim = list(terms = h3_victim_interactions_B, description = "empathy-by-victim-side N1/N2 interactions"),
          Bystander = list(terms = h3_bystander_interactions_B, description = "empathy-by-bystander-victim and bystander-side N1/N2 interactions")
        )
      ),
      formula_rhs = list(
        A = list(Victim = h3_victim_rhs_A, Bystander = h3_bystander_rhs_A),
        B = list(Victim = h3_victim_rhs_B, Bystander = h3_bystander_rhs_B)
      ),
      exclude_terms = c("(Intercept)"),
      plain_title = "H3",
      plain_question = paste(
        "Si la relacion entre empatia y juicio moral cambia dependiendo del",
        "estatus relacional de N1 y N2 dentro de cada rol."
      ),
      plain_sample = "Se estima por separado en Victima y Observador, con una fila por respuesta y sin duplicar observaciones.",
      plain_equation = paste(
        "Juicio moral ~ empatia + estatus relacional de N1/N2 +",
        "empatia x estatus relacional + controles + (1 | id) + [opcional (1 | id_case)]"
      ),
      plain_code_equations = build_plain_code_equations(
        victim_rhs_A = h3_victim_rhs_A,
        bystander_rhs_A = h3_bystander_rhs_A,
        victim_rhs_B = h3_victim_rhs_B,
        bystander_rhs_B = h3_bystander_rhs_B
      ),
      plain_term_note = paste(
        "En Observador se conservan predictores adicionales de alineacion",
        "bystander-victima, incluidas interacciones bystander-victima x bystander-N1/N2",
        "y empatia x bystander-victima; no se agregan interacciones",
        "de orden superior por defecto."
      )
    )
  )
}

get_hypothesis_family_id <- function(spec) {
  if (!is.null(spec$family_id) && nzchar(spec$family_id)) {
    return(spec$family_id)
  }
  spec$id
}

get_hypothesis_family_short_label <- function(spec) {
  spec$short_label
}

get_hypothesis_family_focus_label <- function(spec) {
  spec$short_label
}

get_hypothesis_family_statement <- function(spec) {
  spec$statement
}

get_hypothesis_family_specs <- function(paths = get_project_paths()) {
  specs <- get_hypothesis_specs(paths = paths)
  family_ids <- unique(vapply(specs, get_hypothesis_family_id, character(1)))

  lapply(family_ids, function(family_id) {
    member_specs <- specs[
      vapply(specs, function(spec) identical(get_hypothesis_family_id(spec), family_id), logical(1))
    ]
    anchor_spec <- member_specs[[1]]

    list(
      id = family_id,
      short_label = get_hypothesis_family_short_label(anchor_spec),
      focus_label = get_hypothesis_family_focus_label(anchor_spec),
      statement = get_hypothesis_family_statement(anchor_spec),
      member_ids = vapply(member_specs, `[[`, character(1), "id")
    )
  })
}

get_hypothesis_spec <- function(hypothesis_id, paths = get_project_paths()) {
  specs <- get_hypothesis_specs(paths = paths)
  normalized_ids <- toupper(vapply(specs, `[[`, character(1), "id"))
  match_idx <- match(toupper(trimws(hypothesis_id)), normalized_ids)
  if (is.na(match_idx)) {
    stop(sprintf("Unknown hypothesis id '%s'.", hypothesis_id), call. = FALSE)
  }
  specs[[match_idx]]
}
