/*=================================
Drop the data base if exists.
===================================*/

DROP DATABASE IF EXISTS project1;

/*===================================
Create Database.
=====================================*/

CREATE DATABASE project1 

/*===========================================
Select Databse.
=============================================*/

USE project1;

/*===========================================
Create Table.
=============================================*/
CREATE TABLE data_p1
       (
       order_id INT PRIMARY KEY,
       order_date DATE,
       dispatch_time TIME,
       customer_id INT,
       region VARCHAR(100),
       category VARCHAR(100),
       quantity INT,
       unit_price FLOAT,
       cogs FLOAT,
       delivery_status VARCHAR(100)
       )

/*=========================================================================================================================================================================================================
Import .CSV file.
=========================================================================================================================================================================================================*/

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/erp_messy_data.csv' INTO TABLE data_p1 FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n'
IGNORE 1 ROWS
       (
       order_id,
       order_date,
       dispatch_time,
       customer_id,
       region,
       category,
       quantity,
       unit_price,
       cogs,
       delivery_status
       );


/*=========================================================================================================================================================================================================
Changed the Constraints because of trash data.
=========================================================================================================================================================================================================*/

ALTER TABLE data_p1 MODIFY COLUMN unit_price VARCHAR(50),
MODIFY COLUMN quantity VARCHAR(50)

/*=========================================================================================================================================================================================================
Select the compete table for exploration
=========================================================================================================================================================================================================*/

SELECT *
FROM data_p1
LIMIT 50000

/*=========================================================================================================================================================================================================
Q1. "Pull a quick list of all records where critical fields like dispatch time, quantity, or unit price are blank. Delete them from the table so they don't skew our math."
=========================================================================================================================================================================================================*/

DELETE
FROM data_p1
WHERE dispatch_time IS NULL
  OR dispatch_time = ''
  OR quantity IS NULL
  OR quantity = ''
  OR quantity = '0'
  OR unit_price IS NULL
  OR unit_price = ''
  OR unit_price = '0' -- deleted 5363 rows.

/*=========================================================================================================================================================================================================
Q2. "I suspect there's a bug in the data entry. Find any records where the quantity is zero or a negative number and remove those too."
=========================================================================================================================================================================================================*/

DELETE
FROM data_p1 WHERE quantity <= 0 -- deleted 3909 rows.

/*=========================================================================================================================================================================================================
Q3. "The region and category columns have weird capitalizations and extra spaces. Can you update the table to remove spaces and make everything uppercase?"
=========================================================================================================================================================================================================*/

UPDATE data_p1
SET category = UPPER(TRIM(category))
UPDATE data_p1
SET region = UPPER(TRIM(region))
SELECT *
FROM data_p1 

/*=========================================================================================================================================================================================================
Q4. "Let's check our margins. Flag any orders where the Cost of Goods Sold (COGS) is actually higher than the unit price. We shouldn't be losing money on a sale."
=========================================================================================================================================================================================================*/

SELECT *
FROM data_p1 WHERE COGS > Unit_Price
LIMIT 1000

/*=========================================================================================================================================================================================================
Q5, "I need the exact details for all orders dispatched on Halloween (October 31st, 2022)."
=========================================================================================================================================================================================================*/

SELECT *
FROM data_p1
WHERE order_date = '2022-10-31'

/*=========================================================================================================================================================================================================
Q6. "Pull a list of all 'Hardware' orders where they bought more than 20 items. Limit it to only orders placed in November 2022."
=========================================================================================================================================================================================================*/

SELECT *
FROM data_p1 WHERE category = 'HARDWARE'
AND quantity >= 20
AND MONTH(order_date) = 11
AND YEAR(order_date) = 2022
ORDER BY order_date,
       quantity,
       category
/*=========================================================================================================================================================================================================
Q7. "What's the total gross revenue (quantity * unit_price) broken down by product category?"
=========================================================================================================================================================================================================*/

SELECT category,
       ROUND(SUM(unit_price * quantity), 2) AS Total_Gross_Revenue
FROM data_p1
GROUP BY category;

/*=========================================================================================================================================================================================================
Q8. "What is the average order quantity for our B2B clients in the 'East' region?"
=========================================================================================================================================================================================================*/

SELECT region,
       ROUND(AVG(quantity)) AS avg_quantity
FROM data_p1
WHERE region = 'EAST';

/*=========================================================================================================================================================================================================
Q9. "Find all the 'whale' transactions—any single order where the total order value was over $60,000."
=========================================================================================================================================================================================================*/

SELECT *
FROM data_p1
WHERE (quantity * unit_price) >= 60000;

/*=========================================================================================================================================================================================================
Q10. "How many unique B2B clients do we actually have purchasing from each region?"
=========================================================================================================================================================================================================*/

SELECT region,
       COUNT(DISTINCT(customer_id))
FROM data_p1
GROUP BY region;

/*=========================================================================================================================================================================================================
Q11. "Give me a breakdown of order counts by delivery status, but keep it separated by product category."
=========================================================================================================================================================================================================*/

