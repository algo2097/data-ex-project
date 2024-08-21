select * 
from [dbo].[CovidDeaths]
where continent is not null
order by 3,4


---
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2


--- Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from dbo.CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--- Looking at the total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as casesPercentage
from dbo.CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--- Looking at countries with highest infection rate

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population)*100) as MaxInfectionPercentage
from dbo.CovidDeaths
where continent is not null
group by location, population
order by MaxInfectionPercentage desc

--- Continents with highest death count per population

select continent,max(cast(total_deaths as int)) as HighestDeathCount
from dbo.CovidDeaths
where continent is not null
group by continent
order by HighestDeathCount  desc

--- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/
	sum(new_cases)*100 as deathPercentage
from dbo.CovidDeaths
where continent is not null
group by date
order by 1,2


--- Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--- Use of CTEs

with PopVsVacc (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

)
select *, (rollingPeopleVaccinated/population)*100 from PopVsVacc


--- Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (rollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated



--- Creating view to store data for later

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location
order by dea.location, dea.date) as rollingPeopleVaccinated
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated
