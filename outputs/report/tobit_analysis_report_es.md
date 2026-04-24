---
title: "Reporte de Trabajo sobre Juicio Moral bajo Modelos Tobit de Dos Lados"
author: "Leonardo H. Talero-Sarmiento"
date: "2026-04-23 21:26:17"
numbersections: true
---

Esta corrida usa `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` como unica fuente analitica y preserva cada fila importada como una observacion real de judgement. El estimador productivo es un Tobit de dos lados ajustado con `survival::survreg`, usando censura bilateral en `-9` y `9`, errores estandar robustos por cluster de participante via `cluster = id`, y `factor(session)` en cada formula activa.

# Entendiendo la estrategia de modelado

El propÃƒÂ³sito del pipeline es explicar cÃƒÂ³mo los participantes asignan judgement moral a un negociador focal dentro de un entorno experimental estructurado. El objetivo no se limita a describir promedios; busca estimar cÃƒÂ³mo cambia `judgement` en funciÃƒÂ³n de empatÃƒÂ­a, alineaciÃƒÂ³n de grupo, decisiones de negociaciÃƒÂ³n y estructura relacional especÃƒÂ­fica por rol. Como cada participante aporta evaluaciones repetidas en mÃƒÂºltiples escenarios y targets, la estrategia debe cumplir tres condiciones: preservar una fila por observaciÃƒÂ³n real, respetar el carÃƒÂ¡cter acotado del outcome y ajustar la dependencia intra-participante. Por ello, la rama productiva usa un Tobit de dos lados con inferencia robusta por cluster de participante y ajuste por sesiÃƒÂ³n.

La necesidad del Tobit proviene de la naturaleza de la variable dependiente. `judgement` se interpreta como continua, pero estÃƒÂ¡ acotada por diseÃƒÂ±o de mediciÃƒÂ³n. Los valores extremos son lÃƒÂ­mites de la escala, no realizaciones no restringidas. Un modelo lineal estÃƒÂ¡ndar asume un outcome potencialmente no acotado, lo cual no es apropiado aquÃƒÂ­. El enfoque Tobit modela una evaluaciÃƒÂ³n moral latente, denotada como `y_i^*`, observada a travÃƒÂ©s de una puntuaciÃƒÂ³n acotada:

$$
y_i^* = X_i\beta + \varepsilon_i
$$

y

$$
judgement_i = \max(-9, \min(9, y_i^*)).
$$

Bajo esta especificaciÃƒÂ³n, el modelo representa valores interiores, acumulaciÃƒÂ³n en el lÃƒÂ­mite inferior y acumulaciÃƒÂ³n en el lÃƒÂ­mite superior. En este contexto, censura no significa datos faltantes; significa que la observaciÃƒÂ³n queda registrada en el lÃƒÂ­mite de la escala cuando la evaluaciÃƒÂ³n latente excede ese rango.

El segundo reto metodolÃƒÂ³gico es la estructura de medidas repetidas. Cada participante contribuye mÃƒÂºltiples filas y, por tanto, las observaciones no son independientes. Ignorar esto tenderÃƒÂ­a a subestimar errores estÃƒÂ¡ndar y sobrerreportar significancia. La rama actual lo aborda con errores estÃƒÂ¡ndar robustos agrupados por `id`. AdemÃƒÂ¡s, se incorpora sesiÃƒÂ³n con `factor(session)` para absorber desplazamientos sistemÃƒÂ¡ticos entre sesiones. En esta implementaciÃƒÂ³n, sesiÃƒÂ³n se modela como ajuste de efectos fijos y no como intercepto aleatorio.

Los predictores se organizan en bloques teÃƒÂ³ricos. El primero contiene dimensiones de empatÃƒÂ­a (`iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`) y fundamenta H1. El segundo captura estructura relacional de ingroup/outgroup por rol y fundamenta H2. El bloque de aceptaciÃƒÂ³n (`accept_target`, `accept_other` y su interacciÃƒÂ³n) entra como ajuste transversal en H1-H5 y como foco principal de H4. Todos los modelos incluyen controles sociodemogrÃƒÂ¡ficos.

Las interacciones son clave porque los efectos aditivos no siempre capturan la lÃƒÂ³gica experimental. En H3, interacciones empatÃƒÂ­a-por-grupo evalÃƒÂºan si el efecto de empatÃƒÂ­a depende de la alineaciÃƒÂ³n social. En H4 y H5, `accept_target:accept_other` evalÃƒÂºa si el significado moral de una decisiÃƒÂ³n depende de la decisiÃƒÂ³n de la contraparte.

La distinciÃƒÂ³n entre vÃƒÂ­ctima y bystander es central. Los modelos de vÃƒÂ­ctima se enfocan en alineaciÃƒÂ³n vÃƒÂ­ctima-negociador. Los de bystander requieren un mapa mÃƒÂ¡s amplio que incluye relaciones bystander-vÃƒÂ­ctima, bystander-negociador y vÃƒÂ­ctima-negociador. Por eso las especificaciones por rol no son intercambiables.

Las cinco familias de hipÃƒÂ³tesis siguen esa estructura: H1 (empatÃƒÂ­a), H2 (alineaciÃƒÂ³n de grupo), H3 (empatÃƒÂ­a + grupo + interacciones), H4 (decisiones y su interacciÃƒÂ³n), H5 (modelo integrado).

Un principio clave del flujo es que una fila sigue siendo una observacion real de target-judgement. No se duplican filas para crear pseudo-observaciones por negociador. En su lugar, el contexto relacional de target, other, victima y bystander se conserva dentro de cada fila existente.

En conjunto, la estrategia productiva respeta la naturaleza acotada del outcome, preserva el diseÃƒÂ±o observacional long, ajusta la dependencia por participante, controla heterogeneidad por sesiÃƒÂ³n, separa mecanismos de vÃƒÂ­ctima y bystander, y mapea directamente sobre la arquitectura teÃƒÂ³rica H1-H5. A la vez, no equivale a un Tobit multinivel completo con interceptos aleatorios de participante y sesiÃƒÂ³n.

NA

# Puente semantico de nombres y mapeo por fila

Puente de nombres fuente/legacy: `decision_target` -> nombre operativo activo `accept_target`; `decision_other` -> nombre operativo activo `accept_other`.

Semantica por fila: `target` y `other` son roles dinamicos por observacion; todos los terminos analiticos activos del reporte se expresan directamente en ese par.

**Table 1. Mapeo de decision por fila desde target/other dinamicos hacia mapeos estructurales legacy**

| rule | expected_mapping | rows_in_scope | rows_following_rule | status |
| --- | --- | --- | --- | --- |
| target == 1 | Judged actor = target code 1, counterpart = other code 2; judged decision is `accept_target`, counterpart decision is `accept_other`. | 2430 | 2430 | PASS |
| target == 2 | Judged actor = target code 2, counterpart = other code 1; judged decision is `accept_target`, counterpart decision is `accept_other`. | 2430 | 2430 | PASS |


# Descripcion del dataset y de la muestra

