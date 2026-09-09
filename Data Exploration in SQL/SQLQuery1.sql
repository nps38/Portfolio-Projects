SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- Total Cases vs Total Deaths (US) - Likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (CAST(total_deaths AS DECIMAL(18,4))/NULLIF(total_cases, 0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent <> ''
ORDER BY 1,2


-- Total Cases vs Total Population (US) - % of population that got Covid
SELECT location, date, total_cases, population, (CAST(total_cases AS DECIMAL(18,4))/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' and continent <> ''
ORDER BY 1,2


-- Countries with Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, 
	MAX((CAST(total_cases AS DECIMAL(18,4))/NULLIF(population, 0)))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP BY location
ORDER BY TotalDeathCount desc


-- Continent with Highest Death Count per Population
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Death Percentage Overtime
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
	SUM(CAST(new_deaths AS DECIMAL(18,4)))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
GROUP BY date
ORDER BY 1,2


-- Global Death Percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
	SUM(CAST(new_deaths AS DECIMAL(18,4)))/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
ORDER BY 1,2


-- Total Population vs Vaccinations (CTE)
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingCount)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''
)
SELECT *, (CAST(RollingCount AS DECIMAL(18,4))/NULLIF(Population, 0))*100
FROM PopVsVac


-- Total Population vs Vaccinations (Temp Table)
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingCount numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''

SELECT *, (CAST(RollingCount AS DECIMAL(18,4))/NULLIF(Population, 0))*100
FROM PercentPopulationVaccinated


-- Create View for Visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCount
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent <> ''

SELECT *
FROM PercentPopulationVaccinatedView