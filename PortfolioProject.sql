select * from PortfolioProject..CovidDeaths order by 3,4
select * from PortfolioProject..CovidVaccinations order by 3,4

--Selecting the needed data
Select Location, date, total_cases, new_cases, total_deaths , population 
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at the total cases vs the total deaths 
Select Location, date, total_cases, total_deaths , (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population has gotten covid 
Select Location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%nigeria%'
order by 1,2

--Looking at Countries with Highest Infected Rates Compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAx((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
group by population, location
order by PercentPopulationInfected desc

-- Showing Countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--showing the continent with the highest count per population 
Select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by Continent
order by TotalDeathCount desc
-- OR
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by Location
order by TotalDeathCount desc

--Global Cases
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date 
order by 1,2

-- Looking at Total Population vs Vacination 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- OR 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccination/Population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE's 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccination/Population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population) * 100
from PopvsVac

-- Using Temp Tables 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated (
Continent nvarChar(255),
Location nvarChar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric,
)
Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccination/Population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select * , (RollingPeopleVaccinated/Population) * 100
from #PercentPopulationVaccinated

-- Creating Views to store data for later visualizations.
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations,
SUM(CONVERT(int, dea.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccination/Population) * 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from PercentPopulationVaccinated