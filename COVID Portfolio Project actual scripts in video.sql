select *
from PortfolioProject..CovidDeaths$
where continent is not null 
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations$
--order by 3,4

-- Select Data that we are going to be using 



select Location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths$
where continent is not null 
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract the covid in your country 
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths$
where location like '%Australia%'
and continent is not null 
order by 1,2


-- Looking at Total cases vs Population 
-- Show what percentage of population got Covid 

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths$
-- where location like '%Australia%'
where continent is not null 
order by 1,2

-- Looking at Countries with HIghest Infection Rate compared to Population 

select Location, population, MAX(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from portfolioproject..CovidDeaths$
-- where location like '%Australia%'
group by Location, population
order by PercentPopulationInfected desc


-- Showing Countries with highest Death Count per Population 

select Location, MAX(cast (Total_deaths as int)) TotalDeathCount
from portfolioproject..CovidDeaths$
-- where location like '%Australia%'
where continent is not null 
group by Location, population
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 





-- Showing continent with the hightest death count per population 

select continent, MAX(cast (Total_deaths as int)) TotalDeathCount
from portfolioproject..CovidDeaths$
-- where location like '%Australia%'
where continent is not null 
group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(CAST(new_deaths as int)) as total_deaths, sum(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from portfolioproject..CovidDeaths$
--where location like '%Australia%'
where continent is not null 
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
,--(RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE 


DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- Creating view to store date for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date ) as RollingPeopleVaccinated
--(RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null 
--order by 2,3


select *
from percentpopulationvaccinated

