# R/utils/hypothesis_metadata.R
# Purpose: Centralize hypothesis metadata so model runners and report builders
# stay aligned with the current Option 2 hypothesis definitions.

source("R/utils/case_configuration_functions.R")

inline_code_list_text <- function(x) {
  if (length(x) == 0L) return("")
  paste(sprintf("`%s`", x), collapse = ", ")
}

get_hypothesis_specs <- function(paths = get_project_paths()) {
  accepted_case_terms <- get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = TRUE)
  betrayal_case_terms <- get_case_configuration_term_names(reference = "Hum_x_Hum", include_control = FALSE)
  h1_relational_terms <- c(
    "judged_outgroup",
    "judged_control",
    "counterpart_outgroup",
    "counterpart_control",
    "observer_victim_outgroup"
  )
  judged_terms_full <- c("judged_outgroup", "judged_control")
  judged_terms_no_control <- c("judged_outgroup")
  judged_decision_terms_full <- paste("decision_accept", judged_terms_full, sep = ":")
  judged_decision_terms_no_control <- paste("decision_accept", judged_terms_no_control, sep = ":")
  judged_total_interactions_full <- paste("iri_total", judged_terms_full, sep = ":")
  judged_scale_interactions_full <- as.vector(
    outer(c("iri_fs", "iri_ec", "iri_pt", "iri_pd"), judged_terms_full, paste, sep = ":")
  )
  accepted_total_interactions <- get_case_configuration_interaction_terms(
    "iri_total",
    reference = "Hum_x_Hum",
    include_control = TRUE
  )
  accepted_scale_interactions <- get_case_configuration_interaction_terms(
    c("iri_fs", "iri_ec", "iri_pt", "iri_pd"),
    reference = "Hum_x_Hum",
    include_control = TRUE
  )
  control_terms <- c(
    "role_observer",
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status",
    "factor(negotiator_slot)"
  )
  analytic_control_terms <- c(
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status",
    "factor(negotiator_slot)"
  )
  judged_control_terms_full <- c(
    "decision_accept",
    "counterpart_outgroup",
    "counterpart_control",
    "observer_victim_outgroup",
    "role_observer",
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status",
    "factor(negotiator_slot)"
  )
  judged_control_terms_no_control <- c(
    "decision_accept",
    "counterpart_outgroup",
    "observer_victim_outgroup",
    "role_observer",
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status",
    "factor(negotiator_slot)"
  )
  control_rhs <- paste(control_terms, collapse = " + ")
  analytic_control_rhs <- paste(analytic_control_terms, collapse = " + ")
  accepted_case_rhs <- paste(accepted_case_terms, collapse = " + ")
  betrayal_case_rhs <- paste(betrayal_case_terms, collapse = " + ")
  accepted_total_interactions_rhs <- paste(accepted_total_interactions, collapse = " + ")
  accepted_scale_interactions_rhs <- paste(accepted_scale_interactions, collapse = " + ")
  h1_relational_rhs <- paste(h1_relational_terms, collapse = " + ")
  judged_rhs_full <- paste(c(judged_terms_full, judged_decision_terms_full, "iri_total", judged_control_terms_full), collapse = " + ")
  judged_rhs_full_scales <- paste(c(judged_terms_full, judged_decision_terms_full, "iri_fs", "iri_ec", "iri_pt", "iri_pd", judged_control_terms_full), collapse = " + ")
  judged_rhs_no_control <- paste(c(judged_terms_no_control, judged_decision_terms_no_control, "iri_total", judged_control_terms_no_control), collapse = " + ")
  judged_rhs_no_control_scales <- paste(c(judged_terms_no_control, judged_decision_terms_no_control, "iri_fs", "iri_ec", "iri_pt", "iri_pd", judged_control_terms_no_control), collapse = " + ")
  judged_empathy_rhs_full <- paste(
    c(
      "iri_total",
      judged_terms_full,
      judged_decision_terms_full,
      judged_total_interactions_full,
      judged_control_terms_full
    ),
    collapse = " + "
  )
  judged_empathy_rhs_full_scales <- paste(
    c(
      "iri_fs",
      "iri_ec",
      "iri_pt",
      "iri_pd",
      judged_terms_full,
      judged_decision_terms_full,
      judged_scale_interactions_full,
      judged_control_terms_full
    ),
    collapse = " + "
  )

  list(
    list(
      id = "H1",
      family_id = "H1",
      family_short_label = "H1: Empathy under relational controls",
      family_focus_label = "Empathy under relational controls",
      family_statement = paste(
        "Higher empathy predicts lower moral-judgment scores for harmful decisions after",
        "conditioning on judged-negotiator, counterpart, and observer-side victim relational controls."
      ),
      short_label = "H1: Empathy under relational controls",
      focus_label = "Empathy under relational controls",
      script_path = "R/hypotheses/H1_test.R",
      data_path = paths$processed_accept,
      sample_key = "accepted",
      sample_label = "Accepted decisions only",
      expected_direction = "negative",
      statement = paste(
        "Higher empathy predicts lower moral-judgment scores for harmful decisions after",
        "conditioning on judged-negotiator, counterpart, and observer-side victim relational controls."
      ),
      dependent_variable = "judgement (-9 to 9)",
      primary_terms = list(
        A = c("iri_total"),
        B = c("iri_fs", "iri_ec", "iri_pt", "iri_pd")
      ),
      case_terms = h1_relational_terms,
      model_terms = list(
        A = list(terms = c("iri_total"), description = "the composite empathy term"),
        B = list(terms = c("iri_fs", "iri_ec", "iri_pt", "iri_pd"), description = "the empathy subscale main effects")
      ),
      formula_rhs = list(
        A = paste("iri_total +", h1_relational_rhs, "+", control_rhs),
        B = paste("iri_fs + iri_ec + iri_pt + iri_pd +", h1_relational_rhs, "+", control_rhs)
      ),
      exclude_terms = c("iri_total", "iri_fs", "iri_ec", "iri_pt", "iri_pd", h1_relational_terms),
      plain_title = "H1: empatia y juicio moral controlando por relaciones del caso",
      plain_question = paste(
        "una vez tenemos en cuenta el estatus relacional del negociador juzgado,",
        "de la contraparte y de la victima cuando aplica, la empatia del participante",
        "se relaciona con el juicio moral?"
      ),
      plain_sample = "solo decisiones aceptadas.",
      plain_equation = "judgement = empatia + controles relacionales + controles demograficos",
      plain_code_equations = c(
        "Modelo A: iri_total + judged_outgroup + judged_control + counterpart_outgroup + counterpart_control + observer_victim_outgroup + role_observer + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)",
        "Modelo B: iri_fs + iri_ec + iri_pt + iri_pd + judged_outgroup + judged_control + counterpart_outgroup + counterpart_control + observer_victim_outgroup + role_observer + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)"
      ),
      plain_term_note = sprintf(
        "En H1, los controles relacionales que entran son %s.",
        inline_code_list_text(h1_relational_terms)
      )
    ),
    list(
      id = "H2a",
      family_id = "H2",
      family_short_label = "H2: Judged-status x decision contrasts",
      family_focus_label = "Judged-status x decision contrasts",
      family_statement = paste(
        "Moral-judgment severity will differ significantly as a function of relational",
        "group membership, decision outcome, and their interaction."
      ),
      short_label = "H2a: Judged-status x decision contrasts without control scenarios",
      focus_label = "Judged-status x decision contrasts without control scenarios",
      script_path = "R/hypotheses/H2a_test.R",
      data_path = paths$processed_betrayal,
      sample_key = "betrayal",
      sample_label = "Full judgment sample excluding scenarios with control-labeled negotiators",
      expected_direction = "either",
      statement = paste(
        "Moral-judgment severity should vary with the judged negotiator's",
        "ingroup-versus-outgroup status, and that relational effect should depend",
        "on whether the harmful deal was accepted or rejected."
      ),
      dependent_variable = "judgement (-9 to 9)",
      primary_terms = list(
        A = c(judged_terms_no_control, judged_decision_terms_no_control),
        B = c(judged_terms_no_control, judged_decision_terms_no_control)
      ),
      case_terms = c(judged_terms_no_control, judged_decision_terms_no_control),
      model_terms = list(
        A = list(
          terms = c(judged_terms_no_control, judged_decision_terms_no_control),
          description = "the judged-negotiator relational-status terms and their decision interaction in the non-control sample"
        ),
        B = list(
          terms = c(judged_terms_no_control, judged_decision_terms_no_control),
          description = "the judged-negotiator relational-status terms and their decision interaction in the non-control sample"
        )
      ),
      formula_rhs = list(
        A = judged_rhs_no_control,
        B = judged_rhs_no_control_scales
      ),
      exclude_terms = c(judged_terms_no_control, judged_decision_terms_no_control),
      plain_title = "H2a: estatus relacional del negociador x decision sin escenarios control",
      plain_question = paste(
        "cuando quitamos los escenarios con negociadores control, cambia el",
        "juicio segun si el negociador juzgado es ingroup u outgroup y segun",
        "si acepto o rechazo el trato danino?"
      ),
      plain_sample = "muestra completa de juicios, excluyendo escenarios con negociadores control.",
      plain_equation = "judgement = estatus del negociador juzgado + decision + estatus x decision + empatia + controles relacionales",
      plain_code_equations = c(
        "Modelo A: judged_outgroup + decision_accept + judged_outgroup:decision_accept + iri_total + counterpart_outgroup + observer_victim_outgroup + role_observer + controles",
        "Modelo B: judged_outgroup + decision_accept + judged_outgroup:decision_accept + iri_fs + iri_ec + iri_pt + iri_pd + counterpart_outgroup + observer_victim_outgroup + role_observer + controles"
      ),
      plain_term_note = "En H2a, `ingroup` es la referencia para el negociador juzgado y el termino central es la interaccion entre estatus relacional y decision."
    ),
    list(
      id = "H2b",
      family_id = "H2",
      family_short_label = "H2: Judged-status x decision contrasts",
      family_focus_label = "Judged-status x decision contrasts",
      family_statement = paste(
        "Moral-judgment severity will differ significantly as a function of relational",
        "group membership, decision outcome, and their interaction."
      ),
      short_label = "H2b: Judged-status x decision contrasts with control included",
      focus_label = "Judged-status x decision contrasts with control included",
      script_path = "R/hypotheses/H2b_test.R",
      data_path = paths$processed_judgments,
      sample_key = "analysis",
      sample_label = "Full judgment sample",
      expected_direction = "either",
      statement = paste(
        "Moral-judgment severity should vary with the judged negotiator's",
        "ingroup-versus-outgroup-versus-control status, and that relational",
        "effect should depend on whether the harmful deal was accepted or rejected."
      ),
      dependent_variable = "judgement (-9 to 9)",
      primary_terms = list(
        A = c(judged_terms_full, judged_decision_terms_full),
        B = c(judged_terms_full, judged_decision_terms_full)
      ),
      case_terms = c(judged_terms_full, judged_decision_terms_full),
      model_terms = list(
        A = list(
          terms = c(judged_terms_full, judged_decision_terms_full),
          description = "the judged-negotiator relational-status terms and their decision interaction in the full sample"
        ),
        B = list(
          terms = c(judged_terms_full, judged_decision_terms_full),
          description = "the judged-negotiator relational-status terms and their decision interaction in the full sample"
        )
      ),
      formula_rhs = list(
        A = judged_rhs_full,
        B = judged_rhs_full_scales
      ),
      exclude_terms = c(judged_terms_full, judged_decision_terms_full),
      plain_title = "H2b: estatus relacional del negociador x decision con control incluido",
      plain_question = paste(
        "cambia el juicio segun si el negociador juzgado es ingroup, outgroup o",
        "control y segun si acepto o rechazo el trato danino?"
      ),
      plain_sample = "muestra completa de juicios.",
      plain_equation = "judgement = estatus del negociador juzgado + decision + estatus x decision + empatia + controles relacionales",
      plain_code_equations = c(
        "Modelo A: judged_outgroup + judged_control + decision_accept + interacciones con decision + iri_total + controles relacionales",
        "Modelo B: judged_outgroup + judged_control + decision_accept + interacciones con decision + iri_fs + iri_ec + iri_pt + iri_pd + controles relacionales"
      ),
      plain_term_note = "En H2b, `ingroup` es la referencia para el negociador juzgado y la hipotesis central esta en los terminos de estatus relacional y su interaccion con `decision_accept`."
    ),
    list(
      id = "H3",
      family_id = "H3",
      family_short_label = "H3: Empathy x judged-status moderation",
      family_focus_label = "Empathy x judged-status moderation",
      family_statement = paste(
        "The empathy effect may vary across judged-negotiator relational status,",
        "while decision outcome and relational controls remain in the model."
      ),
      short_label = "H3: Empathy x judged-status moderation",
      focus_label = "Empathy x judged-status moderation",
      script_path = "R/hypotheses/H3_test.R",
      data_path = paths$processed_judgments,
      sample_key = "analysis",
      sample_label = "Full judgment sample",
      expected_direction = "either",
      statement = paste(
        "The empathy effect may vary according to whether the judged negotiator",
        "is ingroup, outgroup, or control, while decision outcome and the",
        "additional relational controls remain explicitly modeled."
      ),
      dependent_variable = "judgement (-9 to 9)",
      primary_terms = list(
        A = judged_total_interactions_full,
        B = judged_scale_interactions_full
      ),
      case_terms = c(judged_terms_full, judged_decision_terms_full),
      model_terms = list(
        A = list(
          terms = judged_total_interactions_full,
          description = "the composite empathy x judged-negotiator relational-status interactions"
        ),
        B = list(
          terms = judged_scale_interactions_full,
          description = "the empathy-dimension x judged-negotiator relational-status interactions"
        )
      ),
      formula_rhs = list(
        A = judged_empathy_rhs_full,
        B = judged_empathy_rhs_full_scales
      ),
      exclude_terms = c(judged_total_interactions_full, judged_scale_interactions_full),
      plain_title = "H3: interaccion entre empatia y estatus del negociador juzgado",
      plain_question = paste(
        "la relacion entre empatia y juicio cambia dependiendo del tipo de",
        "estatus relacional del negociador juzgado?"
      ),
      plain_sample = "muestra completa de juicios.",
      plain_equation = "judgement = empatia + estatus del negociador + decision + estatus x decision + empatia x estatus + controles relacionales",
      plain_code_equations = c(
        "Modelo A: iri_total + judged_outgroup + judged_control + decision_accept + interacciones con decision + iri_total:judged_outgroup + iri_total:judged_control + controles relacionales",
        "Modelo B: subescalas de empatia + judged_outgroup + judged_control + decision_accept + interacciones con decision + interacciones entre subescalas y estatus del negociador + controles relacionales"
      ),
      plain_term_note = "En H3, `ingroup` es la referencia para el negociador juzgado y las interacciones principales comparan como cambia la pendiente de empatia en outgroup y control."
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
  if (!is.null(spec$family_short_label) && nzchar(spec$family_short_label)) {
    return(spec$family_short_label)
  }
  spec$short_label
}

get_hypothesis_family_focus_label <- function(spec) {
  if (!is.null(spec$family_focus_label) && nzchar(spec$family_focus_label)) {
    return(spec$family_focus_label)
  }
  spec$focus_label
}

get_hypothesis_family_statement <- function(spec) {
  if (!is.null(spec$family_statement) && nzchar(spec$family_statement)) {
    return(spec$family_statement)
  }
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
