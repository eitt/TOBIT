# R/utils/model_functions.R
# Purpose: Translation of terms and implementation of interval-censored Tobit
# and cluster-aware non-parametric censored robustness behavior.
# Dependencies: survival, ctqr

source("R/utils/case_configuration_functions.R")

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

expand_case_component <- function(x) {
  switch(
    x,
    Hum = "Humanities",
    Ing = "Engineering",
    Control = "Control label hidden",
    x
  )
}

label_case_configuration <- function(case_label) {
  parts <- strsplit(case_label, "_x_", fixed = TRUE)[[1]]
  if (length(parts) != 2L) return(case_label)
  sprintf(
    "%s victim x %s negotiator",
    expand_case_component(parts[1]),
    expand_case_component(parts[2])
  )
}

label_case_configuration_term <- function(term) {
  if (grepl("^case_[a-z]+_x_[a-z]+$", term)) {
    case_label <- gsub("^case_", "", term)
    case_label <- gsub("_x_", "_x_", case_label)
    case_label <- gsub("^hum", "Hum", case_label)
    case_label <- gsub("_hum", "_Hum", case_label)
    case_label <- gsub("^ing", "Ing", case_label)
    case_label <- gsub("_ing", "_Ing", case_label)
    case_label <- gsub("^control", "Control", case_label)
    case_label <- gsub("_control", "_Control", case_label)
    return(paste("Case configuration:", label_case_configuration(case_label)))
  }

  if (grepl("^case_configuration(_role|_decision|_context)?", term)) {
    return("Case-configuration context")
  }

  term
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
    "decision_accept" = "Negotiator accepted harmful deal",
    "case_configuration" = "Victim x negotiator case configuration",
    "case_configuration_role" = "Case configuration x role",
    "case_configuration_decision" = "Case configuration x decision context",
    "case_configuration_context" = "Case configuration x role x decision context"
  )

  term_key <- canonicalize_term_name(term)
  if (term_key %in% names(direct_map)) {
    return(unname(direct_map[[term_key]]))
  }
  case_label <- label_case_configuration_term(term_key)
  if (!identical(case_label, term_key)) {
    return(case_label)
  }
  if (grepl(":", term_key, fixed = TRUE)) {
    term_parts <- strsplit(term_key, ":", fixed = TRUE)[[1]]
    return(paste(vapply(term_parts, label_term, character(1)), collapse = " x "))
  }
  if (grepl("^factor\\(stage\\)", term)) {
    return(paste0("Stage ", sub("^factor\\(stage\\)", "", term), " (ref = stage 1)"))
  }
  if (grepl("^factor\\(negotiator_slot\\)", term)) {
    return(paste0("Negotiator ", sub("^factor\\(negotiator_slot\\)", "", term), " (ref = negotiator 1)"))
  }
  term
}

#' Default controls for the cluster-aware non-parametric robustness path.
get_clad_bootstrap_defaults <- function() {
  bootstrap_reps <- resolve_clad_bootstrap_reps()

  list(
    quantile = 0.5,
    response_shift = 10,
    cluster_var = "id",
    bootstrap_reps = bootstrap_reps,
    conf_level = 0.95,
    seed = 42L,
    maxit = 2000L,
    run_bootstrap = isTRUE(getOption("tobit.clad_run_bootstrap", TRUE))
  )
}

should_skip_tobit_refit <- function() {
  isTRUE(getOption("tobit.skip_tobit_refit", FALSE))
}

#' Prepare interval-censored endpoints for bounded judgement outcomes.
prepare_interval_model_data <- function(data) {
  model_data <- data
  model_data$lower_endpoint <- ifelse(model_data$judgement <= -9, -Inf, model_data$judgement)
  model_data$upper_endpoint <- ifelse(model_data$judgement >= 9, Inf, model_data$judgement)
  model_data
}

prepare_clad_model_data <- function(data, response_shift = 10) {
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
  model_data
}

build_interval_formula <- function(response_lhs, rhs_formula) {
  stats::as.formula(paste(response_lhs, "~", rhs_formula))
}

build_clad_formula <- function(rhs_formula) {
  build_interval_formula(
    "survival::Surv(lower_endpoint_shifted, upper_endpoint_shifted, type = 'interval2')",
    rhs_formula
  )
}

