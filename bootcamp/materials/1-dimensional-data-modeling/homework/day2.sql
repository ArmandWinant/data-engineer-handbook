DROP TABLE players_scd;
CREATE TABLE IF NOT EXISTS players_scd (
    player_name TEXT,
    scoring_class scoring_class,
    is_active BOOLEAN,
    start_season INTEGER,
    end_season INTEGER,
    current_season INTEGER, -- date partition
    PRIMARY KEY (player_name, start_season)
);

INSERT INTO players_scd
WITH with_previous AS (SELECT player_name,
                         current_season,
                         scorer_class,
                         is_active,
                         LAG(scorer_class, 1)
                         OVER (PARTITION BY player_name ORDER BY current_season)                   AS previous_scoring_class,
                         LAG(is_active, 1) OVER (PARTITION BY player_name ORDER BY current_season) AS previous_is_active
                  FROM players
                  WHERE current_season <= 2021
),
    with_indicators AS (
        SELECT
            *,
            CASE
                WHEN scorer_class <> previous_scoring_class THEN 1
                WHEN is_active <> previous_is_active THEN 1
                ELSE 0
            END AS change_indicator
        FROM with_previous
    ),
    with_streaks AS (
        SELECT
            *,
            SUM(change_indicator) OVER (PARTITION BY player_name ORDER BY current_season) AS streak_identifier
        FROM with_indicators
    )
SELECT
    player_name,
    scorer_class,
    is_active,
    MIN(current_season) AS start_season,
    MAX(current_season) AS end_season,
    2021 AS current_season -- parameter
FROM with_streaks
GROUP BY player_name, streak_identifier, is_active, scorer_class
ORDER BY player_name, streak_identifier


SELECT * FROM players_scd;