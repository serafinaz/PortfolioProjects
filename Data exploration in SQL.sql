SELECT *
FROM PortfolioProject..death
ORDER BY 3,4;

--SELECT *
--FROM PortfolioProject..vaccination
--ORDER BY 3,4

--select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths
FROM PortfolioProject..death
ORDER by 1,2;

-- total_cases vs total_death


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..death
WHERE total_cases != 0 and location like '%China%' and date > '2022-10-01'
ORDER by 4 DESC;

--icu_patients/total_cases
SELECT location, date, total_cases, icu_patients, (icu_patients/total_cases)*100 as severerate
FROM PortfolioProject..death
WHERE total_cases != 0 and location like '%China%' and date > '2022-10-01'
ORDER by 2;

--looking at the highest severe rate compare to population.
SELECT location, MAX(total_cases) as highestsevereCount, icu_patients, MAX(icu_patients/total_cases)*100 as maxsevererate
FROM PortfolioProject..death
WHERE total_cases != 0 and date > '2022-10-01'
GROUP BY PortfolioProject..death.location, icu_patients
ORDER by 2 DESC;

--showing the countries with the highest death count 
SELECT TOP 10 location, MAX(CAST(total_deaths AS INT)) as totaldeathcounts
FROM PortfolioProject..death
WHERE total_deaths != 0 and date > '2022-10-01' and continent != '0'
GROUP BY PortfolioProject..death.location
ORDER by 2 DESC;

-- Let's break things down by continent.
SELECT continent, MAX(CAST(total_deaths AS INT)) as totaldeathcounts
FROM PortfolioProject..death
WHERE total_deaths != 0 and date > '2022-10-01' and continent != '0'
GROUP BY continent
ORDER by 2 DESC;

-- Showing the continent with the highest death count per population.
SELECT continent, MAX(CAST(total_deaths AS INT)) as totaldeathcounts
FROM PortfolioProject..death
WHERE total_deaths != 0 and date > '2022-10-01' and continent != '0'
GROUP BY continent
ORDER by 2 DESC;

--global numbers
SELECT date, SUM(new_cases) AS TOTALCASES, SUM(new_deaths) AS TOTALDEATHS, SUM(new_deaths)/SUM(new_cases) AS per--, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..death
WHERE new_cases != 0 
--and location like '%China%' and date > '2022-10-01'
GROUP BY date
ORDER by 1,2 DESC;

--use vaccination table.
--looking at total_population vs total_vaccination

SELECT death.continent, death.[location], death.[date], death.population
, vaccination.new_vaccinations, SUM(vaccination.new_vaccinations) OVER (Partition by death.location
 ORDER BY death.location, death.date) as RollingPeopleVaccinated
 --， RollingPeopleVaccinated * population
FROM PortfolioProject..vaccination
JOIN PortfolioProject..death
    ON death.location = vaccination.location
    and death.date = vaccination.date
WHERE death.continent != '0'
ORDER BY 1,2,3;

--USE CTE
WITH PopvsVac(continent, location, date, population_density, New_vaccinations, RollingPeopleVaccinated)
AS (
    SELECT death.continent, death.[location], death.[date], death.population_density
    , vaccination.new_vaccinations, SUM(vaccination.new_vaccinations) OVER (Partition by death.location
    ORDER BY death.location, death.date) as RollingPeopleVaccinated
    FROM PortfolioProject..death
    JOIN PortfolioProject..vaccination
        ON death.location = vaccination.location
        and death.date = vaccination.date
    WHERE death.continent != '0'
)
SELECT *
FROM PopvsVac;

--TEMP TABLE
DROP TABLE IF EXISTS #Percentpopulationvaccinated
CREATE TABLE #Percentpopulationvaccinated
(
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    Population NUMERIC,
    NewVaccination NUMERIC,
    RollingPeopleVaccinated NUMERIC
)

INSERT INTO #Percentpopulationvaccinated
SELECT death.continent, death.[location], death.[date], death.population_density
    , vaccination.new_vaccinations, SUM(vaccination.new_vaccinations) OVER (Partition by death.location
    ORDER BY death.location, death.date) as RollingPeopleVaccinated
    FROM PortfolioProject..death
    JOIN PortfolioProject..vaccination
        ON death.location = vaccination.location
        and death.date = vaccination.date
    WHERE death.continent != '0'
SELECT *
FROM #Percentpopulationvaccinated;

--creating view to store data for later visualizations
CREATE VIEW Percentpopulationvaccinated AS
SELECT death.continent, death.[location], death.[date], death.population_density
    , vaccination.new_vaccinations, SUM(vaccination.new_vaccinations) OVER (Partition by death.location
    ORDER BY death.location, death.date) as RollingPeopleVaccinated
FROM PortfolioProject..death
JOIN PortfolioProject..vaccination
    ON death.location = vaccination.location
    and death.date = vaccination.date
WHERE death.continent != '0'

SELECT *
FROM Percentpopulationvaccinated
