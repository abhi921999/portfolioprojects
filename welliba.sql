create database welliba_insights;

Select * from dbo.Welliba_Employee_Experience_Dataset;

-- Average Employee Satisfaction by Department
Select Department, Round(Avg(Satisfaction_Score),2) as Average_Satisfaction_Score,
Round(Avg(Engagement_Level),2) as Average_Engagement_Score
From Welliba_Employee_Experience_Dataset
Group by Department
Order by Average_Satisfaction_Score Desc,Average_Engagement_Score Desc;

-- Identify Employees with High Flight Risk
Select Employee_ID, Department
From Welliba_Employee_Experience_Dataset
Where Flight_Risk = 'High';

--Top 5 Departments with Highest Absenteeism Rates
Select Top 5 Department,Round(Avg(Absenteeism_Rate),2) AS Average_Absenteeism_Rate
From Welliba_Employee_Experience_Dataset
Group by Department
Order by Average_Absenteeism_Rate Desc

--Employee Wellbeing Index vs. Psychological Safety
Select Round(avg(Wellbeing_Index),2) as wellbeing_index, Round(avg(Psychological_Safety),2) as psychological_safety
From Welliba_Employee_Experience_Dataset

--Identify number of Employees with Low eNPS Scores
Select Department,count(Employee_ID)
From Welliba_Employee_Experience_Dataset
Where eNPS_Score < 0
Group by Department

--Career Growth Opportunities by Department
Select Department, Round(Avg(Career_Growth),2) as Average_Career_Growth
From Welliba_Employee_Experience_Dataset
Group by Department
Order by Average_Career_Growth Desc;

-- Predictive Insights: High Flight Risk and Low Engagement
Select Employee_id
From Welliba_Employee_Experience_Dataset
Where Flight_Risk = 'High' and Engagement_Level < 4
Order by Engagement_Level Asc;

--Effectiveness of Managers Across Departments
Select Department, Round(Avg(Manager_Effectiveness),2) AS Average_Manager_Effectiveness
From Welliba_Employee_Experience_Dataset
Group by Department
Order by Average_Manager_Effectiveness Desc;

--Rank Departments by Average Employee Satisfaction
Select Department, Avg(Satisfaction_Score) AS Average_Satisfaction_Score,
Rank() Over (Order by AVG(Satisfaction_Score) Desc) as Department_Rank
From Welliba_Employee_Experience_Dataset
Group by Department
Order by Department_Rank Asc;

--Cumulative Sum of Absenteeism Rate by Department
Select Department, Employee_ID, Absenteeism_Rate,
Sum (Absenteeism_Rate) OVER (PARTITION BY Department ORDER BY Employee_ID) AS Cumulative_Absenteeism_Rate
From Welliba_Employee_Experience_Dataset
Order by Department,Employee_ID;
--Identifying High-Risk Departments
WITH high_risk_employees AS (
Select Employee_id,Department,engagement_level,absenteeism_rate,flight_risk,
satisfaction_score, career_growth, Wellbeing_Index, Psychological_Safety
From Welliba_Employee_Experience_Dataset
Where flight_risk = 'High'
),
department_summary AS (
Select h.Department,AVG(h.engagement_level) AS avg_engagement, AVG(h.absenteeism_rate) AS avg_absenteeism, COUNT(h.employee_id) AS high_risk_employee_count
FROM high_risk_employees h
GROUP BY h.Department
)
Select ds.Department, ds.avg_engagement, ds.avg_absenteeism,  ds.high_risk_employee_count,
  CASE
	When ds.avg_engagement < 4 or ds.avg_absenteeism > 8 Then 'Critical'
    When ds.avg_engagement < 5 or ds.avg_absenteeism > 7 Then 'High'
    Else 'Moderate'
    End as risk_level
From department_summary ds
Order by risk_level Desc, ds.high_risk_employee_count Desc;

--Rank of Each Employee's Satisfaction Score within Their Department and  Employees with Above-Average Satisfaction Scores
WITH DepartmentAvgSatisfaction AS (
Select Department, Avg(Satisfaction_Score) AS Avg_Satisfaction
From  Welliba_Employee_Experience_Dataset
Group by Department
)
SELECT w.Employee_ID,w.Department,w.Satisfaction_Score,
 DENSE_RANK() OVER (PARTITION BY w.Department ORDER BY w.Satisfaction_Score DESC) AS Satisfaction_Rank,
 d.Avg_Satisfaction
From  Welliba_Employee_Experience_Dataset w
Join DepartmentAvgSatisfaction d
On w.Department = d.Department
Where  w.Satisfaction_Score > d.Avg_Satisfaction
Order by  w.Department, Satisfaction_Rank;

-- Departments with the Highest Average Engagement Levels and List Employees in Those Departments with a Low Flight Risk
WITH DepartmentEngagement AS (
Select Department, Avg(Engagement_Level) AS Avg_Engagement
From Welliba_Employee_Experience_Dataset
Group by Department
),
MaxEngagement AS (
Select Max(Avg_Engagement) AS Max_Avg_Engagement
From DepartmentEngagement
)
Select  w.Employee_ID, w.Department, w.Engagement_Level, w.Flight_Risk
From Welliba_Employee_Experience_Dataset w
Join DepartmentEngagement d
On w.Department = d.Department
Join MaxEngagement m
On d.Avg_Engagement = m.Max_Avg_Engagement
Where w.Flight_Risk = 'Low'
Order by w.Department, w.Employee_ID;

--Employees with Above-Average Manager Effectiveness but Below-Average Career Growth within Their Department
Select Employee_ID, Department,Manager_Effectiveness,Career_Growth
From Welliba_Employee_Experience_Dataset w
Where Manager_Effectiveness > (Select AVG(Manager_Effectiveness) From Welliba_Employee_Experience_Dataset Where Department = w.Department)
AND Career_Growth < (Select Avg(Career_Growth) From Welliba_Employee_Experience_Dataset Where Department = w.Department)
Order by Department, Employee_ID;