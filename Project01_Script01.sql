--SELECT *
--FROM PortfolioProject01..[COVID Deaths]
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject01..[COVID Vaccinations]
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject01..[COVID Deaths]
WHERE continent is not null
ORDER BY 1,2


-- TOTAL CASES VS TOTAL DEATHS
-- Likelihood of dying if contracted COVID in Peru

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject01..[COVID Deaths]
WHERE location = 'Peru' and continent is not null
ORDER BY 1,2


-- TOTAL CASES VS POPULATION
-- Shows what percentage of pupulation got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject01..[COVID Deaths]
WHERE location = 'Peru' and continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject01..[COVID Deaths]
--WHERE location = 'Peru'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing countries with highest death count by population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject01..[COVID Deaths]
--WHERE location = 'Peru'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Break down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject01..[COVID Deaths]
--WHERE location = 'Peru'
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount desc


--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject01..[COVID Deaths]
--WHERE location = 'Peru' 
WHERE continent is not null 
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject01..[COVID Deaths] dea
join PortfolioProject01..[COVID Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject01..[COVID Deaths] dea
join PortfolioProject01..[COVID Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject01..[COVID Deaths] dea
join PortfolioProject01..[COVID Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent is not null
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




--Creating View to store data for later visualisations

create view  PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location,
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject01..[COVID Deaths] dea
join PortfolioProject01..[COVID Vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--order by 2,3