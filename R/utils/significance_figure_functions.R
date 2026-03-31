# R/utils/significance_figure_functions.R
# Purpose: Build significance-driven visualizations for hypothesis-relevant
# predictors that clear the report threshold.
# Dependencies: figure_functions.R, model_functions.R

get_extended_plot_style <- function() {
  style <- get_plot_style()
  style$secondary <- "#B55B15"
  style$secondary_light <- "#F3D9C7"
  style$accent <- "#2E8540"
  style$accent_light <- "#DCECDD"
  style
}

safe_mode <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0L) return(NA)
  unique_x <- unique(x)
  unique_x[which.max(tabulate(match(x, unique_x)))]
}

sanitize_identifier <- function(x) {
  cleaned <- gsub("[^A-Za-z0-9]+", "_", tolower(x))
  cleaned <- gsub("^_+|_+$", "", cleaned)
  if (!nzchar(cleaned)) return("term")
  cleaned
}

get_binary_value_labels <- function(var_name) {
  if (grepl("^h2_negstruct_", var_name)) {
    structure_label <- compact_h2_negotiator_structure_term(var_name)
    return(c(
      "0" = "Ref: JN In, CN In",
      "1" = structure_label
    ))
  }

  if (grepl("^case_[a-z]+_x_[a-z]+$", var_name)) {
    case_label <- gsub("^case_", "", var_name)
    case_label <- gsub("^hum", "Hum", case_label)
    case_label <- gsub("_hum", "_Hum", case_label)
    case_label <- gsub("^ing", "Ing", case_label)
    case_label <- gsub("_ing", "_Ing", case_label)
    case_label <- gsub("^control", "Control", case_label)
    case_label <- gsub("_control", "_Control", case_label)
    return(c(
      "0" = "All other case configurations",
      "1" = label_case_configuration(case_label)
    ))
  }

  if (grepl("^acfg_", var_name)) {
    dummy_map <- get_analytic_case_configuration_dummy_names(include_control = TRUE)
    matched_level <- names(dummy_map)[match(var_name, unname(dummy_map))]
    if (length(matched_level) == 1L && !is.na(matched_level)) {
      return(c(
        "0" = "All other judgment configurations",
        "1" = label_analytic_case_configuration(matched_level)
      ))
    }
  }

  switch(
    var_name,
    perp_outgroup = c("0" = "Ingroup perpetrator", "1" = "Outgroup perpetrator"),
    perp_control = c("0" = "Named perpetrator", "1" = "Control label hidden"),
    same_group_harm = c("0" = "Cross-faculty harm", "1" = "Same-faculty harm"),
    victim_outgroup = c("0" = "Victim ingroup", "1" = "Victim outgroup"),
    decision_accept = c("0" = "Rej", "1" = "Acc"),
    judged_outgroup = c("0" = "JN In", "1" = "JN Out"),
    judged_control = c("0" = "JN In", "1" = "JN Ctl"),
    counterpart_outgroup = c("0" = "CN In", "1" = "CN Out"),
    counterpart_control = c("0" = "CN In", "1" = "CN Ctl"),
    observer_victim_outgroup = c("0" = "V In", "1" = "V Out"),
    player_victim_outgroup = c("0" = "V In", "1" = "V Out"),
    role_observer = c("0" = "Vic", "1" = "Obs"),
    participant_engineering = c("0" = "Hum part.", "1" = "Eng part."),
    sex_man = c("0" = "Woman", "1" = "Man"),
    negotiator_slot = c("1" = "Slot 1", "2" = "Slot 2"),
    NULL
  )
}

get_plot_axis_label <- function(var_name) {
  if (grepl("^h2_negstruct_", var_name)) {
    return("JN / CN structure")
  }

  if (grepl("^case_[a-z]+_x_[a-z]+$", var_name)) {
    return("Case-configuration contrast")
  }

  switch(
    var_name,
    role_observer = "Role",
    participant_engineering = "Participant faculty",
    sex_man = "Sex",
    decision_accept = "Acc / Rej",
    player_victim_outgroup = "V",
    observer_victim_outgroup = "V",
    negotiator_slot = "Slot",
    analytic_case_configuration = "Role-dependent judgment configuration",
    analytic_case_configuration_decision = "Judgment configuration x decision context",
    analytic_case_configuration_context = "Judgment configuration x decision context",
    case_configuration = "Victim x negotiator case configuration",
    case_configuration_role = "Case configuration x role",
    case_configuration_decision = "Case configuration x decision context",
    case_configuration_context = "Case configuration x role x decision context",
    label_term_compact(var_name)
  )
}

