-- =============================================================================
-- Esquema de la BBDD Sakila — DDL limpio (PostgreSQL)
-- Proyecto: DataProject LógicaConsultasSQL — Máster en Análisis de Datos
-- Descripción: Definición de las 15 tablas que componen la BBDD Sakila,
--              con tipos, claves primarias y claves foráneas.
-- Uso: este archivo documenta la estructura. Las tablas reales se crean al
--      importar el dump BBDD_Proyecto_shakila_sinuser.sql.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Tipo ENUM para la clasificación MPAA de las películas
-- -----------------------------------------------------------------------------
CREATE TYPE mpaa_rating AS ENUM ('G', 'PG', 'PG-13', 'R', 'NC-17');


-- -----------------------------------------------------------------------------
-- TABLAS DE REFERENCIA GEOGRÁFICA
-- -----------------------------------------------------------------------------

-- country: catálogo de países
CREATE TABLE country (
    country_id  SERIAL       PRIMARY KEY,
    country     VARCHAR(50)  NOT NULL,
    last_update TIMESTAMP    NOT NULL DEFAULT now()
);

-- city: catálogo de ciudades; cada ciudad pertenece a un país
CREATE TABLE city (
    city_id     SERIAL       PRIMARY KEY,
    city        VARCHAR(50)  NOT NULL,
    country_id  INTEGER      NOT NULL REFERENCES country(country_id),
    last_update TIMESTAMP    NOT NULL DEFAULT now()
);

-- address: direcciones físicas usadas por staff, customer y store
CREATE TABLE address (
    address_id  SERIAL       PRIMARY KEY,
    address     VARCHAR(50)  NOT NULL,
    address2    VARCHAR(50),
    district    VARCHAR(20)  NOT NULL,
    city_id     INTEGER      NOT NULL REFERENCES city(city_id),
    postal_code VARCHAR(10),
    phone       VARCHAR(20)  NOT NULL,
    last_update TIMESTAMP    NOT NULL DEFAULT now()
);


-- -----------------------------------------------------------------------------
-- TABLAS DE CATÁLOGO DE PELÍCULAS
-- -----------------------------------------------------------------------------

-- language: idiomas disponibles
CREATE TABLE language (
    language_id SERIAL    PRIMARY KEY,
    name        CHAR(20)  NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT now()
);

-- category: categorías de películas (16 géneros en Sakila)
CREATE TABLE category (
    category_id SERIAL       PRIMARY KEY,
    name        VARCHAR(25)  NOT NULL,
    last_update TIMESTAMP    NOT NULL DEFAULT now()
);

-- actor: actores
CREATE TABLE actor (
    actor_id    SERIAL       PRIMARY KEY,
    first_name  VARCHAR(45)  NOT NULL,
    last_name   VARCHAR(45)  NOT NULL,
    last_update TIMESTAMP    NOT NULL DEFAULT now()
);

-- film: ficha maestra de cada película
CREATE TABLE film (
    film_id              SERIAL       PRIMARY KEY,
    title                VARCHAR(255) NOT NULL,
    description          TEXT,
    release_year         INTEGER,
    language_id          INTEGER      NOT NULL REFERENCES language(language_id),
    original_language_id INTEGER      REFERENCES language(language_id),
    rental_duration      SMALLINT     NOT NULL DEFAULT 3,
    rental_rate          NUMERIC(4,2) NOT NULL DEFAULT 4.99,
    length               SMALLINT,
    replacement_cost     NUMERIC(5,2) NOT NULL DEFAULT 19.99,
    rating               mpaa_rating  DEFAULT 'G',
    last_update          TIMESTAMP    NOT NULL DEFAULT now(),
    special_features     TEXT[],
    fulltext             TSVECTOR     NOT NULL
);

-- film_actor: tabla puente N:M entre actor y film
CREATE TABLE film_actor (
    actor_id    INTEGER   NOT NULL REFERENCES actor(actor_id),
    film_id     INTEGER   NOT NULL REFERENCES film(film_id),
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (actor_id, film_id)
);

