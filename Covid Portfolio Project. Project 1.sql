SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations$
WHERE continent is not null
ORDER BY 3,4

--Select Data that we will be using in the project

SELECT Location, date, total_cases, new_cases, Total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total cases versus Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, Total_deaths,(total_deaths/total_cases)*100 AS DeathtoCases
FROM PortfolioProject..CovidDeaths$
WHERE location like '%africa%'
AND continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--shows what percentage of population got covid
SELECT Location, date, total_cases, Population,(total_cases/population)*100 AS DeathtoPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%africa%'
AND continent is not null
ORDER BY 1,2

--The countries with the highest infection rate

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--highest infection rate in africa
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
WHERE location like '%africa%'
AND continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

--Countries with Highest death count per population

SELECT Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

Breaking down by Continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%africa%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

-- Global Numbers

SELECT date, SUM(new_cases)AS totalcases,SUM(CAST(new_deaths AS INT)) AS totaldeaths, SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
group by date
ORDER BY 1,2

--Covid Vaccinations JOINS

SELECT *
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vacc
on dea.location = vacc.location
and dea.date = vacc.date

--Total Population VS Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
order by 2,3

--use CTE

with PopvsVacc (Continent, location, date, population, new_vaccinations, Rollingpeoplevaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select *
from PopvsVacc



--TEMP TABLE

DROP TABLE if exists
Create Table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
newvaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vacc
on dea.location = vacc.location
and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3

select *, (Rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--CREATE VIEW

create view percentpeoplevaccinated as
(SELECT dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (Partition by dea.location) AS Rollingpeoplevaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vacc
on dea.location = vacc.location
and dea.date = vacc.date
--where dea.continent is not null
)
select *
from percentpeoplevaccinated