is_cluster_bootstrap_clad <- function(model_fit) {
  inherits(model_fit, "clustered_ctqr_bootstrap")
}

get_model_family <- function(model_fit) {
  if (is_cluster_bootstrap_clad(model_fit) || inherits(model_fit, "ctqr")) {
    return("CLAD")
  }
  "Tobit"
}

get_model_response_shift <- function(model_fit) {
  if (is.null(model_fit$response_shift)) {
    return(0)
  }
  as.numeric(model_fit$response_shift[1])
}

coef.clustered_ctqr_bootstrap <- function(object, ...) {
  object$coefficients
}

extract_clad_point_estimates <- function(model_fit) {
  if (is_cluster_bootstrap_clad(model_fit)) {
    coef_values <- model_fit$coefficients
  } else {
    coef_values <- stats::coef(model_fit)
  }

  if (is.matrix(coef_values)) {
    coef_values <- coef_values[, 1]
  }
  coef_values <- as.numeric(coef_values)
  names(coef_values) <- names(stats::coef(model_fit))

  if ("(Intercept)" %in% names(coef_values)) {
    coef_values["(Intercept)"] <- coef_values["(Intercept)"] - get_model_response_shift(model_fit)
  }

  coef_values
}

align_coefficient_vector <- function(coefficients, template_terms) {
  aligned <- rep(NA_real_, length(template_terms))
  names(aligned) <- template_terms
  common_terms <- intersect(names(coefficients), template_terms)
  aligned[common_terms] <- coefficients[common_terms]
  aligned
}

compute_bootstrap_p_value <- function(boot_values) {
  boot_values <- boot_values[is.finite(boot_values)]
  if (length(boot_values) == 0L) {
    return(NA_real_)
  }

  positive_mass <- (sum(boot_values >= 0) + 1) / (length(boot_values) + 1)
  negative_mass <- (sum(boot_values <= 0) + 1) / (length(boot_values) + 1)
  min(1, 2 * min(positive_mass, negative_mass))
}

summarize_bootstrap_distribution <- function(point_estimates, bootstrap_matrix, conf_level = 0.95) {
  alpha <- 1 - conf_level
  finite_counts <- apply(bootstrap_matrix, 2, function(x) sum(is.finite(x)))
  std_error <- vapply(
    seq_len(ncol(bootstrap_matrix)),
    function(idx) {
      boot_values <- bootstrap_matrix[, idx]
      if (sum(is.finite(boot_values)) < 2L) {
        return(NA_real_)
      }
      stats::sd(boot_values, na.rm = TRUE)
    },
    numeric(1)
  )
  names(std_error) <- colnames(bootstrap_matrix)
  safe_quantile <- function(x, prob) {
    finite_x <- x[is.finite(x)]
    if (length(finite_x) == 0L) {
      return(NA_real_)
    }
    stats::quantile(finite_x, probs = prob, na.rm = TRUE, names = FALSE)
  }
  conf_low <- apply(
    bootstrap_matrix,
    2,
    function(x) safe_quantile(x, alpha / 2)
  )
  conf_high <- apply(
    bootstrap_matrix,
    2,
    function(x) safe_quantile(x, 1 - alpha / 2)
  )
  z_value <- point_estimates / std_error
  p_value <- vapply(
    seq_along(point_estimates),
    function(idx) {
      boot_values <- bootstrap_matrix[, idx]
      if (is.finite(std_error[idx]) && std_error[idx] > 0 && finite_counts[idx] >= 2L) {
        return(2 * stats::pnorm(abs(z_value[idx]), lower.tail = FALSE))
      }
      compute_bootstrap_p_value(boot_values)
    },
    numeric(1)
  )
  sparse_inference <- nrow(bootstrap_matrix) < 2L
  inference_text <- if (sparse_inference) {
    paste(
      "Sparse cluster bootstrap by participant id;",
      "p-values use bootstrap sign mass because fewer than two successful refits were available"
    )
  } else {
    "Cluster bootstrap by participant id"
  }

  data.frame(
    term = names(point_estimates),
    estimate = unname(point_estimates),
    std_error = unname(std_error),
    naive_se = NA_real_,
    z_value = unname(z_value),
    p_value = unname(p_value),
    conf_low = unname(conf_low),
    conf_high = unname(conf_high),
    label = vapply(names(point_estimates), label_term, character(1)),
    approach = "CLAD",
    inference = inference_text,
    stringsAsFactors = FALSE
  )
}

