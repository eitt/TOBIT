# Guia sencilla para leer el informe TOBIT

Base analizada: **Bucaramanga**
Generado el: **2026-03-28 19:43:51**

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

- Empatia total: `iri_total`.
- Subescalas de empatia: `iri_fs`, `iri_ec`, `iri_pt`, `iri_pd`.
- Edad: `age`.
- Nivel socioeconomico: `economic_status`.

Estas variables cambian en una escala numerica. Por ejemplo, una persona puede tener mas o menos empatia, o mas o menos edad.

### 1.2 Predictores categoricos o de comparacion

- Configuracion del caso: `Hum_x_Hum`, `Hum_x_Ing`, `Hum_x_Control`, `Ing_x_Hum`, `Ing_x_Ing`, `Ing_x_Control`.
- Rol del participante en la escena: `role_observer`.
- Facultad del participante: `participant_engineering`.
- Sexo recodificado: `sex_man`.
- Posicion del negociador en la pantalla: `factor(negotiator_slot)`.

Estas variables no miden una cantidad continua. Lo que hacen es comparar grupos, roles o tipos de escena.

### 1.3 La idea central de Option 2

Aqui esta uno de los puntos mas importantes del proyecto. Antes uno podia pensar en variables sueltas como ingroup y outgroup. Ahora el proyecto prioriza el caso completo.

Es decir, cada juicio se entiende como una combinacion victima x negociador. Eso hace que la pregunta sea mas interpretable: no es solo si el negociador es outgroup, sino por ejemplo como juzgan un caso `Hum_x_Ing` o un caso `Ing_x_Control`.

## 2. Data card corto

- Archivos base principales: `data/raw/data_final_FLORIDA.xlsx` y `data/raw/data_final_BUC.xlsx`.
- Filas de participantes disponibles ahora: **209**.
- Filas en formato largo de juicios disponibles ahora: **3,980**.
- Filas de decisiones aceptadas usadas en la mayoria de modelos: **1,939**.
- Filas del subconjunto de traicion usadas en H2a: **1,262**.
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
iri_total = promedio de todos los items IRI si al menos el 80% de los items fue respondido
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

### 3.4 Variable relacional central: case configuration

```text
case_configuration = grupo de la victima + '_x_' + grupo del negociador
case_configuration_role = case_configuration + '__' + rol
case_configuration_decision = case_configuration + '__' + decision
case_configuration_context = case_configuration + '__' + rol + '__' + decision
```

Esto permite nombrar cada escena de una forma mas clara.

- `Hum_x_Ing` = victima de Humanidades y negociador evaluado de Ingenieria.
- `Ing_x_Hum` = victima de Ingenieria y negociador evaluado de Humanidades.
- `Hum_x_Hum` = victima de Humanidades y negociador evaluado de Humanidades.

La categoria de referencia principal en las regresiones es `Hum_x_Hum`.

### 3.5 Subconjuntos analiticos

```text
judgments_analysis = filas en formato largo con analysis_include = TRUE
judgments_accept = filas de judgments_analysis donde decision_accept = 1
judgments_betrayal = filas de judgments_accept donde el negociador no es control
```

## 4. Hipotesis explicadas de manera sencilla

### H1: empatia y juicio moral controlando por la configuracion del caso

Pregunta simple: una vez tenemos en cuenta el tipo exacto de escenario, la empatia del participante se relaciona con el juicio moral?

- Muestra usada: solo decisiones aceptadas.

Ecuacion sencilla:

```text
judgement = empatia + configuracion del caso + controles
```

Version mas pegada al codigo:

```text
Modelo A: iri_total + terminos de caso + role_observer + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
Modelo B: iri_fs + iri_ec + iri_pt + iri_pd + terminos de caso + role_observer + participant_engineering + sex_man + age + economic_status + factor(negotiator_slot)
```

En H1, los terminos de caso que entran son `case_hum_x_ing`, `case_hum_x_control`, `case_ing_x_hum`, `case_ing_x_ing`, `case_ing_x_control`, siempre comparados contra `Hum_x_Hum`.

### H2a: comparaciones relacionales dentro de casos de traicion

Pregunta simple: cuando miramos solo escenas de traicion, cambian los juicios segun la combinacion victima x negociador?

