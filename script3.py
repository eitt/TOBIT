import re

with open('R/utils/significance_figure_functions.R', 'r', encoding='utf-8') as f:
    text = f.read()

# Fix classify_predictor_component
text = re.sub(
    r'var_name <- sub\(\"\\^factor\\\\\\\\\\\\\\\\\(\(\.\*\?\)\\\\\\\\\\\\\\\\\)\\\$\", \"\\\\\\\\\\\\\\\\1\", var_name\)',
    'var_name <- sub("^factor\\\\\\\\(([^)]+)\\\\\\\\).*$", "\\\\\\\\1", var_name)',
    text
)

# Fix build_term_visual_spec main block
text = re.sub(
    r'clean_canonical_term <- sub\(\"\\^factor\\\\\\\\\\\\\\\\\(\(\.\*\?\)\\\\\\\\\\\\\\\\\)\\\$\", \"\\\\\\\\\\\\\\\\1\", canonical_term\)',
    'clean_canonical_term <- sub("^factor\\\\\\\\(([^)]+)\\\\\\\\).*$", "\\\\\\\\1", canonical_term)',
    text
)

# Fix build_term_visual_spec interaction block
text = re.sub(
    r'clean_x_var <- sub\(\"\\^factor\\\\\\\\\\\\\\\\\(\(\.\*\?\)\\\\\\\\\\\\\\\\\)\\\$\", \"\\\\\\\\\\\\\\\\1\", orig_x_var\)\n  clean_moderator <- sub\(\"\\^factor\\\\\\\\\\\\\\\\\(\(\.\*\?\)\\\\\\\\\\\\\\\\\)\\\$\", \"\\\\\\\\\\\\\\\\1\", orig_moderator\)',
    'clean_x_var <- sub("^factor\\\\\\\\(([^)]+)\\\\\\\\).*$", "\\\\\\\\1", orig_x_var)\n  clean_moderator <- sub("^factor\\\\\\\\(([^)]+)\\\\\\\\).*$", "\\\\\\\\1", orig_moderator)',
    text
)


with open('R/utils/significance_figure_functions.R', 'w', encoding='utf-8') as f:
    f.write(text)

print('Applied sub regex fix.')
