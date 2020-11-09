-- Prerequisites

DROP TABLE toys;

create table toys (
  toy_name       varchar2(30),
  weight         integer,
  price          number(5,2),
  purchased_date date,
  last_lost_date date
);

insert into toys values ('Miss Snuggles', 4,  9.99,  date'2018-02-01', date'2018-06-01');
insert into toys values ('Baby Turtle',   1,  5.00,  date'2016-09-01', date'2017-03-03');
insert into toys values ('Kangaroo',      10, 29.99, date'2017-03-01', date'2018-06-01');
insert into toys values ('Blue Dinosaur', 8,  9.99,  date'2013-07-01', date'2016-11-01');
insert into toys values ('Purple Ninja',  8,  29.99, date'2018-02-01', null);

commit;

-- Complete the following query, so it sorts the rows by:

-- Weight, lightest to heaviest
-- Toys with the same weight by purchased date from the last bought to the first:

SELECT toy_name, weight, TO_CHAR(purchased_date, 'DD-MON-YYYY')FROM toys
ORDER BY weight, purchased_date DESC;

-- Complete the query to sort the rows by:

-- Price, cheapest to most expensive
-- Toys with same price by date last lost, from newest to oldest. 
-- Rows with a null last_lost_date should appear above any of the same price

SELECT toy_name, price, TO_CHAR(last_lost_date, 'DD-MON-YYYY')FROM toys
ORDER BY price, last_lost_date DESC NULLS FIRST;

-- sort the toys by name. But Miss Snuggles is your favourite,
-- so you want this to always appear at the top. 
-- All the toys after should appear alphabetically.

SELECT toy_name
FROM toys
ORDER BY CASE
        WHEN toy_name = 'Miss Snuggles' THEN 1
        ELSE 2
        END,toy_name;

-- This makes it clearer what you're doing. And your code more resilient to changes!
        
SELECT toy_name, CASE WHEN
                    toy_name = 'Miss Snuggles' THEN 1
                    ELSE 2
                    END first_toy
FROM toys
ORDER by first_toy, toy_name;

-- write the query, so:

-- Kangaroo is top
-- Blue Dinosaur is second
-- The remaining toys are ordered by price, cheapest to most expensive

SELECT toy_name, price FROM
(
SELECT toy_name, price,
CASE WHEN toy_name = 'Kangaroo' THEN 1
WHEN toy_name = 'Blue Dinosaur' THEN 2
ELSE 3 END custom
FROM toys
ORDER BY custom, price);

-- A top-N query returns the first N rows in a sorted data set. 
-- For example, to find the three cheapest toys.

-- Rownum is an Oracle-specific function. 
-- It assigns an increasing number to each row you fetch.

SELECT * FROM 
    (SELECT toy_name, price
    FROM toys
    ORDER BY price)
WHERE ROWNUM <= 3;

-- Row_number is an analytic function. 
-- Like rownum, it assigns an incrementing counter. 

SELECT toy_name, rn, price FROM
    (SELECT t.*, ROW_NUMBER() OVER (ORDER BY price) rn FROM toys t)
WHERE rn <= 3;

-- Oracle Database 12c introduced the ANSI compliant fetch first clause.

SELECT toy_name, price
FROM toys
ORDER BY price
FETCH FIRST 3 ROWS WITH TIES;

-- Using aforementioned functions we retrieve only 3 rows and no more
-- if we would like to retrieve also toys that have the same price as the last price in our order:

SELECT toy_name, price
FROM toys
ORDER BY price DESC
FETCH FIRST 3 ROWS WITH TIES;

SELECT toy_name, rn, price FROM
    (SELECT t.*, RANK() OVER (ORDER BY price DESC) rn FROM toys t)
WHERE rn <= 3;

-- the clauses above will retrieve all rows that have the same price as the
-- last one in order. If we want to retireve all toys with 3 the cheapest price:

SELECT toy_name, rn, price FROM
    (SELECT t.*, DENSE_RANK() OVER (ORDER BY price) rn FROM toys t)
WHERE rn <= 3;

/*
You create and populate a table of brick details as follows:
*/
DROP TABLE bricks;
create table bricks (
  colour varchar2(20),
  height integer,
  width  integer,
  depth  integer
);

insert into bricks values ('blue',   10, 20, 10);
insert into bricks values ('green',  15, 15, 10);
insert into bricks values ('red',    10, 10, 10);
insert into bricks values ('yellow', 10,  5, 10);
commit;
/*
Which of the following choices sort the data so that:

the red brick row appears first
the remaining rows are sorted by increasing volume ( height * width * depth )
i.e. the query returns the data above in the following order:

COLOUR   HEIGHT   WIDTH   DEPTH    
red            10      10      10 
yellow         10       5      10 
blue           10      20      10 
green          15      15      10
Note: only consider the order of the output. The choices may include extra columns not shown above and still be correct.
*/

SELECT * from bricks;

SELECT b.*,
        CASE WHEN colour ='red' THEN 1
        ELSE 2 
        END custom
FROM bricks b
ORDER BY custom, b.height*b.width*b.depth;