get_plot_label_wrap_width <- function(labels) {
  labels <- as.character(labels)
  labels <- labels[nzchar(labels)]
  if (length(labels) == 0L) return(18L)

  max_chars <- max(nchar(labels), na.rm = TRUE)
  if (max_chars >= 40L) return(12L)
  if (max_chars >= 30L) return(14L)
  if (max_chars >= 22L) return(16L)
  20L
}

wrap_plot_label <- function(label, width) {
  label <- as.character(label)
  label <- gsub(" \\(ref = ", "\n(ref = ", label, fixed = TRUE)
  segments <- strsplit(label, "\n", fixed = TRUE)[[1]]
  wrapped_segments <- unlist(lapply(segments, function(segment) {
    wrapped <- strwrap(segment, width = width)
    if (length(wrapped) == 0L) "" else wrapped
  }), use.names = FALSE)
  paste(wrapped_segments, collapse = "\n")
}

wrap_plot_labels <- function(labels, width = NULL) {
  labels <- as.character(labels)
  if (is.null(width)) {
    width <- get_plot_label_wrap_width(labels)
  }
  vapply(labels, wrap_plot_label, character(1), width = width, USE.NAMES = FALSE)
}

format_discrete_value_label <- function(var_name, value) {
  value_chr <- as.character(value)
  value_map <- get_binary_value_labels(var_name)
  if (!is.null(value_map) && value_chr %in% names(value_map)) {
    return(unname(value_map[[value_chr]]))
  }

  if (identical(var_name, "case_configuration")) {
    return(label_case_configuration(value_chr))
  }
  if (identical(var_name, "analytic_case_configuration")) {
    return(label_analytic_case_configuration(value_chr))
  }
  if (identical(var_name, "analytic_case_configuration_decision")) {
    parts <- strsplit(value_chr, "__Accept|__Reject", perl = TRUE)[[1]]
    decision_label <- if (grepl("__Accept$", value_chr)) "Accept" else if (grepl("__Reject$", value_chr)) "Reject" else NA_character_
    if (length(parts) == 1L && !is.na(decision_label)) {
      return(sprintf("%s (%s)", label_analytic_case_configuration(parts[1]), decision_label))
    }
  }
  if (identical(var_name, "analytic_case_configuration_context")) {
    parts <- strsplit(value_chr, "__Accept|__Reject", perl = TRUE)[[1]]
    decision_label <- if (grepl("__Accept$", value_chr)) "Accept" else if (grepl("__Reject$", value_chr)) "Reject" else NA_character_
    if (length(parts) == 1L && !is.na(decision_label)) {
      return(sprintf("%s (%s)", label_analytic_case_configuration(parts[1]), decision_label))
    }
  }
  if (identical(var_name, "case_configuration_role")) {
    parts <- strsplit(value_chr, "__", fixed = TRUE)[[1]]
    if (length(parts) == 2L) {
      return(sprintf("%s (%s)", label_case_configuration(parts[1]), parts[2]))
    }
  }
  if (identical(var_name, "case_configuration_decision")) {
    parts <- strsplit(value_chr, "__", fixed = TRUE)[[1]]
    if (length(parts) == 2L) {
      return(sprintf("%s (%s)", label_case_configuration(parts[1]), parts[2]))
    }
  }
  if (identical(var_name, "case_configuration_context")) {
    parts <- strsplit(value_chr, "__", fixed = TRUE)[[1]]
    if (length(parts) == 3L) {
      return(sprintf("%s (%s, %s)", label_case_configuration(parts[1]), parts[2], parts[3]))
    }
  }

  if (identical(var_name, "economic_status")) {
    return(paste("Socioeconomic status", value_chr))
  }

  value_chr
}

classify_predictor_component <- function(data, var_name) {
  if (!(var_name %in% names(data))) return("categorical")

  values <- data[[var_name]]
  values <- values[!is.na(values)]
  if (length(values) == 0L) return("categorical")

  if (is.factor(values) || is.character(values)) {
    if (length(unique(values)) <= 2L) return("binary")
    return("categorical")
  }

  unique_vals <- sort(unique(values))
  if (length(unique_vals) <= 2L) return("binary")

  if (is.numeric(values)) {
    integer_like <- all(abs(unique_vals - round(unique_vals)) < sqrt(.Machine$double.eps))
    if (integer_like && length(unique_vals) <= 6L) {
      return("categorical")
    }
    return("continuous")
  }

  "categorical"
}

