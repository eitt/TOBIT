source("R/utils/table_functions.R")
source("R/utils/figure_functions.R")
source("R/utils/build_role_relational_variables.R")

read_csv_or_empty <- function(file_path) {
  if (!file.exists(file_path)) {
    return(data.frame())
  }
  read.csv(file_path, stringsAsFactors = FALSE)
}

get_current_symbol_dictionary <- function() {
  data.frame(
    symbol = c(
      "judgement",
      "y*",
      "iri_fs / iri_ec / iri_pt / iri_pd",
      "decision_target",
      "decision_other",
      "victim_N1_group / victim_N2_group",
      "bystander_victim_group / bystander_N1_group / bystander_N2_group",
      "N1_N2_same_faculty",
      "factor(session)",
      "cluster = id",
      "Log(scale)"
    ),
    definition = c(
      "Observed moral judgement on the bounded scale from -9 to 9.",
      "Latent judgement tendency underlying the censored Tobit observation.",
      "IRI empathy dimensions: fantasy, empathic concern, perspective taking, and personal distress.",
      "Indicator for whether the target negotiator accepted the harmful deal; judgement is directed toward this actor.",
      "Indicator for whether the other negotiator accepted the harmful deal and may shift judgement of the target through the joint outcome context.",
      "Victim-specific relations to negotiator 1 and negotiator 2, with ingroup defined by faculty coincidence including control-control matches.",
      "Bystander-side relational factors for the victim and both negotiators, again using faculty coincidence as ingroup.",
      "Context term indicating whether N1 and N2 share faculty membership.",
      "Session fixed effects included directly in every fitted formula.",
      "Participant-level clustering used for robust standard errors and repeated-measures adjustment.",
      "Estimated Tobit log-scale parameter summarizing latent residual dispersion."
    ),
    stringsAsFactors = FALSE
  )
}

get_current_predictor_glossary <- function() {
  data.frame(
    predictor = c(
      "iri_fs",
      "iri_ec",
      "iri_pt",
      "iri_pd",
      "victim_N1_groupingroup",
      "victim_N1_groupoutgroup",
      "victim_N2_groupingroup",
      "victim_N2_groupoutgroup",
      "bystander_victim_groupoutgroup",
      "bystander_N1_groupingroup",
      "bystander_N1_groupoutgroup",
      "bystander_N2_groupingroup",
      "bystander_N2_groupoutgroup",
      "N1_N2_same_facultysame",
      "iri_fs:victim_N1_groupoutgroup",
      "iri_ec:victim_N2_groupoutgroup",
      "iri_pt:bystander_victim_groupoutgroup",
      "iri_pd:bystander_N1_groupoutgroup",
      "decision_target",
      "decision_other",
      "decision_target:decision_other",
      "faculty_player_factorEngineering",
      "sex_female",
      "age",
      "ses"
    ),
    compact_label = c(
      "FS",
      "EC",
      "PT",
      "PD",
      "V-N1 In",
      "V-N1 Out",
      "V-N2 In",
      "V-N2 Out",
      "B-V Out",
      "B-N1 In",
      "B-N1 Out",
      "B-N2 In",
      "B-N2 Out",
      "SameFac",
      "FS x V-N1 Out",
      "EC x V-N2 Out",
      "PT x B-V Out",
      "PD x B-N1 Out",
      "Target Acc",
      "Other Acc",
      "Target x Other",
      "Eng part.",
      "Woman",
      "Age",
      "SES"
    ),
    meaning = c(
      "Fantasy empathy dimension.",
      "Empathic concern empathy dimension.",
      "Perspective-taking empathy dimension.",
      "Personal-distress empathy dimension.",
      "Victim and N1 are from the same faculty, relative to the ingroup baseline.",
      "Victim and N1 are from different faculties, relative to the ingroup baseline.",
      "Victim and N2 are from the same faculty, relative to the ingroup baseline.",
      "Victim and N2 are from different faculties, relative to the ingroup baseline.",
      "Bystander and victim are from different faculties, relative to ingroup.",
      "Bystander and N1 are from the same faculty, relative to the ingroup baseline.",
      "Bystander and N1 are from different faculties, relative to the ingroup baseline.",
      "Bystander and N2 are from the same faculty, relative to the ingroup baseline.",
      "Bystander and N2 are from different faculties, relative to the ingroup baseline.",
      "N1 and N2 share faculty, relative to different-faculty context.",
      "Fantasy slope difference when victim-N1 is outgroup rather than ingroup.",
      "Empathic-concern slope difference when victim-N2 is outgroup rather than ingroup.",
      "Perspective-taking slope difference when the bystander-victim relation is outgroup rather than ingroup.",
      "Personal-distress slope difference when the bystander-N1 relation is outgroup rather than ingroup.",
      "Target negotiator accepted the harmful deal.",
      "Other negotiator accepted the harmful deal.",
      "Joint decision effect when both negotiator decisions are considered together.",
      "Participant belongs to Engineering, relative to Humanities.",
      "Participant is a woman.",
      "Participant age.",
      "Participant socioeconomic status."
    ),
    stringsAsFactors = FALSE
  )
}

