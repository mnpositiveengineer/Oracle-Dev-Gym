-- Prerequisites 

DROP TABLE bricks_for_sale;
create table bricks_for_sale (
  colour   varchar2(10),
  shape    varchar2(10),
  price    number(10, 2),
  primary key ( colour, shape )
);

DROP TABLE purchased_bricks;
create table purchased_bricks (
  colour   varchar2(10),
  shape    varchar2(10),
  price    number(10, 2),
  primary key ( colour, shape )
);

insert into bricks_for_sale values ( 'red', 'cube', 4.95 );
insert into bricks_for_sale values ( 'blue', 'cube', 7.75 );
insert into bricks_for_sale values ( 'blue', 'pyramid', 9.99 );

commit;

SELECT * FROM bricks_for_sale;
SELECT * FROM purchased_bricks;

-- insert a blue pyramid into the table of purchased_brick
-- If it exists, you want to change its price. 
-- And if it doesn't, you want to add it.

MERGE INTO purchased_bricks pb
USING (SELECT 'blue' colour, 'pyramid' shape, 15.95 price
FROM DUAL) st
ON (st.colour = pb.colour AND st.shape = pb.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = st.price
WHEN NOT MATCHED THEN
    INSERT VALUES (st.colour, st.shape, st.price);
    
MERGE INTO purchased_bricks pb
USING (SELECT 'blue' colour, 'pyramid' shape, 10.95 price
FROM DUAL) st
ON (st.colour = pb.colour AND st.shape = pb.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = st.price
WHEN NOT MATCHED THEN
    INSERT VALUES (st.colour, st.shape, st.price);
    
--  merge two whole tables, so all the rows in the source have a matching row in the target.

MERGE INTO purchased_bricks pb
USING bricks_for_sale bs
ON (bs.colour = pb.colour AND bs.shape = pb.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = bs.price
WHEN NOT MATCHED THEN
    INSERT VALUES (bs.colour, bs.shape, bs.price);
    
-- add the yellow cube to purchased_bricks. 
-- And update the price of the red brick to 5.55:

SELECT * FROM purchased_bricks;

MERGE INTO purchased_bricks pb
USING (SELECT 'yellow' colour, 'cube' shape, null price FROM DUAL
UNION ALL
SELECT 'red' colour, 'cube' shape, 5.55 price FROM DUAL) st
ON (st.colour = pb.colour AND st.shape = pb.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = st.price
WHEN NOT MATCHED THEN
    INSERT VALUES (st.colour, st.shape, st.price);

-- updates the price of all the bricks for sale to 100 and adds red pyramid. 

update bricks_for_sale 
set price = 100;

insert into bricks_for_sale values ( 'red', 'pyramid', 5.99 );

commit;

SELECT * FROM bricks_for_sale;
SELECT * FROM purchased_bricks;

-- Merge bricks_for_sale to purchased_bricks to only affect blue rows in both clauses. 
-- So the price of the red cube remains 4.95 and the red pyramid is not added to purchased_bricks:

MERGE INTO purchased_bricks pb
USING bricks_for_sale bs
ON (pb.colour = bs.colour AND pb.shape = bs.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = bs.price
    WHERE pb.colour = 'blue'
WHEN NOT MATCHED THEN
    INSERT VALUES (bs.colour, bs.shape, bs.price)
    WHERE bs.colour = 'blue'; 
    
-- Complete the where clauses in the merge statement below, so that it:
-- Only updates cubes
-- Only inserts green coloured rows