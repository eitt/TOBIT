source("R/00_config.R")
source("R/hypotheses/H_formulas.R")
source("R/utils/mixed_model_functions.R")

paths <- get_project_paths()
judgments_victim <- read.csv(paths$processed_victim, stringsAsFactors = FALSE)
judgments_bystander <- read.csv(paths$processed_bystander, stringsAsFactors = FALSE)

message("Running H4 two-sided Tobit models...")
run_hypothesis_model(
  data = judgments_victim,
  hypothesis_id = "H4",
  role_label = "Victim",
  rhs_formula = get_hypothesis_rhs("H4", "Victim"),
  paths = paths
)
run_hypothesis_model(
  data = judgments_bystander,
  hypothesis_id = "H4",
  role_label = "Bystander",
  rhs_formula = get_hypothesis_rhs("H4", "Bystander"),
  paths = paths
)
