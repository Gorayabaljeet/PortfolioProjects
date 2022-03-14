Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in New Zealand
Select Location, date, total_cases,  total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Zealand%'
and continent is not null
Order By 1,2

-- Looking at Toatl Cases vs Population
--Shows the perentage of Population got covid

Select Location, date, population, total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Zealand%'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to the Population
Select Location, population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Zealand%'
Where continent is not null
Group By Continent, Location, population
Order By PercentPopulationInfected desc 

--Showing Countries with Highest Death Count  per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Zealand%'
Where continent is not null
Group By continent, Location
Order By TotalDeathCount desc 

-- LET'S BREAK DOWN THING BY CONTINENT
-- Showing Continents with the highest death count per population 
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Zealand%'
Where continent is not null
Group By continent
Order By TotalDeathCount desc 


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_Cases, Sum(cast(new_deaths as int)) as total_deaths, Sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Zealand%'
Where continent is not null
--Group By date
Order By 1,2


--Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Order By 2,3


-- Use CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as

(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--Order By 2,3
	)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE

Drop Table If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--Order By 2,3
	

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later Visaulizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order By dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	--Order By 2,3

Select *
From PercentPopulationVaccinated