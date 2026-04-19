# Shared Tobit-model estimation utilities for the longitudinal judgment pipeline.

source("R/utils/table_functions.R")
source("R/utils/build_role_relational_variables.R")

label_term_pretty <- function(term) {
  direct_map <- c(
    "(Intercept)" = "Intercept",
    "iri_fs" = "Empathy: Fantasy",
    "iri_ec" = "Empathy: Empathic concern",
    "iri_pt" = "Empathy: Perspective taking",
    "iri_pd" = "Empathy: Personal distress",
    "age" = "Age",
    "ses" = "Socioeconomic status",
    "sex_female" = "Woman participant",
    "decision_target" = "Target accepted",
    "decision_other" = "Other negotiator accepted",
    "decision_target:decision_other" = "Target accepted x Other accepted",
    "faculty_player_factorEngineering" = "Participant faculty: Engineering vs Humanities",
    "victim_N1_groupingroup" = "Victim-N1 ingroup vs ingroup baseline",
    "victim_N1_groupoutgroup" = "Victim-N1 outgroup vs ingroup",
    "victim_N2_groupingroup" = "Victim-N2 ingroup vs ingroup baseline",
    "victim_N2_groupoutgroup" = "Victim-N2 outgroup vs ingroup",
    "bystander_N1_groupingroup" = "Bystander-N1 ingroup vs ingroup baseline",
    "bystander_N1_groupoutgroup" = "Bystander-N1 outgroup vs ingroup",
    "bystander_N2_groupingroup" = "Bystander-N2 ingroup vs ingroup baseline",
    "bystander_N2_groupoutgroup" = "Bystander-N2 outgroup vs ingroup",
    "bystander_victim_groupoutgroup" = "Bystander-victim outgroup vs ingroup",
    "N1_N2_same_facultysame" = "N1/N2 same faculty vs different",
    "Log(scale)" = "Tobit log-scale"
  )

  if (term %in% names(direct_map)) {
    return(unname(direct_map[[term]]))
  }

  if (grepl("^factor\\(session\\)", term)) {
    return(sub("^factor\\(session\\)", "Session ", term))
  }

  if (grepl(":", term, fixed = TRUE)) {
    parts <- strsplit(term, ":", fixed = TRUE)[[1]]
    return(paste(vapply(parts, label_term_pretty, character(1)), collapse = " x "))
  }

  term
}

prepare_tobit_model_data <- function(data) {
  model_data <- droplevels(as.data.frame(data))
  model_data <- coerce_model_factors(model_data)
  model_data$lower_endpoint <- ifelse(
    model_data$judgement <= -9,
    -Inf,
    model_data$judgement
  )
  model_data$upper_endpoint <- ifelse(
    model_data$judgement >= 9,
    Inf,
    model_data$judgement
  )
  model_data
}

fit_tobit_model <- function(data, rhs_formula) {
  model_data <- prepare_tobit_model_data(data)
  model_formula <- stats::as.formula(
    paste(
      "survival::Surv(lower_endpoint, upper_endpoint, type = 'interval2') ~",
      rhs_formula
    )
  )

  fit_object <- survival::survreg(
    formula = model_formula,
    data = model_data,
    dist = "gaussian",
    robust = TRUE,
    cluster = model_data$id,
    model = TRUE,
    x = TRUE,
    y = TRUE
  )

  model_frame <- stats::model.frame(model_formula, data = model_data, na.action = stats::na.omit)
  model_matrix <- stats::model.matrix(stats::delete.response(stats::terms(model_formula)), data = model_frame)
  matrix_qr <- qr(model_matrix)
  dropped_columns <- if (matrix_qr$rank < ncol(model_matrix)) {
    colnames(model_matrix)[matrix_qr$pivot[(matrix_qr$rank + 1L):ncol(model_matrix)]]
  } else {
    character(0)
  }

  list(
    fit = fit_object,
    data = model_data,
    formula = model_formula,
    session_handling = "factor_session_fixed_effect",
    dependence_adjustment = "cluster_robust_id",
    dropped_columns = dropped_columns
  )
}

extract_model_table <- function(model_result, hypothesis_id, role_label, variant_label) {
  model_summary <- summary(model_result$fit)
  coefficient_frame <- as.data.frame(model_summary$table, stringsAsFactors = FALSE)
  coefficient_frame$term <- rownames(coefficient_frame)
  rownames(coefficient_frame) <- NULL

  names(coefficient_frame) <- c("estimate", "std_error", "naive_se", "statistic", "p_value", "term")
  coefficient_frame$conf_low <- coefficient_frame$estimate - 1.96 * coefficient_frame$std_error
  coefficient_frame$conf_high <- coefficient_frame$estimate + 1.96 * coefficient_frame$std_error
  coefficient_frame$pretty_term <- vapply(
    coefficient_frame$term,
    label_term_pretty,
    character(1)
  )
  coefficient_frame$hypothesis <- hypothesis_id
  coefficient_frame$role <- role_label
  coefficient_frame$variant <- variant_label
  coefficient_frame$model_family <- "Two-sided Tobit"
  coefficient_frame$session_handling <- model_result$session_handling
  coefficient_frame$dependence_adjustment <- model_result$dependence_adjustment
  coefficient_frame$formula <- paste(deparse(model_result$formula, width.cutoff = 500L), collapse = " ")
  add_p_value_display_columns(coefficient_frame)
}

