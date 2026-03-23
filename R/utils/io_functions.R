# R/utils/io_functions.R
# Purpose: Robust data reading, writing, and safe text generation.
# Dependencies: get_project_paths()

#' Locate Python command for Excel fallback
find_python_command <- function() {
  candidates <- c(Sys.which("python"), Sys.which("py"))
  candidates <- candidates[nzchar(candidates)]
  if (length(candidates) == 0L) return("")
  candidates[[1]]
}

#' Read Excel data with built-in Python fallback
#'
#' @param input_file Character. Path to the raw Excel dataset.
#' @return A clean base-R data frame.
read_source_data <- function(input_file) {
  if (!file.exists(input_file)) {
    stop("Input file not found: ", input_file, call. = FALSE)
  }
  
  if (requireNamespace("readxl", quietly = TRUE)) {
    return(as.data.frame(readxl::read_xlsx(input_file)))
  }
  
  python_cmd <- find_python_command()
  if (!nzchar(python_cmd)) {
    stop("readxl is missing and no python fallback found.", call. = FALSE)
  }
  
  py_code <- paste(
    "import pandas as pd",
    sprintf("df = pd.read_excel(r'''%s''')", normalizePath(input_file, winslash = "/", mustWork = TRUE)),
    "print(df.to_csv(index=False))",
    sep = "\n"
  )
  
  csv_lines <- system2(python_cmd, args = "-", input = py_code, stdout = TRUE, stderr = TRUE)
  status <- attr(csv_lines, "status")
  if (!is.null(status) && status != 0L) {
    stop("Python fallback failed.\n", paste(csv_lines, collapse = "\n"), call. = FALSE)
  }
  
  utils::read.csv(text = paste(csv_lines, collapse = "\n"), na.strings = c("", "NA", "NaN"), check.names = FALSE, stringsAsFactors = FALSE)
}

#' Write lines safely using UTF-8 encoding
#'
#' @param lines Character vector to write.
#' @param file_path Character specifying destination file.
write_text_file <- function(lines, file_path) {
  con <- file(file_path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeLines(enc2utf8(lines), con = con, useBytes = TRUE)
}
