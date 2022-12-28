-- Author: Emanuel de Almeida Alves
-- Date : 27/12/2022

-- Creating tables to paste Covid deaths CSV file

DROP TABLE if exists covidDeath;
CREATE TABLE covidDeath(
 iso_code VARCHAR(50),
 continent VARCHAR(50), 
 location VARCHAR(50),
 date DATE,
 population DOUBLE PRECISION,
 total_cases DOUBLE PRECISION,
 new_cases DOUBLE PRECISION,
 new_cases_smoothed DOUBLE PRECISION,
 total_deaths DOUBLE PRECISION,
 new_deaths DOUBLE PRECISION,
 new_deaths_smoothed DOUBLE PRECISION,
 total_cases_per_million DOUBLE PRECISION,
 new_cases_per_million DOUBLE PRECISION,
 new_cases_smoothed_per_million DOUBLE PRECISION,
 total_deaths_per_million DOUBLE PRECISION,
 new_deaths_per_million DOUBLE PRECISION,
 new_deaths_smoothed_per_million DOUBLE PRECISION,
 reproduction_rate DOUBLE PRECISION,
 icu_patients DOUBLE PRECISION,
 icu_patients_per_million DOUBLE PRECISION,
 hosp_patients DOUBLE PRECISION,
 hosp_patients_per_million DOUBLE PRECISION,
 weekly_icu_admissions DOUBLE PRECISION,
 weekly_icu_admissions_per_million DOUBLE PRECISION,
 weekly_hosp_admissions DOUBLE PRECISION,
 weekly_hosp_admissions_per_million DOUBLE PRECISION
);
-- Pasting CSV file in the table 
COPY covidDeath FROM 'C:\covidDeath.csv' DELIMITER ';' CSV HEADER;
--Testing
SELECT * FROM covidDeath;
--Creating tables to paste Covid Vacine CSV file
DROP TABLE if exists covidVacine;
CREATE TABLE covidVacine ( 
 iso_code VARCHAR(50),
 continent VARCHAR(500),
 location VARCHAR(50),
 date DATE,
 new_tests DOUBLE PRECISION,
 total_tests DOUBLE PRECISION,
 total_tests_per_thousand DOUBLE PRECISION,
 new_tests_per_thousand DOUBLE PRECISION,
 new_tests_smoothed DOUBLE PRECISION,
 new_tests_smoothed_per_thousand DOUBLE PRECISION,
 positive_rate DOUBLE PRECISION,
 tests_per_case DOUBLE PRECISION,
 tests_units VARCHAR(50),
 total_vaccinations DOUBLE PRECISION,
 people_vaccinated DOUBLE PRECISION,
 people_fully_vaccinated DOUBLE PRECISION,
 new_vaccinations DOUBLE PRECISION,
 new_vaccinations_smoothed DOUBLE PRECISION,
 total_vaccinations_per_hundred DOUBLE PRECISION,
 people_vaccinated_per_hundred DOUBLE PRECISION,
 people_fully_vaccinated_per_hundred DOUBLE PRECISION,
new_vaccinations_smoothed_per_million DOUBLE PRECISION,
stringency_index DOUBLE PRECISION,
population_density DOUBLE PRECISION,
median_age DOUBLE PRECISION,
aged_65_older DOUBLE PRECISION,
aged_70_older DOUBLE PRECISION,
gdp_per_capita DOUBLE PRECISION,
extreme_poverty DOUBLE PRECISION,
cardiovasc_death_rate DOUBLE PRECISION,
diabetes_prevalence DOUBLE PRECISION,
female_smokers DOUBLE PRECISION,
male_smokers DOUBLE PRECISION,
handwashing_facilities DOUBLE PRECISION,
hospital_beds_per_thousand DOUBLE PRECISION,
life_expectancy DOUBLE PRECISION,
human_development_index DOUBLE PRECISION

);
-- Pasting CSV file in the table
COPY covidVacine FROM 'C:\covidVacination.csv' DELIMITER ';' CSV HEADER;
-- Testing
SELECT * FROM covidVacine;

-- Selecting data that are going to be use
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covidDeath
ORDER BY 1,2;

--Looking at Total cases VS Total Deaths
SELECT Location,
       date,
       total_cases,
	   total_deaths,
	   (total_deaths/NULLIF(total_cases,0))*100 AS death_percentage 
FROM covidDeath
WHERE location LIKE 'Bra_il'
ORDER BY 1,2;

--Looking at Total cases vs Popularion
SELECT Location,
       date,
       Population,
	   total_cases,
       (total_cases/NULLIF(Population,0))*100 AS Percentage_infected_Population
FROM covidDeath
-- Filer for country( Brasil or Brazil )
WHERE location LIKE 'Bra_il'
ORDER BY 1,2;


-- JOIN data from vacine to death table 3
SELECT cD.continent, cD.location, cD.date, population, cV.new_vaccinations
FROM covidDeath AS cD
JOIN covidVacine AS cV
ON cV.location = cD.location
AND cV.date = cD.date

-- Create rollingVaccinated measures
WITH POP_ROLL_VAC(Continent, Location, Date, Population, New_vaccinations, Roll_percantege_vac)
AS
(
SELECT cD.continent, cD.location, cD.date, population, cV.new_vaccinations,
SUM(new_vaccinations) OVER(PARTITION BY cD.location ORDER BY cD.location,cD.date) AS Roll_percantege_vac
FROM covidDeath AS cD
JOIN covidVacine AS cV
ON cV.location = cD.location
AND cV.date = cD.date
WHERE cd.continent is not null
)

Select  *,(Roll_percantege_vac*100/Population) AS porcentage_Vaccinated
FROM POP_ROLL_VAC
order by 2,3

--Creatinga View for tableau 
CREATE VIEW PERCENTAGEPOPULATIONVACCINATED AS
SELECT cD.continent, cD.location, cD.date, population, cV.new_vaccinations,
SUM(new_vaccinations) OVER(PARTITION BY cD.location ORDER BY cD.location,cD.date) AS Roll_percantege_vac
FROM covidDeath AS cD
JOIN covidVacine AS cV
ON cV.location = cD.location
AND cV.date = cD.date
WHERE cd.continent is not null
