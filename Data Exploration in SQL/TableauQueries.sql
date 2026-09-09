/*
Queries used for Tableau Project
*/

SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
	SUM(CAST(new_deaths AS DECIMAL(18,4)))/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent <> ''
ORDER BY 1,2


SELECT location, SUM(new_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent = '' 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc


SELECT Location, Population, 
	MAX((CAST(total_cases AS DECIMAL(18,4))/NULLIF(population, 0)))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


SELECT Location, Population,date, MAX(total_cases) as HighestInfectionCount, 
	MAX((CAST(total_cases AS DECIMAL(18,4))/NULLIF(population, 0)))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population, date
ORDER BY PercentPopulationInfected desc