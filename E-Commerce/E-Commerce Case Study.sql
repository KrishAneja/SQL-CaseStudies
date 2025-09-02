-- Creating Database
create database e_commerce_company;
use e_commerce_company;

-- Selecting Tables
select * from Customers;
select * from Order_details;
select * from orders;
select * from Products;

-- Deleting Unknown Columns
Alter Table customers
drop column MyUnknownColumn;

Create Table Product as 
select product_id, name, category, price from products;

drop table Products;

alter table Product
rename to Products;

-- Problem 1: Analyze the data
desc customers;
desc order_details;
desc orders;
desc products;

-- Problem 2: Market Segmentation Analysis
select location, count(*) as Num_of_Customers
from customers
group by 1
order by 2 desc limit 3;

-- Problem 3: Engagement Depth Analysis
with cte as (select customer_id, count(order_id) NumberofOrders, case when
count(order_id) = 1 then "One-Time Buyer"
when count(order_id) between 2 and 4 then "Occasional Shoppers"
else "Regular Customers" end EngagementSegmentation
from orders 
group by 1
order by 1)

select NumberOforders, count(customer_id) Customercount
from cte 
group by 1
order by 1;

-- Problem 4: Purchase High-Value Products
select product_id, round(avg(quantity)) AvgQuantity, sum(price_per_unit * quantity) TotalRevenue
from order_details
group by 1
having avg(quantity) = 2
order by 3 desc;

-- Problem 5: Category wise Customer Reach
select p.category, count(distinct o.customer_id) unique_customers from products p 
right join order_details od on p.product_id = od.product_id
left join orders o on od.order_id = o.order_id
group by 1
order by 2 desc;

-- Problem 6: Sales Trend Analysis
alter table orders
modify order_date date;

with cte as (
select date_format(order_date, "%Y-%m") as Month,
sum(total_amount) as totalsales
from orders
group by 1)

select *,
round((totalsales	- lag(totalsales) over(order by `Month`))*100/ lag(totalsales) over(order by `Month`),2)  as PercentChange
from cte;

-- Problem 7: Average Order Value Fluctuation
with cte as (
select date_format(order_date, "%Y-%m") as Month,
round(avg(total_amount),2) as AvgOrderValue
from orders
group by 1)

select *,
round((AvgOrderValue - lag(AvgOrderValue) over(order by `Month`)),2)  as ChangeinValue
from cte
order by 3 desc;

-- Problem 8: Inventory Refresh Rate
select product_id, count(quantity) SalesFrequency
from order_details
group by 1
order by 2 desc limit 5;

-- Problem 9: Low Engagement Products
select p.Product_id, p.name, count(distinct o.customer_id) UniqueCustomerCount
from products p join order_details od on p.product_id = od.product_id
join orders o on od.order_id = o.order_id
join customers c on c.customer_id = o.customer_id
group by 1,2
having count(distinct o.customer_id) < 0.4* (select count(distinct customer_id) from customers)
order by 3;

-- Problem 10: Customer Acquisition Trends
with first_orders as(
  select customer_id, MIN(order_date) first_purchase_date
  from orders
  group by 1
)
select date_format(first_purchase_date, '%Y-%m') FirstPurchaseMonth,
count(distinct customer_id) TotalNewCustomers
from first_orders
group by 1
order by 1;

-- Problem 11: Peak Sales Identification Period
select date_format(order_date, "%Y-%m") as Month,
sum(total_amount) Totalsales
from orders
group by 1
order by 2 desc limit 3;

