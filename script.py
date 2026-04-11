import re

with open('R/utils/significance_figure_functions.R', 'r', encoding='utf-8') as f:
    text = f.read()

text = re.sub(
    r'classify_predictor_component <- function\(data, var_name\) \{',
    'classify_predictor_component <- function(data, var_name) {\n  var_name <- sub("^factor\\\\\\\\((.*?)\\\\\\\\)$", "\\\\\\\\1", var_name)',
    text
)

text = re.sub(
    r'build_term_visual_spec <- function\(term, data\) \{[\s\S]*?canonical_term <- canonicalize_term_name\(term\)',
    'build_term_visual_spec <- function(term, data) {\n  canonical_term <- canonicalize_term_name(term)\n  clean_canonical_term <- sub("^factor\\\\\\\\((.*?)\\\\\\\\)$", "\\\\\\\\1", canonical_term)',
    text
)

text = re.sub(
    r'x_var = canonical_term,',
    'x_var = clean_canonical_term,',
    text
)

text = re.sub(
    r'x_var <- continuous_parts\[1\]\n    moderator <- setdiff\(parts, x_var\)\[1\]\n  \} else \{\n    x_var <- parts\[1\]\n    moderator <- parts\[2\]\n  \}',
    'x_var <- continuous_parts[1]\n    moderator <- setdiff(parts, x_var)[1]\n  } else {\n    x_var <- parts[1]\n    moderator <- parts[2]\n  }\n\n  x_var <- sub("^factor\\\\\\\\((.*?)\\\\\\\\)$", "\\\\\\\\1", x_var)\n  moderator <- sub("^factor\\\\\\\\((.*?)\\\\\\\\)$", "\\\\\\\\1", moderator)',
    text
)

with open('R/utils/significance_figure_functions.R', 'w', encoding='utf-8') as f:
    f.write(text)

print('Done.')
