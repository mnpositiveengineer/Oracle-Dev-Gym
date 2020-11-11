-- Prerequisites
DROP TABLE employees;
create table employees as
  select * from hr.employees
  where  department_id in ( 90, 100, 60 );
  
SELECT * FROM employees;

-- create data trees using SQL (employee_id ,first_name, manager_id)

SELECT employee_id, first_name, manager_id
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- build a "reverse" org chart. Begin with employee 107 and go up the chain

SELECT employee_id, first_name, manager_id
FROM employees
START WITH employee_id = 107
CONNECT BY PRIOR manager_id = employee_id;

-- create data trees using SQL (employee_id ,first_name, manager_id)
-- using recursive table

WITH recur_table (employee_id, first_name, manager_id)
AS
(SELECT employee_id, first_name, manager_id
FROM employees
WHERE manager_id IS NULL
UNION ALL
SELECT e.employee_id, e.first_name, e.manager_id
FROM recur_table rt
JOIN employees e
ON e.manager_id = rt.employee_id)
SELECT * FROM recur_table;
  
-- build the reverse org chart from step three again. 
-- But this time using recursive with. It should start with employee_id 107 
-- and go up the company to the CEO.

WITH recur_table (employee_id, first_name, manager_id)
AS
(SELECT employee_id, first_name, manager_id
FROM employees
WHERE employee_id = 107
UNION ALL
SELECT e.employee_id, e.first_name, e.manager_id
FROM employees e
JOIN recur_table rt
ON rt.manager_id = e.employee_id)
SELECT * FROM recur_table;

-- to above queries add level

SELECT level, employee_id, first_name, manager_id
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

SELECT LPAD(' ', level, ' ') || first_name AS first_name
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

WITH recur_table (employee_id, first_name, manager_id, lvl)
AS (
SELECT employee_id, first_name, manager_id, 1 lvl
FROM employees
WHERE manager_id IS NULL
UNION ALL
SELECT e.employee_id, e.first_name, e.manager_id, lvl+1
FROM employees e
JOIN recur_table rt
ON rt.employee_id = e.manager_id)
SELECT * FROM recur_table;

WITH recur_table (employee_id, first_name, manager_id, lvl)
AS (
SELECT employee_id, first_name, manager_id, 1 lvl
FROM employees
WHERE manager_id IS NULL
UNION ALL
SELECT e.employee_id, e.first_name, e.manager_id, lvl+1
FROM employees e
JOIN recur_table rt
ON rt.employee_id = e.manager_id)
SELECT LPAD(' ', lvl, ' ') || first_name
FROM recur_table;

-- above querry will return table when first are placed rows with the highest level
-- SEARCH DEPTH FIRST BY ......... SET ..

WITH recur_table (employee_id, first_name, manager_id, lvl)
AS (
SELECT employee_id, first_name, manager_id, 1 lvl
FROM employees
WHERE manager_id IS NULL
UNION ALL
SELECT e.employee_id, e.first_name, e.manager_id, lvl+1
FROM employees e
JOIN recur_table rt
ON rt.employee_id = e.manager_id)
SEARCH DEPTH FIRST BY first_name SET f_n
SELECT LPAD(' ', lvl, ' ') || first_name
FROM recur_table
ORDER BY f_n;

-- USING SEARCH BREADTH FIRST BY ... SET .. will return table like default

WITH recur_table (employee_id, first_name, manager_id, lvl)
AS (
SELECT employee_id, first_name, manager_id, 1 lvl
FROM employees
WHERE manager_id IS NULL
UNION ALL
SELECT e.employee_id, e.first_name, e.manager_id, lvl+1
FROM employees e
JOIN recur_table rt
ON rt.employee_id = e.manager_id)
SEARCH BREADTH FIRST BY first_name SET f_n
SELECT LPAD(' ', lvl, ' ') || first_name
FROM recur_table
ORDER BY f_n;

-- return employees in depth-first order. You should sort employees with 
-- the same manager by first_name:

/*
This query should give the following output:

LEVEL   EMPLOYEE_ID   FIRST_NAME    LAST_NAME   HIRE_DATE      MANAGER_ID   
      1           100 Steven        King        17-JUN-2003          <null>
      2           102 Lex           De Haan     13-JAN-2001             100 
      3           103 Alexander     Hunold      03-JAN-2006             102 
      4           104 Bruce         Ernst       21-MAY-2007             103 
      4           105 David         Austin      25-JUN-2005             103 
      4           107 Diana         Lorentz     07-FEB-2007             103 
      4           106 Valli         Pataballa   05-FEB-2006             103 
      2           101 Neena         Kochhar     21-SEP-2005             100 
      3           108 Nancy         Greenberg   17-AUG-2002             101 
      4           109 Daniel        Faviet      16-AUG-2002             108 
      4           111 Ismael        Sciarra     30-SEP-2005             108 
      4           110 John          Chen        28-SEP-2005             108 
      4           112 Jose Manuel   Urman       07-MAR-2006             108 
      4           113 Luis          Popp        07-DEC-2007             108
*/

SELECT level, employee_id, first_name, last_name, hire_date, manager_id
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY first_name;

-- display:
-- The last_name of the CEO (the root row) on every row
-- A / separated list of the management chain from the current employee up to the CEO
-- The employees who aren't managers (the leaves)

