# R/utils/transform_functions.R
# Purpose: Helpers for psychometric scoring and safe statistics.
# Dependencies: None

#' Calculate a row mean, returning NA if missingness exceeds a threshold.
#'
#' @param df Data frame containing the items.
#' @param cols Character vector of column names.
#' @param min_non_missing Integer. Minimum number of non-NA values required.
row_mean_with_floor <- function(df, cols, min_non_missing = ceiling(length(cols) * 0.8)) {
  available <- rowSums(!is.na(df[, cols, drop = FALSE]))
  values <- rowMeans(df[, cols, drop = FALSE], na.rm = TRUE)
  values[available < min_non_missing] <- NA_real_
  values
}

#' Calculate Cronbach's alpha for internal consistency.
#'
#' @param df Data frame containing the items.
#' @param cols Character vector of column names.
cronbach_alpha <- function(df, cols) {
  item_frame <- df[, cols, drop = FALSE]
  item_frame <- item_frame[stats::complete.cases(item_frame), , drop = FALSE]
  if (nrow(item_frame) < 2L || ncol(item_frame) < 2L) return(NA_real_)
  
  item_vars <- apply(item_frame, 2, stats::var)
  total_scores <- rowSums(item_frame)
  total_var <- stats::var(total_scores)
  
  if (is.na(total_var) || total_var <= 0) return(NA_real_)
  
  k <- ncol(item_frame)
  (k / (k - 1)) * (1 - sum(item_vars) / total_var)
}

#' Safe mean computation
safe_mean <- function(x) {
  if (all(is.na(x))) return(NA_real_)
  mean(x, na.rm = TRUE)
}

#' Safe standard deviation computation
safe_sd <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) <= 1L) return(NA_real_)
  stats::sd(x)
}

#' Safe standard error computation
safe_se <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) <= 1L) return(NA_real_)
  stats::sd(x) / sqrt(length(x))
}

#' Summarize continuous outcome over grouping variables
summarise_group <- function(df, group_vars, outcome = "judgement") {
  split_index <- interaction(df[, group_vars, drop = FALSE], drop = TRUE, sep = "___")
  chunks <- split(df, split_index)
  
  rows <- lapply(chunks, function(chunk) {
    keys <- chunk[1, group_vars, drop = FALSE]
    keys$Observations <- nrow(chunk)
    keys$MeanJudgement <- safe_mean(chunk[[outcome]])
    keys$SDJudgement <- safe_sd(chunk[[outcome]])
    keys$SEJudgement <- safe_se(chunk[[outcome]])
    keys$Lower95 <- keys$MeanJudgement - 1.96 * keys$SEJudgement
    keys$Upper95 <- keys$MeanJudgement + 1.96 * keys$SEJudgement
    keys
  })
  
  result <- do.call(rbind, rows)
  rownames(result) <- NULL
  result
}
