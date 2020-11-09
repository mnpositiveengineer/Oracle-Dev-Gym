-- Prerequisites
DROP TABLE bricks;
create table bricks (
  brick_id integer,
  colour   varchar2(10),
  shape    varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 'cube', 1 );
insert into bricks values ( 2, 'blue', 'pyramid', 2 );
insert into bricks values ( 3, 'red', 'cube', 1 );
insert into bricks values ( 4, 'red', 'cube', 2 );
insert into bricks values ( 5, 'red', 'pyramid', 3 );
insert into bricks values ( 6, 'green', 'pyramid', 1 );

commit;

-- retrieve the total number of rows in bricks table

SELECT COUNT(*) FROM bricks;

-- retrieve the total number of rows in bricks table
-- with preserving rows in the output to see all rows attributes

SELECT b.*, COUNT(*) OVER() total_rows FROM bricks b;

-- get the number of rows and total weight for each colour:

SELECT colour, COUNT(*), SUM(weight)
FROM bricks
GROUP BY colour;

-- return the total weight and count of rows of each colour and includes all the rows:

SELECT b.*,
        COUNT(*) OVER(PARTITION BY colour) colour_count,
        SUM(weight) OVER(PARTITION BY colour)colour_weight
FROM bricks b;

-- return the count and average weight of bricks for each shape with all rows included:

SELECT shape,
        COUNT(*) OVER(PARTITION BY shape) shape_count,
        ROUND(AVG(weight) OVER(PARTITION BY shape),2) shape_average_weight
FROM bricks;

-- sort the rows by brick_id. Then shows the total number of rows 
-- and sum of the weights for rows with a brick_id less than or equal to that of the current row:

SELECT brick_id,
        shape,
        weight,
        COUNT(*) OVER(ORDER BY brick_id) running_count,
        SUM(weight) OVER(ORDER BY brick_id) running_weight
FROM bricks;

-- get the running average weight, ordered by brick_id:

SELECT brick_id,
        shape,
        weight,
        ROUND(AVG(weight) OVER(ORDER BY brick_id),2) running_weight_average
FROM bricks;

-- get the running count and weight of rows for each colour, sorted by brick_id

SELECT brick_id,
        colour,
        weight,
        COUNT(*) OVER(PARTITION BY colour ORDER BY brick_id) running_count,
        SUM(weight) OVER(PARTITION BY colour ORDER BY brick_id) running_weight
FROM bricks;

-- retrieve running count and weight of rows sorted by weight

SELECT weight,
        COUNT(*) OVER(ORDER BY weight
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_count,
        SUM(weight) OVER(ORDER BY weight
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_weight
FROM bricks
ORDER BY weight, brick_id;

-- show the total weight of:
-- The current row + the previous row
-- All rows with the same weight as the current + all rows with a weight one less than the current

SELECT brick_id,
        weight,
        SUM(weight) OVER(ORDER BY weight
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) weight1,
        SUM(weight) OVER(ORDER BY weight
        RANGE BETWEEN 1 PRECEDING AND CURRENT ROW) weight2
FROM bricks
ORDER BY weight, brick_id; 

-- Complete the windowing clauses to return:
-- The minimum colour of the two rows before (but not including) the current row
-- The count of rows with the same weight as the current and one value following

SELECT brick_id, colour,
        MIN(colour) OVER(ORDER BY brick_id
        ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) mnimimum_color,
        COUNT(*) OVER(ORDER BY weight
        RANGE BETWEEN CURRENT ROW AND 1 FOLLOWING) count_row
FROM bricks
ORDER BY weight, brick_id;

-- find all the colours you have two or more bricks of with all its details

SELECT * FROM
(SELECT colour, COUNT(*) OVER(PARTITION BY colour) amount_of_colour
FROM bricks)
WHERE amount_of_colour >= 2;

-- find the rows where
-- The total weight for the shape
-- The running weight by brick_id
-- are both greater than four:

SELECT * FROM
(SELECT brick_id, shape, weight,
        SUM(weight) OVER(PARTITION BY shape) total_shape_weight,
        SUM(weight) OVER(ORDER BY brick_id) running_weight
FROM bricks)
WHERE total_shape_weight > 4
AND running_weight> 4;

-- other analytical functions

select brick_id, weight, 
       row_number() over ( order by weight ) rn, 
       rank() over ( order by weight ) rk, 
       dense_rank() over ( order by weight ) dr
from   bricks;

select b.*,
       lag ( shape ) over ( order by brick_id ) prev_shape,
       lead ( shape ) over ( order by brick_id ) next_shape
from   bricks b;

select b.*,
       first_value ( weight ) over ( 
         order by brick_id 
       ) first_weight_by_id,
       last_value ( weight ) over ( 
         order by brick_id 
         range between current row and unbounded following
       ) last_weight_by_id
from   bricks b;

/*
You store toy details in this table:
*/
DROP TABLE toys;

create table toys (
  toy_name varchar2(20),
  weight   integer
);

insert into toys values ( 'Baby Rabbit', 1 );
insert into toys values ( 'Green Rabbit', 2 );
insert into toys values ( 'Pink Rabbit', 2 );
insert into toys values ( 'Kangaroo', 5 );

commit;
/*
Which of the following queries will add the running total of the weights, sorted by weight?

The values for this total must be unique, i.e. 1, 3, 5, and 10 as shown below:

TOY_NAME         WEIGHT   RUNNING_WEIGHT
Baby Rabbit           1                1
Green Rabbit          2                3
Pink Rabbit           2                5
Kangaroo              5               10
Note: Either Green Rabbit or Pink Rabbit could have the running weight of 3 and the other 5. Only consider whether the values for this total always increase.
*/

SELECT toy_name, weight, 
            SUM(weight) OVER (ORDER BY weight
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) running_weight
FROM toys;

SELECT toy_name, weight, 
            SUM(weight) OVER (ORDER BY weight, toy_name) running_weight
FROM toys;