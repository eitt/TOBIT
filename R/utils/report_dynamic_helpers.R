source("R/utils/table_functions.R")
source("R/utils/figure_functions.R")
source("R/utils/build_role_relational_variables.R")

read_csv_or_empty <- function(file_path) {
  if (!file.exists(file_path)) {
    return(data.frame())
  }
  read.csv(file_path, stringsAsFactors = FALSE)
}

get_current_symbol_dictionary <- function(lang = "en") {
  is_es <- identical(lang, "es")
  data.frame(
    symbol = c(
      "judgement",
      "y*",
      "iri_fs / iri_ec / iri_pt / iri_pd",
      "target (row-dynamic)",
      "other (row-dynamic counterpart)",
      "N1 / N2 (structural slots)",
      "decision_target",
      "decision_other",
      "victim_N1_group / victim_N2_group",
      "bystander_victim_group / bystander_N1_group / bystander_N2_group",
      "group_target / group_other (legacy audit)",
      "N1_N2_same_faculty",
      "factor(session)",
      "cluster = id",
      "Log(scale)"
    ),
    definition = if (is_es) c(
      "Juicio moral observado en la escala acotada de -9 a 9.",
      "Tendencia latente de juicio subyacente a la observación censurada del Tobit.",
      "Dimensiones de empatía IRI: fantasy, empathic concern, perspective taking y personal distress.",
      "Negociador evaluado en esa fila; este rol es dinámico y puede ser N1 o N2 según la observación.",
      "Negociador contraparte en ese mismo contexto de fila (actor no target).",
      "Identidades estructurales de negociadores reconstruidas dentro de cada fila para el modelado relacional; no son alias fijos de target/other.",
      "Indicador de si el negociador target dinámico por fila aceptó el trato dañino; nombre operativo activo del término legacy accept_target.",
      "Indicador de si el negociador other dinámico por fila aceptó el trato dañino; nombre operativo activo del término legacy accept_other.",
      "Relaciones específicas de víctima con negociador 1 y negociador 2, con ingroup definido por coincidencia de facultad incluyendo control-control.",
      "Factores relacionales del lado bystander para la víctima y ambos negociadores, también con coincidencia de facultad como ingroup.",
      "Campos de agrupación legacy de la fuente, retenidos para trazabilidad; no se usan directamente en las fórmulas activas H2/H3/H5.",
      "Término de contexto que indica si N1 y N2 comparten facultad.",
      "Efectos fijos de sesión incluidos directamente en cada fórmula ajustada.",
      "Agrupación a nivel participante usada para errores estándar robustos y ajuste por medidas repetidas.",
      "Parámetro Tobit log-scale estimado que resume la dispersión residual latente."
    ) else c(
      "Observed moral judgement on the bounded scale from -9 to 9.",
      "Latent judgement tendency underlying the censored Tobit observation.",
      "IRI empathy dimensions: fantasy, empathic concern, perspective taking, and personal distress.",
      "Judged negotiator in that row; this role is dynamic and can be N1 or N2 depending on the observation.",
      "Counterpart negotiator in that same row context (the non-target actor).",
      "Structural negotiator identities reconstructed within each row for relational modeling; they are not fixed aliases of target/other.",
      "Indicator for whether the row-dynamic target negotiator accepted the harmful deal; active operational name for legacy wording accept_target.",
      "Indicator for whether the row-dynamic other negotiator accepted the harmful deal; active operational name for legacy wording accept_other.",
      "Victim-specific relations to negotiator 1 and negotiator 2, with ingroup defined by faculty coincidence including control-control matches.",
      "Bystander-side relational factors for the victim and both negotiators, again using faculty coincidence as ingroup.",
      "Legacy source grouping fields retained for provenance checks; not used directly in active H2/H3/H5 formulas.",
      "Context term indicating whether N1 and N2 share faculty membership.",
      "Session fixed effects included directly in every fitted formula.",
      "Participant-level clustering used for robust standard errors and repeated-measures adjustment.",
      "Estimated Tobit log-scale parameter summarizing latent residual dispersion."
    ),
    stringsAsFactors = FALSE
  )
}

