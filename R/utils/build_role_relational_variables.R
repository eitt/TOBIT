# Role-specific relational-variable construction for the longitudinal judgment dataset.
# One row remains one observed judgement on the row-dynamic target negotiator.
# The analytical outputs in this module are expressed with target/other semantics.

faculty_code_to_label <- function(x) {
  ifelse(
    is.na(x),
    NA_character_,
    ifelse(
      x == 1,
      "Humanities",
      ifelse(x == 2, "Engineering", ifelse(x == 0, "Control", NA_character_))
    )
  )
}

derive_group_relation <- function(reference_faculty, actor_faculty) {
  ifelse(
    is.na(reference_faculty) | is.na(actor_faculty),
    NA_character_,
    ifelse(reference_faculty == actor_faculty, "ingroup", "outgroup")
  )
}

derive_same_faculty_context <- function(target_faculty, other_faculty) {
  ifelse(
    is.na(target_faculty) | is.na(other_faculty),
    NA_character_,
    ifelse(target_faculty == other_faculty, "same", "different")
  )
}

derive_decision_pattern <- function(decision_target, decision_other) {
  ifelse(
    is.na(decision_target) | is.na(decision_other),
    NA_character_,
    ifelse(
      decision_target == 1 & decision_other == 1,
      "both_accept",
      ifelse(
        decision_target == 0 & decision_other == 0,
        "both_reject",
        ifelse(
          decision_target == 1 & decision_other == 0,
          "target_accept_other_reject",
          "target_reject_other_accept"
        )
      )
    )
  )
}

add_negotiator_context_columns <- function(data) {
  data$role_label <- ifelse(data$role == 1, "victim", "bystander")
  data$target_code_label <- ifelse(
    data$target == 1,
    "target_code_1",
    ifelse(data$target == 2, "target_code_2", NA_character_)
  )
  data$faculty_victim <- ifelse(
    data$role == 1 & is.na(data$faculty_victim),
    data$faculty_player,
    data$faculty_victim
  )

  # Analytical context is fully target/other.
  data$target_faculty <- data$faculty_target
  data$other_faculty <- data$faculty_other
  data$target_faculty_label <- faculty_code_to_label(data$target_faculty)
  data$other_faculty_label <- faculty_code_to_label(data$other_faculty)
  data$faculty_player_label <- faculty_code_to_label(data$faculty_player)

  data$decision_target_label <- ifelse(
    data$decision_target == 1,
    "accept",
    ifelse(data$decision_target == 0, "reject", NA_character_)
  )
  # Historical naming bridge: accept_target/accept_other (legacy wording)
  # map to decision_target/decision_other (active operational names).
  data$decision_other_label <- ifelse(
    data$decision_other == 1,
    "accept",
    ifelse(data$decision_other == 0, "reject", NA_character_)
  )
  data$decision_pattern <- derive_decision_pattern(
    data$decision_target,
    data$decision_other
  )

  data
}

coerce_model_factors <- function(data) {
  data$id <- factor(data$id)
  data$session <- factor(data$session)
  data$id_case <- factor(data$id_case)
  data$role_label <- factor(data$role_label, levels = c("victim", "bystander"))
  data$target_code_label <- factor(data$target_code_label, levels = c("target_code_1", "target_code_2"))
  data$faculty_player_factor <- factor(
    data$faculty_player_label,
    levels = c("Humanities", "Engineering")
  )
  data$victim_target_group <- factor(
    data$victim_target_group,
    levels = c("ingroup", "outgroup")
  )
  data$victim_other_group <- factor(
    data$victim_other_group,
    levels = c("ingroup", "outgroup")
  )
  data$bystander_target_group <- factor(
    data$bystander_target_group,
    levels = c("ingroup", "outgroup")
  )
  data$bystander_other_group <- factor(
    data$bystander_other_group,
    levels = c("ingroup", "outgroup")
  )
  data$bystander_victim_group <- factor(
    data$bystander_victim_group,
    levels = c("ingroup", "outgroup")
  )
  data$target_other_same_faculty <- factor(
    data$target_other_same_faculty,
    levels = c("different", "same")
  )
  data$decision_pattern <- factor(
    data$decision_pattern,
    levels = c(
      "both_reject",
      "target_reject_other_accept",
      "target_accept_other_reject",
      "both_accept"
    )
  )
  data
}

build_role_relational_variables <- function(data) {
  enriched <- add_negotiator_context_columns(data)

  enriched$victim_target_group <- derive_group_relation(
    reference_faculty = enriched$faculty_victim,
    actor_faculty = enriched$target_faculty
  )
  enriched$victim_other_group <- derive_group_relation(
    reference_faculty = enriched$faculty_victim,
    actor_faculty = enriched$other_faculty
  )
  enriched$bystander_victim_group <- ifelse(
    enriched$role_label == "bystander",
    derive_group_relation(
      reference_faculty = enriched$faculty_player,
      actor_faculty = enriched$faculty_victim
    ),
    NA_character_
  )
  enriched$bystander_target_group <- ifelse(
    enriched$role_label == "bystander",
    derive_group_relation(
      reference_faculty = enriched$faculty_player,
      actor_faculty = enriched$target_faculty
    ),
    NA_character_
  )
  enriched$bystander_other_group <- ifelse(
    enriched$role_label == "bystander",
    derive_group_relation(
      reference_faculty = enriched$faculty_player,
      actor_faculty = enriched$other_faculty
    ),
    NA_character_
  )
  enriched$target_other_same_faculty <- derive_same_faculty_context(
    target_faculty = enriched$target_faculty,
    other_faculty = enriched$other_faculty
  )
  enriched$target_other_same_faculty_binary <- ifelse(
    enriched$target_other_same_faculty == "same",
    1L,
    ifelse(enriched$target_other_same_faculty == "different", 0L, NA_integer_)
  )

  coerce_model_factors(enriched)
}
