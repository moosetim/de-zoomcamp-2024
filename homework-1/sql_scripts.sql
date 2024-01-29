-- Question 3
select count(1) as n_trips
from public.yellow_taxi_trips
where 1=1
and lpep_pickup_datetime::date = '2019-09-18'
and lpep_dropoff_datetime::date = '2019-09-18';

-- Question 4
select 
	lpep_pickup_datetime::date as pickup_date
	, trip_distance
from public.yellow_taxi_trips
where 1=1
order by trip_distance desc;

-- Question 5
select 
	z."Borough"
	, sum(total_amount) as total_amount_per_borough
from public.yellow_taxi_trips as t
left join public.zones as z
	on t."PULocationID" = z."LocationID"
where 1=1
and lpep_pickup_datetime::date = '2019-09-18'
and z."Borough" != 'Unknown'
group by z."Borough"
having sum(total_amount) > 50000
order by total_amount_per_borough desc;

-- Question 6
select 
	t.*
	, puz."Borough" as pickup_borough
	, puz."Zone" as pickup_zone
	, doz."Borough" as dropoff_borough
	, doz."Zone" as dropoff_zone
from public.yellow_taxi_trips as t
left join public.zones as puz
	on t."PULocationID" = puz."LocationID"
left join public.zones as doz
	on t."DOLocationID" = doz."LocationID"
where 1=1
and t.lpep_pickup_datetime::date >= '2019-09-01'
and t.lpep_pickup_datetime::date <= '2019-09-30'
and puz."Zone" = 'Astoria'
order by tip_amount desc
limit 10;