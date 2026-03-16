-- FK checks
SELECT patient FROM bronze.procedures
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter FROM bronze.procedures
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

-- Composite key NULL check
SELECT patient, encounter, code
FROM bronze.procedures
WHERE patient IS NULL OR encounter IS NULL OR code IS NULL

-- Composite key uplicate check
SELECT date, patient, encounter, code, COUNT(*) counted
FROM bronze.procedures
GROUP BY date, patient,encounter,code
HAVING COUNT(*)>1

-- Value negative check
SELECT base_cost
FROM bronze.procedures
WHERE base_cost<0

-- Date casting check
SELECT patient
FROM (SELECT 
    patient,
    TRY_CAST([date] AS DATE) AS date
FROM bronze.procedures) t
WHERE date IS NULL

-- Future date check
SELECT patient, date
FROM bronze.procedures
WHERE TRY_CAST(date AS DATE) > GETDATE()
