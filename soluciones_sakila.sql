-- =============================================================================
-- DataProject: LógicaConsultasSQL — Base de datos Sakila (PostgreSQL)
-- Autor: Miguel Ángel Bartolomé Talavera
-- Fecha: 19/05/2026
-- Descripción: Soluciones a los 64 ejercicios del proyecto SQL
--
-- Constructos utilizados (los enseñados en el máster):
--   - Consultas básicas:        SELECT, FROM, WHERE, AS
--   - Agregación:               MIN, MAX, COUNT, SUM, AVG, STDDEV, VARIANCE, CONCAT
--   - Ordenación / agrupación:  ORDER BY, LIMIT, OFFSET, GROUP BY, HAVING
--   - Relaciones entre tablas:  INNER JOIN, LEFT JOIN, RIGHT JOIN, CROSS JOIN, FULL JOIN
--   - Subconsultas:             en WHERE (escalar / EXISTS / NOT EXISTS), en SELECT, en FROM
--   - Vistas:                   CREATE VIEW
--   - Estructuras temporales:   CTEs (WITH ...)
-- =============================================================================


-- =============================================================================
-- BLOQUE 1: Consultas sobre una sola tabla
-- Cubre requisito: "Manejo de las consultas con una sola tabla de tu BBDD"
-- =============================================================================

-- Ejercicio 1: Esquema de la BBDD
-- DDL comentado (las tablas ya existen tras importar el dump BBDD_Proyecto_shakila_sinuser.sql).
-- Se incluye CREATE TABLE IF NOT EXISTS para documentar la estructura sin alterar la BBDD.
/*
CREATE TYPE mpaa_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17');

CREATE TABLE IF NOT EXISTS actor (
    actor_id    SERIAL PRIMARY KEY,
    first_name  VARCHAR(45) NOT NULL,
    last_name   VARCHAR(45) NOT NULL,
    last_update TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS country (
    country_id  SERIAL PRIMARY KEY,
    country     VARCHAR(50) NOT NULL,
    last_update TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS city (
    city_id     SERIAL PRIMARY KEY,
    city        VARCHAR(50) NOT NULL,
    country_id  INTEGER     NOT NULL REFERENCES country(country_id),
    last_update TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS address (
    address_id  SERIAL PRIMARY KEY,
    address     VARCHAR(50) NOT NULL,
    address2    VARCHAR(50),
    district    VARCHAR(20) NOT NULL,
    city_id     INTEGER     NOT NULL REFERENCES city(city_id),
    postal_code VARCHAR(10),
    phone       VARCHAR(20) NOT NULL,
    last_update TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS language (
    language_id SERIAL PRIMARY KEY,
    name        CHAR(20)  NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS category (
    category_id SERIAL PRIMARY KEY,
    name        VARCHAR(25) NOT NULL,
    last_update TIMESTAMP   NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS film (
    film_id              SERIAL PRIMARY KEY,
    title                VARCHAR(255) NOT NULL,
    description          TEXT,
    release_year         INTEGER,
    language_id          INTEGER       NOT NULL REFERENCES language(language_id),
    original_language_id INTEGER       REFERENCES language(language_id),
    rental_duration      SMALLINT      NOT NULL DEFAULT 3,
    rental_rate          NUMERIC(4,2)  NOT NULL DEFAULT 4.99,
    length               SMALLINT,
    replacement_cost     NUMERIC(5,2)  NOT NULL DEFAULT 19.99,
    rating               mpaa_rating   DEFAULT 'G',
    last_update          TIMESTAMP     NOT NULL DEFAULT now(),
    special_features     TEXT[],
    fulltext             TSVECTOR      NOT NULL
);

CREATE TABLE IF NOT EXISTS film_actor (
    actor_id    INTEGER NOT NULL REFERENCES actor(actor_id),
    film_id     INTEGER NOT NULL REFERENCES film(film_id),
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (actor_id, film_id)
);

CREATE TABLE IF NOT EXISTS film_category (
    film_id     INTEGER NOT NULL REFERENCES film(film_id),
    category_id INTEGER NOT NULL REFERENCES category(category_id),
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (film_id, category_id)
);

CREATE TABLE IF NOT EXISTS store (
    store_id         SERIAL PRIMARY KEY,
    manager_staff_id INTEGER   NOT NULL,
    address_id       INTEGER   NOT NULL REFERENCES address(address_id),
    last_update      TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS staff (
    staff_id    SERIAL PRIMARY KEY,
    first_name  VARCHAR(45) NOT NULL,
    last_name   VARCHAR(45) NOT NULL,
    address_id  INTEGER     NOT NULL REFERENCES address(address_id),
    email       VARCHAR(50),
    store_id    INTEGER     NOT NULL REFERENCES store(store_id),
    active      BOOLEAN     NOT NULL DEFAULT TRUE,
    username    VARCHAR(16) NOT NULL,
    password    VARCHAR(40),
    last_update TIMESTAMP   NOT NULL DEFAULT now(),
    picture     BYTEA
);

CREATE TABLE IF NOT EXISTS customer (
    customer_id SERIAL PRIMARY KEY,
    store_id    INTEGER     NOT NULL REFERENCES store(store_id),
    first_name  VARCHAR(45) NOT NULL,
    last_name   VARCHAR(45) NOT NULL,
    email       VARCHAR(50),
    address_id  INTEGER     NOT NULL REFERENCES address(address_id),
    activebool  BOOLEAN     NOT NULL DEFAULT TRUE,
    create_date DATE        NOT NULL DEFAULT CURRENT_DATE,
    last_update TIMESTAMP   DEFAULT now(),
    active      INTEGER
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id SERIAL PRIMARY KEY,
    film_id      INTEGER   NOT NULL REFERENCES film(film_id),
    store_id     INTEGER   NOT NULL REFERENCES store(store_id),
    last_update  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS rental (
    rental_id    SERIAL PRIMARY KEY,
    rental_date  TIMESTAMP NOT NULL,
    inventory_id INTEGER   NOT NULL REFERENCES inventory(inventory_id),
    customer_id  INTEGER   NOT NULL REFERENCES customer(customer_id),
    return_date  TIMESTAMP,
    staff_id     INTEGER   NOT NULL REFERENCES staff(staff_id),
    last_update  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS payment (
    payment_id   SERIAL PRIMARY KEY,
    customer_id  INTEGER       NOT NULL REFERENCES customer(customer_id),
    staff_id     INTEGER       NOT NULL REFERENCES staff(staff_id),
    rental_id    INTEGER       NOT NULL REFERENCES rental(rental_id),
    amount       NUMERIC(5,2)  NOT NULL,
    payment_date TIMESTAMP     NOT NULL
);
*/


