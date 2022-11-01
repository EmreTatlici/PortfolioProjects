select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;


--Select data that we are going to be using



SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2;




--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;




--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT Location, date, population ,total_cases, (total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
ORDER BY 1,2;





--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, population ,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC





--LET'S BREAK THINGS DOWN BY CONTINENT
--Showing the continents with the highest death count per population
SELECT continent as Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;





--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100
as DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2;



--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3;



--USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac






--TEMP TABLE	
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null;
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated





--Creating View to store data for later visualizations
CREATE View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY
dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null;
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated