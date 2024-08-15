-- Foreign Keys

-- Example 1 - No foreign key specified
/*
RENAME TABLE c8_employees 
       TO SYSTEM NAME c8_emps;


RENAME TABLE c8_departments 
       TO SYSTEM NAME c8_depts;
*/
------------------------------------------------------
DROP TABLE c8_departments;
DROP TABLE c8_employees;

CREATE TABLE c8_departments (
    department_id   INTEGER     NOT NULL,
    department_name VARCHAR(30) NOT NULL,
  CONSTRAINT c8_departments_pk
  PRIMARY KEY (department_id) );
    
INSERT INTO c8_departments
  VALUES (201, 'Small Appliances'),
         (202, 'Kid''s Apparel');

SELECT * FROM c8_departments;
------------------------------------------------------

CREATE TABLE c8_employees (
    employee_id       INTEGER         NOT NULL,
    first_name        VARCHAR (20)    NOT NULL,
    last_name         VARCHAR (20)    NOT NULL,
    department_id     INTEGER,
  CONSTRAINT c8_employees_pk
  PRIMARY KEY (employee_id) );

-- No foreign key defined

INSERT INTO c8_employees
VALUES (101, 'Betty', 'O''Brien', 201),
       (102, 'Peter', 'Jackson',  202),
       (103, 'Janet', 'Jones',    201),
       (104, 'Sally', 'Allen',    205); -- Department 205 does not exist, but with no foreign key it in inserted

INSERT INTO c8_employees
VALUES (104, 'Sally', 'Allen',    205), -- stop + rollback
       (101, 'Betty', 'O''Brien', 201),
       (102, 'Peter', 'Jackson',  202),
       (103, 'Janet', 'Jones',    201);
       
       
SELECT * FROM c8_employees;

-- What if we try to add foreign key department constraint to c8_employees table

ALTER TABLE c8_employees
  ADD CONSTRAINT c8_employees_department_id_fk
    FOREIGN KEY ( department_id ) 
    REFERENCES c8_departments( department_id );
-- [SQL0667] FOREIGN key value does not match a value in the parent key of constraint c8_employeesS_WORK_DEPARTMENT_FK in IBM01.


------------------------------------------------------------------------------------------------------    
-- Example 2 - Foreign key specified
------------------------------------------------------

TRUNCATE TABLE c8_employees;

ALTER TABLE c8_employees
  ADD CONSTRAINT c8_employees_department_id_fk
    FOREIGN KEY ( department_id )            -- Foreign key is DEPARTMENT_ID in c8_employees table
    REFERENCES c8_departments( department_id ); -- Foreign key references (points to) the primary key DEPARTMENT_ID in c8_departments table

INSERT INTO c8_employees
  VALUES (101, 'Betty', 'O''Brien', 201),
         (102, 'Peter', 'Jackson',  202),
         (103, 'Janet', 'Jones',    201),
         (104, 'Sally', 'Allen',    205); -- 205 is not a value department_id - Foreign key error
-- [SQL0530] Operation not allowed by referential constraint c8_employees_WORK_DEPARTMENT_FK in IBM01.

SELECT * FROM c8_employees;

------------------------------------------------------------------------------------------------------------------
-- Example 3 - Foreign key column in child table is different name then parent table

-- c8_departments table remains the same

DROP TABLE c8_employees;
CREATE TABLE c8_employees (
    employee_id       INTEGER         NOT NULL,
    first_name        VARCHAR (20)    NOT NULL,
    last_name         VARCHAR (20)    NOT NULL,
    work_department   INTEGER,                  -- The c8_employees department column has been renamed to work_department
  CONSTRAINT c8_employees_pk
  PRIMARY KEY (employee_id) );

ALTER TABLE c8_employees
  ADD CONSTRAINT c8_employees_work_department_fk
    FOREIGN KEY ( work_department )              -- Foreign key in c8_employees table is different name than primary key in c8_departments table
    REFERENCES c8_departments( department_id );

INSERT INTO c8_employees
  VALUES (101, 'Betty', 'O''Brien', 201),
         (102, 'Peter', 'Jackson',  202),
         (103, 'Janet', 'Jones',    201);

SELECT * FROM c8_employees;

-----------------------------------------------------------------
-- Example 4 - The sequence in which the tables are created is crucial for foreign keys

DROP TABLE c8_employees;
DROP TABLE c8_departments;

CREATE TABLE c8_departments
  ( department_id     INTEGER         NOT NULL,
    department_name   VARCHAR (20)    NOT NULL,
    manager_id        INTEGER );
    

