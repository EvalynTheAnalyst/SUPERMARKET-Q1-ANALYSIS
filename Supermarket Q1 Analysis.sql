#CREATE DATABASE SupermarketData;
#DROP TABLE SupermarketDt;
use SupermarketData;
CREATE TABLE SupermarketDt(
InvoiceID text,
Branch text,
City text,
Customer text,
Gender text,
Productline text,
UnitPrice numeric,
Quantity int4,
TaxPercentage numeric,
Total numeric,
Date text,
Time text,
Payment text,
cogs numeric,
GrossMarginPercent numeric,
GrossIncome numeric,
Rating numeric
);

# Sanity check 
SELECT *
FROM supermarketdata.supermarket_sales
WHERE `Tax 5%` IS NULL or `Time` IS NULL OR `Payment` IS NULL OR `cogs` IS NULL OR 
`gross income` IS NULL OR `gross margin percentage` IS NULL OR `Rating` IS NULL;

# Checking for duplicate values
SELECT `Invoice ID`, `Branch`,`City`,`Customer type`,`Gender`, `Product line`,Date,Time,
COUNT(*) AS count
FROM supermarketdata.supermarket_sales
GROUP BY `Invoice ID`, `Branch`,`City`,`Customer type`,`Gender`, `Product line`,Date,Time
HAVING COUNT(*) > 1;

SELECT *
FROM supermarketdata.supermarket_sales;

# converting Date and Time text values to Date and Time Datatype
SET SQL_SAFE_UPDATES = 0;
UPDATE supermarketdata.supermarket_sales
SET `Date` = STR_TO_DATE(Date,  '%m/%d/%Y'); 

ALTER TABLE supermarketdata.supermarket_sales
MODIFY `Date` Date;

SET SQL_SAFE_UPDATES = 1; 
update supermarketdata.supermarket_sales
SET `Time` = STR_TO_DATE(`Time`, '%H:%i') 
WHERE `Time` IS NOT NULL;

ALTER TABLE supermarketdata.supermarket_sales
MODIFY `Time` Time;

describe supermarketdata.supermarket_sales;

# Total Transaction by Customer Type
SELECT
	`Customer type`,
    sum(Total) As Revenue,
	Count(*) AS Total_transaction
FROM supermarketdata.supermarket_sales
GROUP BY `Customer type`;

# Average spending per Customer
SELECT
	`invoice ID`,
    AVG(Total) as Avg_spending
FROM supermarketdata.supermarket_sales
GROUP BY `Invoice ID`
ORDER BY Avg_spending DESC;

SELECT
	`invoice ID`,
    AVG(Total) as Avg_spending
FROM supermarketdata.supermarket_sales
GROUP BY `Invoice ID`
ORDER BY Avg_spending;

# sales performance over time.
Select
	`Date`, 
    SUM(`Quantity`) AS TotalQuantity,
    sum(`Total`) As TotalRevenue
FROM supermarketdata.supermarket_sales
GROUP BY Date
order by Date;

#Identify peak sales days and time slots.
SELECT 
        CASE 
           WHEN DAYOFWEEK(Date) = 1 THEN 'Sunday'
           WHEN DAYOFWEEK(Date) = 2 THEN 'Monday'
           WHEN DAYOFWEEK(Date) = 3 THEN 'Tuesday'
           WHEN DAYOFWEEK(Date) = 4 THEN 'Wednesday'
           WHEN DAYOFWEEK(Date) = 5 THEN 'Thursday'
           WHEN DAYOFWEEK(Date) = 6 THEN 'Friday'
           WHEN DAYOFWEEK(Date) = 7 THEN 'Saturday'
       END AS Day_Name,
       CASE 
           WHEN HOUR(Time) BETWEEN 5 AND 11 THEN 'Morning'
           WHEN HOUR(Time) BETWEEN 12 AND 16 THEN 'Afternoon'
           WHEN HOUR(Time) BETWEEN 17 AND 20 THEN 'Evening'
           ELSE 'Night'
       END AS Time_Period,
	sum(`Total`) As TotalRevenue
FROM supermarketdata.supermarket_sales
GROUP BY Day_Name,Time_period
ORDER BY TotalRevenue desc;

#day with Highest Sales 
SELECT 
        CASE 
           WHEN DAYOFWEEK(Date) = 1 THEN 'Sunday'
           WHEN DAYOFWEEK(Date) = 2 THEN 'Monday'
           WHEN DAYOFWEEK(Date) = 3 THEN 'Tuesday'
           WHEN DAYOFWEEK(Date) = 4 THEN 'Wednesday'
           WHEN DAYOFWEEK(Date) = 5 THEN 'Thursday'
           WHEN DAYOFWEEK(Date) = 6 THEN 'Friday'
           WHEN DAYOFWEEK(Date) = 7 THEN 'Saturday'
       END AS Day_Name,
	sum(`Total`) As TotalRevenue
