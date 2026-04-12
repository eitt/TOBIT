# R/08_generate_plain_language_report.R
# Purpose: Build a companion guide in Spanish that explains the data card,
# hypotheses, variable creation rules, and regression codings in a simpler tone.

source("R/00_config.R")
source("R/utils/io_functions.R")
source("R/utils/case_configuration_functions.R")
source("R/utils/hypothesis_metadata.R")

dataset_mode <- getOption("tobit.dataset_mode", default = "BUC")
paths <- get_project_paths(dataset_mode = dataset_mode)
active_model_suffixes <- resolve_active_model_suffixes()

read_csv_if_exists <- function(path) {
  if (!file.exists(path)) {
    return(NULL)
  }
  read.csv(path, stringsAsFactors = FALSE)
}

format_count <- function(x) {
  if (is.null(x) || is.na(x)) {
    return("no disponible")
  }
  format(as.integer(x), big.mark = ",", scientific = FALSE, trim = TRUE)
}

inline_code <- function(x) {
  paste0("`", x, "`")
}

inline_code_list <- function(x) {
  paste(inline_code(x), collapse = ", ")
}

get_dataset_label <- function(mode) {
  switch(
    toupper(mode),
    BUC = "Bucaramanga",
    FLORIDA = "Florida",
    BOTH = "Florida + Bucaramanga",
    mode
  )
}

render_word <- function(md_file) {
  pandoc_cmd <- Sys.which("pandoc")
  if (!nzchar(pandoc_cmd)) {
    return(FALSE)
  }

  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(dirname(md_file))

  docx_name <- sub("\\.md$", ".docx", basename(md_file))
  status <- system2(
    pandoc_cmd,
    args = c("-s", basename(md_file), "-o", docx_name),
    stdout = NULL,
    stderr = NULL
  )
  identical(status, 0L)
}

participants_df <- read_csv_if_exists(paths$processed_participants)
judgments_df <- read_csv_if_exists(paths$processed_judgments)
victim_df <- read_csv_if_exists(paths$processed_victim)
bystander_df <- read_csv_if_exists(paths$processed_bystander)

participant_n <- if (is.null(participants_df)) NA_integer_ else nrow(participants_df)
judgment_n <- if (is.null(judgments_df)) NA_integer_ else nrow(judgments_df)
victim_n <- if (is.null(victim_df)) NA_integer_ else nrow(victim_df)
bystander_n <- if (is.null(bystander_df)) NA_integer_ else nrow(bystander_df)

hypothesis_specs <- get_hypothesis_specs(paths = paths)

build_plain_hypothesis_section <- function(spec) {
  code_equations <- spec$plain_code_equations
  if (length(active_model_suffixes) > 0L && length(code_equations) > 0L) {
    wanted_labels <- paste0("Modelo ", active_model_suffixes)
    keep_mask <- vapply(
      code_equations,
      function(line) any(vapply(wanted_labels, grepl, logical(1), x = line, fixed = TRUE)),
      logical(1)
    )
    code_equations <- code_equations[keep_mask]
  }
  lines <- c(
    sprintf("### %s", spec$plain_title),
    "",
    sprintf("Pregunta simple: %s", spec$plain_question),
    "",
    sprintf("- Muestra usada: %s", spec$plain_sample),
    "",
    "Ecuacion sencilla:",
    "",
    "```text",
    spec$plain_equation,
    "```",
    "",
    "Version mas pegada al codigo:",
    "",
    "```text",
    code_equations,
    "```"
  )
  if (!is.null(spec$plain_term_note) && nzchar(spec$plain_term_note)) {
    lines <- c(lines, "", spec$plain_term_note)
  }
  c(lines, "")
}

plain_hypothesis_lines <- unlist(
  lapply(hypothesis_specs, build_plain_hypothesis_section),
  use.names = FALSE
)

report_path <- file.path(paths$report_dir, "tobit_plain_language_guide.md")

