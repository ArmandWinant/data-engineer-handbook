DROP TABLE IF EXISTS actors;
DROP TYPE IF EXISTS film_year;
DROP TYPE IF EXISTS film_info;
DROP TYPE IF EXISTS quality_class;

CREATE TYPE film_info AS (
    filmid TEXT,
    title TEXT,
    votes INTEGER,
    rating REAL
                           );

CREATE TYPE film_year AS (
    year INTEGER,
    films film_info[]
                         );

CREATE TYPE quality_class AS
    ENUM ('star', 'good', 'average', 'bad');

CREATE TABLE actors (
    actorid TEXT,
    name TEXT,
    films film_year[],
    quality_class quality_class,
    is_active BOOLEAN,
    current_year INTEGER,
    PRIMARY KEY (actorid, current_year)
);

INSERT INTO actors
WITH current_year AS (
    SELECT
        actorid,
        actor AS name,
        ARRAY_AGG(ROW(
            filmid,
            film,
            votes,
            rating
            )::film_info) AS films,
        AVG(rating) AS year_rating,
        year
    FROM actor_films
    WHERE year = 2021
    GROUP BY actorid, actor, year
),
    previous_year AS (
        SELECT *
        FROM actors
        WHERE current_year = 2020
    )
SELECT
    COALESCE(py.actorid, cy.actorid) AS actorid,
    COALESCE(py.name, cy.name) AS name,
    CASE WHEN py.films IS NULL
        THEN ARRAY[(
            cy.year,
            cy.films
        )::film_year]
    WHEN cy.films IS NOT NULL
        THEN py.films || ARRAY[(
            cy.year,
            cy.films
        )::film_year]
    ELSE py.films
    END AS films,
    CASE WHEN cy.films IS NOT NULL THEN
        (CASE WHEN cy.year_rating > 8 THEN 'star'
            WHEN cy.year_rating > 7 THEN 'good'
            WHEN cy.year_rating > 6 THEN 'average'
            ELSE 'bad'
        END)::quality_class
    ELSE py.quality_class
    END AS quality_class,
    cy.films IS NOT NULL AS is_active,
    COALESCE(cy.year, py.current_year + 1) AS current_year
FROM current_year cy
FULL OUTER JOIN previous_year py
ON cy.actorid = py.actorid;