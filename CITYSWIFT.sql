select * from Cityswift..ttc_bus_delay_data_2022_irish_locations;

--unique routes available 
Select distinct Route from Cityswift..ttc_bus_delay_data_2022_irish_locations;

-- incidents on particular day
Select count(Incident) from Cityswift..ttc_bus_delay_data_2022_irish_locations
where Day='Saturday'
Group by Day;

--Distinct locations 
Select Distinct Location 
from Cityswift..ttc_bus_delay_data_2022_irish_locations;

-- total delays 
Select count(*) as total_delays 
from Cityswift..ttc_bus_delay_data_2022_irish_locations;
--Average delay 
SELECT AVG(Min_Delay) AS average_delay 
from Cityswift..ttc_bus_delay_data_2022_irish_locations;

-- Total delays in minute per route
SELECT Route,Sum(Min_Delay) AS total_delays 
from Cityswift..ttc_bus_delay_data_2022_irish_locations
Group by Route
order by total_delays desc;

--location with max incidents
Select Location, count(*) as incident_count
from Cityswift..ttc_bus_delay_data_2022_irish_locations
GROUP BY Location
ORDER BY incident_count DESC;
--the average gap time (in minutes) for incidents occurring on weekdays
SELECT AVG(Min_Gap) as average_gap
from Cityswift..ttc_bus_delay_data_2022_irish_locations
where Day  IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday');

--most common type of incident recorded
Select Incident, count(*) incident_count
from Cityswift..ttc_bus_delay_data_2022_irish_locations
GROUP BY Incident
ORDER BY incident_count DESC;

--the route that had the maximum total delay time across all incidents
SELECT TOP 1 Route, SUM("Min_Delay") AS total_delay
FROM Cityswift..ttc_bus_delay_data_2022_irish_locations
GROUP BY Route
ORDER BY total_delay DESC;

--the top 3 days with the highest total delay time and list the routes and locations involved
WITH TopDays AS (
    SELECT TOP 3 Date, SUM("Min_Delay") AS total_delay
    FROM Cityswift..ttc_bus_delay_data_2022_irish_locations
    GROUP BY Date
    ORDER BY total_delay DESC
)
SELECT t.Date, t.total_delay, d.Route, d.Location
FROM TopDays t
JOIN Cityswift..ttc_bus_delay_data_2022_irish_locations d ON t.Date = d.Date
ORDER BY t.total_delay DESC;

--  average delay time for each route that has more than 10 incidents.
Select Route, Avg(Min_Delay)
from Cityswift..ttc_bus_delay_data_2022_irish_locations 
where Route in
(Select Route 
from Cityswift..ttc_bus_delay_data_2022_irish_locations    
GROUP BY Route
HAVING COUNT(*) > 10
)
GROUP BY Route
order by Avg(Min_Delay) desc;

--location with the highest average delay time for incidents that occur only on weekdays (Monday to Friday).

Select location,Avg(Min_Delay) 
FROM Cityswift..ttc_bus_delay_data_2022_irish_locations
WHERE Day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
GROUP BY Location
HAVING AVG(Min_Delay) = (
SELECT MAX(avg_delay)
 FROM (
        SELECT Location, AVG(Min_Delay) AS avg_delay
        FROM Cityswift..ttc_bus_delay_data_2022_irish_locations
        WHERE Day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
        GROUP BY Location) as sub);

--top 3 locations with the highest average delay time for incidents that occur only on weekdays (Monday to Friday)
WITH WeekdayDelays AS (
    SELECT Location, Min_Delay,
		 AVG(Min_Delay) OVER (PARTITION BY Location) AS avg_delay
	FROM Cityswift..ttc_bus_delay_data_2022_irish_locations
	WHERE Day IN ('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday')
)
SELECT DISTINCT TOP 3 Location, avg_delay
FROM WeekdayDelays
ORDER BY avg_delay DESC;