-- Ejercicio 2: Películas con clasificación 'R'
-- Filtro simple con WHERE sobre el ENUM rating.
SELECT title
FROM film
WHERE rating = 'R'
ORDER BY title;


-- Ejercicio 3: Actores con actor_id entre 30 y 40
-- Rango cerrado expresado con dos comparaciones AND (equivalente a BETWEEN).
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id >= 30
  AND actor_id <= 40
ORDER BY actor_id;


-- Ejercicio 5: Películas ordenadas por duración ascendente
-- ORDER BY length ASC.
SELECT title, length
FROM film
ORDER BY length ASC;


-- Ejercicio 6: Actores con 'Allen' en el apellido
-- LIKE con comodines %...% busca la subcadena. Los datos están en mayúsculas.
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%ALLEN%';


-- Ejercicio 8: Películas 'PG-13' o con duración > 180 min
-- OR lógico entre dos predicados de WHERE.
SELECT title, rating, length
FROM film
WHERE rating = 'PG-13'
   OR length > 180;


-- Ejercicio 10: Mayor y menor duración de película
-- Agregados MAX y MIN; AS para renombrar las columnas de salida.
SELECT MAX(length) AS duracion_maxima,
       MIN(length) AS duracion_minima
FROM film;


-- Ejercicio 12: Películas que no son 'NC-17' ni 'G'
-- Dos comparaciones de desigualdad encadenadas con AND.
SELECT title, rating
FROM film
WHERE rating <> 'NC-17'
  AND rating <> 'G';


-- Ejercicio 14: Películas con duración > 180 minutos
-- Filtro simple con WHERE.
SELECT title, length
FROM film
WHERE length > 180
ORDER BY length DESC;


-- Ejercicio 16: 10 clientes con mayor customer_id
-- ORDER BY DESC + LIMIT 10.
SELECT customer_id, first_name, last_name, email
FROM customer
ORDER BY customer_id DESC
LIMIT 10;


