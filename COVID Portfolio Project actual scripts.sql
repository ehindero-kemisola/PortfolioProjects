Select *
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

-- Select Data that we are going to be using

Select Location, Date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent IS NOT NULL
Order By 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location = 'Nigeria'
And continent IS NOT NULL
Order By 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, Date, Population, total_cases, (total_cases/population)*100 AS PercentPopulatinInfected
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Order By 1,2



-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulatinInfected
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Group By Location, Population, Continent
Order By PercentPopulatinInfected DESC


--LET'S BREAK THINGS DOWN BY CONTINENT



-- Showing continents with the Highest death count per population
Select continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent IS NOT NULL
Group By continent
Order By TotalDeathCount DESC




-- GLOBAL NUMBERS

Select date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent IS NOT NULL
Group By date
Order By 1,2

Select SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location = 'Nigeria'
Where continent IS NOT NULL
--Group By date
Order By 1,2


-- Looking at Total Population vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
Order By 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
--Order By 2,3
)
Select *, (RollingPeopleVaccinated)*100
From PopvsVac



-- TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
--Where dea.continent IS NOT NULL
--Order By 2,3

Select *, (RollingPeopleVaccinated)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition By dea.Location Order By dea.location, dea.Date) AS RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
Where dea.continent IS NOT NULL
--Order By 2,3


Select *
From PercentPopulationVaccinated
