Select *
From PortfolioProject..CovidVaccinations
Where continent is not null
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.. CovidDeaths
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Show likelihood of dying if you contract covid in your country
Select Location, date, population, total_cases, total_deaths,  (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))*100 as Death_Percentage
From PortfolioProject.. CovidDeaths
Where location like '%philippines%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, date, population, total_cases,  (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 as Population_Infected_Percentage
From PortfolioProject.. CovidDeaths
--Where location like '%philippines%'
Where continent is not null
order by 1,2

-- Looking at countries with highest infection rate compared to Population
Select Location, population, Max(total_cases) as Highest_Infection_Count,  Max(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population),0))*100 as Population_Infected_Percentage
From PortfolioProject.. CovidDeaths
--Where location like '%philippines%'
Where continent is not null
group by Location, population
order by Population_Infected_Percentage desc


-- Showing Countries with Highest Death Count per Population
Select Location, population, Max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject.. CovidDeaths
--Where location like '%philippines%'
Where continent is not null
group by Location, population
order by Total_Death_Count desc


-- BREAK THINGS DOWN BY CONTINENT


-- Showing the continent with the highest death count per population 
Select continent, Max(cast(total_deaths as int)) as Total_Death_Count
From PortfolioProject.. CovidDeaths
--Where location like '%philippines%'
Where continent is not null
group by continent
order by Total_Death_Count desc



-- GLOBAL NUMBERS

-- Daily Global percentage of covid death 
Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (CONVERT(float, SUM(new_deaths)) / NULLIF(CONVERT(float, SUM(new_cases)),0))*100 as Death_Percentage
From PortfolioProject.. CovidDeaths
--Where location like '%philippines%'
Where continent is not null
Group By date
order by 1,2

-- Total Global percentage of covid death 
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (CONVERT(float, SUM(new_deaths)) / NULLIF(CONVERT(float, SUM(new_cases)),0))*100 as Death_Percentage
From PortfolioProject.. CovidDeaths
--Where location like '%philippines%'
Where continent is not null
--Group By date


-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Max_People_Vaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- CTE (Common Table Expression)
With PopvsVac (continent, location, date, population, new_vaccinations, Max_People_Vaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Max_People_Vaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
Select *, (Max_People_Vaccinated/population)*100
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
Max_People_Vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Max_People_Vaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
-- order by 2,3

Select *, (Max_People_Vaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as Max_People_Vaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated