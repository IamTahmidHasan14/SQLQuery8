CREATE TABLE salesman (
    salesman_id INT,
    name VARCHAR(67),
    city VARCHAR(67),
    commission FLOAT
);

INSERT INTO salesman (salesman_id, name, city, commission)
VALUES
    (5001, 'James Hoog', 'New York', 0.15),
    (5002, 'Nail Knite', 'Paris', 0.13),
    (5005, 'Pit Alex', 'London', 0.11),
    (5006, 'Mc Lyon', 'Paris', 0.14),
    (5003, 'Lauson Hen', NULL, 0.12);

CREATE TABLE customer (
    customer_id INT,
    cust_name VARCHAR(67),
    city VARCHAR(67),
    grade INT,
    salesman_id INT
);

INSERT INTO customer (customer_id, cust_name, city, grade, salesman_id)
VALUES
    (3002, 'Nick Rimando', 'New York', 100, 5001),
    (3005, 'Graham Zusi', 'California', 200, 5002),
    (3001, 'Brad Guzan', 'London', NULL, 5005),
    (3004, 'Fabian Johns', 'Paris', 300, 5006),
    (3007, 'Brad Davis', 'New York', 200, 5001);

CREATE TABLE orders (
    ord_no INT,
    purch_amt FLOAT,
    ord_date DATE,
    customer_id INT,
    salesman_id INT
);

INSERT INTO orders (ord_no, purch_amt, ord_date, customer_id, salesman_id)
VALUES
    (70001, 150.5, '2012-10-05', 3005, 5002),
    (70009, 270.65, '2012-09-10', 3001, 5005),
    (70002, 65.26, '2012-10-05', 3002, 5001),
    (70004, 110.5, '2012-08-17', 3009, 5003),
    (70007, 948.5, '2012-09-10', 3005, 5002);

SELECT * FROM salesman;
SELECT * FROM customer;
SELECT * FROM orders;

--1
CREATE VIEW NewYorkSalesmen AS
SELECT *
FROM salesman
WHERE city = 'New York';

SELECT * FROM NewYorkSalesmen;

--2
CREATE CLUSTERED INDEX CIX_Salesman
ON salesman (salesman_id);

CREATE CLUSTERED INDEX CIX_Customer
ON customer (customer_id);

sp_helpindex salesman;
sp_helpindex customer;

--3
CREATE VIEW HighestGrade AS
SELECT *
FROM customer
WHERE grade = (SELECT MAX(grade) FROM customer);

SELECT * FROM HighestGrade;

--4
CREATE PROCEDURE GetCustomersByGrade
    @inputGrade INT
AS
BEGIN
    SELECT
        c.cust_name AS 'Customer Name',
        c.city AS 'Customer City',
        c.grade AS 'Customer Grade',
        s.name AS 'Salesman',
        s.city AS 'Salesman City'
    FROM
        customer c
    JOIN
        salesman s ON c.salesman_id = s.salesman_id
    WHERE
        c.grade < @inputGrade
    ORDER BY
        c.customer_id ASC;
END;

EXEC GetCustomersByGrade @inputGrade = 250; 

--5
CREATE PROCEDURE SP_average
AS
BEGIN
    SELECT
        c.city AS 'City',
        AVG(purch_amt) AS 'Average Purchase Amount'
    FROM
        orders o
	JOIN
		customer c ON o.salesman_id = c.salesman_id
    GROUP BY
        c.city;
END;

EXEC SP_average;

--6
SELECT
    salesman_id,
    name AS salesman_name,
    city AS salesman_city,
    commission,
    RANK() OVER (ORDER BY commission DESC) AS sales_rank
FROM
    salesman;

--7
CREATE FUNCTION fnEmployee
(
    @startValue INT,
    @endValue INT
)
RETURNS INT
AS
BEGIN
    DECLARE @result INT = 1;
    DECLARE @i INT = @startValue;

    WHILE @i <= @endValue
    BEGIN
        SET @result = @result * @i;
        SET @i = @i + 1;
    END

    RETURN @result;
END;


DECLARE @start INT = 1;
DECLARE @end INT = 10;
DECLARE @result INT;
SET @result = dbo.fnEmployee(@start, @end);
PRINT 'The multiplication of values from ' + CAST(@start AS VARCHAR) + ' to ' + CAST(@end AS VARCHAR) + ' is: ' + CAST(@result AS VARCHAR);
