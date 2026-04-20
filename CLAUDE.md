# TOBIT Agent Directives

- Treat `outputs/` (reports, models, figures, logs) as generated artifacts. Do not hand-edit generated files unless user explicitly asks.
- Prefer editing source under `R/` and pipeline entry scripts, then regenerate outputs.
- For report wording consistency, update shared helpers in `R/utils/` before patching individual generated report files.
- After regeneration, summarize which source files changed and which generated artifacts were refreshed.
