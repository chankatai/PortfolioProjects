-- CovidDeaths overview

Select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by Location, date

-- Select data to be starting

Select	Location, 
		date, 
		total_cases, 
		new_cases, 
		total_deaths, 
		population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by Location, date

-- Total Cases vs Total Deaths

Select	Location, 
		date, 
		total_cases,
		new_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject.dbo.CovidDeaths
Where location like 'Hong Kong'
order by Location, date

-- Total Cases vs Population

Select	Location, 
		date, 
		total_cases, 
		Population, 
		(total_cases/Population)*100 as Population_Infected_Percentage
from PortfolioProject.dbo.CovidDeaths
Where location like 'Hong Kong'
order by Location, date

-- Highest Infection Rate Countries

Select	Location, 
		Max(total_cases) as Highest_Infection_count, 
		Population, 
		Max((total_cases/Population)*100) as Population_Infected_Percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location, Population
order by Population_Infected_Percentage desc

-- Highest Death Count Countries

Select	Location, 
		Max(cast(total_deaths as int)) as Highest_Death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location
order by Highest_Death_count desc

-- Highest Death Count Continents

Select	continent, 
		Max(cast(total_deaths as int)) as Highest_Death_count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by Highest_Death_count desc 


-- Global numbers (Daily)

Select	date, 
		SUM(new_cases) as day_new_cases, 
		SUM(cast(new_deaths as int)) as day_new_deaths
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
group by date
order by date

-- Global numbers (Aggregate)

Select	SUM(new_cases) as total_cases, 
		SUM(cast(new_deaths as int)) as total_deaths, 
		SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 


-- Population vs Vaccinations(vaccinations, people_vaccinated and people_fully_vaccinated)
-- CTE


;With PopvsVac (continent, location, date, population, new_vaccinations, total_vaccinations, people_vaccinated, people_fully_vaccinated)
as
(
Select	cd.continent,
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as BIGINT)) over (partition by cd.location order by cd.location, cd.date) as total_vaccinations,
		cv.people_vaccinated,
		cv.people_fully_vaccinated
From PortfolioProject.dbo.CovidDeaths cd
Join PortfolioProject.dbo.CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
-- order by location, date
)
Select	*, 
		(total_vaccinations/population) * 100 as Vaccinations_People_Percentage, 
		(people_vaccinated/population) * 100 as people_vaccinated_Percentage, 
		(people_fully_vaccinated/population) * 100 as people_fully_vaccinated
from PopvsVac

-- Crate View

Create View Population_Vaccinated_Percentage as
Select	cd.continent,
		cd.location, 
		cd.date, 
		cd.population, 
		cv.new_vaccinations,
		SUM(cast(cv.new_vaccinations as BIGINT)) over (partition by cd.location order by cd.location, cd.date) as total_vaccinations,
		cv.people_vaccinated,
		cv.people_fully_vaccinated
From PortfolioProject.dbo.CovidDeaths cd
Join PortfolioProject.dbo.CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
-- order by location, date

Select * from Population_Vaccinated_Percentage