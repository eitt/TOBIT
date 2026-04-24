# Formula catalog for H1-H5 under the longitudinal repeated-measures redesign.

source("R/00_config.R")

build_hypothesis_formula_catalog <- function() {
  empathy_terms <- paste(get_empathy_terms(), collapse = " + ")
  empathy_group_terms_victim <- paste(
    c(
      "iri_fs:victim_target_group",
      "iri_fs:victim_other_group",
      "iri_ec:victim_target_group",
      "iri_ec:victim_other_group",
      "iri_pt:victim_target_group",
      "iri_pt:victim_other_group",
      "iri_pd:victim_target_group",
      "iri_pd:victim_other_group"
    ),
    collapse = " + "
  )
  empathy_group_terms_bystander <- paste(
    c(
      "iri_fs:bystander_victim_group",
      "iri_fs:bystander_target_group",
      "iri_fs:bystander_other_group",
      "iri_ec:bystander_victim_group",
      "iri_ec:bystander_target_group",
      "iri_ec:bystander_other_group",
      "iri_pt:bystander_victim_group",
      "iri_pt:bystander_target_group",
      "iri_pt:bystander_other_group",
      "iri_pd:bystander_victim_group",
      "iri_pd:bystander_target_group",
      "iri_pd:bystander_other_group"
    ),
    collapse = " + "
  )
  sociodemographic_terms <- paste(
    c(get_sociodemographic_terms(), "factor(session)"),
    collapse = " + "
  )

  victim_group_block <- paste(
    c(
      "victim_target_group",
      "victim_other_group",
      "victim_target_group:victim_other_group",
      "target_other_same_faculty"
    ),
    collapse = " + "
  )

  bystander_group_block <- paste(
    c(
      "bystander_victim_group",
      "bystander_target_group",
      "bystander_other_group",
      "victim_target_group",
      "victim_other_group",
      "bystander_target_group:bystander_other_group",
      "victim_target_group:victim_other_group",
      "target_other_same_faculty"
    ),
    collapse = " + "
  )

  accept_block <- "accept_target * accept_other"

  data.frame(
    hypothesis = c(
      rep("H1", 2),
      rep("H2", 2),
      rep("H3", 2),
      rep("H4", 2),
      rep("H5", 2)
    ),
    role = rep(c("Victim", "Bystander"), 5),
    formula_rhs = c(
      paste(empathy_terms, accept_block, sociodemographic_terms, sep = " + "),
      paste(empathy_terms, accept_block, sociodemographic_terms, sep = " + "),
      paste(victim_group_block, accept_block, sociodemographic_terms, sep = " + "),
      paste(bystander_group_block, accept_block, sociodemographic_terms, sep = " + "),
      paste(empathy_terms, victim_group_block, empathy_group_terms_victim, accept_block, sociodemographic_terms, sep = " + "),
      paste(empathy_terms, bystander_group_block, empathy_group_terms_bystander, accept_block, sociodemographic_terms, sep = " + "),
      paste(accept_block, sociodemographic_terms, sep = " + "),
      paste(accept_block, sociodemographic_terms, sep = " + "),
      paste(empathy_terms, victim_group_block, empathy_group_terms_victim, accept_block, sociodemographic_terms, sep = " + "),
      paste(empathy_terms, bystander_group_block, empathy_group_terms_bystander, accept_block, sociodemographic_terms, sep = " + ")
    ),
    theoretical_focus = c(
      "Empathy dimensions with the common accept_target x accept_other adjustment and sociodemographics.",
      "Empathy dimensions with the common accept_target x accept_other adjustment and sociodemographics.",
      "Victim-side ingroup/outgroup structure with the allowed target x other relational interaction and the common accept_target x accept_other adjustment.",
      "Bystander-side relational structure with explicit bystander-victim, bystander-target, bystander-other, target/other context terms, and the common accept_target x accept_other adjustment.",
      "Empathy plus victim-side relational structure, including empathy x victim-target and empathy x victim-other interactions, with the common accept_target x accept_other adjustment.",
      "Empathy plus bystander-side relational structure, including empathy x bystander-victim and empathy x bystander-target/other interactions, with the common accept_target x accept_other adjustment.",
      "Target and other negotiator acceptance terms with their interaction, plus sociodemographics.",
      "Target and other negotiator acceptance terms with their interaction, plus sociodemographics.",
      "Integrated model with empathy, victim-side relations, empathy x group interactions, acceptance terms, and the victim-side target/other interaction.",
      "Integrated model with empathy, bystander-side relations, empathy x group interactions, acceptance terms, and role-specific target/other relational interactions."
    ),
    random_effects_primary = "Two-sided Tobit with factor(session) and cluster-robust standard errors by participant id.",
    random_effects_sensitivity = "The production branch keeps factor(session) plus participant-cluster robust inference; a fully mixed Tobit with random participant and session intercepts is documented as a methodological limitation rather than silently substituted.",
    stringsAsFactors = FALSE
  )
}

get_hypothesis_rhs <- function(hypothesis_id, role_label) {
  catalog <- build_hypothesis_formula_catalog()
  matched_row <- catalog[
    catalog$hypothesis == hypothesis_id & catalog$role == role_label,
    ,
    drop = FALSE
  ]
  if (nrow(matched_row) != 1L) {
    stop(
      sprintf("Formula not found for %s / %s.", hypothesis_id, role_label),
      call. = FALSE
    )
  }
  matched_row$formula_rhs[[1]]
}

write_formula_catalog <- function(paths = get_project_paths()) {
  catalog <- build_hypothesis_formula_catalog()
  write.csv(
    catalog,
    file.path(paths$formulas_dir, "hypothesis_formula_catalog.csv"),
    row.names = FALSE
  )
  write.csv(
    catalog,
    file.path(paths$tables_dir, "hypothesis_formula_catalog.csv"),
    row.names = FALSE
  )
  invisible(catalog)
}
