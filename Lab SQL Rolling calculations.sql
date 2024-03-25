use sakila;

-- 1. Get number of monthly active customers.
create or replace view sakila.user_activity as
select customer_id, convert(rental_date, date) as Activity_date,
	date_format(convert(rental_date,date), '%m') as Activity_Month,
	date_format(convert(rental_date,date), '%Y') as Activity_year
from sakila.rental;

select * from sakila.user_activity;

-- get the total number of active user per month and year
create or replace view sakila.monthly_active_users as
select Activity_year, Activity_Month, count(distinct customer_id) as Active_users
from sakila.user_activity
group by Activity_year, Activity_Month;

select * from monthly_active_users;


-- 2. Active users in the previous month.

select 
   Activity_year, 
   Activity_month,
   Active_users, 
   lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month  -- partition by Activity_year
from monthly_active_users;


-- 3. Percentage change in the number of active customers.

-- getting the difference
create or replace view sakila.diff_monthly_active_users as
with cte_view as 
(
	select 
	Activity_year, 
	Activity_month,
	Active_users, 
	lag(Active_users) over (order by Activity_year, Activity_Month) as Last_month
	from monthly_active_users
)
select 
   Activity_year, 
   Activity_month, 
   Active_users, 
   Last_month, 
   (Active_users - Last_month) as Difference 
from cte_view;

select * from diff_monthly_active_users;

select Active_users, Last_month, (Active_users/Last_month)*100 as Percent 
from diff_monthly_active_users;

-- 4. Retained customers every month

select Activity_year, Difference
from diff_monthly_active_users;