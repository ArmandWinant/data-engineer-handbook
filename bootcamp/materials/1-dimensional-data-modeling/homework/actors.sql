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