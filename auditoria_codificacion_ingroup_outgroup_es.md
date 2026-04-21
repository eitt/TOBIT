# 1. Proposito del documento

Este documento audita, con evidencia empirica real del pipeline activo, la logica de codificacion de `ingroup`, `outgroup`, `same`, `different`, `target`, `other`, `N1`, `N2`, `decision_target` y `decision_other` en el proyecto TOBIT.

Se verifico la implementacion activa en `R/utils/build_role_relational_variables.R` y se contrasto contra `data/processed/judgments_analysis.csv` (salida real del pipeline).

# 2. Variables fuente relevantes

| variable | presente | clase | n_missing | valores_unicos |
|---|---|---|---|---|
| target | TRUE | integer | 0 | 1, 2 |
| faculty_target | TRUE | integer | 0 | 0, 1, 2 |
| faculty_other | TRUE | integer | 0 | 0, 1, 2 |
| faculty_victim | TRUE | integer | 0 | 1, 2 |
| faculty_player | TRUE | integer | 0 | 1, 2 |
| decision_target | TRUE | integer | 0 | 0, 1 |
| decision_other | TRUE | integer | 0 | 0, 1 |
| role | TRUE | integer | 0 | 0, 1 |
| group_target | TRUE | integer | 0 | 0, 1, 2 |
| group_other | TRUE | integer | 0 | 0, 1, 2 |

# 3. Formulas logicas de codificacion

Las reglas siguientes corresponden a la implementacion activa observada en `R/utils/build_role_relational_variables.R`.

## 3.1 Reconstruccion de `N1` y `N2`

- Si `target == 1` entonces:
  - `N1_faculty = faculty_target`
  - `N2_faculty = faculty_other`
  - `N1_decision = decision_target`
  - `N2_decision = decision_other`
- Si `target == 2` entonces:
  - `N1_faculty = faculty_other`
  - `N2_faculty = faculty_target`
  - `N1_decision = decision_other`
  - `N2_decision = decision_target`

## 3.2 Regla de `ingroup` / `outgroup` (`derive_group_relation()`)

- `ingroup` si `reference_faculty == actor_faculty`.
- `outgroup` si `reference_faculty != actor_faculty`.
- Esto incluye `Control == Control` como `ingroup`.

## 3.3 Regla de `N1_N2_same_faculty` (`derive_same_faculty_context()`)

- `same` si `N1_faculty == N2_faculty`.
- `different` en caso contrario.

## 3.4 Regla de `decision_pattern` (`derive_decision_pattern()`)

- `both_accept` si `decision_target == 1` y `decision_other == 1`.
- `both_reject` si `decision_target == 0` y `decision_other == 0`.
- `target_accept_other_reject` si `decision_target == 1` y `decision_other == 0`.
- `target_reject_other_accept` si `decision_target == 0` y `decision_other == 1`.

# 4. Evidencia empirica con datos reales

## 4.1 Validacion de reconstruccion `target` -> `N1/N2`

| regla | filas_en_ambito | filas_con_datos | filas_que_cumplen | inconsistencias |
|---|---|---|---|---|
| target == 1: N1_decision = decision_target y N2_decision = decision_other | 2430 | 2430 | 2430 | 0 |
| target == 2: N1_decision = decision_other y N2_decision = decision_target | 2430 | 2430 | 2430 | 0 |
| target == 1: N1_faculty = faculty_target y N2_faculty = faculty_other | 2430 | 2430 | 2430 | 0 |
| target == 2: N1_faculty = faculty_other y N2_faculty = faculty_target | 2430 | 2430 | 2430 | 0 |

## 4.2 Consistencia de variables derivadas contra funciones activas

| variable_derivada | filas_totales | filas_consistentes | inconsistencias | consistencia_pct |
|---|---|---|---|---|
| victim_N1_group | 4860 | 4860 | 0 | 100.00% |
| victim_N2_group | 4860 | 4860 | 0 | 100.00% |
| bystander_victim_group | 4860 | 4860 | 0 | 100.00% |
| bystander_N1_group | 4860 | 4860 | 0 | 100.00% |
| bystander_N2_group | 4860 | 4860 | 0 | 100.00% |
| N1_N2_same_faculty | 4860 | 4860 | 0 | 100.00% |
| decision_pattern | 4860 | 4860 | 0 | 100.00% |

