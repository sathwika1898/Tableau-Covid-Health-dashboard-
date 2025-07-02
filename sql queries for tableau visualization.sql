

---for tableau
---total death percentage

SELECT 
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
ORDER BY 
    1,2;


---2
select * from project1..covidDeaths

select location,sum(cast(new_deaths as bigint)) as TotalDeathCount
from project1..covidDeaths
where continent = '' and 
location not in ('world','European Union (27)','international','High-income countries','Upper-middle-income countries',
'Lower-middle-income countries','Low-income countries')
group by location
order by TotalDeathCount desc


---3

SELECT LOCATION,POPULATION,MAX(CAST(TOTAL_CASES AS BIGINT)) AS HIGHESTINFECTED,
MAX((CAST(TOTAL_CASES AS DECIMAL(15,3)) / CAST(POPULATION AS DECIMAL(15,3))) * 100) AS PEOPLEINFECTEDPOPULATION
FROM
PROJECT1..covidDeaths
WHERE 
ISNUMERIC(TOTAL_CASES) = 1 
GROUP BY LOCATION,POPULATION
ORDER BY 4 DESC


---4
SELECT LOCATION,POPULATION,DATE,MAX(CAST(TOTAL_CASES AS BIGINT)) AS HIGHESTINFECTED,
MAX((CAST(TOTAL_CASES AS DECIMAL(15,3)) / CAST(POPULATION AS DECIMAL(15,3))) * 100) AS PEOPLEINFECTEDPOPULATION
FROM
PROJECT1..covidDeaths
WHERE 
ISNUMERIC(TOTAL_CASES) = 1 and
continent != ' '
GROUP BY LOCATION,POPULATION,date
ORDER BY 4 DESC