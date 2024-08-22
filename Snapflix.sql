select * from dbo.enhanced_snapfix_dataset;

--Total revenue generated for each property type, ordered by the highest revenue.

Select property_type, Round(sum(revenue),2) as Total_Revenue
from dbo.enhanced_snapfix_dataset
group by property_type
order by Total_Revenue Desc;
-- Industrial property type generates the most profit 

--average completion time for tasks that are marked as completed
SELECT AVG(completion_time_hours) AS average_completion_time
FROM dbo.enhanced_snapfix_dataset
WHERE task_status = 'completed';

--tasks along with user roles where the property is located in 'Dublin' or 'Cork'
Select task_category,user_role, property_location,count(*) from dbo.enhanced_snapfix_dataset
group by task_category,user_role,property_location
having property_location in ('Cork','Dublin');

--the total number of tasks created by each user role
Select user_role, count(task_category) as Number_of_tasks
from dbo.enhanced_snapfix_dataset
group by user_role
order by Number_of_tasks desc;

--the property details and task descriptions for tasks with high priority that have been completed
Select property_id,property_type,property_location,task_description
from dbo.enhanced_snapfix_dataset
where task_priority='high' and task_status ='completed';

--total cost savings for each regions
Select region, sum(cost_savings) as total_cost_savings
from dbo.enhanced_snapfix_dataset
group by region
order by total_cost_savings desc;

--top 10 users who have uploaded more than 3 photos for tasks located in 'Limerick'
Select top 10 user_id, sum(photos_uploaded) as Total_photos
from dbo.enhanced_snapfix_dataset
where property_location='Limerick'
group by user_id
having sum(photos_uploaded) > =3 
order by Total_photos desc;

--Retrieve tasks and their respective properties for those created after '2023-01-01', including property type and location.
SELECT task_category, property_type, property_location
FROM dbo.enhanced_snapfix_dataset
WHERE task_status IN ('created', 'in progress')
AND CAST(date AS DATE) BETWEEN '2023-01-01' AND GETDATE();

--the maximum customer satisfaction score for each task category.
Select task_category, Round(max(customer_satisfaction),2) as max_customer_satisfaction
FROM dbo.enhanced_snapfix_dataset
group by  task_category;

--combined list of all tasks along with their statuses from 'Ireland' and 'UAE' regions.
Select region,task_category,count(task_category) as total_task
FROM dbo.enhanced_snapfix_dataset
where region = 'Ireland'  or region = 'UAE'
group by region,task_category

--Find the top 3 users with the highest total revenue from tasks they managed.
select top 3 user_id, sum(revenue)  as total_revenue
from dbo.enhanced_snapfix_dataset
group by user_id
order by sum(revenue)

--Manipulating Task Descriptions
SELECT task_description,LEFT(task_description, CHARINDEX(' ', task_description + ' ') - 1) AS first_word, UPPER(task_description) AS upper_case_description,
REPLACE(task_description, 'issue', 'problem') AS replaced_description,
LTRIM(RTRIM(task_description)) AS trimmed_description,
CONCAT('Task: ', UPPER(REPLACE(LTRIM(RTRIM(task_description)), 'issue', 'problem'))) AS final_description
FROM dbo.enhanced_snapfix_dataset
WHERE task_description IS NOT NULL;

--List all tasks along with their respective property details for properties located in 'Ireland'

Select e.task_category,p.property_type,p.property_id,p.property_location
from dbo.enhanced_snapfix_dataset e
join dbo.enhanced_snapfix_dataset p
on e.property_id=p.property_id
where p.region in ('Ireland');
--Get the average customer satisfaction per region and task category, including only those categories with an average satisfaction above 3.
Select region, task_category ,avg(customer_satisfaction)
from dbo.enhanced_snapfix_dataset 
GROUP BY region, task_category
HAVING AVG(customer_satisfaction) > 3;

--Retrieve tasks that were completed in the last 30 days along with the user roles using a window function.
SELECT task_category,  user_role, completion_time_hours,
 ROW_NUMBER() OVER (PARTITION BY user_role ORDER BY completion_time_hours DESC) AS row_num
FROM dbo.enhanced_snapfix_dataset
WHERE task_status = 'completed' AND date >= DATEADD(day, -30, CAST(GETDATE() AS DATE));

