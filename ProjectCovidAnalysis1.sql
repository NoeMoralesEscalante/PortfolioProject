select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at Total Cases Vs Total Deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRate
from CovidDeaths
where location like '%olombia%'
order by 2

--Convert Column from Varchar to Numeric and Float

ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float;

ALTER TABLE CovidDeaths
ALTER COLUMN population float;

ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations numeric;

--Looking at the Total Cases vs Population

select location, date, population, total_cases, (total_cases/population)*100 as InfectionRate
from CovidDeaths
where location like '%olombia%'
order by 1,2


--Looking at countries with Highest Infection Rate Compare to population

select location, population, max(total_cases) as HighestTotalCases, max((total_cases/population))*100 as InfectionRate
from CovidDeaths
group by location, population
order by 4 desc

--Showing the countries with the Highest Death count per Population

select location, MAX(Total_Deaths) as TotalDeaths
from CovidDeaths
where continent is not null
group by location
order by 2 desc

--Lets break thigns down by continent

select continent, MAX(Total_Deaths) as TotalDeaths
from CovidDeaths
where continent is not null
group by continent
order by 2 desc

--Showing the cotinent with the Highest death count per population

select continent, population, max(total_deaths) as HighestTotalCases, max((total_deaths/population))*100 as DeathRate
from CovidDeaths
where continent is not null
group by continent, population
order by 4 desc

--Global Numbers

select date, sum(new_cases) as TotalCases, SUM(new_deaths) as TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null and new_cases > 0
group by date
order by 1, 2

--Looking at Total Population Vs Vaccinatations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopVsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 
from PopVsVac


--Temp Table

drop table if exists #PercentPeopleVaccinated
create table #PercentPeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPeopleVaccinated


--Create View to Store  data for later visualizations

create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPeopleVaccinated
