# 00_config.R
# Purpose: Define explicit project paths, ensure directory structures, and bootstrap dependencies.
# Inputs: Optional project root path.
# Outputs: A list containing absolute and stable paths to use across the dataset.
# Dependencies: base R
# Execution Order: 1

#' Establish base file paths and ensure directories exist
#' 
#' @param project_root Character. The absolute or relative path to the project root.
#' @param dataset_mode Character. One of "FLORIDA", "BUC", or "BOTH".
#' @return A list mapping simple logical names to absolute file paths and settings.
get_project_paths <- function(project_root = ".", dataset_mode = NULL) {
  # Priority: 1. Argument, 2. Global Option, 3. Default "BOTH"
  if (is.null(dataset_mode)) {
    dataset_mode <- getOption("tobit.dataset_mode", default = "BOTH")
  }
  
  root <- normalizePath(project_root, winslash = "/", mustWork = TRUE)
  
  dirs <- c(
    file.path(root, "data", "raw"),
    file.path(root, "data", "processed"),
    file.path(root, "outputs", "tables"),
    file.path(root, "outputs", "figures"),
    file.path(root, "outputs", "models"),
    file.path(root, "outputs", "logs"),
    file.path(root, "outputs", "report")
  )
  
  for (d in dirs) {
    if (!dir.exists(d)) {
      dir.create(d, recursive = TRUE, showWarnings = FALSE)
    }
  }
  
  list(
    root = root,
    raw_florida = file.path(root, "data", "raw", "data_final_FLORIDA.xlsx"),
    raw_buc = file.path(root, "data", "raw", "data_final_BUC.xlsx"),
    processed_participants = file.path(root, "data", "processed", "participants_scored.csv"),
    processed_judgments = file.path(root, "data", "processed", "judgments_analysis.csv"),
    processed_accept = file.path(root, "data", "processed", "judgments_accept_only.csv"),
    processed_betrayal = file.path(root, "data", "processed", "judgments_betrayal_only.csv"),
    tables_dir = file.path(root, "outputs", "tables"),
    figures_dir = file.path(root, "outputs", "figures"),
    models_dir = file.path(root, "outputs", "models"),
    logs_dir = file.path(root, "outputs", "logs"),
    report_dir = file.path(root, "outputs", "report"),
    dataset_mode = dataset_mode
  )
}

#' Install base dependencies if they are missing
ensure_pipeline_dependencies <- function() {
  packages <- c("survival", "readxl", "grDevices", "stats", "utils", "graphics")
  success <- TRUE
  
  message("Checking project dependencies...")
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message(">>> Installing missing R package: ", pkg)
      # Non-interactive install.packages
      install_status <- tryCatch({
        install.packages(pkg, repos = "https://cloud.r-project.org", dependencies = TRUE)
        TRUE
      }, error = function(e) {
        message("!!! Failed to install package: ", pkg)
        FALSE
      })
      if (!install_status) success <- FALSE
    } else {
      message("Found: ", pkg)
    }
  }
  
  if (success) {
    message("All R dependencies verified.")
  } else {
    message("Warning: Some dependencies could not be resolved automatically.")
  }
  
  return(success)
}
