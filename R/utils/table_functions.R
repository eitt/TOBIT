# R/utils/table_functions.R
# Purpose: Format and export tables for Markdown and LaTeX optimized for Letter width.
# Dependencies: None

#' Format numbers safely
format_number <- function(x, digits = 2) {
  ifelse(is.na(x), "NA", formatC(x, digits = digits, format = "f"))
}

#' Format percentages safely
format_pct <- function(x, digits = 1) {
  ifelse(is.na(x), "NA", paste0(formatC(100 * x, digits = digits, format = "f"), "%"))
}

#' Format p-values safely
format_p_value <- function(p) {
  if (is.na(p)) return("NA")
  if (p < 0.001) return("<0.001")
  formatC(p, digits = 3, format = "f")
}

#' Format confidence intervals safely
format_ci <- function(low, high, digits = 2) {
  paste0("[", format_number(low, digits), ", ", format_number(high, digits), "]")
}

#' Convert a data frame into simple GitHub-flavored Markdown.
to_markdown_table <- function(df, digits = 3) {
  if (!is.data.frame(df) || ncol(df) == 0L) return("")
  
  format_cell <- function(x) {
    if (is.numeric(x)) {
      if (all(is.na(x) | abs(x - round(x)) < .Machine$double.eps^0.5)) {
        return(formatC(x, digits = 0, format = "f"))
      }
      return(formatC(x, digits = digits, format = "f"))
    }
    if (is.logical(x)) {
      return(ifelse(is.na(x), "NA", ifelse(x, "TRUE", "FALSE")))
    }
    x <- as.character(x)
    x[is.na(x)] <- "NA"
    x
  }
  
  formatted <- lapply(df, format_cell)
  formatted_df <- as.data.frame(formatted, stringsAsFactors = FALSE, check.names = FALSE)
  header <- paste0("| ", paste(names(formatted_df), collapse = " | "), " |")
  separator <- paste0("| ", paste(rep("---", ncol(formatted_df)), collapse = " | "), " |")
  rows <- apply(formatted_df, 1, function(row) {
    paste0("| ", paste(row, collapse = " | "), " |")
  })
  
  c(header, separator, rows)
}

#' Escape LaTeX-sensitive characters
escape_latex <- function(x, escape_math = TRUE) {
  x <- as.character(x)
  x[is.na(x)] <- "NA"
  
  if (!escape_math) {
    # If the user explicitly provides LaTeX math, we assume they know what they are doing.
    # We do NOT escape math-related characters.
    return(x)
  }

  escape_plain_text <- function(text) {
    text <- gsub("\\\\", "\\\\textbackslash{}", text)
    text <- gsub("([#$%&_{}])", "\\\\\\1", text, perl = TRUE)
    text <- gsub("~", "\\\\textasciitilde{}", text, fixed = TRUE)
    gsub("\\^", "\\\\textasciicircum{}", text, perl = TRUE)
  }

  preserve_inline_math <- function(text) {
    math_matches <- gregexpr("\\$\\$[^$]*\\$\\$|\\$[^$]*\\$", text, perl = TRUE)[[1]]
    if (length(math_matches) == 1L && math_matches[1] == -1L) {
      return(escape_plain_text(text))
    }

    match_lengths <- attr(math_matches, "match.length")
    math_segments <- regmatches(text, list(math_matches))[[1]]
    placeholders <- paste0("LATEXMATHPLACEHOLDER", seq_along(math_segments), "TOKEN")
    escaped_text <- text

    for (i in rev(seq_along(math_matches))) {
      start <- math_matches[i]
      end <- start + match_lengths[i] - 1L
      escaped_text <- paste0(
        substr(escaped_text, 1L, start - 1L),
        placeholders[i],
        substr(escaped_text, end + 1L, nchar(escaped_text))
      )
    }

    escaped_text <- escape_plain_text(escaped_text)
    for (i in seq_along(placeholders)) {
      escaped_text <- sub(placeholders[i], math_segments[i], escaped_text, fixed = TRUE)
    }

    escaped_text
  }

  vapply(x, preserve_inline_math, character(1), USE.NAMES = FALSE)
}

#' Build a LaTeX table optimized for letter-page width
to_latex_table <- function(df, caption, label, digits = 3, longtable = FALSE, escape_math = TRUE) {
  if (!is.data.frame(df) || ncol(df) == 0L) return("")

  format_cell <- function(x) {
    if (is.numeric(x)) {
      if (all(is.na(x) | abs(x - round(x)) < .Machine$double.eps^0.5)) {
        return(formatC(x, digits = 0, format = "f"))
      }
      return(formatC(x, digits = digits, format = "f"))
    }
    if (is.logical(x)) {
      return(ifelse(is.na(x), "NA", ifelse(x, "TRUE", "FALSE")))
    }
    as.character(x)
  }
  
  formatted <- lapply(df, format_cell)
  formatted_df <- as.data.frame(formatted, stringsAsFactors = FALSE, check.names = FALSE)
  formatted_df[] <- lapply(formatted_df, escape_latex, escape_math = escape_math)
  caption_text <- escape_latex(caption, escape_math = escape_math)
  col_spec <- paste(rep("l", ncol(formatted_df)), collapse = "")
  header <- paste(vapply(names(formatted_df), escape_latex, character(1), escape_math = escape_math), collapse = " & ")
  body <- apply(formatted_df, 1, function(row) paste(row, collapse = " & "))
  
  if (longtable) {
    return(c(
      paste0("\\begin{longtable}{", col_spec, "}"),
      paste0("\\caption{", caption_text, "}\\label{", label, "}\\\\"),
      "\\toprule",
      paste0(header, " \\\\"),
      "\\midrule",
      "\\endfirsthead",
      "\\toprule",
      paste0(header, " \\\\"),
      "\\midrule",
      "\\endhead",
      paste0(body, " \\\\"),
      "\\bottomrule",
      "\\end{longtable}"
    ))
  }
  
  c(
    "\\begin{table}[H]",
    "\\centering",
    paste0("\\caption{", caption_text, "}"),
    paste0("\\label{", label, "}"),
    paste0("\\resizebox{\\textwidth}{!}{%"),
    paste0("\\begin{tabular}{", col_spec, "}"),
    "\\toprule",
    paste0(header, " \\\\"),
    "\\midrule",
    paste0(body, " \\\\"),
    "\\bottomrule",
    "\\end{tabular}",
    "}",
    "\\end{table}"
  )
}

#' Insert a previously written PNG into the LaTeX report.
latex_include_graphic <- function(file_path, caption, label, width = "0.92\\textwidth") {
  rel_path <- gsub("\\\\", "/", file_path)
  c(
    "\\begin{figure}[H]",
    "\\centering",
    paste0("\\includegraphics[width=", width, "]{", rel_path, "}"),
    paste0("\\caption{", escape_latex(caption), "}"),
    paste0("\\label{", label, "}"),
    "\\end{figure}"
  )
}
