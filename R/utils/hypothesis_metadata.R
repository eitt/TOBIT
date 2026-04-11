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
    "economic_status",
    "factor(negotiator_slot)"
  )

  empathy_vars_A <- c("iri_total")
  empathy_vars_B <- c("iri_fs", "iri_ec", "iri_pt", "iri_pd")

  h1_relational_victim <- c(
    "judged_ingroup",
    "judged_outgroup",
    "counterpart_ingroup",
    "counterpart_outgroup",
    "decision_accept"
  )
  h1_relational_bystander <- c(
    h1_relational_victim,
    "observer_victim_outgroup"
  )

  h1_victim_rhs_A <- paste(c(empathy_vars_A, h1_relational_victim, controls), collapse = " + ")
  h1_victim_rhs_B <- paste(c(empathy_vars_B, h1_relational_victim, controls), collapse = " + ")
  h1_bystander_rhs_A <- paste(c(empathy_vars_A, h1_relational_bystander, controls), collapse = " + ")
  h1_bystander_rhs_B <- paste(c(empathy_vars_B, h1_relational_bystander, controls), collapse = " + ")

  h2_structure_terms <- get_h2_negotiator_structure_term_names(
    reference = "J_Cont__C_Cont",
    include_control = TRUE
  )
  h2_bystander_interaction_terms <- paste("player_victim_outgroup", h2_structure_terms, sep = ":")

  h2_victim_rhs_A <- paste(c(empathy_vars_A, h2_structure_terms, controls), collapse = " + ")
  h2_victim_rhs_B <- paste(c(empathy_vars_B, h2_structure_terms, controls), collapse = " + ")
  h2_bystander_rhs_A <- paste(
    c(empathy_vars_A, h2_structure_terms, "player_victim_outgroup", h2_bystander_interaction_terms, controls),
    collapse = " + "
  )
  h2_bystander_rhs_B <- paste(
    c(empathy_vars_B, h2_structure_terms, "player_victim_outgroup", h2_bystander_interaction_terms, controls),
    collapse = " + "
  )

  h3_judged_terms <- c("judged_ingroup", "judged_outgroup")
  h3_decision_block <- c(
    "decision_accept",
    "decision_accept:judged_ingroup",
    "decision_accept:judged_outgroup"
  )
  h3_counterpart_terms <- c("counterpart_ingroup", "counterpart_outgroup")
  h3_interactions_A <- paste(empathy_vars_A, h3_judged_terms, sep = ":")
  h3_interactions_B <- as.vector(outer(empathy_vars_B, h3_judged_terms, paste, sep = ":"))

  h3_victim_rhs_A <- paste(
    c(empathy_vars_A, h3_judged_terms, h3_decision_block, h3_interactions_A, h3_counterpart_terms, controls),
    collapse = " + "
  )
  h3_victim_rhs_B <- paste(
    c(empathy_vars_B, h3_judged_terms, h3_decision_block, h3_interactions_B, h3_counterpart_terms, controls),
    collapse = " + "
  )
  h3_bystander_rhs_A <- paste(
    c(
      empathy_vars_A,
      h3_judged_terms,
      h3_decision_block,
      h3_interactions_A,
      h3_counterpart_terms,
      "observer_victim_outgroup",
      controls
    ),
    collapse = " + "
  )
  h3_bystander_rhs_B <- paste(
    c(
      empathy_vars_B,
      h3_judged_terms,
      h3_decision_block,
      h3_interactions_B,
      h3_counterpart_terms,
      "observer_victim_outgroup",
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
        "conditioning on judged-negotiator status, counterpart status,",
        "decision outcome, and observer-side victim alignment when applicable."
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
      exclude_terms = c("(Intercept)", "Log(scale)"),
      plain_title = "H1",
      plain_question = paste(
        "Si las dimensiones de empatia se relacionan con la severidad del juicio",
        "moral cuando ya controlamos el contexto relacional del negociador."
      ),
      plain_sample = "Se estima por separado en Victima y Observador, con una fila por juicio sobre un negociador.",
      plain_equation = "Juicio moral ~ empatia + estatus del negociador juzgado + estatus de la contraparte + decision + controles",
      plain_code_equations = build_plain_code_equations(
        victim_rhs_A = h1_victim_rhs_A,
        bystander_rhs_A = h1_bystander_rhs_A,
        victim_rhs_B = h1_victim_rhs_B,
        bystander_rhs_B = h1_bystander_rhs_B
      ),
      plain_term_note = paste(
        "En Observador se agrega `observer_victim_outgroup` porque solo ahi varia",
        "la relacion entre el jugador y la victima."
      )
    ),
    list(
      id = "H2",
      family_id = "H2",
      short_label = "Negotiator-Side Structure",
      statement = paste(
        "Moral judgments vary with the joint judged-plus-counterpart",
        "negotiator structure, and in the bystander subset that structure",
        "may also depend on player-victim alignment."
      ),
      expected_direction = "relational",
      primary_terms = list(
        A = list(Victim = h2_structure_terms, Bystander = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interaction_terms)),
        B = list(Victim = h2_structure_terms, Bystander = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interaction_terms))
      ),
      model_terms = list(
        A = list(
          Victim = list(terms = h2_structure_terms, description = "negotiator-side structure contrasts"),
          Bystander = list(
            terms = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interaction_terms),
            description = "negotiator-side structure, player-victim alignment, and their interaction"
          )
        ),
        B = list(
          Victim = list(terms = h2_structure_terms, description = "negotiator-side structure contrasts"),
          Bystander = list(
            terms = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interaction_terms),
            description = "negotiator-side structure, player-victim alignment, and their interaction"
          )
        )
      ),
      formula_rhs = list(
        A = list(Victim = h2_victim_rhs_A, Bystander = h2_bystander_rhs_A),
        B = list(Victim = h2_victim_rhs_B, Bystander = h2_bystander_rhs_B)
      ),
      exclude_terms = c("(Intercept)", "Log(scale)"),
      plain_title = "H2",
      plain_question = paste(
        "Si el juicio cambia segun la posicion conjunta del negociador juzgado",
        "y su contraparte respecto al participante."
      ),
      plain_sample = "Se estima por separado en Victima y Observador, con una fila por juicio sobre un negociador.",
      plain_equation = paste(
        "Juicio moral ~ estructura juzgado-contraparte",
        "(+ alineacion jugador-victima e interacciones en Observador) + empatia + controles"
      ),
      plain_code_equations = build_plain_code_equations(
        victim_rhs_A = h2_victim_rhs_A,
        bystander_rhs_A = h2_bystander_rhs_A,
        victim_rhs_B = h2_victim_rhs_B,
        bystander_rhs_B = h2_bystander_rhs_B
      ),
      plain_term_note = paste(
        "La referencia de H2 es `J_Cont__C_Cont`: N1 y N2 en la condicion",
        "control."
      )
    ),
    list(
      id = "H3",
      family_id = "H3",
      short_label = "Empathy x Judged Status",
      statement = paste(
        "The empathy effect depends on the judged negotiator's ingroup,",
        "outgroup, or control status after retaining decision context and",
        "relational controls."
      ),
      expected_direction = "either",
      primary_terms = list(
        A = h3_interactions_A,
        B = h3_interactions_B
      ),
      model_terms = list(
        A = list(
          Victim = list(terms = h3_interactions_A, description = "composite-empathy by judged-status interactions"),
          Bystander = list(terms = h3_interactions_A, description = "composite-empathy by judged-status interactions")
        ),
        B = list(
          Victim = list(terms = h3_interactions_B, description = "empathy-by-judged-status interactions"),
          Bystander = list(terms = h3_interactions_B, description = "empathy-by-judged-status interactions")
        )
      ),
      formula_rhs = list(
        A = list(Victim = h3_victim_rhs_A, Bystander = h3_bystander_rhs_A),
        B = list(Victim = h3_victim_rhs_B, Bystander = h3_bystander_rhs_B)
      ),
      exclude_terms = c("(Intercept)", "Log(scale)"),
      plain_title = "H3",
      plain_question = paste(
        "Si la relacion entre empatia y juicio moral cambia dependiendo del",
        "estatus del negociador juzgado."
      ),
      plain_sample = "Se estima por separado en Victima y Observador, con una fila por juicio sobre un negociador.",
      plain_equation = paste(
        "Juicio moral ~ empatia + estatus del negociador juzgado + decision +",
        "empatia x estatus juzgado + decision x estatus juzgado + controles"
      ),
      plain_code_equations = build_plain_code_equations(
        victim_rhs_A = h3_victim_rhs_A,
        bystander_rhs_A = h3_bystander_rhs_A,
        victim_rhs_B = h3_victim_rhs_B,
        bystander_rhs_B = h3_bystander_rhs_B
      ),
      plain_term_note = paste(
        "En Observador se conserva ademas `observer_victim_outgroup` para no",
        "mezclar un predictor solo-observador dentro del subconjunto Victima."
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
