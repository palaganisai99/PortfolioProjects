select * from PortfolioProject.dbo.coviddeaths
order by 3,4

-- select * from PortfolioProject.dbo.covidvaccinations
-- order by 3,4

-- select the data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject.dbo.CovidDeaths

-- Looking at Total cases vs Total Deaths
-- show likelohood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
where location = 'Canada'
order by 1,2

-- Looking at Total cases vs Population
-- show what percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected 
from PortfolioProject.dbo.CovidDeaths
where location = 'Canada'
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location,population,max(total_cases)as highestinfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
group by location,population
order by PercentPopulationInfected DESC

-- showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is not null
group by location
order by TotalDeathCount DESC

-- lets break things by continent

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- showing continents with the highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Global Numbers

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage--,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location = 'Canada'
where continent is not null
--group by date
order by 1,2


-- Looking at Total population vs Vaccinations

select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject.dbo.CovidDeaths dea
join PortfolioProject.dbo.CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac(Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as decimal)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date, dea.population,vac.new_vaccinations
,sum(cast(new_vaccinations as decimal)) over (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated