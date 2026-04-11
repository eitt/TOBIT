# Guia sencilla para leer el informe TOBIT

Base analizada: **Florida + Bucaramanga**
Generado el: **2026-04-11 09:04:58**

Hola Diego, he creado este documento para orientar de manera un poco mas sencilla la lectura del informe.

La idea no es reemplazar el informe tecnico. La idea es acompaniarlo y dejar mas claro que entra en el modelo, como se construyen las variables, que significa cada hipotesis y como leer las ecuaciones y las codificaciones de regresion.

## 1. Lo primero: las variables

En el modelo hay una variable dependiente y varios predictores.

- Variable dependiente: `judgement`.
- La podemos leer como la severidad del juicio moral hacia el negociador.
- Su escala va de `-9` a `9`.
- Valores mas bajos significan un juicio mas negativo.
- Valores mas altos significan un juicio mas positivo.

Los predictores se pueden entender en dos grupos.

### 1.1 Predictores continuos

- `iri_total` se conserva en la base como resumen psicometrico, pero no entra al flujo activo de estimacion.
- Subescalas de empatia: `iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`.
- Edad: `age`.
- Nivel socioeconomico: `economic_status`.

Estas variables cambian en una escala numerica. Por ejemplo, una persona puede tener mas o menos empatia, o mas o menos edad.

### 1.2 Predictores categoricos o de comparacion

- Estatus del negociador juzgado: `judged_ingroup` y `judged_outgroup`, con control como referencia.
- Estatus de la contraparte: `counterpart_ingroup` y `counterpart_outgroup`, con control como referencia.
- Alineacion victima-observador: `observer_victim_outgroup` (solo cuando el subconjunto es Observador).
- Decision del negociador juzgado: `decision_accept`.
- Rol del participante en la escena: `role_observer`.
- Facultad del participante: `participant_engineering`.
- Sexo recodificado: `sex_man`.
- Posicion del negociador en la pantalla: `factor(negotiator_slot)`.

Estas variables no miden una cantidad continua. Lo que hacen es comparar grupos, roles o tipos de escena.

### 1.3 La separacion en Subconjuntos (Victima y Observador)

A diferencia de versiones anteriores, el analisis ya no se divide segun si la gente acepto o traiciono. Ahora **todos los modelos** se corren dos veces: una vez exclusivamente para el subconjunto donde el participante actuo como **Victima**, y otra vez para el subconjunto donde actuo como **Observador (Bystander)**. H1 y H3 retienen la decision como predictor; H2 se centra en la estructura relacional del juicio por negociador y, en Observador, en la relacion jugador-victima.

### 1.4 Interpretacion de Interacciones

Cuando veas que un termino con dos puntos (`:`) es marcado como significativo, significa que ambos componentes interactuan. Si una interaccion es significativa, los efectos principales (los que van solos) ya no se interpretan por su cuenta, pues estan subordinados al contexto de la interaccion.
Si es una interaccion entre una subescala continua de empatia y un grupo (ej. `iri_pt:judged_outgroup`), un coeficiente negativo indica que el efecto de la empatia es todavia mas severo para el outgroup frente a la condicion control. Si es discreto por discreto (ej. `judged_outgroup:decision_accept`), un coeficiente positivo significa que penalizamos menos la traicion cuando la comete el outgroup comparado a la condicion control.

## 2. Data card corto

- Archivos base principales: `data/raw/data_final_FLORIDA.xlsx` y `data/raw/data_final_BUC.xlsx`.
- Filas de participantes disponibles ahora: **272**.
- Filas en formato largo de juicios disponibles ahora: **4,860**.
- Juicios emitidos desde el rol de Victima: **2,430**.
- Juicios emitidos desde el rol de Observador: **2,430**.
- La base original empieza con una fila por participante.
- Luego el pipeline reorganiza la informacion para que cada juicio sobre cada negociador quede como una fila propia.

```text
1 participante x 10 etapas x 2 negociadores = hasta 20 filas de juicio por participante
```

## 3. Como se crean las variables principales

### 3.1 Filtro de atencion e inclusion analitica

```text
attention_pass = (ac1 es correcto) AND (ac2 es correcto)
analysis_include = attention_pass AND iri_total disponible AND tratamiento valido
```

En sencillo: para entrar al analisis principal, la persona debe pasar los attention checks, tener suficiente informacion para la empatia total y pertenecer a una secuencia valida del experimento.

### 3.2 Variables de empatia

```text
iri_total = promedio de todos los items IRI si al menos el 80% de los items fue respondido (se conserva en la base, pero no entra al flujo activo de estimacion)
iri_fs = promedio de los items de Fantasy
iri_ec = promedio de los items de Empathic Concern
iri_pt = promedio de los items de Perspective Taking
iri_pd = promedio de los items de Personal Distress
```

Importante: estas variables se conservan en su escala original. El pipeline no las transforma a z-scores.

### 3.3 Variables del escenario y del contexto

