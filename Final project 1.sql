-- precentage of death--

select location,date,total_cases,total_deaths,(total_deaths / total_cases)*100 as DeathPrecnt
from CovidDeaths$
where location like '%egypt%'
order by 1,2

---------------------------------------------------------------------------------------------
--precentage of people that got covid--

select location,date,total_cases,population,(total_cases/ population)*100 as  people_got_infected
from CovidDeaths$
where location like '%states%'
order by 1,2

---------------------------------------------------------------------------------------------
--countries with highest infection rate compared to Population--

select location,population,MAX(total_cases) as highest_infection_count,MAX((total_cases/ population))*100 as  Precent_Population_infacted
from CovidDeaths$
--where location like '%states%'
group by location,population
order by Precent_Population_infacted desc

---------------------------------------------------------------------------------------------

--countries with highest death--
select location,MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc

---------------------------------------------------------------------------------------------

--continent with highest death--
select location,MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%states%'
where continent is null
group by location
order by totaldeathcount desc

---------------------------------------------------------------------------------------------

-- Showing contintents with the highest death count per population--
select continent,MAX(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%states%'
where continent is null
group by continent
order by totaldeathcount desc

---------------------------------------------------------------------------------------------
-- GLOBAL NUMBERS--

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

---------------------------------------------------------------------------------------------
--Total Population vs Vaccinations--

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3
---------------------------------------------------------------------------------------------
--use CTE--
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [protofolio project]..CovidDeaths$ dea
Join [protofolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
---------------------------------------------------------------------------------------------
-- Using Temp Table to perform Calculation on Partition By in previous query--
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [protofolio project]..CovidDeaths$  dea
Join [protofolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
---------------------------------------------------------------------------------------------
-- Creating View to store data for later visualizations--

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [protofolio project]..CovidDeaths$  dea
Join [protofolio project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select*
from PercentPopulationVaccinated