-- Ejercicio 18: Títulos únicos de películas
-- DISTINCT en SELECT elimina duplicados (en Sakila ya son únicos).
SELECT DISTINCT title
FROM film
ORDER BY title;


-- Ejercicio 22: Columna concatenada nombre + apellido de actores
-- CONCAT une cadenas; AS asigna nombre legible a la columna calculada.
SELECT actor_id,
       CONCAT(first_name, ' ', last_name) AS nombre_completo
FROM actor
ORDER BY actor_id;


-- Ejercicio 35: Actores cuyo primer nombre es 'Johnny'
-- Igualdad exacta con los datos en mayúsculas almacenados en Sakila.
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'JOHNNY';


-- Ejercicio 36: Renombrar columnas first_name y last_name
-- AS con alias entrecomillados para conservar mayúsculas y la tilde.
SELECT first_name AS "Nombre",
       last_name  AS "Apellido"
FROM actor
ORDER BY "Apellido", "Nombre";


-- Ejercicio 37: ID del actor más bajo y más alto
-- MIN y MAX sobre la clave primaria.
SELECT MIN(actor_id) AS id_minimo,
       MAX(actor_id) AS id_maximo
FROM actor;


-- Ejercicio 38: Cuenta de actores en la tabla actor
-- COUNT(*) cuenta filas; equivale a COUNT(actor_id) al no haber NULLs en la PK.
SELECT COUNT(*) AS total_actores
FROM actor;


-- Ejercicio 39: Actores ordenados por apellido ascendente
-- ORDER BY last_name ASC (ASC es el orden por defecto, se explicita).
SELECT actor_id, first_name, last_name
FROM actor
ORDER BY last_name ASC;


-- Ejercicio 40: Primeras 5 películas de film
-- LIMIT 5 sobre un ORDER BY explícito para reproducibilidad.
SELECT film_id, title, release_year, rating, length
FROM film
ORDER BY film_id
LIMIT 5;


-- =============================================================================
-- BLOQUE 2: Agregaciones y GROUP BY
-- Cubre requisito: "Manejo de las consultas con una sola tabla de tu BBDD"
-- =============================================================================

-- Ejercicio 7: Cantidad de películas por clasificación (rating)
-- COUNT(*) agrupado por rating con GROUP BY.
SELECT rating,
       COUNT(*) AS num_peliculas
FROM film
GROUP BY rating
ORDER BY num_peliculas DESC;


-- Ejercicio 9: Variabilidad del replacement_cost
-- VARIANCE = varianza muestral en PostgreSQL; STDDEV = desviación estándar muestral.
SELECT VARIANCE(replacement_cost) AS varianza,
       STDDEV(replacement_cost)   AS desviacion_estandar
FROM film;


-- Ejercicio 13: Promedio de duración por clasificación
-- AVG sobre length agrupado por rating; AS para etiquetar la salida.
SELECT rating,
       AVG(length) AS promedio_duracion
FROM film
GROUP BY rating
ORDER BY promedio_duracion DESC;


-- Ejercicio 15: Total de dinero generado por la empresa
-- SUM sobre amount de payment. Resultado: 67.416,51 €.
SELECT SUM(amount) AS total_ingresos
FROM payment;


-- Ejercicio 21: Media de rental_duration
-- AVG sobre rental_duration (días que dura cada alquiler según ficha de la película).
SELECT AVG(rental_duration) AS media_rental_duration
FROM film;


-- Ejercicio 23: Número de alquileres por día (descendente)
-- CAST(rental_date AS DATE) trunca el timestamp a fecha; COUNT(*) cuenta los alquileres.
SELECT CAST(rental_date AS DATE) AS dia,
       COUNT(*)                  AS num_alquileres
FROM rental
GROUP BY CAST(rental_date AS DATE)
ORDER BY num_alquileres DESC;


-- Ejercicio 25: Número de alquileres por mes
-- TO_CHAR(..., 'YYYY-MM') agrupa por año-mes (útil para reporting).
SELECT TO_CHAR(rental_date, 'YYYY-MM') AS mes,
       COUNT(*)                        AS num_alquileres
FROM rental
GROUP BY TO_CHAR(rental_date, 'YYYY-MM')
ORDER BY mes;


