source("R/00_config.R")
source("R/hypotheses/H_formulas.R")
source("R/utils/table_functions.R")

paths <- get_project_paths()

participant_summary <- read.csv(file.path(paths$tables_dir, "participant_summary.csv"), stringsAsFactors = FALSE)
judgement_summary <- read.csv(file.path(paths$tables_dir, "judgement_summary.csv"), stringsAsFactors = FALSE)
formula_catalog <- build_hypothesis_formula_catalog()

plain_lines <- c(
  "# Guia sencilla del pipeline TOBIT longitudinal",
  "",
  paste0("Generado el ", get_report_timestamp(), "."),
  "",
  "## Que representa una fila",
  "",
  "Cada fila del archivo base `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` representa un juicio moral realmente registrado en el experimento sobre el negociador objetivo. Como cada participante evalua 10 escenarios y en cada uno juzga a dos negociadores, la estructura esperada es de 20 filas por `id`. El pipeline nuevo no vuelve a expandir esas filas. Solo agrega columnas de contexto para N1, N2, victima, bystander, decisiones y sesion.",
  "",
  "## Como se evita el doble conteo",
  "",
  "Se copia `source_row_number` desde la importacion y se conserva hasta `judgments_analysis.csv`. Eso permite auditar que el numero de filas importadas y el numero de filas analiticas finales coinciden exactamente.",
  "",
  "## Covariables sociodemograficas en todos los modelos",
  "",
  "- `age`",
  "- `ses`",
  "- `sex_female`",
  "- `faculty_player_factor`",
  "",
  "## Variables relacionales por rol",
  "",
  "- Victima: `victim_N1_group`, `victim_N2_group`, `N1_N2_same_faculty`.",
  "- Bystander: `bystander_victim_group`, `bystander_N1_group`, `bystander_N2_group`, `victim_N1_group`, `victim_N2_group`, `N1_N2_same_faculty`.",
  "- Ingroup significa coincidencia de facultad, incluyendo `control` con `control`; outgroup significa facultades distintas.",
  "- Las variables de rol no son intercambiables: victima y bystander usan mapas relacionales distintos porque la cercania social cambia segun el rol.",
  "",
  "## Decisiones",
  "",
  "- `decision_target`: 0 = reject, 1 = accept.",
  "- `decision_other`: 0 = reject, 1 = accept.",
  "- Su interaccion distingue cuatro contextos: ambos aceptan, ambos rechazan, target acepta / other rechaza, target rechaza / other acepta.",
  "",
  "## Modelos H1-H5",
  "",
  build_table_block(formula_catalog[, c("hypothesis", "role", "formula_rhs")]),
  "",
  "En H3 y H5, el pipeline actual ya no restringe la teoria a efectos aditivos puros. Tambien incluye interacciones dirigidas entre empatia y cercania grupal para comprobar si el efecto de la empatia cambia segun la estructura de ingroup/outgroup.",
  "",
  "## Como se modela la dependencia",
  "",
  "Todos los modelos activos usan TOBIT bilateral: `judgement` se trata como una variable censurada a ambos lados sobre la escala `-9` a `9`. La dependencia intra-participante se ajusta con errores estandar robustos clusterizados por `id`, y la sesion entra como `factor(session)`.",
  "",
  "El reporte dinamico explica `factor(session)` en lugar de `(1 | session)` porque esta rama ya no esta reportando un modelo mixto. La especificacion productiva es un TOBIT con efecto fijo de sesion y ajuste robusto por participante. Ademas, la salida de robustez aclara por que no se corre por defecto un TOBIT saturado con `factor(id_case)`.",
  "",
  "## Resumen de muestra",
  "",
  build_table_block(participant_summary),
  "",
  build_table_block(judgement_summary),
  "",
  "## Resultado practico del rediseno",
  "",
  "La logica dominante ya no es un pipeline centrado solo en IRI agregado. El flujo activo usa `judgement` como variable dependiente, separa victima y bystander, incorpora dependencia repetida por participante mediante clustering robusto por `id`, documenta `factor(session)`, usa `decision_target` y `decision_other`, y deja una pista auditable de que no se introdujo nuevo doble conteo.",
  ""
)

writeLines(plain_lines, file.path(paths$report_dir, "tobit_plain_language_guide.md"))
writeLines(plain_lines, file.path(paths$logs_dir, "plain_language_report.md"))
writeLines(plain_lines, file.path(paths$reports_data_dir, "plain_language_guide.md"))
