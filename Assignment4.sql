/*
NAME: HAEYEON (LUCY) KANG
ASSIGNMENT: ASSIGNMENT 4
*/

# DISABLE SAFE UPDATE MODE
SET SQL_SAFE_UPDATES = 0;

/*
Create Trigger and Function Questions (Total marks 60)

Question 1 (10 marks)
Create a trigger called SALARY_CHANGE_UPD. It is an AFTER UPDATE TRIGGER on the SALARY COLUMN OF THE EMPLOYEE TABLE.   
Compare the OLD salary record with the NEW record to check whether they are different 
and whether the salary has been increased more than 10%.

If they are, INSERT a record into the following table, which you will have to create :
CREATE TABLE SALARY_CHANGES(EMPNO NUMBER, NEW_SALARY DECIMAL (10,2), OLD_SALARY DECIMAL(10,2), 
GREATER_THAN_10 BOOLEAN, TIMESTMP DATE);
*/
CREATE TABLE SALARY_CHANGES(
	EMPNO 				NUMERIC, 
	NEW_SALARY 			DECIMAL(10,2), 
	OLD_SALARY 			DECIMAL(10,2), 
	GREATER_THAN_10 	BOOLEAN, 
	TIMESTMP 			DATE
);

DELIMITER $$
CREATE TRIGGER SALARY_CHANGE_UPD
	AFTER UPDATE ON EMPLOYEE FOR EACH ROW
    BEGIN
		IF(NEW.SALARY - OLD.SALARY) <> 0
			THEN INSERT INTO SALARY_CHANGES VALUES (EMPNO, NEW.SALARY, OLD.SALARY, IF((NEW.SALARY-OLD.SALARY)/NEW.SALARY > 0.1, TRUE, FALSE), NOW());
        END IF;
    END
$$

/*
Question 2 (10 marks)
Create a trigger called PREVENT_UPDATE.   
It is a BEFORE UPDATE TRIGGER on the HIREDATE COLUMN OF THE EMPLOYEE TABLE.   
Compare to see if the old  HIREDATE  with the NEW record to check whether they are different.   
If they are, PREVENT the update from happening by creating an error (hint use SIGNAL SQLSTATE).
*/
DELIMITER $$
CREATE TRIGGER PREVENT_UPDATE
	BEFORE UPDATE ON EMPLOYEE FOR EACH ROW
    BEGIN
		IF (OLD.HIREDATE <> NEW.HIREDATE)
			THEN SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'THE HIREDATE CANNOT BE MODIFIED';
        END IF;
    END
$$

/*
Question 3 (5 marks)
Create a user-defined function (F_COUNT_EDUCATION)  to do the following:
It will accept 1 input Education Level.   
Create a SELECT count the number of employees in the EMPLOYEE table that have an education level greater than 
the one passed to the function and return that number from the function.
*/
DELIMITER $$
CREATE FUNCTION F_COUNT_EDUCATION(EDU_LEVEL SMALLINT(6)) 
	RETURNS INT
	BEGIN
		RETURN(
			SELECT COUNT(EDLEVEL) 
			FROM EMPLOYEE
			WHERE EDLEVEL > EDU_LEVEL
		);
    END
$$

/*
Question 4 (10 marks)
Create a user-defined function (F_EMPLOYEE_COST)  to do the following:
The function needs one input EMPLOYEE NUMBER. 
With that number SELECT the EMPTIME for that employee into a variable FROM the EMPROJACT table.  
 
Then Create a new select that will Multiply that EMPTIME value by the COMM column, 
then add the SALARY and BONUS columns from the EMPLOYEE table for that EMPLOYEE 
to get a return a total cost for that employee.
*/
CREATE FUNCTION F_EMPLOYEE_COST (EMPLOYEE_NUMBER CHAR(6))
	RETURNS DECIMAL(10,2)
    BEGIN
		DECLARE EMPLOYEE_TIME DECIMAL(5,2);
        
        SELECT SUM(EMPTIME)
		INTO EMPLOYEE_TIME
		FROM EMPPROJACT
		WHERE EMPNO = EMPLOYEE_NUMBER;
		
        RETURN (
			SELECT ((COMM * EMPLOYEE_TIME) + SALARY + BONUS)
			FROM EMPLOYEE
			WHERE EMPNO = EMPLOYEE_NUMBER;
        );
    END


#FOR TEST
SELECT * FROM EMPPROJACT;
SELECT * FROM EMPLOYEE;

SELECT F_EMPLOYEE_COST('000010');

/*
Question 5 (10 marks)
First : Create a user-defined function (F_CONVERT_TO_EURO)  to do the following:
Convert a Canadian dollar amount to a Euro amount.  You can use the conversion formula 1 CDN Dollar = 0.72 Euros.
The input and output need to be DECIMAL types 
but you can use whatever size of DECIMAL you want as long as you have 2 decimal places.

Second :  Create a store procedure (P_STAFF_COSTS_EURO) that selects Name, Department, Salary and Comm 
from the Staff table. Sum up Salary and Comm for each Name and Department and convert those values 
to Euro and return records (hint return the select) from the stored procedure.
*/
CREATE FUNCTION F_CONVERT_TO_EURO(CND DECIMAL(10,2))
	RETURNS DECIMAL(10,2)
    BEGIN
		RETURN (CND * 0.72);
    END

CREATE PROCEDURE P_STAFF_COSTS_EURO ()
	BEGIN
        SELECT NAME, DEPT, SALARY, COMM, F_CONVERT_TO_EURO(SALARY+COMM) FROM STAFF;
    END


#FOR TEST
CALL P_STAFF_COSTS_EURO();
/*
Question 6 (15 marks )
Create a user-defined function (F_GET_LET_NUMB) to do the following:

- It will accept 2 inputs DATA_STRING and L_OR_N. The DATA_STRING will be a varchar with letters and numbers. 
The value of L_OR_N will be ‘NUMB’ or ‘ LETT’. 

- Your function will strip out all the Numbers or all the Letters in the string and return them.  
*/
CREATE FUNCTION F_GET_LET_NUMB (DATA_STRING VARCHAR(10), L_OR_N CHAR(4)) 
	RETURNS VARCHAR(10)
BEGIN
	DECLARE LETTERS VARCHAR(10);
    DECLARE NUMBERS VARCHAR(10);
    DECLARE COUNTER INTEGER;
    DECLARE SUBSTR 	VARCHAR(10);
    
    SET COUNTER = 1;
    
	WHILE COUNTER <= LENGTH(DATA_STRING) DO
		SET SUBSTR = SUBSTRING(DATA_STRING, COUNTER, 1);
        
		IF SUBSTR IN ('1', '2', '3', '4', '5', '6', '7', '8', '9', '0') THEN
			SET NUMBERS = CONCAT(IFNULL(NUMBERS, ' '),SUBSTR);
        ELSE
			SET LETTERS = CONCAT(IFNULL(LETTERS, ' '),SUBSTR);
        END IF;
            
		SET COUNTER = COUNTER + 1;
	END WHILE;
        
    IF L_OR_N = 'NUMB' THEN
		RETURN NUMBERS;
	ELSE IF L_OR_N = 'LETT' THEN
		RETURN LETTERS;
    END IF;
    
END


#FOR TEST
SELECT F_GET_LET_NUMB ('L12U3C3Y', 'NUMB') ;