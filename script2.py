import re

with open('R/utils/significance_figure_functions.R', 'r', encoding='utf-8') as f:
    text = f.read()

target = r"""  x_var <- sub\("\^factor\\\\\\\\\(\(\.\*\?\)\\\\\\\\\)\$", "\\\\\\\\1", x_var\)
  moderator <- sub\("\^factor\\\\\\\\\(\(\.\*\?\)\\\\\\\\\)\$", "\\\\\\\\1", moderator\)

  list\(
    term = canonical_term,
    label = label_term\(canonical_term\),
    kind = "interaction",
    x_var = x_var,
    x_type = unname\(part_types\[\[x_var\]\]\),
    moderator = moderator,
    moderator_type = unname\(part_types\[\[moderator\]\]\)"""

replacement = """  clean_x_var <- sub("^factor\\\\\\\\((.*?)\\\\\\\\)$", "\\\\\\\\1", x_var)
  clean_moderator <- sub("^factor\\\\\\\\((.*?)\\\\\\\\)$", "\\\\\\\\1", moderator)

  list(
    term = canonical_term,
    label = label_term(canonical_term),
    kind = "interaction",
    x_var = clean_x_var,
    x_type = unname(part_types[[x_var]]),
    moderator = clean_moderator,
    moderator_type = unname(part_types[[moderator]])"""

text = re.sub(target, replacement, text)

with open('R/utils/significance_figure_functions.R', 'w', encoding='utf-8') as f:
    f.write(text)

print('Done editing R script.')