-- Ejercicio 26: Promedio, desviación estándar y varianza del total pagado
-- AVG + STDDEV + VARIANCE sobre payment.amount.
SELECT AVG(amount)      AS media,
       STDDEV(amount)   AS desviacion_estandar,
       VARIANCE(amount) AS varianza
FROM payment;


-- Ejercicio 41: Actores agrupados por nombre (¿cuál es el más repetido?)
-- GROUP BY + COUNT(*) sobre first_name; ORDER BY descendente para ver el más repetido.
SELECT first_name,
       COUNT(*) AS num_actores
FROM actor
GROUP BY first_name
ORDER BY num_actores DESC, first_name;
-- Respuesta: hay un empate triple en el primer puesto — JULIA, KENNETH y PENELOPE,
-- cada uno con 4 actores. Ningún nombre aparece estrictamente más veces que los demás.


-- =============================================================================
-- BLOQUE 3: JOINs — relaciones entre tablas
-- Cubre requisito: "Manejo de las relaciones entre tablas"
-- (INNER JOIN, LEFT JOIN, RIGHT JOIN, CROSS JOIN, FULL JOIN)
-- =============================================================================

-- Ejercicio 4: Películas cuyo idioma coincide con el idioma original
-- INNER JOIN con language; en Sakila original_language_id es NULL en las 1.000 filas,
-- por lo que la igualdad nunca se cumple y la consulta devuelve 0 filas.
SELECT f.film_id,
       f.title,
       l.name AS idioma
FROM film f
INNER JOIN language l ON l.language_id = f.language_id
WHERE f.language_id = f.original_language_id;


-- Ejercicio 17: Actores de la película 'Egg Igby'
-- N:M actor ↔ film vía la tabla puente film_actor (dos INNER JOINs).
SELECT a.first_name,
       a.last_name
FROM actor a
INNER JOIN film_actor fa ON fa.actor_id = a.actor_id
INNER JOIN film f        ON f.film_id   = fa.film_id
WHERE f.title = 'EGG IGBY'
ORDER BY a.last_name, a.first_name;


-- Ejercicio 19: Comedias con duración > 180 min
-- INNER JOIN encadenado: film → film_category → category.
SELECT f.title,
       f.length
FROM film f
INNER JOIN film_category fc ON fc.film_id     = f.film_id
INNER JOIN category c       ON c.category_id  = fc.category_id
WHERE c.name = 'Comedy'
  AND f.length > 180
ORDER BY f.length DESC;


-- Ejercicio 20: Categorías con promedio de duración > 110 min
-- HAVING filtra sobre el agregado AVG (WHERE no admite agregados).
SELECT c.name AS categoria,
       AVG(f.length) AS promedio_duracion
FROM category c
INNER JOIN film_category fc ON fc.category_id = c.category_id
INNER JOIN film f           ON f.film_id      = fc.film_id
GROUP BY c.name
HAVING AVG(f.length) > 110
ORDER BY promedio_duracion DESC;


-- Ejercicio 29: Películas con cantidad disponible en inventario (LEFT JOIN)
-- LEFT JOIN preserva las películas sin copias en inventario (COUNT devolverá 0).
SELECT f.film_id,
       f.title,
       COUNT(i.inventory_id) AS unidades_disponibles
FROM film f
LEFT JOIN inventory i ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY f.title;


-- Ejercicio 30: Actores y número de películas en las que han actuado
-- LEFT JOIN para no perder actores que (hipotéticamente) no hayan participado en ninguna.
SELECT a.actor_id,
       a.first_name,
       a.last_name,
       COUNT(fa.film_id) AS num_peliculas
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY num_peliculas DESC, a.last_name;


-- Ejercicio 31: Películas con actores (LEFT JOIN film → film_actor → actor)
-- Incluye las 3 películas sin actores asociados (los campos del lado actor serán NULL).
SELECT f.film_id,
       f.title,
       a.actor_id,
       a.first_name,
       a.last_name
FROM film f
LEFT JOIN film_actor fa ON fa.film_id  = f.film_id
LEFT JOIN actor a       ON a.actor_id  = fa.actor_id
ORDER BY f.title, a.last_name;


-- Ejercicio 32: Actores con sus películas (RIGHT JOIN)
-- RIGHT JOIN tal y como pide el enunciado: conserva todos los actores (lado derecho)
-- aunque no tuvieran películas asociadas.
SELECT a.actor_id,
       a.first_name,
       a.last_name,
       f.film_id,
       f.title