build_clad_estimate_only_table <- function(point_estimates, inference_text) {
  data.frame(
    term = names(point_estimates),
    estimate = unname(point_estimates),
    std_error = NA_real_,
    naive_se = NA_real_,
    z_value = NA_real_,
    p_value = NA_real_,
    conf_low = NA_real_,
    conf_high = NA_real_,
    label = vapply(names(point_estimates), label_term, character(1)),
    approach = "CLAD",
    inference = inference_text,
    stringsAsFactors = FALSE
  )
}

build_deferred_clad_result <- function(
    full_fit,
    point_estimates,
    planned_bootstrap_reps,
    quantile,
    response_shift,
    cluster_var,
    conf_level,
    seed) {
  template_terms <- names(point_estimates)
  model_fit <- list(
    base_fit = full_fit,
    coefficients = point_estimates,
    bootstrap_coefficients = matrix(
      numeric(0),
      nrow = 0L,
      ncol = length(template_terms),
      dimnames = list(NULL, template_terms)
    ),
    bootstrap_summary = build_clad_estimate_only_table(
      point_estimates,
      paste(
        "Participant-level cluster bootstrap was not run in this pass;",
        "rerun with bootstrap enabled for cluster-aware standard errors,",
        "confidence intervals, and p-values"
      )
    ),
    call = match.call(),
    terms = full_fit$terms,
    quantile_target = quantile,
    response_shift = response_shift,
    cluster_var = cluster_var,
    bootstrap_replicates = as.integer(planned_bootstrap_reps),
    bootstrap_successes = NA_integer_,
    bootstrap_failures = NA_integer_,
    bootstrap_success_rate = NA_real_,
    bootstrap_conf_level = conf_level,
    bootstrap_seed = seed,
    bootstrap_messages = "Full-sample non-parametric fit converged; participant-level bootstrap was not run because bootstrap inference was disabled for this pass.",
    bootstrap_status = "deferred",
    converged = TRUE,
    n.it = if (!is.null(full_fit$n.it)) as.integer(full_fit$n.it[1]) else NA_integer_,
    approach = "CLAD"
  )
  class(model_fit) <- "clustered_ctqr_bootstrap"
  model_fit
}

build_cluster_row_index <- function(data, cluster_var = "id") {
  if (!(cluster_var %in% names(data))) {
    stop(sprintf("Cluster variable '%s' is missing from the modeling data.", cluster_var), call. = FALSE)
  }
  if (anyNA(data[[cluster_var]])) {
    stop(sprintf("Cluster variable '%s' contains missing values, so participant-level resampling is undefined.", cluster_var), call. = FALSE)
  }

  split(seq_len(nrow(data)), data[[cluster_var]])
}

draw_cluster_bootstrap_sample <- function(data, cluster_index) {
  sampled_clusters <- sample.int(length(cluster_index), length(cluster_index), replace = TRUE)
  sampled_rows <- unlist(cluster_index[sampled_clusters], use.names = FALSE)
  boot_data <- data[sampled_rows, , drop = FALSE]
  rownames(boot_data) <- NULL
  boot_data
}

fit_ctqr_core <- function(model_data, rhs_formula, quantile = 0.5, maxit = 2000) {
  formula_obj <- build_clad_formula(rhs_formula)

  fit <- ctqr::ctqr(
    formula = formula_obj,
    data = model_data,
    p = quantile,
    control = ctqr::ctqr.control(maxit = maxit)
  )
  fit$approach <- "CLAD"
  fit$quantile_target <- quantile
  fit
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
  model_df$inference <- "Cluster-robust standard errors by participant id"
  model_df
}

#' Pull coefficients and CI bounds from an interval-censored median regression (CLAD) object.
extract_clad_model_table <- function(model_fit) {
  if (is_cluster_bootstrap_clad(model_fit) && !is.null(model_fit$bootstrap_summary)) {
    return(model_fit$bootstrap_summary)
  }

  coef_values <- extract_clad_point_estimates(model_fit)
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
  model_df$inference <- "ctqr asymptotic covariance"
  model_df
}

extract_model_table <- function(model_fit) {
  if (is_cluster_bootstrap_clad(model_fit) || inherits(model_fit, "ctqr")) {
    return(extract_clad_model_table(model_fit))
  }
  extract_tobit_model_table(model_fit)
}