FROM supermarketdata.supermarket_sales
GROUP BY Day_Name
ORDER BY TotalRevenue desc;

# Time period with Highest sales 
SELECT 
       CASE 
           WHEN HOUR(Time) BETWEEN 5 AND 11 THEN 'Morning'
           WHEN HOUR(Time) BETWEEN 12 AND 16 THEN 'Afternoon'
           WHEN HOUR(Time) BETWEEN 17 AND 20 THEN 'Evening'
           ELSE 'Night'
       END AS Time_Period,
	sum(`Total`) As TotalRevenue
FROM supermarketdata.supermarket_sales
GROUP BY Time_period
ORDER BY TotalRevenue desc;

#Query to rank product lines by total revenue.
SELECT 
	`product line`,
    sum(Total) as Revenue,
    RANK()over(ORDER by SUM(`Total`)DESC)as Ranks
FROM supermarketdata.supermarket_sales
GROUP BY `Product line`;

#Compute average quantity sold per product category.
SELECT 
	`product line`,
    Round(AVG(Quantity),0) AS AVGquantity
FROM supermarketdata.supermarket_sales
Group By `Product line`;

#branches that produces the highest sales.
SELECT
	Branch,
    SUM(Total) AS Revenue
FROM supermarketdata.supermarket_sales
GROUP BY Branch
ORDER BY Revenue DESC;


# Product with the highest revenue
SELECT `Product line`, 
sum(Total) AS Revenue
FROM supermarketdata.supermarket_sales
GROUP BY `Product line`
ORDER BY Revenue Desc;


#Query to determine the most preferred payment methods.
SELECT
	Payment,
    COUNT(*) as Totalpre
FROM supermarketdata.supermarket_sales
GROUP BY Payment
ORDER BY Totalpre Desc;

#Evaluate the correlation between payment methods and customer satisfaction.
SELECT 
	(COUNT(*) * SUM(Payment_Numeric * Rating) - SUM(Payment_Numeric) * SUM(Rating)) /
    (SQRT((COUNT(*) * SUM(Payment_Numeric * Payment_Numeric) - POWER(SUM(Payment_Numeric), 2)) * 
          (COUNT(*) * SUM(Rating * Rating) - POWER(SUM(Rating), 2)))) 
    AS Payment_Rating_Correlation
FROM (
    SELECT 
        CASE 
            WHEN Payment = 'Cash' THEN 1
            WHEN Payment = 'Credit Card' THEN 2
            WHEN Payment = 'E-Wallet' THEN 3
        END AS Payment_Numeric,
        Rating
    FROM supermarketdata.supermarket_sales
) AS temp;

# Compare sales revenue across branches and cities.
SELECT 
	Branch,
    City,
    SUM(Total) AS Revenue
FROM supermarketdata.supermarket_sales
GROUP BY Branch,City;

# Compute the highest profit margins by product category.
SELECT
	`Product line`,
	`gross margin percentage`
FROM supermarketdata.supermarket_sales
GROUP BY `Product line`,`gross margin percentage`;

# total gross income and gross margin percentages using SQL.
SELECT 
	SUM(`gross income`) as GrossIncome,
	AVG(`gross margin percentage`) AS AvgGrossMargin
FROM supermarketdata.supermarket_sales;

# Analyze customer ratings by product line and store branch.
SELECT 
	`Branch`,
    `Product line`,
    AVG(`Rating`) AS avgRating,
    min(`Rating`) AS minRating,
    max(Rating) As maxRating
FROM supermarketdata.supermarket_sales
GROUP BY  Branch,`Product line`;

#Minimum transaction amount spent by each customer
SELECT 
	`Invoice ID` as Customer,
    AVG(`Total`) AS spend
FROM supermarketdata.supermarket_sales
GROUP BY `Invoice ID` ,`Product line`
ORDER BY spend;

# Factors influencing higher customer satisfaction scores.
SELECT *
FROM supermarketdata.supermarket_sales
WHERE Rating > 7;

#Gender that contribute to high revenue
SELECT 
	`Gender`,
    sum(`gross income`)  as Profit
FROM supermarketdata.supermarket_sales
GROUP BY Gender;

#Total Cogs, Profit, Revenue
SELECT 
	(SUM(cogs)/SUM(Total))*100 AS percentageCostOfRev,
    SUM(`gross income`) AS Profit
FROM supermarketdata.supermarket_sales;

#Avg Gross income Per transaction?
WITH AvgGrosss AS (
    SELECT 
        `Invoice ID`,
        AVG(`gross income`) AS profit
    FROM supermarketdata.supermarket_sales
    GROUP BY `Invoice ID`
)
SELECT 
    AVG(profit) as AvgProfits
FROM AvgGrosss;

