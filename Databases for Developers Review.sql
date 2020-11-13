
-- You store brick details in this table:

DROP TABLE bricks;
create table bricks (
  colour varchar2(10),
  shape  varchar2(10),
  weight integer,
  price  number(10, 2)
);

insert into bricks values ( 'red', 'cube', 1, 0.99 );
insert into bricks values ( 'red', 'pyramid', null, 1.99 );
insert into bricks values ( 'blue', 'cube', 1, null );
insert into bricks values ( 'green', 'cuboid', 4, 2.99 );

commit;

/*
Which of the following queries return those rows where the price and the weight 
are both less than 2?

For the purposes of this question, you can consider null to be less than two.

So correct queries should return the following rows:

COLOUR   SHAPE     WEIGHT   PRICE    
blue     cube             1   <null> 
red      cube             1     0.99 
red      pyramid     <null>     1.99 
*/

SELECT * FROM bricks
WHERE 
(price < 2 OR price IS NULL)
AND
(weight <  2 OR weight IS NULL)
ORDER BY colour, shape;

SELECT * FROM bricks
WHERE 
NVL(price, 0) < 2
AND
NVL(weight, 0) < 2
ORDER BY colour, shape;

SELECT * FROM bricks
WHERE
COALESCE(weight, price) < 2
ORDER BY colour, shape;


-- You store details of toys and their prices in this table:

DROP TABLE toys;
create table toys (
  toy_name varchar2(20),
  price    number(10, 2)
);

insert into toys values ( 'Baby Turle', 0.01 );
insert into toys values ( 'Miss Snuggles', 10.01 );
insert into toys values ( 'Green Rabbit', 14.03 );
insert into toys values ( 'Pink Rabbit', 14.22 );
insert into toys values ( 'Purple Ninja', 15.55 );

commit;
/*
Which of the following queries will:

Return the rows for toys with a price greater than the average (mean)
Add an average price column to the results?
i.e. give this output:

TOY_NAME       PRICE   MEAN_PRICE   
Green Rabbit     14.03       10.764 
Pink Rabbit      14.22       10.764 
Purple Ninja     15.55       10.764
*/

SELECT toy_name, price, (AVG(price) OVER()) mean
FROM toys t
WHERE (SELECT AVG(price) FROM toys) < price
ORDER BY price;

SELECT toy_name, price, (SELECT AVG(price) FROM toys) mean
FROM toys t
WHERE (SELECT AVG(price) FROM toys) < price
ORDER BY price;

WITH avg_price AS
(SELECT AVG(price) mean FROM toys)
SELECT t.*, (SELECT mean FROM avg_price)
FROM toys t
WHERE (SELECT mean FROM avg_price) < price
ORDER BY price;

WITH avg_price AS
(SELECT AVG(price) mean FROM toys)
SELECT t.*, mean
FROM toys t
JOIN avg_price 
ON mean < price
ORDER BY price;

WITH avg_price AS
(SELECT t.*, AVG(price) OVER() mean FROM toys t)
SELECT * FROM avg_price
WHERE price > mean
ORDER BY price;


-- You store brick details in this table:

DROP TABLE bricks;
create table bricks (
  colour varchar2(10),
  shape  varchar2(10),
  weight integer
);

insert into bricks values ( 'red', 'cube', 10 );
insert into bricks values ( 'red', 'pyramid', 8 );
insert into bricks values ( 'blue', 'cube', 10 );
insert into bricks values ( 'green', 'cuboid', 20 );

commit;

/*
Which of the following queries return the two heaviest bricks, along with any 
that weigh the same as the second heaviest?

So the query should return the following rows:

COLOUR   SHAPE    WEIGHT   
green    cuboid         20 
red      cube           10 
blue     cube           10
The green cuboid must be top. But the order of the cubes doesn't matter. 
Either red or blue could appear second, the other third.
*/

SELECT * FROM bricks;