```text
role_observer = 1 si el participante esta en rol de observador, 0 si esta en rol de victima
participant_engineering = 1 si el participante es de Ingenieria, 0 si es de Humanidades
sex_man = 1 si sexo esta codificado como hombre, 0 si esta codificado como mujer
decision_accept = 1 si el negociador acepto el trato danino, 0 si lo rechazo
judgement = juicio moral numerico del negociador en esa etapa y en ese slot
condemnation = -judgement
```

### 3.4 Variables relacionales centrales

```text
group_negotiator1 = estatus In/Out/Cont del negociador 1 respecto al referente del rol
group_negotiator2 = estatus In/Out/Cont del negociador 2 respecto al referente del rol
judged_ingroup = 1 si el negociador juzgado es ingroup, 0 si no
judged_outgroup = 1 si el negociador juzgado es outgroup, 0 si no
counterpart_ingroup = 1 si la contraparte es ingroup, 0 si no
counterpart_outgroup = 1 si la contraparte es outgroup, 0 si no
observer_victim_outgroup = 1 si en filas de observador la victima es outgroup, 0 si no
h2_negotiator_structure = estructura conjunta del negociador juzgado y la contraparte dentro del mismo juicio
player_victim_outgroup = 1 si en Observador el jugador y la victima no comparten facultad, 0 si la comparten
```

Esto permite nombrar cada escena de una forma mas clara y, en H2, modelar la estructura conjunta juzgado-contraparte y su cruce con jugador-victima en Observador.

### 3.5 Subconjuntos analiticos

```text
judgments_analysis = filas en formato largo con analysis_include = TRUE
judgments_victim = filas de judgments_analysis donde role = victim
judgments_bystander = filas de judgments_analysis donde role = observer
judgments_accept = subconjunto legado que se puede conservar para auditoria, pero no es la base activa de H1 en el flujo actual
```

## 4. Hipotesis explicadas de manera sencilla

### H1

Pregunta simple: Si las dimensiones de empatia se relacionan con la severidad del juicio moral cuando ya controlamos el contexto relacional del negociador.

- Muestra usada: Se estima por separado en Victima y Observador, con una fila por juicio sobre un negociador.

Ecuacion sencilla:

```text
Juicio moral ~ empatia + estatus del negociador juzgado + estatus de la contraparte + decision + controles
```

Version mas pegada al codigo:

```text
Modelo B Victima: judgement ~ iri_fs + iri_ec + iri_pt + iri_pd + judged_ingroup + judged_outgroup + counterpart_ingroup + counterpart_outgroup + decision_accept + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
Modelo B Observador: judgement ~ iri_fs + iri_ec + iri_pt + iri_pd + judged_ingroup + judged_outgroup + counterpart_ingroup + counterpart_outgroup + decision_accept + observer_victim_outgroup + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
```

En Observador se agrega `observer_victim_outgroup` porque solo ahi varia la relacion entre el jugador y la victima.

### H2

Pregunta simple: Si el juicio cambia segun la posicion conjunta del negociador juzgado y su contraparte respecto al participante.

- Muestra usada: Se estima por separado en Victima y Observador, con una fila por juicio sobre un negociador.

Ecuacion sencilla:

```text
Juicio moral ~ estructura juzgado-contraparte (+ alineacion jugador-victima e interacciones en Observador) + empatia + controles
```

Version mas pegada al codigo:

```text
Modelo B Victima: judgement ~ iri_fs + iri_ec + iri_pt + iri_pd + h2_negstruct_j_in_c_in + h2_negstruct_j_out_c_in + h2_negstruct_j_cont_c_in + h2_negstruct_j_in_c_out + h2_negstruct_j_out_c_out + h2_negstruct_j_cont_c_out + h2_negstruct_j_in_c_cont + h2_negstruct_j_out_c_cont + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
Modelo B Observador: judgement ~ iri_fs + iri_ec + iri_pt + iri_pd + h2_negstruct_j_in_c_in + h2_negstruct_j_out_c_in + h2_negstruct_j_cont_c_in + h2_negstruct_j_in_c_out + h2_negstruct_j_out_c_out + h2_negstruct_j_cont_c_out + h2_negstruct_j_in_c_cont + h2_negstruct_j_out_c_cont + player_victim_outgroup + player_victim_outgroup:h2_negstruct_j_in_c_in + player_victim_outgroup:h2_negstruct_j_out_c_in + player_victim_outgroup:h2_negstruct_j_cont_c_in + player_victim_outgroup:h2_negstruct_j_in_c_out + player_victim_outgroup:h2_negstruct_j_out_c_out + player_victim_outgroup:h2_negstruct_j_cont_c_out + player_victim_outgroup:h2_negstruct_j_in_c_cont + player_victim_outgroup:h2_negstruct_j_out_c_cont + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
```

La referencia de H2 es `J_Cont__C_Cont`: N1 y N2 en la condicion control.

### H3

Pregunta simple: Si la relacion entre empatia y juicio moral cambia dependiendo del estatus del negociador juzgado.

- Muestra usada: Se estima por separado en Victima y Observador, con una fila por juicio sobre un negociador.

Ecuacion sencilla:

```text
Juicio moral ~ empatia + estatus del negociador juzgado + decision + empatia x estatus juzgado + decision x estatus juzgado + controles
```

