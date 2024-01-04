select * from [Study Case]..CovidDeaths
where continent is not null
order by 3,4;

select * from [Study Case]..CovidVaccinations
order by 3,4;

--Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from [Study Case]..CovidDeaths
order by 1,2

-- looking at total cases vs total deaths 
-- shows deaths pct by covid in Indonesia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Study Case]..CovidDeaths
where location like '%indonesia%'
and continent is not null
order by 1,2

-- looking at Total Cases vs Population
-- shows what percentage of population got covid in Indonesia 
select location, date, population, total_cases, (total_cases/population)*100 as CovidPercentage
from [Study Case]..CovidDeaths
where location like '%indonesia%'
and continent is not null
order by 1,2

-- what country with the highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PctPopulationInfected
from [Study Case]..CovidDeaths
where continent is not null
group by location, population
order by PctPopulationInfected desc


-- Showing countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Study Case]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Study Case]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Study Case]..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- looking at total population vs vaccinations
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from [Study Case]..CovidDeaths dea
join [Study Case]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
lovation nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated 
from [Study Case]..CovidDeaths dea
join [Study Case]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated  
from [Study Case]..CovidDeaths dea
join [Study Case]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select * from PercentPopulationVaccinated