get_current_predictor_glossary <- function(lang = "en") {
  is_es <- identical(lang, "es")
  data.frame(
    predictor = c(
      "iri_fs",
      "iri_ec",
      "iri_pt",
      "iri_pd",
      "victim_N1_groupingroup",
      "victim_N1_groupoutgroup",
      "victim_N2_groupingroup",
      "victim_N2_groupoutgroup",
      "bystander_victim_groupoutgroup",
      "bystander_N1_groupingroup",
      "bystander_N1_groupoutgroup",
      "bystander_N2_groupingroup",
      "bystander_N2_groupoutgroup",
      "N1_N2_same_facultysame",
      "iri_fs:victim_N1_groupoutgroup",
      "iri_ec:victim_N2_groupoutgroup",
      "iri_pt:bystander_victim_groupoutgroup",
      "iri_pd:bystander_N1_groupoutgroup",
      "decision_target",
      "decision_other",
      "decision_target:decision_other",
      "faculty_player_factorEngineering",
      "sex_female",
      "age",
      "ses"
    ),
    compact_label = c(
      "FS",
      "EC",
      "PT",
      "PD",
      "V-N1 In",
      "V-N1 Out",
      "V-N2 In",
      "V-N2 Out",
      "B-V Out",
      "B-N1 In",
      "B-N1 Out",
      "B-N2 In",
      "B-N2 Out",
      "SameFac",
      "FS x V-N1 Out",
      "EC x V-N2 Out",
      "PT x B-V Out",
      "PD x B-N1 Out",
      "Target Acc",
      "Other Acc",
      "Target x Other",
      "Eng part.",
      "Woman",
      "Age",
      "SES"
    ),
    meaning = if (is_es) c(
      "Dimensión de empatía fantasy.",
      "Dimensión de empatía empathic concern.",
      "Dimensión de empatía perspective taking.",
      "Dimensión de empatía personal distress.",
      "La víctima y N1 pertenecen a la misma facultad.",
      "La víctima y N1 pertenecen a facultades diferentes.",
      "La víctima y N2 pertenecen a la misma facultad.",
      "La víctima y N2 pertenecen a facultades diferentes.",
      "Bystander y víctima pertenecen a facultades diferentes.",
      "Bystander y N1 pertenecen a la misma facultad.",
      "Bystander y N1 pertenecen a facultades diferentes.",
      "Bystander y N2 pertenecen a la misma facultad.",
      "Bystander y N2 pertenecen a facultades diferentes.",
      "N1 y N2 comparten pertenencia de facultad.",
      "Diferencia de pendiente de fantasy cuando victim-N1 es outgroup frente a ingroup.",
      "Diferencia de pendiente de empathic concern cuando victim-N2 es outgroup frente a ingroup.",
      "Diferencia de pendiente de perspective taking cuando la relación bystander-victim es outgroup frente a ingroup.",
      "Diferencia de pendiente de personal distress cuando la relación bystander-N1 es outgroup frente a ingroup.",
      "El negociador target dinámico por fila aceptó el trato dañino (término legacy: accept_target).",
      "El negociador contraparte dinámico por fila aceptó el trato dañino (término legacy: accept_other).",
      "Efecto conjunto de decisiones cuando se consideran simultáneamente las decisiones de ambos negociadores.",
      "El participante pertenece a Engineering, relativo a Humanities.",
      "El participante es mujer.",
      "Edad del participante.",
      "Nivel socioeconómico del participante."
    ) else c(
      "Fantasy empathy dimension.",
      "Empathic concern empathy dimension.",
      "Perspective-taking empathy dimension.",
      "Personal-distress empathy dimension.",
      "Victim and N1 are from the same faculty.",
      "Victim and N1 are from different faculties.",
      "Victim and N2 are from the same faculty.",
      "Victim and N2 are from different faculties.",
      "Bystander and victim are from different faculties.",
      "Bystander and N1 are from the same faculty.",
      "Bystander and N1 are from different faculties.",
      "Bystander and N2 are from the same faculty.",
      "Bystander and N2 are from different faculties.",
      "N1 and N2 share faculty membership.",
      "Fantasy slope difference when victim-N1 is outgroup rather than ingroup.",
      "Empathic-concern slope difference when victim-N2 is outgroup rather than ingroup.",
      "Perspective-taking slope difference when the bystander-victim relation is outgroup rather than ingroup.",
      "Personal-distress slope difference when the bystander-N1 relation is outgroup rather than ingroup.",
      "Row-dynamic target negotiator accepted the harmful deal (legacy wording: accept_target).",
      "Row-dynamic counterpart negotiator accepted the harmful deal (legacy wording: accept_other).",
      "Joint decision effect when both negotiator decisions are considered together.",
      "Participant belongs to Engineering, relative to Humanities.",
      "Participant is a woman.",
      "Participant age.",
      "Participant socioeconomic status."
    ),
    stringsAsFactors = FALSE
  )
}

label_current_term <- function(term) {
  if (length(term) > 1L) {
    return(vapply(term, label_current_term, character(1), USE.NAMES = FALSE))
  }

  direct_map <- c(
    "(Intercept)" = "Intercept",
    "iri_fs" = "Empathy: Fantasy",
    "iri_ec" = "Empathy: Empathic concern",
    "iri_pt" = "Empathy: Perspective taking",
    "iri_pd" = "Empathy: Personal distress",
    "age" = "Age",
    "ses" = "Socioeconomic status",
    "sex_female" = "Woman participant",
    "decision_target" = "Target accepted",
    "decision_other" = "Other negotiator accepted",
    "decision_target:decision_other" = "Target accepted x Other accepted",
    "faculty_player_factorEngineering" = "Participant faculty: Engineering vs Humanities",
    "victim_N1_groupingroup" = "Victim-N1 ingroup vs ingroup baseline",
    "victim_N1_groupoutgroup" = "Victim-N1 outgroup vs ingroup",
    "victim_N2_groupingroup" = "Victim-N2 ingroup vs ingroup baseline",
    "victim_N2_groupoutgroup" = "Victim-N2 outgroup vs ingroup",
    "bystander_N1_groupingroup" = "Bystander-N1 ingroup vs ingroup baseline",
    "bystander_N1_groupoutgroup" = "Bystander-N1 outgroup vs ingroup",
    "bystander_N2_groupingroup" = "Bystander-N2 ingroup vs ingroup baseline",
    "bystander_N2_groupoutgroup" = "Bystander-N2 outgroup vs ingroup",
    "bystander_victim_groupoutgroup" = "Bystander-victim outgroup vs ingroup",
    "N1_N2_same_facultysame" = "N1/N2 same faculty vs different",
    "Log(scale)" = "Tobit log-scale"
  )

  if (term %in% names(direct_map)) {
    return(unname(direct_map[[term]]))
  }
  if (grepl("^factor\\(session\\)", term)) {
    return(sub("^factor\\(session\\)", "Session ", term))
  }
  if (grepl(":", term, fixed = TRUE)) {
    return(paste(vapply(strsplit(term, ":", fixed = TRUE)[[1]], label_current_term, character(1)), collapse = " x "))
  }
  term
}

get_interaction_interpretation_rules <- function(lang = "en") {
  if (identical(lang, "es")) {
    return(c(
      "Cuando una interacción es estadísticamente relevante, los efectos principales deben leerse como el componente de línea base de la relación y no como toda la historia sustantiva.",
      "Las interacciones continuo-por-factor indican que la pendiente de empatía cambia según las condiciones relacionales.",
      "Las interacciones factor-por-factor indican que el contexto conjunto difiere de lo esperable al sumar de forma independiente los dos contrastes principales.",
      "La interacción target-by-other en decisiones indica que el significado moral de la elección de un negociador depende de lo que hizo su contraparte.",
      "Los efectos de sesión son términos de ajuste y no se interpretan como mecanismos sustantivos del experimento."
    ))
  }
  c(
    "When an interaction is statistically relevant, the main effects should be read as the baseline component of the relationship rather than the whole substantive story.",
    "Continuous-by-factor interactions indicate that the empathy slope changes across relational conditions.",
    "Factor-by-factor interactions indicate that the joint context differs from what would be expected by adding the two main contrasts independently.",
    "The target-by-other decision interaction indicates that the moral meaning of one negotiator's choice depends on what the counterpart did.",
    "Session effects are adjustment terms only and are not interpreted as substantive experimental mechanisms."
  )
}

