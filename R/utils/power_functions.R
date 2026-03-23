# R/utils/power_functions.R
# Purpose: Calculate Intraclass Correlation Coefficient (ICC), Design Effect,
# and Effective Sample Size (ESS) for clustered repeated-measures data.
# Dependencies: base R (stats)

#' Calculate ANOVA-based ICC (Intraclass Correlation Coefficient)
#' @param outcome Vector of numeric outcome values (e.g., judgements)
#' @param cluster_id Vector of cluster identifiers (e.g., participant IDs)
#' @return Numeric ICC value constrained to [0, 1]
calc_icc_anova <- function(outcome, cluster_id) {
  df <- data.frame(y = outcome, id = as.factor(cluster_id))
  df <- stats::na.omit(df)
  
  if (nrow(df) < 2L || length(unique(df$id)) < 2L) return(0)
  
  fit <- stats::aov(y ~ id, data = df)
  anova_table <- summary(fit)[[1]]
  
  ms_between <- anova_table$`Mean Sq`[1]
  ms_within <- anova_table$`Mean Sq`[2]
  
  k_groups <- length(unique(df$id))
  n_total <- nrow(df)
  n_avg <- n_total / k_groups
  
  if (is.na(ms_between) || is.na(ms_within) || ms_within == 0) return(0)
  
  icc <- (ms_between - ms_within) / (ms_between + (n_avg - 1) * ms_within)
  
  # ICC is theoretically bounded [0, 1] for variance decomposition
  max(0, min(1, icc))
}

#' Calculate Effective Sample Size details
#' @param outcome Vector of numeric outcomes
#' @param cluster_id Vector of cluster identifiers
#' @return A list containing ICC, Design Effect (Deff), and Effective Sample Size (ESS)
calc_effective_sample_size <- function(outcome, cluster_id) {
  df <- data.frame(y = outcome, id = as.factor(cluster_id))
  df <- stats::na.omit(df)
  n_total <- nrow(df)
  n_clusters <- length(unique(df$id))
  
  if (n_clusters <= 0 || n_total <= 0) {
    return(list(TotalN = 0, Clusters = 0, ICC = NA, DesignEffect = NA, EffectiveN = 0))
  }
  
  icc <- calc_icc_anova(df$y, df$id)
  
  # Average cluster size m
  m <- n_total / n_clusters
  
  # Design effect formula DE = 1 + (m - 1) * rho
  deff <- 1 + (m - 1) * icc
  
  # Effective Sample Size
  ess <- n_total / deff
  
  list(
    TotalN = n_total,
    Clusters = n_clusters,
    AvgClusterSize = m,
    ICC = icc,
    DesignEffect = deff,
    EffectiveN = ess
  )
}