Version mas pegada al codigo:

```text
Modelo B Victima: judgement ~ iri_fs + iri_ec + iri_pt + iri_pd + judged_ingroup + judged_outgroup + decision_accept + decision_accept:judged_ingroup + decision_accept:judged_outgroup + iri_fs:judged_ingroup + iri_ec:judged_ingroup + iri_pt:judged_ingroup + iri_pd:judged_ingroup + iri_fs:judged_outgroup + iri_ec:judged_outgroup + iri_pt:judged_outgroup + iri_pd:judged_outgroup + counterpart_ingroup + counterpart_outgroup + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
Modelo B Observador: judgement ~ iri_fs + iri_ec + iri_pt + iri_pd + judged_ingroup + judged_outgroup + decision_accept + decision_accept:judged_ingroup + decision_accept:judged_outgroup + iri_fs:judged_ingroup + iri_ec:judged_ingroup + iri_pt:judged_ingroup + iri_pd:judged_ingroup + iri_fs:judged_outgroup + iri_ec:judged_outgroup + iri_pt:judged_outgroup + iri_pd:judged_outgroup + counterpart_ingroup + counterpart_outgroup + observer_victim_outgroup + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
```

En Observador se conserva ademas `observer_victim_outgroup` para no mezclar un predictor solo-observador dentro del subconjunto Victima.


## 5. Como leer las codificaciones de la regresion

Esta parte sirve para que los coeficientes se lean con mas tranquilidad.

- En H1, tanto en Victima como en Observador, el flujo activo usa `iri_fs`, `iri_ec`, `iri_pt` e `iri_pd`; ademas retiene `judged_ingroup`, `judged_outgroup`, `counterpart_ingroup`, `counterpart_outgroup`, `decision_accept`, `sex_man`, `age` y `economic_status`. Eso deja a la condicion control como referencia.
- En H1, `observer_victim_outgroup` entra solo en Observador. En Victima se elimina para no meter un predictor estructuralmente fijo dentro del subconjunto.
- En H2, ambos subconjuntos retienen las subescalas de empatia activas y la estructura conjunta `h2_negotiator_structure`; el subconjunto Observador agrega `player_victim_outgroup` y sus interacciones con esa estructura.
- En H3, los contrastes centrales siguen usando el estatus del negociador juzgado (`judged_ingroup`, `judged_outgroup`), la decision (`decision_accept`) y sus interacciones. Igual que en H1, `observer_victim_outgroup` solo aparece en Observador.
- `role_observer = 1` significa observador y `0` significa victima.
- `participant_engineering = 1` significa que el participante es de Ingenieria y `0` que es de Humanidades.
- `sex_man = 1` significa hombre y `0` mujer.
- `decision_accept = 1` significa que el negociador acepto y `0` que rechazo.
- `factor(negotiator_slot)` compara al negociador 2 contra el negociador 1. El negociador 1 es la referencia.
- `age` y `economic_status` entran como numeros en su escala original.
- En las tablas y figuras del informe tecnico aparecen abreviaturas compactas: `N1` (judged negotiator), `N2` (counterpart negotiator), `V` (relacion jugador-victima en Observador), `Acc`/`Rej`, `FS`, `EC`, `PT`, `PD` y `SES`.

### Como leer un coeficiente de caso

Si el coeficiente de una dummy `h2_negstruct_*` es negativo, eso quiere decir que esa estructura juzgado-contraparte recibe un juicio mas negativo que la estructura de referencia `J_Cont__C_Cont`, manteniendo lo demas constante.

Si una interaccion como `player_victim_outgroup:h2_negstruct_*` es negativa, eso quiere decir que esa estructura negociador-contraparte se vuelve todavia mas severa cuando, en Observador, el jugador y la victima son de grupos distintos.

Si una interaccion como `iri_pt:judged_outgroup` es negativa, eso quiere decir que la pendiente de esa dimension de empatia es mas negativa cuando el negociador juzgado es outgroup que en la condicion control.

## 6. Por que el proyecto usa dos familias de modelos

- **Modelo Tobit**: es el modelo principal para el resultado acotado entre `-9` y `9`.
- **Modelo de robustez no parametrico**: es una segunda revision usando los mismos predictores, pero con menos dependencia de supuestos fuertes sobre la distribucion.
- En ambos casos, la parte teorica del modelo es la misma. Lo que cambia es la forma estadistica de estimarlo.

El numero por defecto de bootstrap en este momento es **5** y se controla desde `R/00_config.R`.

## 7. Archivos base usados para construir esta guia

Esta guia se apoya especialmente en estos archivos del proyecto:

- `docs/datacard.md`
- `docs/hypotheses.md`
- `docs/statistical_model_instructions.md`
- `R/03_transform_data.R`
- `R/04_generate_variables.R`
- `R/hypotheses/H1_test.R`
- `R/hypotheses/H2_test.R`
- `R/hypotheses/H3_test.R`

## 8. Cierre

En resumen, esta guia busca dejar claro que se esta modelando, como se construyen las variables y como leer las regresiones sin tener que entrar desde el comienzo en el lenguaje mas tecnico del informe principal.