FROM film f
RIGHT JOIN film_actor fa ON fa.film_id  = f.film_id
RIGHT JOIN actor a       ON a.actor_id  = fa.actor_id
ORDER BY a.last_name, a.first_name, f.title;


-- Ejercicio 33: Todas las películas y todos los registros de alquiler
-- Versión solicitada (producto cartesiano limitado) con CROSS JOIN.
-- 1.000 películas × 16.044 alquileres = 16.044.000 filas → se aplica LIMIT.
SELECT f.film_id,
       f.title,
       r.rental_id,
       r.rental_date
FROM film f
CROSS JOIN rental r
LIMIT 100;

-- Alternativa con FULL OUTER JOIN: muestra cada película junto a sus alquileres reales
-- (vía inventory), conservando películas sin alquilar y, en su caso, alquileres huérfanos.
-- Más informativa analíticamente que el producto cartesiano puro.
SELECT f.film_id,
       f.title,
       r.rental_id,
       r.rental_date
FROM film f
FULL OUTER JOIN inventory i ON i.film_id      = f.film_id
FULL OUTER JOIN rental r    ON r.inventory_id = i.inventory_id
ORDER BY f.title, r.rental_date
LIMIT 100;


-- Ejercicio 42: Alquileres con nombres de clientes
-- INNER JOIN: la FK customer_id NOT NULL garantiza que todos los alquileres tienen cliente.
SELECT r.rental_id,
       r.rental_date,
       c.customer_id,
       c.first_name,
       c.last_name
FROM rental r
INNER JOIN customer c ON c.customer_id = r.customer_id
ORDER BY r.rental_id;


-- Ejercicio 43: Clientes con sus alquileres (incluyendo sin alquileres)
-- LEFT JOIN para conservar clientes sin alquileres (en Sakila no hay, pero la consulta
-- es la correcta para el caso general).
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       r.rental_id,
       r.rental_date
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
ORDER BY c.customer_id, r.rental_date;


-- Ejercicio 45: Actores en películas de categoría 'Action'
-- DISTINCT porque un actor puede salir en varias películas de la misma categoría.
SELECT DISTINCT a.actor_id,
                a.first_name,
                a.last_name
FROM actor a
INNER JOIN film_actor fa    ON fa.actor_id    = a.actor_id
INNER JOIN film_category fc ON fc.film_id     = fa.film_id
INNER JOIN category c       ON c.category_id  = fc.category_id
WHERE c.name = 'Action'
ORDER BY a.last_name, a.first_name;


-- Ejercicio 47: Nombre de actores y cantidad de películas
-- Variante del 30 con CONCAT para mostrar el nombre completo.
SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor,
       COUNT(fa.film_id)                      AS num_peliculas
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY num_peliculas DESC, actor;


-- Ejercicio 49: Total de alquileres por cliente
-- LEFT JOIN para incluir clientes sin alquileres (devolverían 0).
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(r.rental_id) AS total_alquileres
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_alquileres DESC, c.last_name;


-- Ejercicio 50: Duración total de películas en categoría 'Action'
-- SUM(length) restringido a la categoría 'Action'. Resultado: 7.143 min.
SELECT c.name AS categoria,
       SUM(f.length) AS duracion_total_minutos
FROM category c
INNER JOIN film_category fc ON fc.category_id = c.category_id
INNER JOIN film f           ON f.film_id      = fc.film_id
WHERE c.name = 'Action'
GROUP BY c.name;


-- Ejercicio 61: Películas alquiladas por categoría (nombre + recuento)
-- Cadena de INNER JOINs: category → film_category → film → inventory → rental.
SELECT c.name AS categoria,
       COUNT(r.rental_id) AS num_alquileres
FROM category c
INNER JOIN film_category fc ON fc.category_id = c.category_id
INNER JOIN film f           ON f.film_id      = fc.film_id
INNER JOIN inventory i      ON i.film_id      = f.film_id
INNER JOIN rental r         ON r.inventory_id = i.inventory_id
GROUP BY c.name
ORDER BY num_alquileres DESC;


-- Ejercicio 62: Películas por categoría estrenadas en 2006
-- COUNT(DISTINCT film_id) por seguridad ante posibles películas con varias categorías.
SELECT c.name AS categoria,
       COUNT(DISTINCT f.film_id) AS num_peliculas
