select date_format(payment_date, '%d-%m-%y') as date_paid,
date_format(payment_date, '%m-%y') as month_year,
order_id, payment_method, round(amount_paid,2)
from payments;

select sum(amount_paid)
from payments;

create view kpi_total_paid as
select date_format(payment_date, '%m-%y') as month_year,
round(sum(amount_paid),2) as monthly_sales,
lag(round(sum(amount_paid),2),1) over (order by date_format(payment_date, '%m-%y')) as previous_month_sales,
round(round(sum(amount_paid),2) - lag(round(sum(amount_paid),2),1) over (order by date_format(payment_date, '%m-%y')),2) as MoM_Growth
from payments
where date_format(payment_date, '%m-%y') is not null
group by date_format(payment_date, '%m-%y');

create view order_and_payment as
select p.order_id, payment_method, amount_paid,
date_format(payment_date, '%m-%y') as date, order_status
from payments p 
join orders o
	on p.order_id = o.order_id;

select *
from order_and_payment;

create view order_item_and_product as
select oi.order_id, oi.product_id, quantity, total_price, product_name, category
from order_items oi
join products p
	on oi.product_id = p.product_id
order by order_id;

create view kpi_total_product_sold as
with cte1 as
(
select *
from order_item_and_product
),
cte2 as
(
select *
from order_and_payment
)
select distinct date, sum(quantity) as product_sold_monthly,
lag(sum(quantity),1) over (order by date) as previous_month_product_sold,
sum(quantity) - lag(sum(quantity),1) over (order by date) as MoM_Growth_product_sold
from cte1
join cte2
	on cte1.order_id = cte2.order_id
group by date
having date is not null
order by date;


create view category as
with cte1 as
(
select *
from order_item_and_product
),
cte2 as
(
select *
from order_and_payment
)
select category, quantity, total_price, date
from cte1
join cte2
	on cte1.order_id = cte2.order_id
order by cte1.order_id;

select *
from order_item_and_product;

create view payment_method as
select order_id, payment_method, amount_paid,
date_format(payment_date, '%m-%y') as date
from payments;

select *
from payments;


create view data_order as
select *,
date_format(order_date, '%m-%y') as date
from orders
having date is not null
order by order_id;