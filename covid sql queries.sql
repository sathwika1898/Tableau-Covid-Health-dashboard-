SELECT * FROM
PROJECT1..covidDeaths
ORDER BY 3,4

--SELECT * FROM
--PROJECT1..covidVaccinations
--ORDER BY 3,4
SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION
FROM
PROJECT1..covidDeaths
ORDER BY 1,2

---LOOKING AT TOTAL_CASES VS tOTAL_DEATHS---

SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,
(CONVERT(DECIMAL(18,3),TOTAL_DEATHS)/NULLIF(CONVERT(DECIMAL(18,3),(TOTAL_CASES)),0))*100 AS DEATHPERCENTAGE
FROM
PROJECT1..covidDeaths
WHERE 
ISNUMERIC(TOTAL_CASES) = 1 AND ISNUMERIC(TOTAL_DEATHS) = 1 AND LOCATION LIKE '%INDIA%'
ORDER BY 1,2


---LOOKING AT TOTAL_CASES VS tOTAL_DEATHS---
---SHOW  WHAT PERCENTAGE OF PEOPLE GOT COVID

SELECT LOCATION,DATE,POPULATION,TOTAL_CASES,
(CONVERT(DECIMAL(15,3),TOTAL_CASES)/POPULATION)*100 AS PEOPLEINFECTEDPOPULATION
FROM
PROJECT1..covidDeaths
WHERE 
ISNUMERIC(TOTAL_CASES) = 1 AND ISNUMERIC(TOTAL_DEATHS) = 1 AND LOCATION LIKE '%INDIA%'
ORDER BY 1,2


---LOOKING FOR HIGHEST CASES VS POPULATION


SELECT LOCATION,POPULATION,MAX(CAST(TOTAL_CASES AS BIGINT)) AS HIGHESTINFECTED,
MAX((CAST(TOTAL_CASES AS DECIMAL(15,3)) / CAST(POPULATION AS DECIMAL(15,3))) * 100) AS PEOPLEINFECTEDPOPULATION
FROM
PROJECT1..covidDeaths
WHERE 
ISNUMERIC(TOTAL_CASES) = 1 
GROUP BY LOCATION,POPULATION
ORDER BY 4 DESC

SELECT LOCATION,MAX(CAST(TOTAL_DEATHS AS BIGINT)) AS MAXDEATHS
FROM
project1..covidDeaths
WHERE CONTINENT IS NOT NULL AND continent <> ' '
GROUP BY LOCATION
ORDER BY 2 DESC


---LETS BREAKDOWN BY CONTINENTS

SELECT continent,MAX(CAST(TOTAL_DEATHS AS BIGINT)) AS MAXDEATHS
FROM
project1..covidDeaths
WHERE CONTINENT IS NOT NULL AND continent <> ' '
GROUP BY continent
ORDER BY 2 DESC


---GLOBAL NUMBERS

SELECT 
    DATE,
    SUM(CAST(NEW_CASES AS BIGINT)) AS TOTAL_CASES,
    SUM(CAST(NEW_DEATHS AS BIGINT)) AS TOTAL_DEATHS,
    (SUM(CAST(NEW_DEATHS AS DECIMAL(15,5)))/NULLIF(SUM(CAST(NEW_CASES AS DECIMAL(15,5))),0))*100 AS DEATH_PERCENTAGE
	---(SUM(CAST(NEW_DEATHS AS BIGINT))/NULLIF(SUM(CAST(NEW_CASES AS BIGINT)),0))*100 AS DEATH_PERCENTAGE
FROM 
    project1..covidDeaths
WHERE 
    CONTINENT IS NOT NULL 
    AND CONTINENT <> ' '
	AND ISNUMERIC(NEW_CASES) = 1 AND ISNUMERIC(NEW_DEATHS) = 1
GROUP BY 
    DATE
ORDER BY 
    1,2;

---joining both the tables

select * from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date


---looking at total population vs new vaccination


select dea.continent,dea.location,dea.date ,new_vaccinations from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date
	where dea.continent <> ' '
order by 1,2


select dea.continent,dea.location,population,dea.date ,new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date
	where dea.continent <> ' '
order by 1,2

---use cte

with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date ,population,new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date
	where dea.continent <> ' '
)
select *,
(cast(rollingpeoplevaccinated as decimal(15,5))/cast(population as decimal(15,5)))*100 as percentageofvaccination
from popvsvac



select dea.location,sum(cast(new_vaccinations as bigint)) from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date
	where dea.continent <> ' '

group by dea.location

order by 1

---temp tables

drop table if exists peoplevaccinated
create table peoplevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
rollingpeoplevaccinated bigint
)

insert into peoplevaccinated
select dea.continent,dea.location,dea.date ,population,new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date
	WHERE 
    dea.continent <> ' '
    AND ISDATE(dea.date) = 1  -- Filter valid dates
    AND ISDATE(vac.date) = 1;

select *,
(cast(rollingpeoplevaccinated as decimal(15,5))/cast(population as decimal(15,5)))*100 as percentageofvaccination
from peoplevaccinated


---creating views

create View  peoplevaccination as
select dea.continent,dea.location,dea.date ,population,new_vaccinations,
sum(cast(new_vaccinations as bigint)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated

from 
project1..covidDeaths as dea
join project1..covidVaccinations as vac
on
	dea.location=vac.location and
	dea.date=vac.date
	where dea.continent <> ' '


SELECT *
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_NAME = 'peoplevaccination';

SELECT *
FROM peoplevaccination;
