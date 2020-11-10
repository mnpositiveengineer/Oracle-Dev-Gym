DROP TABLE match_results;

create table match_results (
  match_date       date,
  location         varchar2(20),
  home_team_name   varchar2(20),
  away_team_name   varchar2(20),
  home_team_points integer,
  away_team_points integer
);

insert into match_results values ( date'2018-01-01', 'Snowley', 'Underrated United', 'Terrible Town', 2, 0 );
insert into match_results values ( date'2018-01-01', 'Coldgate', 'Average Athletic', 'Champions City', 1, 4 );
insert into match_results values ( date'2018-02-01', 'Dorwall', 'Terrible Town', 'Average Athletic', 0, 1 );
insert into match_results values ( date'2018-03-01', 'Coldgate', 'Average Athletic', 'Underrated United', 3, 3 );
insert into match_results values ( date'2018-03-02', 'Newdell', 'Champions City', 'Terrible Town', 8, 0 );

commit;

-- how many games have been played in each location. 

SELECT location, count(*) FROM match_results GROUP BY location;

-- show the locations as columns instead of rows.

SELECT
    COUNT(CASE WHEN location = 'Newdell' THEN 1 END) Newdell,
    COUNT(CASE WHEN location = 'Snowley' THEN 1 END) Snowley,
    COUNT(CASE WHEN location = 'Coldgate' THEN 1 END) Coldgate,
    COUNT(CASE WHEN location = 'Dorwall' THEN 1 END) Dorwall
FROM match_results;

-- using pivot clause

SELECT * FROM (SELECT location FROM match_results)
PIVOT (COUNT(*) FOR location IN 
('Newdell', 'Snowley', 'Coldgate', 'Dorwall'));

-- show the locations as columns, with date of the last match played in each

SELECT * FROM (SELECT TO_CHAR(match_date, 'DD-MON-YYYY') match_date, 
                location FROM match_results)
PIVOT (MAX(match_date) FOR location IN 
('Newdell', 'Snowley', 'Coldgate', 'Dorwall')); 

-- show the team names as columns, with the number of home games each has played:

SELECT * FROM match_results;

SELECT * FROM (SELECT home_team_name FROM match_results)
PIVOT (COUNT(*) FOR home_team_name IN 
('Underrated United', 
'Average Athletic', 
'Terrible Town',  
'Champions City'));

-- see the number of games played each month, showing the months as columns.

SELECT * FROM
(SELECT TO_CHAR(match_date, 'MON') match_month FROM match_results)
PIVOT (COUNT(*) FOR match_month IN ('STY', 'LUT', 'MAR'));

--  show a table of the number of matches played each month in each location

SELECT * FROM
(SELECT TO_CHAR(match_date, 'MON') match_month, location FROM match_results)
PIVOT (COUNT(*) FOR match_month IN ('STY', 'LUT', 'MAR'));

--  restrict this to those locations which had at least one match in January

SELECT * FROM
(SELECT TO_CHAR(match_date, 'MON') match_month, location FROM match_results)
PIVOT (COUNT(*) FOR match_month IN ('STY', 'LUT', 'MAR'))
WHERE "'STY'" >= 1;

/*
show:
For each location, the number of games played on each day of the week
The three letter abbreviation of each day as columns
The column headings without quotes
Those locations that had one or more games played on Monday

The output of this query should be:

LOCATION   MON   TUE   WED   THU   FRI   SAT   SUN   
Coldgate       1     0     0     1     0     0     0 
Snowley        1     0     0     0     0     0     0
*/

SELECT * FROM
(SELECT location, TO_CHAR(match_date, 'DY') match_day FROM match_results)
PIVOT (COUNT(*) FOR match_day IN 
('PN' PON, 'WT' WTO, 'SR' SRO, 'CZ' CZW, 'PT' PTK))
WHERE PON >= 1;

/*
 for each month you want columns showing:

The number of matches played
The total points scored by the home team
The total points scored by the away team
*/

SELECT * FROM
(SELECT TO_CHAR(match_date, 'MON') 
    match_month, 
    home_team_points, 
    away_team_points
FROM match_results)
PIVOT ( COUNT(*) number_of_maches,
        SUM(home_team_points) home_team_points,
        SUM(away_team_points) away_team_points
        FOR match_month IN ('STY' STY, 'LUT' LUT, 'MAR' MAR));
        
/*
show for each location:

A column counting the number of games played
The total number of points scored at each location ( home_team_points + away_team_points )
The count columns should have the matches suffix. The total points scored the suffix points

he output of this query should be:

SNOWLEY_MATCHES   SNOWLEY_POINTS   COLDGATE_MATCHES   COLDGATE_POINTS   DORWALL_MATCHES   DORWALL_POINTS   NEWDELL_MATCHES   NEWDELL_POINTS   
                1                2                  2                11                 1                1                 1                8 
*/    