SELECT * FROM bricks
ORDER BY weight DESC
FETCH FIRST 2 ROWS WITH TIES;

WITH subquery AS
(SELECT b.*, RANK() OVER(ORDER BY weight DESC) rank FROM bricks b)
SELECT colour, shape, weight FROM subquery
WHERE rank <= 2;

WITH subquery AS
(SELECT b.*, DENSE_RANK() OVER(ORDER BY weight DESC) rank FROM bricks b)
SELECT colour, shape, weight FROM subquery
WHERE rank <= 2;


-- You create a table to store brick details and populate it as follows:

DROP TABLE bricks;
create table bricks (
  colour varchar2(10),
  weight integer, 
  price  number(10, 2)
);

insert into bricks values ( 'red',  2,  1 );
insert into bricks values ( 'blue', 4,  1 );
insert into bricks values ( 'red',  6,  4 );
insert into bricks values ( 'blue', 8,  4 );
insert into bricks values ( 'red',  10, 7 );

commit;

/*
Which of the following queries return the average price of each brick 
and the next heaviest and lightest bricks?

So when sorting by weight, the mean includes the rows either side of the current, 
giving this result:

COLOUR   WEIGHT   AVG_PRICE   
red             2           1 
blue            4           2 
red             6           3 
blue            8           5 
red            10         5.5
*/

SELECT colour, weight,
        AVG(price) OVER(ORDER BY weight
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) avg_price
FROM bricks;

SELECT colour, weight,
        AVG(price) OVER(ORDER BY weight
        RANGE BETWEEN 2 PRECEDING AND 2 FOLLOWING) avg_price
FROM bricks;


-- You store brick details in this table:

DROP TABLE bricks;
create table bricks (
  colour varchar2(10),
  shape  varchar2(10),
  weight integer
);

insert into bricks values ( 'red', 'cube', 1 );
insert into bricks values ( 'red', 'cuboid', 1 );
insert into bricks values ( 'red', 'pyramid', 2 );
insert into bricks values ( 'blue', 'cube', 3 );
insert into bricks values ( 'blue', 'cuboid', 5 );
insert into bricks values ( 'blue', 'pyramid', 8 );

commit;

/*
Your boss has asked you to pivot the rows by shape, showing the total weight 
for each colour as columns. They also want you to filter the results, 
so the output only includes shapes with a total weight greater than five.

Which of the following queries will do this, returning the rows below?

SHAPE     RED_TOT_WEIGHT   BLUE_TOT_WEIGHT   
cuboid                   1                 5 
pyramid                  2                 8 
*/

SELECT * FROM bricks;

SELECT b.*, SUM(weight) OVER(PARTITION BY colour) total_colour_weight
FROM bricks b;

SELECT * FROM
(SELECT shape, colour, weight FROM bricks)
PIVOT(SUM(weight) FOR colour IN
        ('red' RED_TOT_WEIGHT, 'blue' BLUE_TOT_WEIGHT))
WHERE RED_TOT_WEIGHT + BLUE_TOT_WEIGHT > 5;

SELECT
    shape,
    SUM(CASE WHEN colour = 'blue' THEN weight END)BLUE_TOT_WEIGHT,
    SUM(CASE WHEN colour = 'red' THEN weight END)RED_TOT_WEIGHT
FROM bricks b
GROUP BY shape
HAVING (SUM(CASE WHEN colour = 'blue' THEN weight END)
+ SUM(CASE WHEN colour = 'red' THEN weight END))> 5;

SELECT
    shape,
    SUM(CASE WHEN colour = 'blue' THEN weight END)BLUE_TOT_WEIGHT,
    SUM(CASE WHEN colour = 'red' THEN weight END)RED_TOT_WEIGHT
FROM bricks b
GROUP BY shape
HAVING SUM(weight)> 5;

-- You store details of films and books in the following tables:

DROP TABLE books;
create table books (
  title varchar2(100)
);

