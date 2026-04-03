
-- ========================
-- silver.allergies
-- ========================
-- Checking if silver row count matches bronze
SELECT COUNT(*) FROM silver.allergies
SELECT COUNT(*) FROM bronze.allergies

-- Check if keys are not NULL
SELECT * 
FROM silver.allergies
WHERE patient_id IS NULL or code IS NULL or encounter_id IS NULL

-- Check if there are unexpected duplicates
SELECT code,encounter_id,patient_id,COUNT(*)
FROM silver.allergies
GROUP BY code,encounter_id,patient_id
HAVING COUNT(*)>1

-- Check for failed date conversions
SELECT COUNT(*) FROM silver.allergies
WHERE start IS NULL
AND start IS NOT NULL  -- was not null in bronze

-- Simpler approach:
SELECT COUNT(*) FROM bronze.allergies WHERE start IS NOT NULL
SELECT COUNT(*) FROM silver.allergies WHERE start IS NOT NULL
-- Both should match

-- ========================
-- silver.careplans
-- ========================
-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.careplans
SELECT COUNT(*) counted_bronze_rows FROM bronze.careplans

-- Check if keys are not NULL
SELECT * 
FROM silver.careplans
WHERE id IS NULL or encounter_id IS NULL or patient_id IS NULL or code IS NULL

-- Check if there are unexpected duplicates
SELECT id,COUNT(*)
FROM silver.careplans
GROUP BY id
HAVING COUNT(*)>1

-- Failed start date conversions
SELECT COUNT(*) FROM silver.careplans WHERE start IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.careplans WHERE start IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.careplans WHERE start IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.careplans c
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = c.patient_id
)

-- Encounters exist in silver
SELECT COUNT(*) FROM silver.careplans c
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = c.encounter_id
)
-- checls if stops are before start
SELECT COUNT(*) FROM silver.careplans
WHERE stop < start

-- ========================
-- silver.conditions
-- ========================

-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.conditions
SELECT COUNT(*) counted_bronze_rows FROM bronze.conditions

-- Check if keys are not NULL
SELECT * 
FROM silver.careplans
WHERE encounter_id IS NULL or patient_id IS NULL or code IS NULL

-- Check if there are unexpected duplicates
SELECT encounter_id,patient_id,code,COUNT(*)
FROM silver.conditions
GROUP BY encounter_id,patient_id,code
HAVING COUNT(*)>1

-- Failed start date conversions
SELECT COUNT(*) FROM silver.conditions WHERE start IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.conditions WHERE start IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.conditions WHERE start IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.conditions c
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = c.patient_id
)

-- Encounters exist in silver
SELECT COUNT(*) FROM silver.conditions c
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = c.encounter_id
)
-- checls if stops are before start
SELECT COUNT(*) FROM silver.conditions
WHERE stop < start

-- ========================
-- silver.devices
-- ========================
-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.devices
SELECT COUNT(*) counted_bronze_rows FROM bronze.devices

-- Check if keys are not NULL
SELECT * 
FROM silver.devices
WHERE encounter_id IS NULL or patient_id IS NULL or code IS NULL

-- Check if there are unexpected duplicates
SELECT encounter_id,patient_id,code,COUNT(*)
FROM silver.devices
GROUP BY encounter_id,patient_id,code
HAVING COUNT(*)>1

-- Failed start date conversions
SELECT COUNT(*) FROM silver.devices WHERE start IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.devices WHERE start IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.devices WHERE start IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.devices d
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = d.patient_id
)

-- Encounters exist in silver
SELECT COUNT(*) FROM silver.devices d
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = d.encounter_id
)
-- checls if stops are before start
SELECT COUNT(*) FROM silver.devices
WHERE stop < start

-- ========================
-- silver.encounters
-- ========================
-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.encounters
SELECT COUNT(*) counted_bronze_rows FROM bronze.encounters

-- Check if keys are not NULL
SELECT * 
FROM silver.encounters
WHERE id IS NULL or patient_id IS NULL or organization_id IS NULL or payer_id IS NULL or provider_id IS NULL

-- Check if there are unexpected duplicates
SELECT id,COUNT(*)
FROM silver.encounters
GROUP BY id
HAVING COUNT(*)>1

-- Failed start date conversions
SELECT COUNT(*) start_NULL_check FROM silver.encounters WHERE start IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.encounters WHERE start IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.encounters WHERE start IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.encounters e
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = e.patient_id
)

-- Payers exist in silver
SELECT COUNT(*) FROM silver.encounters e
WHERE NOT EXISTS (
    SELECT 1 FROM silver.payers p WHERE p.id = e.payer_id
)

-- Providers exist in silver
SELECT COUNT(*) FROM silver.encounters e
WHERE NOT EXISTS (
    SELECT 1 FROM silver.providers p WHERE p.id = e.provider_id
)

-- Organizations exist in silver
SELECT COUNT(*) FROM silver.encounters e
WHERE NOT EXISTS (
    SELECT 1 FROM silver.organizations o WHERE o.id = e.organization_id
)
-- checls if stops are before start
SELECT COUNT(*) FROM silver.encounters
WHERE stop < start

-- ========================
-- silver.imaging_studies
-- ========================

-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.imaging_studies
SELECT COUNT(*) counted_bronze_rows FROM bronze.imaging_studies

-- Check if keys are not NULL
SELECT * 
FROM silver.imaging_studies
WHERE id IS NULL or patient_id IS NULL or encounter_id IS NULL

-- Check if there are unexpected duplicates
SELECT id,COUNT(*)
FROM silver.imaging_studies
GROUP BY id
HAVING COUNT(*)>1

-- Failed date conversions
SELECT COUNT(*) start_NULL_check FROM silver.imaging_studies WHERE date IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.imaging_studies WHERE date IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.imaging_studies WHERE date IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.imaging_studies i
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = i.patient_id
)

-- encounters exist in silver
SELECT COUNT(*) FROM silver.imaging_studies i
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = i.encounter_id
)

-- Distinct modality codes (domain validation)
SELECT DISTINCT modality_code FROM silver.imaging_studies
ORDER BY modality_code

-- ========================
-- silver.immunizations
-- ========================
-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.immunizations
SELECT COUNT(*) counted_bronze_rows FROM bronze.immunizations

-- Check if keys are not NULL
SELECT * 
FROM silver.immunizations
WHERE code IS NULL or patient_id IS NULL or encounter_id IS NULL

-- Check if there are unexpected duplicates
SELECT encounter_id,patient_id,code,COUNT(*)
FROM silver.immunizations
GROUP BY encounter_id,patient_id,code
HAVING COUNT(*)>1

-- Failed date conversions
SELECT COUNT(*) start_NULL_check FROM silver.immunizations WHERE date IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.immunizations WHERE date IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.immunizations WHERE date IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.immunizations i
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = i.patient_id
)

-- encounters exist in silver
SELECT COUNT(*) FROM silver.immunizations i
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = i.encounter_id
)

-- Negative cost check
SELECT COUNT(*) FROM silver.immunizations
WHERE base_cost < 0

-- ========================
-- silver.medications
-- ========================

-- ========================
-- silver.observations
-- ========================

-- ========================
-- silver.organizations
-- ========================

-- ========================
-- silver.patients
-- ========================

-- ========================
-- silver.payer_transitions
-- ========================

-- ========================
-- silver.payers
-- ========================

-- ========================
-- silver.procedures
-- ========================

-- ========================
-- silver.providers
-- ========================
