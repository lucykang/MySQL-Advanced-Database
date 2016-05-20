/*
NAME: HAE YEON KANG (LUCY)
THIS IS ADVANCED DATABASE ASSIGNMENT 1.
*/

/*
Union, Arithmetic and Subquery Questions :

Question 1 (8 marks)
Create a query that lists Last name,  Salary, Salary increased by 3 percent, Monthly salary (hint :divide by 12) increased by 3 percent.  Limit the result to employees whose salary * 1.03, is less than or equal to $45,000.  Sort the list by annual salary. 
(Tables used EMPLOYEE)
*/
SELECT LASTNAME, SALARY, ROUND((SALARY * 1.03), 2) AS INCREASED_SALARY, ROUND((SALARY * 1.03 / 12), 2) AS MONTHLY_SALARY_AFTER_INCREASE
FROM EMPLOYEE
WHERE (SALARY * 1.03) <= 45000
ORDER BY SALARY; 


SELECT MAX(SALARY) FROM EMPLOYEE;

SELECT FIRSTNME, WORKDEPT, SUM(SALARY)
FROM EMPLOYEE
GROUP BY FIRSTNME;

CREATE VIEW EMP_VIEW AS
SELECT (SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'SAMPLE' AND TABLE_NAME = 'EMPLOYEE'
LIMIT 3;)
FROM EMPLOYEE
WITH CHECK OPTION;


SELECT BIRTHDATE, CONCAT(TIMESTAMPDIFF( YEAR, BIRTHDATE, now() ),' Years,',
TIMESTAMPDIFF( MONTH, BIRTHDATE, now() ) % 12,' Months,',
FLOOR( TIMESTAMPDIFF( DAY, BIRTHDATE, now() ) % 30 ),' Days') AS AGE
FROM EMPLOYEE;

/*
Question 2 (8 marks)
Create a query that lists department number, last name, salary. Select all employees matching the following criteria: 
->They belong to department A00 
->Salary is more than or equal to 65 percent of $15,000 = 9750
->Salary is less than or equal to 130 percent of $40,000 = 52000
-> Sort the list by salary
(Tables used EMPLOYEE)
*/
SELECT WORKDEPT, LASTNAME, SALARY
FROM EMPLOYEE
WHERE WORKDEPT = 'A00' AND
	  SALARY >= 15000 * 0.65 AND
      SALARY <= 40000 * 1.3
ORDER BY SALARY;


/*
Question 3 (9 marks)
Create a query that lists the department number, employee number, and salaries of all employees in department D11.  
UNION the same information , but this time sum up all the salaries to create a one line summary entry for the D11 department 
(hint sum the salary).  
Sort the list by Salary. 
you will get the 11 rows from the first query and get one row from the second query that’s showing the summary.
(Tables used EMPLOYEE)
*/
SELECT WORKDEPT, EMPNO, SALARY
FROM EMPLOYEE
WHERE WORKDEPT = 'D11'
UNION
SELECT WORKDEPT, COUNT(*) AS NUMBER_OF_EMPLOYEE, SUM(SALARY) AS SUM_OF_SALARY
FROM EMPLOYEE
WHERE WORKDEPT = 'D11';


/*
Question 4  (15 marks)
Create a query that lists the lastnme, edlevel , job, the number of years they've worked as of Jan 01/2002 ( hint : year function Jan 01/2002 minus hiredate), and their salary.  
Get the employees that have the same Job and Education level  as the employee’s first named starts with J  
(hint sub-select from employee    ie (job, edlevel ) =    ). Sort the listing by highest salary first.  
subquery (job, edlevel) IN (SELECT job, edlevel FROM employee)
(Tables used EMPLOYEE)
*/
SELECT LASTNAME, EDLEVEL, JOB, YEAR('2002-01-01')-YEAR(HIREDATE) AS NUMBER_OF_YEARS_WORKED, SALARY
FROM EMPLOYEE
WHERE HIREDATE <= '2002-01-01' AND (EDLEVEL, JOB) IN (
		SELECT EDLEVEL, JOB 
		FROM EMPLOYEE 
		WHERE FIRSTNME LIKE 'J%')