build_term_visual_spec <- function(term, data) {
  canonical_term <- canonicalize_term_name(term)
  if (!grepl(":", canonical_term, fixed = TRUE)) {
    component_type <- classify_predictor_component(data, canonical_term)
    return(list(
      term = canonical_term,
      label = label_term(canonical_term),
      kind = if (identical(component_type, "continuous")) "continuous_main" else "categorical_main",
      x_var = canonical_term,
      x_type = component_type,
      moderator = NULL,
      moderator_type = NULL
    ))
  }

  parts <- strsplit(canonical_term, ":", fixed = TRUE)[[1]]
  part_types <- stats::setNames(
    vapply(parts, classify_predictor_component, character(1), data = data),
    parts
  )

  continuous_parts <- names(part_types)[part_types == "continuous"]
  if (length(continuous_parts) >= 1L) {
    x_var <- continuous_parts[1]
    moderator <- setdiff(parts, x_var)[1]
  } else {
    x_var <- parts[1]
    moderator <- parts[2]
  }

  list(
    term = canonical_term,
    label = label_term(canonical_term),
    kind = "interaction",
    x_var = x_var,
    x_type = unname(part_types[[x_var]]),
    moderator = moderator,
    moderator_type = unname(part_types[[moderator]])
  )
}

build_reference_profile <- function(data) {
  if (!is.data.frame(data) || nrow(data) == 0L) {
    stop("Cannot build a reference profile from empty data.", call. = FALSE)
  }

  reference <- data[1, , drop = FALSE]
  for (col_name in names(reference)) {
    values <- data[[col_name]]
    if (is.factor(values)) {
      modal_value <- safe_mode(as.character(values))
      reference[[col_name]] <- factor(modal_value, levels = levels(values))
      next
    }

    if (is.character(values)) {
      reference[[col_name]] <- as.character(safe_mode(values))
      next
    }

    if (is.numeric(values)) {
      component_type <- classify_predictor_component(data, col_name)
      if (identical(component_type, "continuous")) {
        reference[[col_name]] <- mean(values, na.rm = TRUE)
      } else {
        reference[[col_name]] <- safe_mode(values)
      }
      next
    }

    reference[[col_name]] <- safe_mode(values)
  }

  reference
}

build_value_grid <- function(data, var_name, component_type, n_points = 60L) {
  values <- data[[var_name]]
  values <- values[!is.na(values)]
  if (length(values) == 0L) return(numeric(0))

  if (identical(component_type, "continuous")) {
    return(seq(min(values), max(values), length.out = n_points))
  }

  sort(unique(values))
}

build_moderator_grid <- function(data, moderator, moderator_type) {
  values <- data[[moderator]]
  values <- values[!is.na(values)]
  if (length(values) == 0L) {
    return(list(values = numeric(0), labels = character(0)))
  }

  if (identical(moderator_type, "continuous")) {
    probs <- c(0.25, 0.5, 0.75)
    moderator_values <- as.numeric(stats::quantile(values, probs = probs, names = FALSE, na.rm = TRUE))
    moderator_labels <- c("Low", "Median", "High")
    return(list(values = moderator_values, labels = moderator_labels))
  }

  moderator_values <- sort(unique(values))
  moderator_labels <- vapply(
    moderator_values,
    function(value) format_discrete_value_label(moderator, value),
    character(1)
  )
  list(values = moderator_values, labels = moderator_labels)
}

get_prediction_bounds <- function() {
  get_judgment_observed_bounds()
}

compute_censored_gaussian_expectation <- function(mu, sigma, lower = get_prediction_bounds()[1], upper = get_prediction_bounds()[2]) {
  sigma <- as.numeric(sigma[1])
  if (!is.finite(sigma) || sigma <= 0) {
    return(clamp_judgment_scale(mu, lower = lower, upper = upper))
  }

  z_lower <- (lower - mu) / sigma
  z_upper <- (upper - mu) / sigma

  lower_mass <- stats::pnorm(z_lower)
  middle_mass <- stats::pnorm(z_upper) - stats::pnorm(z_lower)
  upper_mass <- 1 - stats::pnorm(z_upper)

  expected_value <- lower * lower_mass +
    mu * middle_mass +
    sigma * (stats::dnorm(z_lower) - stats::dnorm(z_upper)) +
    upper * upper_mass

  clamp_judgment_scale(expected_value, lower = lower, upper = upper)
}