build_model_stats_row <- function(
    model_label,
    approach,
    model_data,
    loglik = NA_real_,
    aic = NA_real_,
    pseudo_r2 = NA_real_,
    quantile = NA_real_,
    converged = NA,
    iterations = NA_integer_,
    status = "completed",
    error_message = NA_character_,
    inference = NA_character_,
    cluster_unit = "id",
    bootstrap_replicates = NA_integer_,
    bootstrap_successful = NA_integer_,
    bootstrap_failed = NA_integer_,
    bootstrap_success_rate = NA_real_,
    confidence_level = 0.95) {
  data.frame(
    Model = model_label,
    Approach = approach,
    Observations = nrow(model_data),
    Participants = length(unique(model_data$id)),
    LowerBoundCensored = sum(model_data$judgement <= -9, na.rm = TRUE),
    UpperBoundCensored = sum(model_data$judgement >= 9, na.rm = TRUE),
    LogLik = loglik,
    AIC = aic,
    PseudoR2 = pseudo_r2,
    Quantile = quantile,
    Converged = converged,
    Iterations = iterations,
    Inference = inference,
    ClusterUnit = cluster_unit,
    BootstrapReplicates = bootstrap_replicates,
    BootstrapSuccessful = bootstrap_successful,
    BootstrapFailed = bootstrap_failed,
    BootstrapSuccessRate = bootstrap_success_rate,
    ConfidenceLevel = confidence_level,
    Status = status,
    ErrorMessage = error_message,
    stringsAsFactors = FALSE
  )
}

#' Model-level fit information for Tobit.
extract_tobit_model_stats <- function(model_fit, model_data, model_label) {
  loglik_values <- model_fit$loglik
  pseudo_r2 <- NA_real_
  if (!is.null(loglik_values) && length(loglik_values) == 2L && !isTRUE(all.equal(loglik_values[1], 0))) {
    pseudo_r2 <- 1 - (loglik_values[2] / loglik_values[1])
  }

  build_model_stats_row(
    model_label = model_label,
    approach = "Tobit",
    model_data = model_data,
    loglik = as.numeric(stats::logLik(model_fit)),
    aic = stats::AIC(model_fit),
    pseudo_r2 = pseudo_r2,
    quantile = NA_real_,
    converged = if (!is.null(model_fit$fail)) !isTRUE(model_fit$fail) else NA,
    iterations = if (!is.null(model_fit$iter)) as.integer(model_fit$iter) else NA_integer_,
    status = "completed",
    error_message = NA_character_,
    inference = "Cluster-robust standard errors by participant id",
    cluster_unit = "id",
    bootstrap_replicates = NA_integer_,
    bootstrap_successful = NA_integer_,
    bootstrap_failed = NA_integer_,
    bootstrap_success_rate = NA_real_,
    confidence_level = 0.95
  )
}