- Muestra usada: decisiones aceptadas, excluyendo los casos control.

Ecuacion sencilla:

```text
judgement = configuracion relacional de traicion + empatia + controles
```

Version mas pegada al codigo:

```text
Modelo A: terminos de traicion + iri_total + controles
Modelo B: terminos de traicion + iri_fs + iri_ec + iri_pt + iri_pd + controles
```

En H2a, los terminos relacionales son `case_hum_x_ing`, `case_ing_x_hum`, `case_ing_x_ing`, siempre comparados contra `Hum_x_Hum`.

### H2b: contrastes entre configuraciones completas del caso

Pregunta simple: es mas util modelar el caso completo victima x negociador que usar solo indicadores sueltos como ingroup y outgroup?

- Muestra usada: solo decisiones aceptadas.

Ecuacion sencilla:

```text
judgement = configuracion del caso + empatia + controles
```

Version mas pegada al codigo:

```text
Modelo A: terminos de caso + iri_total + controles
Modelo B: terminos de caso + iri_fs + iri_ec + iri_pt + iri_pd + controles
```

### H3: interaccion entre empatia y configuracion del caso

Pregunta simple: la relacion entre empatia y juicio cambia dependiendo del tipo de caso relacional?

- Muestra usada: solo decisiones aceptadas.

Ecuacion sencilla:

```text
judgement = empatia + configuracion del caso + empatia x configuracion del caso + controles
```

Version mas pegada al codigo:

```text
Modelo A: iri_total + terminos de caso + iri_total:terminos de caso + controles
Modelo B: subescalas de empatia + terminos de caso + interacciones entre subescalas y terminos de caso + controles
```

## 5. Como leer las codificaciones de la regresion

Esta parte sirve para que los coeficientes se lean con mas tranquilidad.

- `Hum_x_Hum` es la categoria de referencia para los contrastes de caso.
- Los dummies explicitos de caso que entran en las regresiones son `case_hum_x_ing`, `case_hum_x_control`, `case_ing_x_hum`, `case_ing_x_ing`, `case_ing_x_control`.
- `role_observer = 1` significa observador y `0` significa victima.
- `participant_engineering = 1` significa que el participante es de Ingenieria y `0` que es de Humanidades.
- `sex_man = 1` significa hombre y `0` mujer.
- `decision_accept = 1` significa que el negociador acepto y `0` que rechazo.
- `factor(negotiator_slot)` compara al negociador 2 contra el negociador 1. El negociador 1 es la referencia.
- `age` y `economic_status` entran como numeros en su escala original.

### Como leer un coeficiente de caso

Si el coeficiente de `case_hum_x_ing` es negativo, eso quiere decir que el caso `Hum_x_Ing` recibe un juicio mas negativo que el caso de referencia `Hum_x_Hum`, manteniendo lo demas constante.

Si una interaccion como `iri_total:case_hum_x_ing` es negativa, eso quiere decir que la pendiente de empatia es mas negativa en `Hum_x_Ing` que en `Hum_x_Hum`.

## 6. Por que el proyecto usa dos familias de modelos

- **Modelo Tobit**: es el modelo principal para el resultado acotado entre `-9` y `9`.
- **Modelo de robustez no parametrico**: es una segunda revision usando los mismos predictores, pero con menos dependencia de supuestos fuertes sobre la distribucion.
- En ambos casos, la parte teorica del modelo es la misma. Lo que cambia es la forma estadistica de estimarlo.

El numero por defecto de bootstrap en este momento es **10** y se controla desde `R/00_config.R`.

## 7. Archivos base usados para construir esta guia

Esta guia se apoya especialmente en estos archivos del proyecto:

- `docs/datacard.md`
- `docs/hypotheses.md`
- `docs/statistical_model_instructions.md`
- `R/03_transform_data.R`
- `R/04_generate_variables.R`
- `R/hypotheses/H1_test.R`
- `R/hypotheses/H2a_test.R`
- `R/hypotheses/H2b_test.R`
- `R/hypotheses/H3_test.R`

## 8. Cierre

En resumen, esta guia busca dejar claro que se esta modelando, como se construyen las variables y como leer las regresiones sin tener que entrar desde el comienzo en el lenguaje mas tecnico del informe principal.