SELECT * FROM
(SELECT location, home_team_points, away_team_points FROM match_results)
PIVOT (COUNT(*) matches,
        SUM(home_team_points+away_team_points) points
        FOR location IN
        ('Snowley' SNOWLEY, 
        'Coldgate' COLDGATE, 
        'Dorwall' DORWALL, 
        'Newdell' NEWDELL)); 


-- Unpivoting is the process of taking columns and converting them to rows. 
-- For example, you may want to convert the home & away team names to a single team column.

SELECT location, match_date, home_team_name team_name, 'HOME' home_or_away 
FROM match_results
UNION ALL
SELECT location, match_date, away_team_name team_name, 'AWAY' home_or_away  
FROM match_results;

-- using UNPIVOT clause

SELECT location, match_date, team_name, home_or_away
FROM match_results
UNPIVOT(team_name FOR home_or_away IN
        (home_team_name AS 'HOME',
        away_team_name AS 'AWAY'))
ORDER BY home_or_away DESC, match_date;

-- unpivot the home and away points for each match:
/*
    MATCH_DATE    LOCATION   HOME_OR_AWAY   POINTS   
01-JAN-2018   Coldgate   AWAY                  4 
01-JAN-2018   Coldgate   HOME                  1 
01-JAN-2018   Snowley    AWAY                  0 
01-JAN-2018   Snowley    HOME                  2 
01-FEB-2018   Dorwall    AWAY                  1 
01-FEB-2018   Dorwall    HOME                  0 
01-MAR-2018   Coldgate   AWAY                  3 
01-MAR-2018   Coldgate   HOME                  3 
02-MAR-2018   Newdell    AWAY                  0 
02-MAR-2018   Newdell    HOME                  8
*/

SELECT TO_CHAR(match_date, 'DD-MON-YYYY') match_date, location, 
home_or_away, points 
FROM match_results
UNPIVOT(points FOR home_or_away IN
        (home_team_points AS 'HOME', away_team_points AS 'AWAY'))
ORDER BY match_date, location, home_or_away;

/*
You store details of your brick collection in this table:
*/

DROP TABLE bricks;
create table bricks (
  brick_id integer,
  colour   varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 1 );
insert into bricks values ( 2, 'blue', 2 );
insert into bricks values ( 3, 'red', 1 );
insert into bricks values ( 4, 'red', 2 );
insert into bricks values ( 5, 'red', 3 );
insert into bricks values ( 6, 'green', 1 );

commit;

/*
Which of the following queries pivots the weight by colour?

I.e. the query returns one row with the columns red, green, and blue. 
Each column displays the total weight of the rows of that colour, like so:

RED   GREEN   BLUE   
    6       1      3 
*/

SELECT * FROM
(SELECT colour, weight FROM bricks)
PIVOT (SUM(weight) FOR colour IN
            ('red' RED, 'green' GREEN, 'blue' BLUE));

SELECT SUM(CASE WHEN colour = 'red' THEN weight END) RED,
    SUM(CASE WHEN colour = 'green' THEN weight END) GREEN,
    SUM(CASE WHEN colour = 'blue' THEN weight END) BLUE
FROM bricks;

/*
You store details of the number of bricks you have of each colour and shape in this table:
*/
DROP TABLE brick_counts;
create table brick_counts (
  shape varchar2(10),
  red   integer,
  green integer,
  blue  integer
);

insert into brick_counts values ( 'cube', 2, 4, 1 );
insert into brick_counts values ( 'pyramid', 1, 2, 1 );

commit;

/*
You want to convert the colour columns to rows.

Which of the following queries will do this, so you get this output?

SHAPE     COLOUR   COLOUR_COUNT   
cube      BLUE                  1 
cube      GREEN                 4 
cube      RED                   2 
pyramid   BLUE                  1 
pyramid   GREEN                 2 
pyramid   RED                   1
*/

SELECT * FROM brick_counts;

SELECT shape, colour, colour_count
FROM brick_counts
UNPIVOT (colour_count FOR colour IN
        (blue AS 'BLUE', green AS 'GREEN', red AS 'RED'));
        
SELECT * FROM(
SELECT shape, 'BLUE' colour, blue AS colour_count FROM brick_counts
UNION ALL
SELECT shape, 'GREEN' colour, green AS colour_count FROM brick_counts
UNION ALL
SELECT shape, 'RED' colour, red AS colour_count FROM brick_counts)
ORDER BY shape, colour;