get_tobit_vcov_matrix <- function(model_fit) {
  vcov_matrix <- model_fit[["var"]]
  if (is.null(vcov_matrix)) return(NULL)
  vcov_matrix <- as.matrix(vcov_matrix)

  if (is.null(dimnames(vcov_matrix))) {
    coefficient_names <- names(model_fit[["coefficients"]])
    if (!is.null(coefficient_names) && length(coefficient_names) + 1L == nrow(vcov_matrix)) {
      full_names <- c(coefficient_names, "Log(scale)")
      dimnames(vcov_matrix) <- list(full_names, full_names)
    } else if (!is.null(coefficient_names) && length(coefficient_names) == nrow(vcov_matrix)) {
      dimnames(vcov_matrix) <- list(coefficient_names, coefficient_names)
    }
  }

  vcov_matrix
}

get_prediction_terms <- function(model_fit) {
  terms_object <- if (inherits(model_fit, "clustered_ctqr_bootstrap")) {
    stats::terms(model_fit[["base_fit"]])
  } else {
    stats::terms(model_fit)
  }
  stats::delete.response(terms_object)
}

get_prediction_coefficients <- function(model_fit) {
  coefficients <- if (inherits(model_fit, "clustered_ctqr_bootstrap")) {
    model_fit[["coefficients"]]
  } else {
    stats::coef(model_fit)
  }
  coefficients <- coefficients[!names(coefficients) %in% "Log(scale)"]
  coefficients
}

align_design_matrix <- function(model_fit, newdata) {
  design_matrix <- stats::model.matrix(get_prediction_terms(model_fit), newdata)
  coefficient_names <- names(get_prediction_coefficients(model_fit))
  missing_terms <- setdiff(coefficient_names, colnames(design_matrix))
  if (length(missing_terms) > 0L) {
    zero_block <- matrix(0, nrow = nrow(design_matrix), ncol = length(missing_terms))
    colnames(zero_block) <- missing_terms
    design_matrix <- cbind(design_matrix, zero_block)
  }
  design_matrix[, coefficient_names, drop = FALSE]
}

extract_factor_wrapped_variables <- function(model_fit) {
  term_labels <- attr(get_prediction_terms(model_fit), "term.labels")
  if (is.null(term_labels) || length(term_labels) == 0L) return(character(0))

  factor_terms <- grep("^factor\\(", term_labels, value = TRUE)
  if (length(factor_terms) == 0L) return(character(0))

  unique(sub("^factor\\(([^)]+)\\)$", "\\1", factor_terms))
}

expand_factor_controls <- function(newdata, original_data, model_fit, protected_vars = character(0)) {
  factor_vars <- setdiff(extract_factor_wrapped_variables(model_fit), protected_vars)
  newdata$.plot_group <- seq_len(nrow(newdata))
  if (length(factor_vars) == 0L) return(newdata)

  expanded_data <- newdata
  for (var_name in factor_vars) {
    if (!(var_name %in% names(expanded_data)) || !(var_name %in% names(original_data))) next
    level_values <- original_data[[var_name]]
    level_values <- sort(unique(level_values[!is.na(level_values)]))
    if (length(level_values) <= 1L) next

    expanded_blocks <- lapply(level_values, function(level_value) {
      block <- expanded_data
      block[[var_name]] <- level_value
      block
    })
    expanded_data <- do.call(rbind, expanded_blocks)
    rownames(expanded_data) <- NULL
  }

  expanded_data
}

align_newdata_levels <- function(newdata, original_data, model_fit) {
  factor_vars <- extract_factor_wrapped_variables(model_fit)
  if (length(factor_vars) == 0L) return(newdata)

  for (var_name in factor_vars) {
    if (!(var_name %in% names(newdata)) || !(var_name %in% names(original_data))) next
    original_values <- original_data[[var_name]]
    original_values <- original_values[!is.na(original_values)]
    if (length(original_values) == 0L) next
    level_values <- sort(unique(original_values))
    newdata[[var_name]] <- factor(newdata[[var_name]], levels = level_values)
  }

  newdata
}

