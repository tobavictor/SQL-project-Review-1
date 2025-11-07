USE Toba;
GO


-- Drop table if it already exists
IF OBJECT_ID('dbo.Project1', 'U') IS NOT NULL
    DROP TABLE dbo.Project1;
GO

-- Create table
CREATE TABLE dbo.Project1 (
    transactions_id INT,
    sale_date DATE,
    sale_time TIME,
    customer_id INT,
    gender NVARCHAR(15),
    age INT,
    category NVARCHAR(100),
    quantity INT,
    price_per_unit FLOAT,
    cogs FLOAT,
    total_sale FLOAT
);

-- Load data from your mounted path
BULK INSERT dbo.Project1
FROM '/var/opt/mssql/data/Project1.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0A',
    TABLOCK
);

--1. Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT *
FROM Project1
WHERE sale_date = '2022-11-05';

--2. Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT
    transactions_id,
    category,
    quantity
FROM Project1
WHERE category='Clothing'
    AND sale_date BETWEEN '2022-11-01' AND '2022-11-30'
    AND quantity> 4;

 --3. Write a SQL query to calculate the total sales (total_sale) for each category.:
SELECT DISTINCT
    category,
    SUM(total_sale) AS TotalSaleSum
 FROM Project1
 GROUP BY category;

--4. Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT
    AVG(age) AS AVGage,
    category
FROM Project1
WHERE category= 'Beauty'
GROUP BY category;

--5. Write a SQL query to find all transactions where the total_sale is greater than 1000:
SELECT
    transactions_id,
    total_sale
FROM Project1
WHERE total_sale >1000;

--6. Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
SELECT
    gender,
    COUNT(transactions_id) AS TotalTx,
    category
FROM Project1
GROUP BY gender, category
ORDER BY gender, category;


--7. Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
With MonthlySales AS(
    SELECT
        DATEPART(Month, sale_date) AS Mnth,
        AVG(CONVERT (INT, total_sale)) AS avgsale,
        DATEPART(Year, sale_date) AS yeah
    FROM Project1
    GROUP BY DATEPART(Month, sale_date),  DATEPART(Year, sale_date)
)
SELECT *

FROM 
(
    SELECT *,
        RANK() OVER (PARTITION BY yeah ORDER BY avgsale DESC) AS RankMonth
    FROM MonthlySales
) ranked
WHERE RankMonth = 1
ORDER BY yeah;

--8. Write a SQL query to find the top 5 customers based on the highest total sales
SELECT TOP(5)
    customer_id,
    SUM(total_sale) AS TOTAL_SALE
FROM Project1
GROUP BY customer_id
ORDER by TOTAL_SALE desc;

--9. Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT
    category,
    COUNT(DISTINCT customer_id) AS UniqueCustomers
FROM Project1
GROUP BY category
ORDER BY UniqueCustomers DESC;

--10. Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN DATEPART(HOUR, sale_time) < 12 THEN 'Morning' 
            WHEN DATEPART(HOUR, sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM Project1
)
SELECT 
    shift,
    COUNT(*) AS TotalOrders    
FROM hourly_sale
GROUP BY shift
ORDER BY TotalOrders DESC;