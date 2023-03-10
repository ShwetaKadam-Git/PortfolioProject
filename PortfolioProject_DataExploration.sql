/**
DATA Exploration Sample project by referring Alex The Analyst youtube channel by Alex Freberg
The data I used in this is the latest one i.e., From Feb 2020 to March 2023. Sample files are added in the project section you can download and import it in your SQL server using SQL import and export wizard
FileNames - CovidDeaths, CovidVaccinations
**/

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

---To select data which we will be using
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY location,date

--Total cases vs Total deaths in a country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
where location like 'India'
and continent is not null
ORDER BY location,date

--Total Cases vs Population 
--Showing percentage of population got covid
SELECT location,date,total_cases,Population,(total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where location like 'India'
ORDER BY 1,2

--Highest percentage of covid cases/infection rate in a country
SELECT location,Population,Max(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY population,location
ORDER BY PercentPopulationInfected DESC

--Countries with Highest death count per population
SELECT Location,Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Data breakup by continent
--Resulted data is incomplete via this query
SELECT continent,Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--second try
SELECT Location,Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing the continents with highest death counts

SELECT continent,Max(cast (total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_Cases,SUM(cast(new_deaths as int)) as total_Deaths,SUM(cast(new_deaths as int))/sum(new_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as total_Cases,SUM(cast(new_deaths as int)) as total_Deaths,SUM(cast(new_deaths as int))/sum(new_Cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like 'India'
where continent is not null
--GROUP BY date
ORDER BY 1,2

--
SELECT *
FROM PortfolioProject..CovidVaccinations VAC
JOIN PortfolioProject..CovidDeaths DEA
ON	DEA.LOCATION=VAC.LOCATION
AND DEA.date=VAC.date

--Total population vs Vaccinations
SELECT 
DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(Convert(bigint,VAC.new_vaccinations )) OVER (Partition by DEA.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON	DEA.LOCATION=VAC.LOCATION
	AND DEA.date=VAC.date
WHERE DEA.continent is not null 
ORDER BY 2,3

-- USING CTE (Common Table Expression)
WITH PopulationVsVaccination(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as 
(
SELECT 
DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(Convert(bigint,VAC.new_vaccinations )) OVER (Partition by DEA.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON	DEA.LOCATION=VAC.LOCATION
	AND DEA.date=VAC.date
WHERE DEA.continent is not null 
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM PopulationVsVaccination

---TEMORARY TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT 
DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(Convert(bigint,VAC.new_vaccinations )) OVER (Partition by DEA.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON	DEA.LOCATION=VAC.LOCATION
	AND DEA.date=VAC.date
WHERE DEA.continent is not null 
ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/Population)*100 
FROM #PercentPopulationVaccinated

--CREATING View to visualize later

CREATE VIEW PercentPopulationVaccinated as
SELECT 
DEA.continent,DEA.location,DEA.date,DEA.population,VAC.new_vaccinations,
SUM(Convert(bigint,VAC.new_vaccinations )) OVER (Partition by DEA.location order by dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
	ON	DEA.LOCATION=VAC.LOCATION
	AND DEA.date=VAC.date
WHERE DEA.continent is not null 
--ORDER BY 2,3