DROP TABLE films;
create table films (
  title varchar2(100)
);

insert into books values ( 'The Player of Games' );
insert into books values ( 'Trainspotting' );
insert into books values ( 'Fight Club' );

insert into films values ( 'Trainspotting' );
insert into films values ( 'Fight Club' );
insert into films values ( 'Inception' );

commit;

/*
You want to find all the titles that are both a book and a film.

Which of the following queries find the common titles, returning the rows below?

TITLE           
Fight Club      
Trainspotting 
*/

SELECT * FROM books
INTERSECT
SELECT * FROM films;

SELECT * FROM books b
WHERE EXISTS (SELECT 1 FROM films f
                WHERE b.title = f.title)
ORDER BY title;

-- You store details of your computer's folder structure in this table:

DROP TABLE folders;
create table folders (
  folder_name        varchar2(128),
  parent_folder_name varchar2(128)
);

insert into folders values ( 'home', 'junk' );
insert into folders values ( 'saxon', 'home' );
insert into folders values ( 'junk', 'saxon' );

commit;

/*
Home is the top-level folder. But someone has accidentally made junk its parent folder, making a loop!

Which of the following queries will build the directory structure starting at home, so you get this output:

FOLDER_NAME   PATH               
home          /home              
saxon         /home/saxon        
junk          /home/saxon/junk
*/

SELECT folder_name,
        SYS_CONNECT_BY_PATH(folder_name, '/') path
FROM folders
START WITH folder_name = 'home'
CONNECT BY NOCYCLE PRIOR folder_name = parent_folder_name;

WITH recur_table (folder_name, path)
AS(
SELECT folder_name, '/home' AS path
FROM folders
WHERE folder_name = 'home'
UNION ALL
SELECT f.folder_name, rt.path || '/' || f.folder_name AS path
FROM folders f
JOIN recur_table rt
ON rt.folder_name = f.parent_folder_name)
CYCLE folder_name SET is_loop TO 'Y' default 'N'
SELECT folder_name, path FROM recur_table
WHERE is_loop = 'N';

-- You have two tables of bricks:

DROP TABLE target_bricks;
create table target_bricks (
  brick_id integer primary key,
  colour   varchar2(10),
  shape    varchar2(10)
);

DROP TABLE source_bricks;
create table source_bricks (
  brick_id integer primary key,
  colour   varchar2(10),
  shape    varchar2(10)
);

insert into target_bricks values ( 1, 'red', 'cube' );
insert into target_bricks values ( 2, 'red', 'pyramid' );
insert into target_bricks values ( 3, 'blue', 'cube' );

insert into source_bricks values ( 1, 'red', 'cube' );
insert into source_bricks values ( 2, 'blue', 'pyramid' );
insert into source_bricks values ( 3, 'blue', 'prism' );
insert into source_bricks values ( 4, 'green', 'cube' );

commit;

/*
The rows from each table match on brick_id. 
You'd like to copy the rows from source_bricks into target_bricks, so that you:

Add any missing brick_ids (brick_id 4)
Updating the colour and shape of those that match (brick_ids 2 & 3)
You'd also like to remove any rows from target_bricks with a matching red row in source_bricks (brick_id 1).

Which of the following choices change the rows in target_bricks, so afterwards it stores the following data:

BRICK_ID   COLOUR   SHAPE     
         2 blue     pyramid   
         3 blue     prism     
         4 green    cube 

*/

MERGE INTO target_bricks tb
USING source_bricks sb
ON (tb.brick_id = sb.brick_id)
WHEN MATCHED THEN
    UPDATE SET tb.colour = sb.colour, tb.shape = sb.shape
    DELETE WHERE tb.colour = sb.colour AND tb.shape = sb.shape
                    AND tb.colour = 'red'
WHEN NOT MATCHED THEN
    INSERT VALUES (sb.brick_id, sb.colour, sb.shape);
    
SELECT * FROM target_bricks;
