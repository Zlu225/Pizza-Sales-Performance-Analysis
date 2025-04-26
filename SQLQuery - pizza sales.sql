select * from [dbo].[pizza_sales];

--1. Total Revenue
select 
sum(total_price) AS Total_revenue
from [dbo].[pizza_sales]

--2. Average Order Value
SELECT 
sum(total_price)/COUNT(distinct order_id) AS Avg_order_Value
from [dbo].[pizza_sales]

--3. Total Pizzas Sold
SELECT sum(quantity) AS Total_pizza_sold 
FROM [dbo].[pizza_sales]


--4. Total Orders
SELECT COUNT(DISTINCT order_id) AS Total_Orders 
FROM [dbo].[pizza_sales]

--5. Average Pizzas Per Order
--solution 1
SELECT ROUND(CAST(SUM(quantity) AS float)/CAST(COUNT(DISTINCT order_id) AS float),2) AS Avg_Pizzas_per_order
FROM [dbo].[pizza_sales]

--solution 2
SELECT CAST(CAST(SUM(quantity) AS DECIMAL(10,2)) / 
CAST(COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS DECIMAL(10,2))
AS Avg_Pizzas_per_order
FROM pizza_sales


--SQL Queries for Daily and Monthly Trend
-- a. Daily Trend for Total Orders
SELECT 
order_date,COUNT(distinct order_id) AS total_orders
FROM
[dbo].[pizza_sales]
group by order_date
order by order_date

--b.Weekday Trend for Total Order
SELECT DATENAME(DW, order_date) AS order_day,COUNT(distinct order_id) AS total_orders
FROM [dbo].[pizza_sales]
group by DATENAME(DW, order_date)

--C. Monthly Trend for Orders
select DATENAME(MONTH, order_date) as Month_Name, COUNT(DISTINCT order_id) as Total_Orders
from pizza_sales
GROUP BY DATENAME(MONTH, order_date)

--% of Sales by Category and Size
--D. % of Sales by Pizza Category
--Solution 1 
with sales_by_category as(
	select pizza_category, sum(total_price) as total_revenue
	from pizza_sales
	group by pizza_category
)
select 
pizza_category, 
total_revenue, 
concat(round((total_revenue/sum(total_revenue) over ())*100,2),'%') as PCT
from sales_by_category
order by total_revenue desc

--Solution 2 from Video
SELECT pizza_category, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_category;


--E. % of Sales by Pizza Size
with sales_by_category as(
	select pizza_size, sum(total_price) as total_revenue
	from pizza_sales
	group by pizza_size
)
select 
pizza_size, 
total_revenue, 
concat(round((total_revenue/sum(total_revenue) over ())*100,2),'%') as PCT
from sales_by_category
order by total_revenue desc;

SELECT pizza_size, CAST(SUM(total_price) AS DECIMAL(10,2)) as total_revenue,
CAST(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS DECIMAL(10,2)) AS PCT
FROM pizza_sales
GROUP BY pizza_size
ORDER BY pizza_size

--F. Total Pizzas Sold by Pizza Category
SELECT pizza_category, SUM(quantity) as Total_Quantity_Sold
FROM pizza_sales
GROUP BY pizza_category
ORDER BY Total_Quantity_Sold DESC

--G. Top 5 Pizzas by Revenue

SELECT Top 5 pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC

--H. Bottom 5 Pizzas by Revenue
SELECT Top 5 pizza_name, SUM(total_price) AS Total_Revenue
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue 

--I. Top 5 Pizzas by Quantity
SELECT Top 5 pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold DESC

--J. Bottom 5 Pizzas by Quantity
SELECT Top 5 pizza_name, SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Pizza_Sold 

--K. Top 5 Pizzas by Total Orders
SELECT Top 5 pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders DESC

--L. Borrom 5 Pizzas by Total Orders
SELECT Top 5 pizza_name, COUNT(DISTINCT order_id) AS Total_Orders
FROM pizza_sales
GROUP BY pizza_name
ORDER BY Total_Orders

/*---------------------------------------------------------------------
以下为制作PowerBI看板时可能会用到的testing queries
---------------------------------------------------------------------*/
--Total orders
select count(distinct order_id)  AS Total_orders
from [dbo].[pizza_sales]

--Total Revenue
select 
sum(total_price) AS Total_revenue
from [dbo].[pizza_sales]

--Average Order Value
SELECT 
sum(total_price)/COUNT(distinct order_id) AS Avg_order_Value
from [dbo].[pizza_sales]

--Total Pizza Sold
select sum(quantity) 
from [dbo].[pizza_sales]

--Avg Pizza Per Order
select round(cast(sum(quantity) as float) / cast(COUNT(distinct order_id) as float),2)
from [dbo].[pizza_sales]

--Daily Trend for Total Orders
select datename(weekday,order_date) AS ORDER_WEEKDAY, 
	CONCAT(ROUND(CAST(COUNT(DISTINCT order_id) AS float)/1000,2),'K') AS TOTAL_ORDERS
from [dbo].[pizza_sales]
group by datename(weekday,order_date)


--Total orders by Order Month
select datepart(MONTH,order_date) AS order_month, COUNT(DISTINCT order_id) AS total_orders
from [dbo].[pizza_sales]
group by datepart(MONTH,order_date)
order by datepart(MONTH,order_date)

--% of Sales by Pizza Category
with A as (
select pizza_category, sum(total_price) as category_sales
from [dbo].[pizza_sales]
group by pizza_category
)
select *, concat(Round((category_sales/sum(category_sales) over ())*100,2),'%') as sales_percentage from A;

--% of Sales by Pizza Size
with A as (
select pizza_size, sum(total_price) as category_sales
from [dbo].[pizza_sales]
group by pizza_size
)
select pizza_size, 
	
	CASE WHEN pizza_size = 'L' THEN 'Large'
		WHEN pizza_size = 'M' THEN 'Medium'
		WHEN  pizza_size = 'S' THEN 'Regular'
		WHEN  pizza_size = 'XL' THEN 'X-Large'
		ELSE 'None'
	END,
	concat(Round((category_sales/sum(category_sales) over ())*100,2),'%') as sales_percentage
from A


--Total Pizza Sold by Category
select pizza_category,sum(quantity)  as pizza_sold
from [dbo].[pizza_sales]
group by pizza_category
order by pizza_sold desc

--Top 5 Pizzas By Revenue
select top 5 [pizza_name], 
	concat(round(sum([total_price])/1000,0),'%') as total_revenue
from [dbo].[pizza_sales]
group by [pizza_name]
order by total_revenue DESC

--Top 5 Pizzas By Quantity
select top 5 [pizza_name], 
	concat(round(cast(sum(quantity) as float)/1000,1),'K') as total_quantity
from [dbo].[pizza_sales]
group by [pizza_name]
order by total_quantity DESC


--Top 5 Pizzas By Total Orders
select top 5 [pizza_name], 
	concat(round(cast(count(distinct order_id) as float)/1000,1),'K') as total_orders
from [dbo].[pizza_sales]
group by [pizza_name]
order by total_orders DESC

--Bottom 5 Pizzas By Revenue
select top 5 [pizza_name], 
	concat(round(sum([total_price])/1000,0),'%') as total_revenue
from [dbo].[pizza_sales]
group by [pizza_name]
order by total_revenue 

--Bottom 5 Pizzas By Quantity
select top 5 [pizza_name], 
	concat(round(cast(sum(quantity) as float)/1000,1),'K') as total_quantity
from [dbo].[pizza_sales]
group by [pizza_name]
order by total_quantity


--Bottom 5 Pizzas By Total Orders
select top 5 [pizza_name], 
	concat(round(cast(count(distinct order_id) as float)/1000,1),'K') as total_orders
from [dbo].[pizza_sales]
group by [pizza_name]
order by total_orders 
