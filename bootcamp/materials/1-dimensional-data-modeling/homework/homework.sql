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


WITH current_year AS (
    SELECT
        actorid,
        actor AS name,

        year AS current_year
    FROM actor_films
    WHERE year = 1970
)
SELECT *
FROM current_year cy;