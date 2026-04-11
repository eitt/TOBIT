# 00_config.R
# Purpose: Define explicit project paths, ensure directory structures, and bootstrap dependencies.
# Inputs: Optional project root path.
# Outputs: A list containing absolute and stable paths to use across the dataset.
# Dependencies: base R
# Execution Order: 1

get_default_case_modeling_option <- function() {
  "Option 2: judgment-level relational modeling"
}

get_default_pipeline_mode <- function() {
  "Tobit" # Can be "Tobit" or "Both"
}

get_default_active_model_suffixes <- function() {
  "B"
}

# Central participant-level sampling setting for quick test runs.
# Use 1.0 (or 100) when you want to keep the full imported dataset.
get_default_dataset_sample_fraction <- function() {
  1
}

get_default_dataset_sample_seed <- function() {
  69L
}

# Central bootstrap setting for the cluster-aware non-parametric branch.
# Change this single value when you want to use a different default.
get_default_clad_bootstrap_reps <- function() {
  5L
}

parse_dataset_sample_fraction_value <- function(x) {
  if (length(x) == 0L || is.null(x) || is.na(x[1])) {
    return(NA_real_)
  }

  if (is.numeric(x) || is.integer(x)) {
    value <- as.numeric(x[1])
  } else {
    x_chr <- trimws(as.character(x[1]))
    x_chr <- sub("%$", "", x_chr)
    value <- suppressWarnings(as.numeric(x_chr))
  }

  if (is.na(value)) {
    return(NA_real_)
  }

  if (value > 1 && value <= 100) {
    value <- value / 100
  }

  value
}

parse_bootstrap_reps_value <- function(x) {
  if (length(x) == 0L || is.null(x) || is.na(x[1])) {
    return(NA_integer_)
  }

  if (is.numeric(x) || is.integer(x)) {
    return(suppressWarnings(as.integer(x[1])))
  }

  x_chr <- trimws(as.character(x[1]))
  x_chr <- sub("[Ll]$", "", x_chr)
  suppressWarnings(as.integer(x_chr))
}

parse_model_suffixes_value <- function(x, allowed = c("A", "B")) {
  if (length(x) == 0L || is.null(x) || all(is.na(x))) {
    return(character(0))
  }

  suffix_values <- if (length(x) == 1L) {
    unlist(strsplit(as.character(x[1]), "[,;\\s]+"), use.names = FALSE)
  } else {
    as.character(x)
  }

  suffix_values <- unique(toupper(trimws(suffix_values[nzchar(trimws(suffix_values))])))
  suffix_values[suffix_values %in% allowed]
}

resolve_active_model_suffixes <- function() {
  suffixes <- parse_model_suffixes_value(
    getOption("tobit.active_model_suffixes", get_default_active_model_suffixes())
  )
  if (length(suffixes) == 0L) {
    suffixes <- parse_model_suffixes_value(get_default_active_model_suffixes())
  }
  suffixes
}

pipeline_includes_nonparametric <- function() {
  identical(
    toupper(trimws(as.character(getOption("tobit.pipeline_mode", get_default_pipeline_mode())))),
    "BOTH"
  )
}

resolve_clad_bootstrap_reps <- function() {
  bootstrap_reps <- parse_bootstrap_reps_value(
    getOption("tobit.clad_bootstrap_reps", get_default_clad_bootstrap_reps())
  )
  if (is.na(bootstrap_reps) || bootstrap_reps < 1L) {
    bootstrap_reps <- get_default_clad_bootstrap_reps()
  }
  bootstrap_reps
}

resolve_dataset_sample_fraction <- function() {
  sample_fraction <- parse_dataset_sample_fraction_value(
    getOption("tobit.dataset_sample_fraction", get_default_dataset_sample_fraction())
  )
  if (is.na(sample_fraction) || sample_fraction <= 0) {
    sample_fraction <- get_default_dataset_sample_fraction()
  }
  min(sample_fraction, 1)
}

resolve_dataset_sample_seed <- function() {
  seed_value <- parse_bootstrap_reps_value(
    getOption("tobit.dataset_sample_seed", get_default_dataset_sample_seed())
  )
  if (is.na(seed_value)) {
    seed_value <- get_default_dataset_sample_seed()
  }
  as.integer(seed_value)
}

apply_pipeline_runtime_options <- function(
  dataset_mode = NULL,
  pipeline_mode = NULL,
  skip_tobit_refit = FALSE,
  active_model_suffixes = NULL,
  clad_bootstrap_reps = NULL,
  dataset_sample_fraction = NULL,
  dataset_sample_seed = NULL
) {
  if (is.null(pipeline_mode)) {
    pipeline_mode <- getOption("tobit.pipeline_mode", get_default_pipeline_mode())
  }
  
  run_bootstrap <- (tolower(trimws(pipeline_mode)) == "both")

  effective_bootstrap_reps <- parse_bootstrap_reps_value(clad_bootstrap_reps)
  if (is.na(effective_bootstrap_reps)) {
    effective_bootstrap_reps <- parse_bootstrap_reps_value(get_default_clad_bootstrap_reps())
  }
  if (is.na(effective_bootstrap_reps) || effective_bootstrap_reps < 1L) {
    effective_bootstrap_reps <- get_default_clad_bootstrap_reps()
  }
  effective_sample_fraction <- parse_dataset_sample_fraction_value(dataset_sample_fraction)
  if (is.na(effective_sample_fraction) || effective_sample_fraction <= 0) {
    effective_sample_fraction <- get_default_dataset_sample_fraction()
  }
  effective_sample_fraction <- min(effective_sample_fraction, 1)
  effective_sample_seed <- parse_bootstrap_reps_value(dataset_sample_seed)
  if (is.na(effective_sample_seed)) {
    effective_sample_seed <- get_default_dataset_sample_seed()
  }
  effective_model_suffixes <- parse_model_suffixes_value(active_model_suffixes)
  if (length(effective_model_suffixes) == 0L) {
    effective_model_suffixes <- resolve_active_model_suffixes()
  }

  if (!is.null(dataset_mode)) {
    options(tobit.dataset_mode = dataset_mode)
  }
  options(tobit.pipeline_mode = pipeline_mode)
  options(tobit.modeling_option = get_default_case_modeling_option())
  options(tobit.clad_run_bootstrap = isTRUE(run_bootstrap))
  options(tobit.skip_tobit_refit = isTRUE(skip_tobit_refit))
  options(tobit.active_model_suffixes = effective_model_suffixes)
  options(tobit.clad_bootstrap_reps = effective_bootstrap_reps)
  options(tobit.dataset_sample_fraction = effective_sample_fraction)
  options(tobit.dataset_sample_seed = as.integer(effective_sample_seed))
  invisible(TRUE)
}