compute_prediction_summary <- function(model_fit, newdata) {
  design_matrix <- align_design_matrix(model_fit, newdata)
  plot_group <- if (".plot_group" %in% names(newdata)) newdata[[".plot_group"]] else seq_len(nrow(newdata))
  plot_group <- as.integer(plot_group)

  if (length(unique(plot_group)) < nrow(design_matrix)) {
    grouped_design <- lapply(
      split(seq_len(nrow(design_matrix)), plot_group),
      function(row_index) colMeans(design_matrix[row_index, , drop = FALSE])
    )
    design_matrix <- do.call(rbind, grouped_design)
  }

  coefficients <- get_prediction_coefficients(model_fit)
  valid_coefs <- !is.na(coefficients)
  if (!all(valid_coefs)) {
    coefficients <- coefficients[valid_coefs]
    design_matrix <- design_matrix[, names(coefficients), drop = FALSE]
  }
  linear_predictor <- as.numeric(design_matrix %*% coefficients)
  prediction_bounds <- get_prediction_bounds()

  if (inherits(model_fit, "clustered_ctqr_bootstrap")) {
    bootstrap_matrix <- model_fit[["bootstrap_coefficients"]]
    conf_level <- if (!is.null(model_fit[["bootstrap_conf_level"]])) {
      as.numeric(model_fit[["bootstrap_conf_level"]][1])
    } else {
      0.95
    }
    alpha <- 1 - conf_level

    if (!is.null(bootstrap_matrix) && nrow(bootstrap_matrix) > 1L) {
      bootstrap_matrix <- bootstrap_matrix[, names(coefficients), drop = FALSE]
      bootstrap_predictions <- design_matrix %*% t(bootstrap_matrix)
      bootstrap_predictions <- clamp_judgment_scale(bootstrap_predictions, lower = prediction_bounds[1], upper = prediction_bounds[2])
      predicted <- clamp_judgment_scale(linear_predictor, lower = prediction_bounds[1], upper = prediction_bounds[2])
      conf_low <- apply(
        bootstrap_predictions,
        1,
        function(x) {
          finite_x <- x[is.finite(x)]
          if (length(finite_x) < 2L) return(NA_real_)
          stats::quantile(finite_x, probs = alpha / 2, na.rm = TRUE, names = FALSE)
        }
      )
      conf_high <- apply(
        bootstrap_predictions,
        1,
        function(x) {
          finite_x <- x[is.finite(x)]
          if (length(finite_x) < 2L) return(NA_real_)
          stats::quantile(finite_x, probs = 1 - alpha / 2, na.rm = TRUE, names = FALSE)
        }
      )
      return(data.frame(predicted = predicted, conf_low = conf_low, conf_high = conf_high, stringsAsFactors = FALSE))
    }

    predicted <- clamp_judgment_scale(linear_predictor, lower = prediction_bounds[1], upper = prediction_bounds[2])
    return(data.frame(predicted = predicted, conf_low = NA_real_, conf_high = NA_real_, stringsAsFactors = FALSE))
  }

  vcov_matrix <- get_tobit_vcov_matrix(model_fit)
  sigma <- as.numeric(model_fit[["scale"]][1])
  predicted <- compute_censored_gaussian_expectation(
    linear_predictor,
    sigma = sigma,
    lower = prediction_bounds[1],
    upper = prediction_bounds[2]
  )

  if (is.null(vcov_matrix)) {
    return(data.frame(predicted = predicted, conf_low = NA_real_, conf_high = NA_real_, stringsAsFactors = FALSE))
  }

  coefficient_names <- names(coefficients)
  vcov_matrix <- vcov_matrix[coefficient_names, coefficient_names, drop = FALSE]
  standard_error <- sqrt(pmax(rowSums((design_matrix %*% vcov_matrix) * design_matrix), 0))
  z_multiplier <- stats::qnorm(0.975)
  linear_low <- linear_predictor - z_multiplier * standard_error
  linear_high <- linear_predictor + z_multiplier * standard_error

  data.frame(
    predicted = predicted,
    conf_low = compute_censored_gaussian_expectation(linear_low, sigma = sigma, lower = prediction_bounds[1], upper = prediction_bounds[2]),
    conf_high = compute_censored_gaussian_expectation(linear_high, sigma = sigma, lower = prediction_bounds[1], upper = prediction_bounds[2]),
    stringsAsFactors = FALSE
  )
}

