# DataProject — Lógica de Consultas SQL · Base de datos Sakila

**Máster en Análisis de Datos**
**Autor:** Miguel Ángel Bartolomé Talavera
**Usuario GitHub:** [@miguelsanse](https://github.com/miguelsanse)
**Fecha de entrega:** 19/05/2026

---

## 1. Objetivo del proyecto

Resolver 64 consultas SQL sobre la base de datos **Sakila** (modelo clásico de un videoclub) para cubrir los bloques formativos del módulo:

- Consultas sobre una sola tabla
- Agregaciones y `GROUP BY`
- `JOIN`s y relaciones entre tablas
- Subconsultas
- Vistas
- Tablas temporales
- Casos especiales (`CROSS JOIN`)

El entregable principal es el archivo [`soluciones_sakila.sql`](soluciones_sakila.sql) con las 64 consultas comentadas y organizadas por bloques.

---

## 2. Stack técnico

| Componente | Versión / detalle |
|---|---|
| Motor BBDD | PostgreSQL 16 |
| Cliente | DBeaver + `psql` (validación) |
| SO | Windows 11 |
| Idioma | Español (comentarios y entregable) |

---

## 3. Estructura del repositorio

```
Proyecto SQL/
├── README.md                              ← este archivo
├── BBDD_Proyecto_shakila_sinuser.sql      ← dump completo (DDL + datos)
├── esquema.sql                            ← DDL limpio de las 15 tablas
└── soluciones_sakila.sql                  ← 64 consultas resueltas
```

---

## 4. Pasos seguidos durante el proyecto

### 4.1 Importación de la BBDD

```bash
# 1) Crear la base de datos vacía
psql -U postgres -c "CREATE DATABASE sakila;"

# 2) Importar el dump (DDL + INSERTs)
psql -U postgres -d sakila -f BBDD_Proyecto_shakila_sinuser.sql

# 3) Verificar volúmenes esperados
psql -U postgres -d sakila -c \
  "SELECT (SELECT COUNT(*) FROM film)   AS films,
          (SELECT COUNT(*) FROM actor)  AS actors,
          (SELECT COUNT(*) FROM rental) AS rentals;"
```

Resultado esperado: **1.000 películas · 200 actores · 16.044 alquileres**.

### 4.2 Exploración del esquema

Sakila modela un videoclub con 15 tablas agrupadas en 4 áreas funcionales:

- **Catálogo de películas:** `film`, `actor`, `category`, `language`, `film_actor`, `film_category`
- **Infraestructura operativa:** `store`, `staff`, `customer`
- **Inventario y transacciones:** `inventory`, `rental`, `payment`
- **Geografía:** `address`, `city`, `country`

Relaciones clave: `film ─ inventory ─ rental ─ payment / customer / staff` y las tablas puente N:M `film_actor` y `film_category`.

### 4.3 Organización del entregable por bloques

En lugar de resolver los 64 ejercicios en orden numérico, se reorganizaron por **complejidad creciente y técnica SQL** (criterio explícito del enunciado):

| Bloque | Técnica | Nº ejercicios |
|---|---|---|
| 1 | Consultas sobre una sola tabla | 18 |
| 2 | Agregaciones y `GROUP BY` | 9 |
| 3 | `JOIN`s entre tablas | 18 |
| 4 | Subconsultas | 14 |
| 5 | Vistas | 1 |
| 6 | Tablas temporales | 2 |
| 7 | `CROSS JOIN` y casos especiales | 2 |
| **Total** | | **64** |

### 4.4 Ciclo de trabajo por ejercicio

Para cada una de las 64 consultas se siguió el mismo procedimiento:

1. **Redactar** la consulta respetando las convenciones (palabras clave en mayúsculas, `snake_case`, aliases descriptivos, indentación de 4 espacios, terminación con `;`).
2. **Validar** con `psql -U postgres -d sakila -c "..."` y comprobar que los resultados eran coherentes.
3. **Comentar** la lógica en español con `-- Ejercicio N: ...`, explicando la técnica utilizada (no la traducción literal del SQL).
4. **Iterar** si fallaba o devolvía datos incoherentes.

### 4.5 Validación final

El archivo completo se ejecuta de extremo a extremo sin errores:

```bash
psql -U postgres -d sakila -v ON_ERROR_STOP=1 -f soluciones_sakila.sql
```

---

## 5. Convenciones de código aplicadas

- Palabras clave SQL en **MAYÚSCULAS** (`SELECT`, `JOIN`, `GROUP BY`, …).
- Tablas y columnas en **minúsculas con `snake_case`**.
- Aliases cortos y descriptivos: `f` (film), `a` (actor), `c` (customer), `r` (rental), `p` (payment), `fa` (film_actor), `fc` (film_category).
- Cada ejercicio precedido por un comentario `-- Ejercicio N: descripción`.
- Indentación de 4 espacios en subcláusulas.
- Uso de `CTE` (`WITH ...`) en subconsultas complejas (p. ej., Ej. 55) para mejorar la legibilidad.
- `DROP ... IF EXISTS` antes de cada vista o tabla temporal → el script es **idempotente**.
- Se evita `SELECT *` salvo cuando el ejercicio lo pide explícitamente.

---

## 6. Informe de análisis

Las siguientes conclusiones se extraen directamente de las 64 consultas resueltas y reflejan el estado real de la BBDD Sakila.

### 6.1 Dimensiones del negocio

| Métrica | Valor |
|---|---|
| Tiendas físicas | 2 |
| Empleados | 2 |
| Clientes registrados (todos activos) | 599 |
| Países cubiertos | 109 |
| Ciudades | 600 |
| Catálogo de películas | 1.000 |
| Actores | 200 |
| Alquileres registrados | 16.044 |
| Pagos registrados | ~16.000 |
| Periodo de actividad | 24/05/2005 – 14/02/2006 |
| **Ingresos totales** | **67.416,51 €** |

### 6.2 Comportamiento de los clientes (Ej. 34, 49, 60, 64)

- Los **5 mejores clientes por gasto acumulado** son Karl Seal (221,55 €), Eleanor Hunt (216,54 €), Clara Shaw (195,58 €), Rhonda Kennedy y Marion Snyder (194,61 € cada uno).
- Por **número de alquileres**, lidera **Eleanor Hunt con 46 alquileres**, seguida de Karl Seal (45) y Marcia Dean (42).
- **Todos los 599 clientes han alquilado al menos una película**: no hay clientes inactivos en el dataset.
- **599 clientes han alquilado al menos 7 películas distintas** (Ej. 60) → todo el padrón es un consumidor recurrente.
- El **gasto medio por pago** es de **4,20 €**, en un rango entre 0 € (devoluciones / promociones) y 11,99 €.

### 6.3 Catálogo de películas (Ej. 7, 13, 18, 24, 27)

- Distribución por clasificación MPAA: **PG-13 (223)**, NC-17 (210), R (195), PG (194), G (178). La oferta está sesgada hacia el público adolescente/adulto joven.
- **PG-13 también es la clasificación con películas más largas** en promedio (120,44 min), seguida de R (118,66 min).
- **39 películas** duran más de 180 minutos; **489** superan la duración media.
- **659 películas** tienen un `rental_rate` superior a la media → existe una clara estratificación de precios premium.
- **3 películas no tienen ningún actor asociado** (anomalía a revisar en el dataset).

### 6.4 Categorías más rentables (Ej. 20, 50, 61, 62)

- Por **número de alquileres**: **Sports (1.179)**, Animation (1.166), Action (1.112), Sci-Fi y Family completan el top 5.
- Por **ingresos generados**: **Sports (5.314 €)**, Sci-Fi (4.757 €), Animation (4.656 €).
- **Duración media por categoría > 110 min** en 13 de las 16 categorías; lidera **Sports con 128,20 min**.
- La categoría 'Action' acumula **7.143 minutos** de metraje total.
- En 2006 (último año del catálogo) las categorías con más estrenos fueron Animation (66) y Action (64).

### 6.5 Actores (Ej. 28, 30, 41, 46, 47)

- El actor más prolífico es **Gina Degeneres (42 películas)**, seguido de Walter Torn (41) y Mary Keitel (40).
- **Solo 2 actores superan las 40 películas** (`actor_id` 107 y 102).
- Ningún actor de los 200 carece de películas asignadas.
- Hay un **triple empate** en el nombre de pila más repetido: **Julia, Kenneth y Penelope**, con 4 actores cada uno.

### 6.6 Estacionalidad de los alquileres (Ej. 23, 25)

Los alquileres se concentran en un periodo de actividad muy corto:

| Mes | Nº alquileres |
|---|---:|
| 2005-05 | 1.156 |
| 2005-06 | 2.311 |
| **2005-07** | **6.709** ← pico |
| 2005-08 | 5.686 |
| 2006-02 | 182 |

El **pico absoluto** se da el **31/07/2005 con 679 alquileres en un solo día**. Tras agosto de 2005 la actividad cae a cero hasta una pequeña reapertura en febrero de 2006 — patrón compatible con un dataset de prueba más que con un negocio real.

### 6.7 Hallazgos puntuales

- **Idioma original (Ej. 4):** la columna `original_language_id` es `NULL` para las 1.000 películas, por lo que la consulta "películas cuyo idioma coincide con el original" devuelve 0 filas. No es un error de la consulta sino una carencia del dataset.
- **Producto cartesiano (Ej. 33, 44):** las consultas con `CROSS JOIN` masivos (`film × rental` = 16 M filas, `film × category` = 16.000 filas) no aportan valor analítico porque las relaciones reales ya están modeladas mediante tablas puente. Se ejecutan a efectos pedagógicos con `LIMIT`.
- **Antepenúltimo alquiler (Ej. 11):** los últimos 22 alquileres comparten el mismo `timestamp` (`2006-02-14 15:16:03`); fue necesario añadir `rental_id DESC` como criterio de desempate para que el resultado sea reproducible.

---

## 7. Cómo reproducir el proyecto

```bash
# Pre-requisitos: PostgreSQL 16 instalado, psql en el PATH

# 1. Clonar el repositorio
git clone https://github.com/miguelsanse/proyectoSQL.git
cd proyectoSQL

# 2. Crear e importar la BBDD
psql -U postgres -c "CREATE DATABASE sakila;"
psql -U postgres -d sakila -f BBDD_Proyecto_shakila_sinuser.sql

# 3. Ejecutar las 64 consultas
psql -U postgres -d sakila -f soluciones_sakila.sql
```

Alternativamente, abrir `soluciones_sakila.sql` en **DBeaver** conectado a la BBDD `sakila` y ejecutar las consultas por bloques con `Ctrl + Enter`.

---

## 8. Licencia y autoría

Proyecto académico del Máster en Análisis de Datos. La base de datos Sakila es propiedad de Oracle Corporation y se distribuye bajo licencia BSD para uso educativo.
