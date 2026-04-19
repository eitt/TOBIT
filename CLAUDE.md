# TOBIT Agent Directives

- Keep this file minimal. Add rule only if agent repeatedly fails and codebase cannot express preference.
- Treat `outputs/` (reports, models, figures, logs) as generated artifacts. Do not hand-edit generated files unless user explicitly asks.
- Prefer editing source under `R/` and pipeline entry scripts, then regenerate outputs from pipeline.
- Preserve dirty worktree changes made by user. Never revert unrelated edits.
- When report text needs consistency, update shared helpers in `R/utils/` instead of patching one generated report file.
- After regeneration, summarize which source files changed and which generated artifacts were refreshed.