build_significance_plot_data <- function(model_fit, data, term) {
  visual_spec <- build_term_visual_spec(term, data)
  reference_profile <- build_reference_profile(data)

  if (identical(visual_spec$kind, "continuous_main")) {
    x_values <- build_value_grid(data, visual_spec$x_var, visual_spec$x_type)
    newdata <- reference_profile[rep(1, length(x_values)), , drop = FALSE]
    newdata[[visual_spec$x_var]] <- x_values
    base_df <- data.frame(
      x_value = x_values,
      x_label = format(round(x_values, 2), trim = TRUE),
      moderator_label = NA_character_,
      stringsAsFactors = FALSE
    )
  } else if (identical(visual_spec$kind, "categorical_main")) {
    x_values <- build_value_grid(data, visual_spec$x_var, visual_spec$x_type)
    newdata <- reference_profile[rep(1, length(x_values)), , drop = FALSE]
    newdata[[visual_spec$x_var]] <- x_values
    base_df <- data.frame(
      x_value = seq_along(x_values),
      x_label = vapply(
        x_values,
        function(value) format_discrete_value_label(visual_spec$x_var, value),
        character(1)
      ),
      moderator_label = NA_character_,
      stringsAsFactors = FALSE
    )
  } else {
    x_values <- build_value_grid(data, visual_spec$x_var, visual_spec$x_type)
    moderator_grid <- build_moderator_grid(data, visual_spec$moderator, visual_spec$moderator_type)
    if (length(x_values) == 0L || length(moderator_grid$values) == 0L) {
      stop("Interaction plot data could not be created because the focal variable or moderator had no observed values.", call. = FALSE)
    }

    newdata_blocks <- vector("list", length(moderator_grid$values))
    base_blocks <- vector("list", length(moderator_grid$values))

    for (idx in seq_along(moderator_grid$values)) {
      newdata_block <- reference_profile[rep(1, length(x_values)), , drop = FALSE]
      newdata_block[[visual_spec$x_var]] <- x_values
      newdata_block[[visual_spec$moderator]] <- moderator_grid$values[idx]
      newdata_blocks[[idx]] <- newdata_block

      base_blocks[[idx]] <- data.frame(
        x_value = if (identical(visual_spec$x_type, "continuous")) x_values else seq_along(x_values),
        x_label = if (identical(visual_spec$x_type, "continuous")) {
          format(round(x_values, 2), trim = TRUE)
        } else {
          vapply(
            x_values,
            function(value) format_discrete_value_label(visual_spec$x_var, value),
            character(1)
          )
        },
        moderator_label = moderator_grid$labels[idx],
        stringsAsFactors = FALSE
      )
    }

    newdata <- do.call(rbind, newdata_blocks)
    base_df <- do.call(rbind, base_blocks)
  }

  newdata <- expand_factor_controls(
    newdata,
    data,
    model_fit,
    protected_vars = stats::na.omit(c(visual_spec$x_var, visual_spec$moderator))
  )
  newdata <- align_newdata_levels(newdata, data, model_fit)
  predictions <- compute_prediction_summary(model_fit, newdata)
  cbind(base_df, predictions, stringsAsFactors = FALSE)
}

describe_prediction_pattern <- function(plot_df, visual_spec) {
  plot_df <- plot_df[!is.na(plot_df$predicted), , drop = FALSE]
  if (nrow(plot_df) == 0L) return("No prediction pattern could be summarized.")

  if (identical(visual_spec$kind, "continuous_main")) {
    ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
    if (nrow(ordered_df) < 2L) return(sprintf("the plot summarizes predicted judgment for %s", label_term(visual_spec$x_var)))
    direction <- if (tail(ordered_df$predicted, 1) >= ordered_df$predicted[1]) "higher" else "lower"
    return(sprintf(
      "across the observed range, higher %s corresponds to %s predicted judgment",
      label_term(visual_spec$x_var),
      direction
    ))
  }

  if (identical(visual_spec$kind, "categorical_main")) {
    ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
    if (nrow(ordered_df) < 2L) {
      return(sprintf("the plot summarizes predicted judgment for %s", label_term(visual_spec$x_var)))
    }
    high_row <- ordered_df[nrow(ordered_df), , drop = FALSE]
    low_row <- ordered_df[1, , drop = FALSE]
    comparison <- if (high_row$predicted[1] >= low_row$predicted[1]) "higher" else "lower"
    return(sprintf(
      "predicted judgment is %s for %s than for %s",
      comparison,
      high_row$x_label[1],
      low_row$x_label[1]
    ))
  }

  interaction_groups <- split(plot_df, plot_df$moderator_label)
  group_slopes <- vapply(
    interaction_groups,
    function(group_df) {
      ordered_group <- group_df[order(group_df$x_value), , drop = FALSE]
      if (nrow(ordered_group) < 2L) return(0)
      tail(ordered_group$predicted, 1) - ordered_group$predicted[1]
    },
    numeric(1)
  )

  if (length(group_slopes) == 0L || max(abs(group_slopes)) == 0) return("the interaction modifies the baseline prediction pattern")

  steepest_group <- names(group_slopes)[which.max(abs(group_slopes))]
  steepest_slope <- unname(group_slopes[steepest_group])
  direction <- if (steepest_slope >= 0) "rises" else "falls"

  sprintf(
    "the predicted relationship %s most sharply for %s when %s",
    direction,
    label_term(visual_spec$x_var),
    paste("the condition is", steepest_group)
  )
}