label_current_term <- function(term) {
  if (length(term) > 1L) {
    return(vapply(term, label_current_term, character(1), USE.NAMES = FALSE))
  }

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
    return(paste(vapply(strsplit(term, ":", fixed = TRUE)[[1]], label_current_term, character(1)), collapse = " x "))
  }
  term
}

get_interaction_interpretation_rules <- function() {
  c(
    "When an interaction is statistically relevant, the main effects should be read as the baseline component of the relationship rather than the whole substantive story.",
    "Continuous-by-factor interactions indicate that the empathy slope changes across relational conditions.",
    "Factor-by-factor interactions indicate that the joint context differs from what would be expected by adding the two main contrasts independently.",
    "The target-by-other decision interaction indicates that the moral meaning of one negotiator's choice depends on what the counterpart did.",
    "Session effects are adjustment terms only and are not interpreted as substantive experimental mechanisms."
  )
}

get_dataset_sample_description <- function() {
  c(
    "The report uses the consolidated long experimental dataset as the single analytical source.",
    "Each participant contributes 20 judgement rows in principle: ten scenarios multiplied by two target-negotiator evaluations.",
    "Each imported row remains one real judgement observation on the target negotiator, enriched with relational context for N1, N2, victim, and bystander without duplicating rows.",
    "Double counting is prevented because N1 and N2 are reconstructed as contextual attributes inside each existing row rather than by expanding the file into duplicated negotiator-specific observations.",
    "Victim and bystander analyses are estimated separately so that relational coding follows the role-specific logic of the experiment."
  )
}

get_current_tobit_math_foundations <- function() {
  c(
    "The primary estimator is a two-sided Tobit fitted with `survival::survreg`.",
    "",
    "$$y_i = \\max(-9, \\min(9, y_i^*))$$",
    "",
    "$$y_i^* = \\beta_0 + X_i\\beta + \\delta_{session(i)} + \\varepsilon_i$$",
    "",
    "where `factor(session)` supplies session fixed effects and cluster-robust standard errors are computed at the participant level through `cluster = id` with `robust = TRUE`.",
    "This report therefore treats session as an implemented fixed-effect adjustment, not as a random intercept."
  )
}

get_current_limitations <- function() {
  c(
    "The production branch does not fit a full multilevel Tobit with explicit random participant and session intercepts inside the same estimator.",
    "Sparse relational cells can produce rank-deficient design matrices, so some interaction contrasts are dropped automatically and reported as such.",
    "The dynamic figures visualize model-implied predictions from the saved primary Tobit fits and should be interpreted jointly with the coefficient tables rather than as standalone causal effects."
  )
}