FROM category c
INNER JOIN film_category fc ON fc.category_id = c.category_id
INNER JOIN film f           ON f.film_id      = fc.film_id
WHERE f.release_year = 2006
GROUP BY c.name
ORDER BY c.name;


-- Ejercicio 64: Películas alquiladas por cliente (id, nombre, apellido, cantidad)
-- Equivalente al 49 con la cabecera explícita pedida en el enunciado.
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       COUNT(r.rental_id) AS cantidad
FROM customer c
LEFT JOIN rental r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY cantidad DESC, c.last_name;


-- =============================================================================
-- BLOQUE 4: Subconsultas
-- Cubre requisito: "Manejo de las subconsultas"
-- Tipos usados: en WHERE (escalar / EXISTS / NOT EXISTS), en SELECT, en FROM
-- =============================================================================

-- Ejercicio 11: Coste del antepenúltimo alquiler ordenado por fecha
-- "Antepenúltimo" = 3.º empezando por el final → ORDER BY rental_date DESC + OFFSET 2.
-- Muchos alquileres comparten timestamp final (2006-02-14 15:16:03); se desempata
-- por rental_id DESC para reproducibilidad.
SELECT r.rental_id,
       r.rental_date,
       p.amount AS coste
FROM rental r
LEFT JOIN payment p ON p.rental_id = r.rental_id
ORDER BY r.rental_date DESC, r.rental_id DESC
OFFSET 2 LIMIT 1;


-- Ejercicio 24: Películas con duración superior al promedio
-- Subconsulta escalar en WHERE — se evalúa una sola vez y se compara con cada fila.
SELECT title,
       length
FROM film
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY length DESC;


-- Ejercicio 27: Películas que se alquilan por encima del rental_rate medio
-- Mismo patrón que el 24 pero sobre rental_rate (subconsulta escalar en WHERE).
SELECT title,
       rental_rate
FROM film
WHERE rental_rate > (SELECT AVG(rental_rate) FROM film)
ORDER BY rental_rate DESC, title;


-- Ejercicio 28: IDs de actores en más de 40 películas
-- GROUP BY + HAVING. Resultado: actor_id 107 (42 films) y 102 (41 films).
SELECT actor_id,
       COUNT(*) AS num_peliculas
FROM film_actor
GROUP BY actor_id
HAVING COUNT(*) > 40
ORDER BY num_peliculas DESC;


-- Ejercicio 34: Los 5 clientes que más dinero se han gastado
-- SUM(amount) agrupado por cliente, ORDER BY total DESC + LIMIT 5.
-- Se incluye además una subconsulta en SELECT para mostrar el % sobre el total facturado.
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       SUM(p.amount) AS total_gastado,
       SUM(p.amount) / (SELECT SUM(amount) FROM payment) * 100 AS pct_sobre_total
FROM customer c
INNER JOIN payment p ON p.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_gastado DESC
LIMIT 5;


-- Ejercicio 46: Actores que NO han participado en ninguna película
-- NOT EXISTS sobre film_actor correlada por actor_id. En Sakila devuelve 0 filas
-- (los 200 actores tienen al menos una película asignada).
SELECT a.actor_id,
       a.first_name,
       a.last_name
FROM actor a
WHERE NOT EXISTS (
    SELECT 1
    FROM film_actor fa
    WHERE fa.actor_id = a.actor_id
)
ORDER BY a.last_name, a.first_name;


-- Ejercicio 53: Títulos alquilados por 'Tammy Sanders' sin devolver
-- EXISTS correlada: para cada película, comprueba si existe un alquiler suyo por Tammy
-- Sanders todavía abierto (return_date IS NULL).
SELECT DISTINCT f.title
FROM film f
WHERE EXISTS (
    SELECT 1
    FROM rental r
    INNER JOIN inventory i ON i.inventory_id = r.inventory_id
    INNER JOIN customer c  ON c.customer_id  = r.customer_id
    WHERE i.film_id = f.film_id
      AND c.first_name = 'TAMMY'
      AND c.last_name  = 'SANDERS'
      AND r.return_date IS NULL
)
ORDER BY f.title;