--Find all users who have managed tasks in more than one region.
Select user_id, count(region) as Total_region
FROM dbo.enhanced_snapfix_dataset
group by user_id
having count (distinct (region))>1
order by Total_region desc;

--List tasks and their respective properties where the task description contains the word 'inspection'.
Select task_category,task_priority,property_id,property_location,property_type
FROM dbo.enhanced_snapfix_dataset
where task_category like '%inspection%';

--Combine the list of tasks from 'India' and 'UAE' regions using a UNION.
Select task_status,task_category,task_priority,task_description,region
FROM dbo.enhanced_snapfix_dataset
where region='UAE'
Union
Select task_status,task_category,task_priority,task_description,region
FROM dbo.enhanced_snapfix_dataset
where region='India'

--Retrieve the total number of tasks for each user role and property type combination.
Select user_role,property_type,count(*) as number_of_tasks
FROM dbo.enhanced_snapfix_dataset
group by  user_role,property_type
order by number_of_tasks desc;

--Calculate the percentage of high-priority tasks for each property type.
Select property_type,
 Round(100.0 * SUM(CASE WHEN task_priority = 'high' THEN 1 ELSE 0 END) / COUNT(*),2) AS high_priority_percentage
FROM dbo.enhanced_snapfix_dataset
GROUP BY  property_type;

--Find the earliest and latest task creation dates for each property location.
SELECT property_location, MIN(date) AS earliest_date, MAX(date) AS latest_date
FROM  dbo.enhanced_snapfix_dataset
GROUP BY  property_location;

--task priority
SELECT  task_description, task_priority,
    CASE 
        WHEN task_priority = 'high' THEN 'Urgent'
        WHEN task_priority = 'medium' THEN 'Important'
        WHEN task_priority = 'low' THEN 'Normal'
        ELSE 'Undefined'
    END AS priority_label
FROM dbo.enhanced_snapfix_dataset;

--Rank Tasks by Completion Time Within Each User Role
SELECT task_description, user_role, completion_time_hours,
 RANK() 
 OVER (
 PARTITION BY user_role 
 ORDER BY completion_time_hours ASC
 ) AS rank_within_role
FROM dbo.enhanced_snapfix_dataset
WHERE task_status = 'completed';

--Find Top 3 Properties with the Most Completed High-Priority Tasks in Each Region
WITH HighPriorityTasks AS (
SELECT  property_id, property_location, COUNT(*) AS high_priority_task_count
FROM dbo.enhanced_snapfix_dataset
WHERE task_status = 'completed' AND task_priority = 'high'
GROUP BY property_id, property_location
),
RankedProperties AS (
SELECT property_id,property_location,high_priority_task_count,
RANK() OVER ( PARTITION BY property_location ORDER BY high_priority_task_count DESC) AS rank_within_region
FROM HighPriorityTasks
)
SELECT property_id,property_location,high_priority_task_count
FROM RankedProperties
WHERE rank_within_region <= 3
ORDER BY property_location, rank_within_region;

--Identify Properties with Above-Average Completed Tasks and Calculate High-Priority Task Percentage
CREATE TABLE PropertyTaskCounts (
property_id INT,
property_location VARCHAR(255),
completed_task_count INT
);

INSERT INTO PropertyTaskCounts
SELECT property_id, property_location,COUNT(*) AS completed_task_count
FROM dbo.enhanced_snapfix_dataset
WHERE task_status = 'completed'
GROUP BY  property_id, property_location;

CREATE TABLE RegionTaskAverages (
property_location VARCHAR(255),
avg_completed_task_count DECIMAL(10, 2)
);

INSERT INTO RegionTaskAverages
SELECT 
property_location,
AVG(completed_task_count) AS avg_completed_task_count
FROM PropertyTaskCounts
GROUP BY property_location;

SELECT p.property_id, p.property_location, p.completed_task_count,
100.0 * SUM(CASE WHEN e.task_priority = 'high' THEN 1 ELSE 0 END) / p.completed_task_count AS high_priority_percentage
FROM PropertyTaskCounts p
JOIN RegionTaskAverages r 
ON p.property_location = r.property_location
JOIN dbo.enhanced_snapfix_dataset e 
ON p.property_id = e.property_id
WHERE p.completed_task_count > r.avg_completed_task_count AND e.task_status = 'completed'
GROUP BY p.property_id, p.property_location, p.completed_task_count
ORDER BY high_priority_percentage DESC;