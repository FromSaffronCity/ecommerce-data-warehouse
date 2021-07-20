/* checking postgresql version */
select version();

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
 month int,
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
