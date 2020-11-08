-- Prerequisites

DROP TABLE bricks;

create table bricks (
  brick_id integer,
  colour   varchar2(10)
);

DROP TABLE colours;

create table colours (
  colour_name           varchar2(10),
  minimum_bricks_needed integer
);

insert into colours values ( 'blue', 2 );
insert into colours values ( 'green', 3 );
insert into colours values ( 'red', 2 );
insert into colours values ( 'orange', 1);
insert into colours values ( 'yellow', 1 );
insert into colours values ( 'purple', 1 );

insert into bricks values ( 1, 'blue' );
insert into bricks values ( 2, 'blue' );
insert into bricks values ( 3, 'blue' );
insert into bricks values ( 4, 'green' );
insert into bricks values ( 5, 'green' );
insert into bricks values ( 6, 'red' );
insert into bricks values ( 7, 'red' );
insert into bricks values ( 8, 'red' );
insert into bricks values ( 9, null );

commit;

-- You use inline views to calculate an intermediate result set. 
-- For example, you can count the number of bricks you have of each colour:

SELECT * FROM
(SELECT colour, COUNT(*)
FROM bricks
GROUP BY colour);

-- You can then join the result of this to the colours table. This allows 
-- you to find out which colours you have fewer bricks of than the 
-- minimum needed defined in colours:

SELECT colour, count, minimum_bricks_needed FROM
(SELECT colour, COUNT(*) count
FROM bricks
GROUP BY colour) b
JOIN colours c
ON c.colour_name = b.colour
WHERE b.count<c.minimum_bricks_needed;

-- Complete the query below, using an inline view 
-- to find the min and max brick_id for each colour of brick:

SELECT * FROM (
SELECT colour, MAX(brick_id), MIN(brick_id)
FROM bricks b
GROUP BY colour);

-- MODULE 4: Nested Subqueries

--  find all the rows in colours where you have a matching brick

SELECT * FROM colours
WHERE colour_name IN 
(SELECT colour FROM bricks);

-- use exists to achieve the same result as before:

SELECT * FROM colours c
WHERE EXISTS
(SELECT 1 FROM bricks b 
WHERE c.colour_name = b.colour);

-- find all the colours that have at least one brick with a brick_id less than 5,

SELECT colour_name FROM colours
WHERE colour_name IN 
(SELECT colour FROM bricks WHERE brick_id < 5);

-- find all the colours that have at least one brick with a brick_id less than 5
-- using EXISTS

SELECT colour_name FROM colours c
WHERE EXISTS 
(SELECT 1 FROM bricks b
WHERE c.colour_name = b.colour
AND b.brick_id < 5);

-- find all the rows in colours without a matching colour in bricks

SELECT * FROM colours c
WHERE NOT EXISTS
(SELECT 1 FROM bricks b
WHERE c.colour_name = b.colour);

-- USING NOT IN WILL RETURN NOTHING, BECAUSE THERE IS NULL VALUE

SELECT * FROM colours
WHERE colour_name NOT IN 
(SELECT colour FROM bricks);

-- WE HAVE TO HANDLE IT

SELECT * FROM colours
WHERE colour_name NOT IN 
(SELECT colour FROM bricks
WHERE colour IS NOT NULL);

-- Complete the subquery to find all the rows in bricks with a colour 
-- where colours.minimum_bricks_needed = 2

SELECT * FROM bricks b
WHERE EXISTS
(SELECT 1 FROM colours c
WHERE c.colour_name = b.colour
AND c.minimum_bricks_needed = 2);

-- return a count of the number of bricks matching each colour. 
-- When null return 0
SELECT c.*,
    NVL((SELECT COUNT(*) FROM bricks b
    WHERE b.colour = c.colour_name
    GROUP BY b.colour),0) number_of_bricks
FROM colours c;

-- find the minimum brick_id for each colour

SELECT c.*,
    (SELECT MIN(brick_id)
        FROM bricks b
        WHERE b.colour = c.colour_name
        GROUP BY b.colour) min_brick_id
FROM colours c;
    
-- CTEs: Reusable Subqueries

-- In one query find which colours you have more bricks 
-- of than the minimum needed and the average number of 
-- bricks you have of each colour
-- use CTE

WITH brick_count AS
    (SELECT colour, COUNT(*) count
    FROM bricks
    GROUP BY colour)
SELECT c.colour_name,(SELECT AVG(count) FROM brick_count)
FROM colours c
WHERE c.minimum_bricks_needed < 
(SELECT count FROM brick_count bc
WHERE bc.colour = c.colour_name);

-- find which bricks you have less of than the average number of each colour
                
WITH colour_count AS
(SELECT b.colour, COUNT(*) amount
FROM bricks b
GROUP BY b.colour)
SELECT * FROM colour_count
WHERE amount < (SELECT AVG(amount) FROM colour_count);


