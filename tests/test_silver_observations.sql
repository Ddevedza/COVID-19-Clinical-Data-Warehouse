-- Date check
SELECT patient
FROM (SELECT patient, TRY_CAST([date] AS DATE) AS date
      FROM bronze.observations) t
WHERE date IS NULL

-- Duplicate check
-- This time we added description as the obseration can be done under two different descriptions/values
SELECT
	date,
	patient,
	encounter,
	code,
	description,
	value,
	COUNT(*) counted
FROM bronze.observations
GROUP BY date,patient,encounter,code, description, value
HAVING COUNT(*)>1

-- Note: NULL encounter_id is expected (~30k rows are patient-level observations)
-- Only flag NULL patient_id or code as genuine issues
SELECT patient, code
FROM bronze.observations
WHERE patient IS NULL OR code IS NULL

-- Unexpected spaces
SELECT
	patient,
	encounter,
	code
FROM bronze.observations
WHERE TRIM(patient) != patient or TRIM(encounter) != encounter or TRIM(code) != code or TRIM(type) != type

-- FK not existing keys check
SELECT patient
FROM bronze.observations
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter
FROM bronze.observations
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)
