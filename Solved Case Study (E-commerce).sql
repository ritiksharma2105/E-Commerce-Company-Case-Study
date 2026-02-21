Create database e_commerce_cs;

Use e_commerce_cs;

/*
E-commerce Case Study
1. Data Problem
2. Hypothesis
3. Data Understanding & Cleaning
4. Analysis (EDA) 
*/

/* 1. Data Problem
-- Customer Insights (Segmentation)
-- location based sales performance
-- Customer Retention / Repeat Purchase
-- Product Performance (Product/Revenue) Top()
-- Inventory / sales planning
-- order value & customer spending behaviour
-- time based sales trends
-- Price Sensitivity (Product Price & Qty)
*/

/* 2) Hypothesis
-- Location Wise total sales
-- using pareto analysis
-- cust purchasing behavious
-- top performing pro & categ
-- Avg order value
-- sales trend by year,month, day
-- low price pro, high sale n vice versa
-- order with multiple item have high total amt
-- frequecy bought items
*/

/* 3. Data Understanding and Data Cleaning*/
#Learn about the table 
Desc customers;
Desc order_details;
Desc orders;
Desc products;

Select * from customers;
/* With Customers Table
CustomerID- Unique or not?
Is there any null value?
How many total rows?
How many Distinct Locations?
*/

select * from order_details;
/* With Order Details Table
OrderID- Unique or not?
How many qtyies sold per Orderid and what's the total sales value?

*/ 

select * from orders;
/* With Orders Table
orderid & customerid are FK here
Order_Date is in text datatype, correct it. (yyyy-mmm-dd)
total amount per customerid
*/ 

Select * from products;
/* With Products Table
ProductID is unique or not?
How many category are there?
Category wise pricing
*/ 

-- 3.1. What is Primary key in each tabel and Remove Dublicates?

-- 1. Customers table
Select * from customers;

Select Customer_id, 
Count(*) from customers
Group BY Customer_id
Having count(*) > 1; -- No duplicate value in customers (PK)

-- 2. Order details
Select * from order_details;

Select Order_id,
Count(*) from order_details
group by order_id
Having Count(*) > 1; -- there is duplicate values (FK)

-- 3. Orders 
Select * from orders;

Select order_id,
Count(*) from orders
group by order_id
having Count(*) > 1; -- there is no duplicate values (PK)

-- 4. Products
Select * from products;

Select Product_id,
Count(*) from products
group by product_id
having count(*) > 1; -- there is no dupicate values (PK)

#-------------------------------------------------------------#
-- We have to remove the dublicates (if exist)
-- Create a dummy table 
-- Insert a data into a dummy table 
-- drop the actual tble 
-- rename the dummy table to actual table
#-------------------------------------------------------------#
    -- PART=2 Starts
    -- 3.3 null values check
    
select * from customers;
select * from order_details;
select * from orders;
select * from products;
   
Select * from customers c
Join orders o
On c.customer_id = o.customer_id
Where o.customer_id is null; -- no missing value

Select * from order_details od
Join orders o 
on od.order_id = o.Order_id
Where o.order_id is null; -- no missing value

Select * from products p
Join order_details od
On p.product_id = od.product_id
Where od.Product_id is null; -- no missing value
#-----------------------------------------------#

-- 3.3 Left JOIN
-- Row 1 and Matches Row 1
-- Row 2 no match with other table

-- Row 1 --> Row 1
-- Row 2 --> NA

Select 
    od.order_id,
    p.product_id,
    od.price_per_unit as od_price_per_unit,
    p.price as p_price
    From products p
    Join order_details od
    on p.product_id = od.product_id
    Where p.price <> od.price_per_unit; -- this identifies the not matching values, but in this all prices are matching with each other via productid
    
Select 
    od.order_id,
    p.product_id,
    od.price_per_unit as od_price_per_unit,
    p.price as p_price
    From products p
    Join order_details od
    on p.product_id = od.product_id
    Where p.price = od.price_per_unit;
    
