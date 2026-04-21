# Role-specific relational-variable construction for the longitudinal judgment dataset.
# One row remains one observed judgement on the row-dynamic target negotiator.
# The code below only enriches each existing row with contextual N1/N2 slot
# attributes; it never duplicates rows for N1 or N2, which is how the pipeline
# avoids double counting.

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

derive_same_faculty_context <- function(n1_faculty, n2_faculty) {
  ifelse(
    is.na(n1_faculty) | is.na(n2_faculty),
    NA_character_,
    ifelse(n1_faculty == n2_faculty, "same", "different")
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
  # target is row-dynamic: each observation can judge N1 or N2.
  data$target_label <- ifelse(data$target == 1, "N1", "N2")
  data$faculty_victim <- ifelse(
    data$role == 1 & is.na(data$faculty_victim),
    data$faculty_player,
    data$faculty_victim
  )

  # Reconstruct structural slots N1/N2 inside each row from target/other fields.
  # If target == 1, target already corresponds to N1; otherwise target corresponds to N2.
  data$N1_faculty <- ifelse(data$target == 1, data$faculty_target, data$faculty_other)
  data$N2_faculty <- ifelse(data$target == 1, data$faculty_other, data$faculty_target)
  data$N1_decision <- ifelse(data$target == 1, data$decision_target, data$decision_other)
  data$N2_decision <- ifelse(data$target == 1, data$decision_other, data$decision_target)

  data$N1_faculty_label <- faculty_code_to_label(data$N1_faculty)
  data$N2_faculty_label <- faculty_code_to_label(data$N2_faculty)
  data$faculty_player_label <- ifelse(
    data$faculty_player == 1,
    "Humanities",
    ifelse(
      data$faculty_player == 2,
      "Engineering",
      ifelse(data$faculty_player == 0, "Control", NA_character_)
    )
  )

  data$decision_target_label <- ifelse(
    data$decision_target == 1,
    "accept",
    ifelse(data$decision_target == 0, "reject", NA_character_)
  )
  # Historical naming note: accept_target/accept_other (legacy wording) map to
  # decision_target/decision_other (active operational names).
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
  data$target_label <- factor(data$target_label, levels = c("N1", "N2"))
  data$faculty_player_factor <- factor(
    data$faculty_player_label,
    levels = c("Humanities", "Engineering")
  )
  data$victim_N1_group <- factor(
    data$victim_N1_group,
    levels = c("ingroup", "outgroup")
  )
  data$victim_N2_group <- factor(
    data$victim_N2_group,
    levels = c("ingroup", "outgroup")
  )
  data$bystander_N1_group <- factor(
    data$bystander_N1_group,
    levels = c("ingroup", "outgroup")
  )
  data$bystander_N2_group <- factor(
    data$bystander_N2_group,
    levels = c("ingroup", "outgroup")
  )
  data$bystander_victim_group <- factor(
    data$bystander_victim_group,
    levels = c("ingroup", "outgroup")
  )
  data$N1_N2_same_faculty <- factor(
    data$N1_N2_same_faculty,
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

  enriched$victim_N1_group <- derive_group_relation(
    reference_faculty = enriched$faculty_victim,
    actor_faculty = enriched$N1_faculty
  )
  enriched$victim_N2_group <- derive_group_relation(
    reference_faculty = enriched$faculty_victim,
    actor_faculty = enriched$N2_faculty
  )
  enriched$bystander_victim_group <- ifelse(
    enriched$role_label == "bystander",
    derive_group_relation(
      reference_faculty = enriched$faculty_player,
      actor_faculty = enriched$faculty_victim
    ),
    NA_character_
  )
  enriched$bystander_N1_group <- ifelse(
    enriched$role_label == "bystander",
    derive_group_relation(
      reference_faculty = enriched$faculty_player,
      actor_faculty = enriched$N1_faculty
    ),
    NA_character_
  )
  enriched$bystander_N2_group <- ifelse(
    enriched$role_label == "bystander",
    derive_group_relation(
      reference_faculty = enriched$faculty_player,
      actor_faculty = enriched$N2_faculty
    ),
    NA_character_
  )
  enriched$N1_N2_same_faculty <- derive_same_faculty_context(
    n1_faculty = enriched$N1_faculty,
    n2_faculty = enriched$N2_faculty
  )
  enriched$N1_N2_same_faculty_binary <- ifelse(
    enriched$N1_N2_same_faculty == "same",
    1L,
    ifelse(enriched$N1_N2_same_faculty == "different", 0L, NA_integer_)
  )

  coerce_model_factors(enriched)
}