compute_descriptive_clustering_diagnostic <- function(data) {
  participant_means <- stats::aggregate(judgement ~ id, data = data, FUN = mean, na.rm = TRUE)
  merged <- merge(data, participant_means, by = "id", suffixes = c("", "_participant_mean"))
  between_var <- stats::var(participant_means$judgement, na.rm = TRUE)
  within_var <- stats::var(merged$judgement - merged$judgement_participant_mean, na.rm = TRUE)
  icc <- if ((between_var + within_var) > 0) between_var / (between_var + within_var) else NA_real_
  avg_cluster_size <- mean(table(data$id))
  design_effect <- 1 + ((avg_cluster_size - 1) * icc)
  ess <- if (is.finite(design_effect) && design_effect > 0) nrow(data) / design_effect else NA_real_

  data.frame(
    metric = c("participants", "observations", "average_observations_per_id", "icc_descriptive", "design_effect", "effective_sample_size"),
    value = c(length(unique(data$id)), nrow(data), avg_cluster_size, icc, design_effect, ess),
    stringsAsFactors = FALSE
  )
}

build_participant_correlation_table <- function(participants, judgments_analysis) {
  participant_mean_judgement <- aggregate(
    judgement ~ id,
    data = judgments_analysis,
    FUN = function(x) mean(x, na.rm = TRUE)
  )
  participant_level <- merge(
    participants,
    participant_mean_judgement,
    by = "id",
    all.x = TRUE
  )
  corr_matrix <- stats::cor(
    participant_level[, c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "judgement"), drop = FALSE],
    use = "pairwise.complete.obs"
  )
  data.frame(
    term = rownames(corr_matrix),
    corr_matrix,
    row.names = NULL,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

is_session_term <- function(term) {
  grepl("^factor\\(session\\)", term)
}

is_control_only_term <- function(term) {
  term %in% c("(Intercept)", "age", "ses", "sex_female", "Log(scale)") ||
    grepl("^faculty_player_factor", term) ||
    is_session_term(term)
}

is_focal_term_for_hypothesis <- function(hypothesis_id, term_name) {
  if (term_name == "(Intercept)" || is_session_term(term_name) || grepl("^faculty_player_factor", term_name)) {
    return(FALSE)
  }

  switch(
    hypothesis_id,
    H1 = grepl("^iri_", term_name),
    H2 = grepl("victim_N|bystander_|N1_N2_same_faculty", term_name),
    H3 = grepl("^iri_|victim_N|bystander_|N1_N2_same_faculty", term_name),
    H4 = grepl("^decision_target$|^decision_other$|decision_target:decision_other", term_name),
    H5 = grepl("^iri_|victim_N|bystander_|N1_N2_same_faculty|decision_target|decision_other", term_name),
    FALSE
  )
}

build_role_significance_summary <- function(coef_summary) {
  if (nrow(coef_summary) == 0L) {
    return(data.frame())
  }

  sig_df <- coef_summary[
    !vapply(seq_len(nrow(coef_summary)), function(i) is_session_term(coef_summary$term[[i]]), logical(1)) &
      vapply(seq_len(nrow(coef_summary)), function(i) is_focal_term_for_hypothesis(coef_summary$hypothesis[[i]], coef_summary$term[[i]]), logical(1)),
    ,
    drop = FALSE
  ]

  all_cells <- expand.grid(
    hypothesis = paste0("H", 1:5),
    role = c("Victim", "Bystander"),
    stringsAsFactors = FALSE
  )

  if (nrow(sig_df) == 0L) {
    all_cells$support <- "None below p < 0.10"
    return(all_cells)
  }

  sig_df$support_label <- ifelse(
    is.na(sig_df$p_symbol) | sig_df$p_symbol == "",
    label_current_term(sig_df$term),
    paste0(label_current_term(sig_df$term), sig_df$p_symbol)
  )

  sig_df <- sig_df[sig_df$p_value < 0.10, , drop = FALSE]
  if (nrow(sig_df) == 0L) {
    all_cells$support <- "None below p < 0.10"
    return(all_cells)
  }

  summary_df <- aggregate(
    support_label ~ hypothesis + role,
    data = sig_df,
    FUN = function(x) paste(unique(x), collapse = "; ")
  )
  names(summary_df)[3] <- "support"

  merged <- merge(all_cells, summary_df, by = c("hypothesis", "role"), all.x = TRUE)
  merged$support[is.na(merged$support)] <- "None below p < 0.10"
  merged
}

prepare_report_coefficient_table <- function(coef_df) {
  if (nrow(coef_df) == 0L) {
    return(coef_df)
  }
  filtered <- coef_df[!vapply(coef_df$term, is_session_term, logical(1)), , drop = FALSE]
  filtered$term_label <- vapply(filtered$term, label_current_term, character(1))
  filtered[, c("term_label", "estimate", "std_error", "conf_low", "conf_high", "p_value_display"), drop = FALSE]
}

generate_model_narrative <- function(coef_df, hypothesis_id, role_label) {
  if (nrow(coef_df) == 0L) {
    return("No coefficients were available for interpretation.")
  }

  focal_df <- coef_df[
    vapply(seq_len(nrow(coef_df)), function(i) is_focal_term_for_hypothesis(hypothesis_id, coef_df$term[[i]]), logical(1)) &
      !vapply(coef_df$term, is_session_term, logical(1)),
    ,
    drop = FALSE
  ]
  focal_sig <- focal_df[!is.na(focal_df$p_value) & focal_df$p_value < 0.10, , drop = FALSE]

  if (nrow(focal_sig) == 0L) {
    return(sprintf(
      "In the %s %s model, no focal hypothesis term reached p < 0.10. The report therefore retains the coefficient table for auditability but does not attach a significance-driven substantive interpretation beyond the descriptive prediction plots.",
      hypothesis_id,
      role_label
    ))
  }

  focal_sig <- focal_sig[order(focal_sig$p_value, -abs(focal_sig$estimate)), , drop = FALSE]
  top_rows <- utils::head(focal_sig, 3)
  effect_sentences <- vapply(
    seq_len(nrow(top_rows)),
    function(i) {
      direction <- ifelse(top_rows$estimate[[i]] >= 0, "higher", "lower")
      sprintf(
        "%s is associated with %s predicted judgement (estimate = %.2f, p = %s).",
        label_current_term(top_rows$term[[i]]),
        direction,
        top_rows$estimate[[i]],
        top_rows$p_value_display[[i]]
      )
    },
    character(1)
  )

  paste(
    sprintf(
      "The %s %s model shows focal evidence for %s hypothesis terms.",
      hypothesis_id,
      role_label,
      ifelse(nrow(focal_sig) == 1L, "one", as.character(nrow(focal_sig)))
    ),
    paste(effect_sentences, collapse = " "),
    "Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative."
  )
}

get_term_component_spec <- function(term_piece) {
  factor_specs <- list(
    victim_N1_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    victim_N2_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    bystander_N1_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    bystander_N2_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    bystander_victim_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    N1_N2_same_faculty = list(ref = "different", levels = c("different", "same")),
    faculty_player_factor = list(ref = "Humanities", levels = c("Humanities", "Engineering"))
  )

  if (term_piece %in% c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "age", "ses")) {
    return(list(type = "continuous", var = term_piece, focus = NULL, reference = NULL))
  }
  if (term_piece %in% c("decision_target", "decision_other", "sex_female")) {
    return(list(type = "binary", var = term_piece, focus = 1, reference = 0))
  }

  for (base_name in names(factor_specs)) {
    if (startsWith(term_piece, base_name)) {
      suffix <- sub(base_name, "", term_piece, fixed = TRUE)
      if (!nzchar(suffix)) next
      return(list(
        type = "factor_contrast",
        var = base_name,
        focus = suffix,
        reference = factor_specs[[base_name]]$ref
      ))
    }
  }

  NULL
}