-- Ejercicio 54: Actores en películas de categoría 'Sci-Fi' (orden apellido)
-- EXISTS correlada por actor_id sobre film_actor → film_category → category.
SELECT a.first_name,
       a.last_name
FROM actor a
WHERE EXISTS (
    SELECT 1
    FROM film_actor fa
    INNER JOIN film_category fc ON fc.film_id     = fa.film_id
    INNER JOIN category c       ON c.category_id  = fc.category_id
    WHERE fa.actor_id = a.actor_id
      AND c.name      = 'Sci-Fi'
)
ORDER BY a.last_name, a.first_name;


-- Ejercicio 55: Actores en películas alquiladas tras el primer alquiler de 'Spartacus Cheaper'
-- CTE 'primer_alquiler' calcula la fecha mínima de alquiler de esa película;
-- EXISTS correlada filtra actores cuyas películas se alquilaron después de esa fecha.
WITH primer_alquiler AS (
    SELECT MIN(r.rental_date) AS fecha
    FROM rental r
    INNER JOIN inventory i ON i.inventory_id = r.inventory_id
    INNER JOIN film f      ON f.film_id      = i.film_id
    WHERE f.title = 'SPARTACUS CHEAPER'
)
SELECT a.first_name,
       a.last_name
FROM actor a
WHERE EXISTS (
    SELECT 1
    FROM film_actor fa
    INNER JOIN inventory i ON i.film_id      = fa.film_id
    INNER JOIN rental r    ON r.inventory_id = i.inventory_id
    WHERE fa.actor_id  = a.actor_id
      AND r.rental_date > (SELECT fecha FROM primer_alquiler)
)
ORDER BY a.last_name, a.first_name;


-- Ejercicio 56: Actores que NO han actuado en películas de categoría 'Music'
-- NOT EXISTS correlada por actor_id, negando la participación en categoría 'Music'.
SELECT a.actor_id,
       a.first_name,
       a.last_name
FROM actor a
WHERE NOT EXISTS (
    SELECT 1
    FROM film_actor fa
    INNER JOIN film_category fc ON fc.film_id     = fa.film_id
    INNER JOIN category c       ON c.category_id  = fc.category_id
    WHERE fa.actor_id = a.actor_id
      AND c.name      = 'Music'
)
ORDER BY a.last_name, a.first_name;


-- Ejercicio 57: Películas alquiladas por más de 8 días
-- Diferencia (return_date - rental_date) como INTERVAL, comparada con 8 días.
SELECT DISTINCT f.title
FROM film f
INNER JOIN inventory i ON i.film_id      = f.film_id
INNER JOIN rental r    ON r.inventory_id = i.inventory_id
WHERE r.return_date IS NOT NULL
  AND (r.return_date - r.rental_date) > INTERVAL '8 days'
ORDER BY f.title;


-- Ejercicio 58: Películas de la misma categoría que 'Animation'
-- EXISTS correlada por film_id: la película pertenece a la categoría 'Animation'.
-- (En Sakila no existe una película titulada 'ANIMATION'; se interpreta como
--  "películas pertenecientes a la categoría llamada Animation").
SELECT f.title
FROM film f
WHERE EXISTS (
    SELECT 1
    FROM film_category fc
    INNER JOIN category c ON c.category_id = fc.category_id
    WHERE fc.film_id = f.film_id
      AND c.name     = 'Animation'
)
ORDER BY f.title;


-- Ejercicio 59: Películas con la misma duración que 'Dancing Fever'
-- Subconsulta escalar en WHERE; excluye la propia película.
SELECT title,
       length
FROM film
WHERE length = (SELECT length FROM film WHERE title = 'DANCING FEVER')
  AND title <> 'DANCING FEVER'
ORDER BY title;


-- Ejercicio 60: Clientes que han alquilado al menos 7 películas distintas
-- Subconsulta en FROM ('sub') con GROUP BY + HAVING sobre películas distintas;
-- el JOIN principal recupera los datos del cliente.
SELECT c.customer_id,
       c.first_name,
       c.last_name,
       sub.peliculas_distintas
FROM customer c
INNER JOIN (
    SELECT r.customer_id,
           COUNT(DISTINCT i.film_id) AS peliculas_distintas
    FROM rental r
    INNER JOIN inventory i ON i.inventory_id = r.inventory_id
    GROUP BY r.customer_id
    HAVING COUNT(DISTINCT i.film_id) >= 7
) sub ON sub.customer_id = c.customer_id
ORDER BY c.last_name, c.first_name;


