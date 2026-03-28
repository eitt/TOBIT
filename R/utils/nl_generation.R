# R/utils/nl_generation.R
# Purpose: Generate dynamic narrative text explaining Tobit and CLAD model coefficients
# Dependencies: model_functions.R

# Helper to explain p-value significance
describe_significance <- function(p_value, estimate) {
  if (is.na(p_value)) {
    return("the p-value cannot be determined")
  }

  if (p_value < 0.001) {
    sig <- "highly statistically significant"
  } else if (p_value < 0.01) {
    sig <- "statistically significant"
  } else if (p_value < 0.05) {
    sig <- "statistically significant"
  } else if (p_value < 0.1) {
    sig <- "marginally significant"
  } else {
    sig <- "not statistically significant"
  }

  direction <- if (estimate > 0) "a positive effect" else "a negative effect"
  if (p_value >= 0.05) {
    return(sprintf("indicates the effect is %s, meaning we do not have enough evidence to reject the null hypothesis for this vector", sig))
  } else {
    return(sprintf("indicates %s, meaning the predictor has %s on the latent moral judgment", sig, direction))
  }
}

# Helper mapping term explicitly to a natural language definition for insertion into a sentence
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

  meaning_map <- c(
    "iri_total" = "the average composite of empathetic propensity across the participant",
    "iri_fs" = "the participant's inclination to transpose themselves imaginatively into the feelings of fictitious characters (Fantasy scale)",
    "iri_ec" = "the participant's tendency to experience feelings of sympathy and compassion for unfortunate others (Empathic Concern)",
    "iri_pt" = "the participant's tendency to spontaneously adopt the psychological point of view of others (Perspective Taking)",
    "iri_pd" = "the participant's tendency to experience distress and discomfort in tense interpersonal settings (Personal Distress)",
    "case_configuration" = "the explicit victim x negotiator case-configuration factor used in Option 2 relational modeling",
    "case_configuration_role" = "the victim x negotiator case configuration further conditioned by participant role (Observer or Victim)",
    "case_configuration_decision" = "the victim x negotiator case configuration further conditioned by decision context (Accept or Reject)",
    "case_configuration_context" = "the full victim x negotiator case configuration further conditioned by both role and decision context",
    "perp_outgroup" = "whether the perpetrator belonged to a faculty different from the participant (Outgroup)",
    "perp_control" = "whether the perpetrator's organizational alignment was explicitly hidden (Control label)",
    "victim_outgroup" = "whether the victim was affiliated with a different faculty than the participant",
    "iri_total:perp_outgroup" = "the combined interaction effect between overall empathy and an outgroup perpetrator",
    "iri_total:perp_control" = "the combined interaction effect between overall empathy and an unidentified perpetrator",
    "iri_fs:perp_outgroup" = "the combined interaction effect between the Fantasy scale and an outgroup perpetrator",
    "iri_fs:perp_control" = "the combined interaction effect between the Fantasy scale and an unidentified perpetrator",
    "iri_ec:perp_outgroup" = "the combined interaction effect between Empathic Concern and an outgroup perpetrator",
    "iri_ec:perp_control" = "the combined interaction effect between Empathic Concern and an unidentified perpetrator",
    "iri_pt:perp_outgroup" = "the combined interaction effect between Perspective Taking and an outgroup perpetrator",
    "iri_pt:perp_control" = "the combined interaction effect between Perspective Taking and an unidentified perpetrator",
    "iri_pd:perp_outgroup" = "the combined interaction effect between Personal Distress and an outgroup perpetrator",
    "iri_pd:perp_control" = "the combined interaction effect between Personal Distress and an unidentified perpetrator",
    "role_observer" = "the procedural role where the participant acted exclusively as an observer rather than a victim",
    "participant_engineering" = "whether the participant belonged to the Engineering faculty as opposed to Humanities",
    "sex_man" = "whether the participant identified as a man instead of a woman",
    "age" = "the participant's biological age in years",
    "economic_status" = "the socioeconomic contextual stratum of the participant's background",
    "same_group_harm" = "whether the harm inflicted by the perpetrator targeted a victim from their own faculty (Ingroup Betrayal)"
  )
  term_key <- canonicalize_term_name(term)
  if (term_key %in% names(meaning_map)) {
    return(meaning_map[[term_key]])
  }
  case_term <- describe_case_term(term_key)
  if (!is.null(case_term)) {
    return(case_term)
  }
  if (grepl(":", term_key, fixed = TRUE)) {
    term_parts <- strsplit(term_key, ":", fixed = TRUE)[[1]]
    return(paste(vapply(term_parts, get_term_definition, character(1)), collapse = " interacted with "))
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

    # Handle the standard intercepts and scales that bounded-outcome models produce.
    if (term == "(Intercept)") {
      lines <- c(lines, sprintf(
        if (model_family == "CLAD") {
          "The Intercept represents the baseline conditional median latent moral judgment when all continuous predictors are zero and categorical predictors are at their reference levels. In this model, that baseline median is estimated at %.3f (p=%.3f)."
        } else {
          "The Intercept represents the baseline latent moral judgment when all continuous predictors are zero and categorical predictors are at their reference levels. In this model, the baseline is estimated at %.3f (p=%.3f)."
        },
        est,
        p_val
      ))
      next
    }
    if (term == "Log(scale)") {
      lines <- c(lines, sprintf(
        "The Log(scale) is a standard Tobit variance parameter representing the natural logarithm of the standard deviation of the unobserved residuals. The estimated scale parameter log is %.3f, capturing the underlying dispersion of latent judgments.",
        est
      ))
      next
    }

    # Skip fixed effect slot outputs to avoid cluttering narrative
    if (grepl("^factor\\(negotiator_slot\\)", term)) next

    # Dynamic Natural Language construction
    term_def <- get_term_definition(term)
    sig_desc <- describe_significance(p_val, est)

    sentence <- sprintf(
      "The term %s (representing %s) has an estimated $\\beta$ coefficient of %.3f. The p-value of %.3f %s.",
      term, term_def, est, p_val, sig_desc
    )
    lines <- c(lines, sentence)
  }

  paste(lines, collapse = " ")
}
