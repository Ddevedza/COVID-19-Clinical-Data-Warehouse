GO

TRUNCATE TABLE gold.patients;

INSERT INTO gold.patients (
    patient_id,
	first_name,
	last_name,
    full_name,
    birthdate,
    deathdate,
    age,
    is_deceased,
    gender,
    race,
    ethnicity,
	marital_status,
    birthplace,
    address,
    city,
    state,
    county,
    zip,
    healthcare_expenses,
    healthcare_coverage
    )
SELECT
    id AS patient_id,
	first AS first_name,-- first name was split as to make it easier for analysts
	last AS last_name,
	ISNULL(first,'') + ' ' + ISNULL(last,'') AS full_name, -- full name
	birthdate,
	deathdate,
	DATEDIFF(YEAR, birthdate, -- difference between birthdate
		CASE 
			WHEN deathdate IS NOT NULL THEN deathdate -- and deathdate
			ELSE GETDATE()  -- or current date
		END
	) AS age, -- in order to calculate current age
	CASE -- creating flags 0/1 for alive and deceased patients
		WHEN deathdate IS NOT NULL THEN 1 
		ELSE 0
	END is_deceased,
	CASE
		WHEN LOWER(gender) IN ('f', 'female') THEN 'female' -- in case lower gender f or female, it is turned to female
		WHEN LOWER(gender) IN ('m', 'male') THEN 'male'
		ELSE 'unknown' -- unknown in any other case
	END AS gender,
	race,
	ethnicity,
	CASE 
		WHEN LOWER(marital) IN ('m', 'married') THEN 'married' -- married or m is turned to married
		WHEN LOWER(marital) IN ('s', 'single') THEN 'single'
		ELSE 'unknown'
	END AS marital_status,
    birthplace,
    address,
    city,
    state,
    county,
    zip,
    healthcare_expenses,
    healthcare_coverage
FROM silver.patients;
