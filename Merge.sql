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

MERGE INTO purchased_bricks pb
USING bricks_for_sale bs
ON (pb.colour = bs.colour AND bs.shape = pb.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = bs.price
    WHERE pb.shape = 'cube'
WHEN NOT MATCHED THEN
    INSERT VALUES (bs.colour, bs.shape, bs.price)
    WHERE bs.colour = 'green';

-- write a query that only updates prices of purchased elements with
-- values from bricks_for_sale

MERGE INTO purchased_bricks pb
USING bricks_for_sale bs
ON (pb.colour = bs.colour AND pb.shape = bs.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = bs.price;
    
-- delete all the rows from purchased_bricks which matches with the rows in 
-- bricks_for_sale

MERGE INTO purchased_bricks pb
USING bricks_for_sale bs
ON (pb.colour = bs.colour AND pb.shape = bs.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = bs.price
    DELETE WHERE pb.colour = bs.colour;
    
-- Complete the following merge statement, so it removes matched rows from 
-- purchased_bricks that have a price less than 9

MERGE INTO purchased_bricks pb
USING bricks_for_sale bs
ON (pb.colour = bs.colour AND pb.shape = bs.shape)
WHEN MATCHED THEN
    UPDATE SET pb.price = bs.price
    DELETE WHERE pb.price < 9; 
    
-- We store details of the playing card collections belonging to you and me in these tables:

DROP TABLE my_playing_cards;
create table my_playing_cards (
  card_value  varchar2(10),
  suit        varchar2(10),
  back_colour varchar2(10)
);

DROP TABLE your_playing_cards;
create table your_playing_cards (
  card_value  varchar2(10),
  suit        varchar2(10),
  back_colour varchar2(10)
);

insert into my_playing_cards values ( 'Ace', 'spades', 'blue' );
insert into my_playing_cards values ( 'Ace', 'diamonds', 'blue' );

insert into your_playing_cards values ( 'Ace', 'spades', 'red' );
insert into your_playing_cards values ( 'Ace', 'diamonds', 'red' );
insert into your_playing_cards values ( 'Ace', 'hearts', 'red' );
insert into your_playing_cards values ( 'Ace', 'clubs', 'red' );

commit;
/*
We want to combine the rows from these tables. So the rows in my_playing_cards 
match those in your_playing_cards. The rows join on card_suit and value.

Which of the following choices:

Add the missing rows to my_playing_cards (Aces of hearts and clubs)
Update the back_colour of existing rows to red?
i.e. when you query my_playing_cards afterwards, like so:

select * from my_playing_cards
order  by card_value, suit;
It returns these rows:

CARD_VALUE   SUIT       BACK_COLOUR   
Ace          clubs      red           
Ace          diamonds   red           
Ace          hearts     red           
Ace          spades     red
*/

SELECT * FROM my_playing_cards;
SELECT * FROM your_playing_cards;

MERGE INTO my_playing_cards mc
USING your_playing_cards yc
ON (mc.card_value = yc.card_value AND mc.suit = yc.suit)
WHEN MATCHED THEN
    UPDATE SET mc.back_colour = yc.back_colour
WHEN NOT MATCHED THEN
    INSERT VALUES (yc.card_value, yc.suit, yc.back_colour);