get_dataset_sample_description <- function(lang = "en") {
  if (identical(lang, "es")) {
    return(c(
      "El reporte usa el dataset experimental consolidado en formato long como única fuente analítica.",
      "Cada participante aporta en principio 20 filas de judgement: diez escenarios multiplicados por dos evaluaciones de negociadores target.",
      "Cada fila importada se mantiene como una observación real de judgement sobre el negociador target, enriquecida con contexto relacional de N1, N2, víctima y bystander, sin duplicación de filas.",
      "Se evita doble conteo porque N1 y N2 se reconstruyen como atributos contextuales dentro de cada fila existente, en lugar de expandir el archivo en observaciones duplicadas por negociador.",
      "Los análisis de víctima y bystander se estiman por separado para que la codificación relacional siga la lógica específica de cada rol."
    ))
  }
  c(
    "The report uses the consolidated long experimental dataset as the single analytical source.",
    "Each participant contributes 20 judgement rows in principle: ten scenarios multiplied by two target-negotiator evaluations.",
    "Each imported row remains one real judgement observation on the target negotiator, enriched with relational context for N1, N2, victim, and bystander without duplicating rows.",
    "Double counting is prevented because N1 and N2 are reconstructed as contextual attributes inside each existing row rather than by expanding the file into duplicated negotiator-specific observations.",
    "Victim and bystander analyses are estimated separately so that relational coding follows the role-specific logic of the experiment."
  )
}

build_target_slot_mapping_audit <- function(data) {
  required_cols <- c("target", "decision_target", "decision_other", "N1_decision", "N2_decision")
  missing_cols <- setdiff(required_cols, names(data))
  if (length(missing_cols) > 0L) {
    return(data.frame(
      rule = "mapping_check_not_available",
      expected_mapping = sprintf("Missing columns: %s", paste(missing_cols, collapse = ", ")),
      rows_in_scope = NA_integer_,
      rows_following_rule = NA_integer_,
      status = "NOT_RUN",
      stringsAsFactors = FALSE
    ))
  }

  target_numeric <- suppressWarnings(as.numeric(as.character(data$target)))
  rule_one_scope <- target_numeric == 1
  rule_two_scope <- target_numeric == 2

  row_one_valid <- rule_one_scope &
    as.character(data$N1_decision) == as.character(data$decision_target) &
    as.character(data$N2_decision) == as.character(data$decision_other)
  row_two_valid <- rule_two_scope &
    as.character(data$N1_decision) == as.character(data$decision_other) &
    as.character(data$N2_decision) == as.character(data$decision_target)

  rule_one_n <- sum(rule_one_scope, na.rm = TRUE)
  rule_two_n <- sum(rule_two_scope, na.rm = TRUE)
  rule_one_ok <- sum(row_one_valid, na.rm = TRUE)
  rule_two_ok <- sum(row_two_valid, na.rm = TRUE)

  data.frame(
    rule = c("target == 1", "target == 2"),
    expected_mapping = c(
      "N1_decision = decision_target; N2_decision = decision_other",
      "N1_decision = decision_other; N2_decision = decision_target"
    ),
    rows_in_scope = c(rule_one_n, rule_two_n),
    rows_following_rule = c(rule_one_ok, rule_two_ok),
    status = c(
      ifelse(rule_one_ok == rule_one_n, "PASS", "CHECK"),
      ifelse(rule_two_ok == rule_two_n, "PASS", "CHECK")
    ),
    stringsAsFactors = FALSE
  )
}

