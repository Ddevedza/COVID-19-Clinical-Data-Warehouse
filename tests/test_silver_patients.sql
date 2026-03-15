-- PK NULL check
SELECT id
FROM bronze.patients
WHERE id IS NULL

-- duplicate check
SELECT 
	id, 
	COUNT(*) counted
FROM bronze.patients
GROUP BY id
HAVING COUNT(*) > 1

-- date check
SELECT
id,
birthdate
FROM bronze.patients
WHERE TRY_CAST(birthdate AS DATE) > TRY_CAST(deathdate AS DATE)
OR birthdate IS NULL

-- negative/unexpected values
SELECT
id,
healthcare_coverage,
healthcare_expenses
FROM bronze.patients
WHERE healthcare_expenses<healthcare_coverage or healthcare_coverage<0 or healthcare_expenses<0

-- Unexpected spaces
SELECT id, first, last
FROM bronze.patients
WHERE TRIM(id) != id OR TRIM(first) != first OR TRIM(last) != last	

-- Gender domain validation (should only be M or F)
SELECT DISTINCT gender
FROM bronze.patients

-- Marital status domain validation
SELECT DISTINCT marital
FROM bronze.patients

-- Race and ethnicity domain validation
SELECT DISTINCT race FROM bronze.patients
SELECT DISTINCT ethnicity FROM bronze.patients

-- Deathdate NULL check (how many patients are alive vs dead)
SELECT
    COUNT(*) AS total,
    SUM(CASE WHEN deathdate IS NULL THEN 1 ELSE 0 END) AS alive,
    SUM(CASE WHEN deathdate IS NOT NULL THEN 1 ELSE 0 END) AS deceased
FROM bronze.patients

-- Age sanity check (no one should be over 150 years old)
SELECT id, birthdate
FROM bronze.patients
WHERE TRY_CAST(birthdate AS DATE) < DATEADD(YEAR, -150, GETDATE())

-- State domain validation
SELECT DISTINCT state
FROM bronze.patients
ORDER BY state
