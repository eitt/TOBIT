# R/03_transform_data.R
# Purpose: Score psychometric scales (IRI) and filter analysis sample.
# Inputs: 02_cleaned.csv
# Outputs: 03_transformed_participants.csv
# Dependencies: 00_config.R, transform_functions.R
# Execution Order: 4

source("R/00_config.R")
source("R/utils/transform_functions.R")
paths <- get_project_paths()

df <- read.csv(file.path(paths$root, "data", "processed", "02_cleaned.csv"), stringsAsFactors = FALSE)

# Predictors remain on their original scale; no z-score normalization is applied.

iri_scales <- list(
  iri_fs = c("FS1", "FS5", "FS7", "FS12", "FS16", "FS20", "FS25"),
  iri_ec = c("EC2", "EC4", "EC9", "EC14", "EC17", "EC19", "EC24", "EC28"),
  iri_pt = c("PT3", "PT8", "PT11", "PT15", "PT21", "PT23", "PT26"),
  iri_pd = c("PD6", "PD10", "PD13", "PD18", "PD22", "PD27")
)
iri_items <- unlist(iri_scales, use.names = FALSE)

# Main composite required 80% completion
df$iri_total <- row_mean_with_floor(df, iri_items, min_non_missing = ceiling(length(iri_items) * 0.8))

# Subscales
for (scale_name in names(iri_scales)) {
  scale_items <- iri_scales[[scale_name]]
  df[[scale_name]] <- row_mean_with_floor(df, scale_items, min_non_missing = max(1L, floor(length(scale_items) * 0.75)))
}

# Define primary sample inclusion limit
df$analysis_include <- df$attention_pass & !is.na(df$iri_total) & df$valid_treatment

write.csv(df, file.path(paths$root, "data", "processed", "03_transformed_participants.csv"), row.names = FALSE, na = "")