build_introductory_theoretical_chapter <- function(lang = "en") {
  if (identical(lang, "es")) {
    return(c(
      "# Entendiendo la estrategia de modelado",
      "",
      "El propósito del pipeline es explicar cómo los participantes asignan judgement moral a un negociador focal dentro de un entorno experimental estructurado. El objetivo no se limita a describir promedios; busca estimar cómo cambia `judgement` en función de empatía, alineación de grupo, decisiones de negociación y estructura relacional específica por rol. Como cada participante aporta evaluaciones repetidas en múltiples escenarios y targets, la estrategia debe cumplir tres condiciones: preservar una fila por observación real, respetar el carácter acotado del outcome y ajustar la dependencia intra-participante. Por ello, la rama productiva usa un Tobit de dos lados con inferencia robusta por cluster de participante y ajuste por sesión.",
      "",
      "La necesidad del Tobit proviene de la naturaleza de la variable dependiente. `judgement` se interpreta como continua, pero está acotada por diseño de medición. Los valores extremos son límites de la escala, no realizaciones no restringidas. Un modelo lineal estándar asume un outcome potencialmente no acotado, lo cual no es apropiado aquí. El enfoque Tobit modela una evaluación moral latente, denotada como `y_i^*`, observada a través de una puntuación acotada:",
      "",
      "$$",
      "y_i^* = X_i\\beta + \\varepsilon_i",
      "$$",
      "",
      "y",
      "",
      "$$",
      "judgement_i = \\max(-9, \\min(9, y_i^*)).",
      "$$",
      "",
      "Bajo esta especificación, el modelo representa valores interiores, acumulación en el límite inferior y acumulación en el límite superior. En este contexto, censura no significa datos faltantes; significa que la observación queda registrada en el límite de la escala cuando la evaluación latente excede ese rango.",
      "",
      "El segundo reto metodológico es la estructura de medidas repetidas. Cada participante contribuye múltiples filas y, por tanto, las observaciones no son independientes. Ignorar esto tendería a subestimar errores estándar y sobrerreportar significancia. La rama actual lo aborda con errores estándar robustos agrupados por `id`. Además, se incorpora sesión con `factor(session)` para absorber desplazamientos sistemáticos entre sesiones. En esta implementación, sesión se modela como ajuste de efectos fijos y no como intercepto aleatorio.",
      "",
      "Los predictores se organizan en bloques teóricos. El primero contiene dimensiones de empatía (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`) y fundamenta H1. El segundo captura estructura relacional de ingroup/outgroup por rol y fundamenta H2. El tercero incorpora decisiones de negociación con `decision_target`, `decision_other` y su interacción, núcleo de H4. Todos los modelos incluyen controles sociodemográficos.",
      "",
      "Las interacciones son clave porque los efectos aditivos no siempre capturan la lógica experimental. En H3, interacciones empatía-por-grupo evalúan si el efecto de empatía depende de la alineación social. En H4 y H5, `decision_target:decision_other` evalúa si el significado moral de una decisión depende de la decisión de la contraparte.",
      "",
      "La distinción entre víctima y bystander es central. Los modelos de víctima se enfocan en alineación víctima-negociador. Los de bystander requieren un mapa más amplio que incluye relaciones bystander-víctima, bystander-negociador y víctima-negociador. Por eso las especificaciones por rol no son intercambiables.",
      "",
      "Las cinco familias de hipótesis siguen esa estructura: H1 (empatía), H2 (alineación de grupo), H3 (empatía + grupo + interacciones), H4 (decisiones y su interacción), H5 (modelo integrado).",
      "",
      "Un principio clave del flujo es que una fila sigue siendo una observación real de target-judgement. No se duplican filas para crear pseudo-observaciones por negociador. En su lugar, el contexto de N1, N2, víctima y bystander se reconstruye dentro de cada fila existente.",
      "",
      "En conjunto, la estrategia productiva respeta la naturaleza acotada del outcome, preserva el diseño observacional long, ajusta la dependencia por participante, controla heterogeneidad por sesión, separa mecanismos de víctima y bystander, y mapea directamente sobre la arquitectura teórica H1-H5. A la vez, no equivale a un Tobit multinivel completo con interceptos aleatorios de participante y sesión."
    ))
  }
  c(
    "# Understanding the modeling strategy",
    "",
    "The purpose of the pipeline is to explain how participants assign moral judgement to a focal negotiator within a structured experimental setting. The objective is not limited to describing average responses. Rather, the pipeline is designed to estimate how judgement changes as a function of empathy, group alignment, negotiation decisions, and role-specific relational structure. The outcome of interest is `judgement`, interpreted as the participant's moral evaluation of the target negotiator. Because each participant contributes repeated evaluations across scenarios and targets, the modeling strategy must satisfy three conditions simultaneously: it must preserve one row per real observation, respect the bounded structure of the outcome, and account for within-participant dependence. For these reasons, the production workflow uses a two-sided Tobit model with participant-cluster robust inference and session adjustment.",
    "",
    "The need for a Tobit specification follows directly from the nature of the dependent variable. `judgement` is continuous in interpretation but bounded in measurement. Values at the extremes are therefore not ordinary unrestricted observations; they are limits imposed by the response scale. A standard linear model assumes an outcome that can vary freely over the real line, which is inappropriate when responses accumulate at lower and upper boundaries. The Tobit framework addresses this by assuming an underlying latent moral evaluation, denoted here by `y_i^*`, that is only observed through a bounded realized score:",
    "",
    "$$",
    "y_i^* = X_i\\beta + \\varepsilon_i",
    "$$",
    "",
    "and",
    "",
    "$$",
    "judgement_i = \\max(-9, \\min(9, y_i^*)).",
    "$$",
    "",
    "Under this specification, the model jointly represents three kinds of outcomes: interior continuous values, lower-bound pile-up, and upper-bound pile-up. In this context, censoring does not mean that data are missing. It means that the observed score is recorded at the measurement boundary whenever the latent evaluation would extend beyond the scale. The Tobit model is therefore not a technical convenience but a direct response to the design of the judgement variable itself.",
    "",
    "A second methodological challenge arises from the repeated-measures structure of the experiment. Each participant contributes multiple rows, so the observations are not independent. Ignoring this dependence would tend to underestimate standard errors and overstate statistical significance. The current pipeline addresses this issue through participant-cluster robust standard errors using `id` as the clustering variable. Session is also incorporated because different experimental sessions may vary in context, timing, or implementation details. This is handled through `factor(session)`, which absorbs systematic session-level shifts. In the active production branch, session is therefore modeled as a fixed-effect adjustment rather than as a random session intercept. The implemented estimator is best described as a two-sided Tobit with participant-cluster robust inference and session fixed effects.",
    "",
    "The predictors are organized into theoretically meaningful blocks. The first block contains empathy dimensions, represented by `iri_fs`, `iri_ec`, `iri_pt`, and `iri_pd`, and provides the basis for H1. The second block captures role-specific ingroup/outgroup structure and underlies H2. The third block incorporates negotiation decisions through `decision_target`, `decision_other`, and their interaction, forming the core of H4. Finally, all models include sociodemographic controls such as age, SES, sex, and player faculty. This structure allows the pipeline to evaluate distinct explanatory mechanisms while preserving a coherent hypothesis architecture.",
    "",
    "Interactions are especially important in this design because additive effects alone are unlikely to capture the logic of the experiment. In H3, empathy-by-group interactions test whether the effect of empathy depends on social alignment. In H4 and H5, the interaction between `decision_target` and `decision_other` evaluates whether the moral meaning of one negotiator's decision depends on the counterpart's decision. These interaction terms are theoretically motivated and reflect the fact that moral evaluation is shaped not only by isolated attributes but also by combinations of dispositions, relationships, and actions.",
    "",
    "The distinction between victim and bystander roles is central to the entire modeling strategy. Victim models focus on victim-negotiator alignment and therefore operate with a more direct relational structure. Bystander models, by contrast, require a broader map that includes bystander-victim, bystander-negotiator, and victim-negotiator relations. Because these mechanisms differ substantively, the victim and bystander specifications cannot be treated as interchangeable. Role-specific models are therefore necessary both statistically and theoretically.",
    "",
    "The five hypothesis families follow naturally from this structure. H1 models `judgement` as a function of empathy and controls. H2 focuses on role-specific group alignment. H3 combines empathy and group structure with theoretically motivated interactions. H4 models judgement as a function of `decision_target`, `decision_other`, and their interaction. H5 integrates all previous components into a single specification. This progression allows the analysis to move from simpler explanations toward a more comprehensive account of moral judgement.",
    "",
    "A key principle of the workflow is that one row remains one real target-judgement observation. The pipeline does not duplicate rows into separate pseudo-observations for negotiators, because doing so would artificially inflate the sample size and distort inference. Instead, the relational context involving N1, N2, victim, and bystander is reconstructed within each existing row. This preserves the integrity of the long-format design while maintaining the proper unit of analysis.",
    "",
    "Taken together, the current production strategy has several strengths. It respects the bounded structure of the outcome, preserves the long-format observational design, adjusts inference for repeated observations, controls for session-level heterogeneity, separates victim and bystander mechanisms, and maps directly onto the theoretical architecture of H1 through H5. At the same time, its limitations must also be recognized. The estimator is not a full mixed-effects Tobit with random participant and session intercepts. In addition, sparse role-specific cells may still produce rank-deficient contrasts in interaction-heavy models. For that reason, interpretation should rely on the full combination of coefficient tables and model-implied figures rather than on isolated p-values.",
    "",
    "Overall, the current production pipeline is statistically and conceptually aligned with the experiment. It treats bounded continuous moral judgement with a two-sided Tobit model, handles repeated observations through participant-cluster robust inference, adjusts session heterogeneity through fixed effects, and preserves role-specific relational theory within model specification. This makes the present workflow a defensible production framework, while also leaving a clear path for future multilevel Tobit extensions."
  )
}

