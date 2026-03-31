# R/utils/hypothesis_metadata.R
# Purpose: Centralize hypothesis metadata so model runners and report builders
# stay aligned with the current Option 2 hypothesis definitions.

source("R/utils/case_configuration_functions.R")

inline_code_list_text <- function(x) {
  if (length(x) == 0L) return("")
  paste(sprintf("`%s`", x), collapse = ", ")
}

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
  component <- spec$primary_terms[[model_suffix]]
  resolve_subset_component(component, subset_role = subset_role)
}

get_hypothesis_model_terms <- function(spec, model_suffix, subset_role = NULL) {
  component <- spec$model_terms[[model_suffix]]
  resolve_subset_component(component, subset_role = subset_role)
}

get_hypothesis_formula_rhs <- function(spec, model_suffix, subset_role = NULL) {
  component <- spec$formula_rhs[[model_suffix]]
  resolve_subset_component(component, subset_role = subset_role)
}

get_hypothesis_specs <- function(paths = get_project_paths()) {
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
  h2_structure_terms <- get_h2_negotiator_structure_term_names(reference = "J_In__C_In", include_control = TRUE)
  h2_bystander_interactions <- paste("player_victim_outgroup", h2_structure_terms, sep = ":")
  control_terms <- c(
    "decision_accept",
    "role_observer",
    "participant_engineering",
    "sex_man",
    "age",
    "economic_status",
    "factor(negotiator_slot)"
  )
  subset_participant_control_terms <- c(
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
  subset_participant_control_rhs <- paste(subset_participant_control_terms, collapse = " + ")
  analytic_control_rhs <- paste(analytic_control_terms, collapse = " + ")
  h1_relational_rhs <- paste(h1_relational_terms, collapse = " + ")
  judged_rhs_full <- paste(c(judged_terms_full, judged_decision_terms_full, "iri_total", judged_control_terms_full), collapse = " + ")
  judged_rhs_full_scales <- paste(c(judged_terms_full, judged_decision_terms_full, "iri_fs", "iri_ec", "iri_pt", "iri_pd", judged_control_terms_full), collapse = " + ")
  judged_rhs_no_control <- paste(c(judged_terms_no_control, judged_decision_terms_no_control, "iri_total", judged_control_terms_no_control), collapse = " + ")
  judged_rhs_no_control_scales <- paste(c(judged_terms_no_control, judged_decision_terms_no_control, "iri_fs", "iri_ec", "iri_pt", "iri_pd", judged_control_terms_no_control), collapse = " + ")
  h2_victim_rhs_total <- paste(c("iri_total", h2_structure_terms, subset_participant_control_terms), collapse = " + ")
  h2_victim_rhs_scales <- paste(c("iri_fs", "iri_ec", "iri_pt", "iri_pd", h2_structure_terms, subset_participant_control_terms), collapse = " + ")
  h2_bystander_rhs_total <- paste(c("iri_total", h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions, subset_participant_control_terms), collapse = " + ")
  h2_bystander_rhs_scales <- paste(c("iri_fs", "iri_ec", "iri_pt", "iri_pd", h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions, subset_participant_control_terms), collapse = " + ")
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
        "Within the victim and bystander subsets, higher empathy predicts lower moral-judgment scores",
        "for harmful decisions after conditioning on judged-negotiator status, counterpart status,",
        "decision outcome, observer-side victim alignment when applicable, and participant controls."
      ),
      short_label = "H1: Empathy under relational controls",
      focus_label = "Empathy under relational controls",
      script_path = "R/hypotheses/H1_test.R",
      data_path = "Subset dependent (Victim or Bystander)",
      sample_key = "subset",
      sample_label = "Full role-specific target sample",
      expected_direction = "negative",
      statement = paste(
        "Within the victim and bystander subsets, higher empathy predicts lower moral-judgment scores",
        "for harmful decisions after conditioning on judged-negotiator status, counterpart status,",
        "decision outcome, observer-side victim alignment when applicable, and participant controls."
      ),
      dependent_variable = "judgement (-9 to 9)",
      primary_terms = list(
        A = c("iri_total"),
        B = c("iri_fs", "iri_ec", "iri_pt", "iri_pd")
      ),
      case_terms = h1_relational_terms,
      model_terms = list(
        A = list(
          terms = c("iri_total"),
          description = "the composite empathy term, while retaining judged and counterpart status, decision outcome, and participant controls"
        ),
        B = list(
          terms = c("iri_fs", "iri_ec", "iri_pt", "iri_pd"),
          description = "the four empathy subscale main effects, while retaining judged and counterpart status, decision outcome, and participant controls"
        )
      ),
      formula_rhs = list(
        A = paste("iri_total +", h1_relational_rhs, "+", control_rhs),
        B = paste("iri_fs + iri_ec + iri_pt + iri_pd +", h1_relational_rhs, "+", control_rhs)
      ),
      exclude_terms = c("iri_total", "iri_fs", "iri_ec", "iri_pt", "iri_pd", h1_relational_terms),
      plain_title = "H1: empatia y juicio moral controlando por relaciones del caso",
      plain_question = paste(
        "una vez tenemos en cuenta el estatus relacional del negociador juzgado,",
        "de la contraparte, la decision y la victima cuando aplica, la empatia del participante",
        "se relaciona con el juicio moral en Victima y Observador?"
      ),
      plain_sample = "Se estima por separado en Victima y Observador con la misma estructura de predictores.",
      plain_equation = paste(
        "judgement = iri_total o {iri_fs + iri_ec + iri_pt + iri_pd} + judged_outgroup + judged_control +",
        "counterpart_outgroup + counterpart_control + observer_victim_outgroup + decision_accept +",
        "participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)"
      ),
      plain_code_equations = c(
        "Modelo A: iri_total + judged_outgroup + judged_control + counterpart_outgroup + counterpart_control + observer_victim_outgroup + role_observer + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)",
        "Modelo B: iri_fs + iri_ec + iri_pt + iri_pd + judged_outgroup + judged_control + counterpart_outgroup + counterpart_control + observer_victim_outgroup + role_observer + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)"
      ),
      plain_term_note = paste(
        sprintf("En H1, los controles relacionales que entran son %s.", inline_code_list_text(h1_relational_terms)),
        "En ambos subconjuntos, el Modelo B conserva las cuatro subescalas de empatia (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`),",
        "mientras que ambos modelos retienen `decision_accept`, `sex_man`, `age` y `economic_status`.",
        "`observer_victim_outgroup` solo varia cuando aplica y `role_observer` queda fijo dentro de cada subconjunto."
      )
    ),
    list(
      id = "H2",
      family_id = "H2",
      family_short_label = "H2: Negotiator-side relational structure",
      family_focus_label = "Negotiator-side relational structure",
      family_statement = paste(
        "Moral-judgment severity will differ as a function of the judgment-level",
        "ingroup/outgroup/control structure of the judged and counterpart negotiators,",
        "with an additional player-victim alignment interaction in the bystander subset."
      ),
      short_label = "H2: Negotiator-side relational structure",
      focus_label = "Negotiator-side relational structure",
      script_path = "R/hypotheses/H2_test.R",
      data_path = "Subset dependent (Victim or Bystander)",
      sample_key = "subset",
      sample_label = "Full role-specific target sample",
      expected_direction = "either",
      statement = paste(
        "Moral-judgment severity should vary with the judgment-level ingroup/outgroup/control",
        "structure of the judged and counterpart negotiators. In the bystander subset,",
        "that negotiator-side structure should further depend on whether the player and the victim",
        "share faculty or not."
      ),
      dependent_variable = "judgement (-9 to 9)",
      primary_terms = list(
        A = list(
          Victim = h2_structure_terms,
          Bystander = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions)
        ),
        B = list(
          Victim = h2_structure_terms,
          Bystander = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions)
        )
      ),
      case_terms = h2_structure_terms,
      model_terms = list(
        A = list(
          Victim = list(
            terms = h2_structure_terms,
            description = "the negotiator-side ingroup/outgroup/control structure dummies in the victim subset"
          ),
          Bystander = list(
            terms = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions),
            description = "the negotiator-side structure, player-victim outgroup term, and their interaction in the bystander subset"
          )
        ),
        B = list(
          Victim = list(
            terms = h2_structure_terms,
            description = "the negotiator-side ingroup/outgroup/control structure dummies in the victim subset"
          ),
          Bystander = list(
            terms = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions),
            description = "the negotiator-side structure, player-victim outgroup term, and their interaction in the bystander subset"
          )
        )
      ),
      formula_rhs = list(
        A = list(
          Victim = h2_victim_rhs_total,
          Bystander = h2_bystander_rhs_total
        ),
        B = list(
          Victim = h2_victim_rhs_scales,
          Bystander = h2_bystander_rhs_scales
        )
      ),
      exclude_terms = c(h2_structure_terms, "player_victim_outgroup", h2_bystander_interactions),
      plain_title = "H2: estructura relacional del juicio por negociador",
      plain_question = paste(
        "cambia el juicio moral cuando cambia la estructura conjunta del negociador juzgado",
        "y de la contraparte, y en Observador ademas cuando cambia la relacion entre jugador y victima?"
      ),
      plain_sample = paste(
        "Se estima por separado en Victima y Observador. Cada participante juzga dos veces por escenario,",
        "una vez por cada negociador, asi que H2 siempre trabaja al nivel juicio-por-negociador."
      ),
      plain_equation = paste(
        "Victima: judgement = estructura conjunta {juzgado, contraparte} + empatia + controles;",
        "Observador: judgement = estructura conjunta {juzgado, contraparte} + jugador-victima +",
        "estructura x jugador-victima + empatia + controles"
      ),
      plain_code_equations = c(
        "Victima, Modelo A: all h2_negstruct_* dummies + iri_total + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)",
        "Victima, Modelo B: all h2_negstruct_* dummies + iri_fs + iri_ec + iri_pt + iri_pd + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)",
        "Observador, Modelo A: all h2_negstruct_* dummies + player_victim_outgroup + player_victim_outgroup:h2_negstruct_* + iri_total + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)",
        "Observador, Modelo B: all h2_negstruct_* dummies + player_victim_outgroup + player_victim_outgroup:h2_negstruct_* + iri_fs + iri_ec + iri_pt + iri_pd + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)"
      ),
      plain_term_note = paste(
        "La referencia de H2 es `J_In__C_In`, es decir, negociador juzgado ingroup y contraparte ingroup.",
        "En Observador, `player_victim_outgroup` compara victima outgroup contra victima ingroup,",
        "y las interacciones prueban si el efecto de la estructura negociador-contraparte cambia segun esa relacion jugador-victima."
      )
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
      data_path = "Subset dependent (Victim or Bystander)",
      sample_key = "subset",
      sample_label = "Full role-specific target sample",
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
      plain_sample = "Depende del subconjunto (Victima u Observador).",
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