draw_confidence_band <- function(x, low, high, color) {
  finite_index <- is.finite(x) & is.finite(low) & is.finite(high)
  if (!any(finite_index)) return(invisible(NULL))
  x <- x[finite_index]
  low <- low[finite_index]
  high <- high[finite_index]
  graphics::polygon(
    c(x, rev(x)),
    c(low, rev(high)),
    col = grDevices::adjustcolor(color, alpha.f = 0.20),
    border = NA
  )
  graphics::lines(x, low, col = grDevices::adjustcolor(color, alpha.f = 0.75), lty = 2, lwd = 1.4)
  graphics::lines(x, high, col = grDevices::adjustcolor(color, alpha.f = 0.75), lty = 2, lwd = 1.4)
}

build_interaction_legend_payload <- function(plot_payloads, style) {
  interaction_idx <- which(vapply(plot_payloads, function(payload) identical(payload$visual_spec$kind, "interaction"), logical(1)))
  if (length(interaction_idx) == 0L) return(NULL)

  payload <- plot_payloads[[interaction_idx[1]]]
  moderator_labels <- unique(payload$plot_df$moderator_label)
  moderator_labels <- moderator_labels[!is.na(moderator_labels)]
  if (length(moderator_labels) == 0L) return(NULL)

  palette_dark <- c(style$primary, style$secondary, style$accent)
  list(
    title = get_plot_axis_label(payload$visual_spec$moderator),
    labels = moderator_labels,
    colors = palette_dark[seq_along(moderator_labels)]
  )
}

draw_interaction_legend_panel <- function(legend_payload) {
  if (is.null(legend_payload)) return(invisible(NULL))

  graphics::par(mar = c(0.2, 0.5, 0.2, 0.5), xpd = NA)
  graphics::plot.new()
  graphics::legend(
    "center",
    legend = wrap_plot_labels(legend_payload$labels, width = 16L),
    col = legend_payload$colors,
    lwd = 3,
    pch = 19,
    pt.cex = 1.0,
    bty = "n",
    cex = 0.90,
    ncol = 1,
    title = wrap_title(legend_payload$title, width = 18)
  )
  invisible(NULL)
}

draw_continuous_panel <- function(panel_df, visual_spec, panel_title, style) {
  ordered_df <- panel_df[order(panel_df$x_value), , drop = FALSE]
  ordered_df <- ordered_df[!is.na(ordered_df$predicted), , drop = FALSE]
  if (nrow(ordered_df) == 0L) {
    graphics::plot.new()
    graphics::title(main = wrap_title(panel_title, width = 28))
    graphics::text(0.5, 0.5, "No finite predictions available")
    return(invisible(NULL))
  }
  y_limits <- get_judgment_observed_bounds()
  y_ticks <- get_judgment_axis_ticks()

  graphics::plot(
    ordered_df$x_value,
    ordered_df$predicted,
    type = "n",
    main = wrap_title(panel_title, width = 28),
    xlab = wrap_title(get_plot_axis_label(visual_spec$x_var), width = 26),
    ylab = "Predicted judgment",
    ylim = y_limits,
    yaxt = "n"
  )
  graphics::axis(2, at = y_ticks, labels = y_ticks)
  graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
  draw_confidence_band(ordered_df$x_value, ordered_df$conf_low, ordered_df$conf_high, style$primary)
  graphics::lines(ordered_df$x_value, ordered_df$predicted, col = style$primary, lwd = 3)
}

draw_categorical_panel <- function(panel_df, visual_spec, panel_title, style) {
  ordered_df <- panel_df[order(panel_df$x_value), , drop = FALSE]
  ordered_df <- ordered_df[!is.na(ordered_df$predicted), , drop = FALSE]
  if (nrow(ordered_df) == 0L) {
    graphics::plot.new()
    graphics::title(main = wrap_title(panel_title, width = 28))
    graphics::text(0.5, 0.5, "No finite predictions available")
    return(invisible(NULL))
  }
  y_limits <- get_judgment_observed_bounds()
  y_ticks <- get_judgment_axis_ticks()

  graphics::plot(
    ordered_df$x_value,
    ordered_df$predicted,
    type = "n",
    xaxt = "n",
    main = wrap_title(panel_title, width = 28),
    xlab = wrap_title(get_plot_axis_label(visual_spec$x_var), width = 26),
    ylab = "Predicted judgment",
    ylim = y_limits,
    yaxt = "n"
  )
  graphics::axis(2, at = y_ticks, labels = y_ticks)
  graphics::axis(
    1,
    at = ordered_df$x_value,
    labels = wrap_plot_labels(ordered_df$x_label),
    cex.axis = 0.85
  )
  graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
  draw_confidence_interval_bars(ordered_df$x_value, ordered_df$conf_low, ordered_df$conf_high, style$primary, cap_width = 0.1, lwd = 2)
  graphics::points(ordered_df$x_value, ordered_df$predicted, pch = 19, cex = 1.2, col = style$primary)
}