get_current_tobit_math_foundations <- function(lang = "en") {
  if (identical(lang, "es")) {
    return(c(
      "El estimador principal es un Tobit de dos lados ajustado con `survival::survreg`.",
      "",
      "$$y_i = \\max(-9, \\min(9, y_i^*))$$",
      "",
      "$$y_i^* = \\beta_0 + X_i\\beta + \\delta_{session(i)} + \\varepsilon_i$$",
      "",
      "donde `factor(session)` aporta efectos fijos de sesión y los errores estándar robustos por cluster se calculan al nivel de participante mediante `cluster = id` con `robust = TRUE`.",
      "Por tanto, este reporte trata sesión como ajuste implementado de efecto fijo y no como intercepto aleatorio."
    ))
  }
  c(
    "The primary estimator is a two-sided Tobit fitted with `survival::survreg`.",
    "",
    "$$y_i = \\max(-9, \\min(9, y_i^*))$$",
    "",
    "$$y_i^* = \\beta_0 + X_i\\beta + \\delta_{session(i)} + \\varepsilon_i$$",
    "",
    "where `factor(session)` supplies session fixed effects and cluster-robust standard errors are computed at the participant level through `cluster = id` with `robust = TRUE`.",
    "This report therefore treats session as an implemented fixed-effect adjustment, not as a random intercept."
  )
}

get_current_limitations <- function(lang = "en") {
  if (identical(lang, "es")) {
    return(c(
      "La rama productiva no ajusta un Tobit multinivel completo con interceptos aleatorios explícitos de participante y sesión dentro del mismo estimador.",
      "Celdas relacionales escasas pueden producir matrices de diseño con deficiencia de rango, por lo que algunos contrastes de interacción se descartan automáticamente y se reportan como tales.",
      "Las figuras dinámicas visualizan predicciones implicadas por el modelo a partir de los ajustes Tobit primarios guardados y deben interpretarse junto con las tablas de coeficientes, no como efectos causales autónomos."
    ))
  }
  c(
    "The production branch does not fit a full multilevel Tobit with explicit random participant and session intercepts inside the same estimator.",
    "Sparse relational cells can produce rank-deficient design matrices, so some interaction contrasts are dropped automatically and reported as such.",
    "The dynamic figures visualize model-implied predictions from the saved primary Tobit fits and should be interpreted jointly with the coefficient tables rather than as standalone causal effects."
  )
}

compute_descriptive_clustering_diagnostic <- function(data) {
  participant_means <- stats::aggregate(judgement ~ id, data = data, FUN = mean, na.rm = TRUE)
  merged <- merge(data, participant_means, by = "id", suffixes = c("", "_participant_mean"))
  between_var <- stats::var(participant_means$judgement, na.rm = TRUE)
  within_var <- stats::var(merged$judgement - merged$judgement_participant_mean, na.rm = TRUE)
  icc <- if ((between_var + within_var) > 0) between_var / (between_var + within_var) else NA_real_
  avg_cluster_size <- mean(table(data$id))
  design_effect <- 1 + ((avg_cluster_size - 1) * icc)
  ess <- if (is.finite(design_effect) && design_effect > 0) nrow(data) / design_effect else NA_real_

  data.frame(
    metric = c("participants", "observations", "average_observations_per_id", "icc_descriptive", "design_effect", "effective_sample_size"),
    value = c(length(unique(data$id)), nrow(data), avg_cluster_size, icc, design_effect, ess),
    stringsAsFactors = FALSE
  )
}

build_participant_correlation_table <- function(participants, judgments_analysis) {
  participant_mean_judgement <- aggregate(
    judgement ~ id,
    data = judgments_analysis,
    FUN = function(x) mean(x, na.rm = TRUE)
  )
  participant_level <- merge(
    participants,
    participant_mean_judgement,
    by = "id",
    all.x = TRUE
  )
  corr_matrix <- stats::cor(
    participant_level[, c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "judgement"), drop = FALSE],
    use = "pairwise.complete.obs"
  )
  data.frame(
    term = rownames(corr_matrix),
    corr_matrix,
    row.names = NULL,
    check.names = FALSE,
    stringsAsFactors = FALSE
  )
}

is_session_term <- function(term) {
  grepl("^factor\\(session\\)", term)
}

is_control_only_term <- function(term) {
  term %in% c("(Intercept)", "age", "ses", "sex_female", "Log(scale)") ||
    grepl("^faculty_player_factor", term) ||
    is_session_term(term)
}

is_focal_term_for_hypothesis <- function(hypothesis_id, term_name) {
  if (term_name == "(Intercept)" || is_session_term(term_name) || grepl("^faculty_player_factor", term_name)) {
    return(FALSE)
  }

  switch(
    hypothesis_id,
    H1 = grepl("^iri_", term_name),
    H2 = grepl("victim_N|bystander_|N1_N2_same_faculty", term_name),
    H3 = grepl("^iri_|victim_N|bystander_|N1_N2_same_faculty", term_name),
    H4 = grepl("^decision_target$|^decision_other$|decision_target:decision_other", term_name),
    H5 = grepl("^iri_|victim_N|bystander_|N1_N2_same_faculty|decision_target|decision_other", term_name),
    FALSE
  )
}

build_role_significance_summary <- function(coef_summary) {
  if (nrow(coef_summary) == 0L) {
    return(data.frame())
  }

  sig_df <- coef_summary[
    !vapply(seq_len(nrow(coef_summary)), function(i) is_session_term(coef_summary$term[[i]]), logical(1)) &
      vapply(seq_len(nrow(coef_summary)), function(i) is_focal_term_for_hypothesis(coef_summary$hypothesis[[i]], coef_summary$term[[i]]), logical(1)),
    ,
    drop = FALSE
  ]

  all_cells <- expand.grid(
    hypothesis = paste0("H", 1:5),
    role = c("Victim", "Bystander"),
    stringsAsFactors = FALSE
  )

  if (nrow(sig_df) == 0L) {
    all_cells$support <- "None below p < 0.10"
    return(all_cells)
  }

  sig_df$support_label <- ifelse(
    is.na(sig_df$p_symbol) | sig_df$p_symbol == "",
    label_current_term(sig_df$term),
    paste0(label_current_term(sig_df$term), sig_df$p_symbol)
  )

  sig_df <- sig_df[sig_df$p_value < 0.10, , drop = FALSE]
  if (nrow(sig_df) == 0L) {
    all_cells$support <- "None below p < 0.10"
    return(all_cells)
  }

  summary_df <- aggregate(
    support_label ~ hypothesis + role,
    data = sig_df,
    FUN = function(x) paste(unique(x), collapse = "; ")
  )
  names(summary_df)[3] <- "support"

  merged <- merge(all_cells, summary_df, by = c("hypothesis", "role"), all.x = TRUE)
  merged$support[is.na(merged$support)] <- "None below p < 0.10"
  merged
}