/*
3.1 Check for the Primary Key
3.2 Validation Step - Join
3.3 Null values check 
*/

/* 3.3 -- Missing Values and Working on NULL

*/

select * from customers;
select * from order_details;
select * from orders;
select * from products;

-- there are no values in any of the columns.

/*3.4 DATE 

*/

-- 1. orders table
select * from orders;

UPDATE orders
SET order_date = STR_TO_DATE(order_date, '%d-%m-%Y');

Create table orders_updated as
Select *, cast(order_date as date) as order_date_updated
from orders;

Desc orders;

Select * from orders_updated;

Drop table orders;

Rename table orders_updated to orders;

Select * from Orders; -- new table updated & renamed

-- 3.5 Setting a primary Key

select * from customers; -- customerid (PK)
select * from order_details;
select * from orders; -- orderid (PK)
select * from products; -- Productid (PK)

Alter Table customers
add primary key (Customer_id);
desc customers;

Alter Table orders
Add primary key (order_id);
Desc orders;

Alter Table Products
Add primary key (product_id);
Desc products;

/*
1. What is the Table and how to know thw tables and cols
2. Try finding it out PRIMARY KEY AND how to check (Group by and Having)
3. Relationship between the tables -- JOIN
4. NULL -- missing values checked
5. DATE FORMATE and update with diff table 
*/

-- 4) Analysis (EDA)

-- 4.1) Analyse the Data
desc customers;
desc order_details;
desc orders;
desc products;

-- 4.2) Customer & market segmentation
Select * from customers;

Select Location,
    Count(Customer_id) as number_of_customer
From customers
Group by Location
Order By number_of_customer Desc
limit 3; -- segmentation on the basis of location

-- 4.3) Engagement Depth Analysis
Select * from orders;

Create table Engagement_analysis as 
Select 
     Customer_id,
     NumberOfOrders,
           Case
              When NumberOfOrders <= 1 Then 'One-time buyer'
              When NumberOfOrders between 2 and 4 Then 'Occassional Buyers'
              When NumberOfOrders > 4 Then 'Regular Customers'
              Else 'None'
              End as Segment_Analysis
		From (
             Select Customer_id,
             Count(order_id) as NumberOfOrders
             From orders
             Group By Customer_id
             ) as t;
			
Select * from Engagement_analysis;

Select NumberOfOrders,
Count(Customer_id) as CustomerCount
From Engagement_analysis
Group by NumberOfOrders
Order By NumberOfOrders asc; -- CustomerCount per number of orders
#--------------------------------------------------------------------#

-- 4.4) Segment analysis 
Create table Engagement_analysis1 as 
Select 
     Order_id,
     Customer_id,
           Case
              When NumberOfOrders <= 1 Then 'One-time buyer'
              When NumberOfOrders between 2 and 4 Then 'Occassional Buyers'
              When NumberOfOrders > 4 Then 'Regular Customers'
              Else 'None'
              End as Segment_Analysis
		From (
             Select Order_id, Customer_id,
             Sum(Order_id) as NumberOfOrders
             From orders
             Group By Order_id, Customer_id
             ) as t;

Select * from Engagement_analysis1;

Select count(*), Segment_analysis from Engagement_analysis1
Group by Segment_analysis;
#------------------------------------------------#

-- 4.5) Product Purchase Performance (High value products / low value)
Select * from order_details;
-- High Value Prodcts
Select
     Product_id,
     Avg(quantity) as AvgQuantity,
     sum(quantity*price_per_unit) as TotalRevenue
From order_details
Group By Product_id
Having AvgQuantity = 2
Order By TotalRevenue desc;

-- Low Value products
Select
     Product_id,
     Avg(quantity) as AvgQuantity,
     sum(quantity*price_per_unit) as TotalRevenue
From order_details
Group By Product_id
Having AvgQuantity < 2
Order By AvgQuantity, TotalRevenue asc;
#---------------------------------------------------------#

-- 4.6) Category wise- Customer reach
Select * from products;
Select * from order_details;
Select * from Orders; 

