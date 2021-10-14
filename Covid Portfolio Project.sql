SELECT Location, date, total_cases, new_cases, total_deaths, population	
From CovidDeaths
where Continent is not null
order by 1,2;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country(United States)
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
WHERE location like '%states%' and Continent is not null
order by 1,2;

-- Total Cases vs Population
-- Shows What percentage of the Country's population got Covid(United States)

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_Pop
From CovidDeaths
WHERE location like '%states%' and Continent is not null
order by 1,2;

-- Filtered data to United States, Extracted Year from date, and sorted by date Ascending. 

SELECT Location, date, total_cases, total_deaths, (total_cases/population)*100 AS Percentage_of_Population_Infected,
EXTRACT(year FROM date) AS Year
From CovidDeaths
WHERE location like '%states%' and Continent is not null
order by date ASC;

-- Looking at Countries with Highest Infection Rate compared to the Population 

SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percentage_of_Population_Infected
From CovidDeaths
where Continent is not null
GROUP BY Location, Population
order by Percentage_of_Population_Infected DESC;

-- Showing Countries with the Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths AS DECIMAL)) As Total_Death_Count
From CovidDeaths
where Continent is not null
GROUP BY Location
order by Total_Death_Count DESC;

-- Lets break things down by continent

-- Showing Continent with the Highest Death Count per Population

SELECT Continent, MAX(cast(total_deaths AS DECIMAL)) As Total_Death_Count
From CovidDeaths
where Continent is not null
GROUP BY Continent
order by Total_Death_Count DESC;

-- Global Numbers 

SELECT Sum(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 As Death_Percentage
From CovidDeaths
WHERE Continent is not null
order by 1,2;

-- Looking at Total Population vs Vaccinations 

SELECT cov.continent, cov.location, cov.date, cov.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY cov.Location ORDER BY cov.Location, cov.date) as Rolling_People_Vaccinated
FROM CovidDeaths as cov
JOIN Vaccinations as vac
	ON cov.location = vac.location and cov.date = vac.date
WHERE cov.Continent is not null
order by 2,3;


-- Use CTE --> Common Table Expression

With PopVsVac(Continent, Location, date, Population, new_vaccinations, Rolling_People_Vaccinated)
as
(
SELECT cov.continent, cov.location, cov.date, cov.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY cov.Location ORDER BY cov.Location, cov.date) as Rolling_People_Vaccinated
FROM CovidDeaths as cov
JOIN Vaccinations as vac
	ON cov.location = vac.location and cov.date = vac.date
WHERE cov.Continent is not null
)
SELECT *, (Rolling_People_Vaccinated/Population)*100  
FROM PopVsVac;


-- Temp Table


DROP TABLE IF EXISTS Percent_Population_Vaccinated;
CREATE TEMPORARY TABLE Percent_Population_Vaccinated AS (SELECT cov.continent, cov.location, cov.date, cov.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY cov.Location ORDER BY cov.Location, cov.date) as Rolling_People_Vaccinated
FROM CovidDeaths as cov
JOIN Vaccinations as vac
	ON cov.location = vac.location and cov.date = vac.date
WHERE cov.Continent is not null);

SELECT *, (Rolling_People_Vaccinated/Population)*100  
FROM Percent_Population_Vaccinated;


-- Creating Views to store data for later visualations

CREATE View Percent_Population_Vaccinated AS
SELECT cov.continent, cov.location, cov.date, cov.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY cov.Location ORDER BY cov.Location, cov.date) as Rolling_People_Vaccinated
FROM CovidDeaths as cov
JOIN Vaccinations as vac
	ON cov.location = vac.location and cov.date = vac.date
WHERE cov.Continent is not NULL;

CREATE View Highest_Death_Count_Per_Continent_Population AS
SELECT Continent, MAX(cast(total_deaths AS DECIMAL)) As Total_Death_Count
From CovidDeaths
where Continent is not null
GROUP BY Continent
order by Total_Death_Count DESC;

CREATE View Highest_Death_Count_Per_Countries_Population AS
SELECT Location, MAX(cast(total_deaths AS DECIMAL)) As Total_Death_Count
From CovidDeaths
where Continent is not null
GROUP BY Location
order by Total_Death_Count DESC;

CREATE View Countries_Infection_Rate_Compared_to_Population AS
SELECT Location, Population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percentage_of_Population_Infected
From CovidDeaths
where Continent is not null
GROUP BY Location, Population
order by Percentage_of_Population_Infected DESC;

CREATE View Country_Covid_Specifics AS
SELECT Location, date, total_cases, new_cases, total_deaths, population	
From CovidDeaths
where Continent is not null
order by 1,2;

CREATE View United_States_Death_Percentage AS
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths
WHERE location like '%states%' and Continent is not null
order by 1,2;

CREATE View United_States_Percentage_of_Pop AS
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_Pop
From CovidDeaths
WHERE location like '%states%' and Continent is not null
order by 1,2;