SELECT category,
       delivery_status,
       COUNT(*) AS total_orders
FROM data_p1
GROUP BY category,
       delivery_status
ORDER BY category,
       delivery_status

/*=========================================================================================================================================================================================================         
Q12. "Which specific customer ID has generated the absolute highest gross revenue for us overall? Give me the top 5."
=========================================================================================================================================================================================================*/

SELECT
    customer_id,
    ROUND(SUM(quantity * unit_price), 2) AS total_revenue
FROM data_p1
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 5;

/*=========================================================================================================================================================================================================
Q13. "Are there any clients who have experienced 'Delayed' deliveries more than 200 times? Who are they?"
=========================================================================================================================================================================================================*/

SELECT customer_id,
       COUNT(*) AS delayed_count
FROM data_p1
WHERE delivery_status LIKE 'delay%'
GROUP BY customer_id
HAVING COUNT(*) > 200;

/*=========================================================================================================================================================================================================
Q14. "What is the average profit margin per unit (unit_price - cogs) we are making on 'Peripherals'?"
=========================================================================================================================================================================================================*/

SELECT category,
       ROUND(AVG(unit_price - cogs)) AS Avg_Profit
FROM data_p1
WHERE category = 'PERIPHERALS'

/*=========================================================================================================================================================================================================
Q15. "I want to see the total number of items sold per day, but only show me days where we pushed out more than 7500 items total."
=========================================================================================================================================================================================================*/

SELECT order_date,
         SUM(quantity) AS Total_sales
FROM data_p1
GROUP BY order_date
HAVING SUM(quantity) > 7500
ORDER BY order_date

/*=========================================================================================================================================================================================================
Q16. "What was our single best-selling month for each year? I need the year, the month, and the total revenue."
=========================================================================================================================================================================================================*/

WITH Monthly_Revenue AS
       (SELECT YEAR(order_date) AS YEAR,
       MONTH(order_date) AS MONTH,
       ROUND(SUM(quantity * unit_price)) AS Total_Revenue
FROM data_p1
GROUP BY YEAR(order_date),
       MONTH(order_date)),

Ranked_Months AS
       (SELECT *,
       RANK() OVER(PARTITION BY YEAR
       ORDER BY Total_Revenue DESC) AS Revenue_Rank
FROM Monthly_Revenue)
SELECT YEAR,
       MONTH,
       Total_Revenue
FROM Ranked_Months
WHERE Revenue_Rank = 1;

/*=========================================================================================================================================================================================================
Q17. We need to optimize warehouse staffing. Group the dispatch times into 'Morning' (before 12pm), 'Afternoon' (12pm-5pm), and 'Evening' (after 5pm). How many orders go out in each shift?
=========================================================================================================================================================================================================*/

WITH hourly_sales AS 
       (SELECT *, 
       CASE 
              WHEN HOUR(dispatch_time) < 12 THEN "Morning" 
              WHEN HOUR(dispatch_time) BETWEEN 12 AND 17 THEN "Afternoon" 
              ELSE "Evening"
              END AS Shift
FROM data_p1)
SELECT Shift,
       COUNT (*) AS total_orders
FROM hourly_sales
GROUP BY Shift;

/*=========================================================================================================================================================================================================
Q18. "For the 'Morning' shift specifically, which product category is dispatched the most?"
=========================================================================================================================================================================================================*/

WITH hourly_sales AS
       (SELECT *,
       CASE
              WHEN HOUR(dispatch_time) < 12 THEN "Morning"
              WHEN HOUR(dispatch_time) BETWEEN 12 AND 17 THEN "Afternoon"
              ELSE "evening"
              END AS Shift
FROM data_p1)
SELECT Shift,
       category,
       COUNT(*) AS No_products
FROM hourly_sales
WHERE Shift = "Morning"
GROUP BY category
ORDER BY No_products DESC
LIMIT 1;;

/*=========================================================================================================================================================================================================
Q19. "Which product category brings in the highest average revenue per order? Rank them 1 to 3."
=========================================================================================================================================================================================================*/

WITH category_revenue AS
       (SELECT category,
       AVG(quantity * unit_price) AS avg_revenue_per_order
FROM data_p1
GROUP BY category),

ranked_categories AS
       (SELECT category,
       avg_revenue_per_order,
       RANK() OVER (ORDER BY avg_revenue_per_order DESC) AS revenue_rank
FROM category_revenue)

SELECT category,
       ROUND(avg_revenue_per_order, 2) AS avg_revenue_per_order,
       revenue_rank
FROM ranked_categories
WHERE revenue_rank <= 3
ORDER BY revenue_rank;

/*=========================================================================================================================================================================================================================
Q20. "Finally, I need a 'Risk Report'. Find all customers who have a return rate—basically, anyone who has ever returned an item—and tell me how many items they returned in total, sorted by the worst offenders."
=========================================================================================================================================================================================================================*/

SELECT customer_id,
       SUM(quantity) AS total_returned_items
FROM data_p1
WHERE delivery_status LIKE '%return%'
GROUP BY customer_id
ORDER BY total_returned_items DESC;

