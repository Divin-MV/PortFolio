SELECT * 
FROM dbo.coviddeaths
ORDER BY 3,4


SELECT * 
FROM dbo.covidvacc
ORDER BY 3,4


---select data to be used

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM dbo.coviddeaths
ORDER BY 1,2

--- total cases and total deaths are of nvarchar. changing datatype

ALTER TABLE dbo.coviddeaths
ALTER COLUMN total_cases float

ALTER TABLE dbo.coviddeaths
ALTER COLUMN total_deaths float




---Looking at total cases vs total Deaths
---shows likelihood of dying


SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
FROM dbo.coviddeaths
--WHERE location like '%united kingdom%'
ORDER BY 1,2


---Lookin at total cases vs population
---shows percentage of pupulation that got covid

SELECT location,date,population, total_cases,(total_cases/population)*100 as populationpercentage
FROM dbo.coviddeaths
--WHERE location like '%united kingdom%'
ORDER BY 1,2

---Looking at countries with highest infection rates

SELECT location,population, MAX(total_cases) as HighestInfectionCount ,MAX((total_cases/population))*100 as populationpercentage
FROM dbo.coviddeaths
GROUP BY location, population
ORDER BY 4 desc


---Showing countries with highest death count by population

SELECT location,population, MAX(total_deaths) as HighestDeathCount ,MAX((total_deaths/population))*100 as populationpercentage
FROM dbo.coviddeaths
GROUP BY location, population
ORDER BY 4 desc


---showing by continent/aggregate

SELECT location,population, MAX(total_deaths) as HighestDeathCount ,MAX((total_deaths/population))*100 as populationpercentage
FROM dbo.coviddeaths
WHERE continent is null --and location not like '%income%'
GROUP BY location, population
ORDER BY 4 desc


--- looking at world numbers


SELECT location, date, total_cases, total_deaths, ((total_deaths/total_cases)*100) as DeathPerc
FROM dbo.coviddeaths
WHERE continent is null and location like '%world%'
ORDER BY 2


---looking at total population vs Vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as CumulativeVac
FROM dbo.coviddeaths dea
JOIN dbo.covidvacc vac
	ON dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,2,3


---Using CTE for virtuual table

WITH PopVsVac
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as CumulativeVac
FROM dbo.coviddeaths dea
JOIN dbo.covidvacc vac
	ON dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT * , ((CumulativeVac/population)*100) AS PercVac
FROM PopVsVac
ORDER BY 1,2,3


--- Creating Temp Table

DROP TABLE if exists PercentPopVacc
CREATE TABLE PercentPopVacc
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
CumulativeVac numeric
)
INSERT INTO PercentPopVacc
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as CumulativeVac
FROM dbo.coviddeaths dea
JOIN dbo.covidvacc vac
	ON dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, ((CumulativeVac/population)*100) AS PercVac
FROM PercentPopVacc
ORDER BY 2,3



---Creating View to store data for visualization


CREATE VIEW PercentPopVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as CumulativeVac
FROM dbo.coviddeaths dea
JOIN dbo.covidvacc vac
	ON dea.location =vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


SELECT * 
FROM PercentPopVaccinated