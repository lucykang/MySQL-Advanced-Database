/*
NAME: HAE YEON KANG (LUCY)
THIS IS ADVANCED DATABASE ASSIGNMENT 3.

Stored Procedure Questions :

Question 1 (15 marks)
Create a stored procedure (P_TOTAL_PRICES) that has one OUT parameter (n_total_price).  
Use a loop to iterate through the records in the PRODUCT table.
Add each price to n_total_price, on each iteration, to output the total cost of the products in the PRODUCTS table.
*/
CREATE PROCEDURE P_TOTAL_PRICES (OUT N_TOTAL_PRICE DECIMAL(30,2))
BEGIN
	DECLARE C_PRICE DECIMAL(10,2);
	DECLARE FOUND BOOLEAN DEFAULT TRUE;
	DECLARE C_TOTAL_PRICE CURSOR FOR
		SELECT PRICE FROM PRODUCT;
	DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET FOUND = FALSE;
	SET N_TOTAL_PRICE = 0;
    
    OPEN C_TOTAL_PRICE;
    FETCH C_TOTAL_PRICE INTO C_PRICE;
    WHILE FOUND DO
		SET N_TOTAL_PRICE = N_TOTAL_PRICE + C_PRICE;
        FETCH C_TOTAL_PRICE INTO C_PRICE;
	END WHILE;
    CLOSE C_TOTAL_PRICE;
END

-- CALL P_TOTAL_PRICES (@TOTAL);
-- SELECT @TOTAL;
-- SELECT PRICE FROM PRODUCT;
/*
Question 2 (25 marks)
Create a stored procedure (P_DEL_D11) that CREATES a GLOBAL TEMPORARY TABLE, that is based on the following query 
(SELECT distinct firstname as fname, lastname as lname,workdept as deptnum FROM employee e).  
Then issues a DELETE on the GLOBAL TEMPORARY table deleting records with deptnum = ‘D11’.
*/
CREATE PROCEDURE P_DEL_D11()
BEGIN
	CREATE TEMPORARY TABLE TEMP_EMP 
		SELECT FIRSTNME AS FNAME, LASTNAME AS LNAME, WORKDEPT AS DEPTNUM 
        FROM EMPLOYEE E;
    DELETE FROM TEMP_EMP WHERE DEPTNUM = 'D11';
END

/*
Question 3 (25 marks) 
Create a stored procedure ( P_DYN_TABLE) that creates a table DYNAMICALLY by having 2 input parameters, 
1 which is the SOURCE table for that new table, and the second input is the name of the new table.  
You will need to define two statements, 1 for the structure of the table, AND 1 statement to populate it 
(Hint for the first statement you will need to build the CREATE statement by concatenating the NEW table name and the SOURCE table.  
For the second statement you will need to use the PREPARE and EXECUTE commands.).
*/
CREATE PROCEDURE P_DYN_TABLE (IN SOURCE_TBL VARCHAR(20), IN NEW_TBL_NAME VARCHAR(20))
BEGIN
	-- STRUCTURE OF THE TABLE. YOU WILL NEED TO BUILD THE CREATE STATEMENT BY CONCAT NEW TBL NAME & SOURCE TBL NAME
    DECLARE TBL_NAME VARCHAR(50);
    
    SET @TBL_NAME = CONCAT(NEW_TBL_NAME, '_',SOURCE_TBL);
    SET @STR = CONCAT('CREATE TABLE ', @TBL_NAME, ' LIKE ', SOURCE_TBL);
    
    PREPARE STMT FROM @STR;
    EXECUTE STMT ;
    
    -- STATEMENT TO POPULATE THE TABLE. PREPARE AND EXCUTE COMMAND.
    SET @STR2 = CONCAT('INSERT INTO ', @TBL_NAME, ' SELECT * FROM ', SOURCE_TBL);
    PREPARE STMT FROM @STR2;
    EXECUTE STMT ;
END

CALL P_DYN_TABLE ('SALES', 'COPY');
SELECT * FROM COPY_SALES;

/* 
Question 4 (40 marks) 
Write a statement to create a Table called  GREAT_SALES with the same columns as the SALES table.
Write a statement to create a Table called  POOR_SALES with the same columns as the SALES table.
Create a stored procedure ( P_SALES_TYPES) that creates a cursor that SELECTS  SALES_PERSON, REGION and sums up SALES.
Open the cursor and iterate through the rows and INSERT a record in the GREAT_SALES table if sales are >= 10 
otherwise INSERT into the POOR_SALES table.
*/
CREATE TABLE GREAT_SALES LIKE SALES;
CREATE TABLE POOR_SALES LIKE SALES;

CREATE PROCEDURE P_SALES_TYPES ()
BEGIN
	DECLARE V_SALES_PERSON VARCHAR(15);
    DECLARE V_REGION VARCHAR(15);
    DECLARE V_SUM_SALES INT(5);
    
	DECLARE FOUND BOOLEAN DEFAULT FALSE;
	DECLARE C_SALES	CURSOR FOR
		SELECT SALES_PERSON, REGION, SUM(SALES)
        FROM SALES
        GROUP BY SALES_PERSON, REGION
        ORDER BY 1;
    DECLARE CONTINUE HANDLER FOR NOT FOUND
		SET FOUND = TRUE;
	OPEN C_SALES;
    FETCH C_SALES INTO V_SALES_PERSON, V_REGION, V_SUM_SALES;
    
    SALES_LOOP : LOOP
		IF FOUND THEN
			LEAVE SALES_LOOP;
		ELSEIF V_SUM_SALES >= 10 
			THEN INSERT INTO GREAT_SALES SELECT * FROM SALES;
		ELSE
			THEN INSERT INTO POOR_SALES SELECT * FROM SALES;
		END IF;
		FETCH C_SALES INTO V_SALES_PERSON, V_REGION, V_SUM_SALES;
    END LOOP;
    CLOSE C_SALES;
END

CALL P_SALES_TYPES;
-- SELECT * FROM GREAT_SALES;
-- SELECT * FROM POOR_SALES;

-- SELECT * FROM SALES;