## 4.3 Comparacion `judgments_analysis` vs recomputo desde `processed_clean`

| columna | filas_totales | filas_iguales | diferencias | igualdad_pct |
|---|---|---|---|---|
| N1_faculty | 4860 | 4860 | 0 | 100.00% |
| N2_faculty | 4860 | 4860 | 0 | 100.00% |
| N1_decision | 4860 | 4860 | 0 | 100.00% |
| N2_decision | 4860 | 4860 | 0 | 100.00% |
| victim_N1_group | 4860 | 4860 | 0 | 100.00% |
| victim_N2_group | 4860 | 4860 | 0 | 100.00% |
| bystander_victim_group | 4860 | 4860 | 0 | 100.00% |
| bystander_N1_group | 4860 | 4860 | 0 | 100.00% |
| bystander_N2_group | 4860 | 4860 | 0 | 100.00% |
| N1_N2_same_faculty | 4860 | 4860 | 0 | 100.00% |
| decision_pattern | 4860 | 4860 | 0 | 100.00% |

## 4.4 Tablas de frecuencia de variables derivadas

| variable | valor | n | porcentaje |
|---|---|---|---|
| victim_N1_group | ingroup | 1682 | 34.61% |
| victim_N1_group | outgroup | 3178 | 65.39% |
| victim_N2_group | ingroup | 1578 | 32.47% |
| victim_N2_group | outgroup | 3282 | 67.53% |
| bystander_victim_group |  | 2430 | 50.00% |
| bystander_victim_group | ingroup | 1212 | 24.94% |
| bystander_victim_group | outgroup | 1218 | 25.06% |
| bystander_N1_group |  | 2430 | 50.00% |
| bystander_N1_group | ingroup | 812 | 16.71% |
| bystander_N1_group | outgroup | 1618 | 33.29% |
| bystander_N2_group |  | 2430 | 50.00% |
| bystander_N2_group | ingroup | 798 | 16.42% |
| bystander_N2_group | outgroup | 1632 | 33.58% |
| N1_N2_same_faculty | different | 3276 | 67.41% |
| N1_N2_same_faculty | same | 1584 | 32.59% |
| decision_pattern | both_accept | 1214 | 24.98% |
| decision_pattern | both_reject | 1352 | 27.82% |
| decision_pattern | target_accept_other_reject | 1147 | 23.60% |
| decision_pattern | target_reject_other_accept | 1147 | 23.60% |

# 5. Ejemplos concretos con filas reales

## 5.1 Dos ejemplos con `target == 1`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | victim_N1_group | victim_N2_group | N1_N2_same_faculty | decision_pattern |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1s1 | bystander | 1 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 1 | 0 | 0 | 0 | 1 | 0 | outgroup | outgroup | same | target_accept_other_reject |
| 3 | 1s2 | bystander | 1 | 1 | Humanities | 1 | Humanities | 2 | Engineering | 1 | Humanities | 0 | 1 | 1 | 1 | 0 | 1 | outgroup | outgroup | same | target_reject_other_accept |

- Fila `1` (`id_case` 1s1): como `target == 1`, la codificacion activa exige `N1_decision = decision_target` y `N2_decision = decision_other`; en los datos se observa `N1_decision = 1` y `N2_decision = 0`.
- Fila `3` (`id_case` 1s2): como `target == 1`, la codificacion activa exige `N1_decision = decision_target` y `N2_decision = decision_other`; en los datos se observa `N1_decision = 0` y `N2_decision = 1`.

## 5.2 Dos ejemplos con `target == 2`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | victim_N1_group | victim_N2_group | N1_N2_same_faculty | decision_pattern |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 2 | 1s1 | bystander | 2 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 0 | 1 | 0 | 0 | 1 | 0 | outgroup | outgroup | same | target_reject_other_accept |
| 4 | 1s2 | bystander | 2 | 1 | Humanities | 1 | Humanities | 2 | Engineering | 1 | Humanities | 1 | 0 | 1 | 1 | 0 | 1 | outgroup | outgroup | same | target_accept_other_reject |

