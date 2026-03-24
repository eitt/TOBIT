# R/04_generate_variables.R
# Purpose: Reshape wide data to long (negotiator level), construct fixed effect identifiers, 
# identity alignments, and generate final variables.
# Inputs: 03_transformed_participants.csv
# Outputs: judgments_all.csv, judgments_analysis.csv, judgments_accept_only.csv
# Dependencies: 00_config.R
# Execution Order: 5

source("R/00_config.R")
paths <- get_project_paths()

participants <- read.csv(file.path(paths$root, "data", "processed", "03_transformed_participants.csv"), stringsAsFactors = FALSE)

# Generate wide role variables as requested
for (stage in 1:10) {
  role_col <- sprintf("role_s%d", stage)
  participants[[role_col]] <- ifelse(participants$treatment == 1, ifelse(stage <= 5, 2, 1),
                              ifelse(participants$treatment == 2, ifelse(stage <= 5, 1, 2), NA_integer_))
}

n_rows <- nrow(participants) * 20L
long_rows <- vector("list", n_rows)
index <- 1L

for (row_id in seq_len(nrow(participants))) {
  row <- participants[row_id, , drop = FALSE]
  
  for (stage in 1:10) {
    # Generate Role for stage given treatment
    role_numeric <- ifelse(row$treatment == 1, ifelse(stage <= 5, 2, 1),
                    ifelse(row$treatment == 2, ifelse(stage <= 5, 1, 2), NA_real_))
    role <- ifelse(is.na(role_numeric), NA_character_, ifelse(role_numeric == 2, "victim", "observer"))
    
    for (slot in 1:2) {
      neg_faculty <- as.integer(row[[sprintf("faculty_neg_%d_s%d", slot, stage)]])
      victim_faculty <- as.integer(row[[sprintf("faculty_victim_s%d", stage)]])
      participant_faculty <- as.integer(row$faculty_player)
      judgement <- as.numeric(row[[sprintf("judgement_n%d_s%d", slot, stage)]])
      
      negotiator_alignment <- if (is.na(neg_faculty)) NA_character_ else if (neg_faculty == 3L) "control" else if (neg_faculty == participant_faculty) "ingroup" else "outgroup"
      
      long_rows[[index]] <- data.frame(
        id = as.integer(row$id),
        stage = stage,
        negotiator_slot = slot,
        role = role,
        role_observer = as.integer(role == "observer"),
        age = as.numeric(row$age),
        economic_status = as.numeric(row$economic_status),
        sex = as.integer(row$sex),
        sex_man = as.integer(row$sex == 2),
        participant_faculty = participant_faculty,
        participant_engineering = as.integer(participant_faculty == 2),
        treatment = as.integer(row$treatment),
        analysis_include = as.logical(row$analysis_include),
        iri_total = as.numeric(row$iri_total),
        iri_fs = as.numeric(row$iri_fs),
        iri_ec = as.numeric(row$iri_ec),
        iri_pt = as.numeric(row$iri_pt),
        iri_pd = as.numeric(row$iri_pd),
        faculty_negotiator = neg_faculty,
        faculty_victim = victim_faculty,
        negotiator_alignment = negotiator_alignment,
        perp_outgroup = as.integer(negotiator_alignment == "outgroup"),
        perp_control = as.integer(negotiator_alignment == "control"),
        victim_outgroup = as.integer(victim_faculty != participant_faculty),
        same_group_harm = if (is.na(neg_faculty) || neg_faculty == 3L) NA_integer_ else as.integer(neg_faculty == victim_faculty),
        decision_accept = as.integer(row[[sprintf("decision_neg%d_s%d", slot, stage)]]),
        judgement = judgement,
        condemnation = -judgement,
        stringsAsFactors = FALSE
      )
      index <- index + 1L
    }
  }
}

judgments_all <- do.call(rbind, long_rows)

# Filter for relevant analytical datasets
judgments_analysis <- judgments_all[judgments_all$analysis_include == TRUE, , drop = FALSE]
judgments_accept <- judgments_analysis[!is.na(judgments_analysis$decision_accept) & judgments_analysis$decision_accept == 1L, , drop = FALSE]
judgments_betrayal <- judgments_accept[!is.na(judgments_accept$perp_control) & judgments_accept$perp_control == 0L, , drop = FALSE]

write.csv(participants, paths$processed_participants, row.names = FALSE, na = "")
write.csv(judgments_analysis, paths$processed_judgments, row.names = FALSE, na = "")
write.csv(judgments_accept, paths$processed_accept, row.names = FALSE, na = "")
write.csv(judgments_betrayal, paths$processed_betrayal, row.names = FALSE, na = "")