El reporte usa el dataset experimental consolidado en formato long como ÃƒÂºnica fuente analÃƒÂ­tica.
Cada participante aporta en principio 20 filas de judgement: diez escenarios multiplicados por dos evaluaciones de negociadores target.
Cada fila importada se mantiene como una observacion real de judgement sobre el negociador target, enriquecida con contexto relacional de target, other, victima y bystander, sin duplicacion de filas.
Se evita doble conteo porque target y other se mantienen dentro de cada fila existente, en lugar de expandir el archivo en observaciones duplicadas por negociador.
Los anÃƒÂ¡lisis de vÃƒÂ­ctima y bystander se estiman por separado para que la codificaciÃƒÂ³n relacional siga la lÃƒÂ³gica especÃƒÂ­fica de cada rol.

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
| y* | Tendencia latente de juicio subyacente a la observaciÃƒÂ³n censurada del Tobit. |
| iri_fs / iri_ec / iri_pt / iri_pd | Dimensiones de empatÃƒÂ­a IRI: fantasy, empathic concern, perspective taking y personal distress. |
| target (row-dynamic) | Negociador evaluado en esa fila; este rol es dinÃƒÂ¡mico y se define por el codigo `target` de esa observacion. |
| other (row-dynamic counterpart) | Negociador contraparte en ese mismo contexto de fila (actor no target). |
| target / other (analytical pair) | Par analitico target/other usado para modelado relacional sin fijar identidades estructurales por negociador. |
| accept_target | Indicador de si el negociador target dinÃƒÂ¡mico por fila aceptÃƒÂ³ el trato daÃƒÂ±ino; nombre operativo activo con puente legacy desde decision_target. |
| accept_other | Indicador de si el negociador other dinÃƒÂ¡mico por fila aceptÃƒÂ³ el trato daÃƒÂ±ino; nombre operativo activo con puente legacy desde decision_other. |
| decision_target / decision_other (legacy source) | Nombres de columnas en el archivo fuente original; se conservan para compatibilidad y auditoria, pero la capa analitica activa usa `accept_target` y `accept_other`. |
| victim_target_group / victim_other_group | Relaciones especificas de victima con target y other, con ingroup definido por coincidencia de facultad incluyendo control-control. |
| bystander_victim_group / bystander_target_group / bystander_other_group | Factores relacionales del lado bystander para la vÃƒÂ­ctima y ambos negociadores, tambiÃƒÂ©n con coincidencia de facultad como ingroup. |
| group_target / group_other (legacy audit) | Campos de agrupaciÃƒÂ³n legacy de la fuente, retenidos para trazabilidad; no se usan directamente en las fÃƒÂ³rmulas activas H2/H3/H5. |
| target_other_same_faculty | Termino de contexto que indica si target y other comparten facultad. |
| factor(session) | Efectos fijos de sesiÃƒÂ³n incluidos directamente en cada fÃƒÂ³rmula ajustada. |
| cluster = id | AgrupaciÃƒÂ³n a nivel participante usada para errores estÃƒÂ¡ndar robustos y ajuste por medidas repetidas. |
| Log(scale) | ParÃƒÂ¡metro Tobit log-scale estimado que resume la dispersiÃƒÂ³n residual latente. |

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
| FS | DimensiÃƒÂ³n de empatÃƒÂ­a fantasy. |
| EC | DimensiÃƒÂ³n de empatÃƒÂ­a empathic concern. |
| PT | DimensiÃƒÂ³n de empatÃƒÂ­a perspective taking. |
| PD | DimensiÃƒÂ³n de empatÃƒÂ­a personal distress. |
| V-Tgt In | La victima y target pertenecen a la misma facultad. |
| V-Tgt Out | La victima y target pertenecen a facultades diferentes. |
| V-Oth In | La victima y other pertenecen a la misma facultad. |
| V-Oth Out | La victima y other pertenecen a facultades diferentes. |
| B-V Out | Bystander y vÃƒÂ­ctima pertenecen a facultades diferentes. |
| B-Tgt In | Bystander y target pertenecen a la misma facultad. |
| B-Tgt Out | Bystander y target pertenecen a facultades diferentes. |
| B-Oth In | Bystander y other pertenecen a la misma facultad. |
| B-Oth Out | Bystander y other pertenecen a facultades diferentes. |
| SameFac | target y other comparten pertenencia de facultad. |
| FS x V-Tgt Out | Diferencia de pendiente de fantasy cuando victim-target es outgroup frente a ingroup. |
| EC x V-Oth Out | Diferencia de pendiente de empathic concern cuando victim-other es outgroup frente a ingroup. |
| PT x B-V Out | Diferencia de pendiente de perspective taking cuando la relaciÃƒÂ³n bystander-victim es outgroup frente a ingroup. |
| PD x B-Tgt Out | Diferencia de pendiente de personal distress cuando la relacion bystander-target es outgroup frente a ingroup. |
| Target Acc | El negociador target dinÃƒÂ¡mico por fila aceptÃƒÂ³ el trato daÃƒÂ±ino (nombre fuente legacy: decision_target). |
| Other Acc | El negociador contraparte dinÃƒÂ¡mico por fila aceptÃƒÂ³ el trato daÃƒÂ±ino (nombre fuente legacy: decision_other). |
| Target x Other | Efecto conjunto de decisiones cuando se consideran simultÃƒÂ¡neamente las decisiones de ambos negociadores. |
| Eng part. | El participante pertenece a Engineering, relativo a Humanities. |
| Woman | El participante es mujer. |
| Age | Edad del participante. |
| SES | Nivel socioeconÃƒÂ³mico del participante. |


Nota. Los contrastes de grupo se interpretan contra la linea base ingroup, salvo indicacion explicita en contrario.

El reporte mantiene referencias compactas de predictores en captions y narrativas de figuras, pero el glosario anterior es el mapeo autoritativo hacia las variables actuales del pipeline.

# Reglas de interpretacion de interacciones

1. Cuando una interacciÃƒÂ³n es estadÃƒÂ­sticamente relevante, los efectos principales deben leerse como el componente de lÃƒÂ­nea base de la relaciÃƒÂ³n y no como toda la historia sustantiva.
2. Las interacciones continuo-por-factor indican que la pendiente de empatÃƒÂ­a cambia segÃƒÂºn las condiciones relacionales.
3. Las interacciones factor-por-factor indican que el contexto conjunto difiere de lo esperable al sumar de forma independiente los dos contrastes principales.
4. La interacciÃƒÂ³n target-by-other en decisiones indica que el significado moral de la elecciÃƒÂ³n de un negociador depende de lo que hizo su contraparte.
5. Los efectos de sesiÃƒÂ³n son tÃƒÂ©rminos de ajuste y no se interpretan como mecanismos sustantivos del experimento.

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
H1 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy dimensions with the common accept\_target x accept\_other adjustment and sociodemographics. \\
H1 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy dimensions with the common accept\_target x accept\_other adjustment and sociodemographics. \\
H2 & Victim & victim\_target\_group  +  victim\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Victim-side ingroup/outgroup structure with the allowed target x other relational interaction and the common accept\_target x accept\_other adjustment. \\
H2 & Bystander & bystander\_victim\_group  +  bystander\_target\_group  +  bystander\_other\_group  +  victim\_target\_group  +  victim\_other\_group  +  bystander\_target\_group : bystander\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Bystander-side relational structure with explicit bystander-victim, bystander-target, bystander-other, target/other context terms, and the common accept\_target x accept\_other adjustment. \\
H3 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  victim\_target\_group  +  victim\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : victim\_target\_group  +  iri\_fs : victim\_other\_group  +  iri\_ec : victim\_target\_group  +  iri\_ec : victim\_other\_group  +  iri\_pt : victim\_target\_group  +  iri\_pt : victim\_other\_group  +  iri\_pd : victim\_target\_group  +  iri\_pd : victim\_other\_group  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy plus victim-side relational structure, including empathy x victim-target and empathy x victim-other interactions, with the common accept\_target x accept\_other adjustment. \\
H3 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  bystander\_victim\_group  +  bystander\_target\_group  +  bystander\_other\_group  +  victim\_target\_group  +  victim\_other\_group  +  bystander\_target\_group : bystander\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : bystander\_victim\_group  +  iri\_fs : bystander\_target\_group  +  iri\_fs : bystander\_other\_group  +  iri\_ec : bystander\_victim\_group  +  iri\_ec : bystander\_target\_group  +  iri\_ec : bystander\_other\_group  +  iri\_pt : bystander\_victim\_group  +  iri\_pt : bystander\_target\_group  +  iri\_pt : bystander\_other\_group  +  iri\_pd : bystander\_victim\_group  +  iri\_pd : bystander\_target\_group  +  iri\_pd : bystander\_other\_group  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Empathy plus bystander-side relational structure, including empathy x bystander-victim and empathy x bystander-target/other interactions, with the common accept\_target x accept\_other adjustment. \\
H4 & Victim & accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Terminos de aceptacion de target y other con su interaccion, mas sociodemograficos. \\
H4 & Bystander & accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Terminos de aceptacion de target y other con su interaccion, mas sociodemograficos. \\
H5 & Victim & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  victim\_target\_group  +  victim\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : victim\_target\_group  +  iri\_fs : victim\_other\_group  +  iri\_ec : victim\_target\_group  +  iri\_ec : victim\_other\_group  +  iri\_pt : victim\_target\_group  +  iri\_pt : victim\_other\_group  +  iri\_pd : victim\_target\_group  +  iri\_pd : victim\_other\_group  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Modelo integrado con empatia, relaciones del lado Victim, interacciones empatia x grupo, terminos de aceptacion y la interaccion target/other del lado Victim. \\
H5 & Bystander & iri\_fs  +  iri\_ec  +  iri\_pt  +  iri\_pd  +  bystander\_victim\_group  +  bystander\_target\_group  +  bystander\_other\_group  +  victim\_target\_group  +  victim\_other\_group  +  bystander\_target\_group : bystander\_other\_group  +  victim\_target\_group : victim\_other\_group  +  target\_other\_same\_faculty  +  iri\_fs : bystander\_victim\_group  +  iri\_fs : bystander\_target\_group  +  iri\_fs : bystander\_other\_group  +  iri\_ec : bystander\_victim\_group  +  iri\_ec : bystander\_target\_group  +  iri\_ec : bystander\_other\_group  +  iri\_pt : bystander\_victim\_group  +  iri\_pt : bystander\_target\_group  +  iri\_pt : bystander\_other\_group  +  iri\_pd : bystander\_victim\_group  +  iri\_pd : bystander\_target\_group  +  iri\_pd : bystander\_other\_group  +  accept\_target * accept\_other  +  age  +  ses  +  sex\_female  +  faculty\_player\_factor  +  factor(session) & Modelo integrado con empatia, relaciones del lado Bystander, interacciones empatia x grupo, terminos de aceptacion e interacciones relacionales target/other especificas por rol. \\
\bottomrule
\end{longtable}
\endgroup