draw_interaction_panel <- function(panel_df, visual_spec, panel_title, style) {
  panel_df <- panel_df[!is.na(panel_df$predicted), , drop = FALSE]
  if (nrow(panel_df) == 0L) {
    graphics::plot.new()
    graphics::title(main = wrap_title(panel_title, width = 28))
    graphics::text(0.5, 0.5, "No finite predictions available")
    return(invisible(NULL))
  }

  moderator_labels <- unique(panel_df$moderator_label)
  palette_dark <- c(style$primary, style$secondary, style$accent)
  y_limits <- get_judgment_observed_bounds()
  y_ticks <- get_judgment_axis_ticks()

  x_values <- sort(unique(panel_df$x_value))
  graphics::plot(
    x_values,
    rep(NA_real_, length(x_values)),
    type = "n",
    xaxt = if (identical(visual_spec$x_type, "continuous")) "s" else "n",
    main = wrap_title(panel_title, width = 28),
    xlab = wrap_title(get_plot_axis_label(visual_spec$x_var), width = 26),
    ylab = "Predicted judgment",
    ylim = y_limits,
    yaxt = "n"
  )
  graphics::axis(2, at = y_ticks, labels = y_ticks)
  graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)

  if (!identical(visual_spec$x_type, "continuous")) {
    x_labels <- unique(panel_df[, c("x_value", "x_label")])
    x_labels <- x_labels[order(x_labels$x_value), , drop = FALSE]
    graphics::axis(
      1,
      at = x_labels$x_value,
      labels = wrap_plot_labels(x_labels$x_label),
      cex.axis = 0.85
    )
  }

  for (idx in seq_along(moderator_labels)) {
    moderator_label <- moderator_labels[idx]
    color <- palette_dark[((idx - 1L) %% length(palette_dark)) + 1L]
    group_df <- panel_df[panel_df$moderator_label == moderator_label, , drop = FALSE]
    group_df <- group_df[order(group_df$x_value), , drop = FALSE]
    if (identical(visual_spec$x_type, "continuous")) {
      draw_confidence_band(group_df$x_value, group_df$conf_low, group_df$conf_high, color)
    } else {
      draw_confidence_interval_bars(group_df$x_value, group_df$conf_low, group_df$conf_high, color, cap_width = 0.1, lwd = 2)
      graphics::points(group_df$x_value, group_df$predicted, pch = 19, cex = 1.05, col = color)
    }
    graphics::lines(group_df$x_value, group_df$predicted, col = color, lwd = 3)
  }

  invisible(NULL)
}

write_significance_figure <- function(file_path, plot_payloads, figure_title) {
  if (length(plot_payloads) == 0L) return(invisible(FALSE))

  style <- get_extended_plot_style()
  panel_count <- length(plot_payloads)
  legend_payload <- build_interaction_legend_payload(plot_payloads, style)
  has_legend <- !is.null(legend_payload)
  width <- if (panel_count > 1L) 12.6 else 8.8
  height <- if (has_legend) 7.4 else 6.2

  open_accessible_png(file_path, width = width, height = height)
  old_par <- graphics::par(no.readonly = TRUE)
  on.exit({
    graphics::layout(1)
    graphics::par(old_par)
    grDevices::dev.off()
  }, add = TRUE)

  apply_accessible_theme()
  if (has_legend) {
    graphics::layout(
      rbind(seq_len(panel_count), rep(panel_count + 1L, panel_count)),
      heights = c(4.8, 1.6)
    )
  }

  for (payload in plot_payloads) {
    graphics::par(
      mar = c(8.8, 5.0, 3.0, 1.2),
      mgp = c(5.4, 0.9, 0),
      oma = c(0, 0, 0, 0)
    )
    panel_title <- if (identical(payload$approach, "Tobit")) {
      "Tobit"
    } else {
      "Clustered non-parametric"
    }

    if (identical(payload$visual_spec$kind, "continuous_main")) {
      draw_continuous_panel(payload$plot_df, payload$visual_spec, panel_title, style)
    } else if (identical(payload$visual_spec$kind, "categorical_main")) {
      draw_categorical_panel(payload$plot_df, payload$visual_spec, panel_title, style)
    } else {
      draw_interaction_panel(payload$plot_df, payload$visual_spec, panel_title, style)
    }
  }

  if (has_legend) {
    draw_interaction_legend_panel(legend_payload)
  }

  invisible(TRUE)
}
