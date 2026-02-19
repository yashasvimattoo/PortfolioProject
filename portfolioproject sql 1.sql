select * from deaths_clean
where continent is not null order by 3,4;
#select * from vacc_clean order by 3,4;
select location,date_fixed,total_cases,new_cases,total_deaths,population
from deaths_clean where continent is not null order by 1,2;
#SELECT date FROM deaths_clean LIMIT 5;
#date ko date format mei krne k liye
ALTER TABLE deaths_clean
ADD date_fixed DATE;
UPDATE deaths_clean
SET date_fixed = STR_TO_DATE(date, '%d-%m-%Y');
ALTER TABLE vacc_clean
ADD date_fixed DATE;
UPDATE vacc_clean
SET date_fixed = STR_TO_DATE(date, '%d-%m-%Y');
-- SELECT location, date_fixed
-- FROM deaths_clean
-- ORDER BY date_fixed;

-- looking at the total cases vs total deaths
-- shows likelihood of dying if u contract covid in states
select location,date_fixed,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from deaths_clean 
where location like '%states%'
and continent is not null 
order by 1,2;

-- looking at total cases vs population
-- shows what percentage of population got covid
select location,date_fixed,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from deaths_clean 
where location like '%states%'
order by 1,2;

-- looking at countries with highest infection rate compared to population
select location,population,MAX(total_cases) as HighestInfectionCount, 
MAX((total_cases/population))*100 as PercentPopulationInfected
from deaths_clean 
-- where location like '%states%'
group by location, population
order by PercentPopulationInfected desc;

-- countries with highest death count per population
select location, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount 
from deaths_clean 
-- where location like '%states%'
where continent is not null 
group by location
order by TotalDeathCount desc;
-- signed was used kyunki ye text mei th isko int datatype krna tha

-- LET'S BREAK THING DOWN BY CONTINENT
-- showing continents with highest death count per population

-- select location, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount 
-- from deaths_clean 
-- -- where location like '%states%'
-- where continent is null 
-- group by location
-- order by TotalDeathCount desc;
select continent, sum(cast(new_deaths as SIGNED))from deaths_clean where continent is not null
group by continent;

-- GLOBAL NUMBERS
-- daily total case aur death diye 
select date_fixed, SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths ,
SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
from deaths_clean 
-- where location like '%states%'
where continent is not null 
group by date_fixed
order by 1,2;
-- total case aur death diye 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as SIGNED)) as total_deaths ,
SUM(cast(new_deaths as SIGNED))/SUM(new_cases)*100 as DeathPercentage
from deaths_clean 
-- where location like '%states%'
where continent is not null 
-- group by date_fixed
order by 1,2;

-- looking at total population vs vaccinations
select  dea.continent, dea.location, dea.date_fixed , dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date_fixed) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from deaths_clean dea
join vacc_clean vac 
   on dea.location = vac.location
   and dea.date_fixed = vac.date_fixed
where dea.continent is not null
order by 2,3;  
-- use CTE
With PopvsVac( Continent, location, date_fixed, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select  dea.continent, dea.location, dea.date_fixed , dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS SIGNED)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date_fixed) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from deaths_clean dea
join vacc_clean vac 
   on dea.location = vac.location
   and dea.date_fixed = vac.date_fixed
where dea.continent is not null
-- order by 2,3
) 
select * ,(RollingPeopleVaccinated/Population)* 100
from PopvsVac;

-- temp tables

drop temporary table if exists PercentPopulationVaccinated1;
create temporary table PercentPopulationVaccinated1
(
Continent nvarchar(255),
location nvarchar(255),
date_fixed datetime,
population decimal,
New_vaccinations decimal,
RollingPeopleVaccinated decimal
);

insert into PercentPopulationVaccinated1
select  dea.continent, dea.location, dea.date_fixed , dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS decimal)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date_fixed) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from deaths_clean dea
join vacc_clean vac 
   on dea.location = vac.location
   and dea.date_fixed = vac.date_fixed;
-- where dea.continent is not null;
-- order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from PercentPopulationVaccinated1;

-- creating view to store data for later visualizations
Create view PercentPopulationVaccinated as
select  dea.continent, dea.location, dea.date_fixed , dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS decimal)) OVER (PARTITION BY dea.location order by 
dea.location, dea.date_fixed) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from deaths_clean dea
join vacc_clean vac 
   on dea.location = vac.location
   and dea.date_fixed = vac.date_fixed
where dea.continent is not null;
-- order by 2,3;

select * from PercentPopulationVaccinated;
