### Mini Project - Hermann Fan - jf1687@georgetown.edu ###

### Question 1 ###
select Reporting_Airline, max(DepDelayMinutes) as max_delay
from al_perf
group by Reporting_Airline
order by max_delay asc; # 16 rows returned

### Question 2 ###
select Reporting_Airline, ABS(MIN(DepDelay)) AS max_early_departure_minutes
from al_perf
group by Reporting_Airline
order by max_early_departure_minutes desc; # 16 rows returned

### Question 3
with temp as (
    select
        DayOfWeek,
        case DayOfWeek
            WHEN 1 THEN 'Monday'
            WHEN 2 THEN 'Tuesday'
            WHEN 3 THEN 'Wednesday'
            WHEN 4 THEN 'Thursday'
            WHEN 5 THEN 'Friday'
            WHEN 6 THEN 'Saturday'
            WHEN 7 THEN 'Sunday'
        end as day_name,
        COUNT(*) as num_flights
    from al_perf
    group by DayOfWeek
)# this is a temperal table
select
    day_name,
    num_flights,
    dense_rank() over (order by num_flights desc) as day_rank  
from temp
order by day_rank; # 8 rows returned 

### question 4
select 
	OriginCityName,
    Origin,
    avg(DepDelayMinutes) as avg_dep_delay
from al_perf
group by Origin, OriginCityName
order by avg_dep_delay DESC
limit 1; # which is Bishop, California, 1 row returned since limit 1

### question 5
with airline_airport_avg as (
    select 
        Reporting_Airline,
        OriginCityName as airport_name,
        Origin         as airport_code,
        round(avg(DepDelayMinutes),3) as avg_dep_delay # the final table looks too messy, so added a round function
    from al_perf
    group by Reporting_Airline, Origin, OriginCityName
),
ranked as (
    select
        *,
        row_number() over (
            partition by Reporting_Airline
            order by avg_dep_delay desc
        ) as rn
    from airline_airport_avg
)
select
	Reporting_Airline,
    airport_name,
    avg_dep_delay
from ranked
where rn = 1
order by Reporting_Airline; # 16 rows returned

### question 6
select COUNT(*) as num_cancelled_flights
from al_perf
where Cancelled = 1; # 1 row --> 4035 cancelled flights

### question 6b
with airport_reason_counts as (
    select
        origincityname as airport_name,
        origin as airport_code,
        cancellationcode,
        count(*) as num_cancelled
    from al_perf
    where cancelled = 1
    group by origincityname, origin, cancellationcode
),
ranked as (
    select
        *,
        row_number() over (
            partition by airport_name, airport_code
            order by num_cancelled desc
        ) as rn
    from airport_reason_counts
)

select
    airport_name,
    airport_code,
    cancellationcode as most_frequent_reason,
    num_cancelled
from ranked
where rn = 1
order by num_cancelled desc; # 233 rows returned

### question 7
with daily_counts as (
    select
        flightdate,
        count(*) as num_flights
    from al_perf
    group by flightdate
) # a temp table called daily_counts, selecting all necessaries
select
    flightdate,
    num_flights,
    avg(num_flights) over (
        order by flightdate
        rows between 3 preceding and 1 preceding
    ) as avg_flights_prev_3_days
from daily_counts
order by flightdate;