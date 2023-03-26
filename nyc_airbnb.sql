select * from AB_NYC_2019;
ALTER TABLE AB_NYC_2019
ALTER COLUMN price FLOAT;

--1. What is the most common room type for Airbnb listing

select room_type, count(id) most_common_room_type
from AB_NYC_2019
group by room_type
order by 2 desc;

--2. What is the average price per night for each borough in NYC?

select neighbourhood_group, neighbourhood, format(round(avg(price),2),'N2') avg_price
from AB_NYC_2019
group by neighbourhood_group, neighbourhood
order by 1,2

--3 Which borough has the most expensive Airbnb listings on average?

select neighbourhood_group, format(round(avg(price),2),'N2') avg_price
from AB_NYC_2019
group by neighbourhood_group
order by avg(price) desc

--4. What is the distribution of the number of reviews for Airbnb listings in NYC?

select sum(case when number_of_reviews = 0 then 1 else 0 end) No_reviews,
sum(case when number_of_reviews > 0 and number_of_reviews < 100 then 1 else 0 end) less_than_100_reviews,
sum(case when number_of_reviews >= 100  and number_of_reviews < 500 then 1 else 0 end) [100_to_500_reviews],
sum(case when number_of_reviews >= 500 then 1 else 0 end) more_than_500_reviews			 
from AB_NYC_2019

--5. Which neighborhood in Brooklyn has the highest number of Airbnb listings?

select neighbourhood, count(id) number_of_listings
from AB_NYC_2019
where neighbourhood_group = 'Brooklyn'
group by neighbourhood
order by 2 desc

--6. What is the average number of reviews for Airbnb listings in Manhattan?

select round(avg(number_of_reviews),0) avg_number_of_reviews
from AB_NYC_2019
where neighbourhood_group = 'Manhattan';

--7 . What is the minimum number of nights that Airbnb listings in Queens require for a booking?

select min(minimum_nights) minimum_nights_for_booking
from AB_NYC_2019
where neighbourhood_group = 'Queens'

--8. Which host has the most listings in NYC?

select top 20 host_id, host_name, sum(calculated_host_listings_count) total_listings
from AB_NYC_2019
group by host_id, host_name
order by 3 desc;


--9. What is the average price per night for Airbnb listings in the top 5 neighborhoods with the highest number of listings?

select top 5 neighbourhood, count(id) total_listings, round(avg(price),2) avg_price
from AB_NYC_2019
group by neighbourhood
order by 2 desc

--10. What is the average price per night for each room type, and how does it compare to the overall average price per night?

with avg_price_cte as 
(
	select round(avg(price),2) overall_avg
	from AB_NYC_2019
),
room_type_cte as
(
	select room_type, round(avg(price),2) avg_price
	from AB_NYC_2019
	group by room_type
)
select *
from room_type_cte, avg_price_cte
order by 2 desc;

--11. What is the average price per night for each neighborhood, and how does it compare to the overall average price per night?

with avg_price_cte as 
(
	select round(avg(price),2) overall_avg
	from AB_NYC_2019
),
neighbourhood_cte as
(
	select neighbourhood, round(avg(price),2) avg_price
	from AB_NYC_2019
	group by neighbourhood
)
select *
from neighbourhood_cte, avg_price_cte
order by 2 desc;

--12. What is the percentage of listings in each neighborhood that have a minimum number of nights greater than or equal to 30?

with cte_min_30_night_booking as
(
	select neighbourhood, count(id) listings_min_30_night_booking
	from AB_NYC_2019
	where minimum_nights >= 30
	group by neighbourhood
),
cte_listings_neighbourhood as
(
	select neighbourhood, count(id) total_listings
	from AB_NYC_2019
	group by neighbourhood
),
cte_join as
(
	select a.neighbourhood, a.listings_min_30_night_booking, b.total_listings
	from cte_min_30_night_booking a
	left join cte_listings_neighbourhood b
	on a.neighbourhood = b.neighbourhood
)
select *,
format((listings_min_30_night_booking * 100.0 / total_listings),'N2') pct_min_30_nights_booking
from cte_join
order by 4 desc;
