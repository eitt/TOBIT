# Guia sencilla del pipeline TOBIT longitudinal

Generado el 2026-04-23 21:26:51.

## Que representa una fila

Cada fila del archivo base `Version 2.0/consolidado_ALL_2026_04_09_LONG.xlsx` representa un juicio moral realmente registrado en el experimento sobre el negociador objetivo. Como cada participante evalua 10 escenarios y en cada uno juzga a dos negociadores, la estructura esperada es de 20 filas por `id`. El pipeline nuevo no vuelve a expandir esas filas. Solo agrega columnas de contexto para target, other, victima, bystander, decisiones y sesion.

## Como se evita el doble conteo

Se copia `source_row_number` desde la importacion y se conserva hasta `judgments_analysis.csv`. Eso permite auditar que el numero de filas importadas y el numero de filas analiticas finales coinciden exactamente.

## Covariables sociodemograficas en todos los modelos

- `age`
- `ses`
- `sex_female`
- `faculty_player_factor`

## Variables relacionales por rol

- Victima: `victim_target_group`, `victim_other_group`, `target_other_same_faculty`.
- Bystander: `bystander_victim_group`, `bystander_target_group`, `bystander_other_group`, `victim_target_group`, `victim_other_group`, `target_other_same_faculty`.
- Ingroup significa coincidencia de facultad, incluyendo `control` con `control`; outgroup significa facultades distintas.
- Las variables de rol no son intercambiables: victima y bystander usan mapas relacionales distintos porque la cercania social cambia segun el rol.

## Decisiones

- `accept_target`: 0 = reject, 1 = accept.
- `accept_other`: 0 = reject, 1 = accept.
- Su interaccion distingue cuatro contextos: ambos aceptan, ambos rechazan, target acepta / other rechaza, target rechaza / other acepta.

## Modelos H1-H5

| hypothesis | role | formula_rhs |
| --- | --- | --- |
| H1 | Victim | iri_fs + iri_ec + iri_pt + iri_pd + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H1 | Bystander | iri_fs + iri_ec + iri_pt + iri_pd + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H2 | Victim | victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H2 | Bystander | bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H3 | Victim | iri_fs + iri_ec + iri_pt + iri_pd + victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:victim_target_group + iri_fs:victim_other_group + iri_ec:victim_target_group + iri_ec:victim_other_group + iri_pt:victim_target_group + iri_pt:victim_other_group + iri_pd:victim_target_group + iri_pd:victim_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H3 | Bystander | iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group + iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group + iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group + iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H4 | Victim | accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H4 | Bystander | accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H5 | Victim | iri_fs + iri_ec + iri_pt + iri_pd + victim_target_group + victim_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:victim_target_group + iri_fs:victim_other_group + iri_ec:victim_target_group + iri_ec:victim_other_group + iri_pt:victim_target_group + iri_pt:victim_other_group + iri_pd:victim_target_group + iri_pd:victim_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |
| H5 | Bystander | iri_fs + iri_ec + iri_pt + iri_pd + bystander_victim_group + bystander_target_group + bystander_other_group + victim_target_group + victim_other_group + bystander_target_group:bystander_other_group + victim_target_group:victim_other_group + target_other_same_faculty + iri_fs:bystander_victim_group + iri_fs:bystander_target_group + iri_fs:bystander_other_group + iri_ec:bystander_victim_group + iri_ec:bystander_target_group + iri_ec:bystander_other_group + iri_pt:bystander_victim_group + iri_pt:bystander_target_group + iri_pt:bystander_other_group + iri_pd:bystander_victim_group + iri_pd:bystander_target_group + iri_pd:bystander_other_group + accept_target * accept_other + age + ses + sex_female + faculty_player_factor + factor(session) |

En H3 y H5, el pipeline actual ya no restringe la teoria a efectos aditivos puros. Tambien incluye interacciones dirigidas entre empatia y cercania grupal para comprobar si el efecto de la empatia cambia segun la estructura de ingroup/outgroup.

## Como se modela la dependencia

Todos los modelos activos usan TOBIT bilateral: `judgement` se trata como una variable censurada a ambos lados sobre la escala `-9` a `9`. La dependencia intra-participante se ajusta con errores estandar robustos clusterizados por `id`, y la sesion entra como `factor(session)`.

El reporte dinamico explica `factor(session)` en lugar de `(1 | session)` porque esta rama ya no esta reportando un modelo mixto. La especificacion productiva es un TOBIT con efecto fijo de sesion y ajuste robusto por participante. Ademas, la salida de robustez aclara por que no se corre por defecto un TOBIT saturado con `factor(id_case)`.

## Resumen de muestra

| metric | value |
| --- | --- |
| participants | 243.000 |
| sessions | 16.000 |
| mean_age | 20.086 |
| women_share | 0.426 |
| engineering_share | 0.568 |

| sample | rows | participants | mean_judgement | sd_judgement |
| --- | --- | --- | --- | --- |
| All | 4860 | 243 | 1.623 | 6.674 |
| Victim | 2430 | 243 | 1.504 | 6.842 |
| Bystander | 2430 | 243 | 1.741 | 6.500 |

## Resultado practico del rediseno

La logica dominante ya no es un pipeline centrado solo en IRI agregado. El flujo activo usa `judgement` como variable dependiente, separa victima y bystander, incorpora dependencia repetida por participante mediante clustering robusto por `id`, documenta `factor(session)`, usa `accept_target` y `accept_other`, y deja una pista auditable de que no se introdujo nuevo doble conteo.