#' Establish base file paths and ensure directories exist
#'
#' @param project_root Character. The absolute or relative path to the project root.
#' @param dataset_mode Character. One of "FLORIDA", "BUC", or "BOTH".
#' @return A list mapping simple logical names to absolute file paths and settings.
get_project_paths <- function(project_root = ".", dataset_mode = NULL) {
  # Priority: 1. Argument, 2. Global Option, 3. Default "BOTH"
  if (is.null(dataset_mode)) {
    dataset_mode <- getOption("tobit.dataset_mode", default = "FLORIDA")
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
    processed_victim = file.path(root, "data", "processed", "judgments_victim.csv"),
    processed_bystander = file.path(root, "data", "processed", "judgments_bystander.csv"),
    tables_dir = file.path(root, "outputs", "tables"),
    figures_dir = file.path(root, "outputs", "figures"),
    models_dir = file.path(root, "outputs", "models"),
    logs_dir = file.path(root, "outputs", "logs"),
    report_dir = file.path(root, "outputs", "report"),
    dataset_mode = dataset_mode
  )
}

#' Remove generated artifacts from the outputs tree before a fresh full run.
#'
#' @param paths List. Result of get_project_paths().
#' @param clear_reports Logical. Whether report artifacts should also be removed.
#' @return Invisible named integer vector with the number of top-level entries
#'   removed from each output directory.
clear_pipeline_outputs <- function(paths = get_project_paths(), clear_reports = TRUE) {
  output_dirs <- c(
    tables = paths$tables_dir,
    figures = paths$figures_dir,
    models = paths$models_dir,
    logs = paths$logs_dir
  )
  if (isTRUE(clear_reports)) {
    output_dirs <- c(output_dirs, report = paths$report_dir)
  }

  removed_counts <- setNames(integer(length(output_dirs)), names(output_dirs))

  for (dir_name in names(output_dirs)) {
    output_dir <- output_dirs[[dir_name]]
    dir_entries <- list.files(output_dir, all.files = TRUE, no.. = TRUE, full.names = TRUE)
    removed_counts[[dir_name]] <- length(dir_entries)
    if (length(dir_entries) > 0L) {
      unlink(dir_entries, recursive = TRUE, force = TRUE)
    }
  }

  invisible(removed_counts)
}

#' Apply a reproducible random participant-level sample for quicker test runs.
#'
#' @param data Data frame to sample.
#' @param sample_fraction Numeric in (0, 1], or percentage-style values such as 10.
#' @param seed Integer seed for reproducibility.
#' @return Sampled data frame preserving original row order among sampled rows.
sample_pipeline_dataset <- function(data, sample_fraction = NULL, seed = NULL) {
  if (!is.data.frame(data)) {
    stop("sample_pipeline_dataset() expects a data frame.", call. = FALSE)
  }

  if (is.null(sample_fraction)) {
    sample_fraction <- resolve_dataset_sample_fraction()
  } else {
    sample_fraction <- parse_dataset_sample_fraction_value(sample_fraction)
    if (is.na(sample_fraction) || sample_fraction <= 0) {
      sample_fraction <- resolve_dataset_sample_fraction()
    }
    sample_fraction <- min(sample_fraction, 1)
  }

  if (is.null(seed)) {
    seed <- resolve_dataset_sample_seed()
  } else {
    seed <- parse_bootstrap_reps_value(seed)
    if (is.na(seed)) {
      seed <- resolve_dataset_sample_seed()
    }
  }

  n_rows <- nrow(data)
  if (n_rows == 0L || sample_fraction >= 1) {
    return(data)
  }

  sample_size <- max(1L, floor(n_rows * sample_fraction))
  if (sample_size >= n_rows) {
    return(data)
  }

  set.seed(seed)
  sampled_idx <- sort(sample.int(n_rows, size = sample_size, replace = FALSE))
  sampled_data <- data[sampled_idx, , drop = FALSE]
  rownames(sampled_data) <- NULL
  sampled_data
}

#' Install base dependencies if they are missing
ensure_pipeline_dependencies <- function() {
  packages <- c("survival", "readxl", "grDevices", "stats", "utils", "graphics", "ctqr", "pch")
  success <- TRUE

  message("Checking project dependencies...")
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message(">>> Installing missing R package: ", pkg)
      # Non-interactive install.packages
      install_status <- tryCatch(
        {
          install.packages(pkg, repos = "https://cloud.r-project.org", dependencies = TRUE)
          TRUE
        },
        error = function(e) {
          message("!!! Failed to install package: ", pkg)
          FALSE
        }
      )
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
