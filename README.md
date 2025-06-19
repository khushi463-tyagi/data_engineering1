# data_engineering1


## select * from player_seasons
Retrieves all rows from the player_seasons table.
/n
This table stores season-wise stats of players.
/n
Likely includes fields like player_name, season, pts, reb, etc.
/n
Used as a source for building or updating the players table.

## create type season_stats as (...)
Defines a composite type season_stats with fields: season, gp, pts, reb, and ast.

Used for storing structured season data inside an array in the players table.

Helps in compactly representing a player's performance over multiple seasons.

Makes it easier to store and unnest complex stat records.

## Create table players (...)
Creates the players table with player metadata and an array of season_stats.

Uses composite type season_stats[] to store multi-season performance.

current_season indicates the latest season stored.

Composite primary key ensures uniqueness per player-season.

CTE with yesterday and today + full outer join
sql
Copy
Edit
WITH yesterday AS (...), today AS (...)


## SELECT * FROM today t FULL OUTER JOIN yesterday y ON t.player_name = y.player_name
Joins player data from previous (players) and current (player_seasons) seasons.

full outer join ensures inclusion of all players—new, existing, or inactive.

Used to compare or merge old and new data before insertion.

Essential for time-series player tracking.

## insert into players ... (first version)
Inserts new or updated player data for season 2001 into players.

Uses COALESCE to merge metadata from old and new sources.

Appends new season_stats if available or keeps existing ones.

Increments current_season appropriately.

## select * from players where current_season=2001;
Fetches all player records updated to 2001.

Used to verify insert/update correctness.

Shows combined metadata and performance arrays.

## select player_name, unnest(season_stats)...
Unnests season_stats[] for Michael Jordan to view each season individually.

Useful for inspecting per-season stats from the array structure.

Converts each array element into a row for analysis.

WITH unnested AS (...) SELECT ...
Same as above but uses a CTE to extract and then expand season_stats fields.

Shows season, GP, PTS, REB, AST as columns per row.

Easier for reporting and aggregation.

## drop table players;
Deletes the players table.

Used to reset or modify table schema.

## create type scoring_class as enum(...)
Defines a new enum type scoring_class for classifying player scoring.

Enum values: 'star', 'good', 'average', 'bad'.

Used in updated players table to categorize scoring ability.

## Recreate players table (with new fields)
Adds scoring_class and years_since_last_season to track form and gaps.

season_stats still stored as array.

Allows richer analytics (like classifying players and gaps).

## insert into players (second version)
Similar to the first insert but also calculates:

scoring_class based on pts thresholds.

years_since_last_season to track inactive periods.

Keeps season_stats updated and classifies players for 2001.

Handles both returning and missing players via full outer join.

## select * from players where current_season = 2001;
Lists updated player data with scoring class and gap in seasons.

Useful after insertion to see if data was classified correctly.

## select player_name, season_stats[1], season_stats[...]
Gets each player’s first and latest season in terms of full records.

Uses array slicing and cardinality() to access ends of the stats array.

Helpful for tracking career progression.

## select player_name, (season_stats[1]).pts, ...
Extracts just pts from first and latest seasons.

Easier comparison of performance over time.

## select player_name, ... pts ratio
Computes ratio of latest points to first season’s points.

Protects against divide-by-zero with a conditional fallback.

Identifies improvement or decline.

## select ... order by ratio desc;
Same as above, but sorts players by improvement in scoring.

Helps identify most improved or declining players
