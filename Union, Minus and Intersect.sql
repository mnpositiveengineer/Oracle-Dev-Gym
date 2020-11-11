-- Prerequisites

DROP TABLE my_brick_collection;
create table my_brick_collection (
  colour varchar2(10),
  shape  varchar2(10),
  weight integer
);

DROP TABLE your_brick_collection;
create table your_brick_collection (
  height integer,
  width  integer,
  depth  integer,
  colour varchar2(10),
  shape  varchar2(10)
);

insert into my_brick_collection values ( 'red', 'cube', 10 );
insert into my_brick_collection values ( 'blue', 'cuboid', 8 );
insert into my_brick_collection values ( 'green', 'pyramid', 20 );
insert into my_brick_collection values ( 'green', 'pyramid', 20 );
insert into my_brick_collection values ( null, 'cuboid', 20 );

insert into your_brick_collection values ( 2, 2, 2, 'red', 'cube' );
insert into your_brick_collection values ( 2, 2, 2, 'blue', 'cube' );
insert into your_brick_collection values ( 2, 2, 8, null, 'cuboid' );

commit;

-- return a list of all the colours in the two tables

/*
The output of this query should be:

COLOUR   
blue     
green    
red      
<null>
*/

SELECT colour FROM my_brick_collection
UNION
SELECT colour FROM your_brick_collection;

-- return a list of all the shapes in both tables. 
-- There must show one row for each row in the source tables

/*
This query should return the following rows:

SHAPE       
cube      
cube      
cube      
cuboid    
cuboid    
cuboid    
pyramid   
pyramid 
*/

SELECT shape FROM my_brick_collection
UNION ALL
SELECT shape FROM your_brick_collection
ORDER BY shape;

-- return all the colours and shapes in one table not in another.

SELECT colour, shape FROM my_brick_collection mc
WHERE NOT EXISTS (SELECT 1 FROM your_brick_collection bc
                    WHERE (mc.colour = bc.colour OR 
                    (mc.colour IS NULL AND bc.colour IS NULL))
                    AND (mc.shape = bc.shape OR
                    mc.shape IS NULL AND bc.shape IS NULL));
                    
-- using minus operator (duplicates will be removed)

SELECT colour, shape FROM my_brick_collection
MINUS
SELECT colour, shape FROM your_brick_collection;

-- find colours and shapes that are in both tables.

SELECT colour, shape FROM my_brick_collection mc
WHERE EXISTS (SELECT 1 FROM your_brick_collection yc
                WHERE (yc.colour = mc.colour OR 
                (yc.colour IS NULL AND mc.colour IS NULL))
                AND (yc.shape = mc.shape OR
                (yc.shape IS NULL AND mc.shape IS NULL)));
                
-- using intersect

SELECT colour, shape FROM my_brick_collection
INTERSECT
SELECT colour, shape FROM your_brick_collection;

-- return a list of all the shapes in my collection not in yours:

SELECT shape FROM my_brick_collection
MINUS
SELECT shape FROM your_brick_collection;

-- return a list of all the colours that are in both tables:

SELECT colour FROM my_brick_collection
INTERSECT
SELECT colour FROM your_brick_collection;

-- FIND all the differences in colour + shape combination, between two tables

(SELECT colour, shape FROM my_brick_collection
MINUS
SELECT colour, shape FROM your_brick_collection)
UNION ALL
(SELECT colour, shape FROM your_brick_collection
MINUS
SELECT colour, shape FROM my_brick_collection);

(SELECT colour, shape FROM my_brick_collection
UNION ALL
SELECT colour, shape FROM your_brick_collection)
MINUS
(SELECT colour, shape FROM my_brick_collection
INTERSECT
SELECT colour, shape FROM your_brick_collection);

-- MINUS will not show the differences in counts of the same values.
-- if we have 1 red cube in 1st table and 2 red cubes in 2nd table
-- minus will not show us this differences
-- plus aforementioned queries need to select 4 times from tables

insert into my_brick_collection values ( 'red', 'cube', 5 );
commit;

SELECT colour, shape, SUM(my_brick), SUM(your_brick), 
    CASE 
        WHEN SUM(my_brick) > SUM(your_brick) THEN 'ME'
        WHEN SUM(my_brick) < SUM(your_brick) THEN 'YOU'
        ELSE
        'EQUAL'
        END more_bricks
FROM
(SELECT colour, shape, 1 my_brick, 0 your_brick
FROM my_brick_collection
UNION ALL
SELECT colour, shape, 0 my_brick, 1 your_brick
FROM your_brick_collection)
GROUP BY colour, shape
HAVING SUM(my_brick) <> SUM(your_brick);

-- You have two tables of bricks:

DROP TABLE left_table_bricks;
create table left_table_bricks (
  colour varchar2(10),
  shape  varchar2(10)
);

DROP TABLE right_table_bricks;
create table right_table_bricks (
  colour varchar2(10),
  shape  varchar2(10)
);

insert into left_table_bricks values ( 'red', 'cube' );
insert into left_table_bricks values ( 'blue', 'cube' );
insert into left_table_bricks values ( 'green', 'pyramid');

insert into right_table_bricks values ( 'blue', 'cube' );
insert into right_table_bricks values ( 'green', 'pyramid' );
insert into right_table_bricks values ( 'red', 'pyramid' );

commit;

/*
You want to find all rows that are only in one of these tables.

Which of the following queries returns these rows?

COLOUR   SHAPE     
red      cube      
red      pyramid 
*/

(SELECT colour, shape FROM left_table_bricks
MINUS
SELECT colour, shape FROM right_table_bricks)
UNION ALL
(SELECT colour, shape FROM right_table_bricks
MINUS
SELECT colour, shape FROM left_table_bricks);

(SELECT colour, shape FROM left_table_bricks
UNION ALL
SELECT colour, shape FROM right_table_bricks)
MINUS
(SELECT colour, shape FROM left_table_bricks
INTERSECT
SELECT colour, shape FROM right_table_bricks);

SELECT colour, shape FROM
(SELECT colour, shape, SUM(left_brick), SUM(right_brick) FROM
(SELECT colour, shape, 1 left_brick, 0 right_brick FROM left_table_bricks
UNION ALL
SELECT colour, shape, 0 left_brick, 1 right_bric FROM right_table_bricks)
GROUP BY colour, shape
HAVING SUM(left_brick) <> SUM(right_brick));