-- =============================================================================
-- BLOQUE 5: Vistas
-- Cubre requisito: "Vistas"
-- =============================================================================

-- Ejercicio 48: Vista actor_num_peliculas
-- DROP previo para hacer el script idempotente; la vista expone nombre completo
-- y nº de películas, reutilizable como tabla virtual en consultas posteriores.
DROP VIEW IF EXISTS actor_num_peliculas;
CREATE VIEW actor_num_peliculas AS
SELECT CONCAT(a.first_name, ' ', a.last_name) AS actor,
       COUNT(fa.film_id)                      AS num_peliculas
FROM actor a
LEFT JOIN film_actor fa ON fa.actor_id = a.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name;

-- Consulta de comprobación: los 5 actores con más películas según la vista.
SELECT *
FROM actor_num_peliculas
ORDER BY num_peliculas DESC, actor
LIMIT 5;


-- =============================================================================
-- BLOQUE 6: Estructuras de datos temporales — CTEs (WITH ...)
-- Cubre requisito: "Estructuras de datos temporales con CTEs"
-- Nota: el enunciado original menciona "tabla temporal". Se resuelve con CTEs
-- (Common Table Expressions), que son la estructura temporal explicada en clase
-- y existen únicamente dentro del scope de la consulta que las define.
-- =============================================================================

-- Ejercicio 51: CTE cliente_rentas_temporal
-- WITH define una tabla derivada con el total de alquileres por cliente,
-- consultable inmediatamente después como si fuera una tabla.
WITH cliente_rentas_temporal AS (
    SELECT c.customer_id,
           c.first_name,
           c.last_name,
           COUNT(r.rental_id) AS total_alquileres
    FROM customer c
    LEFT JOIN rental r ON r.customer_id = c.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *
FROM cliente_rentas_temporal
ORDER BY total_alquileres DESC, last_name
LIMIT 10;


-- Ejercicio 52: CTE peliculas_alquiladas (>= 10 alquileres)
-- WITH + HAVING filtra solo películas con 10 o más alquileres (792 películas).
WITH peliculas_alquiladas AS (
    SELECT f.film_id,
           f.title,
           COUNT(r.rental_id) AS num_alquileres
    FROM film f
    INNER JOIN inventory i ON i.film_id      = f.film_id
    INNER JOIN rental r    ON r.inventory_id = i.inventory_id
    GROUP BY f.film_id, f.title
    HAVING COUNT(r.rental_id) >= 10
)
SELECT *
FROM peliculas_alquiladas
ORDER BY num_alquileres DESC, title
LIMIT 10;


-- =============================================================================
-- BLOQUE 7: Casos especiales — CROSS JOIN
-- =============================================================================

-- Ejercicio 44: CROSS JOIN entre film y category
-- Producto cartesiano: 1.000 películas × 16 categorías = 16.000 combinaciones.
SELECT f.film_id,
       f.title,
       c.category_id,
       c.name AS categoria
FROM film f
CROSS JOIN category c
ORDER BY f.film_id, c.category_id
LIMIT 50;  -- limitado por legibilidad; sin LIMIT devolvería 16.000 filas.

-- ¿Aporta valor esta consulta?
-- Respuesta: NO en este caso. La relación real entre film y category es N:M, ya modelada
-- a través de la tabla puente film_category, que indica qué categoría tiene cada película.
-- El CROSS JOIN aquí emparejaría cada película con TODAS las categorías existan o no en
-- film_category, generando 15.000 combinaciones falsas (cada película solo está en 1
-- categoría real). Solo tendría utilidad como base para construir matrices vacías que
-- después se rellenan con LEFT JOIN — un patrón poco habitual y sin valor analítico
-- directo en este dominio.


-- Ejercicio 63: CROSS JOIN entre staff y store
-- 2 empleados × 2 tiendas = 4 combinaciones. Útil, por ejemplo, para listar todas las
-- asignaciones posibles antes de cruzarlas con la tabla real de adscripción.
SELECT s.staff_id,
       s.first_name,
       s.last_name,
       st.store_id
FROM staff s
CROSS JOIN store st
ORDER BY s.staff_id, st.store_id;


-- =============================================================================
-- FIN DEL PROYECTO
-- =============================================================================
