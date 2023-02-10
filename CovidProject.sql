SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

-- Select Data that we are going ot be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Looking Total Cases vs Total Deaths (Peru)

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Peru'
ORDER BY 1, 2;


-- Looking Total Cases vs Population

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 2) AS InfectPercentage
FROM CovidDeaths
WHERE location = 'Peru'
ORDER BY 1, 2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 2)) AS InfectPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC;


-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC;

-- By Continent

SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY 2 DESC;

/*
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC;
*/


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100, 2) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1;

-- TOTAL 
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100, 2) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1;

-- Looking Total Population vs Vaccinations

SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
FROM CovidDeaths AS d
JOIN CovidVaccs AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;

/*
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.date) AS TotalVaccinations
FROM CovidDeaths AS d
JOIN CovidDeaths AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2, 3;
*/

-- Using CTE

WITH t1 as (SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.date) AS TotalVaccinations
FROM CovidDeaths AS d
JOIN CovidDeaths AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL)

SELECT *, ROUND((TotalVaccinations/population)*100, 2) AS PercentageVaccination
FROM t1;

-- Using Temp Table

DROP TABLE IF EXISTS #PercentPopVacc
CREATE TABLE #PercentPopVacc (
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	TotalVaccinations numeric
);

INSERT INTO #PercentPopVacc
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.date) AS TotalVaccinations
FROM CovidDeaths AS d
JOIN CovidDeaths AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL;

SELECT *, ROUND((TotalVaccinations/population)*100, 2) AS PercentageVaccination
FROM #PercentPopVacc
ORDER BY 2, 3;


-- CREATING VIEWS (store data for later visualizations)
GO 
CREATE OR ALTER VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.date) AS TotalVaccinations
FROM CovidDeaths AS d
JOIN CovidDeaths AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL;
GO

SELECT *
FROM PercentPopulationVaccinated;

GO
CREATE OR ALTER VIEW PercentDeathGlobal AS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, ROUND((SUM(CAST(new_deaths AS INT))/SUM(new_cases))*100, 2) AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date;
GO

SELECT *
FROM PercentDeathGlobal
ORDER BY 1;

GO 
CREATE OR ALTER VIEW InfectionRateGLobal AS
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(ROUND((total_cases/population)*100, 2)) AS InfectPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
GO 

SELECT *
FROM InfectionRateGLobal
ORDER BY 4 DESC;