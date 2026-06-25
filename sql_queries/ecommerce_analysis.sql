use brazilian;

select * from orders;

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from orders;

CREATE TABLE products (
product_id VARCHAR(100),
product_category_name VARCHAR(255),
product_name_lenght INT,
product_description_lenght INT,
product_photos_qty INT,
product_weight_g INT,
product_length_cm DECIMAL(10,2),
product_height_cm DECIMAL(10,2),
product_width_cm DECIMAL(10,2)
);

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

drop table products;

CREATE TABLE products(
product_id VARCHAR(100),
product_category_name VARCHAR(255),
product_name_lenght VARCHAR(20),
product_description_lenght VARCHAR(20),
product_photos_qty VARCHAR(20),
product_weight_g VARCHAR(20),
product_length_cm VARCHAR(20),
product_height_cm VARCHAR(20),
product_width_cm VARCHAR(20)
);

select * from products;

create table sellers(
seller_id varchar(100),
seller_zip_code_prefix varchar(100),
seller_city	varchar(100),
seller_state varchar(100)
);

LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from sellers;

create table category_name(
product_category_name varchar(100),
product_category_name_english varchar(100)
);


LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/product_category_name_translation.csv'
INTO TABLE category_name
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table customers(
customer_id	varchar(100),
customer_unique_id	varchar(100),
customer_zip_code_prefix	varchar(100),
customer_city varchar(100)	,
customer_state varchar(100)
);

load data infile
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_customers_dataset.csv '
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table geolocation(
geolocation_zip_code_prefix varchar(100)	,
geolocation_lat varchar(100),
geolocation_lng varchar(100)	,
geolocation_city	varchar(100),
geolocation_state varchar(100)
);

load data infile
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_geolocation_dataset.csv '
INTO TABLE geolocation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


create table order_items(
order_id varchar(100)	,
order_item_id varchar(100)	,
product_id	varchar(100),
seller_id	varchar(100),
shipping_limit_date	varchar(100),
price	varchar(100),
freight_value varchar(100)
);
load data infile
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_order_items_dataset.csv '
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table order_payments(
order_id	varchar(100),
payment_sequential	varchar(100),
payment_type	varchar(100),
payment_installments	varchar(100),
payment_value varchar(100)
);
load data infile
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_order_payments_dataset.csv '
INTO TABLE order_payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table order_reviews(
review_id varchar(100), 
order_id	varchar(100),
review_score	varchar(100),
review_comment_title	varchar(5000),
review_comment_message	varchar(5000),
review_creation_date	varchar(1000),
review_answer_timestamp varchar(1000)
);

drop table order_Reviews;

load data infile
'C:/ProgramData/MySQL/MySQL Server 9.7/Uploads/olist_order_reviews_dataset.csv '
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from order_Reviews;

-- --Business Questions & SQL Solutions--
-- 1. Top 10 Cities by Orders

-- Method 1 :with cte & joins
with top10_city as(
select *,rank() over(order by no_of_orders desc) as rk from(
select c.customer_city,count(*) as No_of_orders from orders o
left join customers c on o.customer_id = c.customer_id
group by c.customer_city order by no_of_orders desc)t)
select Customer_City,No_of_orders from top10_city where rk<11;

-- Method 2 :joins & simple
SELECT customer_city, COUNT(*) total_orders FROM customers c JOIN orders o ON c.customer_id=o.customer_id GROUP BY 1 ORDER BY 2 DESC LIMIT 10;

-- 2. Monthly Sales Trend

select DATE_FORMAT( order_purchase_timestamp, '%Y-%m' ) month,round(sum(oi.price),0) from orders o
inner join order_items oi on o.order_id = oi.order_id
group by 1
order by 1;

-- 3. Monthly Order Growth %

select *,concat(round((no_of_orders-lag(no_of_orders,1,0) over(order by d))/lag(no_of_orders,1,0) over(order by d),1),"%") as monthly_order_growth from(
select date_format(order_purchase_timestamp,"%Y-%m") as d,count(order_id) as no_of_orders from orders
group by 1 order by 1)t;

-- 4. Average Delivery Days

select round(avg(datediff(order_delivered_customer_Date,order_purchase_timestamp)),2) as avg_delivery_days from orders ;

-- 5. Delayed Deliveries

select * from orders where order_delivered_customer_Date>order_estimated_Delivery_date;

-- 6. Delay %

SELECT concat(round( sum( order_delivered_customer_date> order_estimated_delivery_date )*100/count(*),2),'%') as Delay FROM orders;


-- 7. Top Product Categories with most delivery

select c.product_Category_name_english,count(c.product_Category_name_english) from orders o1 
left join order_items o on o1.order_id = o.order_id
inner join products p on o.product_id = p.product_id
inner join category_name c on p.product_category_name = c.product_category_name
group by 1
order by 2 desc
limit 10;

-- 8. Top Revenue Cities

select c.customer_city,round(sum(oi.price),0) as top_revenue_cities from orders o 
left join customers c on o.customer_id = c.customer_id
inner join order_items oi on o.order_id = oi.order_id
group by 1 order by 2 desc limit 10;

-- 9. Payment Mix

select Payment_type,concat(round(total*100/sum(total) over(),1),"%") payment_share from (
select payment_type,sum(payment_value) total from order_payments group by 1)t;

-- 10. Cancellation %

select concat(round((select count(*) from orders where order_status='canceled')*100/count(*),2),"%") as cancellation_Rate from orders ;

-- 11. Average Order Value

SELECT ROUND(AVG(order_total),2)FROM(SELECT order_id,SUM(price+freight_value)order_total 
FROM order_items GROUP BY order_id)x;

-- 12. Top Sellers based on amount of price of order sold

select seller_id,round(sum(price),0) as total 
from order_items group by seller_id order by 2 desc limit 10;

-- 13. Repeat Customers

select count(*) as repeated_customers_count from(SELECT customer_id ,count(*) 
FROM orders GROUP BY 1 HAVING COUNT(*)>1 )t;

-- 14. Average Approval Delay

select avg(timestampdiff(hour,order_purchase_timestamp,order_approved_At)) 
from orders where order_approved_at is not null;

-- 15. Monthly Delivery Performance

select date_format(order_purchase_timestamp,"%Y-%m") as month,
	round(avg(datediff(order_delivered_customer_date,order_purchase_timestamp)),0) as delivery_performance 
from orders group by 1 order by 1;