build_reference_profile <- function(data) {
  reference <- data[1, , drop = FALSE]
  for (col_name in names(reference)) {
    values <- data[[col_name]]
    if (is.factor(values)) {
      modal_name <- names(sort(table(values), decreasing = TRUE))
      reference[[col_name]] <- factor(
        if (length(modal_name) == 0L) levels(values)[1] else modal_name[1],
        levels = levels(values)
      )
    } else if (is.numeric(values)) {
      reference[[col_name]] <- mean(values, na.rm = TRUE)
    } else {
      values_chr <- values[!is.na(values)]
      reference[[col_name]] <- if (length(values_chr) == 0L) NA else names(sort(table(values_chr), decreasing = TRUE))[1]
    }
  }
  reference
}

compute_censored_gaussian_expectation <- function(mu, sigma, lower = -9, upper = 9) {
  if (!is.finite(sigma) || sigma <= 0) {
    return(clamp_judgment_scale(mu, lower = lower, upper = upper))
  }
  z_lower <- (lower - mu) / sigma
  z_upper <- (upper - mu) / sigma
  lower_mass <- stats::pnorm(z_lower)
  middle_mass <- stats::pnorm(z_upper) - stats::pnorm(z_lower)
  upper_mass <- 1 - stats::pnorm(z_upper)

  lower * lower_mass +
    mu * middle_mass +
    sigma * (stats::dnorm(z_lower) - stats::dnorm(z_upper)) +
    upper * upper_mass
}

