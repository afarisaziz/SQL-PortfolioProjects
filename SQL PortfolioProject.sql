Select *
From PortfolioProject..CovidDeaths
order by 3,4


-- Select Data that we are going to be starting with
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where location like 'Malaysia'
order by 1,2

-- Countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestCases, max((total_cases)/population)*100 as MaxInfectedPopulationPercentage
from PortfolioProject..CovidDeaths
--where location like 'Malaysia'
group by location, population
order by MaxInfectedPopulationPercentage desc


-- Countries with Highest Death Count per Population
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

-- Countries with Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
Where continent is not null
group by location
order by TotalDeathCount desc

--BREAKING DOWN TO CONTINENTS
--Showing continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases) as TotalCases, SUM(new_deaths) as TotalDeath, SUM(new_deaths)/SUM(new_cases)*100 as TotalDeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Population vs Vaccinations
-- Shows Percentage of Population that has received at least one Covid Vaccine

select dea.continent, dea.location, dea.date ,dea.population ,vac.new_vaccinations,
SUM(CAST(CONVERT(int,vac.new_vaccinations) AS bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Using CTE to perform Calculcation on Partition By in previous query

with PopVSVacs (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date ,dea.population ,vac.new_vaccinations,
SUM(CAST(CONVERT(int,vac.new_vaccinations) AS bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *,  (RollingPeopleVaccinated/population)*100 as VaccinatedPeoplePercentage from PopVSVacs
where (location like 'Malaysia' and New_Vaccinations is not null)
order by 2,3

--Using Temp Table to perform Calculation on Partition By in previos query

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date ,dea.population ,vac.new_vaccinations,
SUM(CAST(CONVERT(int,vac.new_vaccinations) AS bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *,  (RollingPeopleVaccinated/population)*100 as VaccinatedPeoplePercentage from #PercentPopulationVaccinated
where (location like 'Malaysia' and New_Vaccinations is not null)
order by 2,3

--creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date ,dea.population ,vac.new_vaccinations,
SUM(CAST(CONVERT(int,vac.new_vaccinations) AS bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated


