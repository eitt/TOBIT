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
  if (is.na(p)) {
    return("NA")
  }
  if (p < 0.001) {
    return("<0.001")
  }
  formatC(p, digits = 3, format = "f")
}

#' Conventional significance markers for p-values.
significance_symbol <- function(p) {
  if (length(p) > 1L) {
    return(vapply(p, significance_symbol, character(1), USE.NAMES = FALSE))
  }
  if (is.na(p)) {
    return("")
  }
  if (p < 0.001) {
    return("***")
  }
  if (p < 0.01) {
    return("**")
  }
  if (p < 0.05) {
    return("*")
  }
  if (p < 0.10) {
    return("+")
  }
  ""
}

#' Format p-values together with their conventional significance markers.
format_p_value_with_symbol <- function(p) {
  if (length(p) > 1L) {
    return(vapply(p, format_p_value_with_symbol, character(1), USE.NAMES = FALSE))
  }
  paste0(format_p_value(p), significance_symbol(p))
}

#' Append human-readable significance columns to a model table.
add_p_value_display_columns <- function(df, p_col = "p_value") {
  if (!is.data.frame(df) || !(p_col %in% names(df))) {
    return(df)
  }
  df$p_symbol <- significance_symbol(df[[p_col]])
  df[[paste0(p_col, "_display")]] <- format_p_value_with_symbol(df[[p_col]])
  df
}

#' Format confidence intervals safely
format_ci <- function(low, high, digits = 2) {
  paste0("[", format_number(low, digits), ", ", format_number(high, digits), "]")
}

# Build a markdown-ready table block.
# Backward compatible modes:
# - build_table_block(df): plain table (legacy behavior).
# - build_table_block(df, caption = "..."): table + Pandoc caption.
# - build_table_block(df, digits = 2, empty_message = "..."): legacy formatting args.
build_table_block <- function(
  table_df,
  caption = NULL,
  label = NULL,
  digits = 3,
  empty_message = "_No table data available._"
) {
  table_md <- to_markdown_table(table_df, digits = digits)

  if (length(table_md) == 0L || all(!nzchar(table_md))) {
    return(empty_message)
  }

  if (is.null(caption) || !nzchar(caption)) {
    return(table_md)
  }

  caption_line <- if (!is.null(label) && nzchar(label)) {
    paste0("Table: ", caption, " {#", label, "}")
  } else {
    paste0("Table: ", caption)
  }

  c(
    table_md,
    caption_line,
    ""
  )
}

#' Convert a data frame into simple GitHub-flavored Markdown.
to_markdown_table <- function(df, digits = 3) {
  if (!is.data.frame(df) || ncol(df) == 0L) {
    return("")
  }

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
to_latex_table <- function(
  df,
  caption,
  label,
  digits = 3,
  longtable = FALSE,
  escape_math = TRUE,
  preserve_font_size = FALSE
) {
  if (!is.data.frame(df) || ncol(df) == 0L) {
    return("")
  }

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
  col_spec <- if (isTRUE(preserve_font_size) && ncol(formatted_df) >= 2L) {
    paste0(
      ">{\\raggedright\\arraybackslash}X",
      paste(rep("l", ncol(formatted_df) - 1L), collapse = "")
    )
  } else if (isTRUE(preserve_font_size)) {
    ">{\\raggedright\\arraybackslash}X"
  } else {
    paste(rep("l", ncol(formatted_df)), collapse = "")
  }
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

  if (isTRUE(preserve_font_size)) {
    return(c(
      "\\begin{table}[H]",
      "\\centering",
      "{\\fontsize{11}{13}\\selectfont",
      "\\renewcommand{\\arraystretch}{1.10}",
      paste0("\\caption{", caption_text, "}"),
      paste0("\\label{", label, "}"),
      paste0("\\begin{tabularx}{\\textwidth}{", col_spec, "}"),
      "\\toprule",
      paste0(header, " \\\\"),
      "\\midrule",
      paste0(body, " \\\\"),
      "\\bottomrule",
      "\\end{tabularx}",
      "}",
      "\\end{table}"
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

# Build a LaTeX table with fixed-width columns for the H1-H5 formula catalog.
# Narrow first columns (H/Role), wide formula/focus columns.
to_latex_formula_catalog_table <- function(df, caption, label) {
  if (!is.data.frame(df) || ncol(df) == 0L) {
    return(character(0))
  }

  format_cell <- function(x) {
    x <- as.character(x)
    x[is.na(x)] <- "NA"
    x
  }

  formatted <- lapply(df, format_cell)
  formatted_df <- as.data.frame(formatted, stringsAsFactors = FALSE, check.names = FALSE)
  if ("Formula" %in% names(formatted_df)) {
    # Add natural wrap opportunities using visible separators only (no inline TeX commands).
    formula_text <- as.character(df$Formula)
    formula_text[is.na(formula_text)] <- "NA"
    formula_text <- gsub(":", " : ", formula_text, fixed = TRUE)
    formula_text <- gsub("\\+", " + ", formula_text)
    formatted_df$Formula <- formula_text
  }
  formatted_df[] <- lapply(formatted_df, escape_latex, escape_math = TRUE)

  header <- paste(vapply(names(formatted_df), escape_latex, character(1), escape_math = TRUE), collapse = " & ")
  body <- apply(formatted_df, 1, function(row) paste(row, collapse = " & "))

  col_spec <- paste0(
    "@{}",
    ">{\\raggedright\\arraybackslash\\hspace{0pt}}p{0.06\\textwidth}",
    ">{\\raggedright\\arraybackslash\\hspace{0pt}}p{0.12\\textwidth}",
    ">{\\raggedright\\arraybackslash\\hspace{0pt}}p{0.58\\textwidth}",
    ">{\\raggedright\\arraybackslash\\hspace{0pt}}p{0.24\\textwidth}",
    "@{}"
  )

  c(
    "\\begingroup",
    "\\setlength{\\tabcolsep}{2pt}",
    "\\scriptsize",
    paste0("\\begin{longtable}{", col_spec, "}"),
    paste0("\\caption{", escape_latex(caption), "}\\label{", label, "}\\\\"),
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
    "\\end{longtable}",
    "\\endgroup"
  )
}

#' Insert a previously written PNG into the LaTeX report.
latex_include_graphic <- function(file_path, caption, label, width = "0.92\\textwidth", escape = TRUE) {
  rel_path <- gsub("\\\\", "/", file_path)
  caption_text <- if (escape) escape_latex(caption) else caption
  c(
    "\\begin{figure}[H]",
    "\\centering",
    paste0("\\includegraphics[width=", width, "]{", rel_path, "}"),
    paste0("\\caption{", caption_text, "}"),
    paste0("\\label{", label, "}"),
    "\\end{figure}"
  )
}
