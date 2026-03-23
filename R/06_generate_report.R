# R/06_generate_report.R
# Purpose: Dynamically generate a full scientific manuscript (Markdown, LaTeX, PDF, Word)
# incorporating theoretical foundations, bivariate stats, power analysis, 
# dynamic NLP coefficient interpretations, and normality tests.
# Execution Order: 7

source("R/00_config.R")
source("R/utils/io_functions.R")
source("R/utils/power_functions.R")
source("R/utils/table_functions.R")
source("R/utils/narrative_functions.R")
source("R/utils/model_functions.R")
source("R/utils/nl_generation.R")
paths <- get_project_paths()

message("Generating Comprehensive Scientific Manuscript (LaTeX/PDF/Word)...")

# 1. LOAD DATA & ASSETS
judgments_accept <- read.csv(paths$processed_accept, stringsAsFactors = FALSE)
power_results <- calc_effective_sample_size(judgments_accept$judgement, judgments_accept$id)
bivar_cor <- read.csv(file.path(paths$tables_dir, "bivariate_correlations.csv"), row.names = 1, check.names = FALSE)

# Helper for rendering dual model sections (A and B)
build_model_section <- function(hypothesis_id, model_suffix, table_caption) {
  coef_file <- file.path(paths$models_dir, sprintf("%s_%s_coefficients.csv", hypothesis_id, model_suffix))
  model_file <- file.path(paths$models_dir, sprintf("%s_%s_model.rds", hypothesis_id, model_suffix))
  
  if (!file.exists(coef_file) || !file.exists(model_file)) return(c("Model outputs missing."))
  
  coef_df <- read.csv(coef_file, stringsAsFactors = FALSE)
  model_fit <- readRDS(model_file)
  
  table_latex <- to_latex_table(
    coef_df[, c("label", "estimate", "std_error", "p_value")], 
    table_caption, 
    sprintf("tab:%s_%s", tolower(hypothesis_id), tolower(model_suffix)),
    digits = 3
  )
  
  narrative <- generate_coefficient_narrative(coef_df)
  normality_text <- test_tobit_normality(model_fit)
  
  c(
    table_latex, 
    "",
    "\\textbf{Interpretation}", 
    "",
    escape_latex(narrative), 
    "", 
    "\\textbf{Diagnostics}", 
    "",
    escape_latex(normality_text), 
    ""
  )
}

