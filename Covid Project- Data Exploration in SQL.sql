SELECT *
FROM [Portfolio Project]..[CovidDeaths]
where continent is not null and date like '%2023%'
order by 4 desc

SELECT *
FROM [Portfolio Project]..[CovidVaccinations]
where continent is not null and date like '%2023%'
order by 4 desc

ALTER TABLE [Portfolio Project]..[CovidDeaths] ALTER COLUMN total_deaths FLOAT;
ALTER TABLE [Portfolio Project]..[CovidDeaths] ALTER COLUMN total_cases FLOAT;

--Likely to be dying who are infected with covid
Select location, date, total_cases,new_cases,total_deaths,population, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..[CovidDeaths]
Where location like '%states%' and date like '%2023%'
and continent is not null 
order by 1,2 desc

-- Shows what percentage of population infected with Covid

Select location, date,total_cases,new_cases,total_deaths,population, (total_cases/population)*100 as DeathPercentage
From [Portfolio Project]..[CovidDeaths]
Where location like '%states%' and date like '%2023%'
and continent is not null 
order by DeathPercentage desc

--Looking at highest infected population based on the location
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases /population)*100 as PopulationInfectedPercentage 
From [Portfolio Project]..[CovidDeaths] 
Where continent is not null and date like '%2022%' OR date LIKE '%2023%'
Group by location,population
Order by PopulationInfectedPercentage desc


--Showing Countries with highest death count per population

Select location, MAX(total_deaths) as Totaldeathcount 
From [Portfolio Project]..[CovidDeaths] 
where continent not in ('World', 'High income','Upper middle income') and date like'%2023%'
Group by location
Order by Totaldeathcount desc

-- Breaking things down by continent
Select continent, MAX(cast(Total_deaths as int)) as TotaldeathCount
From [Portfolio Project]..[CovidDeaths]
where continent is not null and date like'%2023%'
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..[CovidDeaths]
--Where location like '%states%'
where continent is not null and date like'%2023%'
--Group By continent
--order by 1,2

--Looking at Total population vs Vaccinations
With PopVsVaccination (Continent, location, date, POPULATION, new_vaccinations, RollingPeopleVaccinated)
AS (
Select d.continent,d.location,d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as d
Join [Portfolio Project]..CovidVaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null and d.date like '%2023%'
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVaccination


--Creating a temporary table
Create Table PopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PopulationVaccinated
Select d.continent,d.location,d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as d
Join [Portfolio Project]..CovidVaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null and d.date like '%2023%'
--order by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopulationVaccinated

-- Creating View to store data for later visualizations
Create View PopulationVaccinated AS
Select d.continent,d.location,d.date, d.population, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (Partition by d.location Order by d.location, d.date) as RollingPeopleVaccinated
from [Portfolio Project]..CovidDeaths as d
Join [Portfolio Project]..CovidVaccinations as v
on d.location = v.location and d.date = v.date
where d.continent is not null and d.date like '%2023%'

Select * 
FROM PopulationVaccinated
