
-- sql capstone project --  
create database sql_project ;
use sql_project ;

select * from amazon;
select count(*) from amazon;
desc amazon;

-- renaming the column names -- 
alter table amazon rename column `Invoice ID` to invoice_id ;

set sql_safe_updates=0;

alter table amazon change Branch branch VARCHAR(5),
change City city VARCHAR(30),
change `Customer type` customer_type VARCHAR(30),
change Gender gender VARCHAR(10),
change `Product line` product_line VARCHAR(100),
change `Unit price` unit_price DECIMAL(10, 2),
change Quantity quantity INT ,
change `Tax 5%` VAT FLOAT(6, 4) ,change Total total DECIMAL(10, 2),
change `Payment` payment_method VARCHAR(30),
change `gross margin percentage` gross_margin_percentage FLOAT(11, 9),
change `gross income` gross_income DECIMAL(10, 2),
change Rating rating FLOAT(2, 1);

select * from amazon;

alter table amazon change `Unit price` unit_price DECIMAL(10, 2),
change Quantity quantity INT ,
change `Tax 5%` VAT FLOAT(6, 4) ,change Total total DECIMAL(10, 2),
change `Payment` payment_method VARCHAR(30);

alter table amazon change `gross margin percentage` gross_margin_percentage FLOAT(15, 9),
change `gross income` gross_income DECIMAL(10, 2),
change Rating rating FLOAT(3, 1);

alter table amazon change invoice_id invoice_id VARCHAR(30);

desc amazon;
select * from amazon;

update amazon set Date=date_format(Date,'%y-%m-%d');

alter table amazon rename column Date to date;

select (date) from amazon;

update amazon set Time=time_format(Time,'%H:%i:%s');

desc amazon ;

alter table amazon modify Time time;

alter table amazon rename column Time to time;

select * from amazon;

/*
Feature Engineering: This will help us generate some new columns from existing ones.
2.1   Add a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
2.2          Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.
2.3        Add a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
*/
alter table amazon add timeofday varchar(15);

select * from amazon; 

-- Morning, Afternoon and Evening

select case when hour(time) >= 8 and hour(time) < 12 then 'Morning' 
when hour(time) >= 12 and hour(time) < 18 then 'Afternoon' 
when hour(time) >= 18 and hour(time) < 24 then 'Evening' 
else 'Night' end as timeofday from amazon;


update amazon set timeofday =case when hour(time) >= 8 and hour(time) < 12 then 'Morning' 
when hour(time) >= 12 and hour(time) < 18 then 'Afternoon' 
when hour(time) >= 18 and hour(time) < 24 then 'Evening' 
else 'Night' end;
select * from amazon;
commit;

select *, date_format(date,'%b') from amazon;

alter table amazon add dayname varchar(10);
alter table amazon add monthname varchar(10);

update amazon set dayname= date_format(date,'%a') ;

update amazon set monthname = date_format(date,'%b');

commit;

/*
Product Analysis
Conduct analysis on the data to understand the different product lines, the products lines performing best and the product lines that need to be improved.
*/
select * from amazon;
select distinct product_line from amazon;
select product_line, sum(total) as total_sales, sum(gross_income) as total_income
from amazon group by product_line order by total_sales desc;
-- The Food and beverages product is giving highest sales and Home and lifestyle product is giving least sales 

select product_line, max(total) as max_sales, max(gross_income) as max_income
from amazon group by product_line order by max_sales desc ;

select product_line, min(total) as min_sales, min(gross_income) as max_income
from amazon group by product_line order by min_sales desc;

select branch,product_line, sum(total) as total_sales, sum(gross_income) as total_income
from amazon group by branch,product_line order by total_sales desc ;

-- product wise maximum rating --
select product_line,avg(rating) as avg_rating, max(rating) as max_rating,min(rating) as min_rating from amazon group by product_line order by avg_rating desc;
select product_line,count(*) as product_count from amazon group by product_line order by product_count desc; 
select product_line,sum(quantity) as total_product_qunty from amazon group by product_line order by total_product_qunty desc; 
select product_line,count(*) as rating_count from amazon 
where rating between 9 and 10 group by product_line order by rating_count desc;