SELECT employee_id, first_name, manager_id,
        CONNECT_BY_ROOT first_name root,
        SYS_CONNECT_BY_PATH (first_name, '/') path,
        CONNECT_BY_ISLEAF is_leaf
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

/*
Your company structure is stored in this table:
*/

DROP TABLE employees;
create table employees (
  employee_id   integer,
  employee_name varchar2(30),
  manager_id    integer
);

insert into employees values ( 1, 'Big Boss', null );
insert into employees values ( 2, 'Stressed Manager', 1 );
insert into employees values ( 3, 'Lowly Worker', 2 );
insert into employees values ( 4, 'Aspiring Junior', 2 );
insert into employees values ( 5, 'The Newbie', 2 );
insert into employees values ( 6, 'Master Senior Consultant', 1 );

commit;

/*
Which of the following queries will show:

Each person's position in the organization chart, starting with Big Boss at 1, their reports at 2, at so on
Indents their names according to their position?
i.e. return the following rows:

LEVEL   EMPLOYEE                     
      1  Big Boss                    
      2   Stressed Manager           
      3    Lowly Worker              
      3    Aspiring Junior           
      3    The Newbie                
      2   Master Senior Consultant
*/
SELECT * FROM employees;

SELECT level, 
        LPAD(' ', level, ' ') || employee_name AS employee
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

WITH recur_table (lvl, employee_name, employee_id, manager_id)
AS
(SELECT 1 lvl, employee_name, employee_id, manager_id
FROM employees
WHERE manager_id IS NULL
UNION ALL
SELECT lvl+1, e.employee_name, e.employee_id, e.manager_id
FROM employees e
JOIN recur_table rt
ON rt.employee_id = e.manager_id)
SEARCH DEPTH FIRST BY employee_name SET name
SELECT lvl, 
LPAD(' ', lvl ,' ') || employee_name  employee
FROM recur_table
ORDER BY name;



-- The following table stores a computer's directory structure:

DROP TABLE folders;
create table folders (
  folder_name        varchar2(128),
  parent_folder_name varchar2(128)
);

insert into folders values ( '/home', null );
insert into folders values ( '/tmp', null );
insert into folders values ( '/saxon', '/home' );
insert into folders values ( '/feuerstein', '/home' );
insert into folders values ( '/junk', '/tmp' );

commit;

/*
Which of the following queries display the folders and their directory path?

i.e. give this output?

FOLDER_NAME   DIRECTORY_PATH     
/home         /home              
/feuerstein   /home/feuerstein   
/saxon        /home/saxon        
/tmp          /tmp               
/junk         /tmp/junk 

*/

SELECT folder_name,
        SYS_CONNECT_BY_PATH (folder_name, ' ') directory_path
FROM folders
START WITH parent_folder_name IS NULL
CONNECT BY PRIOR folder_name = parent_folder_name;

WITH recur_table (folder_name , parent_folder_name, directory_path)
AS (
SELECT folder_name , parent_folder_name, folder_name AS directory_path
FROM folders
WHERE parent_folder_name IS NULL
UNION ALL
SELECT f.folder_name , f.parent_folder_name, 
    rt.directory_path || f.folder_name AS directory_path
FROM folders f
JOIN recur_table rt
ON rt.folder_name = f.parent_folder_name)
SEARCH DEPTH FIRST BY folder_name SET fn
SELECT folder_name, directory_path FROM recur_table
ORDER BY fn;


-- Your application stores details of how to draw its menu in this table:

DROP TABLE menu_items;
create table menu_items (
  item_id        integer,
  item_name      varchar2(10),
  parent_item_id integer,
  item_position  integer
);

insert into menu_items values ( 1, 'File', null, 1 );
insert into menu_items values ( 2, 'Edit', null, 2 );

insert into menu_items values ( 3, 'New...', 1, 1 );
insert into menu_items values ( 4, 'Open...', 1, 2 );
insert into menu_items values ( 5, 'Save As...', 1, 4 );
insert into menu_items values ( 6, 'Save', 1, 3 );

insert into menu_items values ( 7, 'Paste', 2, 3 );
insert into menu_items values ( 8, 'Copy', 2, 2 );
insert into menu_items values ( 9, 'Cut', 2, 1 );

commit;

/*
You need to display all an item's children below it. 
You need to sort children of the same parent by their item_position; 
i.e. the following order:

ITEM_NAME    
File         
New...       
Open...      
Save         
Save As...   
Edit         
Cut          
Copy         
Paste    
Which of the following queries build the menu tree, returning the rows in this order?
*/
  
SELECT * FROM menu_items;

SELECT item_name
FROM menu_items
START WITH parent_item_id IS NULL
CONNECT BY PRIOR item_id = parent_item_id
ORDER SIBLINGS BY item_position;

WITH recur_table (item_id, item_name, parent_item_id, item_position)
AS (
SELECT item_id, item_name, parent_item_id, item_position
FROM menu_items
WHERE parent_item_id IS NULL
UNION ALL
SELECT mi.item_id, mi.item_name, mi.parent_item_id, mi.item_position
FROM menu_items mi
JOIN recur_table rt
ON rt.item_id = mi.parent_item_id)
SEARCH DEPTH FIRST BY item_position SET ip
SELECT item_name FROM recur_table
ORDER BY ip;