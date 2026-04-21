---
title: "Reporte de Trabajo sobre Juicio Moral bajo Modelos Tobit de Dos Lados"
author: "Leonardo H. Talero-Sarmiento"
date: "2026-04-20 20:34:33"
numbersections: true
---

Esta corrida usa `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` como unica fuente analitica y preserva cada fila importada como una observacion real de judgement. El estimador productivo es un Tobit de dos lados ajustado con `survival::survreg`, usando censura bilateral en `-9` y `9`, errores estandar robustos por cluster de participante via `cluster = id`, y `factor(session)` en cada formula activa.

# Entendiendo la estrategia de modelado

El propósito del pipeline es explicar cómo los participantes asignan judgement moral a un negociador focal dentro de un entorno experimental estructurado. El objetivo no se limita a describir promedios; busca estimar cómo cambia `judgement` en función de empatía, alineación de grupo, decisiones de negociación y estructura relacional específica por rol. Como cada participante aporta evaluaciones repetidas en múltiples escenarios y targets, la estrategia debe cumplir tres condiciones: preservar una fila por observación real, respetar el carácter acotado del outcome y ajustar la dependencia intra-participante. Por ello, la rama productiva usa un Tobit de dos lados con inferencia robusta por cluster de participante y ajuste por sesión.

La necesidad del Tobit proviene de la naturaleza de la variable dependiente. `judgement` se interpreta como continua, pero está acotada por diseño de medición. Los valores extremos son límites de la escala, no realizaciones no restringidas. Un modelo lineal estándar asume un outcome potencialmente no acotado, lo cual no es apropiado aquí. El enfoque Tobit modela una evaluación moral latente, denotada como `y_i^*`, observada a través de una puntuación acotada:

$$
y_i^* = X_i\beta + \varepsilon_i
$$

y

$$
judgement_i = \max(-9, \min(9, y_i^*)).
$$

Bajo esta especificación, el modelo representa valores interiores, acumulación en el límite inferior y acumulación en el límite superior. En este contexto, censura no significa datos faltantes; significa que la observación queda registrada en el límite de la escala cuando la evaluación latente excede ese rango.

El segundo reto metodológico es la estructura de medidas repetidas. Cada participante contribuye múltiples filas y, por tanto, las observaciones no son independientes. Ignorar esto tendería a subestimar errores estándar y sobrerreportar significancia. La rama actual lo aborda con errores estándar robustos agrupados por `id`. Además, se incorpora sesión con `factor(session)` para absorber desplazamientos sistemáticos entre sesiones. En esta implementación, sesión se modela como ajuste de efectos fijos y no como intercepto aleatorio.