md_lines <- c(
  "# Guia sencilla para leer el informe TOBIT",
  "",
  sprintf("Base analizada: **%s**", get_dataset_label(paths$dataset_mode)),
  sprintf("Generado el: **%s**", format(Sys.time(), "%Y-%m-%d %H:%M:%S")),
  "",
  "Hola Diego, he creado este documento para orientar de manera un poco mas sencilla la lectura del informe.",
  "",
  "La idea no es reemplazar el informe tecnico. La idea es acompaniarlo y dejar mas claro que entra en el modelo, como se construyen las variables, que significa cada hipotesis y como leer las ecuaciones y las codificaciones de regresion.",
  "",
  "## 1. Lo primero: las variables",
  "",
  "En el modelo hay una variable dependiente y varios predictores.",
  "",
  "- Variable dependiente: `judgement`.",
  "- La podemos leer como la severidad del juicio moral hacia el negociador.",
  "- Su escala va de `-9` a `9`.",
  "- Valores mas bajos significan un juicio mas negativo.",
  "- Valores mas altos significan un juicio mas positivo.",
  "",
  "Los predictores se pueden entender en dos grupos.",
  "",
  "### 1.1 Predictores continuos",
  "",
  "- `iri_total` se conserva en la base como resumen psicometrico, pero no entra al flujo activo de estimacion.",
  "- Subescalas de empatia: `iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`.",
  "- Edad: `age`.",
  "- Nivel socioeconomico: `economic_status`.",
  "",
  "Estas variables cambian en una escala numerica. Por ejemplo, una persona puede tener mas o menos empatia, o mas o menos edad.",
  "",
  "### 1.2 Predictores categoricos o de comparacion",
  "",
  "- Relacion victima-N1: `victim_N1_group` (In/Out, con Control como referencia).",
  "- Relacion victima-N2: `victim_N2_group` (In/Out, con Control como referencia).",
  "- Relacion observador-victima: `bystander_victim_group` (Out con In como referencia).",
  "- Relacion observador-N1: `bystander_N1_group` (In/Out, con Control como referencia).",
  "- Relacion observador-N2: `bystander_N2_group` (In/Out, con Control como referencia).",
  "- Contexto de emparejamiento entre negociadores: `N1_N2_same_faculty`.",
  "- Rol del participante en la escena: `role_observer`.",
  "- Facultad del participante: `participant_engineering`.",
  "- Sexo recodificado: `sex_man`.",
  "",
  "Estas variables no miden una cantidad continua. Lo que hacen es comparar grupos, roles o tipos de escena.",
  "",
  "### 1.3 La separacion en Subconjuntos (Victima y Observador)",
  "",
  "Todos los modelos se corren dos veces: una vez para el subconjunto donde el participante actuo como **Victima**, y otra vez para el subconjunto donde actuo como **Observador (Bystander)**. La estructura explicativa se define con relaciones N1/N2 por rol y con el contexto `N1_N2_same_faculty`.",
  "",
  "### 1.4 Interpretacion de Interacciones",
  "",
  "Cuando veas que un termino con dos puntos (`:`) es marcado como significativo, significa que ambos componentes interactuan. Si una interaccion es significativa, los efectos principales (los que van solos) ya no se interpretan por su cuenta, pues estan subordinados al contexto de la interaccion.",
  "Si es una interaccion entre una subescala continua de empatia y un grupo (ej. `iri_pt:victim_N1_groupOut`), un coeficiente negativo indica que el efecto de la empatia es todavia mas severo en esa condicion relacional frente a la referencia. Si es discreto por discreto (ej. `bystander_N1_groupOut:bystander_N2_groupOut`), un coeficiente positivo significa que la combinacion de esas dos condiciones vuelve el juicio menos severo que la referencia.",
  "",
  "## 2. Data card corto",
  "",
  "- Archivos base principales: `data/raw/data_final_FLORIDA.xlsx` y `data/raw/data_final_BUC.xlsx`.",
  sprintf("- Filas de participantes disponibles ahora: **%s**.", format_count(participant_n)),
  sprintf("- Filas en formato largo de juicios disponibles ahora: **%s**.", format_count(judgment_n)),
  sprintf("- Juicios emitidos desde el rol de Victima: **%s**.", format_count(victim_n)),
  sprintf("- Juicios emitidos desde el rol de Observador: **%s**.", format_count(bystander_n)),
  "- La base original empieza con una fila por participante.",
  "- Luego el pipeline reorganiza la informacion para que cada juicio sobre cada negociador quede como una fila propia.",
  "",
  "```text",
  "1 participante x 10 etapas x 2 negociadores = hasta 20 filas de juicio por participante",
  "```",
  "",
  "## 3. Como se crean las variables principales",
  "",
  "### 3.1 Filtro de atencion e inclusion analitica",
  "",
  "```text",
  "attention_pass = (ac1 es correcto) AND (ac2 es correcto)",
  "analysis_include = attention_pass AND iri_total disponible AND tratamiento valido",
  "```",
  "",
  "En sencillo: para entrar al analisis principal, la persona debe pasar los attention checks, tener suficiente informacion para la empatia total y pertenecer a una secuencia valida del experimento.",
  "",
  "### 3.2 Variables de empatia",
  "",
  "```text",
  "iri_total = promedio de todos los items IRI si al menos el 80% de los items fue respondido (se conserva en la base, pero no entra al flujo activo de estimacion)",
  "iri_fs = promedio de los items de Fantasy",
  "iri_ec = promedio de los items de Empathic Concern",
  "iri_pt = promedio de los items de Perspective Taking",
  "iri_pd = promedio de los items de Personal Distress",
  "```",
  "",
  "Importante: estas variables se conservan en su escala original. El pipeline no las transforma a z-scores.",
  "",
  "### 3.3 Variables del escenario y del contexto",
  "",
  "```text",
  "role_observer = 1 si el participante esta en rol de observador, 0 si esta en rol de victima",
  "participant_engineering = 1 si el participante es de Ingenieria, 0 si es de Humanidades",
  "sex_man = 1 si sexo esta codificado como hombre, 0 si esta codificado como mujer",
  "decision_accept = 1 si el negociador acepto el trato danino, 0 si lo rechazo",
  "judgement = juicio moral numerico del negociador en esa etapa y en ese slot",
  "condemnation = -judgement",
  "```",
  "",
  "### 3.4 Variables relacionales centrales",
  "",
  "```text",
  "victim_N1_group = relacion de N1 con la victima (Cont/In/Out)",
  "victim_N2_group = relacion de N2 con la victima (Cont/In/Out)",
  "bystander_N1_group = relacion de N1 con el observador (Cont/In/Out)",
  "bystander_N2_group = relacion de N2 con el observador (Cont/In/Out)",
  "bystander_victim_group = relacion victima-observador (In/Out)",
  "N1_N2_same_faculty = 1 si N1 y N2 son de la misma facultad, 0 si no",
  "```",
  "",
  "Esto permite modelar directamente la estructura relacional del problema sin colapsarla a una variable generica de caso.",
  "",
  "### 3.5 Subconjuntos analiticos",
  "",
  "```text",
  "judgments_analysis = filas en formato largo con analysis_include = TRUE",
  "judgments_victim = filas de judgments_analysis donde role = victim",
  "judgments_bystander = filas de judgments_analysis donde role = observer",
  "judgments_accept = subconjunto legado que se puede conservar para auditoria, pero no es la base activa de H1 en el flujo actual",
  "```",
  "",
  "## 4. Hipotesis explicadas de manera sencilla",
  "",
  plain_hypothesis_lines,
  "",
  "## 5. Como leer las codificaciones de la regresion",
  "",
  "Esta parte sirve para que los coeficientes se lean con mas tranquilidad.",
  "",
  "- En H1, tanto en Victima como en Observador, el flujo activo usa `iri_fs`, `iri_ec`, `iri_pt` e `iri_pd`; ademas retiene los predictores relacionales por rol (`victim_N1_group`, `victim_N2_group`, y en Observador `bystander_victim_group`, `bystander_N1_group`, `bystander_N2_group`) junto con `N1_N2_same_faculty`, `sex_man`, `age` y `economic_status`.",
  "- En H2, Victima usa `victim_N1_group * victim_N2_group` y Observador usa `bystander_N1_group * bystander_N2_group`, `victim_N1_group * victim_N2_group`, y ademas `bystander_victim_group:bystander_N1_group` y `bystander_victim_group:bystander_N2_group`; todo con `N1_N2_same_faculty` como efecto principal contextual.",
  "- En H3, los contrastes centrales pasan a interacciones entre empatia y estatus relacional de N1/N2 por rol; en Observador tambien se conserva `empatia x bystander_victim_group` y el bloque `bystander_victim_group x bystander_N1/N2`.",
  "- `role_observer = 1` significa observador y `0` significa victima.",
  "- `participant_engineering = 1` significa que el participante es de Ingenieria y `0` que es de Humanidades.",
  "- `sex_man = 1` significa hombre y `0` mujer.",
  "- Todas las estimaciones inferenciales incluyen `(1 | id)` para manejar observaciones repetidas por participante; cuando `id_case` identifica pares repetidos por caso, tambien se agrega `(1 | id_case)`.",
  "- `age` y `economic_status` entran como numeros en su escala original.",
  "- En las tablas y figuras del informe tecnico aparecen abreviaturas compactas para relaciones N1/N2 por rol (`V-N1`, `V-N2`, `B-N1`, `B-N2`, `B-V`) ademas de `FS`, `EC`, `PT`, `PD` y `SES`.",
  "",
  "### Como leer un coeficiente de caso",
  "",
  "Si el coeficiente de una categoria como `victim_N1_groupOut` es negativo, eso quiere decir que esa condicion relacional recibe un juicio mas negativo que la referencia con Control, manteniendo lo demas constante.",
  "",
  "Si una interaccion como `bystander_N1_groupOut:bystander_N2_groupOut` es negativa, eso quiere decir que la combinacion de esas dos condiciones en Observador se vuelve todavia mas severa que lo esperado por sus efectos por separado.",
  "",
  "Si una interaccion como `iri_pt:victim_N1_groupOut` es negativa, eso quiere decir que la pendiente de esa dimension de empatia es mas negativa cuando esa condicion relacional de N1 esta presente frente a la referencia.",
  "",
  "## 6. Por que el proyecto usa dos familias de modelos",
  "",
  "- Modelo lineal mixto: es el modelo principal y agrega `(1 | id)` para capturar la repeticion de respuestas dentro de cada participante, y `(1 | id_case)` cuando ese agrupamiento esta disponible e identificable.",
  "- Modelo de robustez no parametrico: es una segunda revision usando los mismos predictores, pero con menos dependencia de supuestos fuertes sobre la distribucion.",
  "- En ambos casos, la parte teorica del modelo es la misma. Lo que cambia es la forma estadistica de estimarlo.",
  "",
  sprintf("El numero por defecto de bootstrap en este momento es %s y se controla desde `R/00_config.R`.", resolve_clad_bootstrap_reps()),
  "",
  "## 7. Archivos base usados para construir esta guia",
  "",
  "Esta guia se apoya especialmente en estos archivos del proyecto:",
  "",
  "- `docs/datacard.md`",
  "- `docs/hypotheses.md`",
  "- `docs/statistical_model_instructions.md`",
  "- `R/03_transform_data.R`",
  "- `R/04_generate_variables.R`",
  "- `R/hypotheses/H1_test.R`",
  "- `R/hypotheses/H2_test.R`",
  "- `R/hypotheses/H3_test.R`",
  "",
  "## 8. Cierre",
  "",
  "En resumen, esta guia busca dejar claro que se esta modelando, como se construyen las variables y como leer las regresiones sin tener que entrar desde el comienzo en el lenguaje mas tecnico del informe principal.",
  ""
)

write_text_file(md_lines, report_path)
write_text_file(md_lines, file.path(paths$logs_dir, "plain_language_report.md"))

if (render_word(report_path)) {
  message("Guia sencilla escrita en outputs/report como Markdown y Word.")
} else {
  message("Guia sencilla escrita en outputs/report como Markdown.")
}