extract_fit_stats <- function(model_result, hypothesis_id, role_label, variant_label) {
  fit <- model_result$fit
  response_residuals <- tryCatch(
    stats::residuals(fit, type = "response"),
    error = function(e) numeric(0)
  )
  response_residuals <- response_residuals[is.finite(response_residuals)]
  shapiro_p <- if (length(response_residuals) >= 3L) {
    stats::shapiro.test(
      if (length(response_residuals) > 5000L) sample(response_residuals, 5000L) else response_residuals
    )$p.value
  } else {
    NA_real_
  }

  dropped_column_names <- if (length(model_result$dropped_columns) == 0L) {
    NA_character_
  } else {
    paste(model_result$dropped_columns, collapse = " | ")
  }

  fit_failed <- !is.null(fit$fail) && isTRUE(fit$fail)

  data.frame(
    hypothesis = hypothesis_id,
    role = role_label,
    variant = variant_label,
    model_family = "Two-sided Tobit",
    session_handling = model_result$session_handling,
    dependence_adjustment = model_result$dependence_adjustment,
    formula = paste(deparse(model_result$formula, width.cutoff = 500L), collapse = " "),
    n_obs = stats::nobs(fit),
    n_participants = length(unique(model_result$data$id)),
    n_sessions = length(unique(model_result$data$session)),
    n_cases = length(unique(model_result$data$id_case)),
    lower_censored_n = sum(model_result$data$judgement <= -9, na.rm = TRUE),
    upper_censored_n = sum(model_result$data$judgement >= 9, na.rm = TRUE),
    logLik = as.numeric(stats::logLik(fit)),
    AIC = stats::AIC(fit),
    BIC = stats::BIC(fit),
    sigma = fit$scale,
    singular = NA,
    dropped_columns = length(model_result$dropped_columns),
    dropped_column_names = dropped_column_names,
    shapiro_p = shapiro_p,
    convergence_messages = if (fit_failed) "survreg reported a fit failure flag" else NA_character_,
    stringsAsFactors = FALSE
  )
}

save_model_result_bundle <- function(
    model_result,
    hypothesis_id,
    role_label,
    variant_label,
    paths) {
  prefix <- sprintf("%s_%s_%s", hypothesis_id, role_label, variant_label)
  coefficient_table <- extract_model_table(model_result, hypothesis_id, role_label, variant_label)
  fit_stats <- extract_fit_stats(model_result, hypothesis_id, role_label, variant_label)

  write.csv(
    coefficient_table,
    file.path(paths$models_dir, sprintf("%s_coefficients.csv", prefix)),
    row.names = FALSE
  )
  write.csv(
    fit_stats,
    file.path(paths$models_dir, sprintf("%s_fit_stats.csv", prefix)),
    row.names = FALSE
  )
  saveRDS(
    model_result$fit,
    file.path(paths$models_dir, sprintf("%s_model.rds", prefix))
  )

  list(
    coefficients = coefficient_table,
    fit_stats = fit_stats,
    prefix = prefix
  )
}

run_hypothesis_model <- function(
    data,
    hypothesis_id,
    role_label,
    rhs_formula,
    paths = get_project_paths()) {
  primary_result <- fit_tobit_model(
    data = data,
    rhs_formula = rhs_formula
  )

  primary_saved <- save_model_result_bundle(
    primary_result,
    hypothesis_id,
    role_label,
    "primary",
    paths
  )

  robustness_note <- data.frame(
    hypothesis = hypothesis_id,
    role = role_label,
    note = paste(
      "The default redesign now prioritizes a two-sided Tobit with factor(session)",
      "and participant-cluster robust standard errors.",
      "A second id_case-saturated Tobit specification is not run by default because",
      "it would add more than one thousand fixed effects and destabilize the interval-censored fit."
    ),
    stringsAsFactors = FALSE
  )
  write.csv(
    robustness_note,
    file.path(paths$tables_dir, sprintf("%s_%s_robustness.csv", hypothesis_id, role_label)),
    row.names = FALSE
  )
  write.csv(
    robustness_note,
    file.path(paths$diagnostics_dir, sprintf("%s_%s_robustness.csv", hypothesis_id, role_label)),
    row.names = FALSE
  )

  invisible(
    list(
      primary = primary_saved,
      robustness = robustness_note
    )
  )
}