- Fila `2` (`id_case` 1s1): como `target == 2`, la codificacion activa exige `N1_decision = decision_other` y `N2_decision = decision_target`; en los datos se observa `N1_decision = 1` y `N2_decision = 0`.
- Fila `4` (`id_case` 1s2): como `target == 2`, la codificacion activa exige `N1_decision = decision_other` y `N2_decision = decision_target`; en los datos se observa `N1_decision = 0` y `N2_decision = 1`.

## 5.3 Dos ejemplos de codificacion `ingroup`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | victim_N1_group |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 9 | 1s5 | bystander | 1 | 2 | Engineering | 2 | Engineering | 2 | Engineering | 1 | Humanities | 0 | 0 | 2 | 2 | 0 | 0 | ingroup |
| 10 | 1s5 | bystander | 2 | 2 | Engineering | 2 | Engineering | 2 | Engineering | 1 | Humanities | 0 | 0 | 2 | 2 | 0 | 0 | ingroup |

- Fila `9` (`id_case` 1s5): `victim_N1_group = ingroup` porque las facultades de referencia/actor en esa fila son `Engineering` y `Engineering`.
- Fila `10` (`id_case` 1s5): `victim_N1_group = ingroup` porque las facultades de referencia/actor en esa fila son `Engineering` y `Engineering`.

## 5.4 Dos ejemplos de codificacion `outgroup`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | victim_N1_group |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1s1 | bystander | 1 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 1 | 0 | 0 | 0 | 1 | 0 | outgroup |
| 2 | 1s1 | bystander | 2 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 0 | 1 | 0 | 0 | 1 | 0 | outgroup |

- Fila `1` (`id_case` 1s1): `victim_N1_group = outgroup` porque las facultades de referencia/actor en esa fila son `Humanities` y `Control`.
- Fila `2` (`id_case` 1s1): `victim_N1_group = outgroup` porque las facultades de referencia/actor en esa fila son `Humanities` y `Control`.

## 5.5 Dos ejemplos con `N1_N2_same_faculty == same`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | N1_N2_same_faculty |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1s1 | bystander | 1 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 1 | 0 | 0 | 0 | 1 | 0 | same |
| 2 | 1s1 | bystander | 2 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 0 | 1 | 0 | 0 | 1 | 0 | same |

- Fila `1` (`id_case` 1s1): `N1_N2_same_faculty = same` porque `N1_faculty = 0` y `N2_faculty = 0`.
- Fila `2` (`id_case` 1s1): `N1_N2_same_faculty = same` porque `N1_faculty = 0` y `N2_faculty = 0`.

## 5.6 Dos ejemplos con `N1_N2_same_faculty == different`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | N1_N2_same_faculty |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 11 | 1s6 | victim | 1 | 2 | Engineering | 0 | Control | 1 | Humanities | 1 | Humanities | 0 | 1 | 2 | 0 | 0 | 1 | different |
| 12 | 1s6 | victim | 2 | 0 | Control | 2 | Engineering | 1 | Humanities | 1 | Humanities | 1 | 0 | 2 | 0 | 0 | 1 | different |

- Fila `11` (`id_case` 1s6): `N1_N2_same_faculty = different` porque `N1_faculty = 2` y `N2_faculty = 0`.
- Fila `12` (`id_case` 1s6): `N1_N2_same_faculty = different` porque `N1_faculty = 2` y `N2_faculty = 0`.

### Ejemplo de `decision_pattern = both_accept`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | decision_pattern |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 25 | 2s3 | bystander | 1 | 0 | Control | 2 | Engineering | 1 | Humanities | 1 | Humanities | 1 | 1 | 0 | 2 | 1 | 1 | both_accept |

- Fila `25` (`id_case` 2s3): `decision_pattern = both_accept` porque `decision_target = 1` y `decision_other = 1`.

### Ejemplo de `decision_pattern = both_reject`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | decision_pattern |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 9 | 1s5 | bystander | 1 | 2 | Engineering | 2 | Engineering | 2 | Engineering | 1 | Humanities | 0 | 0 | 2 | 2 | 0 | 0 | both_reject |

- Fila `9` (`id_case` 1s5): `decision_pattern = both_reject` porque `decision_target = 0` y `decision_other = 0`.

### Ejemplo de `decision_pattern = target_accept_other_reject`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | decision_pattern |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1s1 | bystander | 1 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 1 | 0 | 0 | 0 | 1 | 0 | target_accept_other_reject |

