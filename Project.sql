-- selecting data we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_101..[owid-covid-data]
where NULLIF(continent, '') IS NOT NULL 
order by location, date;

--total number of COVID-19 tests conducted by each country
Select location,Sum(Cast(total_tests as bigint)) from Portfolio_101..Covid_Vaccination where NULLIF(continent, '') IS NOT NULL  group by location

 --First Case Per Country
Select Location, Min(Date)
from Portfolio_101..[owid-covid-data]  
where NULLIF(continent, '') IS NOT NULL and total_cases >0 
Group by location
 
--Total new Cases on particular date
SELECT Date, SUM(CAST(new_cases AS INT)) AS TotalNewCases
FROM Portfolio_101..[owid-covid-data]
WHERE date = '01-06-2021'
GROUP BY Date;

-- Count of countries which had more than 10,000 deaths
Select Count(Distinct( location)) as count_of_Countries
FROM Portfolio_101..[owid-covid-data] 
where Cast(total_deaths as int)>10000 and NULLIF(continent, '') IS NOT NULL

 --To find highest cases in last 30 days
SELECT TOP 5 location, SUM(CAST(new_cases AS INT)) AS HighestNewCases
FROM Portfolio_101..[owid-covid-data]
WHERE CONVERT(DATETIME, date, 105) >= DATEADD(day, -30, GETDATE()) and NULLIF(continent, '') IS NOT NULL
GROUP BY location
ORDER BY HighestNewCases DESC;

-- to check percantage of population vaccinated
SELECT d.location, MAX(d.population) AS Population, MAX(c.total_vaccinations) AS TotalVaccinations, (CAST(MAX(c.total_vaccinations) AS FLOAT) / NULLIF(CAST(MAX(d.population) AS FLOAT), 0)) * 100 AS VaccinationPercentage
from Portfolio_101..[owid-covid-data] d
Join Portfolio_101..Covid_Vaccination c
ON d.location = c.location
and d.date=c.date
where NULLIF(d.continent, '') IS NOT NULL 
Group by d.location
order by location, population;


-- Total cases vs Total Death
Select location, date,total_cases,total_deaths, (CAST(total_deaths AS FLOAT) / NULLIF(CAST(total_cases AS FLOAT), 0)) * 100 AS death_percentage
from Portfolio_101..[owid-covid-data]
where location like '%Ireland%' or location like '%India%'  and  NULLIF(continent, '') IS NOT NULL 
order by location, date;