#' Model-level fit information for CLAD.
extract_clad_model_stats <- function(model_fit, model_data, model_label) {
  if (is_cluster_bootstrap_clad(model_fit)) {
    converged <- if (!is.null(model_fit$converged)) as.logical(model_fit$converged[1]) else NA
    iterations <- if (!is.null(model_fit$n.it)) as.integer(model_fit$n.it[1]) else NA_integer_
    bootstrap_successful <- if (!is.null(model_fit$bootstrap_successes)) as.integer(model_fit$bootstrap_successes[1]) else NA_integer_
    bootstrap_replicates <- if (!is.null(model_fit$bootstrap_replicates)) as.integer(model_fit$bootstrap_replicates[1]) else NA_integer_
    bootstrap_failed <- if (!is.null(model_fit$bootstrap_failures)) as.integer(model_fit$bootstrap_failures[1]) else NA_integer_
    bootstrap_success_rate <- if (!is.null(model_fit$bootstrap_success_rate)) as.numeric(model_fit$bootstrap_success_rate[1]) else NA_real_
    bootstrap_status <- if (!is.null(model_fit$bootstrap_status)) as.character(model_fit$bootstrap_status[1]) else "completed"
    status <- if (!isTRUE(converged)) {
      "not_converged"
    } else if (identical(bootstrap_status, "deferred")) {
      "bootstrap_deferred"
    } else if (is.na(bootstrap_successful) || bootstrap_successful < 1L) {
      "bootstrap_failed"
    } else if (bootstrap_successful < 2L) {
      "bootstrap_sparse"
    } else {
      "completed"
    }
    inference_text <- if (identical(bootstrap_status, "deferred")) {
      "Full-sample interval-censored non-parametric fit converged; participant-level cluster bootstrap was not run because bootstrap inference was disabled for this pass"
    } else if (!is.na(bootstrap_successful) && bootstrap_successful < 2L) {
      "Participant-level cluster bootstrap after interval-censored median regression produced fewer than two successful refits, so inference is sparse"
    } else {
      "Participant-level cluster bootstrap after interval-censored median regression"
    }

    return(
      build_model_stats_row(
        model_label = model_label,
        approach = "CLAD",
        model_data = model_data,
        loglik = NA_real_,
        aic = NA_real_,
        pseudo_r2 = NA_real_,
        quantile = if (!is.null(model_fit$quantile_target)) as.numeric(model_fit$quantile_target[1]) else 0.5,
        converged = converged,
        iterations = iterations,
        status = status,
        error_message = NA_character_,
        inference = inference_text,
        cluster_unit = if (!is.null(model_fit$cluster_var)) as.character(model_fit$cluster_var[1]) else "id",
        bootstrap_replicates = bootstrap_replicates,
        bootstrap_successful = bootstrap_successful,
        bootstrap_failed = bootstrap_failed,
        bootstrap_success_rate = bootstrap_success_rate,
        confidence_level = if (!is.null(model_fit$bootstrap_conf_level)) as.numeric(model_fit$bootstrap_conf_level[1]) else 0.95
      )
    )
  }

  converged <- if (!is.null(model_fit$converged)) as.logical(model_fit$converged[1]) else NA
  iterations <- if (!is.null(model_fit$n.it)) as.integer(model_fit$n.it[1]) else NA_integer_

  build_model_stats_row(
    model_label = model_label,
    approach = "CLAD",
    model_data = model_data,
    loglik = NA_real_,
    aic = NA_real_,
    pseudo_r2 = NA_real_,
    quantile = if (!is.null(model_fit$quantile_target)) as.numeric(model_fit$quantile_target[1]) else 0.5,
    converged = converged,
    iterations = iterations,
    status = if (isTRUE(converged)) "completed" else "not_converged",
    error_message = NA_character_,
    inference = "ctqr asymptotic covariance",
    cluster_unit = "id",
    bootstrap_replicates = NA_integer_,
    bootstrap_successful = NA_integer_,
    bootstrap_failed = NA_integer_,
    bootstrap_success_rate = NA_real_,
    confidence_level = 0.95
  )
}