- Fila `1` (`id_case` 1s1): `decision_pattern = target_accept_other_reject` porque `decision_target = 1` y `decision_other = 0`.

### Ejemplo de `decision_pattern = target_reject_other_accept`

| source_row_number | id_case | role_label | target | faculty_target | faculty_target_label | faculty_other | faculty_other_label | faculty_victim | faculty_victim_label | faculty_player | faculty_player_label2 | decision_target | decision_other | N1_faculty | N2_faculty | N1_decision | N2_decision | decision_pattern |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 2 | 1s1 | bystander | 2 | 0 | Control | 0 | Control | 1 | Humanities | 1 | Humanities | 0 | 1 | 0 | 0 | 1 | 0 | target_reject_other_accept |

- Fila `2` (`id_case` 1s1): `decision_pattern = target_reject_other_accept` porque `decision_target = 0` y `decision_other = 1`.

# 6. Comprobacion explicita del caso Control

| prueba | filas_con_datos | filas_esperadas_ok | filas_no_ok |
|---|---|---|---|
| Variables relacionales activas (`victim_*`, `bystander_*`): Control vs Control -> ingroup | 0 | 0 | 0 |
| Variables relacionales activas (`victim_*`, `bystander_*`): Control vs Humanities/Engineering -> outgroup | 0 | 0 | 0 |
| Regla base `derive_group_relation()` aplicada a pares reales `N1_faculty` vs `N2_faculty`: Control vs Control -> ingroup | 546 | 546 | 0 |
| Regla base `derive_group_relation()` aplicada a pares reales `N1_faculty` vs `N2_faculty`: Control vs Humanities/Engineering -> outgroup | 2222 | 2222 | 0 |

Interpretacion: en las variables relacionales activas de H2/H3/H5 no hay filas con facultad de referencia `Control`, por lo que ese caso no aparece directamente en esas columnas. Sin embargo, al evaluar la misma regla de `derive_group_relation()` sobre pares reales `N1_faculty`/`N2_faculty`, se observa evidencia empirica consistente: `Control-Control` se codifica como `ingroup` y `Control-Humanities/Engineering` como `outgroup`.

# 7. Relacion con H2/H3/H5

Se reviso `R/hypotheses/H_formulas.R` y el catalogo activo (`outputs/tables/hypothesis_formula_catalog.csv`). H2/H3/H5 usan variables relacionales reconstruidas por rol (`victim_N1_group`, `victim_N2_group`, `bystander_victim_group`, `bystander_N1_group`, `bystander_N2_group`, `N1_N2_same_faculty`) y terminos de decision (`decision_target`, `decision_other`).

Verificacion de presencia de terminos activos:

| termino | presente_en_H2_H3_H5 |
|---|---|
| victim_N1_group | TRUE |
| victim_N2_group | TRUE |
| bystander_victim_group | TRUE |
| bystander_N1_group | TRUE |
| bystander_N2_group | TRUE |
| N1_N2_same_faculty | TRUE |
| decision_target | TRUE |
| decision_other | TRUE |

Verificacion de terminos legacy (`group_target`, `group_other`) en formulas H2/H3/H5:

| termino_legacy | aparece_en_H2_H3_H5 |
|---|---|
| group_target | FALSE |
| group_other | FALSE |

# 8. Conclusion de auditoria

La evidencia empirica observada coincide con la logica de codificacion implementada en el pipeline activo. La reconstruccion de `N1/N2`, la derivacion de variables relacionales por rol, `N1_N2_same_faculty` y `decision_pattern` es consistente con los datos reales analizados, sin inconsistencias estructurales en las validaciones ejecutadas.

## Archivos de codigo inspeccionados

- `R/utils/build_role_relational_variables.R`
- `R/04_generate_variables.R`
- `R/utils/prepare_consolidated_dataset.R`
- `R/hypotheses/H_formulas.R`

## Datasets usados para verificacion

- `C:/Users/LEONA/Documents/GitHub/TOBIT/data/processed/02_cleaned.csv`
- `C:/Users/LEONA/Documents/GitHub/TOBIT/data/processed/judgments_analysis.csv`
- `C:/Users/LEONA/Documents/GitHub/TOBIT/outputs/tables/hypothesis_formula_catalog.csv`

## Ruta del entregable

- `auditoria_codificacion_ingroup_outgroup_es.md`
