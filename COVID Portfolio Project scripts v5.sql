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
		continent,
		date, 
		total_cases,
		new_cases, 
		total_deaths, 
		(total_deaths/total_cases)*100 as Death_Percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by Location, date

-- Highest Death Count Countries

Select	Location, 
		Max(cast(total_deaths as int)) as Total_Death_Count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location
order by Total_Death_Count desc

-- Total Cases vs Population

Select	Location, 
		date, 
		total_cases, 
		Population, 
		(total_cases/Population)*100 as Population_Infected_Percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by Location, date

-- Highest Infection Rate Countries

Select	continent,
		Location, 
		Max(total_cases) as Highest_Infection_count, 
		date,
		Population, 
		Max((total_cases/Population)*100) as Population_Infected_Percentage
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by Location, Population, date, continent
order by Population_Infected_Percentage desc



-- Highest Death Count Continents

Select	continent, 
		SUM(cast(new_deaths as int)) as Total_Death_Count
from PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by Total_Death_Count desc 

-- Global numbers (Daily)

;with GloNum as(
Select	date, 
		SUM(new_cases) as day_new_cases, 
		SUM(cast(new_deaths as int)) as day_new_deaths,
		SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage,
		Sum(SUM(new_cases)) over (order by date rows between unbounded preceding and CURRENT ROW) as daily_total_cases,
		Sum(SUM(cast(new_deaths as int))) over (order by date rows between unbounded preceding and CURRENT ROW) as daily_total_deaths
From PortfolioProject.dbo.CovidDeaths
Where continent is not null 
group by date
)

select	*,
		((daily_total_deaths)/daily_total_cases)*100 as DeathPercentage_Aggregate
from GloNum
order by date;

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