# 2. BUILD LATEX CONTENT
latex_lines <- c(
  "\\documentclass[11pt]{article}",
  "\\usepackage[margin=1in]{geometry}",
  "\\usepackage[T1]{fontenc}",
  "\\usepackage[utf8]{inputenc}",
  "\\usepackage{amsmath, amssymb, amsfonts}",
  "\\usepackage{graphicx}",
  "\\usepackage{booktabs}",
  "\\usepackage{float}",
  "\\usepackage{hyperref}",
  "\\title{Scientific Analysis of Moral Judgments using Tobit Models}",
  "\\author{Automated Research Pipeline}",
  paste0("\\date{", format(Sys.Date(), "%B %d, %Y"), "}"),
  "\\begin{document}",
  "\\maketitle",
  "",
  "\\section{Dataset and Sample Description}",
  escape_latex(paste(get_dataset_narration(paths$dataset_mode), collapse = " ")),
  "",
  "\\section{Datacard and Variable Definitions}",
  "The following table defines the primary symbols and variables used in the mathematical specifications and hypothesis tests.",
  to_latex_table(get_symbols_dictionary(), "Symbols and Variable Dictionary.", "tab:symbols", escape_math = FALSE),
  "",
  "\\section{Hypotheses to Test}",
  "\\begin{itemize}",
  "  \\item \\textbf{H1 (Empathy):} Higher empathy predicts lower moral-judgment scores for harmful decisions.",
  "  \\item \\textbf{H2a (Betrayal):} Same-faculty harm receives lower moral-judgment scores than cross-faculty harm.",
  "  \\item \\textbf{H2b (Outgroup):} Outgroup perpetrators receive lower moral-judgment scores than ingroup perpetrators.",
  "  \\item \\textbf{H3 (Moderation):} The empathy effect is stronger in outgroup cases.",
  "\\end{itemize}",
  "",
  "\\section{Mathematical Approach and Theoretical Foundations}",
  paste(get_math_foundations(), collapse = "\n"),
  "",
  "\\section{Analysis of Sample Size Impact}",
  paste(get_error_analysis_narration(), collapse = "\n"),
  sprintf("\nBased on the current run, the observed Intraclass Correlation (ICC) is %.3f, with an Effective Sample Size (ESS) of %.1f.", power_results$ICC, power_results$EffectiveN),
  "",
  "\\section{Descriptive Statistics}",
  "The empathy profile of the sample is visualized in Figure \\ref{fig:radar}, showing the average scores across the four IRI latent variables.",
  latex_include_graphic(file.path("../figures", "figure_03_empathy_radar.png"), "IRI Latent Variable Averages (Radar Plot profile).", "fig:radar"),
  "Judgment severity distributions segmented by experimental conditions are presented in Figure \\ref{fig:dist_panels}.",
  latex_include_graphic(file.path("../figures", "figure_04_severity_panels.png"), "Judgment Severity Distribution (Ingroup vs. Outgroup).", "fig:dist_panels"),
  "",
  "\\section{Bi-variate Statistics}",
  "The correlation matrix between the psychometric subscales and the mean moral judgment is presented below.",
  to_latex_table(bivar_cor, "Correlation Matrix: IRI Subscales and Moral Judgment.", "tab:bivar"),
  "Visual representations of these relationships are provided in Figure \\ref{fig:bivar_scatters}.",
  latex_include_graphic(file.path("../figures", "figure_05_bivariate_scatters.png"), "Bivariate Scatters: IRI Scales vs. Mean Judgment.", "fig:bivar_scatters"),
  "",
  "\\section{Hypothesis Validation and Results}",
  "Detailed coefficient tables for each Tobit model, coupled with natural language interpretive narratives and non-parametric normality diagnostic tests, are provided below.",
  "",
  "\\subsection{H1: Empathy Effect}",
  "This section evaluates the primary effect of empathy on moral judgments.",
  "\\subsubsection{Model A: Composite Empathy}",
  build_model_section("H1", "A", "H1 Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Empathy Constructs}",
  build_model_section("H1", "B", "H1 Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H2a: Ingroup Betrayal}",
  "This section tests whether harm directed at the perpetrator's own group is judged differently.",
  "\\subsubsection{Model A: Composite Empathy Control}",
  build_model_section("H2a", "A", "H2a Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Construct Controls}",
  build_model_section("H2a", "B", "H2a Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H2b: Outgroup Derogation}",
  "This section examines the difference in judgment when the perpetrator is an outgroup member compared to an ingroup member.",
  "\\subsubsection{Model A: Composite Empathy Control}",
  build_model_section("H2b", "A", "H2b Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Construct Controls}",
  build_model_section("H2b", "B", "H2b Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\subsection{H3: Interaction Moderation}",
  "This section tests the interaction and moderation between absolute empathy dimensions and the outgroup status of the perpetrator.",
  "\\subsubsection{Model A: Composite Empathy Interaction}",
  build_model_section("H3", "A", "H3 Model A: Composite Empathy Regression Coefficients."),
  "\\subsubsection{Model B: Separated Constructs Interaction}",
  build_model_section("H3", "B", "H3 Model B: Separated Constructs Regression Coefficients."),
  "",
  "\\section{Discussion and Limitations}",
  paste(get_limitations_narration(), collapse = " "),
  "",
  "\\section{Conclusion}",
  "Based on the nested interval-censored maximum likelihood estimations, the structural effects of empathy, group dynamics, and betrayal have been documented alongside their theoretical assumptions above.",
  "\\end{document}"
)

tex_path <- file.path(paths$report_dir, "tobit_analysis_report.tex")
write_text_file(latex_lines, tex_path)

# Rendering Markdown is temporarily simplified to focus on standardizing the LaTeX/PDF engine.
md_lines <- c(
  "# Scientific Analysis of Moral Judgments",
  "",
  "## Dataset Description",
  paste(get_dataset_narration(paths$dataset_mode), collapse = " "),
  "",
  "## PDF Comprehensive Report Generated",
  "Please check `tobit_analysis_report.pdf` in the `outputs/report/` folder for the fully documented mathematical formulations, dual model hypothesis testing, and the algorithmically interpreted natural language coefficients.",
  ""
)
write_text_file(md_lines, file.path(paths$report_dir, "tobit_analysis_report.md"))

# 3. RENDERING HELPER (Word and PDF)
render_pdf <- function(tex_file) {
  pdflatex_cmd <- Sys.which("pdflatex")
  if (!nzchar(pdflatex_cmd)) return(FALSE)
  old_wd <- getwd(); setwd(dirname(tex_file)); on.exit(setwd(old_wd))
  system2(pdflatex_cmd, args = c("-interaction=nonstopmode", basename(tex_file)), stdout = NULL)
  system2(pdflatex_cmd, args = c("-interaction=nonstopmode", basename(tex_file)), stdout = NULL)
  TRUE
}
render_word <- function(md_file) {
  pandoc_cmd <- Sys.which("pandoc")
  if (!nzchar(pandoc_cmd)) return(FALSE)
  old_wd <- getwd(); setwd(dirname(md_file)); on.exit(setwd(old_wd))
  docx_name <- gsub("\\.md$", ".docx", basename(md_file))
  system2(pandoc_cmd, args = c("-s", basename(md_file), "-o", docx_name))
  TRUE
}

render_pdf(tex_path)
render_word(file.path(paths$report_dir, "tobit_analysis_report.md"))
message("Scientific manuscript expansion complete.")
