/* checking postgresql version */
select version();

/*
	task3: implementing the star schema in PostgreSQL 
			and uploading the given data into the database.
*/

/* creating dimension tables */

/* creating trans_dim table */
create table trans_dim
(payment_key varchar(20) not null primary key,
 trans_type varchar(20),
 bank_name varchar(50));

/* importing trans_dim */
select * from trans_dim;

/* creating customer_dim table */
create table customer_dim
(coustomer_key varchar(20) not null primary key,
 name varchar(50),
 contact_no varchar(20),
 nid varchar(20),
 address varchar(80),
 street varchar(80),
 upazila varchar(20),
 district varchar(20),
 division varchar(20));

/* importing customer_dim */
select * from customer_dim;

/* creating time_dim table */
create table time_dim
(time_key varchar(20) not null primary key,
 date varchar(50),
 hour int,
 day int,
 week varchar(10),
 month integer,
 quarter varchar(10),
 year int);

/* importing time_dim */
update time_dim
set date = to_timestamp(date, 'DD-MM-YYYY HH24:MI');

alter table time_dim
alter column date type timestamp without time zone
using date::timestamp without time zone;

select * from time_dim;

/* creating item_dim table */
create table item_dim
(item_key varchar(20) not null primary key,
 item_name varchar(50),
 description varchar(50),
 unit_price real,
 man_country varchar(20),
 supplier varchar(50),
 stock_quantity int,
 unit varchar(20));

/* importing item_dim */
select * from item_dim;

/* creating store_dim table */
create table store_dim
(store_key varchar(20) not null primary key,
 location varchar(80),
 city varchar(20),
 upazila varchar(20),
 district varchar(20));

/* importing store_dim */
select * from store_dim;

/* creating fact table */
create table fact_table
(payment_key varchar(20) references trans_dim(payment_key),
 coustomer_key varchar(20) references customer_dim(coustomer_key),
 time_key varchar(20) references time_dim(time_key),
 item_key varchar(20) references item_dim(item_key),
 store_key varchar(20) references store_dim(store_key),
 quantity int,
 unit varchar(20),
 unit_price real,
 total_price real);

/* importing fact_table */
select * from fact_table;

/* 
	task4: creating 3 different cross tabulations for 3 different dimensions using total price/quantity
			and writing SQL to find the cross-tabs.
*/

/* creating cross-tab for transaction dimension */
create table sales_transaction
as
select trans_type, bank_name, total_price
from fact_table, trans_dim
where fact_table.payment_key = trans_dim.payment_key;

select * from sales_transaction;

/* listing corresponding SQL for finding corss-tab */
select sum(total_price) as total_price
from sales_transaction;

select trans_type, sum(total_price) as total_price
from sales_transaction
group by trans_type;

select bank_name, sum(total_price) as total_price
from sales_transaction
group by bank_name;

select trans_type, bank_name, sum(total_price) as total_price
from sales_transaction
group by trans_type, bank_name;

/* creating cross-tab for customer dimension */
create table sales_customer
as
select name, division, total_price
from fact_table, customer_dim
where fact_table.coustomer_key = customer_dim.coustomer_key;

select * from sales_customer;

/* listing corresponding SQL for finding corss-tab */
select sum(total_price) as total_price
from sales_customer;

select name, sum(total_price) as total_price
from sales_customer
group by name;

select division, sum(total_price) as total_price
from sales_customer
group by division;

select name, division, sum(total_price) as total_price
from sales_customer
group by name, division;

/* creating cross-tab for item dimension */
create table sales_item
as
select item_name, man_country, quantity
from fact_table, item_dim
where fact_table.item_key = item_dim.item_key;

select * from sales_item;

/* listing corresponding SQL for finding corss-tab */
select sum(quantity) as total_quantity
from sales_item;

select item_name, sum(quantity) as total_quantity
from sales_item
group by item_name;

select man_country, sum(quantity) as total_quantity
from sales_item
group by man_country;

select item_name, man_country, sum(quantity) as total_quantity
from sales_item
group by item_name, man_country;

/*
	task5: finding at least 5 important DSS (Decision Support System) reports (one for each dimension)
			(using SQL cube operation) as bar chart.
*/

/* generating DSS report on transaction typewise buyers count */
copy (select coalesce(trans_type, 'all trans_type') trans_type, count(*) as total_buyer
from fact_table, trans_dim
where fact_table.payment_key = trans_dim.payment_key
group by cube(trans_type)
order by total_buyer desc)
to 'D:\Academic 4-1\CSE453 (High Performance Database System)\dw-assignment\dw-assignment-report\csv\dss_trans_type_buyer.csv'
delimiter ',' csv header;

/* generating DSS report on divisionwise buyers count */
copy (select coalesce(division, 'all division') division, count(*) as total_buyer
from fact_table, customer_dim
where fact_table.coustomer_key = customer_dim.coustomer_key
group by cube(division)
order by total_buyer desc)
to 'D:\Academic 4-1\CSE453 (High Performance Database System)\dw-assignment\dw-assignment-report\csv\dss_division_buyer.csv'
delimiter ',' csv header;

/* generating DSS report on quarterwise sales count */
copy (select coalesce(quarter, 'all quarter') quarter, sum(quantity) as total_quantity
from fact_table, time_dim
where fact_table.time_key = time_dim.time_key
group by cube(quarter)
order by total_quantity desc)
to 'D:\Academic 4-1\CSE453 (High Performance Database System)\dw-assignment\dw-assignment-report\csv\dss_quarter_count.csv'
delimiter ',' csv header;

/* generating DSS report on manufacturer countrywise sales count */
copy (select coalesce(man_country, 'all man_country') man_country, sum(quantity) as total_quantity
from fact_table, item_dim
where fact_table.item_key = item_dim.item_key
group by cube(man_country)
order by total_quantity desc)
to 'D:\Academic 4-1\CSE453 (High Performance Database System)\dw-assignment\dw-assignment-report\csv\dss_man_country_count.csv'
delimiter ',' csv header;

/* generating DSS report on districtwise sales earning */
copy (select coalesce(district, 'all district') district, sum(total_price) as total_price
from fact_table, store_dim
where fact_table.store_key = store_dim.store_key
group by cube(district)
order by total_price desc)
to 'D:\Academic 4-1\CSE453 (High Performance Database System)\dw-assignment\dw-assignment-report\csv\dss_district_earning.csv'
delimiter ',' csv header;