-- film_category: tabla puente N:M entre film y category
CREATE TABLE film_category (
    film_id     INTEGER   NOT NULL REFERENCES film(film_id),
    category_id INTEGER   NOT NULL REFERENCES category(category_id),
    last_update TIMESTAMP NOT NULL DEFAULT now(),
    PRIMARY KEY (film_id, category_id)
);


-- -----------------------------------------------------------------------------
-- TABLAS OPERATIVAS (tiendas, personal, clientes)
-- -----------------------------------------------------------------------------

-- store: cada tienda física del videoclub
CREATE TABLE store (
    store_id         SERIAL    PRIMARY KEY,
    manager_staff_id INTEGER   NOT NULL,
    address_id       INTEGER   NOT NULL REFERENCES address(address_id),
    last_update      TIMESTAMP NOT NULL DEFAULT now()
);

-- staff: empleados de las tiendas
CREATE TABLE staff (
    staff_id    SERIAL       PRIMARY KEY,
    first_name  VARCHAR(45)  NOT NULL,
    last_name   VARCHAR(45)  NOT NULL,
    address_id  INTEGER      NOT NULL REFERENCES address(address_id),
    email       VARCHAR(50),
    store_id    INTEGER      NOT NULL REFERENCES store(store_id),
    active      BOOLEAN      NOT NULL DEFAULT TRUE,
    username    VARCHAR(16)  NOT NULL,
    password    VARCHAR(40),
    last_update TIMESTAMP    NOT NULL DEFAULT now(),
    picture     BYTEA
);

-- customer: clientes registrados, ligados a una tienda principal
CREATE TABLE customer (
    customer_id SERIAL       PRIMARY KEY,
    store_id    INTEGER      NOT NULL REFERENCES store(store_id),
    first_name  VARCHAR(45)  NOT NULL,
    last_name   VARCHAR(45)  NOT NULL,
    email       VARCHAR(50),
    address_id  INTEGER      NOT NULL REFERENCES address(address_id),
    activebool  BOOLEAN      NOT NULL DEFAULT TRUE,
    create_date DATE         NOT NULL DEFAULT CURRENT_DATE,
    last_update TIMESTAMP    DEFAULT now(),
    active      INTEGER
);


-- -----------------------------------------------------------------------------
-- TABLAS TRANSACCIONALES (inventario, alquileres, pagos)
-- -----------------------------------------------------------------------------

-- inventory: copias físicas de cada película en cada tienda
CREATE TABLE inventory (
    inventory_id SERIAL    PRIMARY KEY,
    film_id      INTEGER   NOT NULL REFERENCES film(film_id),
    store_id     INTEGER   NOT NULL REFERENCES store(store_id),
    last_update  TIMESTAMP NOT NULL DEFAULT now()
);

-- rental: cada acto de alquiler de una copia concreta por un cliente
CREATE TABLE rental (
    rental_id    SERIAL    PRIMARY KEY,
    rental_date  TIMESTAMP NOT NULL,
    inventory_id INTEGER   NOT NULL REFERENCES inventory(inventory_id),
    customer_id  INTEGER   NOT NULL REFERENCES customer(customer_id),
    return_date  TIMESTAMP,
    staff_id     INTEGER   NOT NULL REFERENCES staff(staff_id),
    last_update  TIMESTAMP NOT NULL DEFAULT now()
);

-- payment: pagos asociados a uno o varios alquileres
CREATE TABLE payment (
    payment_id   SERIAL       PRIMARY KEY,
    customer_id  INTEGER      NOT NULL REFERENCES customer(customer_id),
    staff_id     INTEGER      NOT NULL REFERENCES staff(staff_id),
    rental_id    INTEGER      NOT NULL REFERENCES rental(rental_id),
    amount       NUMERIC(5,2) NOT NULL,
    payment_date TIMESTAMP    NOT NULL
);


-- =============================================================================
-- Resumen de relaciones clave
-- =============================================================================
--  film ─┬─ language        (idioma actual y original)
--        ├─ film_actor ── actor          (N:M reparto)
--        ├─ film_category ── category    (N:M géneros)
--        └─ inventory ── rental ── payment / customer / staff
--
--  customer / staff / store ── address ── city ── country
-- =============================================================================