Los predictores se organizan en bloques teóricos. El primero contiene dimensiones de empatía (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`) y fundamenta H1. El segundo captura estructura relacional de ingroup/outgroup por rol y fundamenta H2. El tercero incorpora decisiones de negociación con `decision_target`, `decision_other` y su interacción, núcleo de H4. Todos los modelos incluyen controles sociodemográficos.

Las interacciones son clave porque los efectos aditivos no siempre capturan la lógica experimental. En H3, interacciones empatía-por-grupo evalúan si el efecto de empatía depende de la alineación social. En H4 y H5, `decision_target:decision_other` evalúa si el significado moral de una decisión depende de la decisión de la contraparte.

La distinción entre víctima y bystander es central. Los modelos de víctima se enfocan en alineación víctima-negociador. Los de bystander requieren un mapa más amplio que incluye relaciones bystander-víctima, bystander-negociador y víctima-negociador. Por eso las especificaciones por rol no son intercambiables.

Las cinco familias de hipótesis siguen esa estructura: H1 (empatía), H2 (alineación de grupo), H3 (empatía + grupo + interacciones), H4 (decisiones y su interacción), H5 (modelo integrado).

Un principio clave del flujo es que una fila sigue siendo una observación real de target-judgement. No se duplican filas para crear pseudo-observaciones por negociador. En su lugar, el contexto de N1, N2, víctima y bystander se reconstruye dentro de cada fila existente.

En conjunto, la estrategia productiva respeta la naturaleza acotada del outcome, preserva el diseño observacional long, ajusta la dependencia por participante, controla heterogeneidad por sesión, separa mecanismos de víctima y bystander, y mapea directamente sobre la arquitectura teórica H1-H5. A la vez, no equivale a un Tobit multinivel completo con interceptos aleatorios de participante y sesión.

NA

# Puente semantico de nombres y mapeo por fila

Puente legacy/intuitivo de nombres: `accept_target` -> nombre operativo activo `decision_target`; `accept_other` -> nombre operativo activo `decision_other`.

Semantica por fila: `target` y `other` son roles dinamicos por observacion, mientras `N1` y `N2` son slots estructurales reconstruidos dentro de cada fila.

**Table 1. Mapeo de decision por fila desde target/other dinamicos hacia slots estructurales N1/N2**

| rule | expected_mapping | rows_in_scope | rows_following_rule | status |
| --- | --- | --- | --- | --- |
| target == 1 | N1_decision = decision_target; N2_decision = decision_other | 2430 | 2430 | PASS |
| target == 2 | N1_decision = decision_other; N2_decision = decision_target | 2430 | 2430 | PASS |


# Descripcion del dataset y de la muestra

El reporte usa el dataset experimental consolidado en formato long como única fuente analítica.
Cada participante aporta en principio 20 filas de judgement: diez escenarios multiplicados por dos evaluaciones de negociadores target.
Cada fila importada se mantiene como una observación real de judgement sobre el negociador target, enriquecida con contexto relacional de N1, N2, víctima y bystander, sin duplicación de filas.
Se evita doble conteo porque N1 y N2 se reconstruyen como atributos contextuales dentro de cada fila existente, en lugar de expandir el archivo en observaciones duplicadas por negociador.
Los análisis de víctima y bystander se estiman por separado para que la codificación relacional siga la lógica específica de cada rol.

La interpretacion autoritativa es que cada jugador observa diez escenarios y evalua dos negociadores, por lo que el archivo longitudinal debe contener 20 filas de judgement por participante. El diagnostico de clustering siguiente es consistente con ese diseno.

**Table 2. Resumen de participantes**

| metric | value |
| --- | --- |
| participants | 243.000 |
| sessions | 16.000 |
| mean_age | 20.086 |
| women_share | 0.426 |
| engineering_share | 0.568 |

**Table 3. Resumen de judgement**

| sample | rows | participants | mean_judgement | sd_judgement |
| --- | --- | --- | --- | --- |
| All | 4860 | 243 | 1.623 | 6.674 |
| Victim | 2430 | 243 | 1.504 | 6.842 |
| Bystander | 2430 | 243 | 1.741 | 6.500 |


# Datacard y diccionario de simbolos

**Table 4. Diccionario de simbolos del datacard**

| symbol | definition |
| --- | --- |
| judgement | Juicio moral observado en la escala acotada de -9 a 9. |
| y* | Tendencia latente de juicio subyacente a la observación censurada del Tobit. |
| iri_fs / iri_ec / iri_pt / iri_pd | Dimensiones de empatía IRI: fantasy, empathic concern, perspective taking y personal distress. |
| target (row-dynamic) | Negociador evaluado en esa fila; este rol es dinámico y puede ser N1 o N2 según la observación. |
| other (row-dynamic counterpart) | Negociador contraparte en ese mismo contexto de fila (actor no target). |
| N1 / N2 (structural slots) | Identidades estructurales de negociadores reconstruidas dentro de cada fila para el modelado relacional; no son alias fijos de target/other. |
| decision_target | Indicador de si el negociador target dinámico por fila aceptó el trato dañino; nombre operativo activo del término legacy accept_target. |
| decision_other | Indicador de si el negociador other dinámico por fila aceptó el trato dañino; nombre operativo activo del término legacy accept_other. |
| victim_N1_group / victim_N2_group | Relaciones específicas de víctima con negociador 1 y negociador 2, con ingroup definido por coincidencia de facultad incluyendo control-control. |
| bystander_victim_group / bystander_N1_group / bystander_N2_group | Factores relacionales del lado bystander para la víctima y ambos negociadores, también con coincidencia de facultad como ingroup. |
| group_target / group_other (legacy audit) | Campos de agrupación legacy de la fuente, retenidos para trazabilidad; no se usan directamente en las fórmulas activas H2/H3/H5. |
| N1_N2_same_faculty | Término de contexto que indica si N1 y N2 comparten facultad. |
| factor(session) | Efectos fijos de sesión incluidos directamente en cada fórmula ajustada. |
| cluster = id | Agrupación a nivel participante usada para errores estándar robustos y ajuste por medidas repetidas. |
| Log(scale) | Parámetro Tobit log-scale estimado que resume la dispersión residual latente. |

**Table 5. Auditoria de observaciones**

| checkpoint | value |
| --- | --- |
| base_excel_rows | 4860 |
| processed_import_rows | 4860 |
| processed_judgment_rows | 4860 |
| unique_source_row_numbers | 4860 |
| duplicated_source_row_numbers | 0 |


# Glosario de predictores

**Table 6. Glosario de predictores (version de lectura)**

| Codigo | Interpretacion |
| --- | --- |
| FS | Dimensión de empatía fantasy. |
| EC | Dimensión de empatía empathic concern. |
| PT | Dimensión de empatía perspective taking. |
| PD | Dimensión de empatía personal distress. |
| V-N1 In | La víctima y N1 pertenecen a la misma facultad. |
| V-N1 Out | La víctima y N1 pertenecen a facultades diferentes. |
| V-N2 In | La víctima y N2 pertenecen a la misma facultad. |
| V-N2 Out | La víctima y N2 pertenecen a facultades diferentes. |
| B-V Out | Bystander y víctima pertenecen a facultades diferentes. |
| B-N1 In | Bystander y N1 pertenecen a la misma facultad. |
| B-N1 Out | Bystander y N1 pertenecen a facultades diferentes. |
| B-N2 In | Bystander y N2 pertenecen a la misma facultad. |
| B-N2 Out | Bystander y N2 pertenecen a facultades diferentes. |
| SameFac | N1 y N2 comparten pertenencia de facultad. |
| FS x V-N1 Out | Diferencia de pendiente de fantasy cuando victim-N1 es outgroup frente a ingroup. |
| EC x V-N2 Out | Diferencia de pendiente de empathic concern cuando victim-N2 es outgroup frente a ingroup. |
| PT x B-V Out | Diferencia de pendiente de perspective taking cuando la relación bystander-victim es outgroup frente a ingroup. |
| PD x B-N1 Out | Diferencia de pendiente de personal distress cuando la relación bystander-N1 es outgroup frente a ingroup. |
| Target Acc | El negociador target dinámico por fila aceptó el trato dañino (término legacy: accept_target). |
| Other Acc | El negociador contraparte dinámico por fila aceptó el trato dañino (término legacy: accept_other). |
| Target x Other | Efecto conjunto de decisiones cuando se consideran simultáneamente las decisiones de ambos negociadores. |
| Eng part. | El participante pertenece a Engineering, relativo a Humanities. |
| Woman | El participante es mujer. |
| Age | Edad del participante. |
| SES | Nivel socioeconómico del participante. |


Nota. Los contrastes de grupo se interpretan contra la linea base ingroup, salvo indicacion explicita en contrario.

El reporte mantiene referencias compactas de predictores en captions y narrativas de figuras, pero el glosario anterior es el mapeo autoritativo hacia las variables actuales del pipeline.

# Reglas de interpretacion de interacciones

1. Cuando una interacción es estadísticamente relevante, los efectos principales deben leerse como el componente de línea base de la relación y no como toda la historia sustantiva.
2. Las interacciones continuo-por-factor indican que la pendiente de empatía cambia según las condiciones relacionales.
3. Las interacciones factor-por-factor indican que el contexto conjunto difiere de lo esperable al sumar de forma independiente los dos contrastes principales.
4. La interacción target-by-other en decisiones indica que el significado moral de la elección de un negociador depende de lo que hizo su contraparte.
5. Los efectos de sesión son términos de ajuste y no se interpretan como mecanismos sustantivos del experimento.

# Hipotesis H1-H5 con resumenes de ecuaciones especificas por rol

\begingroup
\setlength{\tabcolsep}{2pt}
\scriptsize
\begin{longtable}{@{}>{\raggedright\arraybackslash\hspace{0pt}}p{0.06\textwidth}>{\raggedright\arraybackslash\hspace{0pt}}p{0.12\textwidth}>{\raggedright\arraybackslash\hspace{0pt}}p{0.58\textwidth}>{\raggedright\arraybackslash\hspace{0pt}}p{0.24\textwidth}@{}}
\caption{Formulas especificas por rol H1-H5 y enfoque teorico.}\label{tbl-formula-catalog}\\
\toprule
H & Rol & Formula & Enfoque \\
\midrule
\endfirsthead
\toprule
H & Rol & Formula & Enfoque \\
\midrule
\endhead
H1 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Solo dimensiones de empatia, siempre ajustadas por sociodemograficos. \\
H1 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Solo dimensiones de empatia, siempre ajustadas por sociodemograficos. \\
H2 & Victim & victim\_N1\_group  +  victim\_N2\_group  +  victim\_N1\_group : victim\_N2\_group  +  N1\_N2\_same\_faculty  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Estructura ingroup/outgroup del lado Victim con la interaccion relacional permitida N1 x N2. \\
H2 & Bystander & bystander\_victim\_group  +  bystander\_N1\_group  +  bystander\_N2\_group  +  victim\_N1\_group  +  victim\_N2\_group  +  bystander\_N1\_group : bystander\_N2\_group  +  victim\_N1\_group : victim\_N2\_group  +  N1\_N2\_same\_faculty  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Estructura relacional del lado Bystander con terminos explicitos bystander-victim, bystander-negotiator, victim-negotiator y contexto N1/N2. \\
H3 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  victim\_N1\_group  +  victim\_N2\_group  +  victim\_N1\_group : victim\_N2\_group  +  N1\_N2\_same\_faculty  +  iri\_fs : victim\_N1\_group  +  iri\_fs : victim\_N2\_group  +  iri\_ec : victim\_N1\_group  +  iri\_ec : victim\_N2\_group  +  iri\_pt : victim\_N1\_group  +  iri\_pt : victim\_N2\_group  +  iri\_pd : victim\_N1\_group  +  iri\_pd : victim\_N2\_group  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empatia mas estructura relacional del lado Victim, incluyendo interacciones empatia x victim-N1 y empatia x victim-N2 porque la empatia puede depender de cercania al negociador. \\
H3 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  bystander\_victim\_group  +  bystander\_N1\_group  +  bystander\_N2\_group  +  victim\_N1\_group  +  victim\_N2\_group  +  bystander\_N1\_group : bystander\_N2\_group  +  victim\_N1\_group : victim\_N2\_group  +  N1\_N2\_same\_faculty  +  iri\_fs : bystander\_victim\_group  +  iri\_fs : bystander\_N1\_group  +  iri\_fs : bystander\_N2\_group  +  iri\_ec : bystander\_victim\_group  +  iri\_ec : bystander\_N1\_group  +  iri\_ec : bystander\_N2\_group  +  iri\_pt : bystander\_victim\_group  +  iri\_pt : bystander\_N1\_group  +  iri\_pt : bystander\_N2\_group  +  iri\_pd : bystander\_victim\_group  +  iri\_pd : bystander\_N1\_group  +  iri\_pd : bystander\_N2\_group  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empatia mas estructura relacional del lado Bystander, incluyendo interacciones empatia x bystander-victim y empatia x bystander-negotiator porque la empatia puede depender de cercania de grupo en el rol Bystander. \\
H4 & Victim & decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Decisiones de target y del otro negociador con su interaccion, mas sociodemograficos. \\
H4 & Bystander & decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Decisiones de target y del otro negociador con su interaccion, mas sociodemograficos. \\
H5 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  victim\_N1\_group  +  victim\_N2\_group  +  victim\_N1\_group : victim\_N2\_group  +  N1\_N2\_same\_faculty  +  iri\_fs : victim\_N1\_group  +  iri\_fs : victim\_N2\_group  +  iri\_ec : victim\_N1\_group  +  iri\_ec : victim\_N2\_group  +  iri\_pt : victim\_N1\_group  +  iri\_pt : victim\_N2\_group  +  iri\_pd : victim\_N1\_group  +  iri\_pd : victim\_N2\_group  +  decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Modelo integrado con empatia, relaciones del lado Victim, interacciones empatia x grupo, decisiones y la interaccion relacional del lado Victim. \\
H5 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  bystander\_victim\_group  +  bystander\_N1\_group  +  bystander\_N2\_group  +  victim\_N1\_group  +  victim\_N2\_group  +  bystander\_N1\_group : bystander\_N2\_group  +  victim\_N1\_group : victim\_N2\_group  +  N1\_N2\_same\_faculty  +  iri\_fs : bystander\_victim\_group  +  iri\_fs : bystander\_N1\_group  +  iri\_fs : bystander\_N2\_group  +  iri\_ec : bystander\_victim\_group  +  iri\_ec : bystander\_N1\_group  +  iri\_ec : bystander\_N2\_group  +  iri\_pt : bystander\_victim\_group  +  iri\_pt : bystander\_N1\_group  +  iri\_pt : bystander\_N2\_group  +  iri\_pd : bystander\_victim\_group  +  iri\_pd : bystander\_N1\_group  +  iri\_pd : bystander\_N2\_group  +  decision\_target * decision\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Modelo integrado con empatia, relaciones del lado Bystander, interacciones empatia x grupo, decisiones e interacciones relacionales especificas por rol. \\
\bottomrule
\end{longtable}
\endgroup

Cualquier nota previa del repositorio que tratara el codigo de negociador `0` como algo distinto de la categoria explicita control, o que restringiera H3 a efectos aditivos, debe considerarse desactualizada. Las formulas activas siguientes son la especificacion autoritativa.

## H1

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + age + ses + sex_female + faculty_player_factor + factor(session)`

## H2

`Victim`: `victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + age + ses + sex_female + faculty_player_factor + factor(session)`

## H3

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:victim_N1_group + iri_fs:victim_N2_group + iri_ec:victim_N1_group + iri_ec:victim_N2_group + iri_pt:victim_N1_group + iri_pt:victim_N2_group + iri_pd:victim_N1_group + iri_pd:victim_N2_group + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group + iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group + iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group + iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group + age + ses + sex_female + faculty_player_factor + factor(session)`

## H4

`Victim`: `decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## H5

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_N1_group + victim_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:victim_N1_group + iri_fs:victim_N2_group + iri_ec:victim_N1_group + iri_ec:victim_N2_group + iri_pt:victim_N1_group + iri_pt:victim_N2_group + iri_pd:victim_N1_group + iri_pd:victim_N2_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_N1_group + bystander_N2_group + victim_N1_group + victim_N2_group + bystander_N1_group:bystander_N2_group + victim_N1_group:victim_N2_group + N1_N2_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_N1_group + iri_fs:bystander_N2_group + iri_ec:bystander_victim_group + iri_ec:bystander_N1_group + iri_ec:bystander_N2_group + iri_pt:bystander_victim_group + iri_pt:bystander_N1_group + iri_pt:bystander_N2_group + iri_pd:bystander_victim_group + iri_pd:bystander_N1_group + iri_pd:bystander_N2_group + decision_target * decision_other + age + ses + sex_female + faculty_player_factor + factor(session)`

# Fundamentos matematicos

El estimador principal es un Tobit de dos lados ajustado con `survival::survreg`.

$$y_i = \max(-9, \min(9, y_i^*))$$

$$y_i^* = \beta_0 + X_i\beta + \delta_{session(i)} + \varepsilon_i$$

donde `factor(session)` aporta efectos fijos de sesión y los errores estándar robustos por cluster se calculan al nivel de participante mediante `cluster = id` con `robust = TRUE`.
Por tanto, este reporte trata sesión como ajuste implementado de efecto fijo y no como intercepto aleatorio.

En esta rama productiva, se reporta `factor(session)` en lugar de `(1|session)` porque el estimador ajustado es un Tobit de dos lados con efectos fijos de sesion y errores estandar robustos por cluster de participante. El reporte no afirma un intercepto aleatorio de sesion que no haya sido estimado.

# Diagnostico de dependencia y tamano efectivo de muestra

El siguiente diagnostico de clustering es descriptivo. Resume la dependencia intra-participante en los datos observados y no debe leerse como evidencia de que el estimador ajustado incluyo interceptos aleatorios por participante.

**Table 7. Diagnostico descriptivo de clustering**

| metric | value |
| --- | --- |
| participants | 243.000 |
| observations | 4860.000 |
| average_observations_per_id | 20.000 |
| icc_descriptive | 0.134 |
| design_effect | 3.537 |
| effective_sample_size | 1373.909 |


Como el objetivo de inferencia es el judgement repetido dentro de participante, la tabla de tamano efectivo de muestra es solo un diagnostico descriptivo de clustering; no reemplaza el ajuste de dependencia basado en modelo mediante `cluster = id` y `factor(session)`.

# Estadisticas descriptivas y figuras

**Table 8. Resumen de decisiones por rol**

| role_label | decision_pattern | n | mean_judgement |
| --- | --- | --- | --- |
| bystander | both_accept | 604 | -2.785 |
| victim | both_accept | 610 | -3.167 |
| bystander | both_reject | 690 | 7.086 |
| victim | both_reject | 662 | 7.062 |
| bystander | target_accept_other_reject | 568 | -3.155 |
| victim | target_accept_other_reject | 579 | -3.803 |
| bystander | target_reject_other_accept | 568 | 4.958 |
| victim | target_reject_other_accept | 579 | 5.378 |

**Table 9. Resumen ingroup/outgroup especifico por rol**

| variable | level | n |
| --- | --- | --- |
| victim_N1_group | ingroup | 1682 |
| victim_N1_group | outgroup | 3178 |
| victim_N2_group | ingroup | 1578 |
| victim_N2_group | outgroup | 3282 |
| bystander_victim_group | ingroup | 1212 |
| bystander_victim_group | outgroup | 1218 |
| bystander_N1_group | ingroup | 812 |
| bystander_N1_group | outgroup | 1618 |
| bystander_N2_group | ingroup | 798 |
| bystander_N2_group | outgroup | 1632 |
| N1_N2_same_faculty | different | 3276 |
| N1_N2_same_faculty | same | 1584 |

**Table 10. Matriz de correlacion entre empatia y judgement promedio a nivel participante**

| term | iri_fs | iri_ec | iri_pt | iri_pd | judgement |
| --- | --- | --- | --- | --- | --- |
| iri_fs | 1.000 | 0.409 | 0.154 | 0.282 | 0.051 |
| iri_ec | 0.409 | 1.000 | 0.482 | 0.219 | -0.017 |
| iri_pt | 0.154 | 0.482 | 1.000 | -0.177 | 0.111 |
| iri_pd | 0.282 | 0.219 | -0.177 | 1.000 | -0.046 |
| judgement | 0.051 | -0.017 | 0.111 | -0.046 | 1.000 |


El resumen de grupos y las formulas anteriores usan codificacion ingroup/outgroup especifica por rol. Ingroup se define por coincidencia de facultad, incluyendo `control` con `control`, mientras outgroup significa facultades no coincidentes.

![Perfil promedio de subescalas IRI en participantes.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_iri_subscale_radar.png)

Esta figura resume el perfil central de empatia de la muestra antes de condicionar en modelos especificos de hipotesis.

![Dispersogramas bivariados a nivel participante de subescalas IRI frente a `judgement` promedio.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_bivariate_empathy_vs_mean_judgement.png)

Estos scatterplots muestran la relacion descriptiva a nivel participante entre dimensiones de empatia y `judgement` promedio.

![Distribuciones observadas de `judgement` separadas por rol.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role.png)

Esta figura muestra la forma bruta del outcome acotado `judgement` en los subconjuntos Victim y Bystander.

![Distribuciones observadas de `judgement` por rol y negociador target.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_target.png)

Esta figura muestra si la distribucion bruta y acotada de `judgement` cambia segun si el target evaluado es N1 o N2 dentro de escenarios Victim y Bystander.

![Distribuciones observadas de `judgement` por rol y decision del target.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_target_decision.png)

Esta figura aisla si la aceptacion o rechazo del propio target se asocia con perfiles brutos distintos de `judgement` dentro de cada rol.

![Distribuciones observadas de `judgement` por rol y decision de la contraparte.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_other_decision.png)

Esta figura muestra si `judgement` del target varia con la aceptacion o rechazo del otro negociador.

![Distribuciones observadas de `judgement` por rol y patron conjunto de decision.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_decision_pattern.png)

Esta figura muestra como cambia la distribucion de `judgement` enfocada en target a traves de los cuatro resultados conjuntos de negociacion en escenarios Victim y Bystander.

![Conteos observados de patrones de decision por rol.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_decision_pattern_by_role.png)

Esta figura resume con que frecuencia aparece cada patron conjunto de decision en los subconjuntos Victim y Bystander.

![Distribuciones de `judgement` del rol Victim a traves de pareamientos de facultad N1 x N2.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_victim_n1n2_faculty_grid.png)

Esta figura muestra como varia la distribucion bruta de `judgement` a traves del espacio relacional completo definido por el pareamiento de facultad entre N1 y N2.

![Distribuciones de `judgement` del rol Bystander a traves de pareamientos de facultad N1 x N2.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_n1n2_faculty_grid.png)

Esta figura muestra como varia la distribucion bruta de `judgement` a traves del espacio relacional completo definido por el pareamiento de facultad entre N1 y N2.

![Distribuciones de `judgement` del rol Victim a traves de combinaciones victim-N1 y victim-N2 de ingroup/outgroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_victim_group_grid.png)

Esta figura opcional destaca como varia el `judgement` bruto del rol Victim a traves de combinaciones ingroup/outgroup centradas en la victima.

![Distribuciones de `judgement` del rol Bystander a traves de combinaciones bystander-N1 y bystander-N2 de ingroup/outgroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_playerN1_playerN2_grid.png)

Esta figura opcional enfatiza combinaciones relacionales del lado Bystander ligadas directamente a la alineacion de grupo de N1 y N2.

![Distribuciones de `judgement` del rol Bystander a traves de combinaciones victim-N1 y victim-N2 de ingroup/outgroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_victimN1_victimN2_grid.png)

Esta figura opcional muestra como `judgement` del bystander covaria con combinaciones relacionales centradas en la victima dentro de las mismas filas observadas.

# Resumen de ajuste del estimador

Los modelos Bystander usan 2,420 observaciones de 243 participantes.
Los modelos Victim usan 2,420 observaciones de 243 participantes.

Todos los modelos productivos usan la configuracion del estimador mostrada abajo.

**Table 11. Configuracion del estimador**

| Estimator | Session handling | Dependence |
| --- | --- | --- |
| Two-sided Tobit | factor_session_fixed_effect | cluster_robust_id |

## Resumen de ajuste y censura a nivel de modelo

### Modelos Bystander

**Table 12. Resumen de ajuste y censura para modelos Bystander**

| H | L. cens. | U. cens. | AIC | BIC | Sigma |
| --- | --- | --- | --- | --- | --- |
| H1 | 300 | 723 | 12558.800 | 12703.600 | 10.264 |
| H2 | 300 | 723 | 12557.400 | 12725.400 | 10.242 |
| H3 | 300 | 723 | 12569.200 | 12829.800 | 10.193 |
| H4 | 300 | 723 | 11060.300 | 11199.300 | 6.917 |
| H5 | 300 | 723 | 11080.200 | 11358.200 | 6.876 |

### Modelos Victim

**Table 13. Resumen de ajuste y censura para modelos Victim**

| H | L. cens. | U. cens. | AIC | BIC | Sigma |
| --- | --- | --- | --- | --- | --- |
| H1 | 377 | 744 | 12280.600 | 12425.300 | 11.564 |
| H2 | 377 | 744 | 12297.600 | 12442.400 | 11.607 |
| H3 | 377 | 744 | 12296.000 | 12510.300 | 11.541 |
| H4 | 377 | 744 | 10747.900 | 10886.900 | 7.626 |
| H5 | 377 | 744 | 10749.300 | 10980.900 | 7.570 |

# Resumen de significancia de hipotesis por rol

## Victim

**Table 14. Terminos de soporte focal Victim (p < 0.10)**

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Victim | Empathy: Perspective taking** |
| H2 | Victim | None below p < 0.10 |
| H3 | Victim | Empathy: Fantasy*; Empathy: Perspective taking+ |
| H4 | Victim | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Victim | Empathy: Fantasy*; Victim-N2 outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-N1 outgroup vs ingroup+; Target accepted x Other accepted*** |

## Bystander

**Table 15. Terminos de soporte focal Bystander (p < 0.10)**

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Bystander | None below p < 0.10 |
| H2 | Bystander | Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+ |
| H3 | Bystander | Empathy: Empathic concern+; Empathy: Personal distress+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+; Empathy: Fantasy x Bystander-victim outgroup vs ingroup+; Empathy: Personal distress x Bystander-victim outgroup vs ingroup* |
| H4 | Bystander | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Bystander | Victim-N1 outgroup vs ingroup*; Victim-N2 outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted*** |

# Figuras guiadas por significancia

## H1 Victim: Empathy: Perspective taking

![H1 Victim: predicciones implicadas por el modelo para Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h1_victim_iri_pt.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H2 Bystander: Bystander-N2 outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Bystander-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_bystander_n2_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H2 Bystander: Victim-N1 outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_n1_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H2 Bystander: Victim-N2 outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_n2_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H2 Bystander: Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_bystander_n1_groupoutgroup_bystander_n2_groupoutgr.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H2 Bystander: Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_n1_groupoutgroup_victim_n2_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Victim: Empathy: Fantasy

![H3 Victim: predicciones implicadas por el modelo para Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_fs.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Victim: Empathy: Perspective taking

![H3 Victim: predicciones implicadas por el modelo para Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_pt.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Empathy: Empathic concern

![H3 Bystander: predicciones implicadas por el modelo para Empathy: Empathic concern.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_ec.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Empathy: Personal distress

![H3 Bystander: predicciones implicadas por el modelo para Empathy: Personal distress.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_pd.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Victim-N1 outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_n1_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Victim-N2 outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_n2_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_bystander_n1_groupoutgroup_bystander_n2_groupoutgr.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Bystander: Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_n1_groupoutgroup_victim_n2_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_fs_bystander_victim_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Bystander: Empathy: Personal distress x Bystander-victim outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Empathy: Personal distress x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_pd_bystander_victim_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H4 Victim: Target accepted

![H4 Victim: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Victim: Other negotiator accepted

![H4 Victim: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Victim: Target accepted x Other accepted

![H4 Victim: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_decision_target_decision_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H4 Bystander: Target accepted

![H4 Bystander: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Bystander: Other negotiator accepted

![H4 Bystander: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Bystander: Target accepted x Other accepted

![H4 Bystander: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_decision_target_decision_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Victim: Empathy: Fantasy

![H5 Victim: predicciones implicadas por el modelo para Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Victim-N2 outgroup vs ingroup

![H5 Victim: predicciones implicadas por el modelo para Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_victim_n2_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Target accepted

![H5 Victim: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Other negotiator accepted

![H5 Victim: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Empathy: Fantasy x Victim-N1 outgroup vs ingroup

![H5 Victim: predicciones implicadas por el modelo para Empathy: Fantasy x Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs_victim_n1_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Victim: Target accepted x Other accepted

![H5 Victim: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_decision_target_decision_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Bystander: Victim-N1 outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Victim-N1 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_n1_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Victim-N2 outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_n2_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Target accepted

![H5 Bystander: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Other negotiator accepted

![H5 Bystander: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_n1_groupoutgroup_victim_n2_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_iri_fs_bystander_victim_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Bystander: Target accepted x Other accepted

![H5 Bystander: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_decision_target_decision_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

# Tablas completas de coeficientes y resumen de interpretacion

## H1 Victim coefficient table

**Table 16. H1 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -0.874 | 3.297 | -7.337 | 5.589 | 0.791 |
| Empathy: Fantasy | 0.644 | 0.524 | -0.383 | 1.672 | 0.219 |
| Empathy: Empathic concern | -0.850 | 0.751 | -2.322 | 0.623 | 0.258 |
| Empathy: Perspective taking | 1.773 | 0.614 | 0.570 | 2.975 | 0.004** |
| Empathy: Personal distress | 0.035 | 0.588 | -1.117 | 1.188 | 0.952 |
| Age | -0.025 | 0.133 | -0.285 | 0.235 | 0.850 |
| Socioeconomic status | 0.451 | 0.344 | -0.224 | 1.126 | 0.190 |
| Woman participant | 0.211 | 0.812 | -1.380 | 1.803 | 0.795 |
| Participant faculty: Engineering vs Humanities | 1.352 | 0.803 | -0.222 | 2.925 | 0.092+ |
| Tobit log-scale | 2.448 | 0.057 | 2.336 | 2.560 | <0.001*** |

El modelo H1 Victim muestra evidencia focal para un términos de hipótesis. Empathy: Perspective taking se asocia con mayor judgement predicho (estimate = 1.77, p = 0.004**). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H1 Bystander coefficient table

**Table 17. H1 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -3.438 | 3.171 | -9.654 | 2.777 | 0.278 |
| Empathy: Fantasy | 0.111 | 0.446 | -0.763 | 0.984 | 0.804 |
| Empathy: Empathic concern | -0.859 | 0.638 | -2.110 | 0.391 | 0.178 |
| Empathy: Perspective taking | 0.573 | 0.560 | -0.524 | 1.671 | 0.306 |
| Empathy: Personal distress | 0.167 | 0.561 | -0.934 | 1.267 | 0.766 |
| Age | 0.361 | 0.103 | 0.160 | 0.563 | <0.001*** |
| Socioeconomic status | 0.491 | 0.299 | -0.096 | 1.078 | 0.101 |
| Woman participant | -0.810 | 0.704 | -2.190 | 0.569 | 0.250 |
| Participant faculty: Engineering vs Humanities | 1.005 | 0.626 | -0.222 | 2.232 | 0.109 |
| Tobit log-scale | 2.329 | 0.057 | 2.217 | 2.440 | <0.001*** |

En el modelo H1 Bystander, ningún término focal de hipótesis alcanzó p < 0.10. Por ello, el reporte conserva la tabla de coeficientes para auditabilidad, pero no añade una interpretación sustantiva guiada por significancia más allá de los gráficos descriptivos de predicción.

Recordatorio H2: `N1`/`N2` son slots estructurales reconstruidos dentro de cada fila, no aliases fijos de `target`/`other`; `group_target` y `group_other` son campos legacy de fuente/auditoria, mientras que los modelos activos de H2 usan predictores relacionales reconstruidos.

## H2 Victim coefficient table

**Table 18. H2 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 2.846 | 3.504 | -4.023 | 9.715 | 0.417 |
| Victim-N1 outgroup vs ingroup | -0.232 | 1.364 | -2.905 | 2.441 | 0.865 |
| Victim-N2 outgroup vs ingroup | -0.424 | 1.310 | -2.992 | 2.144 | 0.746 |
| N1/N2 same faculty vs different | 0.359 | 0.849 | -1.305 | 2.023 | 0.672 |
| Age | -0.020 | 0.133 | -0.281 | 0.241 | 0.881 |
| Socioeconomic status | 0.525 | 0.358 | -0.176 | 1.227 | 0.142 |
| Woman participant | 0.327 | 0.764 | -1.171 | 1.824 | 0.669 |
| Participant faculty: Engineering vs Humanities | 1.526 | 0.817 | -0.076 | 3.128 | 0.062+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 0.133 | 1.792 | -3.379 | 3.646 | 0.941 |
| Tobit log-scale | 2.452 | 0.057 | 2.340 | 2.563 | <0.001*** |

En el modelo H2 Victim, ningún término focal de hipótesis alcanzó p < 0.10. Por ello, el reporte conserva la tabla de coeficientes para auditabilidad, pero no añade una interpretación sustantiva guiada por significancia más allá de los gráficos descriptivos de predicción.

## H2 Bystander coefficient table

**Table 19. H2 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -2.381 | 3.001 | -8.263 | 3.501 | 0.428 |
| Bystander-victim outgroup vs ingroup | -0.315 | 0.495 | -1.285 | 0.656 | 0.525 |
| Bystander-N1 outgroup vs ingroup | 1.132 | 1.078 | -0.980 | 3.245 | 0.294 |
| Bystander-N2 outgroup vs ingroup | 2.085 | 1.120 | -0.110 | 4.280 | 0.063+ |
| Victim-N1 outgroup vs ingroup | -2.168 | 1.227 | -4.573 | 0.237 | 0.077+ |
| Victim-N2 outgroup vs ingroup | -2.331 | 1.214 | -4.710 | 0.049 | 0.055+ |
| N1/N2 same faculty vs different | 0.786 | 0.831 | -0.844 | 2.416 | 0.344 |
| Age | 0.325 | 0.101 | 0.126 | 0.524 | 0.001** |
| Socioeconomic status | 0.466 | 0.299 | -0.120 | 1.052 | 0.119 |
| Woman participant | -0.902 | 0.661 | -2.198 | 0.394 | 0.173 |
| Participant faculty: Engineering vs Humanities | 1.064 | 0.646 | -0.202 | 2.331 | 0.099+ |
| Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup | -2.359 | 1.401 | -5.104 | 0.386 | 0.092+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 2.884 | 1.578 | -0.210 | 5.977 | 0.068+ |
| Tobit log-scale | 2.326 | 0.057 | 2.215 | 2.438 | <0.001*** |

El modelo H2 Bystander muestra evidencia focal para 5 términos de hipótesis. Victim-N2 outgroup vs ingroup se asocia con menor judgement predicho (estimate = -2.33, p = 0.055+). Bystander-N2 outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 2.08, p = 0.063+). Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 2.88, p = 0.068+). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H3 Victim coefficient table

**Table 20. H3 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | -4.295 | 4.224 | -12.574 | 3.984 | 0.309 |
| Empathy: Fantasy | 2.044 | 0.859 | 0.360 | 3.727 | 0.017* |
| Empathy: Empathic concern | -0.137 | 1.104 | -2.302 | 2.027 | 0.901 |
| Empathy: Perspective taking | 1.678 | 0.980 | -0.242 | 3.598 | 0.087+ |
| Empathy: Personal distress | -0.416 | 1.038 | -2.451 | 1.619 | 0.689 |
| Victim-N1 outgroup vs ingroup | 1.415 | 2.894 | -4.257 | 7.087 | 0.625 |
| Victim-N2 outgroup vs ingroup | 2.983 | 3.200 | -3.288 | 9.255 | 0.351 |
| N1/N2 same faculty vs different | 0.297 | 0.845 | -1.360 | 1.954 | 0.725 |
| Age | -0.025 | 0.132 | -0.284 | 0.235 | 0.853 |
| Socioeconomic status | 0.472 | 0.344 | -0.203 | 1.146 | 0.171 |
| Woman participant | 0.248 | 0.817 | -1.352 | 1.849 | 0.761 |
| Participant faculty: Engineering vs Humanities | 1.519 | 0.812 | -0.073 | 3.110 | 0.061+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 0.328 | 1.780 | -3.161 | 3.816 | 0.854 |
| Empathy: Fantasy x Victim-N1 outgroup vs ingroup | -0.829 | 0.752 | -2.302 | 0.644 | 0.270 |
| Empathy: Fantasy x Victim-N2 outgroup vs ingroup | -1.132 | 0.883 | -2.863 | 0.599 | 0.200 |
| Empathy: Empathic concern x Victim-N1 outgroup vs ingroup | 0.380 | 1.113 | -1.802 | 2.562 | 0.733 |
| Empathy: Empathic concern x Victim-N2 outgroup vs ingroup | -1.357 | 1.116 | -3.544 | 0.831 | 0.224 |
| Empathy: Perspective taking x Victim-N1 outgroup vs ingroup | -0.388 | 1.042 | -2.430 | 1.653 | 0.709 |
| Empathy: Perspective taking x Victim-N2 outgroup vs ingroup | 0.482 | 1.152 | -1.777 | 2.740 | 0.676 |
| Empathy: Personal distress x Victim-N1 outgroup vs ingroup | -0.049 | 0.958 | -1.926 | 1.828 | 0.959 |
| Empathy: Personal distress x Victim-N2 outgroup vs ingroup | 0.573 | 0.928 | -1.245 | 2.391 | 0.537 |
| Tobit log-scale | 2.446 | 0.057 | 2.334 | 2.558 | <0.001*** |

El modelo H3 Victim muestra evidencia focal para 2 términos de hipótesis. Empathy: Fantasy se asocia con mayor judgement predicho (estimate = 2.04, p = 0.017*). Empathy: Perspective taking se asocia con mayor judgement predicho (estimate = 1.68, p = 0.087+). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H3 Bystander coefficient table

**Table 21. H3 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 2.237 | 4.049 | -5.698 | 10.173 | 0.581 |
| Empathy: Fantasy | 1.337 | 0.928 | -0.482 | 3.155 | 0.150 |
| Empathy: Empathic concern | -2.025 | 1.209 | -4.395 | 0.344 | 0.094+ |
| Empathy: Perspective taking | 0.002 | 1.030 | -2.017 | 2.022 | 0.998 |
| Empathy: Personal distress | -1.516 | 0.910 | -3.300 | 0.269 | 0.096+ |
| Bystander-victim outgroup vs ingroup | -3.515 | 2.601 | -8.612 | 1.583 | 0.177 |
| Bystander-N1 outgroup vs ingroup | -1.442 | 2.871 | -7.070 | 4.185 | 0.615 |
| Bystander-N2 outgroup vs ingroup | -0.129 | 2.740 | -5.499 | 5.241 | 0.963 |
| Victim-N1 outgroup vs ingroup | -2.124 | 1.215 | -4.505 | 0.256 | 0.080+ |
| Victim-N2 outgroup vs ingroup | -2.317 | 1.216 | -4.701 | 0.066 | 0.057+ |
| N1/N2 same faculty vs different | 0.826 | 0.820 | -0.781 | 2.434 | 0.314 |
| Age | 0.353 | 0.103 | 0.152 | 0.554 | <0.001*** |
| Socioeconomic status | 0.418 | 0.295 | -0.160 | 0.996 | 0.157 |
| Woman participant | -0.791 | 0.696 | -2.155 | 0.574 | 0.256 |
| Participant faculty: Engineering vs Humanities | 0.868 | 0.625 | -0.357 | 2.093 | 0.165 |
| Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup | -2.421 | 1.405 | -5.174 | 0.331 | 0.085+ |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 2.833 | 1.574 | -0.252 | 5.918 | 0.072+ |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.335 | 0.759 | -2.823 | 0.152 | 0.078+ |
| Empathy: Fantasy x Bystander-N1 outgroup vs ingroup | -0.947 | 0.780 | -2.476 | 0.582 | 0.225 |
| Empathy: Fantasy x Bystander-N2 outgroup vs ingroup | 0.016 | 0.856 | -1.663 | 1.694 | 0.985 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 1.081 | 1.084 | -1.043 | 3.206 | 0.318 |
| Empathy: Empathic concern x Bystander-N1 outgroup vs ingroup | 1.081 | 1.022 | -0.922 | 3.085 | 0.290 |
| Empathy: Empathic concern x Bystander-N2 outgroup vs ingroup | -0.073 | 1.135 | -2.298 | 2.152 | 0.949 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.142 | 0.900 | -1.623 | 1.906 | 0.875 |
| Empathy: Perspective taking x Bystander-N1 outgroup vs ingroup | 0.355 | 1.034 | -1.672 | 2.381 | 0.732 |
| Empathy: Perspective taking x Bystander-N2 outgroup vs ingroup | 0.348 | 0.960 | -1.534 | 2.230 | 0.717 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 1.647 | 0.770 | 0.138 | 3.155 | 0.032* |
| Empathy: Personal distress x Bystander-N1 outgroup vs ingroup | 0.501 | 0.827 | -1.120 | 2.122 | 0.545 |
| Empathy: Personal distress x Bystander-N2 outgroup vs ingroup | 0.948 | 0.788 | -0.597 | 2.493 | 0.229 |
| Tobit log-scale | 2.322 | 0.057 | 2.210 | 2.433 | <0.001*** |

El modelo H3 Bystander muestra evidencia focal para 8 términos de hipótesis. Empathy: Personal distress x Bystander-victim outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 1.65, p = 0.032*). Victim-N2 outgroup vs ingroup se asocia con menor judgement predicho (estimate = -2.32, p = 0.057+). Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 2.83, p = 0.072+). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

Recordatorio H4: el termino legacy `accept_target` corresponde al nombre operativo activo `decision_target`, y `accept_other` corresponde a `decision_other`; ambos se refieren a roles dinamicos `target`/`other` por fila, no a identidades fijas N1/N2.

## H4 Victim coefficient table

**Table 22. H4 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 9.771 | 2.575 | 4.723 | 14.819 | <0.001*** |
| Target accepted | -16.984 | 1.072 | -19.086 | -14.882 | <0.001*** |
| Other negotiator accepted | -3.951 | 0.705 | -5.332 | -2.570 | <0.001*** |
| Age | 0.042 | 0.102 | -0.158 | 0.242 | 0.681 |
| Socioeconomic status | 0.284 | 0.273 | -0.251 | 0.819 | 0.298 |
| Woman participant | 0.464 | 0.548 | -0.611 | 1.539 | 0.398 |
| Participant faculty: Engineering vs Humanities | 1.364 | 0.595 | 0.197 | 2.531 | 0.022* |
| Target accepted x Other accepted | 4.558 | 0.772 | 3.044 | 6.071 | <0.001*** |
| Tobit log-scale | 2.032 | 0.051 | 1.932 | 2.132 | <0.001*** |

El modelo H4 Victim muestra evidencia focal para 3 términos de hipótesis. Target accepted se asocia con menor judgement predicho (estimate = -16.98, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.56, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -3.95, p = <0.001***). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H4 Bystander coefficient table

**Table 23. H4 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 7.699 | 2.718 | 2.371 | 13.026 | 0.005** |
| Target accepted | -15.354 | 0.967 | -17.249 | -13.459 | <0.001*** |
| Other negotiator accepted | -4.262 | 0.662 | -5.559 | -2.965 | <0.001*** |
| Age | 0.164 | 0.094 | -0.020 | 0.349 | 0.081+ |
| Socioeconomic status | 0.206 | 0.246 | -0.276 | 0.689 | 0.402 |
| Woman participant | 0.098 | 0.543 | -0.967 | 1.164 | 0.856 |
| Participant faculty: Engineering vs Humanities | 1.174 | 0.515 | 0.165 | 2.183 | 0.023* |
| Target accepted x Other accepted | 4.849 | 0.769 | 3.342 | 6.357 | <0.001*** |
| Tobit log-scale | 1.934 | 0.050 | 1.835 | 2.033 | <0.001*** |

El modelo H4 Bystander muestra evidencia focal para 3 términos de hipótesis. Target accepted se asocia con menor judgement predicho (estimate = -15.35, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -4.26, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.85, p = <0.001***). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

Recordatorio H5: `N1`/`N2` son slots estructurales reconstruidos (no aliases fijos de `target`/`other`), `group_target`/`group_other` son campos legacy de auditoria, y `accept_target`/`accept_other` se mapean a `decision_target`/`decision_other` para roles dinamicos por fila.

## H5 Victim coefficient table

**Table 24. H5 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 4.069 | 3.411 | -2.617 | 10.755 | 0.233 |
| Empathy: Fantasy | 1.469 | 0.656 | 0.184 | 2.755 | 0.025* |
| Empathy: Empathic concern | 0.420 | 0.899 | -1.342 | 2.183 | 0.640 |
| Empathy: Perspective taking | 1.168 | 0.766 | -0.334 | 2.670 | 0.127 |
| Empathy: Personal distress | -0.316 | 0.716 | -1.719 | 1.087 | 0.659 |
| Victim-N1 outgroup vs ingroup | 1.766 | 1.806 | -1.774 | 5.305 | 0.328 |
| Victim-N2 outgroup vs ingroup | 4.155 | 2.198 | -0.153 | 8.462 | 0.059+ |
| N1/N2 same faculty vs different | -0.299 | 0.574 | -1.424 | 0.826 | 0.603 |
| Target accepted | -16.910 | 1.071 | -19.010 | -14.810 | <0.001*** |
| Other negotiator accepted | -3.881 | 0.699 | -5.251 | -2.512 | <0.001*** |
| Age | 0.016 | 0.100 | -0.180 | 0.212 | 0.870 |
| Socioeconomic status | 0.219 | 0.267 | -0.305 | 0.743 | 0.412 |
| Woman participant | 0.444 | 0.572 | -0.677 | 1.564 | 0.438 |
| Participant faculty: Engineering vs Humanities | 1.495 | 0.610 | 0.299 | 2.690 | 0.014* |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | -0.161 | 1.217 | -2.547 | 2.224 | 0.894 |
| Empathy: Fantasy x Victim-N1 outgroup vs ingroup | -0.826 | 0.468 | -1.744 | 0.091 | 0.077+ |
| Empathy: Fantasy x Victim-N2 outgroup vs ingroup | -0.632 | 0.578 | -1.764 | 0.500 | 0.274 |
| Empathy: Empathic concern x Victim-N1 outgroup vs ingroup | -0.045 | 0.684 | -1.386 | 1.296 | 0.948 |
| Empathy: Empathic concern x Victim-N2 outgroup vs ingroup | -0.784 | 0.849 | -2.447 | 0.879 | 0.356 |
| Empathy: Perspective taking x Victim-N1 outgroup vs ingroup | -0.058 | 0.596 | -1.227 | 1.111 | 0.922 |
| Empathy: Perspective taking x Victim-N2 outgroup vs ingroup | -0.276 | 0.742 | -1.731 | 1.179 | 0.710 |
| Empathy: Personal distress x Victim-N1 outgroup vs ingroup | 0.026 | 0.572 | -1.095 | 1.147 | 0.964 |
| Empathy: Personal distress x Victim-N2 outgroup vs ingroup | -0.139 | 0.541 | -1.199 | 0.921 | 0.797 |
| Target accepted x Other accepted | 4.445 | 0.762 | 2.950 | 5.939 | <0.001*** |
| Tobit log-scale | 2.024 | 0.051 | 1.924 | 2.124 | <0.001*** |

El modelo H5 Victim muestra evidencia focal para 6 términos de hipótesis. Target accepted se asocia con menor judgement predicho (estimate = -16.91, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.44, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -3.88, p = <0.001***). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H5 Bystander coefficient table

**Table 25. H5 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 10.158 | 3.366 | 3.561 | 16.756 | 0.003** |
| Empathy: Fantasy | 0.737 | 0.674 | -0.583 | 2.058 | 0.274 |
| Empathy: Empathic concern | -0.705 | 0.860 | -2.391 | 0.981 | 0.412 |
| Empathy: Perspective taking | -0.680 | 0.731 | -2.112 | 0.753 | 0.352 |
| Empathy: Personal distress | -0.178 | 0.699 | -1.549 | 1.192 | 0.799 |
| Bystander-victim outgroup vs ingroup | -1.983 | 1.951 | -5.807 | 1.840 | 0.309 |
| Bystander-N1 outgroup vs ingroup | -0.272 | 1.921 | -4.037 | 3.494 | 0.887 |
| Bystander-N2 outgroup vs ingroup | -1.351 | 1.831 | -4.939 | 2.237 | 0.461 |
| Victim-N1 outgroup vs ingroup | -1.543 | 0.774 | -3.061 | -0.026 | 0.046* |
| Victim-N2 outgroup vs ingroup | -1.589 | 0.759 | -3.076 | -0.103 | 0.036* |
| N1/N2 same faculty vs different | -0.105 | 0.564 | -1.210 | 1.001 | 0.853 |
| Target accepted | -15.384 | 0.962 | -17.270 | -13.498 | <0.001*** |
| Other negotiator accepted | -4.305 | 0.665 | -5.609 | -3.001 | <0.001*** |
| Age | 0.184 | 0.097 | -0.006 | 0.375 | 0.058+ |
| Socioeconomic status | 0.168 | 0.248 | -0.317 | 0.654 | 0.497 |
| Woman participant | 0.040 | 0.557 | -1.051 | 1.132 | 0.942 |
| Participant faculty: Engineering vs Humanities | 1.064 | 0.516 | 0.053 | 2.075 | 0.039* |
| Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup | -1.307 | 1.011 | -3.289 | 0.675 | 0.196 |
| Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup | 2.410 | 1.069 | 0.315 | 4.505 | 0.024* |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.143 | 0.507 | -2.137 | -0.149 | 0.024* |
| Empathy: Fantasy x Bystander-N1 outgroup vs ingroup | 0.119 | 0.515 | -0.890 | 1.127 | 0.818 |
| Empathy: Fantasy x Bystander-N2 outgroup vs ingroup | -0.133 | 0.580 | -1.270 | 1.004 | 0.818 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 0.698 | 0.812 | -0.894 | 2.289 | 0.390 |
| Empathy: Empathic concern x Bystander-N1 outgroup vs ingroup | -0.033 | 0.666 | -1.338 | 1.272 | 0.960 |
| Empathy: Empathic concern x Bystander-N2 outgroup vs ingroup | -0.162 | 0.786 | -1.703 | 1.378 | 0.836 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.649 | 0.618 | -0.561 | 1.860 | 0.293 |
| Empathy: Perspective taking x Bystander-N1 outgroup vs ingroup | 0.542 | 0.662 | -0.756 | 1.840 | 0.413 |
| Empathy: Perspective taking x Bystander-N2 outgroup vs ingroup | 0.714 | 0.682 | -0.624 | 2.051 | 0.296 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 0.605 | 0.608 | -0.588 | 1.798 | 0.320 |
| Empathy: Personal distress x Bystander-N1 outgroup vs ingroup | -0.191 | 0.567 | -1.302 | 0.919 | 0.736 |
| Empathy: Personal distress x Bystander-N2 outgroup vs ingroup | 0.626 | 0.541 | -0.434 | 1.685 | 0.247 |
| Target accepted x Other accepted | 4.891 | 0.791 | 3.340 | 6.442 | <0.001*** |
| Tobit log-scale | 1.928 | 0.050 | 1.830 | 2.026 | <0.001*** |

El modelo H5 Bystander muestra evidencia focal para 7 términos de hipótesis. Target accepted se asocia con menor judgement predicho (estimate = -15.38, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -4.31, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.89, p = <0.001***). Los dummies de sesión permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

# Lista de verificacion de cumplimiento

**Table 26. Lista de verificacion de cumplimiento del pipeline**

| criterion | status | evidence |
| --- | --- | --- |
| a) usa judgement | YES | Todas las formulas modelan judgement de forma directa. |
| b) estructura repetida por id | YES | Todos los modelos Tobit ajustados usan errores estandar robustos por cluster de participante mediante cluster = id. |
| c) agrupacion por sesion | YES | La rama Tobit activa usa factor(session) en cada formula y documenta esa eleccion de forma explicita en lugar de afirmar un intercepto aleatorio de sesion. |
| d) el pipeline no introduce doble conteo | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) Victim y Bystander tratados de forma diferente | YES | Las formulas especificas por rol se estiman por separado y H2/H3/H5 usan bloques relacionales diferentes para Victim y Bystander. |
| f) decision_target y decision_other incluidos donde corresponde | YES | H4 y H5 incluyen decision_target, decision_other y su interaccion. |
| g) sociodemograficos incluidos en cada modelo de hipotesis | YES | Cada formula H1-H5 retiene age, ses, sex_female y faculty_player_factor. |


# Correcciones frente a notas desactualizadas

La rama productiva actual reemplaza notas previas que usaban `control_hidden` para el codigo de negociador `0`, restringian H3 a terminos de empatia solo aditivos, o implicaban que el estimador principal usaba `(1|session)`. El repositorio ahora documenta de forma directa el estimador implementado y el diseno autoritativo especifico por rol.

# Limitaciones

La rama productiva no ajusta un Tobit multinivel completo con interceptos aleatorios explícitos de participante y sesión dentro del mismo estimador.
Celdas relacionales escasas pueden producir matrices de diseño con deficiencia de rango, por lo que algunos contrastes de interacción se descartan automáticamente y se reportan como tales.
Las figuras dinámicas visualizan predicciones implicadas por el modelo a partir de los ajustes Tobit primarios guardados y deben interpretarse junto con las tablas de coeficientes, no como efectos causales autónomos.

# Discusion

Los resultados de empatia apuntan a un mecanismo en el que `judgement` no responde solo a resultados, sino tambien a sensibilidad social disposicional. Cuando las pendientes de empatia varian entre relaciones ingroup y outgroup, los hallazgos respaldan la expectativa teorica de que la orientacion empatica esta filtrada por cercania social percibida y no opera como un amplificador moral uniforme.

Los resultados de ingroup/outgroup importan porque el experimento inserta `judgement` en una estructura relacional con dos negociadores y lazos sociales dependientes del rol. Por eso los modelos de Victim y Bystander no son intercambiables. En Victim, la pregunta central es como se relacionan el negociador evaluado y su contraparte con la persona afectada. En Bystander, el participante es externo al evento de dano y la evaluacion puede depender de un mapa mas amplio con relaciones bystander-victim, bystander-negotiator y victim-negotiator.

Los terminos de decision afinan la interpretacion moral del outcome enfocado en target. `decision_target` captura que hizo el negociador evaluado, `decision_other` captura la decision de la contraparte y su interaccion prueba si el significado de una decision cambia cuando el otro negociador acepta o rechaza. Esto es sustantivamente relevante porque la evaluacion moral del target puede responder tanto a la accion individual como al resultado conjunto de la negociacion.

En terminos practicos, los resultados aportan a etica de negociacion y evaluacion de terceros. Si `judgement` cambia con empatia, cercania de facultad y patrones conjuntos de decision, entonces la justicia percibida en negociaciones daninas esta moldeada por contexto disposicional y relacional. Esto tiene implicaciones para como observadores asignan culpa, justifican conducta estrategica o infieren responsabilidad desde accion coordinada.

Metodologicamente, el estimador activo es un Tobit de dos lados con errores estandar robustos agrupados por participante y efectos fijos de sesion. Es una decision productiva honesta para un outcome acotado con medidas repetidas, porque preserva la estructura Tobit de `judgement`, ajusta dependencia intra-participante via `cluster = id`, y controla desplazamientos por sesion con `factor(session)`. Al mismo tiempo, no equivale a un Tobit mixto completo con interceptos aleatorios de participante y sesion.

Las principales limitaciones se desprenden de esa eleccion del estimador y de la escasez en algunas celdas relacionales. La rama productiva no estima un Tobit mixto completo, algunos contrastes de interaccion pueden descartarse en subconjuntos con deficiencia de rango, y la lectura sustantiva debe mantenerse anclada en tablas de coeficientes y figuras implicadas por el modelo, no en p-values aislados. Trabajo futuro deberia comparar estos estimados con modelos censurados multinivel estables, evaluar interacciones alternativas por rol y probar replicacion en otros contextos institucionales o culturales.

# Nota final de auditoria

El proyecto refleja fielmente el diseno autoritativo en su rama productiva: `judgement` es el outcome, el archivo long se mantiene como fuente unica, una fila sigue siendo una observacion real, se usan definiciones de grupo especificas por rol, `decision_target` y `decision_other` se modelan donde corresponde, y las mediciones repetidas se manejan con inferencia robusta por cluster de participante y `factor(session)`.

No quedo advertencia de deficiencia de rango en el resumen de ajuste guardado para esta corrida.

Limitacion del estimador: el estimador productivo sigue siendo un Tobit de dos lados con `factor(session)` y errores estandar robustos por cluster en `id`, no un Tobit de efectos mixtos completo con interceptos aleatorios de participante y sesion.

# Apendice tecnico: mapa de codigos de predictores

**Table 27. Mapa predictor-a-codigo (apendice tecnico)**

| Predictor | Code |
| --- | --- |
| iri_fs | FS |
| iri_ec | EC |
| iri_pt | PT |
| iri_pd | PD |
| victim_N1_groupingroup | V-N1 In |
| victim_N1_groupoutgroup | V-N1 Out |
| victim_N2_groupingroup | V-N2 In |
| victim_N2_groupoutgroup | V-N2 Out |
| bystander_victim_groupoutgroup | B-V Out |
| bystander_N1_groupingroup | B-N1 In |
| bystander_N1_groupoutgroup | B-N1 Out |
| bystander_N2_groupingroup | B-N2 In |
| bystander_N2_groupoutgroup | B-N2 Out |
| N1_N2_same_facultysame | SameFac |
| iri_fs:victim_N1_groupoutgroup | FS x V-N1 Out |
| iri_ec:victim_N2_groupoutgroup | EC x V-N2 Out |
| iri_pt:bystander_victim_groupoutgroup | PT x B-V Out |
| iri_pd:bystander_N1_groupoutgroup | PD x B-N1 Out |
| decision_target | Target Acc |
| decision_other | Other Acc |
| decision_target:decision_other | Target x Other |
| faculty_player_factorEngineering | Eng part. |
| sex_female | Woman |
| age | Age |
| ses | SES |


# Conclusiones

Las conclusiones de este reporte deben leerse como asociacionales y no causales. En este informe, `judgement` fue estimado con un modelo Tobit de dos lados que maneja censura, observaciones repetidas por participante y ajuste de sesion mediante `factor(session)` con inferencia robusta agrupada por participante.

Esta seccion de cierre referencia la estructura completa del reporte. Debe leerse junto con los resumenes de ecuaciones H1-H5, el resumen de significancia por rol, las tablas completas de coeficientes con interpretacion y las figuras guiadas por significancia.

## Sintesis por hipotesis

### H1

H1 evalua empatia como predictor directo de `judgement` reteniendo controles comunes. Para referencia cruzada, ver el resumen de ecuaciones H1 y las tablas y figuras especificas por rol de H1. En el rol Victim,
el resumen de soporte especifico por rol destaco: Empathy: Perspective taking**.
En el rol Bystander,
ningun termino focal alcanzo el umbral p < 0.10 en la tabla de resumen especifica por rol.
En conjunto, H1 sugiere que la posicion de rol condiciona que tan claramente aparece empatia en el patron ajustado de `judgement`.

### H2

Recordatorio H2: `N1`/`N2` son slots estructurales reconstruidos dentro de cada fila, no aliases fijos de `target`/`other`; `group_target` y `group_other` son campos legacy de fuente/auditoria, mientras que los modelos activos de H2 usan predictores relacionales reconstruidos.

H2 se enfoca en estructura ingroup/outgroup especifica por rol. Para referencia cruzada, ver el resumen de ecuaciones H2 y las tablas y figuras especificas por rol de H2. En el rol Victim,
ningun termino focal alcanzo el umbral p < 0.10 en la tabla de resumen especifica por rol.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+.
Esta comparacion indica que las claves de alineacion relacional no son igual de informativas entre roles y pueden volverse mas visibles cuando participantes evaluan como observadores y no como actores directamente afectados.

### H3

H3 combina empatia, estructura de grupo e interacciones. Para referencia cruzada, ver el resumen de ecuaciones H3, las tablas de coeficientes H3 y las figuras de interaccion H3. En el rol Victim,
el resumen de soporte especifico por rol destaco: Empathy: Fantasy*; Empathy: Perspective taking+.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Empathy: Empathic concern+; Empathy: Personal distress+; Victim-N1 outgroup vs ingroup+; Victim-N2 outgroup vs ingroup+; Bystander-N1 outgroup vs ingroup x Bystander-N2 outgroup vs ingroup+; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup+; Empathy: Fantasy x Bystander-victim outgroup vs ingroup+; Empathy: Personal distress x Bystander-victim outgroup vs ingroup*.
La evidencia de H3 debe leerse como una prueba de moderacion contextual: empatia no necesariamente opera como una pendiente uniforme cuando cambia la distancia social.

### H4

Recordatorio H4: el termino legacy `accept_target` corresponde al nombre operativo activo `decision_target`, y `accept_other` corresponde a `decision_other`; ambos se refieren a roles dinamicos `target`/`other` por fila, no a identidades fijas N1/N2.

H4 prueba terminos de decision de forma directa mediante `decision_target`, `decision_other` y su interaccion. Para referencia cruzada, ver el resumen de ecuaciones H4 y las tablas y figuras de significancia especificas por rol de H4. En el rol Victim,
el resumen de soporte especifico por rol destaco: Target accepted***; Other negotiator accepted***; Target accepted x Other accepted***.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Target accepted***; Other negotiator accepted***; Target accepted x Other accepted***.
En ambos roles, H4 suele ser donde el mecanismo decisional se ve con mayor claridad, porque el juicio al target esta condicionado explicitamente por resultados conjuntos de negociacion.

### H5

Recordatorio H5: `N1`/`N2` son slots estructurales reconstruidos (no aliases fijos de `target`/`other`), `group_target`/`group_other` son campos legacy de auditoria, y `accept_target`/`accept_other` se mapean a `decision_target`/`decision_other` para roles dinamicos por fila.

H5 es la especificacion integrada que combina empatia, terminos relacionales, decisiones e interacciones. Para referencia cruzada, ver el resumen de ecuaciones H5, las tablas de coeficientes H5 y las figuras de significancia H5. En el rol Victim,
el resumen de soporte especifico por rol destaco: Empathy: Fantasy*; Victim-N2 outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-N1 outgroup vs ingroup+; Target accepted x Other accepted***.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Victim-N1 outgroup vs ingroup*; Victim-N2 outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Victim-N1 outgroup vs ingroup x Victim-N2 outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted***.
H5 debe leerse como sintesis y no como reemplazo de hipotesis previas: muestra como componentes disposicionales, relacionales y decisionales coexisten en un mismo modelo.

## Interpretacion global

Tomadas en conjunto, las cinco hipotesis indican que `judgement` en este experimento es multimecanismo y no unidimensional. Terminos de empatia pueden importar, alineacion relacional puede importar, y terminos de decision pueden importar fuertemente, pero su visibilidad cambia por rol y por contexto de modelo.

En terminos practicos, el reporte respalda una lectura contingente al rol: el juicio en Victim conserva contenido disposicional mas fuerte en algunas especificaciones, mientras el juicio en Bystander suele depender mas del contexto relacional, y ambos roles permanecen sensibles a las decisiones conjuntas de los negociadores.

