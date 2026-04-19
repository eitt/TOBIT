# 00_config.R
# Central configuration for the longitudinal Tobit pipeline.

get_project_paths <- function(project_root = ".") {
  root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)

  output_data_dirs <- c(
    "01_harmonized",
    "02_eda",
    "03_sem",
    "04_qca",
    "05_clustering",
    "06_reports"
  )

  dirs_to_create <- c(
    file.path(root, "data", "processed"),
    file.path(root, "outputs", "data"),
    file.path(root, "outputs", "tables"),
    file.path(root, "outputs", "figures"),
    file.path(root, "outputs", "models"),
    file.path(root, "outputs", "logs"),
    file.path(root, "outputs", "report"),
    file.path(root, "outputs", "data", output_data_dirs)
  )

  for (dir_path in dirs_to_create) {
    if (!dir.exists(dir_path)) {
      dir.create(dir_path, recursive = TRUE, showWarnings = FALSE)
    }
  }

  list(
    root = root,
    base_long_dataset = file.path(
      root,
      "Version 2.0",
      "consolidado_ALL_2026_04_09_LONG.xlsx"
    ),
    processed_import = file.path(root, "data", "processed", "01_imported.csv"),
    processed_clean = file.path(root, "data", "processed", "02_cleaned.csv"),
    processed_transformed = file.path(
      root,
      "data",
      "processed",
      "03_transformed_participants.csv"
    ),
    processed_participants = file.path(
      root,
      "data",
      "processed",
      "participants_scored.csv"
    ),
    processed_judgments = file.path(
      root,
      "data",
      "processed",
      "judgments_analysis.csv"
    ),
    processed_victim = file.path(
      root,
      "data",
      "processed",
      "judgments_victim.csv"
    ),
    processed_bystander = file.path(
      root,
      "data",
      "processed",
      "judgments_bystander.csv"
    ),
    processed_dictionary = file.path(
      root,
      "data",
      "processed",
      "variable_dictionary.csv"
    ),
    output_data_dir = file.path(root, "outputs", "data"),
    harmonized_dir = file.path(root, "outputs", "data", "01_harmonized"),
    eda_dir = file.path(root, "outputs", "data", "02_eda"),
    formulas_dir = file.path(root, "outputs", "data", "03_sem"),
    results_dir = file.path(root, "outputs", "data", "04_qca"),
    diagnostics_dir = file.path(root, "outputs", "data", "05_clustering"),
    reports_data_dir = file.path(root, "outputs", "data", "06_reports"),
    tables_dir = file.path(root, "outputs", "tables"),
    figures_dir = file.path(root, "outputs", "figures"),
    models_dir = file.path(root, "outputs", "models"),
    logs_dir = file.path(root, "outputs", "logs"),
    report_dir = file.path(root, "outputs", "report")
  )
}

ensure_pipeline_dependencies <- function() {
  required_packages <- c("readxl", "survival")
  missing_packages <- required_packages[
    !vapply(
      required_packages,
      requireNamespace,
      logical(1),
      quietly = TRUE
    )
  ]

  if (length(missing_packages) > 0L) {
    stop(
      sprintf(
        paste(
          "Missing required R packages: %s.",
          "Install them locally before running the pipeline."
        ),
        paste(missing_packages, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  invisible(TRUE)
}

clear_pipeline_outputs <- function(paths = get_project_paths()) {
  output_dirs <- c(
    paths$harmonized_dir,
    paths$eda_dir,
    paths$formulas_dir,
    paths$results_dir,
    paths$diagnostics_dir,
    paths$reports_data_dir,
    paths$tables_dir,
    paths$figures_dir,
    paths$models_dir,
    paths$logs_dir,
    paths$report_dir
  )

  removed_entries <- integer(length(output_dirs))
  names(removed_entries) <- basename(output_dirs)

  for (dir_path in output_dirs) {
    entries <- list.files(
      dir_path,
      all.files = TRUE,
      no.. = TRUE,
      full.names = TRUE
    )
    removed_entries[[basename(dir_path)]] <- length(entries)
    if (length(entries) > 0L) {
      unlink(entries, recursive = TRUE, force = TRUE)
    }
  }

  invisible(removed_entries)
}

get_empathy_terms <- function() {
  c("iri_fs", "iri_ec", "iri_pt", "iri_pd")
}

get_sociodemographic_terms <- function() {
  c("age", "ses", "sex_female", "faculty_player_factor")
}

get_report_timestamp <- function() {
  format(Sys.time(), "%Y-%m-%d %H:%M:%S")
}
