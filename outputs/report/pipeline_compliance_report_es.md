# Reporte de Cumplimiento del Pipeline

Por Leonardo H. Talero-Sarmiento; Fecha  2026-04-23 21:26:51.

**Table 1. Lista de verificacion de cumplimiento del pipeline**

| criterion | status | evidence |
| --- | --- | --- |
| a) uses judgement | YES | All formulas model judgement directly. |
| b) repeated structure by id | YES | All fitted Tobit models use participant-cluster robust standard errors through cluster = id. |
| c) session grouping | YES | The active Tobit branch uses factor(session) in every formula and documents that choice explicitly instead of claiming a random session intercept. |
| d) no double count introduced by the pipeline | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) victim and bystander treated differently | YES | Role-specific formulas are estimated separately and H2/H3/H5 use different relational blocks for victim and bystander. |
| f) accept_target and accept_other included in H1-H5 | YES | All H1-H5 formulas include accept_target, accept_other, and their interaction as part of the active specification. |
| g) sociodemographics included in every hypothesis model | YES | Every H1-H5 formula retains age, ses, sex_female, and faculty_player_factor. |


