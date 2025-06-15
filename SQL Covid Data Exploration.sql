SELECT * FROM `subtle-creek-380809.Covid.Deaths`
where continent is not null
order by 3,4;

SELECT * FROM `subtle-creek-380809.Covid.Vaccinations`
order by 3,4;

-- Select Data that we are going tp be using

SELECT location, date, total_cases, new_cases, total_deaths, population FROM `subtle-creek-380809.Covid.Deaths`
order by 1,2;

-- Looking at Total Deaths vs Total Cases 
-- Shows likelihood of dying if you contract covid in your location
SELECT location, date, total_cases, new_cases, total_deaths, Population, (total_deaths/total_cases)*100 as DeathPercentage
FROM `subtle-creek-380809.Covid.Deaths`
WHERE location like '%States%' and continent is not null
order by 1,2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, Population, (total_cases/population)*100 as PercentPopulation
FROM `subtle-creek-380809.covid.deaths`
WHERE location like '%States%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT location, Population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
FROM `subtle-creek-380809.covid.deaths`
-- WHERE location like '%States%'
group by location, population
order by PercentPopulationInfected desc;

-- Showing Countries with Highest Death Count per Population

SELECT location, max(Total_deaths) as TotalDeathCount
FROM `subtle-creek-380809.covid.deaths`
-- WHERE location like '%States%'
where continent is not null
group by location
order by TotalDeathCount desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT


-- Showing the continents with the highest death count per population

SELECT continent, max(Total_deaths) as TotalDeathCount
FROM `subtle-creek-380809.covid.deaths`
-- WHERE location like '%States%'
where continent is not null
group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
FROM `subtle-creek-380809.Covid.Deaths`
-- WHERE location like '%States%' 
where continent is not null
--group by date
order by 1,2;


-- Looking at Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,  (sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date)/population)*100 as VaccinatedPercentage
FROM subtle-creek-380809.Covid.Deaths dea
Join subtle-creek-380809.Covid.Vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2, 3


-- USE CTE

With PopvsVac
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM subtle-creek-380809.Covid.Deaths dea
Join subtle-creek-380809.Covid.Vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2, 3 
)
Select *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from PopvsVac


-- TEMP TABLE

CREATE TEMP Table PercentPopulationVaccinated
as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM subtle-creek-380809.Covid.Deaths dea
Join subtle-creek-380809.Covid.Vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null;
--order by 2, 3 

SELECT *, (RollingPeopleVaccinated/population)*100 as VaccinatedPercentage
from PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE OR REPLACE VIEW `subtle-creek-380809.Covid.PercentPopulationVaccinated` AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM subtle-creek-380809.Covid.Deaths dea
Join subtle-creek-380809.Covid.Vaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *
from `subtle-creek-380809.Covid.PercentPopulationVaccinated`