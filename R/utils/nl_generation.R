# R/utils/nl_generation.R
# Purpose: Generate dynamic narrative text explaining model coefficients
# Dependencies: model_functions.R

#' Helper to explain significance in plain language
describe_significance <- function(p_value, estimate) {
  if (is.na(p_value)) {
    return("the statistical significance is unclear")
  }

  if (p_value < 0.001) {
    sig <- "very strong evidence"
  } else if (p_value < 0.01) {
    sig <- "strong evidence"
  } else if (p_value < 0.05) {
    sig <- "clear evidence"
  } else if (p_value < 0.1) {
    sig <- "suggestive but inconclusive evidence"
  } else {
    sig <- "little to no evidence"
  }

  direction <- if (estimate > 0) "an increase (higher scores)" else "a decrease (lower, more severe scores)"
  
  if (p_value >= 0.05) {
    return(sprintf("indicates %s of an effect, meaning the current data doesn't reliably show a relationship for this specific variable", sig))
  } else {
    return(sprintf("indicates %s of an effect, showing that this variable leads to %s in the moral judgment", sig, direction))
  }
}

#' Helper mapping term explicitly to a natural language definition
get_term_definition <- function(term) {
  describe_case_term <- function(term_key) {
    if (!grepl("^case_[a-z]+_x_[a-z]+$", term_key)) {
      return(NULL)
    }
    case_label <- gsub("^case_", "", term_key)
    case_label <- gsub("^hum", "Hum", case_label)
    case_label <- gsub("_hum", "_Hum", case_label)
    case_label <- gsub("^ing", "Ing", case_label)
    case_label <- gsub("_ing", "_Ing", case_label)
    case_label <- gsub("^control", "Control", case_label)
    case_label <- gsub("_control", "_Control", case_label)
    sprintf(
      "whether the judged scenario matches the explicit victim x negotiator case configuration %s",
      label_case_configuration(case_label)
    )
  }

  describe_analytic_case_term <- function(term_key) {
    if (!grepl("^acfg_", term_key)) {
      return(NULL)
    }
    dummy_map <- get_analytic_case_configuration_dummy_names(include_control = TRUE)
    matched_level <- names(dummy_map)[match(term_key, unname(dummy_map))]
    if (length(matched_level) != 1L || is.na(matched_level)) {
      return(NULL)
    }
    sprintf(
      "whether the judged scenario matches the role-dependent judgment configuration %s",
      label_analytic_case_configuration(matched_level)
    )
  }

  meaning_map <- c(
    "iri_total" = "the participant's general level of empathy across all dimensions",
    "iri_fs" = "the tendency to imaginatively get involved in fictitious stories (Fantasy subscale)",
    "iri_ec" = "the tendency to feel sympathy and compassion for others (Empathic Concern subscale)",
    "iri_pt" = "the tendency to look at things from another's point of view (Perspective Taking subscale)",
    "iri_pd" = "the tendency to feel distress in uncomfortable social situations (Personal Distress subscale)",
    "target_other_same_faculty" = "whether target and other belong to the same faculty",
    "victim_target_groupIn" = "whether target is ingroup to the victim (relative to the control-labeled baseline)",
    "victim_target_groupOut" = "whether target is outgroup to the victim (relative to the control-labeled baseline)",
    "victim_other_groupIn" = "whether other is ingroup to the victim (relative to the control-labeled baseline)",
    "victim_other_groupOut" = "whether other is outgroup to the victim (relative to the control-labeled baseline)",
    "bystander_target_groupIn" = "whether target is ingroup to the bystander (relative to the control-labeled baseline)",
    "bystander_target_groupOut" = "whether target is outgroup to the bystander (relative to the control-labeled baseline)",
    "bystander_other_groupIn" = "whether other is ingroup to the bystander (relative to the control-labeled baseline)",
    "bystander_other_groupOut" = "whether other is outgroup to the bystander (relative to the control-labeled baseline)",
    "bystander_victim_groupOut" = "whether the victim is outgroup to the bystander (reference = ingroup)",
    "case_configuration" = "the relational configuration of victim and negotiator groups",
    "decision_accept" = "whether the judged target accepted the harmful deal",
    "judged_ingroup" = "whether target was ingroup rather than in the control-labeled baseline",
    "judged_outgroup" = "whether target belonged to a different faculty than the reference participant (Outgroup)",
    "judged_control" = "whether target's group affiliation was hidden from the participant (Control)",
    "counterpart_ingroup" = "whether other was ingroup rather than in the control-labeled baseline",
    "counterpart_outgroup" = "whether other belonged to a different faculty than the reference participant (Outgroup)",
    "counterpart_control" = "whether other's group affiliation was hidden from the participant (Control)",
    "observer_victim_outgroup" = "whether the victim belonged to a different faculty than the observer (Outgroup)",
    "player_victim_outgroup" = "whether the player and victim belonged to different groups",
    "perp_outgroup" = "whether the perpetrator was from a different group",
    "perp_control" = "whether the perpetrator's group was hidden",
    "victim_outgroup" = "whether the victim was from a different group",
    "role_observer" = "the bystander role where the participant observes rather than being the victim",
    "participant_engineering" = "whether the participant is from an Engineering faculty",
    "sex_man" = "being a man (relative to being a woman)",
    "age" = "the participant's age",
    "economic_status" = "the socioeconomic contextual stratum of the participant's background",
    "same_group_harm" = "whether the harm inflicted by the perpetrator targeted their own group member (betrayal)"
  )
  term_key <- canonicalize_term_name(term)
  if (term_key %in% names(meaning_map)) {
    return(meaning_map[[term_key]])
  }
  case_term <- describe_case_term(term_key)
  if (!is.null(case_term)) {
    return(case_term)
  }
  analytic_case_term <- describe_analytic_case_term(term_key)
  if (!is.null(analytic_case_term)) {
    return(analytic_case_term)
  }
  h2_structure_term <- label_h2_negotiator_structure_term(term_key)
  if (!identical(h2_structure_term, term_key)) {
    return(paste("the target-other group structure comparing", sub("^Negotiator-side structure: ", "", h2_structure_term)))
  }
  if (grepl(":", term_key, fixed = TRUE)) {
    term_parts <- strsplit(term_key, ":", fixed = TRUE)[[1]]
    return(paste(vapply(term_parts, get_term_definition, character(1)), collapse = " in combination with "))
  }
  if (grepl("^factor\\(negotiator_slot\\)", term)) {
    return("fixed effects for specific negotiator presentation order")
  }
  if (grepl("^factor\\(stage\\)", term)) {
    return("fixed effects for specific chronological evaluation stages")
  }
  return(sprintf("the term '%s'", term))
}