-- looking at total case vs population
Select location, date,total_cases,population, (CAST(total_cases AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS covid_percentage
from Portfolio_101..[owid-covid-data]
where location like '%Ireland%' or location like '%India%' and  NULLIF(continent, '') IS NOT NULL 
order by location, date;

--country with highest cases compared to population 
Select location, max(total_cases) as HighestCases, population, (CAST(MAX(total_cases) AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS highest_covid_percentage
from Portfolio_101..[owid-covid-data]
WHERE NULLIF(continent, '') IS NOT NULL 
Group by location,population
order by highest_covid_percentage desc;

----country with highest deathcount compared to population -- check again tomm
Select location, max(Cast(total_deaths as int)) as Highestdeath
from Portfolio_101..[owid-covid-data]
WHERE NULLIF(continent, '') IS NOT NULL
Group by location
order by Highestdeath desc;

--select * from Portfolio_101..[owid-covid-data] where continent is not null--location like '%asia%'
--order by location,date; 

-- By continent
Select continent, max(Cast(total_deaths as int)) as Highestdeath_1
from Portfolio_101..[owid-covid-data]
WHERE NULLIF(continent, '') IS NOT NULL
Group by continent
order by Highestdeath_1 desc;

--Global Numbers 
Select location,sum(Cast(new_cases as int)), Sum(Cast(new_deaths as Int)) , ((SUM(CAST(new_deaths AS float))) / NULLIF(SUM(CAST(new_cases AS float)), 0)*100) AS DeathPercentageGlobal
from Portfolio_101..[owid-covid-data]
where NULLIF(continent, '') IS NOT NULL 
Group by location
order by DeathPercentageGlobal desc;

Select date, Sum(Cast(new_deaths as Int))
from Portfolio_101..[owid-covid-data]
where NULLIF(continent, '') IS NOT NULL 
Group by date
order by date;


-- Total population vs vaccination

Select d.location,d.continent,d.date,d.population,v.new_vaccinations,
SUM(Cast(new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date)
As RollingVaccine
from Portfolio_101..[owid-covid-data] d
Join Portfolio_101..Covid_Vaccination v
ON d.location = v.location
and d.date=v.date
where NULLIF(d.continent, '') IS NOT NULL 
order by location, date;

--USE CTE
With PopVsVac (location, continent, date, population, new_vaccinations,RollingVaccine)
as
(Select d.location,d.continent,d.date,d.population,v.new_vaccinations,
SUM(Cast(new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date)
As RollingVaccine
from Portfolio_101..[owid-covid-data] d
Join Portfolio_101..Covid_Vaccination v
ON d.location = v.location
and d.date=v.date
where NULLIF(d.continent, '') IS NOT NULL 
--order by location, date
)
SELECT   *, 
(CAST(RollingVaccine AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS VaccinationPercentage
FROM PopVsVac;


-- Temp Table
 Create Table PercentPopulationVaccinated
 (
 continent nvarchar (255),
 location nvarchar (255),
 Date datetime,
 population int,
 new_vaccinations int,
 RollingVaccine int)

ALTER TABLE PercentPopulationVaccinated
ALTER COLUMN RollingVaccine bigint;

 Insert into PercentPopulationVaccinated
 Select d.location,d.continent,TRY_CONVERT(datetime, d.date, 120),d.population,v.new_vaccinations,
SUM(Cast(new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date)
As RollingVaccine
from Portfolio_101..[owid-covid-data] d
Join Portfolio_101..Covid_Vaccination v
ON d.location = v.location
and d.date=v.date
where NULLIF(d.continent, '') IS NOT NULL 
--order by location, date

SELECT   *, 
(CAST(RollingVaccine AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated;


Drop table PercentPopulationVaccinated;
 Create Table PercentPopulationVaccinated_1
 (
 continent nvarchar (255),
 location nvarchar (255),
 Date datetime,
 population int,
 new_vaccinations int,
 RollingVaccine int)

 ALTER TABLE PercentPopulationVaccinated_1
ALTER COLUMN RollingVaccine bigint;

 Insert into PercentPopulationVaccinated_1
 Select d.continent,d.location,TRY_CONVERT(datetime, d.date, 120),d.population,v.new_vaccinations,
SUM(Cast(new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date)
As RollingVaccine
from Portfolio_101..[owid-covid-data] d
Join Portfolio_101..Covid_Vaccination v
ON d.location = v.location
and d.date=v.date
where NULLIF(d.continent, '') IS NOT NULL 
--order by location, date

SELECT   *, 
(CAST(RollingVaccine AS FLOAT) / NULLIF(CAST(population AS FLOAT), 0)) * 100 AS VaccinationPercentage
FROM PercentPopulationVaccinated_1;


-- Creating Views
create view percentpeoplevaccinated as
Select d.continent,d.location,TRY_CONVERT(datetime, d.date, 120) as newdate,d.population,v.new_vaccinations,
SUM(Cast(new_vaccinations as bigint)) OVER (partition by d.location order by d.location, d.date)
As RollingVaccine
from Portfolio_101..[owid-covid-data] d
Join Portfolio_101..Covid_Vaccination v
ON d.location = v.location
and d.date=v.date
where NULLIF(d.continent, '') IS NOT NULL 

Create view highestdeathbycontinent as
Select continent, max(Cast(total_deaths as int)) as Highestdeath_1
from Portfolio_101..[owid-covid-data]
WHERE NULLIF(continent, '') IS NOT NULL
Group by continent
--order by Highestdeath_1 desc;

SELECT *
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'highestdeathbycontinent'