Select 
     p.category,
     Count(distinct o.customer_id) as unique_customers
From products p
Join Order_details od
On p.Product_id = od.product_id
Join orders o
On od.order_id = o.order_id
Group by p.category
Order By unique_customers desc;
#----------------------------------------------------------------#

-- 4.7) Sales Trend Analysis
Select * from orders;

WITH Sales_trend as (
Select 
     date_format(order_date_updated, '%Y-%m') as Month,
     sum(total_amount) as TotalSales
   From orders
   Group By Month
   )
   Select 
       Month,
       TotalSales,
       Round(((TotalSales - lag(TotalSales) over(order By Month)) /
       lag(TotalSales) over(order By Month)) * 100,2) as PercentChange
From Sales_Trend
Order By Month; 
#--------------------------------------------------------------------#

-- 4.8) Avg Order value Fluctuation
Select * from orders;

With Order_value as (
Select 
    date_format(order_date_updated, '%Y-%m') as Month,
    Round(avg(total_Amount), 2) as AvgOrderValue
From orders
Group by date_format(order_date_updated, '%Y-%m')
)
Select 
    Month,
    AvgOrderValue,
    Round(AvgOrderValue - lag(AvgOrderValue) over(order by Month),2) as ChangeInValue
From Order_value
Order By ChangeInValue Desc; -- Month wise change in value
#-------------------#
-- by sub query
Select
   Month,
   AvgOrdervalue,
   Round(AvgOrdervalue - lag(AvgOrdervalue) Over(order by Month), 2) as ChangeInValue
From (
       Select
       date_format(order_date_updated, '%Y-%m') as Month,
       round(avg(total_amount),2) as AvgOrderValue
       From Orders
       group by date_format(order_date_updated, '%Y-%m')
       ) as Monthly_sales
	Order By ChangeInValue desc;
#-------------------------------------------------------------------------------------#

-- 4.9) Inventory Planning Product wise / Refresh rate for Re-stocking
Select * from order_details;

Select
	product_id,
    Count(quantity*price_per_unit) as SalesFrequency
From order_details
Group by Product_id
Order by SalesFrequency desc
limit 5; -- which prod id has the highest salesfrequency? .i.e, Pro id 7
#------------------------------------------------------------------------------------------#

-- 4.10) Engagement Products 
Select * from products;
Select * from orders;
Select * from Order_Details;
Select * from customers;     

With ProductCustomerCount as (
Select
     p.product_id as Product_id,
     p.name as Name,
     Count(distinct o.customer_id) as UniqueCustomerCount
     From Products p
     Join Order_details od
     on p.product_id = od.product_id
     Join Orders o
     On od.order_id = o.order_id
     Group By Product_id, Name
),
Total_Customers As (
    Select count(distinct Customer_id) as TotalCustomerCount
    From customers
)
Select 
pcc.Product_id,
pcc.Name,
pcc.UniqueCustomerCount
From ProductCustomerCount pcc
join total_customers tc 
Where pcc.UniqueCustomerCount < (0.40 * TotalCustomerCount)
Order by pcc.UniqueCustomerCount asc; 
#---------------------------------------------------------------------#

-- 4.11) Customer Aquisition Trends 
Select * from orders;

With Customer_Aquisition As (
SELECT
     Customer_id,
     Min(order_date_updated) AS FirstPurchaseDate
     From orders 
     Group by 
     Customer_id
)
Select 
     date_format(FirstPurchaseDate, '%Y-%m') as FirstPurchaseMonth,
     Count(Customer_id) as TotalNewCustomers
From Customer_Aquisition
Group by date_format(FirstPurchaseDate, '%Y-%m')
Order by FirstPurchaseMonth;
#---------------------------------------------------------------#

-- 4.12) Peak Sales Period Identification
Select * from orders;

Select 
     date_format(order_date_updated, '%Y-%m') as Month,
     Sum(total_amount) as TotalSales
From orders
Group By month
Order by TotalSales desc
Limit 3; -- this will show the Peak sales months
#-----------------------------------------------------------------#