prepare_report_coefficient_table <- function(coef_df) {
  if (nrow(coef_df) == 0L) {
    return(coef_df)
  }
  filtered <- coef_df[!vapply(coef_df$term, is_session_term, logical(1)), , drop = FALSE]
  filtered$term_label <- vapply(filtered$term, label_current_term, character(1))
  filtered[, c("term_label", "estimate", "std_error", "conf_low", "conf_high", "p_value_display"), drop = FALSE]
}

generate_model_narrative <- function(coef_df, hypothesis_id, role_label, lang = "en") {
  is_es <- identical(lang, "es")
  if (nrow(coef_df) == 0L) {
    return(if (is_es) "No hubo coeficientes disponibles para interpretación." else "No coefficients were available for interpretation.")
  }

  focal_df <- coef_df[
    vapply(seq_len(nrow(coef_df)), function(i) is_focal_term_for_hypothesis(hypothesis_id, coef_df$term[[i]]), logical(1)) &
      !vapply(coef_df$term, is_session_term, logical(1)),
    ,
    drop = FALSE
  ]
  focal_sig <- focal_df[!is.na(focal_df$p_value) & focal_df$p_value < 0.10, , drop = FALSE]

  if (nrow(focal_sig) == 0L) {
    return(sprintf(
      if (is_es) {
        "En el modelo %s %s, ningún término focal de hipótesis alcanzó p < 0.10. Por ello, el reporte conserva la tabla de coeficientes para auditabilidad, pero no añade una interpretación sustantiva guiada por significancia más allá de los gráficos descriptivos de predicción."
      } else {
        "In the %s %s model, no focal hypothesis term reached p < 0.10. The report therefore retains the coefficient table for auditability but does not attach a significance-driven substantive interpretation beyond the descriptive prediction plots."
      },
      hypothesis_id,
      role_label
    ))
  }

  focal_sig <- focal_sig[order(focal_sig$p_value, -abs(focal_sig$estimate)), , drop = FALSE]
  top_rows <- utils::head(focal_sig, 3)
  effect_sentences <- vapply(
    seq_len(nrow(top_rows)),
    function(i) {
      direction <- ifelse(top_rows$estimate[[i]] >= 0, if (is_es) "mayor" else "higher", if (is_es) "menor" else "lower")
      sprintf(
        if (is_es) {
          "%s se asocia con %s judgement predicho (estimate = %.2f, p = %s)."
        } else {
          "%s is associated with %s predicted judgement (estimate = %.2f, p = %s)."
        },
        label_current_term(top_rows$term[[i]]),
        direction,
        top_rows$estimate[[i]],
        top_rows$p_value_display[[i]]
      )
    },
    character(1)
  )

  paste(
    sprintf(
      if (is_es) {
        "El modelo %s %s muestra evidencia focal para %s términos de hipótesis."
      } else {
        "The %s %s model shows focal evidence for %s hypothesis terms."
      },
      hypothesis_id,
      role_label,
      ifelse(nrow(focal_sig) == 1L, if (is_es) "un" else "one", as.character(nrow(focal_sig)))
    ),
    paste(effect_sentences, collapse = " "),
    if (is_es) {
      "Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva."
    } else {
      "Session dummies remain in the fitted estimator for adjustment but are intentionally omitted from the substantive narrative."
    }
  )
}

get_term_component_spec <- function(term_piece) {
  factor_specs <- list(
    victim_N1_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    victim_N2_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    bystander_N1_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    bystander_N2_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    bystander_victim_group = list(ref = "ingroup", levels = c("ingroup", "outgroup")),
    N1_N2_same_faculty = list(ref = "different", levels = c("different", "same")),
    faculty_player_factor = list(ref = "Humanities", levels = c("Humanities", "Engineering"))
  )

  if (term_piece %in% c("iri_fs", "iri_ec", "iri_pt", "iri_pd", "age", "ses")) {
    return(list(type = "continuous", var = term_piece, focus = NULL, reference = NULL))
  }
  if (term_piece %in% c("decision_target", "decision_other", "sex_female")) {
    return(list(type = "binary", var = term_piece, focus = 1, reference = 0))
  }

  for (base_name in names(factor_specs)) {
    if (startsWith(term_piece, base_name)) {
      suffix <- sub(base_name, "", term_piece, fixed = TRUE)
      if (!nzchar(suffix)) next
      return(list(
        type = "factor_contrast",
        var = base_name,
        focus = suffix,
        reference = factor_specs[[base_name]]$ref
      ))
    }
  }

  NULL
}

build_reference_profile <- function(data) {
  reference <- data[1, , drop = FALSE]
  for (col_name in names(reference)) {
    values <- data[[col_name]]
    if (is.factor(values)) {
      modal_name <- names(sort(table(values), decreasing = TRUE))
      reference[[col_name]] <- factor(
        if (length(modal_name) == 0L) levels(values)[1] else modal_name[1],
        levels = levels(values)
      )
    } else if (is.numeric(values)) {
      reference[[col_name]] <- mean(values, na.rm = TRUE)
    } else {
      values_chr <- values[!is.na(values)]
      reference[[col_name]] <- if (length(values_chr) == 0L) NA else names(sort(table(values_chr), decreasing = TRUE))[1]
    }
  }
  reference
}

compute_censored_gaussian_expectation <- function(mu, sigma, lower = -9, upper = 9) {
  if (!is.finite(sigma) || sigma <= 0) {
    return(clamp_judgment_scale(mu, lower = lower, upper = upper))
  }
  z_lower <- (lower - mu) / sigma
  z_upper <- (upper - mu) / sigma
  lower_mass <- stats::pnorm(z_lower)
  middle_mass <- stats::pnorm(z_upper) - stats::pnorm(z_lower)
  upper_mass <- 1 - stats::pnorm(z_upper)

  lower * lower_mass +
    mu * middle_mass +
    sigma * (stats::dnorm(z_lower) - stats::dnorm(z_upper)) +
    upper * upper_mass
}

