Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4

--Select * 
--From PortfolioProject..CovidVaccination
--order by 3,4 


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country 

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Albania%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Albania%'
Where continent is not null
order by 1,2

--Looking at Countries with highest infection rate compared to popilation.

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Albania%'
Where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc


--Showing the Countries with the Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Albania%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

--Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
----Where location like '%Albania%'
--Where continent is null
--Group by location
--order by TotalDeathCount desc

--Showing the continent with the highest death count.

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Albania%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS


Select date, SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Albania%'
where continent is not null
Group by date
order by 1,2

--Total number of infected

Select  SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Albania%'
where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 


--Use CTE

With PopvsVac  (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)* 100
From PopvsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)* 100
From #PercentPopulationVaccinated