extract_model_stats <- function(model_fit, model_data, model_label) {
  if (is_cluster_bootstrap_clad(model_fit) || inherits(model_fit, "ctqr")) {
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

#' Fit a cluster-aware interval-censored non-parametric robustness model.
#' Point estimates come from ctqr median regression. Participant-level cluster
#' bootstrap inference runs only after the full-sample fit converges and can be
#' disabled explicitly for a faster fit-only pass.
fit_cluster_bootstrap_clad <- function(
    data,
    rhs_formula,
    quantile = NULL,
    response_shift = NULL,
    cluster_var = NULL,
    bootstrap_reps = NULL,
    conf_level = NULL,
    seed = NULL,
    maxit = NULL,
    run_bootstrap = NULL) {
  defaults <- get_clad_bootstrap_defaults()
  if (is.null(quantile)) quantile <- defaults$quantile
  if (is.null(response_shift)) response_shift <- defaults$response_shift
  if (is.null(cluster_var)) cluster_var <- defaults$cluster_var
  if (is.null(bootstrap_reps)) bootstrap_reps <- defaults$bootstrap_reps
  if (is.null(conf_level)) conf_level <- defaults$conf_level
  if (is.null(seed)) seed <- defaults$seed
  if (is.null(maxit)) maxit <- defaults$maxit
  if (is.null(run_bootstrap)) run_bootstrap <- defaults$run_bootstrap

  model_data <- prepare_clad_model_data(data, response_shift = response_shift)
  full_fit <- suppressWarnings(
    fit_ctqr_core(model_data, rhs_formula, quantile = quantile, maxit = maxit)
  )
  full_fit$response_shift <- response_shift
  point_estimates <- extract_clad_point_estimates(full_fit)
  template_terms <- names(point_estimates)
  full_fit_converged <- if (!is.null(full_fit$converged)) isTRUE(as.logical(full_fit$converged[1])) else FALSE

  if (!full_fit_converged) {
    model_fit <- list(
      base_fit = full_fit,
      coefficients = point_estimates,
      bootstrap_coefficients = matrix(
        numeric(0),
        nrow = 0L,
        ncol = length(template_terms),
        dimnames = list(NULL, template_terms)
      ),
      bootstrap_summary = build_clad_estimate_only_table(
        point_estimates,
        "Cluster bootstrap skipped because the full-sample non-parametric fit did not converge"
      ),
      call = match.call(),
      terms = full_fit$terms,
      quantile_target = quantile,
      response_shift = response_shift,
      cluster_var = cluster_var,
      bootstrap_replicates = as.integer(bootstrap_reps),
      bootstrap_successes = NA_integer_,
      bootstrap_failures = NA_integer_,
      bootstrap_success_rate = NA_real_,
      bootstrap_conf_level = conf_level,
      bootstrap_seed = seed,
      bootstrap_messages = "Full-sample non-parametric fit did not converge; participant-level bootstrap was skipped.",
      bootstrap_status = "skipped_not_converged",
      converged = FALSE,
      n.it = if (!is.null(full_fit$n.it)) as.integer(full_fit$n.it[1]) else NA_integer_,
      approach = "CLAD"
    )
    class(model_fit) <- "clustered_ctqr_bootstrap"
    return(model_fit)
  }

  if (!isTRUE(run_bootstrap)) {
    return(
      build_deferred_clad_result(
        full_fit = full_fit,
        point_estimates = point_estimates,
        planned_bootstrap_reps = bootstrap_reps,
        quantile = quantile,
        response_shift = response_shift,
        cluster_var = cluster_var,
        conf_level = conf_level,
        seed = seed
      )
    )
  }

  cluster_index <- build_cluster_row_index(data, cluster_var = cluster_var)
  if (length(cluster_index) < 2L) {
    stop("At least two participant clusters are required for cluster bootstrap inference.", call. = FALSE)
  }

  set.seed(seed)
  bootstrap_store <- matrix(
    NA_real_,
    nrow = bootstrap_reps,
    ncol = length(template_terms),
    dimnames = list(sprintf("rep_%s", seq_len(bootstrap_reps)), template_terms)
  )
  bootstrap_success <- rep(FALSE, bootstrap_reps)
  bootstrap_messages <- rep(NA_character_, bootstrap_reps)

  for (boot_idx in seq_len(bootstrap_reps)) {
    boot_data <- draw_cluster_bootstrap_sample(data, cluster_index)
    boot_model_data <- prepare_clad_model_data(boot_data, response_shift = response_shift)
    boot_fit <- tryCatch(
      suppressWarnings(
        fit_ctqr_core(boot_model_data, rhs_formula, quantile = quantile, maxit = maxit)
      ),
      error = function(e) e
    )

    if (inherits(boot_fit, "error")) {
      bootstrap_messages[boot_idx] <- boot_fit$message
      next
    }

    if (!isTRUE(as.logical(boot_fit$converged[1]))) {
      bootstrap_messages[boot_idx] <- "ctqr did not converge"
      next
    }

    boot_fit$response_shift <- response_shift
    bootstrap_store[boot_idx, ] <- align_coefficient_vector(
      extract_clad_point_estimates(boot_fit),
      template_terms
    )
    bootstrap_success[boot_idx] <- TRUE
  }

  successful_bootstrap <- bootstrap_store[bootstrap_success, , drop = FALSE]
  if (nrow(successful_bootstrap) == 0L) {
    stop(
      "The participant-level cluster bootstrap produced no converged non-parametric refits, so cluster-aware inference could not be computed.",
      call. = FALSE
    )
  }

  model_fit <- list(
    base_fit = full_fit,
    coefficients = point_estimates,
    bootstrap_coefficients = successful_bootstrap,
    bootstrap_summary = summarize_bootstrap_distribution(
      point_estimates,
      successful_bootstrap,
      conf_level = conf_level
    ),
    call = match.call(),
    terms = full_fit$terms,
    quantile_target = quantile,
    response_shift = response_shift,
    cluster_var = cluster_var,
    bootstrap_replicates = as.integer(bootstrap_reps),
    bootstrap_successes = as.integer(sum(bootstrap_success)),
    bootstrap_failures = as.integer(sum(!bootstrap_success)),
    bootstrap_success_rate = sum(bootstrap_success) / length(bootstrap_success),
    bootstrap_conf_level = conf_level,
    bootstrap_seed = seed,
    bootstrap_messages = stats::na.omit(bootstrap_messages),
    bootstrap_status = "completed",
    converged = if (!is.null(full_fit$converged)) as.logical(full_fit$converged[1]) else NA,
    n.it = if (!is.null(full_fit$n.it)) as.integer(full_fit$n.it[1]) else NA_integer_,
    approach = "CLAD"
  )
  class(model_fit) <- "clustered_ctqr_bootstrap"
  model_fit
}

#' Backward-compatible alias used throughout the existing pipeline.
fit_clad <- function(
    data,
    rhs_formula,
    quantile = NULL,
    response_shift = NULL,
    cluster_var = NULL,
    bootstrap_reps = NULL,
    conf_level = NULL,
    seed = NULL,
    maxit = NULL,
    run_bootstrap = NULL) {
  fit_cluster_bootstrap_clad(
    data = data,
    rhs_formula = rhs_formula,
    quantile = quantile,
    response_shift = response_shift,
    cluster_var = cluster_var,
    bootstrap_reps = bootstrap_reps,
    conf_level = conf_level,
    seed = seed,
    maxit = maxit,
    run_bootstrap = run_bootstrap
  )
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

write_failed_model_stats <- function(
    model_data,
    output_prefix,
    model_label,
    model_dir,
    approach,
    error_message,
    quantile = NA_real_,
    inference = NA_character_,
    cluster_unit = "id",
    bootstrap_replicates = NA_integer_,
    confidence_level = 0.95) {
  write.csv(
    build_model_stats_row(
      model_label = model_label,
      approach = approach,
      model_data = model_data,
      loglik = NA_real_,
      aic = NA_real_,
      pseudo_r2 = NA_real_,
      quantile = quantile,
      converged = FALSE,
      iterations = NA_integer_,
      status = "failed",
      error_message = error_message,
      inference = inference,
      cluster_unit = cluster_unit,
      bootstrap_replicates = bootstrap_replicates,
      bootstrap_successful = 0L,
      bootstrap_failed = bootstrap_replicates,
      bootstrap_success_rate = if (!is.na(bootstrap_replicates) && bootstrap_replicates > 0L) 0 else NA_real_,
      confidence_level = confidence_level
    ),
    file.path(model_dir, sprintf("%s_fit_stats.csv", output_prefix)),
    row.names = FALSE
  )
}

run_estimation_suite <- function(data, rhs_formula, output_prefix, model_label, model_dir) {
  clad_defaults <- get_clad_bootstrap_defaults()
  tobit_fit <- NULL
  if (!should_skip_tobit_refit()) {
    tobit_fit <- fit_clustered_tobit(data, rhs_formula)
    save_model_outputs(tobit_fit, data, output_prefix, paste0(model_label, "_Tobit"), model_dir)
  }

  clad_prefix <- paste0(output_prefix, "_CLAD")
  clad_result <- tryCatch(
    fit_clad(
      data,
      rhs_formula,
      quantile = clad_defaults$quantile,
      response_shift = clad_defaults$response_shift,
      cluster_var = clad_defaults$cluster_var,
      bootstrap_reps = clad_defaults$bootstrap_reps,
      conf_level = clad_defaults$conf_level,
      seed = clad_defaults$seed,
      maxit = clad_defaults$maxit,
      run_bootstrap = clad_defaults$run_bootstrap
    ),
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
      clad_result$message,
      quantile = clad_defaults$quantile,
      inference = "Participant-level cluster bootstrap after interval-censored median regression",
      cluster_unit = clad_defaults$cluster_var,
      bootstrap_replicates = clad_defaults$bootstrap_reps,
      confidence_level = clad_defaults$conf_level
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

  set.seed(42)
  res_sub <- if (length(res) > 5000) sample(res, 5000) else res

  sw_test <- stats::shapiro.test(res_sub)

  if (sw_test$p.value < 0.05) {
    return(sprintf(
      paste(
        "The Shapiro-Wilk test on the deviance residuals indicates a violation of the normality assumption",
        "(W = %.3f, p = %.3e).",
        "The primary Tobit model still uses participant-clustered standard errors by id,",
        "and the report pairs it with a cluster-bootstrap non-parametric censored robustness model."
      ),
      sw_test$statistic,
      sw_test$p.value
    ))
  }

  sprintf(
    "The Shapiro-Wilk test on the deviance residuals suggests that the latent-error normality assumption is reasonably compatible with the data (W = %.3f, p = %.3f). The Tobit branch therefore remains a defensible clustered benchmark.",
    sw_test$statistic,
    sw_test$p.value
  )
}

summarize_clad_diagnostics <- function(model_fit) {
  quantile_target <- if (!is.null(model_fit$quantile_target)) as.numeric(model_fit$quantile_target[1]) else 0.5
  converged <- if (!is.null(model_fit$converged)) as.logical(model_fit$converged[1]) else NA
  iterations <- if (!is.null(model_fit$n.it)) as.integer(model_fit$n.it[1]) else NA_integer_
  shift_value <- get_model_response_shift(model_fit)

  if (is_cluster_bootstrap_clad(model_fit)) {
    if (!isTRUE(converged) && !is.null(model_fit$bootstrap_status) && model_fit$bootstrap_status[1] == "skipped_not_converged") {
      return(sprintf(
        paste(
          "The non-parametric robustness model did not achieve convergence in the full sample after %s iterations,",
          "so participant-level cluster bootstrap inference was not attempted for this specification.",
          "The reported point estimates remain on the original judgement scale because the internal response shift of %.1f units was back-transformed."
        ),
        if (is.na(iterations)) "NA" else as.character(iterations),
        shift_value
      ))
    }

    if (isTRUE(converged) && !is.null(model_fit$bootstrap_status) && model_fit$bootstrap_status[1] == "deferred") {
      return(sprintf(
        paste(
          "The non-parametric robustness model converged in the full sample after %s iterations,",
          "but participant-level cluster bootstrap inference was disabled for this run.",
          "The reported coefficients are back-transformed to the original judgement scale after an internal response shift of %.1f units.",
          "Cluster-aware p-values and confidence intervals will appear once the bootstrap-enabled run is executed."
        ),
        if (is.na(iterations)) "NA" else as.character(iterations),
        shift_value
      ))
    }

    return(sprintf(
      paste(
        "The non-parametric robustness model was estimated as an interval-censored median regression (p = %.2f),",
        "and participant id was used only as the clustering unit for inference rather than as a substantive predictor.",
        "Within-participant dependence is handled through a participant-level cluster bootstrap that resampled %s ids with replacement,",
        "retaining all repeated observations from each sampled participant; %s bootstrap refits converged successfully.",
        "The full-sample optimization status is %s after %s iterations.",
        "To satisfy the positive-time requirement of the censored quantile routine, the bounded judgement outcome was shifted internally by %.1f units,",
        "and the reported intercept is back-transformed to the original judgement scale.",
        "Reported standard errors come from that cluster bootstrap, percentile confidence intervals use the bootstrap distribution directly,",
        "and p-values are summarized from the bootstrap standard errors on a normal-approximation scale."
      ),
      quantile_target,
      if (is.null(model_fit$bootstrap_replicates)) "NA" else as.character(model_fit$bootstrap_replicates),
      if (is.null(model_fit$bootstrap_successes)) "NA" else as.character(model_fit$bootstrap_successes),
      if (isTRUE(converged)) "converged" else "not confirmed as converged",
      if (is.na(iterations)) "NA" else as.character(iterations),
      shift_value
    ))
  }

  sprintf(
    paste(
      "The CLAD robustness model was estimated as an interval-censored median regression (p = %.2f).",
      "This legacy object relies on ctqr's asymptotic covariance matrix after %s iterations,",
      "with a response shift of %.1f units to satisfy the positive-time requirement of the censored quantile routine."
    ),
    quantile_target,
    if (is.na(iterations)) "NA" else as.character(iterations),
    shift_value
  )
}

get_model_diagnostics <- function(model_fit) {
  if (is_cluster_bootstrap_clad(model_fit) || inherits(model_fit, "ctqr")) {
    return(summarize_clad_diagnostics(model_fit))
  }
  test_tobit_normality(model_fit)
}
