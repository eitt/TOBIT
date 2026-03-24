# R/utils/model_functions.R
# Purpose: Translation of terms and implementation of interval-censored Tobit and CLAD behavior.
# Dependencies: survival, ctqr

canonicalize_term_name <- function(term) {
  if (!grepl(":", term, fixed = TRUE)) {
    return(term)
  }

  term_parts <- strsplit(term, ":", fixed = TRUE)[[1]]
  if (length(term_parts) != 2L) {
    return(term)
  }

  paste(sort(term_parts), collapse = ":")
}

#' Translates coefficient names to readable titles
label_term <- function(term) {
  direct_map <- c(
    "(Intercept)" = "Intercept",
    "iri_total" = "Empathy composite (average)",
    "iri_fs" = "Empathy: Fantasy scale",
    "iri_ec" = "Empathy: Empathic concern",
    "iri_pt" = "Empathy: Perspective taking",
    "iri_pd" = "Empathy: Personal distress",
    "Log(scale)" = "Scale variance (log)",
    "perp_outgroup" = "Outgroup perpetrator (ref = ingroup)",
    "perp_control" = "Control label hidden (ref = ingroup)",
    "victim_outgroup" = "Victim outgroup (ref = ingroup)",
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

  term_key <- canonicalize_term_name(term)
  if (term_key %in% names(direct_map)) {
    return(unname(direct_map[[term_key]]))
  }
  if (grepl("^factor\\(stage\\)", term)) {
    return(paste0("Stage ", sub("^factor\\(stage\\)", "", term), " (ref = stage 1)"))
  }
  if (grepl("^factor\\(negotiator_slot\\)", term)) {
    return(paste0("Negotiator ", sub("^factor\\(negotiator_slot\\)", "", term), " (ref = negotiator 1)"))
  }
  term
}

#' Prepare interval-censored endpoints for bounded judgement outcomes.
prepare_interval_model_data <- function(data) {
  model_data <- data
  model_data$lower_endpoint <- ifelse(model_data$judgement <= -9, -Inf, model_data$judgement)
  model_data$upper_endpoint <- ifelse(model_data$judgement >= 9, Inf, model_data$judgement)
  model_data
}

build_interval_formula <- function(response_lhs, rhs_formula) {
  stats::as.formula(paste(response_lhs, "~", rhs_formula))
}

get_model_family <- function(model_fit) {
  if (inherits(model_fit, "ctqr")) {
    return("CLAD")
  }
  "Tobit"
}

get_model_response_shift <- function(model_fit) {
  if (is.null(model_fit$response_shift)) {
    return(0)
  }
  as.numeric(model_fit$response_shift)
}

#' Pull coefficients and CI bounds from a survreg Tobit object.
extract_tobit_model_table <- function(model_fit) {
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
  model_df$approach <- "Tobit"
  model_df
}

#' Pull coefficients and CI bounds from an interval-censored median regression (CLAD) object.
extract_clad_model_table <- function(model_fit) {
  coef_values <- stats::coef(model_fit)
  if (is.matrix(coef_values)) {
    coef_values <- coef_values[, 1]
  }
  coef_values <- as.numeric(coef_values)
  names(coef_values) <- names(stats::coef(model_fit))

  if ("(Intercept)" %in% names(coef_values)) {
    coef_values["(Intercept)"] <- coef_values["(Intercept)"] - get_model_response_shift(model_fit)
  }

  covar <- model_fit$covar
  if (is.list(covar)) {
    covar <- covar[[1]]
  }

  std_error <- rep(NA_real_, length(coef_values))
  names(std_error) <- names(coef_values)

  if (!is.null(covar)) {
    covar_mat <- as.matrix(covar)
    if (!is.null(rownames(covar_mat)) && !is.null(colnames(covar_mat))) {
      common_terms <- intersect(names(coef_values), rownames(covar_mat))
      if (length(common_terms) > 0L) {
        std_error[common_terms] <- sqrt(pmax(diag(covar_mat[common_terms, common_terms, drop = FALSE]), 0))
      }
    } else if (nrow(covar_mat) == length(coef_values)) {
      std_error[] <- sqrt(pmax(diag(covar_mat), 0))
    }
  }

  z_value <- coef_values / std_error
  p_value <- 2 * stats::pnorm(abs(z_value), lower.tail = FALSE)

  model_df <- data.frame(
    term = names(coef_values),
    estimate = unname(coef_values),
    std_error = unname(std_error),
    naive_se = NA_real_,
    z_value = unname(z_value),
    p_value = unname(p_value),
    stringsAsFactors = FALSE
  )
  model_df$conf_low <- model_df$estimate - 1.96 * model_df$std_error
  model_df$conf_high <- model_df$estimate + 1.96 * model_df$std_error
  model_df$label <- vapply(model_df$term, label_term, character(1))
  model_df$approach <- "CLAD"
  model_df
}

extract_model_table <- function(model_fit) {
  if (inherits(model_fit, "ctqr")) {
    return(extract_clad_model_table(model_fit))
  }
  extract_tobit_model_table(model_fit)
}

#' Model-level fit information for Tobit.
extract_tobit_model_stats <- function(model_fit, model_data, model_label) {
  loglik_values <- model_fit$loglik
  pseudo_r2 <- NA_real_
  if (!is.null(loglik_values) && length(loglik_values) == 2L && !isTRUE(all.equal(loglik_values[1], 0))) {
    pseudo_r2 <- 1 - (loglik_values[2] / loglik_values[1])
  }
  data.frame(
    Model = model_label,
    Approach = "Tobit",
    Observations = nrow(model_data),
    Participants = length(unique(model_data$id)),
    LowerBoundCensored = sum(model_data$judgement <= -9, na.rm = TRUE),
    UpperBoundCensored = sum(model_data$judgement >= 9, na.rm = TRUE),
    LogLik = as.numeric(stats::logLik(model_fit)),
    AIC = stats::AIC(model_fit),
    PseudoR2 = pseudo_r2,
    Quantile = NA_real_,
    Converged = if (!is.null(model_fit$fail)) !isTRUE(model_fit$fail) else NA,
    Iterations = if (!is.null(model_fit$iter)) as.integer(model_fit$iter) else NA_integer_,
    Status = "completed",
    ErrorMessage = NA_character_,
    stringsAsFactors = FALSE
  )
}

#' Model-level fit information for CLAD.
extract_clad_model_stats <- function(model_fit, model_data, model_label) {
  converged <- if (!is.null(model_fit$converged)) as.logical(model_fit$converged[1]) else NA
  iterations <- if (!is.null(model_fit$n.it)) as.integer(model_fit$n.it[1]) else NA_integer_
  data.frame(
    Model = model_label,
    Approach = "CLAD",
    Observations = nrow(model_data),
    Participants = length(unique(model_data$id)),
    LowerBoundCensored = sum(model_data$judgement <= -9, na.rm = TRUE),
    UpperBoundCensored = sum(model_data$judgement >= 9, na.rm = TRUE),
    LogLik = NA_real_,
    AIC = NA_real_,
    PseudoR2 = NA_real_,
    Quantile = if (!is.null(model_fit$quantile_target)) as.numeric(model_fit$quantile_target[1]) else 0.5,
    Converged = converged,
    Iterations = iterations,
    Status = if (isTRUE(converged)) "completed" else "not_converged",
    ErrorMessage = NA_character_,
    stringsAsFactors = FALSE
  )
}

extract_model_stats <- function(model_fit, model_data, model_label) {
  if (inherits(model_fit, "ctqr")) {
    return(extract_clad_model_stats(model_fit, model_data, model_label))
  }
  extract_tobit_model_stats(model_fit, model_data, model_label)
}

#' Fit interval-censored clustered Tobit model
#' Model treats values at -9 as left-censored and 9 as right-censored.
fit_clustered_tobit <- function(data, rhs_formula) {
  model_data <- prepare_interval_model_data(data)
  formula_obj <- build_interval_formula(
    "survival::Surv(lower_endpoint, upper_endpoint, type = 'interval2')",
    rhs_formula
  )

  fit <- survival::survreg(
    formula = formula_obj,
    data = model_data,
    dist = "gaussian",
    robust = TRUE,
    cluster = id,
    model = TRUE,
    x = TRUE,
    y = TRUE
  )
  fit$approach <- "Tobit"
  fit$response_shift <- 0
  fit
}

#' Fit CLAD-style interval-censored median regression using ctqr.
fit_clad <- function(data, rhs_formula, quantile = 0.5, response_shift = 10) {
  model_data <- prepare_interval_model_data(data)
  model_data$lower_endpoint_shifted <- ifelse(
    is.finite(model_data$lower_endpoint),
    model_data$lower_endpoint + response_shift,
    model_data$lower_endpoint
  )
  model_data$upper_endpoint_shifted <- ifelse(
    is.finite(model_data$upper_endpoint),
    model_data$upper_endpoint + response_shift,
    model_data$upper_endpoint
  )

  formula_obj <- build_interval_formula(
    "survival::Surv(lower_endpoint_shifted, upper_endpoint_shifted, type = 'interval2')",
    rhs_formula
  )

  fit <- ctqr::ctqr(
    formula = formula_obj,
    data = model_data,
    p = quantile,
    control = ctqr::ctqr.control(maxit = 2000)
  )
  fit$approach <- "CLAD"
  fit$response_shift <- response_shift
  fit$quantile_target <- quantile
  fit
}

save_model_outputs <- function(model_fit, model_data, output_prefix, model_label, model_dir) {
  write.csv(
    extract_model_table(model_fit),
    file.path(model_dir, sprintf("%s_coefficients.csv", output_prefix)),
    row.names = FALSE
  )
  saveRDS(model_fit, file.path(model_dir, sprintf("%s_model.rds", output_prefix)))
  write.csv(
    extract_model_stats(model_fit, model_data, model_label),
    file.path(model_dir, sprintf("%s_fit_stats.csv", output_prefix)),
    row.names = FALSE
  )
}

write_failed_model_stats <- function(model_data, output_prefix, model_label, model_dir, approach, error_message) {
  write.csv(
    data.frame(
      Model = model_label,
      Approach = approach,
      Observations = nrow(model_data),
      Participants = length(unique(model_data$id)),
      LowerBoundCensored = sum(model_data$judgement <= -9, na.rm = TRUE),
      UpperBoundCensored = sum(model_data$judgement >= 9, na.rm = TRUE),
      LogLik = NA_real_,
      AIC = NA_real_,
      PseudoR2 = NA_real_,
      Quantile = if (approach == "CLAD") 0.5 else NA_real_,
      Converged = FALSE,
      Iterations = NA_integer_,
      Status = "failed",
      ErrorMessage = error_message,
      stringsAsFactors = FALSE
    ),
    file.path(model_dir, sprintf("%s_fit_stats.csv", output_prefix)),
    row.names = FALSE
  )
}

run_estimation_suite <- function(data, rhs_formula, output_prefix, model_label, model_dir) {
  tobit_fit <- fit_clustered_tobit(data, rhs_formula)
  save_model_outputs(tobit_fit, data, output_prefix, paste0(model_label, "_Tobit"), model_dir)

  clad_prefix <- paste0(output_prefix, "_CLAD")
  clad_result <- tryCatch(
    fit_clad(data, rhs_formula),
    error = function(e) e
  )

  if (inherits(clad_result, "error")) {
    warning(sprintf("CLAD fit failed for %s: %s", output_prefix, clad_result$message))
    write_failed_model_stats(
      data,
      clad_prefix,
      paste0(model_label, "_CLAD"),
      model_dir,
      "CLAD",
      clad_result$message
    )
    return(invisible(list(tobit = tobit_fit, clad = NULL)))
  }

  save_model_outputs(clad_result, data, clad_prefix, paste0(model_label, "_CLAD"), model_dir)
  invisible(list(tobit = tobit_fit, clad = clad_result))
}

get_term_row <- function(model_table, term_name) {
  model_table[model_table$term == term_name, , drop = FALSE]
}

#' Test Tobit residuals for normality
test_tobit_normality <- function(model_fit) {
  # Deviance residuals from survreg offer a mechanism to assess normality assumption
  res <- tryCatch(
    stats::residuals(model_fit, type = "deviance"),
    error = function(e) NULL
  )

  if (is.null(res) || !is.numeric(res)) {
    return(
      "Residual-based normality diagnostics could not be computed from the saved interval-censored Tobit object. The report therefore omits the Shapiro-Wilk test for this model."
    )
  }

  res <- res[is.finite(res)]
  if (length(res) < 3L) {
    return(
      "Residual-based normality diagnostics could not be computed because fewer than three finite residuals were available for this model."
    )
  }

  # Shapiro-Wilk requires a sample size between 3 and 5000.
  set.seed(42) # for reproducible subsampling if needed
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

summarize_clad_diagnostics <- function(model_fit) {
  quantile_target <- if (!is.null(model_fit$quantile_target)) as.numeric(model_fit$quantile_target[1]) else 0.5
  converged <- if (!is.null(model_fit$converged)) as.logical(model_fit$converged[1]) else NA
  iterations <- if (!is.null(model_fit$n.it)) as.integer(model_fit$n.it[1]) else NA_integer_
  shift_value <- get_model_response_shift(model_fit)

  sprintf(
    paste(
      "The CLAD robustness model was estimated as an interval-censored median regression (p = %.2f).",
      "This estimator does not impose a Gaussian latent-error assumption and is therefore reported as a robustness check",
      "alongside the Tobit model when normality is doubtful.",
      "The optimization status for this fit is %s after %s iterations.",
      "To satisfy the positive-time requirement of the censored quantile routine, the bounded judgement outcome was shifted internally by %.1f units;",
      "the reported coefficients are back-transformed to the original judgement scale.",
      "Standard errors come from the ctqr asymptotic covariance matrix and should be interpreted as complementary robustness evidence rather than clustered Tobit replacements."
    ),
    quantile_target,
    if (isTRUE(converged)) "converged" else "not confirmed as converged",
    if (is.na(iterations)) "NA" else as.character(iterations),
    shift_value
  )
}

get_model_diagnostics <- function(model_fit) {
  if (inherits(model_fit, "ctqr")) {
    return(summarize_clad_diagnostics(model_fit))
  }
  test_tobit_normality(model_fit)
}
