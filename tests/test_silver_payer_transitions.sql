-- FK NULL check
SELECT 
	patient,
	payer
FROM bronze.payer_transitions
WHERE patient IS NULL or payer IS NULL

-- date check
SELECT patient
FROM bronze.payer_transitions
WHERE start_year>end_year

-- Unexpected spaces
SELECT patient,payer
FROM bronze.payer_transitions
WHERE TRIM(patient) != patient OR TRIM(payer) != payer

-- Duplicate check
SELECT patient, payer, start_year, COUNT(*) counted
FROM bronze.payer_transitions
GROUP BY patient, payer, start_year
HAVING COUNT(*) > 1

-- FK checks
SELECT patient FROM bronze.payer_transitions
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT payer FROM bronze.payer_transitions
WHERE payer NOT IN (SELECT id FROM bronze.payers)

-- Ownership domain validation (what values exist?)
SELECT DISTINCT ownership
FROM bronze.payer_transitions

-- Year sanity check (no unrealistic years)
SELECT patient, start_year, end_year
FROM bronze.payer_transitions
WHERE start_year < 1900 OR end_year > 2030

-- Coverage gap check (do a patient's coverage periods overlap?)
SELECT 
    a.patient,
    a.end_year,
    b.start_year
FROM bronze.payer_transitions a
JOIN bronze.payer_transitions b
    ON a.patient = b.patient
    AND a.payer != b.payer
    AND a.end_year > b.start_year
    AND a.start_year < b.start_year
