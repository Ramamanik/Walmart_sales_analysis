select 
  * 
from 
  wm_sales_analysis.walmartsalesdata;
  --------------------------------------------------------------
CREATE TABLE IF NOT EXISTS wm_sales_analysis.walmartsalesdata(
  invoice_id VARCHAR(30) NOT NULL PRIMARY KEY, 
  branch VARCHAR(5) NOT NULL, 
  city VARCHAR(30) NOT NULL, 
  customer_type VARCHAR(30) NOT NULL, 
  gender VARCHAR(30) NOT NULL, 
  product_line VARCHAR(100) NOT NULL, 
  unit_price DECIMAL(10, 2) NOT NULL, 
  quantity INT NOT NULL, 
  tax_pct FLOAT(6, 4) NOT NULL, 
  total DECIMAL(12, 4) NOT NULL, 
  date DATETIME NOT NULL, 
  time TIME NOT NULL, 
  payment VARCHAR(15) NOT NULL, 
  cogs DECIMAL(10, 2) NOT NULL, 
  gross_margin_pct FLOAT(11, 9), 
  gross_income DECIMAL(12, 4), 
  rating FLOAT(2, 1)
);
----------------------------------------------------------
SELECT 
  time, 
  (
    CASE WHEN `time` BETWEEN "00:00:00" 
    AND "12:00:00" THEN "Morning" WHEN `time` BETWEEN "12:01:00" 
    AND "16:00:00" THEN "Afternoon" ELSE "Evening" END
  ) AS time_of_day 
FROM 
  wm_sales_analysis.walmartsalesdata;
  --------------------------------------------------------------
select 
  distinct(city) 
from 
  wm_sales_analysis.walmartsalesdata;
  -----------------------------------------------------------------
-- Alter table wm_sales_analysis.walmartsalesdata ADD column Time_of_day varchar(20);

/* UPDATE wm_sales_analysis.walmartsalesdata
SET time_of_day = (
  CASE
    WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);
*/
--------------------------------------------------------------------
# Find city in each branch
select 
  distinct(city), 
  branch 
from 
  wm_sales_analysis.walmartsalesdata 
order by 
  branch;
  -----------------------------------------------------
#How many unique product lines does the data have?
select 
  `Product line`, 
  count(`Product line`) 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  `Product line`;
 -------------------------------------------------------- 
# most common payment method
with cte as (
  select 
    payment, 
    count(*) as cnt 
  from 
    wm_sales_analysis.walmartsalesdata 
  group by 
    payment 
  order by 
    2 desc
) 
select 
  * 
from 
  cte 
limit 
  1;
 ------------------------------------------------------------- 
# most selling product line
select 
  `Product line`, 
  sum(Quantity) 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  `Product line` 
order by 
  2 desc 
limit 
  1;
SELECT 
  date, 
  DAYNAME(date) 
FROM 
  wm_sales_analysis.walmartsalesdata;
  --------------------------------------------------------------
-- ALTER TABLE wm_sales_analysis.walmartsalesdata ADD COLUMN day_name VARCHAR(10);
-- UPDATE wm_sales_analysis.walmartsalesdata
-- SET day_name = DAYNAME(date);
-- Add month_name column
--------------------------------------------------------------------
SELECT 
  date, 
  MONTHNAME(date) 
FROM 
  wm_sales_analysis.walmartsalesdata;
-- ALTER TABLE wm_sales_analysis.walmartsalesdata ADD COLUMN month_name VARCHAR(10);
-- UPDATE wm_sales_analysis.walmartsalesdata
-- SET month_name = MONTHNAME(date) where 1=1;
----------------------------------------------------------------------------------
SET 
  SQL_SAFE_UPDATES = 0;
-- What is the total revenue by month
-----------------------------------------------------------------------------------
select 
  month_name as month, 
  sum(Total) as total_revenue 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  month_name 
order by 
  2;
  -----------------------------------------------------------------------------------
-- What month had the largest COGS?
select 
  month_name, 
  sum(cogs) 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  month_name 
order by 
  2 desc 
limit 
  1;
---------------------------------------------------------------------------------------------
-- What product line had the largest revenue?
SELECT 
  'product line', 
  SUM(total) as total_revenue 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  'product line' 
order by 
  2 desc;
------------------------------------------------------------------
-- What is the city with the largest revenue?
select 
  t.* 
from 
  (
    select 
      city, 
      Branch, 
      sum(total) as total_revenue 
    from 
      wm_sales_analysis.walmartsalesdata 
    group by 
      1, 
      2 
    order by 
      3 desc 
    limit 
      1
  ) t;
  ------------------------------------------------------------------
  