/*
Sales Analysis
This analysis aims to answer the question of the sales trends of product. 
The result of this can help us measure the effectiveness of each sales strategy the business applies and what modifications are needed to gain more sales.
*/
select * from amazon;

select monthname,sum(total) as monthly_sales,sum(gross_income) as monthly_revenue from amazon group by monthname;
-- maximum sales occured in the Jan ,least sales occured in Feb

select branch,sum(total) as branch_total_sales,sum(gross_income) as total_revenue from amazon group by branch order by branch_total_sales desc;
-- The branch C is performing well compared to A and B branches
select timeofday,sum(total) as total_sales,sum(gross_income) from amazon group by timeofday;
-- in the afternoon sales are very high 

select timeofday, count(*) as sales_occurence from amazon group by timeofday;
-- in the afternoon the maximum sales happening time 

select gender,product_line,sum(total) as total_sales from amazon group by gender,product_line order by total_sales desc;
-- the maximum sales from female customers purchasing the product Food and Beverages.


/* Customer Analysis
This analysis aims to uncover the different customer segments, purchase trends and the profitability of each customer segment.
*/
select * from amazon;

select gender,sum(total) as total_sales,sum(gross_income) as total_revenue from amazon group by gender; 

-- female purchasing sales are higher Then male. 

select gender,timeofday,sum(total) as total_sales,sum(gross_income) as total_revenue from amazon group by gender,timeofday 
order by total_sales desc; 
-- The gender wise maxmimum sales occured in the afternoon.

select gender,product_line,sum(quantity) as product_quantity from amazon group by gender,product_line order by product_quantity desc;
-- Female customers most purchasing product is Fashion accessories.
-- male customers mostly purchasing Health and beauty.

-- gender wise average rating is 
select gender,product_line,avg(rating) avg_rating from amazon group by gender,product_line order by avg_rating desc;  
select customer_type,sum(total) as total_sales from amazon group by customer_type;

-- in the afternoon gender wise sales are high
-- Business Questions To Answer

-- 1.Q What is the count of distinct cities in the dataset?
select count(distinct city) as distinct_cities from amazon;
select distinct city from amazon;
-- There are 3 distinct cities named as Yangon ,Naypyitaw,Mandalay 

-- 2 Q.For each branch, what is the corresponding city?
select distinct branch,city from amazon ;

-- branch A belongs to Yangon and branch C  belongs to Naypyitaw , B Belongs to Mandalay 

-- 3 Q What is the count of distinct product lines in the dataset? 
select count(distinct product_line) as unique_product_count from amazon;

-- There are 6 unique products available

-- 4. Q Which payment method occurs most frequently?

select payment_method ,count(*) as count_payment_method from amazon group by payment_method order by count_payment_method desc;

-- the Ewallet and Cash payment methods occur mostly same

-- 5. Q Which product line has the highest sales?

select product_line, sum(total) as total_sales from amazon group by product_line order by total_sales desc limit 1;

-- most sales happened in the Food and bevarages 

-- 6.Q How much revenue is generated each month?

select monthname,sum(gross_income) as total_revenue from amazon group by monthname;
-- Jan the total revenue is 5537.95, in Feb the revenue is 4629.70 then Mar revenue 5212.40 
-- In Jan maximum revenue is generated 

-- 7. In which month did the cost of goods sold reach its peak?

select monthname ,sum(cogs) as total_goods_cost from amazon 
group by monthname order by total_goods_cost desc;
--  in the January month the cost of goods are at peaks 

-- 8.Which product line generated the highest revenue? 
select product_line,sum(gross_income) as total_revenue from amazon group by 
product_line order by total_revenue desc;

-- the Food and beverages product generates highest revenue

-- 9.In which city was the highest revenue recorded? 
select * from amazon ;
select city,sum(gross_income) as total_revenue from amazon group by 
city order by total_revenue desc ;
-- in the city named Naypyitaw as highest revenue 

