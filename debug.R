source("R/00_config.R")
source("R/utils/transform_functions.R")
source("R/utils/table_functions.R")
source("R/utils/model_functions.R")
source("R/utils/significance_figure_functions.R")

data <- read.csv("data/processed/judgments_bystander.csv")
print(classify_predictor_component(data, "factor(group_target)Outgroup"))
print(classify_predictor_component(data, "iri_fs:factor(group_target)Outgroup"))

spec <- build_term_visual_spec("iri_fs:factor(group_target)Outgroup", data)
print(spec)
print(str(build_moderator_grid(data, spec$moderator, spec$moderator_type)))