build_aligned_design_matrix <- function(model_fit, newdata) {
  model_terms <- stats::delete.response(stats::terms(model_fit))
  design_matrix <- stats::model.matrix(model_terms, newdata, xlev = model_fit$xlevels)
  coefficient_names <- names(stats::coef(model_fit))
  missing_terms <- setdiff(coefficient_names, colnames(design_matrix))
  if (length(missing_terms) > 0L) {
    zero_block <- matrix(0, nrow = nrow(design_matrix), ncol = length(missing_terms))
    colnames(zero_block) <- missing_terms
    design_matrix <- cbind(design_matrix, zero_block)
  }
  design_matrix[, coefficient_names, drop = FALSE]
}

compute_prediction_summary <- function(model_fit, newdata) {
  coefficient_names <- names(stats::coef(model_fit))
  design_matrix <- build_aligned_design_matrix(model_fit, newdata)
  coefficients <- stats::coef(model_fit)
  valid_coef <- is.finite(coefficients)
  coefficients <- coefficients[valid_coef]
  design_matrix <- design_matrix[, names(coefficients), drop = FALSE]
  linear_predictor <- as.numeric(design_matrix %*% coefficients)
  sigma <- as.numeric(model_fit$scale[1])

  vcov_matrix <- as.matrix(model_fit$var)
  if (is.null(dimnames(vcov_matrix))) {
    full_names <- c(coefficient_names, "Log(scale)")
    if (length(full_names) == nrow(vcov_matrix)) {
      dimnames(vcov_matrix) <- list(full_names, full_names)
    }
  }
  vcov_matrix <- vcov_matrix[names(coefficients), names(coefficients), drop = FALSE]
  se_lp <- sqrt(pmax(rowSums((design_matrix %*% vcov_matrix) * design_matrix), 0))
  z <- stats::qnorm(0.975)

  data.frame(
    predicted = compute_censored_gaussian_expectation(linear_predictor, sigma = sigma),
    conf_low = compute_censored_gaussian_expectation(linear_predictor - z * se_lp, sigma = sigma),
    conf_high = compute_censored_gaussian_expectation(linear_predictor + z * se_lp, sigma = sigma),
    stringsAsFactors = FALSE
  )
}

build_plot_data_for_term <- function(model_fit, data, term_name) {
  data <- coerce_model_factors(as.data.frame(data))

  if (!grepl(":", term_name, fixed = TRUE)) {
    component <- get_term_component_spec(term_name)
    if (is.null(component)) {
      return(NULL)
    }

    reference <- build_reference_profile(data)
    if (component$type == "continuous") {
      x_values <- seq(min(data[[component$var]], na.rm = TRUE), max(data[[component$var]], na.rm = TRUE), length.out = 60L)
      newdata <- reference[rep(1, length(x_values)), , drop = FALSE]
      newdata[[component$var]] <- x_values
      pred_df <- compute_prediction_summary(model_fit, newdata)
      return(data.frame(
        x_value = x_values,
        x_label = format(round(x_values, 2), trim = TRUE),
        moderator_label = NA_character_,
        pred_df,
        stringsAsFactors = FALSE
      ))
    }

    x_values <- c(component$reference, component$focus)
    if (component$type == "binary") {
      x_labels <- c("0", "1")
    } else {
      x_labels <- x_values
    }
    newdata <- reference[rep(1, length(x_values)), , drop = FALSE]
    newdata[[component$var]] <- x_values
    pred_df <- compute_prediction_summary(model_fit, newdata)
    data.frame(
      x_value = seq_along(x_values),
      x_label = x_labels,
      moderator_label = NA_character_,
      pred_df,
      stringsAsFactors = FALSE
    )
  } else {
    parts <- strsplit(term_name, ":", fixed = TRUE)[[1]]
    comp_a <- get_term_component_spec(parts[1])
    comp_b <- get_term_component_spec(parts[2])
    if (is.null(comp_a) || is.null(comp_b)) {
      return(NULL)
    }
    reference <- build_reference_profile(data)

    # Prefer a continuous focal predictor on x when present.
    if (identical(comp_a$type, "continuous") && !identical(comp_b$type, "continuous")) {
      x_component <- comp_a
      moderator_component <- comp_b
    } else if (!identical(comp_a$type, "continuous") && identical(comp_b$type, "continuous")) {
      x_component <- comp_b
      moderator_component <- comp_a
    } else {
      x_component <- comp_a
      moderator_component <- comp_b
    }

    x_values <- if (x_component$type == "continuous") {
      seq(min(data[[x_component$var]], na.rm = TRUE), max(data[[x_component$var]], na.rm = TRUE), length.out = 60L)
    } else {
      c(x_component$reference, x_component$focus)
    }
    moderator_values <- if (moderator_component$type == "continuous") {
      as.numeric(stats::quantile(data[[moderator_component$var]], probs = c(0.25, 0.75), na.rm = TRUE))
    } else {
      c(moderator_component$reference, moderator_component$focus)
    }
    moderator_labels <- as.character(moderator_values)
    if (moderator_component$type == "binary") {
      if (moderator_component$var %in% c("decision_target", "decision_other")) {
        moderator_labels <- ifelse(as.character(moderator_values) == "1", "accept", "reject")
      } else if (moderator_component$var == "sex_female") {
        moderator_labels <- ifelse(as.character(moderator_values) == "1", "woman", "man")
      }
    }

    blocks <- lapply(seq_along(moderator_values), function(idx) {
      block <- reference[rep(1, length(x_values)), , drop = FALSE]
      block[[x_component$var]] <- x_values
      block[[moderator_component$var]] <- moderator_values[[idx]]
      pred_df <- compute_prediction_summary(model_fit, block)
      data.frame(
        x_value = if (x_component$type == "continuous") x_values else seq_along(x_values),
        x_label = as.character(x_values),
        moderator_label = moderator_labels[[idx]],
        x_axis_label = label_current_term(x_component$var),
        pred_df,
        stringsAsFactors = FALSE
      )
    })
    do.call(rbind, blocks)
  }
}

get_plot_x_axis_label <- function(term_name, plot_df) {
  if (!is.null(plot_df$x_axis_label) && length(unique(stats::na.omit(plot_df$x_axis_label))) > 0L) {
    return(unique(stats::na.omit(plot_df$x_axis_label))[1])
  }
  if (grepl(":", term_name, fixed = TRUE)) {
    parts <- strsplit(term_name, ":", fixed = TRUE)[[1]]
    components <- lapply(parts, get_term_component_spec)
    is_cont <- vapply(components, function(x) !is.null(x) && identical(x$type, "continuous"), logical(1))
    if (sum(is_cont) == 1L) {
      return(label_current_term(parts[which(is_cont)[1]]))
    }
  }
  label_current_term(term_name)
}