#' Generate fully formed narrative interpreting the tabular coefficients
generate_coefficient_narrative <- function(coef_df, model_family = "Tobit") {
  lines <- c()

  for (i in 1:nrow(coef_df)) {
    term <- coef_df$term[i]
    est <- coef_df$estimate[i]
    p_val <- coef_df$p_value[i]

    # Intercept
    if (term == "(Intercept)") {
      lines <- c(lines, sprintf(
        "Baseline judgment represents the starting moral score when all continuous variables are at their average and all group variables are at their reference levels (for active negotiator-status terms, the control-labeled condition). In this model, that baseline is estimated at %.3f (p=%.3f).",
        est,
        p_val
      ))
      next
    }
    
    # Scale
    if (term == "Log(scale)") {
      lines <- c(lines, sprintf(
        "Judgment variation (log-scale) is %.3f, which indicates the level of dispersion or noise in latent judgments. This reflects inherent variety of moral opinions across the sample.",
        est
      ))
      next
    }

    # Hide fixed effects
    if (grepl("^factor\\(negotiator_slot\\)", term)) next

    # Simplified Term labels
    term_label <- label_term(term)
    term_def <- get_term_definition(term)
    sig_desc <- describe_significance(p_val, est)

    sentence <- sprintf(
      "The variable %s (%s) has an estimated effect of %.3f. The results show %s. For example, a 1-unit increase in this variable (or moving from the reference group to this group) would shift the moral judgment by approximately %.2f points on the -9 to 9 scale.",
      term_label, term_def, est, sig_desc, est
    )
    
    # Interactions
    if (grepl(":", term, fixed = TRUE) && !is.na(p_val) && p_val < 0.1) {
      if (grepl("iri", term)) { # continuous x discrete
        interaction_context <- sprintf("Because this is a continuous-by-discrete interaction, the %s coefficient indicates that the effect of empathy on the judgment is %s for this specific condition compared to the baseline. This means the 'empathy gap' in judgment is %s here.", 
          if(est > 0) "positive" else "negative",
          if(est > 0) "strengthened (pushed higher)" else "dampened (pushed lower)",
          if(est > 0) "less severe" else "more severe"
        )
      } else { # discrete x discrete
        interaction_context <- sprintf("Because this is an interaction between two group conditions, the %s coefficient indicates that the judgment penalty or reward is %s when both conditions are present at once.",
          if(est > 0) "positive" else "negative",
          if(est > 0) "offset or reduced" else "magnified or increased"
        )
      }
      sentence <- paste(sentence, interaction_context)
    }

    lines <- c(lines, sentence)
  }

  paste(lines, collapse = " ")
}

