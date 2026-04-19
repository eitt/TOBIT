source("R/00_config.R")
source("R/utils/table_functions.R")

paths <- get_project_paths()

judgement_summary <- read.csv(file.path(paths$tables_dir, "judgement_summary.csv"), stringsAsFactors = FALSE)
hypothesis_summary <- read.csv(file.path(paths$tables_dir, "hypothesis_summary.csv"), stringsAsFactors = FALSE)
fit_summary <- read.csv(file.path(paths$tables_dir, "model_fit_summary.csv"), stringsAsFactors = FALSE)
compliance_report <- read.csv(file.path(paths$tables_dir, "pipeline_compliance_report.csv"), stringsAsFactors = FALSE)

behavioral_lines <- c(
  "# Behavioral-Economics Style Dynamic Report",
  "",
  paste0("By Leonardo H. Talero-Sarmiento; Date  ", get_report_timestamp(), "."),
  "",
  "## Materials and Methods",
  "",
  "The active workflow analyzes the Version 2.0 consolidated long dataset as repeated moral judgments. The dependent variable is `judgement`. Each source row remains one analytical observation, and the pipeline reconstructs the N1/N2 context, role-specific ingroup/outgroup relations, and joint decision structure without reshaping the data again.",
  "",
  "Primary estimation now uses a two-sided Tobit fitted with `survival::survreg`. The lower and upper observed limits of `judgement` are treated as bilateral censoring points, participant dependence is handled with `cluster = id` and `robust = TRUE`, and session differences are represented with `factor(session)` rather than a claimed random session intercept. Victim and bystander models are estimated separately.",
  "",
  build_table_block(judgement_summary),
  "",
  "## Results",
  "",
  "The table below lists the terms that reached at least `p < 0.10` in the primary Tobit models. Empty cells mean that the corresponding hypothesis-role combination did not produce a focal term below that threshold.",
  "",
  build_table_block(hypothesis_summary),
  "",
  "## Fit Snapshot",
  "",
  build_table_block(fit_summary[, intersect(c("hypothesis", "role", "model_family", "session_handling", "dependence_adjustment", "lower_censored_n", "upper_censored_n", "AIC", "BIC"), names(fit_summary)), drop = FALSE]),
  "",
  "## Limitations",
  "",
  "The repository does not currently fit a production multilevel Tobit with `(1|session)` inside the same estimator used here. To avoid overstating the implemented model, the pipeline encodes session as `factor(session)` and uses participant-cluster robust standard errors by `id`. Control-hidden faculty labels are retained as a separate level instead of being forced into ingroup or outgroup categories.",
  "",
  "## Conclusion",
  "",
  "The project now centers the experimental design rather than the old aggregated-IRI workflow. `judgement` is the outcome in all inferential models, the participant-level dependence adjustment is explicit, session handling is audited through `factor(session)`, role-specific relational coding differs between victim and bystander, and `decision_target` / `decision_other` are built directly into H4 and H5.",
  "",
  "## Compliance Snapshot",
  "",
  build_table_block(compliance_report),
  ""
)

writeLines(behavioral_lines, file.path(paths$report_dir, "tobit_behavioral_economics_report.md"))
writeLines(behavioral_lines, file.path(paths$logs_dir, "behavioral_economics_report.md"))
writeLines(behavioral_lines, file.path(paths$reports_data_dir, "behavioral_economics_report.md"))