-- 10. Which product line incurred the highest Value Added Tax? 
select product_line, sum(VAT) as total_tax from amazon group by 
product_line order by total_tax desc;

-- The Food and beverages is paying the highest tax 

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

select product_line,total,date, case when total > (select avg(total) as avg_sales  from amazon a where a.product_line=b.product_line) 
then 'Good' else 'Bad' end as sales_performance from amazon b;

-- 12.Identify the branch that exceeded the average number of products sold.
select * from amazon;

select branch, avg(quantity) from amazon group by branch having avg(quantity) > (select avg(quantity) from amazon) ;

-- The branch C exceed's the average no of products sold.

select avg(quantity) from amazon;

-- 13.Which product line is most frequently associated with each gender? 

select product_line,gender ,count(*) as gender_frquency from amazon group by product_line,gender 
order by gender_frquency desc ;
-- Fashion accessories product is most frequent with female,
-- Health and beauty product is mostly with male category

-- 14. Calculate the average rating for each product line.
select product_line,avg(rating) as avg_rating from amazon group by product_line
order by avg_rating desc;

 -- 15. Count the sales occurrences for each time of day on every weekday.
select dayname,timeofday,count(*) as sales_count from amazon group by dayname,timeofday 
order by sales_count desc;

-- the sales in the afternoon are maximum on every day 

-- 16.Identify the customer type contributing the highest revenue.

select Customer_type,sum(gross_income) as total_revenue from amazon group by 
 Customer_type order by total_revenue desc ;
-- the member customer is giving the highest revenue 

-- 17. Determine the city with the highest VAT percentage. 

select city, sum(VAT/total) as vat_percent from amazon group by city order by vat_percent desc ; 
-- Yangon city as highest vat percentage

select city,count(*) from amazon group by city;

-- 18. Identify the customer type with the highest VAT payments.
select Customer_type,sum(VAT) ,sum(total) as vat_percent from amazon group by Customer_type 
order by vat_percent desc ; 
-- the Member type of customers are having highest VAT payments

-- 19. What is the count of distinct customer types in the dataset?  
select count(distinct customer_type) as customer_count from amazon;

-- there are 2 distinct customers exist

-- 20. What is the count of distinct payment methods in the dataset?
select count(distinct  payment_method) as payment_method_count from amazon;

-- 3 payment types available 
select distinct payment_method from amazon;
-- Ewallet ,cash , credit card,
-- Q. 21. Which customer type occurs most frequently? 
select customer_type ,count(*) as customer_count from amazon group by customer_type
order by customer_count desc limit 1;
-- Member type of customer occurs frequently

-- 22 Identify the customer type with the highest purchase frequency 
select customer_type  ,count(*) as purchase_frequency from amazon group by customer_type
order by purchase_frequency desc limit 1;

-- Member customer type as highest purchase frequency. 
-- 23. Determine the predominant gender among customers. 

select customer_type, gender , count(*) as gender_count from amazon group by customer_type,gender
order by gender_count desc;

-- the predominant gender among the customers is Female.

-- 24. Examine the distribution of genders within each branch. 

select branch,gender,count(*) as gender_count from amazon group by branch,gender
order by branch ;

-- 25.Identify the time of day when customers provide the most ratings. 

select timeofday,count(rating) as rating_count from amazon group by timeofday 
order by rating_count desc limit 1;

-- in the afternoon customer provide maximum ratings

-- 26.Determine the time of day with the highest customer ratings for each branch.
select branch,timeofday,count(rating) as rating_count from amazon group by branch, timeofday 
order by rating_count desc;
-- in the afternoon for each branch the customers provide highest ratings 

-- 27.Identify the day of the week with the highest average ratings. 

select dayname , avg(rating) as avg_rating from amazon 
group by dayname order by avg_rating desc limit 1;
-- in the Monday the average rating is highest

-- 28. Determine the day of the week with the highest average ratings for each branch.
select branch,dayname , avg(rating) as avg_rating from amazon group by branch, dayname 
order by avg_rating desc; 

-- for branches A and C highest ratings in the Friday , for B branch Monday 









 






select * from amazon;








select * from amazon;





