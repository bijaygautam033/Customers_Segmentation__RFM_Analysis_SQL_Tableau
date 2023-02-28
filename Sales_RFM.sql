
-- Inspecting the data

select distinct status from sales; ------- Finding unique status for the orders
select distinct year_id from sales; ------- years of sales
select distinct productline from sales; 
select distinct country from sales;
select distinct dealsize from sales;

/* Total quantities ordered by productlines*/

select productline,sum(quantityordered)as total_quantities
from sales
group by productline
order by total_quantities desc;
/* Classic cars has the maximum quantities of the orders
(33992) followed by vintage cars(21069)
and least quantities ordered are trains(2712).*/



-- Sales by productline--

select productline,round(sum(sales)) as total_sales
from sales
group by productline 
order by total_sales desc;

/* Classic cars has the highest sales of $3919616 folowed
by vintage cars ($1903151).
Trains have the lowest sales of $226243*/

-- Sales by year---

select year_id,round(sum(sales)) as total_sales
from sales
group by year_id
order by total_sales desc;

/* Year 2004 has the highest sales of $4724163 and 
the least sales is on 2005 of $1791487 since sales were operated 
on;y for first 5 month in 2005 */

select distinct month_id from sales
where year_id=2005;

-- Top 5 countries with the highest sales

select country,round(sum(sales)) as total_sales 
from sales
group by country
order by total_sales desc
limit 5;

-- USA has the highest sales---

-- Top 5 Sales by customer name--

select customername,round(sum(sales)) as total_sales
from sales
group by customername
order by total_sales desc
limit 5;

/* Euro shopping channel has the highest sales of
$912294 */

-- Sales by dealsize


select dealsize,round(sum(sales)) as total_sales
from sales
group by dealsize
order by total_sales desc;

/* Medium dealsize of the products 
have the highest sales of $6087432
and the least is large dealsize of $1302119 */

-- sales by month and year(2003)--

select month_id,round(sum(sales)) as total_sales
from sales 
where year_id=2003
group by month_id
order by total_sales desc;

/* November seems to be the highest earning
revenue in 2003 of $1029838.*/

select month_id,productline,round(sum(sales)) as total_sales
from sales
where year_id=2003 and month_id=11
group by month_id,productline
order by total_sales desc;

/* Classic cars have the highest sales for November 
in 2003*/

select month_id,productline,round(sum(sales)) as total_sales
from sales
where year_id=2004 and month_id=11
group by month_id,productline
order by total_sales desc;

/* For 2004 also November seems to be the highest revenue
earning month for the product of classic cars*/

-- who is our best customer? Answerd with RFM Analysis

 
with cte  as
(select customername,round(sum(sales)) as monetary,
count(ordernumber) as frequency,
max(orderdate) as last_order_date,
(select max(orderdate) from sales)as max_order_date
from sales
group by customername),

rfm as
(select cte.*,datediff(max_order_date,last_order_date) as recency
from cte),

/* Abpve query retrieves the recency of the customers
meaning how long did the customer order the products.*/

rfm_calc as
(select rfm.*,
ntile(4) over(order by recency desc) as rfm_recency,
ntile(4) over(order by frequency ) as rfm_frequency,
ntile(4) over(order by monetary ) as rfm_monetary
from rfm),

rfm1 as
(select rfm_calc.*,rfm_recency+rfm_frequency+rfm_monetary as rfm_cell,
concat(convert(rfm_recency,char),convert(rfm_frequency,char),convert(rfm_monetary, char)) as rfm_cell_string
 from rfm_calc )
 
 /*Retrieving the rfm segments for each customers
 and dividing the customers to eaxh segments based on recency, frequency and monetary parameters*/
 
select customername,rfm_cell_string,
case
 when rfm_cell_string in (444,344,434,433,443) then 'loyal_customers'
 when rfm_cell_string in (111,112,121,122,123,132,211,212,114,141,221) then 'lost_customers' 
 when rfm_cell_string in (133,134,143,234,244,334,343,344,144,412,333,423) then 'customers_at_risk' 
 when rfm_cell_string in (311,411,331) then 'new_customers' 
 when rfm_cell_string in (222,223,233,322,421,422,232,332,432) then 'potential_customers' 
 end as rfm_segment
from rfm1;


-- What products are often most sold together?--
select * from sales;
select distinct ordernumber,
(select group_concat( productcode)as productcode
from sales p
where ordernumber in
(select ordernumber  from
(select ordernumber,count(*) items_ordered
from sales
where status='shipped'
group by ordernumber)a
where items_ordered=2 and p.ordernumber=s.ordernumber)) as productcodes
from sales s
order by productcodes desc;

/* productcodes S18_1342 and S18_1367
are sold together for different order numbers

productcodes S18_2325 and S24_1937 are sold together*/

select productline from sales
where productcode in('S18_1342','S18_1367');

select productline from sales
where productcode in('S18_2325','S24_1937');





 
 
 
 
 
 






