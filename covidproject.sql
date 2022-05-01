SELECT location, date, total_cases, total_deaths, population 
FROM coviddeath  
order by 1, 2;

-- looking at total cases vs. total deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM `coviddeath`  
where location = 'Canada' and continent is not null
order by 1, 2;

-- Looking at total cases vs. Population
-- Shows percentage of population got covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as casepercentage
FROM `coviddeath`  
where location = 'Canada' and continent is not null
order by 2, 3;

-- Looking at countries with highest infection rate compared to population

SELECT location, MAX(total_cases) as highest_infection, population, (max(total_cases)/population)*100 as percent_population_infected
FROM `coviddeath`  
where continent is not null
group by location, population
order by percent_population_infected DESC;

-- Showing countries with highest death count per population

SELECT location, MAX(total_deaths) as total_deaths_count, population, (MAX(total_deaths)/population)*100 as percent_population_died
FROM `coviddeath`  
where continent is not null AND location not in ('world', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
group by location, population
order by percent_population_died DESC;

-- Breaking down by continent
-- Showing continents with highest death count

SELECT location, max(total_deaths) as total_deaths_count
FROM coviddeath 
where continent is null and location not in ('World', 'High income', 'Low income', 'Upper middle income', 'lower middle income', 'international')
group by location
order by total_deaths_count DESC;

-- Showing Global Numbers

SELECT sum(new_cases) as cases, sum(new_deaths) as deaths, sum(new_deaths)/sum(new_cases)*100 AS death_percentage
FROM `coviddeath`   
where continent is not null;

-- Looking at total population vs vaccinations

with pplvac AS 
(
    Select 
        d.continent, 
        d.location, 
        d.date, 
        d.population, 
        v.new_vaccinations,
        sum(v.new_vaccinations) OVER (partition by d.location order by d.location, d.date) as rolling_people_vaccinated
    from `coviddeath` d
    join `covidvac` v
    on d.location = v.location and d.date = v.date
    where d.continent is not null
)
select *, (rolling_people_vaccinated/population)*100 AS vaccineused_vs_population
from pplvac
order by location