ORDER BY SALARY DESC;


/*
Join Questions :

Question 5 (15 marks)
Create a query that lists actno, deptno, deptname, lastname and firstnme of  the gender female employees, and department C01. 
Then right join to the empprojact table 
(Tables used EMPLOYEE, DEPARTMENT, EMPPROJACT)
*/
SELECT EP.ACTNO, D.DEPTNO, D.DEPTNAME, E.LASTNAME, E.FIRSTNME
FROM EMPLOYEE E LEFT OUTER JOIN DEPARTMENT D
ON E.WORKDEPT = D.DEPTNO
RIGHT OUTER JOIN EMPPROJACT EP
ON EP.EMPNO = E.EMPNO
WHERE E.WORKDEPT = 'C01' AND E.SEX = 'F';

/*
Question 6 (15 marks)
Create a query that lists actno, emstdate, mgrno, projno, firstnme, lastname. 
Where emstdate is greater than Sept 25,2002. 
Order the list the activity number and the emstdate.   

The PROJECT table must be replaced by the following query (select projno, deptno from PROJECT where deptno = ‘D11’)
and left join between PROJECT select table and department. 

(Tables used EMPLOYEE, DEPARTMENT, EMPPROJACT, PROJECT)
*/
SELECT EP.ACTNO, EP.EMSTDATE, D.MGRNO, EP.PROJNO, E.FIRSTNME, E.LASTNAME
FROM EMPPROJACT EP LEFT OUTER JOIN EMPLOYEE E
ON EP.EMPNO = E.EMPNO
JOIN DEPARTMENT D
ON D.DEPTNO = E.WORKDEPT
LEFT OUTER JOIN (SELECT PROJNO, DEPTNO FROM PROJECT WHERE DEPTNO = 'D11') P
ON P.DEPTNO = D.DEPTNO
WHERE EMSTDATE > '2002-09-25'
ORDER BY 1,2;


/*
Question 7 (15 marks)
Create a query that lists empno, projno, emptime, emendate. Where emptime is greater than 0.5.  
Left join the project to the empprojact table 
and LEFT join the act table 
and then right join employee table. 
Where projno is AD3113 and empno is 000270.

(Tables used PROJECT, ACT, EMPPROJACT, EMPLOYEE)
*/
SELECT EP.EMPNO, EP.PROJNO, EP.EMPTIME, EP.EMENDATE
FROM EMPPROJACT EP LEFT OUTER JOIN PROJECT P
ON P.PROJNO = EP.PROJNO
LEFT OUTER JOIN ACT A
ON A.ACTNO = EP.ACTNO
RIGHT OUTER JOIN EMPLOYEE E
ON EP.EMPNO = E.EMPNO
WHERE EP.PROJNO = 'AD3113' AND EP.EMPNO = '000270' AND EP.EMPTIME > 0.5;


/*
Question 8 (15 marks)
Create the DDL for the following two tables:
*/

CREATE TABLE CATEGORIES (
	CATEGORYID CHAR(6) NOT NULL,
    CATEGORYNAME VARCHAR(25) );
    
ALTER TABLE CATEGORIES
	ADD CONSTRAINT PK_CATEGORIES PRIMARY KEY (CATEGORYID);

CREATE TABLE PROPERTIES (
	PRODUCTID CHAR(6) NOT NULL,
    CATEGORYID CHAR(6) NOT NULL,
    MODELNUMBER VARCHAR(30) NOT NULL,
    MODELNAME VARCHAR(25),
    UNITCOST DECIMAL(5,2) NOT NULL,
    DESCRIPTION VARCHAR(200) );
    
ALTER TABLE PROPERTIES
	ADD CONSTRAINT PK_PROPERTIES PRIMARY KEY (PRODUCTID),
    ADD CONSTRAINT FK_PROPERTIES FOREIGN KEY (CATEGORYID)
    REFERENCES CATEGORIES(CATEGORYID);



