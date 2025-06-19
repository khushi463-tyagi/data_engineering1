select * from player_seasons


create type season_stats as (
season INTEGER,
	gp INTEGER,
	pts REAL,
	reb REAL,
	ast REAL
)

Create table players (
player_name TEXT,
	height TEXT,
	college TEXT,
	country TEXT,
	draft_year TEXT,
	draft_round TEXT,
	draft_number TEXT,
	season_stats season_stats[],
	current_season INTEGER,
	Primary key(player_name,current_season)
)

WITH yesterday AS (
    SELECT * 
    FROM players
    WHERE current_season = 1995
),
today AS (
    SELECT * 
    FROM player_seasons
    WHERE season = 1996
)
select *
from today t full outer join yesterday y
on t.player_name =y.player_name 


insert into players
WITH yesterday AS (
    SELECT * 
    FROM players
    WHERE current_season = 2000
),
today AS (
    SELECT * 
    FROM player_seasons
    WHERE season = 2001
)
select 
COALESCE(t.player_name,y.player_name) AS player_name,
COALESCE(t.height,y.height) AS height,
COALESCE(t.college,y.college) AS college,
COALESCE(t.country,y.country) AS country,
COALESCE(t.draft_year,y.draft_year) AS draft_year,
COALESCE(t.draft_round,y.draft_round) AS draft_round,
COALESCE(t.draft_number,y.draft_number) AS draft_number,
case when y.season_stats is null
then array[row(
t.season,
t.gp,
	t.pts,
t.reb,
t.ast)::season_stats] 
when t.season is not null then  y.season_stats || array[row(
t.season,
t.gp,
	t.pts,
t.reb,
t.ast)::season_stats] 
else y.season_stats
end,
COALESCE(t.season,y.current_season+1 ) AS current_season
from today t full outer join yesterday y
on t.player_name =y.player_name 


select * from players where current_season=2001;

select player_name,unnest(season_stats)as season_stats from players where current_season=2001 AND player_name='Michael Jordan'

WITH unnested AS (
  SELECT 
    player_name,
    UNNEST(season_stats)::season_stats AS season_stats
  FROM players
  WHERE current_season = 2001 AND player_name = 'Michael Jordan'
)
SELECT 
  player_name,
  (season_stats::season_stats).*
FROM unnested


drop table players;

create type scoring_class as enum('star','good','average','bad');



Create table players (
player_name TEXT,
	height TEXT,
	college TEXT,
	country TEXT,
	draft_year TEXT,
	draft_round TEXT,
	draft_number TEXT,
	season_stats season_stats[],
	scoring_class scoring_class,
	years_since_last_season INTEGER,
	current_season INTEGER,
	Primary key(player_name,current_season)
)



insert into players
WITH yesterday AS (
    SELECT * 
    FROM players
    WHERE current_season = 2000
),
today AS (
    SELECT * 
    FROM player_seasons
    WHERE season = 2001
)
select 
COALESCE(t.player_name,y.player_name) AS player_name,
COALESCE(t.height,y.height) AS height,
COALESCE(t.college,y.college) AS college,
COALESCE(t.country,y.country) AS country,
COALESCE(t.draft_year,y.draft_year) AS draft_year,
COALESCE(t.draft_round,y.draft_round) AS draft_round,
COALESCE(t.draft_number,y.draft_number) AS draft_number,
case when y.season_stats is null
then array[row(
t.season,
t.gp,
	t.pts,
t.reb,
t.ast)::season_stats] 
when t.season is not null then  y.season_stats || array[row(
t.season,
t.gp,
	t.pts,
t.reb,
t.ast)::season_stats] 
else y.season_stats
end,
 
CASE
  WHEN t.season IS NOT NULL THEN
    CASE
      WHEN t.pts > 20 THEN 'star'
      WHEN t.pts > 15 THEN 'good'
      WHEN t.pts > 10 THEN 'average'
      ELSE 'bad'
    END::scoring_class
  ELSE y.scoring_class
END AS scoring_class,

case 
	when t.season is not null then 0
	else y.years_since_last_season+1
	end as years_since_last_season,
COALESCE(t.season,y.current_season+1 ) AS current_season
from today t full outer join yesterday y
on t.player_name =y.player_name 


select * from players where current_season =2001;



select player_name,
	season_stats[1] as first_season,
	season_stats[cardinality(season_stats)] as latest_season
	from players 
	where current_season=2001;



select player_name,
	(season_stats[1]).pts as first_season,
	(season_stats[cardinality(season_stats)]).pts as latest_season
	from players 
	where current_season=2001;

select player_name,
	(season_stats[cardinality(season_stats)]).pts/
	CASE WHEN (season_stats[1]).pts =0 THEN 1 ELSE (season_stats[1]::season_stats).pts
	END
	from players 
	where current_season=2001;



select player_name,
	(season_stats[cardinality(season_stats)]).pts/
	CASE WHEN (season_stats[1]).pts =0 THEN 1 ELSE (season_stats[1]::season_stats).pts
	END
	from players 
	where current_season=2001
	order by 2 desc;