-- What product line had the largest VAT?
select 
  'product line', 
  max(`Tax 5%`) 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  1 
order by 
  2 desc;
-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
--------------------------------------------------------------------------------
SELECT 
  AVG(quantity) AS avg_qnty 
FROM 
  wm_sales_analysis.walmartsalesdata;
  ------------------------------------------------------------------------------
select 
  `product line`, 
  quantity, 
  case when avg(quantity)> 7 then "good" else "bad" end as remark 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  `product line`, 
  quantity 
order by 
  quantity desc;
------------------------------------------------------------------------------
-- Which branch sold more products than average product sold?
select 
  branch, 
  sum(quantity) as pdt_sold 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  branch 
having 
  sum(quantity) >(
    select 
      avg(quantity) 
    from 
      wm_sales_analysis.walmartsalesdata
  );
-------------------------------------------------------------------------------------------
-- What is the most common product line by gender
SELECT 
  gender, 
  `product line`, 
  COUNT(gender) AS total_cnt 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  gender, 
  `product line` 
ORDER BY 
  total_cnt DESC;
  --------------------------------------------------------------------------------
-- What is the average rating of each product line
SELECT 
  ROUND(
    AVG(rating), 
    2
  ) as avg_rating, 
  `product line` 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  `product line` 
ORDER BY 
  avg_rating DESC;
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT 
  DISTINCT `customer type` 
FROM 
  wm_sales_analysis.walmartsalesdata;
  ---------------------------------------------------------------------
-- How many unique payment methods does the data have?
SELECT 
  DISTINCT payment 
FROM 
  wm_sales_analysis.walmartsalesdata;
  ---------------------------------------------------------------------
-- What is the most common customer type?
SELECT 
  `customer type`, 
  count(*) as count 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  `customer type` 
ORDER BY 
  count DESC;
  -----------------------------------------------------------------------
-- Which customer type buys the most?
SELECT 
  `customer type`, 
  COUNT(*) 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  `customer type`;
  ------------------------------------------------------------------------
-- What is the most of the customers gender?
SELECT 
  gender, 
  COUNT(*) as gender_cnt 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  gender 
ORDER BY 
  gender_cnt DESC;
  ---------------------------------------------------------------------
-- What is the gender distribution per branch?
SELECT 
  branch, 
  gender, 
  COUNT(*) as gender_cnt 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  branch, 
  gender 
order by 
  branch, 
  gender;
  -----------------------------------------------------------------------

-- Which time of the day do customers give most ratings?
SELECT 
  time_of_day as tm, 
  avg(rating) AS avg_rating 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  time_of_day 
ORDER BY 
  avg_rating DESC;
  ---------------------------------------------------------------------
-- Which time of the day do customers give most ratings per branch?
SELECT 
  Time_of_day, 
  branch, 
  round(
    avg(rating)
  ) AS avg_rating 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  Time_of_day, 
  branch 
ORDER BY 
  avg_rating DESC 
limit 
  1;
  ---------------------------------------------------------------------
-- Which day fo the week has the best avg ratings?
SELECT 
  day_name, 
  AVG(rating) AS avg_rating 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  day_name 
ORDER BY 
  avg_rating DESC;
  -----------------------------------------------------------------------

--  How many sales are made on these days?
SELECT 
  day_name, 
  COUNT(day_name) total_sales 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  day_name 
ORDER BY 
  total_sales DESC;
-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday 
SELECT 
  time_of_day, 
  day_name, 
  COUNT(*) AS total_sales 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  time_of_day, 
  day_name 
ORDER BY 
  time_of_day asc, 
  total_sales DESC;
  -------------------------------------------------------------------
-- Which of the customer types brings the most revenue?
SELECT 
  `customer type`, 
  round(
    max(total), 
    2
  ) AS total_revenue 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  `customer type` 
ORDER BY 
  total_revenue desc;
  ----------------------------------------------------------------
-- Which city has the largest tax/VAT percent?
SELECT 
  city, 
  ROUND(
    max(`Tax 5%`), 
    2
  ) AS High_tax_pct 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  city 
ORDER BY 
  High_tax_pct DESC;
  -------------------------------------------------------------
-- Which customer type pays the most in VAT?
select 
  `Customer type`, 
  max(`Tax 5%`) as max_tax 
from 
  wm_sales_analysis.walmartsalesdata 
group by 
  `customer type` 
order by 
  max_tax desc 
limit 
  2;
----------------------------------------------------------------
SELECT 
  `customer type`, 
  AVG(`Tax 5%`) AS avg_tax 
FROM 
  wm_sales_analysis.walmartsalesdata 
GROUP BY 
  `customer type` 
ORDER BY 
  avg_tax;
  
