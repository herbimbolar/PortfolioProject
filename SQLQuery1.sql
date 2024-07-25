SELECT *
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL

SELECT *
FROM portfolioproject..covidvaccinations
WHERE continent IS NOT NULL

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject..coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

SELECT date, SUM(cast(total_deaths as int)), SUM (cast(total_deaths as int)/population)*100 AS percentageinfecteddeaths
FROM portfolioproject..coviddeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentageinfectedcase
FROM portfolioproject..coviddeaths
WHERE LOCATION LIKE '%states%'
ORDER BY 1,2

SELECT location, population, max(total_cases) AS highestinfectioncount, max(total_cases/population)*100 AS percentageinfectedpopulation
FROM portfolioproject..coviddeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentageinfectedpopulation DESC

SELECT location, population, max(total_deaths) AS totaldeathcount
FROM portfolioproject..coviddeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY totaldeathcount DESC

SELECT location, population, max(cast(total_deaths as int)) AS totaltdeathcount
FROM portfolioproject..coviddeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY totaltdeathcount DESC

SELECT continent, max(cast(total_deaths as int)) AS totaldeathcount
FROM portfolioproject..coviddeaths
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC

SELECT date, SUM(cast(total_deaths as int)) AS total_deaths, SUM (cast(total_deaths as int)/population)*100 AS percentageinfecteddeaths
FROM portfolioproject..coviddeaths dea
--WHERE LOCATION LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT dea.continent, dea.location, dea.date, vac.new_vaccinations
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 1,2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY vac.location order by dea.location, dea.date) as Rolledvaccinations
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
      ON dea.location = vac.location
      and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolledvaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY vac.location order by dea.location, dea.date) as Rolledvaccinations
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
      ON dea.location = vac.location
      and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

SELECT *, (Rolledvaccinations/population)*100 
FROM PopvsVac

CREATE TABLE #PercentPopulationvsVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolledvaccinations numeric
)

INSERT INTO #PercentPopulationvsVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY vac.location order by dea.location, dea.date) as Rolledvaccinations
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
      ON dea.location = vac.location
      and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3

SELECT *, (Rolledvaccinations/population)*100 
FROM #PercentPopulationvsVaccinated

CREATE VIEW PopulationvsVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY vac.location order by dea.location, dea.date) as Rolledvaccinations
FROM portfolioproject..coviddeaths dea
JOIN portfolioproject..covidvaccinations vac
      ON dea.location = vac.location
      and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3





