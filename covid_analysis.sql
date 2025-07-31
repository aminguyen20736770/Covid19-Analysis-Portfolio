-- Select all data from CovidDeaths
select * 
from [COVID Portfolio Project]..CovidDeaths


-- Select Data that I am going to be using
select location, date, total_cases, new_cases, total_deaths, population 
from [COVID Portfolio Project]..CovidDeaths
where continent is not null
order by 1,2


-- Comparison between Total Cases and Total Deaths in Australia
-- Showing the likelihood of death if you contract COVID in Australia
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [COVID Portfolio Project]..CovidDeaths
where location = 'Australia'
and continent is not null
order by 1,2


-- Looking at the Total Cases vs Population in Australia
-- Showing how many percentage of the population in Australia got COVID
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from [COVID Portfolio Project]..CovidDeaths
where location = 'Australia'
order by 1,2


-- Looking at which country has the highest infection rate compared to population
select location, MAX(total_cases) as HighestCount, population, MAX((total_cases/population))*100 as InfectionPercentage
from [COVID Portfolio Project]..CovidDeaths
group by location, population
order by InfectionPercentage desc


-- Looking at countries with the highest death count per population
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from [COVID Portfolio Project]..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc
-- I added the clause 'where continent is not null' so that the result does not show continents as a whole and only countries


-- Looking at continents with the highest death count per population
-- Now I only want to look at continents and not location (countries)
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from [COVID Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Looking at global numbers showing total cases, total deaths and death percentage globally
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as TotalDeathCount
from [COVID Portfolio Project]..CovidDeaths
where continent is not null


-- Select all data from CovidVaccinations
select * 
from [COVID Portfolio Project]..CovidVaccinations

-- Join 2 tables together on locationa and date - CovidDeaths and CovidVaccinations
select * 
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 


-- Looking at Total Population vs Vaccinations
-- Showing numbers of people in the world that got vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


-- Practice using CTE (Common Table Expression)
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
)
select * from PopvsVac


-- Showing percentage of rolling people vaccinated vs population
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


-- Temp Table
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vacciantions numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating view to store data for visualisation
Create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

Create view PopulationVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from [COVID Portfolio Project]..CovidDeaths dea
join [COVID Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null

Create view Australia_DeathPercentage as 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [COVID Portfolio Project]..CovidDeaths
where location = 'Australia'
and continent is not null

Create view Australia_TotalcasesvsPopulation as
select location, date, total_cases, population, (total_cases/population)*100 as PopulationPercentage
from [COVID Portfolio Project]..CovidDeaths
where location = 'Australia'