write_significance_plot_current <- function(file_path, plot_df, term_name) {
  if (is.null(plot_df) || nrow(plot_df) == 0L) {
    return(FALSE)
  }
  style <- get_plot_style()
  open_accessible_png(file_path, width = 8.8, height = 6.2)
  apply_accessible_theme()
  graphics::par(mar = c(5, 5, 3.5, 1.5), bty = "l")

  y_limits <- get_judgment_observed_bounds()
  y_ticks <- get_judgment_axis_ticks()
  x_axis_label <- get_plot_x_axis_label(term_name, plot_df)

  if (all(is.na(plot_df$moderator_label))) {
    if (length(unique(plot_df$x_value)) > 10L) {
      ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
      graphics::plot(
        ordered_df$x_value,
        ordered_df$predicted,
        type = "n",
        xlab = x_axis_label,
        ylab = "Predicted judgement",
        main = wrap_title(paste("Effect plot for", label_current_term(term_name)), width = 34),
        ylim = y_limits,
        yaxt = "n"
      )
      graphics::axis(2, at = y_ticks, labels = y_ticks)
      graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
      graphics::polygon(
        c(ordered_df$x_value, rev(ordered_df$x_value)),
        c(ordered_df$conf_low, rev(ordered_df$conf_high)),
        col = grDevices::adjustcolor(style$primary, alpha.f = 0.20),
        border = NA
      )
      graphics::lines(ordered_df$x_value, ordered_df$predicted, col = style$primary_dark, lwd = 3)
    } else {
      ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
      graphics::plot(
        ordered_df$x_value,
        ordered_df$predicted,
        type = "n",
        xaxt = "n",
        xlab = x_axis_label,
        ylab = "Predicted judgement",
        main = wrap_title(paste("Grouped prediction for", label_current_term(term_name)), width = 34),
        ylim = y_limits,
        yaxt = "n"
      )
      graphics::axis(2, at = y_ticks, labels = y_ticks)
      graphics::axis(1, at = ordered_df$x_value, labels = ordered_df$x_label)
      graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
      draw_confidence_interval_bars(ordered_df$x_value, ordered_df$conf_low, ordered_df$conf_high, style$primary_dark)
      graphics::lines(ordered_df$x_value, ordered_df$predicted, col = style$primary_dark, lwd = 2)
      graphics::points(ordered_df$x_value, ordered_df$predicted, pch = 19, col = style$primary_dark)
    }
  } else {
    groups <- split(plot_df, plot_df$moderator_label)
    palette <- c(style$primary_dark, "#B55B15", "#2E8540")
    all_x <- sort(unique(plot_df$x_value))
    is_continuous_x <- length(all_x) > 10L
    graphics::plot(
      all_x,
      rep(NA_real_, length(all_x)),
      type = "n",
      xlab = x_axis_label,
      ylab = "Predicted judgement",
      main = wrap_title(paste("Interaction plot for", label_current_term(term_name)), width = 34),
      ylim = y_limits,
      yaxt = "n",
      xaxt = if (is_continuous_x) "s" else "n"
    )
    graphics::axis(2, at = y_ticks, labels = y_ticks)
    if (!is_continuous_x) {
      x_labels <- unique(plot_df[, c("x_value", "x_label")])
      x_labels <- x_labels[order(x_labels$x_value), , drop = FALSE]
      graphics::axis(1, at = x_labels$x_value, labels = x_labels$x_label)
    }
    graphics::abline(h = 0, col = style$grid, lty = 3, lwd = 1)
    idx <- 1L
    for (group_name in names(groups)) {
      group_df <- groups[[group_name]]
      group_df <- group_df[order(group_df$x_value), , drop = FALSE]
      color <- palette[((idx - 1L) %% length(palette)) + 1L]
      if (is_continuous_x) {
        graphics::polygon(
          c(group_df$x_value, rev(group_df$x_value)),
          c(group_df$conf_low, rev(group_df$conf_high)),
          col = grDevices::adjustcolor(color, alpha.f = 0.18),
          border = NA
        )
        graphics::lines(group_df$x_value, group_df$predicted, col = color, lwd = 3)
      } else {
        graphics::lines(group_df$x_value, group_df$predicted, col = color, lwd = 3)
        graphics::points(group_df$x_value, group_df$predicted, col = color, pch = 19)
        draw_confidence_interval_bars(group_df$x_value, group_df$conf_low, group_df$conf_high, color)
      }
      idx <- idx + 1L
    }
    graphics::legend(
      "topleft",
      legend = names(groups),
      col = palette[seq_along(groups)],
      lwd = 3,
      pch = if (is_continuous_x) NA else 19,
      bty = "n"
    )
  }

  grDevices::dev.off()
  TRUE
}

describe_plot_pattern_current <- function(plot_df, lang = "en") {
  is_es <- identical(lang, "es")
  if (is.null(plot_df) || nrow(plot_df) == 0L) {
    return(if (is_es) "No se pudo resumir un patrón de predicción finito." else "No finite prediction pattern could be summarized.")
  }
  if (all(is.na(plot_df$moderator_label))) {
    ordered_df <- plot_df[order(plot_df$x_value), , drop = FALSE]
    if (nrow(ordered_df) < 2L) {
      return(if (is_es) "La figura resume el perfil ajustado de judgement predicho." else "The figure summarizes the fitted predicted judgement profile.")
    }
    direction <- ifelse(tail(ordered_df$predicted, 1) >= ordered_df$predicted[1], if (is_es) "mayor" else "higher", if (is_es) "menor" else "lower")
    return(sprintf(
      if (is_es) {
        "A lo largo del contraste mostrado, el modelo implica un judgement predicho %s hacia el lado derecho del gráfico."
      } else {
        "Across the displayed contrast, the model implies %s predicted judgement toward the right-hand side of the plot."
      },
      direction
    ))
  }
  if (is_es) {
    "Las líneas ajustadas y las bandas sombreadas de confianza al 95% resumen cómo cambia el judgement predicho a lo largo del término focal, manteniendo las covariables restantes en su perfil de referencia."
  } else {
    "The plotted fitted lines and shaded 95% confidence bands summarize how predicted judgement changes across the focal term while holding remaining covariates at their reference profile."
  }
}
