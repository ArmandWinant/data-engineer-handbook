-- CREATE TABLE IF NOT EXISTS players_scd (
--     player_name TEXT,
--     scoring_class scoring_class,
--     is_active BOOLEAN,
--     start_season INTEGER,
--     end_season INTEGER,
--     current_season INTEGER, -- date partition
--     PRIMARY KEY (player_name, current_season)
-- );

SELECT
    player_name,
    scorer_class,
    is_active
FROM players
WHERE current_season = 2022;