ALTER TABLE c8_departments
  ADD CONSTRAINT c8_departments_pk
    PRIMARY KEY (department_id);

ALTER TABLE c8_departments
  ADD CONSTRAINT c8_departments_manager_id_fk        -- Cannot add foreign key on manager_id because c8_employees table does not exist
    FOREIGN KEY ( manager_id )                    -- Foreign key for manager_id
    REFERENCES c8_employees( employee_id );
-- [SQL0204] c8_employees in IBM7105 type *FILE not found.

CREATE TABLE c8_employees (
    employee_id       INTEGER         NOT NULL ,
    first_name        VARCHAR (20)    NOT NULL ,
    last_name         VARCHAR (20)    NOT NULL ,
    department_id     INTEGER,
  CONSTRAINT c8_employees_pk
  PRIMARY KEY (employee_id) );


ALTER TABLE c8_employees
  ADD CONSTRAINT c8_employees_department_id_fk
    FOREIGN KEY ( department_id ) 
    REFERENCES c8_departments( department_id );
	
ALTER TABLE c8_departments                    -- manager_id FK can now be added to c8_departments table because c8_employees table exists
  ADD CONSTRAINT c8_departments_manager_id_fk
	FOREIGN KEY ( manager_id )
		REFERENCES c8_employees( employee_id );
		
INSERT INTO c8_departments
  VALUES (101, 'Software Development', NULL),  -- manager_id must be NULL because the c8_employees table has not been populated 
         (102, 'Sales', NULL);

SELECT * FROM c8_departments;
         
INSERT INTO c8_employees
  VALUES (100, 'Sally', 'Programmer', 101),
         (110, 'Jack',  'Clark', 101),
         (120, 'Betty', 'Jones', 101);
       
SELECT * FROM c8_employees;
         
INSERT INTO c8_departments
  VALUES (103, 'Marketing', 120);  -- manager_id assigned

  
UPDATE IBM7009.c8_departments    -- This will not work because OF journaling issue
  SET manager_id = 110
  WHERE department_id = 101;

  
  SELECT * FROM c8_departments;

-----------------------------------------------------------------------------
-- Example 5 -- Defining foreign keys in intersection table

DROP TABLE c8_employees;
DROP TABLE c8_projects;
DROP TABLE c8_employee_projects;

CREATE TABLE c8_employees (
    employee_id  INTEGER       NOT NULL ,
    first_name   VARCHAR (20)  NOT NULL ,
    last_name    VARCHAR (20)  NOT NULL,
  CONSTRAINT c8_employees_id_pk
  PRIMARY KEY (employee_id) );

CREATE TABLE c8_projects (
    project_id     INTEGER      NOT NULL,
    project_title  VARCHAR (40) NOT NULL, 
  CONSTRAINT c8_projects_pk
  PRIMARY KEY (project_id) );

CREATE TABLE c8_employee_projects (   -- hours
    employee_id     INTEGER           NOT NULL ,
    project_id      INTEGER           NOT NULL ,
    employee_hours  DECIMAL (7,2),    
  CONSTRAINT c8_employee_projects_pk
    PRIMARY KEY (employee_id, project_id) );

ALTER TABLE c8_employee_projects
  ADD CONSTRAINT emp_pro_employee_id_fk
    FOREIGN KEY ( employee_id ) 
    REFERENCES c8_employees( employee_id );
	
ALTER TABLE c8_employee_projects
  ADD CONSTRAINT emp_pro_project_id_fk
    FOREIGN KEY ( project_id ) 
    REFERENCES c8_projects( project_id );
         
INSERT INTO c8_projects
  VALUES (201, 'Mainstreet Upgrade'  ),
         (202, 'Web Maintenance' );

INSERT INTO c8_employees
  VALUES (101, 'Sally', 'Smith' ),
         (102, 'Jack',  'Clark' ),
         (103, 'Betty', 'Jones' );
         

INSERT INTO c8_employee_projects
  VALUES (101, 201, 65),
         (101, 202, 40),
         (102, 201, 25),
         (103, 202, 82),
         (102, 202, 125);
        
SELECT * FROM c8_employees;

SELECT * FROM c8_projects;

SELECT * FROM c8_employee_projects;       
         

-- LOOKING AHEAD
SELECT project_title, last_name, employee_hours
  FROM c8_employee_projects
  JOIN c8_employees USING (employee_id)
  JOIN c8_projects USING (project_id)
  ORDER BY project_title;




        
		 
		 









  
  