build_aligned_design_matrix <- function(model_fit, newdata) {
  model_terms <- stats::delete.response(stats::terms(model_fit))
  design_matrix <- stats::model.matrix(model_terms, newdata, xlev = model_fit$xlevels)
  coefficient_names <- names(stats::coef(model_fit))
  missing_terms <- setdiff(coefficient_names, colnames(design_matrix))
  if (length(missing_terms) > 0L) {
    zero_block <- matrix(0, nrow = nrow(design_matrix), ncol = length(missing_terms))
    colnames(zero_block) <- missing_terms
    design_matrix <- cbind(design_matrix, zero_block)
  }
  design_matrix[, coefficient_names, drop = FALSE]
}

compute_prediction_summary <- function(model_fit, newdata) {
  coefficient_names <- names(stats::coef(model_fit))
  design_matrix <- build_aligned_design_matrix(model_fit, newdata)
  coefficients <- stats::coef(model_fit)
  valid_coef <- is.finite(coefficients)
  coefficients <- coefficients[valid_coef]
  design_matrix <- design_matrix[, names(coefficients), drop = FALSE]
  linear_predictor <- as.numeric(design_matrix %*% coefficients)
  sigma <- as.numeric(model_fit$scale[1])

  vcov_matrix <- as.matrix(model_fit$var)
  if (is.null(dimnames(vcov_matrix))) {
    full_names <- c(coefficient_names, "Log(scale)")
    if (length(full_names) == nrow(vcov_matrix)) {
      dimnames(vcov_matrix) <- list(full_names, full_names)
    }
  }
  vcov_matrix <- vcov_matrix[names(coefficients), names(coefficients), drop = FALSE]
  se_lp <- sqrt(pmax(rowSums((design_matrix %*% vcov_matrix) * design_matrix), 0))
  z <- stats::qnorm(0.975)

  data.frame(
    predicted = compute_censored_gaussian_expectation(linear_predictor, sigma = sigma),
    conf_low = compute_censored_gaussian_expectation(linear_predictor - z * se_lp, sigma = sigma),
    conf_high = compute_censored_gaussian_expectation(linear_predictor + z * se_lp, sigma = sigma),
    stringsAsFactors = FALSE
  )
}

