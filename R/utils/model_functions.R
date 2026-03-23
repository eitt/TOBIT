# R/utils/model_functions.R
# Purpose: Translation of terms and implementation of interval-censored Tobit behavior.
# Dependencies: survival

#' Translates coefficient names to readable titles
label_term <- function(term) {
  direct_map <- c(
    "(Intercept)" = "Intercept",
    "iri_total_z" = "Empathy composite (z)",
    "iri_total" = "Empathy composite (average)",
    "iri_fs" = "Empathy: Fantasy scale",
    "iri_ec" = "Empathy: Empathic concern",
    "iri_pt" = "Empathy: Perspective taking",
    "iri_pd" = "Empathy: Personal distress",
    "Log(scale)" = "Scale variance (log)",
    "perp_outgroup" = "Outgroup perpetrator (ref = ingroup)",
    "perp_control" = "Control label hidden (ref = ingroup)",
    "victim_outgroup" = "Victim outgroup (ref = ingroup)",
    "iri_total_z:perp_outgroup" = "Empathy x outgroup perpetrator",
    "iri_total_z:perp_control" = "Empathy x control label hidden",
    "iri_total:perp_outgroup" = "Empathy x outgroup perpetrator",
    "iri_total:perp_control" = "Empathy x control label hidden",
    "iri_fs:perp_outgroup" = "Fantasy x outgroup perpetrator",
    "iri_fs:perp_control" = "Fantasy x control label hidden",
    "iri_ec:perp_outgroup" = "Empathic concern x outgroup perpetrator",
    "iri_ec:perp_control" = "Empathic concern x control label hidden",
    "iri_pt:perp_outgroup" = "Perspective taking x outgroup perpetrator",
    "iri_pt:perp_control" = "Perspective taking x control label hidden",
    "iri_pd:perp_outgroup" = "Personal distress x outgroup perpetrator",
    "iri_pd:perp_control" = "Personal distress x control label hidden",
    "role_observer" = "Observer role (ref = victim)",
    "participant_engineering" = "Engineering participant (ref = humanities)",
    "sex_man" = "Man (ref = woman)",
    "age" = "Age",
    "economic_status" = "Socioeconomic status",
    "same_group_harm" = "Negotiator and victim share faculty",
    "decision_accept" = "Negotiator accepted harmful deal"
  )
  
  if (term %in% names(direct_map)) return(unname(direct_map[[term]]))
  if (grepl("^factor\\(stage\\)", term)) {
    return(paste0("Stage ", sub("^factor\\(stage\\)", "", term), " (ref = stage 1)"))
  }
  if (grepl("^factor\\(negotiator_slot\\)", term)) {
    return(paste0("Negotiator ", sub("^factor\\(negotiator_slot\\)", "", term), " (ref = negotiator 1)"))
  }
  term
}

#' Pull coefficients and CI bounds from a survival reg object
extract_model_table <- function(model_fit) {
  summary_obj <- summary(model_fit)
  table_matrix <- summary_obj$table
  model_df <- data.frame(
    term = rownames(table_matrix),
    estimate = table_matrix[, 1],
    std_error = table_matrix[, 2],
    naive_se = table_matrix[, 3],
    z_value = table_matrix[, 4],
    p_value = table_matrix[, 5],
    stringsAsFactors = FALSE
  )
  model_df$conf_low <- model_df$estimate - 1.96 * model_df$std_error
  model_df$conf_high <- model_df$estimate + 1.96 * model_df$std_error
  model_df$label <- vapply(model_df$term, label_term, character(1))
  model_df
}

#' Model-level fit information
extract_model_stats <- function(model_fit, model_data, model_label) {
  loglik_values <- model_fit$loglik
  pseudo_r2 <- NA_real_
  if (!is.null(loglik_values) && length(loglik_values) == 2L && !isTRUE(all.equal(loglik_values[1], 0))) {
    pseudo_r2 <- 1 - (loglik_values[2] / loglik_values[1])
  }
  data.frame(
    Model = model_label,
    Observations = nrow(model_data),
    Participants = length(unique(model_data$id)),
    LowerBoundCensored = sum(model_data$judgement <= -9, na.rm = TRUE),
    UpperBoundCensored = sum(model_data$judgement >= 9, na.rm = TRUE),
    LogLik = as.numeric(stats::logLik(model_fit)),
    AIC = stats::AIC(model_fit),
    PseudoR2 = pseudo_r2,
    stringsAsFactors = FALSE
  )
}

#' Fit interval-censored clustered Tobit model
#' Model treats values at -9 as left-censored and 9 as right-censored.
fit_clustered_tobit <- function(data, rhs_formula) {
  model_data <- data
  model_data$lower_endpoint <- ifelse(model_data$judgement <= -9, -Inf, model_data$judgement)
  model_data$upper_endpoint <- ifelse(model_data$judgement >= 9, Inf, model_data$judgement)
  
  formula_obj <- stats::as.formula(
    paste("survival::Surv(lower_endpoint, upper_endpoint, type = 'interval2') ~", rhs_formula)
  )
  
  survival::survreg(
    formula = formula_obj,
    data = model_data,
    dist = "gaussian",
    robust = TRUE,
    cluster = model_data$id,
    model = TRUE,
    x = TRUE,
    y = TRUE
  )
}

get_term_row <- function(model_table, term_name) {
  model_table[model_table$term == term_name, , drop = FALSE]
}

#' Test Tobit residuals for normality
test_tobit_normality <- function(model_fit) {
  # Deviance residuals from survreg offer a mechanism to assess normality assumption
  res <- stats::residuals(model_fit, type = "deviance")
  
  # Shapiro-Wilk requires a sample size between 3 and 5000.
  sample_size <- min(5000, length(res))
  set.seed(42)  # for reproducible subsampling if needed
  res_sub <- if (length(res) > 5000) sample(res, 5000) else res
  
  sw_test <- stats::shapiro.test(res_sub)
  
  if (sw_test$p.value < 0.05) {
    return(sprintf(
      "The Shapiro-Wilk test on the deviance residuals indicates a violation of the normality assumption (W = %.3f, p = %.3e). Consequently, standard clustered errors might be inefficient. For maximum robustness in future analyses, we recommend exploring a non-parametric alternative such as Censored Least Absolute Deviations (CLAD) or specifying bootstrapped standard errors for the Tobit estimator.",
      sw_test$statistic, sw_test$p.value
    ))
  } else {
    return(sprintf(
      "The Shapiro-Wilk test on the deviance residuals suggests that the assumption of normally distributed latent errors is adequately met (W = %.3f, p = %.3f). The parametric Tobit bounds are statistically justified.",
      sw_test$statistic, sw_test$p.value
    ))
  }
}
