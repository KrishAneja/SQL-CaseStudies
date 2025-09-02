-- Creating Database and Loading Datasets
create database retail_analytics;
use retail_analytics;

-- Selecting Tables
select * from customers;
select * from products;
select * from sales;

-- Renaming Columns
alter table customers 
rename column ï»¿CustomerID to CustomerID;

alter table sales 
rename column ï»¿TransactionID to TransactionID;

alter table products
rename column ï»¿ProductID to ProductID;

-- Problem 1: Remove Duplicates
select transactionid, count(*) num_rows
from sales
group by 1
having count(*) > 1;

create table sales_unique(
select distinct * from sales
);

drop table sales;

alter table sales_unique rename to sales;

-- Problem 2: Fix Incorrect Prices
select s.price, p.price from sales s 
join products p on s.productid = p.productid
where s.price != p.price;

set sql_safe_updates = 0;

update sales
set price = 93.12
where price = 9312;
 
/* Alternate Way
update sales s
set price = (select p.price from products p where p.productid = s.productid)
where s.productid in (select productid from products p where p.price != s.price)
*/

-- Problem 3: Fixing Null Values
select count(*) from customers
where location = "";

update customers
set location = "Unknown"
where location = "";

select * from customers;

-- Problem 4: Cleaning Date
create table transactions (select * from sales);

select * from transactions;
update transactions
set Transactiondate = str_to_date(Transactiondate, "%d/%m/%Y");

alter table transactions
modify Transactiondate date;

drop table sales;

alter table transactions rename to sales;
select * from sales;

-- Problem 5: Total Sales Summary
select productid, sum(quantitypurchased) as Totalunitssold, sum(price*quantitypurchased) as Totalsales
from sales
group by 1
order by 3 desc;

-- Problem 6: Customer Purchase Frequency
select customerid, count(*) as NumberofTransactions 
from sales
group by 1
order by 2 desc;

-- Problem 7: Product Categories Performance
select p.category, sum(s.quantitypurchased) Totalunitssold, sum(s.price * s.quantitypurchased) TotalSales
from sales s join products p on 
s.productid = p.productid
group by 1
order by 3 desc;

-- Problem 8: High Sales Products
select productid,  sum(price * quantitypurchased) TotalRevenue
from sales
group by 1
order by 2 desc limit 10;

-- Problem 9: Low Sales Products
select productid, sum(quantitypurchased) totalunitssold
from sales
group by 1
having sum(quantitypurchased) > 0
order by 2 limit 10;

-- Problem 10: Sales Trend
select cast(transactiondate as date) as DateTrans, count(distinct transactionid) as Transaction_count, sum(quantitypurchased) TotalUnitsSold,
sum(price * quantitypurchased) Totalsales
from sales
group by 1
order by 1 desc;

-- Problem 11: Growth Rate of Sales 
with cte as(
select month(transactiondate) month, round(sum(price * quantitypurchased),2) total_sales
from sales
group by 1)
,
cte2 as(
    select month, total_sales,
    round(lag(total_sales) over(order by month),2) previous_month_sales
    from cte
)
select *, 
concat(round((total_sales-previous_month_sales)*100/previous_month_sales,2), " %") mom_growth_percentage
from cte2
group by month
order by month;

-- Problem 12: High Purchase Frequency
select customerid, count(transactionid) as NumberOfTransactions, round(sum(price * quantitypurchased),2) TotalSpent
from sales
group by 1
having count(transactionid) > 10 and  sum(price * quantitypurchased) > 1000
order by 3 desc;

-- Problem 13:  Occasional Customers
select customerid, count(transactionid) as NumberOfTransactions, round(sum(price * quantitypurchased),2) TotalSpent
from sales
group by 1
having count(transactionid) <= 2
order by 2,3 desc ;

-- Problem 14: Repeat Purchases
select customerid, productid,
count(*) TimesPurchased
from sales
group by 1,2
having count(*) > 1
order by 3 desc;

-- Problem 15: Loyality Indicators
select customerid,
min(transactiondate) FirstPurchase, max(transactiondate) LastPurchase,
datediff(max(transactiondate),min(transactiondate)) DaysBetweenPurchases
from sales
group by 1
having datediff(max(transactiondate),min(transactiondate)) > 0
order by 4 desc;

-- Problem 16: Customer Segmentation
create table customer_segment AS 
with cust_base as (
select c.CustomerID, 
	sum(s.QuantityPurchased) total_qty
from sales s
left join customers c 
	on s.CustomerID = c.CustomerID
      group by 1
      ) 
select 
	CustomerID, 
    case when total_qty between 1 and 10 then 'Low' 
    when total_qty between 11 and 30 then 'Med'
    when total_qty > 30 then 'High' 
    else 'None' end as CustomerSegment 
from cust_base;

select CustomerSegment, count(*)
from customer_segment
group by 1;