build_plot_data_for_term <- function(model_fit, data, term_name) {
  data <- coerce_model_factors(as.data.frame(data))

  if (!grepl(":", term_name, fixed = TRUE)) {
    component <- get_term_component_spec(term_name)
    if (is.null(component)) {
      return(NULL)
    }

    reference <- build_reference_profile(data)
    if (component$type == "continuous") {
      x_values <- seq(min(data[[component$var]], na.rm = TRUE), max(data[[component$var]], na.rm = TRUE), length.out = 60L)
      newdata <- reference[rep(1, length(x_values)), , drop = FALSE]
      newdata[[component$var]] <- x_values
      pred_df <- compute_prediction_summary(model_fit, newdata)
      return(data.frame(
        x_value = x_values,
        x_label = format(round(x_values, 2), trim = TRUE),
        moderator_label = NA_character_,
        pred_df,
        stringsAsFactors = FALSE
      ))
    }

    x_values <- c(component$reference, component$focus)
    if (component$type == "binary") {
      x_labels <- c("0", "1")
    } else {
      x_labels <- x_values
    }
    newdata <- reference[rep(1, length(x_values)), , drop = FALSE]
    newdata[[component$var]] <- x_values
    pred_df <- compute_prediction_summary(model_fit, newdata)
    data.frame(
      x_value = seq_along(x_values),
      x_label = x_labels,
      moderator_label = NA_character_,
      pred_df,
      stringsAsFactors = FALSE
    )
  } else {
    parts <- strsplit(term_name, ":", fixed = TRUE)[[1]]
    comp_a <- get_term_component_spec(parts[1])
    comp_b <- get_term_component_spec(parts[2])
    if (is.null(comp_a) || is.null(comp_b)) {
      return(NULL)
    }
    reference <- build_reference_profile(data)
    x_component <- if (identical(comp_a$type, "continuous")) comp_a else comp_a
    moderator_component <- comp_b
    x_values <- if (x_component$type == "continuous") {
      seq(min(data[[x_component$var]], na.rm = TRUE), max(data[[x_component$var]], na.rm = TRUE), length.out = 60L)
    } else {
      c(x_component$reference, x_component$focus)
    }
    moderator_values <- if (moderator_component$type == "continuous") {
      as.numeric(stats::quantile(data[[moderator_component$var]], probs = c(0.25, 0.75), na.rm = TRUE))
    } else {
      c(moderator_component$reference, moderator_component$focus)
    }
    moderator_labels <- as.character(moderator_values)

    blocks <- lapply(seq_along(moderator_values), function(idx) {
      block <- reference[rep(1, length(x_values)), , drop = FALSE]
      block[[x_component$var]] <- x_values
      block[[moderator_component$var]] <- moderator_values[[idx]]
      pred_df <- compute_prediction_summary(model_fit, block)
      data.frame(
        x_value = if (x_component$type == "continuous") x_values else seq_along(x_values),
        x_label = as.character(x_values),
        moderator_label = moderator_labels[[idx]],
        pred_df,
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, blocks)
  }
}

write_significance_plot_current <- function(file_path, plot_df, term_name) {
  if (is.null(plot_df) || nrow(plot_df) == 0L) {
    return(FALSE)
  }
  style <- get_plot_style()
  open_accessible_png(file_path, width = 8.8, height = 6.2)
  apply_accessible_theme()
  graphics::par(mar = c(5, 5, 3.5, 1.5), bty = "l")

  y_limits <- get_judgment_observed_bounds()
  y_ticks <- get_judgment_axis_ticks()

  if (all(is.na(plot_df$moderator_label))) {
    if (length(unique(plot_df$x_value)) > 10L) {
      ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
      graphics::plot(
        ordered_df$x_value,
        ordered_df$predicted,
        type = "n",
        xlab = label_current_term(term_name),
        ylab = "Predicted judgement",
        main = wrap_title(paste("Effect plot for", label_current_term(term_name)), width = 34),
        ylim = y_limits,
        yaxt = "n"
      )
      graphics::axis(2, at = y_ticks, labels = y_ticks)
      graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
      graphics::polygon(
        c(ordered_df$x_value, rev(ordered_df$x_value)),
        c(ordered_df$conf_low, rev(ordered_df$conf_high)),
        col = grDevices::adjustcolor(style$primary, alpha.f = 0.20),
        border = NA
      )
      graphics::lines(ordered_df$x_value, ordered_df$predicted, col = style$primary_dark, lwd = 3)
    } else {
      ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
      graphics::plot(
        ordered_df$x_value,
        ordered_df$predicted,
        type = "n",
        xaxt = "n",
        xlab = label_current_term(term_name),
        ylab = "Predicted judgement",
        main = wrap_title(paste("Grouped prediction for", label_current_term(term_name)), width = 34),
        ylim = y_limits,
        yaxt = "n"
      )
      graphics::axis(2, at = y_ticks, labels = y_ticks)
      graphics::axis(1, at = ordered_df$x_value, labels = ordered_df$x_label)
      graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
      draw_confidence_interval_bars(ordered_df$x_value, ordered_df$conf_low, ordered_df$conf_high, style$primary_dark)
      graphics::lines(ordered_df$x_value, ordered_df$predicted, col = style$primary_dark, lwd = 2)
      graphics::points(ordered_df$x_value, ordered_df$predicted, pch = 19, col = style$primary_dark)
    }
  } else {
    groups <- split(plot_df, plot_df$moderator_label)
    palette <- c(style$primary_dark, "#B55B15", "#2E8540")
    all_x <- sort(unique(plot_df$x_value))
    graphics::plot(
      all_x,
      rep(NA_real_, length(all_x)),
      type = "n",
      xlab = label_current_term(term_name),
      ylab = "Predicted judgement",
      main = wrap_title(paste("Interaction plot for", label_current_term(term_name)), width = 34),
      ylim = y_limits,
      yaxt = "n",
      xaxt = if (length(unique(plot_df$x_value)) > 10L) "s" else "n"
    )
    graphics::axis(2, at = y_ticks, labels = y_ticks)
    if (length(unique(plot_df$x_value)) <= 10L) {
      x_labels <- unique(plot_df[, c("x_value", "x_label")])
      x_labels <- x_labels[order(x_labels$x_value), , drop = FALSE]
      graphics::axis(1, at = x_labels$x_value, labels = x_labels$x_label)
    }
    graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
    idx <- 1L
    for (group_name in names(groups)) {
      group_df <- groups[[group_name]]
      group_df <- group_df[order(group_df$x_value), , drop = FALSE]
      color <- palette[((idx - 1L) %% length(palette)) + 1L]
      graphics::lines(group_df$x_value, group_df$predicted, col = color, lwd = 3)
      graphics::points(group_df$x_value, group_df$predicted, col = color, pch = 19)
      draw_confidence_interval_bars(group_df$x_value, group_df$conf_low, group_df$conf_high, color)
      idx <- idx + 1L
    }
    graphics::legend("topleft", legend = names(groups), col = palette[seq_along(groups)], lwd = 3, pch = 19, bty = "n")
  }

  grDevices::dev.off()
  TRUE
}

describe_plot_pattern_current <- function(plot_df) {
  if (is.null(plot_df) || nrow(plot_df) == 0L) {
    return("No finite prediction pattern could be summarized.")
  }
  if (all(is.na(plot_df$moderator_label))) {
    ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
    if (nrow(ordered_df) < 2L) {
      return("The figure summarizes the fitted predicted judgement profile.")
    }
    direction <- ifelse(tail(ordered_df$predicted, 1) >= ordered_df$predicted[1], "higher", "lower")
    return(sprintf("Across the displayed contrast, the model implies %s predicted judgement toward the right-hand side of the plot.", direction))
  }
  "The plotted lines summarize how the fitted predicted judgement changes across the focal term while holding the remaining covariates at their reference profile."
}
