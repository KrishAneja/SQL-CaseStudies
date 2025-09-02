-- Creating Database
create database airbnb;

-- Viewing Data
desc countries;
desc sessions_data;
desc users;

select * from countries;
select * from sessions_data;
select * from users;

-- Analyzing
select count(*) from sessions_data
where action_type = "partner_callback";

-- Viewing Demographics
select distinct action_type from sessions_data;

select count(*) from users
where gender = "FEMALE";

-- Most Common Country
select country_destination, count(*) from users
group by 1
order by 2 desc;

-- Most Common Signup
select signup_method, count(*) from users where gender = "FEMALE"
group by 1
order by 2 desc;

-- Most Active Users
select user_id
from sessions_data
group by 1
having sum(secs_elapsed) > 10000
order by count(user_id) desc limit 5;

-- Gender wise Signup Demographics
select gender, signup_method, count(*) from users 
where date_first_booking is not null and country_destination != "NDF"
group by 1,2;

-- Country wise Average age
select country_destination, avg(age) average_age
from users
where country_destination != "NDF"
group by 1
order by 2 asc;

-- People older than 100
select count(*) from users
where age > 100;

-- US citizen having session count less than 5
select s.user_id as id, count(s.user_id) session_count from 
sessions_data s join users u on s.user_id = u.id
where u.country_destination = "US"
group by 1
having count(s.user_id) < 5
order by 2 desc;

-- Counting Organic Clicks
select count(*) Organic_Clicks from sessions_data s join users u on s.user_id = u.id
where u.affiliate_provider = "direct" and s.action_type = "click";

-- Action Count by device type and action
select s.action, s.device_type, count(*) action_count from sessions_data s join
users u on s.user_id = u.id 
where u.country_destination != "NDF"
group by 1,2
order by 3 desc limit 5;

-- Average time spent by device type and action type
select s.action_type, s.device_type, avg(s.secs_elapsed) average_time_spent from sessions_data s join
users u on s.user_id = u.id 
where u.country_destination != "NDF"
group by 1,2
order by 3 desc;

-- Conversion Rate by First Affiliate Tracked
select first_affiliate_tracked as affiliate_channel, count(*) total_users,
sum(case when country_destination != "NDF" THEN 1 else 0 END) as bookings,
Round(sum(case when country_destination != "NDF" THEN 1 else 0 END)*100/count(*),4) as conversion_rate
from users
group by 1
order by 4 desc;

-- Conversion Rate by Affiliate Provider
select affiliate_provider, signup_method, count(*) total_users,
sum(case when country_destination != "NDF" THEN 1 else 0 END) as bookings,
Round(sum(case when country_destination != "NDF" THEN 1 else 0 END)*100/count(*),4) as conversion_rate
from users
group by 1,2
order by 5 desc;

-- Conversion Rate by Affiliate Channel
select affiliate_channel, count(*) total_users,
sum(case when country_destination != "NDF" THEN 1 else 0 END) as bookings,
Round(sum(case when country_destination != "NDF" THEN 1 else 0 END)*100/count(*),4) as conversion_rate
from users
group by 1
order by 4 desc;

-- Action Pairs Frequent Combination
select
    s1.action AS first_action,
    s2.action AS second_action,
    Count(*) AS action_pair_count,
    Sum(s1.secs_elapsed + s2.secs_elapsed) AS total_time_spent
from sessions_data s1
join sessions_data s2
    on s1.user_id = s2.user_id
   and s1.action <> s2.action          
join users u
    on s1.user_id = u.id
where s1.device_type = 'Windows Desktop'
  and s2.device_type = 'Windows Desktop'
  and u.country_destination != 'NDF'
group by s1.action, s2.action
order by total_time_spent DESC
limit 10;








