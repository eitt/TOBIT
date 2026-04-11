import re

with open('R/utils/model_functions.R', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace label_term
pattern1 = r"label_term <- function\(term\) \{[\s\S]*?\n\}"
rep1 = """label_term <- function(term) {
  direct_map <- c(
    "(Intercept)" = "Intercept",
    "iri_total" = "Empathy composite (average)",
    "iri_fs" = "Empathy: Fantasy scale",
    "iri_ec" = "Empathy: Empathic concern",
    "iri_pt" = "Empathy: Perspective taking",
    "iri_pd" = "Empathy: Personal distress",
    "Log(scale)" = "Scale variance (log)",
    "factor(group_target)Outgroup" = "Target Negotiator Outgroup (Ref=Ingroup)",
    "factor(group_target)Control" = "Target Negotiator Control (Ref=Ingroup)",
    "factor(group_other)Outgroup" = "Other Negotiator Outgroup (Ref=Ingroup)",
    "factor(group_other)Control" = "Other Negotiator Control (Ref=Ingroup)",
    "factor(obs_group)Outgroup" = "Victim Outgroup (Ref=Ingroup)",
    "factor(obs_group)Control"  = "Victim Control (Ref=Ingroup)",
    "decision_target" = "Target Negotiator Accepted Harm",
    "decision_other" = "Other Negotiator Accepted Harm",
    "age" = "Age",
    "ses" = "Socioeconomic status",
    "sex_female" = "Female (ref=Male)",
    "faculty_player" = "Faculty Player",
    "factor(target)Negotiator 2" = "Target Evaluated: Negotiator 2"
  )

  term_key <- canonicalize_term_name(term)
  if (term_key %in% names(direct_map)) {
    return(unname(direct_map[[term_key]]))
  }
  
  if (grepl(":", term_key, fixed = TRUE)) {
    term_parts <- strsplit(term_key, ":", fixed = TRUE)[[1]]
    return(paste(vapply(term_parts, label_term, character(1)), collapse = " x "))
  }
  
  if (grepl("^factor\\\\(stage\\\\)", term)) {
    return(paste0("Stage ", sub("^factor\\\\(stage\\\\)", "", term), " (ref = stage 1)"))
  }
  if (grepl("^factor\\\\(target\\\\)", term)) {
    return(paste0("Target ", sub("^factor\\\\(target\\\\)", "", term)))
  }
  term
}"""

# Replace label_term_compact
pattern2 = r"label_term_compact <- function\(term\) \{[\s\S]*?\n\}"
rep2 = """label_term_compact <- function(term) {
  direct_map <- c(
    "(Intercept)" = "Intercept",
    "iri_total" = "Emp",
    "iri_fs" = "FS",
    "iri_ec" = "EC",
    "iri_pt" = "PT",
    "iri_pd" = "PD",
    "Log(scale)" = "Log(scale)",
    "factor(group_target)Outgroup" = "T-Out",
    "factor(group_target)Control" = "T-Ctl",
    "factor(group_other)Outgroup" = "O-Out",
    "factor(group_other)Control" = "O-Ctl",
    "factor(obs_group)Outgroup" = "V-Out",
    "factor(obs_group)Control"  = "V-Ctl",
    "decision_target" = "T-Acc",
    "decision_other" = "O-Acc",
    "age" = "Age",
    "ses" = "SES",
    "sex_female" = "Fem",
    "faculty_player" = "Fac",
    "factor(target)Negotiator 2" = "T:2"
  )

  term_key <- canonicalize_term_name(term)
  if (term_key %in% names(direct_map)) {
    return(unname(direct_map[[term_key]]))
  }

  if (grepl(":", term_key, fixed = TRUE)) {
    term_parts <- strsplit(term_key, ":", fixed = TRUE)[[1]]
    return(paste(vapply(term_parts, label_term_compact, character(1)), collapse = " x "))
  }

  if (grepl("^factor\\\\(stage\\\\)", term)) {
    return(paste0("Stage ", sub("^factor\\\\(stage\\\\)", "", term)))
  }
  if (grepl("^factor\\\\(target\\\\)", term)) {
    return(paste0("T:", sub("^factor\\\\(target\\\\)", "", term)))
  }

  term
}"""

text = re.sub(pattern1, rep1, text, count=1)
text = re.sub(pattern2, rep2, text, count=1)

with open('R/utils/model_functions.R', 'w', encoding='utf-8') as f:
    f.write(text)

print("Replacement successful.")