Cualquier nota previa del repositorio que tratara el codigo de negociador `0` como algo distinto de la categoria explicita control, o que restringiera H3 a efectos aditivos, debe considerarse desactualizada. Las formulas activas siguientes son la especificacion autoritativa.

## H1

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## H2

`Victim`: `victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## H3

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:victim_target_group + iri_fs:victim_other_group + iri_ec:victim_target_group + iri_ec:victim_other_group + iri_pt:victim_target_group + iri_pt:victim_other_group + iri_pd:victim_target_group + iri_pd:victim_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group + iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group + iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group + iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## H4

`Victim`: `accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

## H5

`Victim`: `iri_fs + iri_ec + iri_pt + iri_pd + victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:victim_target_group + iri_fs:victim_other_group + iri_ec:victim_target_group + iri_ec:victim_other_group + iri_pt:victim_target_group + iri_pt:victim_other_group + iri_pd:victim_target_group + iri_pd:victim_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

`Bystander`: `iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group + iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group + iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group + iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session)`

# Fundamentos matematicos

El estimador principal es un Tobit de dos lados ajustado con `survival::survreg`.

$$y_i = \max(-9, \min(9, y_i^*))$$

$$y_i^* = \beta_0 + X_i\beta + \delta_{session(i)} + \varepsilon_i$$

donde `factor(session)` aporta efectos fijos de sesiÃƒÂ³n y los errores estÃƒÂ¡ndar robustos por cluster se calculan al nivel de participante mediante `cluster = id` con `robust = TRUE`.
Por tanto, este reporte trata sesiÃƒÂ³n como ajuste implementado de efecto fijo y no como intercepto aleatorio.

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
| victim_target_group | ingroup | 1630 |
| victim_target_group | outgroup | 3230 |
| victim_other_group | ingroup | 1630 |
| victim_other_group | outgroup | 3230 |
| bystander_victim_group | ingroup | 1212 |
| bystander_victim_group | outgroup | 1218 |
| bystander_target_group | ingroup | 805 |
| bystander_target_group | outgroup | 1625 |
| bystander_other_group | ingroup | 805 |
| bystander_other_group | outgroup | 1625 |
| target_other_same_faculty | different | 3276 |
| target_other_same_faculty | same | 1584 |

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

Esta figura muestra si la distribucion bruta y acotada de `judgement` cambia segun si el codigo de target es 1 o 2 dentro de escenarios Victim y Bystander.

![Distribuciones observadas de `judgement` por rol y decision del target.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_target_decision.png)

Esta figura aisla si la aceptacion o rechazo del propio target se asocia con perfiles brutos distintos de `judgement` dentro de cada rol.

![Distribuciones observadas de `judgement` por rol y decision de la contraparte.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_other_decision.png)

Esta figura muestra si `judgement` del target varia con la aceptacion o rechazo del otro negociador.

![Distribuciones observadas de `judgement` por rol y patron conjunto de decision.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_by_role_and_decision_pattern.png)

Esta figura muestra como cambia la distribucion de `judgement` enfocada en target a traves de los cuatro resultados conjuntos de negociacion en escenarios Victim y Bystander.

![Conteos observados de patrones de decision por rol.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_decision_pattern_by_role.png)

Esta figura resume con que frecuencia aparece cada patron conjunto de decision en los subconjuntos Victim y Bystander.

![Distribuciones de `judgement` del rol Victim a traves de pareamientos de facultad target x other.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_victim_target_other_faculty_grid.png)

Esta figura muestra como varia la distribucion bruta de `judgement` a traves del espacio relacional completo definido por el pareamiento de facultad entre target y other.

![Distribuciones de `judgement` del rol Bystander a traves de pareamientos de facultad target x other.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_target_other_faculty_grid.png)

Esta figura muestra como varia la distribucion bruta de `judgement` a traves del espacio relacional completo definido por el pareamiento de facultad entre target y other.

![Distribuciones de `judgement` del rol Victim a traves de combinaciones victim-target y victim-other de ingroup/outgroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_victim_group_grid.png)

Esta figura opcional destaca como varia el `judgement` bruto del rol Victim a traves de combinaciones ingroup/outgroup centradas en la victima.

![Distribuciones de `judgement` del rol Bystander a traves de combinaciones bystander-target y bystander-other de ingroup/outgroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_target_other_group_grid.png)

Esta figura opcional enfatiza combinaciones relacionales del lado Bystander ligadas directamente a la alineacion de grupo de target y other.

![Distribuciones de `judgement` del rol Bystander a traves de combinaciones victim-target y victim-other de ingroup/outgroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_judgement_distribution_bystander_victim_target_other_group_grid.png)

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
| H1 | 300 | 723 | 11062.700 | 11224.900 | 6.908 |
| H2 | 300 | 723 | 11065.800 | 11251.100 | 6.901 |
| H3 | 300 | 723 | 11076.700 | 11354.700 | 6.867 |
| H4 | 300 | 723 | 11060.300 | 11199.300 | 6.917 |
| H5 | 300 | 723 | 11076.700 | 11354.700 | 6.867 |

### Modelos Victim

**Table 13. Resumen de ajuste y censura para modelos Victim**

| H | L. cens. | U. cens. | AIC | BIC | Sigma |
| --- | --- | --- | --- | --- | --- |
| H1 | 377 | 744 | 10737.900 | 10900.100 | 7.593 |
| H2 | 377 | 744 | 10753.900 | 10916.100 | 7.624 |
| H3 | 377 | 744 | 10748.000 | 10979.700 | 7.566 |
| H4 | 377 | 744 | 10747.900 | 10886.900 | 7.626 |
| H5 | 377 | 744 | 10748.000 | 10979.700 | 7.566 |

# Resumen de significancia de hipotesis por rol

## Victim

**Table 14. Terminos de soporte focal Victim (p < 0.10)**

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Victim | Empathy: Perspective taking* |
| H2 | Victim | None below p < 0.10 |
| H3 | Victim | Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Empathy: Fantasy x Victim-other outgroup vs ingroup+ |
| H4 | Victim | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Victim | Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-other outgroup vs ingroup+; Target accepted x Other accepted*** |

## Bystander

**Table 15. Terminos de soporte focal Bystander (p < 0.10)**

| hypothesis | role | support |
| --- | --- | --- |
| H1 | Bystander | None below p < 0.10 |
| H2 | Bystander | Victim-target outgroup vs ingroup*; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup* |
| H3 | Bystander | Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup* |
| H4 | Bystander | Target accepted***; Other negotiator accepted***; Target accepted x Other accepted*** |
| H5 | Bystander | Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted*** |

# Figuras guiadas por significancia

## H1 Victim: Empathy: Perspective taking

![H1 Victim: predicciones implicadas por el modelo para Empathy: Perspective taking.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h1_victim_iri_pt.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H2 Bystander: Victim-target outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_target_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H2 Bystander: Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup

![H2 Bystander: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h2_bystander_victim_target_groupoutgroup_victim_other_groupoutg.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Victim: Empathy: Fantasy

![H3 Victim: predicciones implicadas por el modelo para Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_fs.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Victim: Victim-target outgroup vs ingroup

![H3 Victim: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_victim_target_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H3 Victim: Empathy: Fantasy x Victim-other outgroup vs ingroup

![H3 Victim: predicciones implicadas por el modelo para Empathy: Fantasy x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_victim_iri_fs_victim_other_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Bystander: Victim-target outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_target_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Victim-other outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_other_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H3 Bystander: Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_victim_target_groupoutgroup_victim_other_groupoutg.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H3 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H3 Bystander: predicciones implicadas por el modelo para Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h3_bystander_iri_fs_bystander_victim_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H4 Victim: Target accepted

![H4 Victim: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_accept_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Victim: Other negotiator accepted

![H4 Victim: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_accept_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Victim: Target accepted x Other accepted

![H4 Victim: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_victim_accept_target_accept_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H4 Bystander: Target accepted

![H4 Bystander: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_accept_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Bystander: Other negotiator accepted

![H4 Bystander: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_accept_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H4 Bystander: Target accepted x Other accepted

![H4 Bystander: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h4_bystander_accept_target_accept_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Victim: Empathy: Fantasy

![H5 Victim: predicciones implicadas por el modelo para Empathy: Fantasy.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Victim-target outgroup vs ingroup

![H5 Victim: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_victim_target_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Target accepted

![H5 Victim: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_accept_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Other negotiator accepted

![H5 Victim: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_accept_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Victim: Empathy: Fantasy x Victim-other outgroup vs ingroup

![H5 Victim: predicciones implicadas por el modelo para Empathy: Fantasy x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_iri_fs_victim_other_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Victim: Target accepted x Other accepted

![H5 Victim: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_victim_accept_target_accept_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Bystander: Victim-target outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_target_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Victim-other outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_other_groupoutgroup.png)

A lo largo del contraste mostrado, el modelo implica mayor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Target accepted

![H5 Bystander: predicciones implicadas por el modelo para Target accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_accept_target.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Other negotiator accepted

![H5 Bystander: predicciones implicadas por el modelo para Other negotiator accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_accept_other.png)

A lo largo del contraste mostrado, el modelo implica menor `judgement` predicho hacia el lado derecho del grafico.

## H5 Bystander: Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_victim_target_groupoutgroup_victim_other_groupoutg.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Bystander: Empathy: Fantasy x Bystander-victim outgroup vs ingroup

![H5 Bystander: predicciones implicadas por el modelo para Empathy: Fantasy x Bystander-victim outgroup vs ingroup.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_iri_fs_bystander_victim_groupoutgroup.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

## H5 Bystander: Target accepted x Other accepted

![H5 Bystander: predicciones implicadas por el modelo para Target accepted x Other accepted.](C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/figures/figure_h5_bystander_accept_target_accept_other.png)

Las lineas ajustadas y bandas sombreadas de confianza al 95% resumen como cambia `judgement` predicho a lo largo del termino focal, manteniendo las covariables restantes en su perfil de referencia.

# Tablas completas de coeficientes y resumen de interpretacion

## H1 Victim coefficient table

**Table 16. H1 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 7.872 | 2.742 | 2.497 | 13.246 | 0.004** |
| Empathy: Fantasy | 0.441 | 0.375 | -0.294 | 1.176 | 0.240 |
| Empathy: Empathic concern | -0.165 | 0.584 | -1.309 | 0.980 | 0.778 |
| Empathy: Perspective taking | 0.956 | 0.462 | 0.051 | 1.862 | 0.039* |
| Empathy: Personal distress | -0.358 | 0.450 | -1.241 | 0.524 | 0.426 |
| Target accepted | -16.916 | 1.072 | -19.016 | -14.816 | <0.001*** |
| Other negotiator accepted | -3.880 | 0.698 | -5.248 | -2.511 | <0.001*** |
| Age | 0.019 | 0.101 | -0.178 | 0.217 | 0.849 |
| Socioeconomic status | 0.240 | 0.267 | -0.283 | 0.763 | 0.368 |
| Woman participant | 0.437 | 0.576 | -0.693 | 1.567 | 0.448 |
| Participant faculty: Engineering vs Humanities | 1.370 | 0.609 | 0.177 | 2.563 | 0.024* |
| Target accepted x Other accepted | 4.487 | 0.767 | 2.984 | 5.989 | <0.001*** |
| Tobit log-scale | 2.027 | 0.051 | 1.927 | 2.128 | <0.001*** |

El modelo H1 Victim muestra evidencia focal para un tÃƒÂ©rminos de hipÃƒÂ³tesis. Empathy: Perspective taking se asocia con mayor judgement predicho (estimate = 0.96, p = 0.039*). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H1 Bystander coefficient table

**Table 17. H1 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 6.370 | 3.060 | 0.371 | 12.368 | 0.037* |
| Empathy: Fantasy | 0.191 | 0.359 | -0.513 | 0.895 | 0.595 |
| Empathy: Empathic concern | -0.527 | 0.522 | -1.551 | 0.497 | 0.313 |
| Empathy: Perspective taking | 0.542 | 0.462 | -0.364 | 1.449 | 0.241 |
| Empathy: Personal distress | 0.387 | 0.427 | -0.449 | 1.224 | 0.364 |
| Target accepted | -15.355 | 0.964 | -17.245 | -13.465 | <0.001*** |
| Other negotiator accepted | -4.265 | 0.660 | -5.559 | -2.972 | <0.001*** |
| Age | 0.182 | 0.098 | -0.011 | 0.375 | 0.065+ |
| Socioeconomic status | 0.195 | 0.244 | -0.283 | 0.673 | 0.424 |
| Woman participant | 0.012 | 0.556 | -1.079 | 1.102 | 0.983 |
| Participant faculty: Engineering vs Humanities | 1.048 | 0.518 | 0.032 | 2.064 | 0.043* |
| Target accepted x Other accepted | 4.832 | 0.764 | 3.334 | 6.329 | <0.001*** |
| Tobit log-scale | 1.933 | 0.050 | 1.834 | 2.032 | <0.001*** |

En el modelo H1 Bystander, ningÃƒÂºn tÃƒÂ©rmino focal de hipÃƒÂ³tesis alcanzÃƒÂ³ p < 0.10. Por ello, el reporte conserva la tabla de coeficientes para auditabilidad, pero no aÃƒÂ±ade una interpretaciÃƒÂ³n sustantiva guiada por significancia mÃƒÂ¡s allÃƒÂ¡ de los grÃƒÂ¡ficos descriptivos de predicciÃƒÂ³n.

Recordatorio H2: los predictores relacionales activos usan semantica `target`/`other` por fila; `group_target` y `group_other` permanecen como campos legacy de fuente/auditoria y no como terminos activos de H2.

## H2 Victim coefficient table

**Table 18. H2 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 10.104 | 2.661 | 4.888 | 15.320 | <0.001*** |
| Victim-target outgroup vs ingroup | 0.107 | 0.924 | -1.704 | 1.918 | 0.908 |
| Victim-other outgroup vs ingroup | -0.094 | 0.913 | -1.884 | 1.696 | 0.918 |
| Target/other same faculty vs different | -0.312 | 0.577 | -1.442 | 0.818 | 0.589 |
| Target accepted | -17.009 | 1.074 | -19.114 | -14.904 | <0.001*** |
| Other negotiator accepted | -3.967 | 0.708 | -5.355 | -2.580 | <0.001*** |
| Age | 0.040 | 0.102 | -0.160 | 0.240 | 0.694 |
| Socioeconomic status | 0.271 | 0.272 | -0.262 | 0.804 | 0.319 |
| Woman participant | 0.473 | 0.548 | -0.601 | 1.547 | 0.388 |
| Participant faculty: Engineering vs Humanities | 1.379 | 0.594 | 0.214 | 2.544 | 0.020* |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | -0.290 | 1.224 | -2.688 | 2.108 | 0.813 |
| Target accepted x Other accepted | 4.564 | 0.773 | 3.049 | 6.079 | <0.001*** |
| Tobit log-scale | 2.031 | 0.051 | 1.931 | 2.131 | <0.001*** |

En el modelo H2 Victim, ningÃƒÂºn tÃƒÂ©rmino focal de hipÃƒÂ³tesis alcanzÃƒÂ³ p < 0.10. Por ello, el reporte conserva la tabla de coeficientes para auditabilidad, pero no aÃƒÂ±ade una interpretaciÃƒÂ³n sustantiva guiada por significancia mÃƒÂ¡s allÃƒÂ¡ de los grÃƒÂ¡ficos descriptivos de predicciÃƒÂ³n.

## H2 Bystander coefficient table

**Table 19. H2 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 7.966 | 2.823 | 2.432 | 13.499 | 0.005** |
| Bystander-victim outgroup vs ingroup | 0.279 | 0.342 | -0.391 | 0.950 | 0.414 |
| Bystander-target outgroup vs ingroup | 0.790 | 0.752 | -0.684 | 2.263 | 0.294 |
| Bystander-other outgroup vs ingroup | 0.798 | 0.754 | -0.681 | 2.277 | 0.290 |
| Victim-target outgroup vs ingroup | -1.927 | 0.769 | -3.435 | -0.420 | 0.012* |
| Victim-other outgroup vs ingroup | -1.206 | 0.739 | -2.655 | 0.243 | 0.103 |
| Target/other same faculty vs different | -0.186 | 0.574 | -1.312 | 0.940 | 0.746 |
| Target accepted | -15.379 | 0.967 | -17.276 | -13.483 | <0.001*** |
| Other negotiator accepted | -4.262 | 0.666 | -5.567 | -2.957 | <0.001*** |
| Age | 0.169 | 0.096 | -0.018 | 0.357 | 0.077+ |
| Socioeconomic status | 0.201 | 0.248 | -0.284 | 0.687 | 0.416 |
| Woman participant | 0.130 | 0.543 | -0.934 | 1.194 | 0.811 |
| Participant faculty: Engineering vs Humanities | 1.200 | 0.517 | 0.187 | 2.213 | 0.020* |
| Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup | -1.261 | 1.022 | -3.263 | 0.742 | 0.217 |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 2.487 | 1.065 | 0.400 | 4.574 | 0.020* |
| Target accepted x Other accepted | 4.876 | 0.780 | 3.348 | 6.404 | <0.001*** |
| Tobit log-scale | 1.932 | 0.050 | 1.833 | 2.030 | <0.001*** |

El modelo H2 Bystander muestra evidencia focal para 2 tÃƒÂ©rminos de hipÃƒÂ³tesis. Victim-target outgroup vs ingroup se asocia con menor judgement predicho (estimate = -1.93, p = 0.012*). Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 2.49, p = 0.020*). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H3 Victim coefficient table

**Table 20. H3 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 4.125 | 3.402 | -2.543 | 10.793 | 0.225 |
| Empathy: Fantasy | 1.470 | 0.647 | 0.202 | 2.738 | 0.023* |
| Empathy: Empathic concern | 0.395 | 0.899 | -1.367 | 2.156 | 0.661 |
| Empathy: Perspective taking | 1.145 | 0.759 | -0.342 | 2.632 | 0.131 |
| Empathy: Personal distress | -0.291 | 0.712 | -1.686 | 1.103 | 0.682 |
| Victim-target outgroup vs ingroup | 3.844 | 1.817 | 0.282 | 7.406 | 0.034* |
| Victim-other outgroup vs ingroup | 2.012 | 1.962 | -1.833 | 5.858 | 0.305 |
| Target/other same faculty vs different | -0.301 | 0.574 | -1.425 | 0.824 | 0.600 |
| Target accepted | -16.908 | 1.071 | -19.008 | -14.809 | <0.001*** |
| Other negotiator accepted | -3.881 | 0.699 | -5.251 | -2.512 | <0.001*** |
| Age | 0.018 | 0.100 | -0.178 | 0.214 | 0.856 |
| Socioeconomic status | 0.216 | 0.268 | -0.309 | 0.741 | 0.420 |
| Woman participant | 0.453 | 0.572 | -0.668 | 1.573 | 0.428 |
| Participant faculty: Engineering vs Humanities | 1.481 | 0.605 | 0.294 | 2.668 | 0.014* |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | -0.160 | 1.214 | -2.539 | 2.220 | 0.895 |
| Empathy: Fantasy x Victim-target outgroup vs ingroup | -0.453 | 0.519 | -1.470 | 0.564 | 0.382 |
| Empathy: Fantasy x Victim-other outgroup vs ingroup | -1.004 | 0.569 | -2.118 | 0.111 | 0.077+ |
| Empathy: Empathic concern x Victim-target outgroup vs ingroup | -0.178 | 0.683 | -1.517 | 1.161 | 0.794 |
| Empathy: Empathic concern x Victim-other outgroup vs ingroup | -0.635 | 0.803 | -2.209 | 0.940 | 0.429 |
| Empathy: Perspective taking x Victim-target outgroup vs ingroup | -0.787 | 0.610 | -1.982 | 0.408 | 0.197 |
| Empathy: Perspective taking x Victim-other outgroup vs ingroup | 0.470 | 0.647 | -0.799 | 1.739 | 0.468 |
| Empathy: Personal distress x Victim-target outgroup vs ingroup | -0.282 | 0.477 | -1.218 | 0.654 | 0.555 |
| Empathy: Personal distress x Victim-other outgroup vs ingroup | 0.152 | 0.618 | -1.059 | 1.363 | 0.806 |
| Target accepted x Other accepted | 4.448 | 0.765 | 2.949 | 5.947 | <0.001*** |
| Tobit log-scale | 2.024 | 0.051 | 1.924 | 2.124 | <0.001*** |

El modelo H3 Victim muestra evidencia focal para 3 tÃƒÂ©rminos de hipÃƒÂ³tesis. Empathy: Fantasy se asocia con mayor judgement predicho (estimate = 1.47, p = 0.023*). Victim-target outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 3.84, p = 0.034*). Empathy: Fantasy x Victim-other outgroup vs ingroup se asocia con menor judgement predicho (estimate = -1.00, p = 0.077+). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H3 Bystander coefficient table

**Table 21. H3 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 10.174 | 3.376 | 3.556 | 16.791 | 0.003** |
| Empathy: Fantasy | 0.752 | 0.667 | -0.556 | 2.060 | 0.260 |
| Empathy: Empathic concern | -0.726 | 0.849 | -2.389 | 0.938 | 0.393 |
| Empathy: Perspective taking | -0.677 | 0.730 | -2.107 | 0.754 | 0.354 |
| Empathy: Personal distress | -0.147 | 0.690 | -1.499 | 1.205 | 0.831 |
| Bystander-victim outgroup vs ingroup | -1.920 | 1.934 | -5.712 | 1.871 | 0.321 |
| Bystander-target outgroup vs ingroup | -1.273 | 1.812 | -4.824 | 2.277 | 0.482 |
| Bystander-other outgroup vs ingroup | -0.383 | 1.807 | -3.923 | 3.158 | 0.832 |
| Victim-target outgroup vs ingroup | -1.941 | 0.763 | -3.438 | -0.445 | 0.011* |
| Victim-other outgroup vs ingroup | -1.217 | 0.736 | -2.659 | 0.225 | 0.098+ |
| Target/other same faculty vs different | -0.111 | 0.563 | -1.214 | 0.992 | 0.844 |
| Target accepted | -15.382 | 0.961 | -17.265 | -13.499 | <0.001*** |
| Other negotiator accepted | -4.267 | 0.664 | -5.570 | -2.965 | <0.001*** |
| Age | 0.182 | 0.097 | -0.008 | 0.372 | 0.061+ |
| Socioeconomic status | 0.159 | 0.246 | -0.324 | 0.642 | 0.520 |
| Woman participant | 0.055 | 0.556 | -1.034 | 1.144 | 0.921 |
| Participant faculty: Engineering vs Humanities | 1.072 | 0.515 | 0.062 | 2.082 | 0.038* |
| Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup | -1.287 | 1.012 | -3.270 | 0.697 | 0.204 |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 2.437 | 1.062 | 0.356 | 4.519 | 0.022* |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.130 | 0.509 | -2.128 | -0.133 | 0.026* |
| Empathy: Fantasy x Bystander-target outgroup vs ingroup | 0.348 | 0.470 | -0.574 | 1.269 | 0.460 |
| Empathy: Fantasy x Bystander-other outgroup vs ingroup | -0.381 | 0.451 | -1.264 | 0.503 | 0.399 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 0.666 | 0.809 | -0.920 | 2.252 | 0.410 |
| Empathy: Empathic concern x Bystander-target outgroup vs ingroup | -0.532 | 0.563 | -1.634 | 0.571 | 0.344 |
| Empathy: Empathic concern x Bystander-other outgroup vs ingroup | 0.378 | 0.640 | -0.876 | 1.631 | 0.555 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.664 | 0.610 | -0.531 | 1.860 | 0.276 |
| Empathy: Perspective taking x Bystander-target outgroup vs ingroup | 0.802 | 0.559 | -0.293 | 1.898 | 0.151 |
| Empathy: Perspective taking x Bystander-other outgroup vs ingroup | 0.444 | 0.595 | -0.722 | 1.609 | 0.456 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 0.597 | 0.605 | -0.590 | 1.783 | 0.324 |
| Empathy: Personal distress x Bystander-target outgroup vs ingroup | 0.491 | 0.444 | -0.379 | 1.361 | 0.269 |
| Empathy: Personal distress x Bystander-other outgroup vs ingroup | -0.084 | 0.494 | -1.053 | 0.885 | 0.866 |
| Target accepted x Other accepted | 4.884 | 0.793 | 3.330 | 6.437 | <0.001*** |
| Tobit log-scale | 1.927 | 0.050 | 1.828 | 2.025 | <0.001*** |

El modelo H3 Bystander muestra evidencia focal para 4 tÃƒÂ©rminos de hipÃƒÂ³tesis. Victim-target outgroup vs ingroup se asocia con menor judgement predicho (estimate = -1.94, p = 0.011*). Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup se asocia con mayor judgement predicho (estimate = 2.44, p = 0.022*). Empathy: Fantasy x Bystander-victim outgroup vs ingroup se asocia con menor judgement predicho (estimate = -1.13, p = 0.026*). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

Recordatorio H4: el nombre fuente legacy `decision_target` corresponde al nombre operativo activo `accept_target`, y `decision_other` corresponde a `accept_other`; ambos se refieren a roles dinamicos `target`/`other` por fila.

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

El modelo H4 Victim muestra evidencia focal para 3 tÃƒÂ©rminos de hipÃƒÂ³tesis. Target accepted se asocia con menor judgement predicho (estimate = -16.98, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.56, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -3.95, p = <0.001***). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

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

El modelo H4 Bystander muestra evidencia focal para 3 tÃƒÂ©rminos de hipÃƒÂ³tesis. Target accepted se asocia con menor judgement predicho (estimate = -15.35, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -4.26, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.85, p = <0.001***). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

Recordatorio H5: la especificacion integrada mantiene semantica `target`/`other` en terminos relacionales y de aceptacion; `group_target`/`group_other` siguen como campos legacy de auditoria y `decision_target`/`decision_other` se mapean a `accept_target`/`accept_other`.

## H5 Victim coefficient table

**Table 24. H5 Victim coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 4.125 | 3.402 | -2.543 | 10.793 | 0.225 |
| Empathy: Fantasy | 1.470 | 0.647 | 0.202 | 2.738 | 0.023* |
| Empathy: Empathic concern | 0.395 | 0.899 | -1.367 | 2.156 | 0.661 |
| Empathy: Perspective taking | 1.145 | 0.759 | -0.342 | 2.632 | 0.131 |
| Empathy: Personal distress | -0.291 | 0.712 | -1.686 | 1.103 | 0.682 |
| Victim-target outgroup vs ingroup | 3.844 | 1.817 | 0.282 | 7.406 | 0.034* |
| Victim-other outgroup vs ingroup | 2.012 | 1.962 | -1.833 | 5.858 | 0.305 |
| Target/other same faculty vs different | -0.301 | 0.574 | -1.425 | 0.824 | 0.600 |
| Target accepted | -16.908 | 1.071 | -19.008 | -14.809 | <0.001*** |
| Other negotiator accepted | -3.881 | 0.699 | -5.251 | -2.512 | <0.001*** |
| Age | 0.018 | 0.100 | -0.178 | 0.214 | 0.856 |
| Socioeconomic status | 0.216 | 0.268 | -0.309 | 0.741 | 0.420 |
| Woman participant | 0.453 | 0.572 | -0.668 | 1.573 | 0.428 |
| Participant faculty: Engineering vs Humanities | 1.481 | 0.605 | 0.294 | 2.668 | 0.014* |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | -0.160 | 1.214 | -2.539 | 2.220 | 0.895 |
| Empathy: Fantasy x Victim-target outgroup vs ingroup | -0.453 | 0.519 | -1.470 | 0.564 | 0.382 |
| Empathy: Fantasy x Victim-other outgroup vs ingroup | -1.004 | 0.569 | -2.118 | 0.111 | 0.077+ |
| Empathy: Empathic concern x Victim-target outgroup vs ingroup | -0.178 | 0.683 | -1.517 | 1.161 | 0.794 |
| Empathy: Empathic concern x Victim-other outgroup vs ingroup | -0.635 | 0.803 | -2.209 | 0.940 | 0.429 |
| Empathy: Perspective taking x Victim-target outgroup vs ingroup | -0.787 | 0.610 | -1.982 | 0.408 | 0.197 |
| Empathy: Perspective taking x Victim-other outgroup vs ingroup | 0.470 | 0.647 | -0.799 | 1.739 | 0.468 |
| Empathy: Personal distress x Victim-target outgroup vs ingroup | -0.282 | 0.477 | -1.218 | 0.654 | 0.555 |
| Empathy: Personal distress x Victim-other outgroup vs ingroup | 0.152 | 0.618 | -1.059 | 1.363 | 0.806 |
| Target accepted x Other accepted | 4.448 | 0.765 | 2.949 | 5.947 | <0.001*** |
| Tobit log-scale | 2.024 | 0.051 | 1.924 | 2.124 | <0.001*** |

El modelo H5 Victim muestra evidencia focal para 6 tÃƒÂ©rminos de hipÃƒÂ³tesis. Target accepted se asocia con menor judgement predicho (estimate = -16.91, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.45, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -3.88, p = <0.001***). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

## H5 Bystander coefficient table

**Table 25. H5 Bystander coefficient estimates**

| term_label | estimate | std_error | conf_low | conf_high | p_value_display |
| --- | --- | --- | --- | --- | --- |
| Intercept | 10.174 | 3.376 | 3.556 | 16.791 | 0.003** |
| Empathy: Fantasy | 0.752 | 0.667 | -0.556 | 2.060 | 0.260 |
| Empathy: Empathic concern | -0.726 | 0.849 | -2.389 | 0.938 | 0.393 |
| Empathy: Perspective taking | -0.677 | 0.730 | -2.107 | 0.754 | 0.354 |
| Empathy: Personal distress | -0.147 | 0.690 | -1.499 | 1.205 | 0.831 |
| Bystander-victim outgroup vs ingroup | -1.920 | 1.934 | -5.712 | 1.871 | 0.321 |
| Bystander-target outgroup vs ingroup | -1.273 | 1.812 | -4.824 | 2.277 | 0.482 |
| Bystander-other outgroup vs ingroup | -0.383 | 1.807 | -3.923 | 3.158 | 0.832 |
| Victim-target outgroup vs ingroup | -1.941 | 0.763 | -3.438 | -0.445 | 0.011* |
| Victim-other outgroup vs ingroup | -1.217 | 0.736 | -2.659 | 0.225 | 0.098+ |
| Target/other same faculty vs different | -0.111 | 0.563 | -1.214 | 0.992 | 0.844 |
| Target accepted | -15.382 | 0.961 | -17.265 | -13.499 | <0.001*** |
| Other negotiator accepted | -4.267 | 0.664 | -5.570 | -2.965 | <0.001*** |
| Age | 0.182 | 0.097 | -0.008 | 0.372 | 0.061+ |
| Socioeconomic status | 0.159 | 0.246 | -0.324 | 0.642 | 0.520 |
| Woman participant | 0.055 | 0.556 | -1.034 | 1.144 | 0.921 |
| Participant faculty: Engineering vs Humanities | 1.072 | 0.515 | 0.062 | 2.082 | 0.038* |
| Bystander-target outgroup vs ingroup x Bystander-other outgroup vs ingroup | -1.287 | 1.012 | -3.270 | 0.697 | 0.204 |
| Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup | 2.437 | 1.062 | 0.356 | 4.519 | 0.022* |
| Empathy: Fantasy x Bystander-victim outgroup vs ingroup | -1.130 | 0.509 | -2.128 | -0.133 | 0.026* |
| Empathy: Fantasy x Bystander-target outgroup vs ingroup | 0.348 | 0.470 | -0.574 | 1.269 | 0.460 |
| Empathy: Fantasy x Bystander-other outgroup vs ingroup | -0.381 | 0.451 | -1.264 | 0.503 | 0.399 |
| Empathy: Empathic concern x Bystander-victim outgroup vs ingroup | 0.666 | 0.809 | -0.920 | 2.252 | 0.410 |
| Empathy: Empathic concern x Bystander-target outgroup vs ingroup | -0.532 | 0.563 | -1.634 | 0.571 | 0.344 |
| Empathy: Empathic concern x Bystander-other outgroup vs ingroup | 0.378 | 0.640 | -0.876 | 1.631 | 0.555 |
| Empathy: Perspective taking x Bystander-victim outgroup vs ingroup | 0.664 | 0.610 | -0.531 | 1.860 | 0.276 |
| Empathy: Perspective taking x Bystander-target outgroup vs ingroup | 0.802 | 0.559 | -0.293 | 1.898 | 0.151 |
| Empathy: Perspective taking x Bystander-other outgroup vs ingroup | 0.444 | 0.595 | -0.722 | 1.609 | 0.456 |
| Empathy: Personal distress x Bystander-victim outgroup vs ingroup | 0.597 | 0.605 | -0.590 | 1.783 | 0.324 |
| Empathy: Personal distress x Bystander-target outgroup vs ingroup | 0.491 | 0.444 | -0.379 | 1.361 | 0.269 |
| Empathy: Personal distress x Bystander-other outgroup vs ingroup | -0.084 | 0.494 | -1.053 | 0.885 | 0.866 |
| Target accepted x Other accepted | 4.884 | 0.793 | 3.330 | 6.437 | <0.001*** |
| Tobit log-scale | 1.927 | 0.050 | 1.828 | 2.025 | <0.001*** |

El modelo H5 Bystander muestra evidencia focal para 7 tÃƒÂ©rminos de hipÃƒÂ³tesis. Target accepted se asocia con menor judgement predicho (estimate = -15.38, p = <0.001***). Other negotiator accepted se asocia con menor judgement predicho (estimate = -4.27, p = <0.001***). Target accepted x Other accepted se asocia con mayor judgement predicho (estimate = 4.88, p = <0.001***). Los dummies de sesiÃƒÂ³n permanecen en el estimador ajustado como ajuste, pero se omiten intencionalmente de la narrativa sustantiva.

# Lista de verificacion de cumplimiento

**Table 26. Lista de verificacion de cumplimiento del pipeline**

| criterion | status | evidence |
| --- | --- | --- |
| a) usa judgement | YES | Todas las formulas modelan judgement de forma directa. |
| b) estructura repetida por id | YES | Todos los modelos Tobit ajustados usan errores estandar robustos por cluster de participante mediante cluster = id. |
| c) agrupacion por sesion | YES | La rama Tobit activa usa factor(session) en cada formula y documenta esa eleccion de forma explicita en lugar de afirmar un intercepto aleatorio de sesion. |
| d) el pipeline no introduce doble conteo | YES | Imported rows = 4860; final analytical rows = 4860; duplicated source row numbers introduced by the pipeline = 0. |
| e) Victim y Bystander tratados de forma diferente | YES | Las formulas especificas por rol se estiman por separado y H2/H3/H5 usan bloques relacionales diferentes para Victim y Bystander. |
| f) accept_target y accept_other incluidos en H1-H5 | YES | Todas las formulas H1-H5 incluyen accept_target, accept_other y su interaccion como parte de la especificacion activa. |
| g) sociodemograficos incluidos en cada modelo de hipotesis | YES | Cada formula H1-H5 retiene age, ses, sex_female y faculty_player_factor. |


# Correcciones frente a notas desactualizadas

La rama productiva actual reemplaza notas previas que usaban `control_hidden` para el codigo de negociador `0`, restringian H3 a terminos de empatia solo aditivos, o implicaban que el estimador principal usaba `(1|session)`. El repositorio ahora documenta de forma directa el estimador implementado y el diseno autoritativo especifico por rol.

# Limitaciones

La rama productiva no ajusta un Tobit multinivel completo con interceptos aleatorios explÃƒÂ­citos de participante y sesiÃƒÂ³n dentro del mismo estimador.
Celdas relacionales escasas pueden producir matrices de diseÃƒÂ±o con deficiencia de rango, por lo que algunos contrastes de interacciÃƒÂ³n se descartan automÃƒÂ¡ticamente y se reportan como tales.
Las figuras dinÃƒÂ¡micas visualizan predicciones implicadas por el modelo a partir de los ajustes Tobit primarios guardados y deben interpretarse junto con las tablas de coeficientes, no como efectos causales autÃƒÂ³nomos.

# Discusion

Los resultados de empatia apuntan a un mecanismo en el que `judgement` no responde solo a resultados, sino tambien a sensibilidad social disposicional. Cuando las pendientes de empatia varian entre relaciones ingroup y outgroup, los hallazgos respaldan la expectativa teorica de que la orientacion empatica esta filtrada por cercania social percibida y no opera como un amplificador moral uniforme.

Los resultados de ingroup/outgroup importan porque el experimento inserta `judgement` en una estructura relacional con dos negociadores y lazos sociales dependientes del rol. Por eso los modelos de Victim y Bystander no son intercambiables. En Victim, la pregunta central es como se relacionan el negociador evaluado y su contraparte con la persona afectada. En Bystander, el participante es externo al evento de dano y la evaluacion puede depender de un mapa mas amplio con relaciones bystander-victim, bystander-negotiator y victim-negotiator.

Los terminos de decision afinan la interpretacion moral del outcome enfocado en target. `accept_target` captura que hizo el negociador evaluado, `accept_other` captura la decision de la contraparte y su interaccion prueba si el significado de una decision cambia cuando el otro negociador acepta o rechaza. Esto es sustantivamente relevante porque la evaluacion moral del target puede responder tanto a la accion individual como al resultado conjunto de la negociacion.

En terminos practicos, los resultados aportan a etica de negociacion y evaluacion de terceros. Si `judgement` cambia con empatia, cercania de facultad y patrones conjuntos de decision, entonces la justicia percibida en negociaciones daninas esta moldeada por contexto disposicional y relacional. Esto tiene implicaciones para como observadores asignan culpa, justifican conducta estrategica o infieren responsabilidad desde accion coordinada.

Metodologicamente, el estimador activo es un Tobit de dos lados con errores estandar robustos agrupados por participante y efectos fijos de sesion. Es una decision productiva honesta para un outcome acotado con medidas repetidas, porque preserva la estructura Tobit de `judgement`, ajusta dependencia intra-participante via `cluster = id`, y controla desplazamientos por sesion con `factor(session)`. Al mismo tiempo, no equivale a un Tobit mixto completo con interceptos aleatorios de participante y sesion.

Las principales limitaciones se desprenden de esa eleccion del estimador y de la escasez en algunas celdas relacionales. La rama productiva no estima un Tobit mixto completo, algunos contrastes de interaccion pueden descartarse en subconjuntos con deficiencia de rango, y la lectura sustantiva debe mantenerse anclada en tablas de coeficientes y figuras implicadas por el modelo, no en p-values aislados. Trabajo futuro deberia comparar estos estimados con modelos censurados multinivel estables, evaluar interacciones alternativas por rol y probar replicacion en otros contextos institucionales o culturales.

# Nota final de auditoria

El proyecto refleja fielmente el diseno autoritativo en su rama productiva: `judgement` es el outcome, el archivo long se mantiene como fuente unica, una fila sigue siendo una observacion real, se usan definiciones de grupo especificas por rol, `accept_target` y `accept_other` se modelan en H1-H5, y las mediciones repetidas se manejan con inferencia robusta por cluster de participante y `factor(session)`.

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
| victim_target_groupingroup | V-Tgt In |
| victim_target_groupoutgroup | V-Tgt Out |
| victim_other_groupingroup | V-Oth In |
| victim_other_groupoutgroup | V-Oth Out |
| bystander_victim_groupoutgroup | B-V Out |
| bystander_target_groupingroup | B-Tgt In |
| bystander_target_groupoutgroup | B-Tgt Out |
| bystander_other_groupingroup | B-Oth In |
| bystander_other_groupoutgroup | B-Oth Out |
| target_other_same_facultysame | SameFac |
| iri_fs:victim_target_groupoutgroup | FS x V-Tgt Out |
| iri_ec:victim_other_groupoutgroup | EC x V-Oth Out |
| iri_pt:bystander_victim_groupoutgroup | PT x B-V Out |
| iri_pd:bystander_target_groupoutgroup | PD x B-Tgt Out |
| accept_target | Target Acc |
| accept_other | Other Acc |
| accept_target:accept_other | Target x Other |
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
el resumen de soporte especifico por rol destaco: Empathy: Perspective taking*.
En el rol Bystander,
ningun termino focal alcanzo el umbral p < 0.10 en la tabla de resumen especifica por rol.
En conjunto, H1 sugiere que la posicion de rol condiciona que tan claramente aparece empatia en el patron ajustado de `judgement`.

### H2

Recordatorio H2: los predictores relacionales activos usan semantica `target`/`other` por fila; `group_target` y `group_other` permanecen como campos legacy de fuente/auditoria y no como terminos activos de H2.

H2 se enfoca en estructura ingroup/outgroup especifica por rol. Para referencia cruzada, ver el resumen de ecuaciones H2 y las tablas y figuras especificas por rol de H2. En el rol Victim,
ningun termino focal alcanzo el umbral p < 0.10 en la tabla de resumen especifica por rol.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Victim-target outgroup vs ingroup*; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*.
Esta comparacion indica que las claves de alineacion relacional no son igual de informativas entre roles y pueden volverse mas visibles cuando participantes evaluan como observadores y no como actores directamente afectados.

### H3

H3 combina empatia, estructura de grupo e interacciones. Para referencia cruzada, ver el resumen de ecuaciones H3, las tablas de coeficientes H3 y las figuras de interaccion H3. En el rol Victim,
el resumen de soporte especifico por rol destaco: Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Empathy: Fantasy x Victim-other outgroup vs ingroup+.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*.
La evidencia de H3 debe leerse como una prueba de moderacion contextual: empatia no necesariamente opera como una pendiente uniforme cuando cambia la distancia social.

### H4

Recordatorio H4: el nombre fuente legacy `decision_target` corresponde al nombre operativo activo `accept_target`, y `decision_other` corresponde a `accept_other`; ambos se refieren a roles dinamicos `target`/`other` por fila.

H4 prueba terminos de decision de forma directa mediante `accept_target`, `accept_other` y su interaccion. Para referencia cruzada, ver el resumen de ecuaciones H4 y las tablas y figuras de significancia especificas por rol de H4. En el rol Victim,
el resumen de soporte especifico por rol destaco: Target accepted***; Other negotiator accepted***; Target accepted x Other accepted***.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Target accepted***; Other negotiator accepted***; Target accepted x Other accepted***.
En ambos roles, H4 suele ser donde el mecanismo decisional se ve con mayor claridad, porque el juicio al target esta condicionado explicitamente por resultados conjuntos de negociacion.

### H5

Recordatorio H5: la especificacion integrada mantiene semantica `target`/`other` en terminos relacionales y de aceptacion; `group_target`/`group_other` siguen como campos legacy de auditoria y `decision_target`/`decision_other` se mapean a `accept_target`/`accept_other`.

H5 es la especificacion integrada que combina empatia, terminos relacionales, decisiones e interacciones. Para referencia cruzada, ver el resumen de ecuaciones H5, las tablas de coeficientes H5 y las figuras de significancia H5. En el rol Victim,
el resumen de soporte especifico por rol destaco: Empathy: Fantasy*; Victim-target outgroup vs ingroup*; Target accepted***; Other negotiator accepted***; Empathy: Fantasy x Victim-other outgroup vs ingroup+; Target accepted x Other accepted***.
En el rol Bystander,
el resumen de soporte especifico por rol destaco: Victim-target outgroup vs ingroup*; Victim-other outgroup vs ingroup+; Target accepted***; Other negotiator accepted***; Victim-target outgroup vs ingroup x Victim-other outgroup vs ingroup*; Empathy: Fantasy x Bystander-victim outgroup vs ingroup*; Target accepted x Other accepted***.
H5 debe leerse como sintesis y no como reemplazo de hipotesis previas: muestra como componentes disposicionales, relacionales y decisionales coexisten en un mismo modelo.

## Interpretacion global

Tomadas en conjunto, las cinco hipotesis indican que `judgement` en este experimento es multimecanismo y no unidimensional. Terminos de empatia pueden importar, alineacion relacional puede importar, y terminos de decision pueden importar fuertemente, pero su visibilidad cambia por rol y por contexto de modelo.

En terminos practicos, el reporte respalda una lectura contingente al rol: el juicio en Victim conserva contenido disposicional mas fuerte en algunas especificaciones, mientras el juicio en Bystander suele depender mas del contexto relacional, y ambos roles permanecen sensibles a las decisiones conjuntas de los negociadores.

