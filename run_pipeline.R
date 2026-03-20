args <- commandArgs(trailingOnly = TRUE)
project_root <- if (length(args) >= 1L) args[[1]] else "."

source(file.path(project_root, "R", "pipeline_functions.R"))

results <- run_full_pipeline(project_root)

cat("Pipeline completed.\n")
cat("Markdown report:", results$paths$report_md, "\n")
if (isTRUE(results$word_exported)) {
  cat("Word report:", results$paths$report_docx, "\n")
} else {
  cat("Word report was not created because Pandoc was not found.\n")
}
cat("LaTeX report:", results$paths$report_tex, "\n")
if (isTRUE(results$pdf_exported)) {
  cat("PDF report:", results$paths$report_pdf, "\n")
} else {
  cat("PDF report was not created because pdflatex was not found or LaTeX compilation failed.\n")
}
