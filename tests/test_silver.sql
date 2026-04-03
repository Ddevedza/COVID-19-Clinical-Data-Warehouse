
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
-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.medications
SELECT COUNT(*) counted_bronze_rows FROM bronze.medications

-- Check if keys are not NULL
SELECT * 
FROM silver.medications
WHERE payer_id IS NULL or code IS NULL or patient_id IS NULL or encounter_id IS NULL

-- Check if there are unexpected duplicates
SELECT stop, base_cost,payer_id,code,patient_id,encounter_id,COUNT(*)
FROM silver.medications
GROUP BY start, stop, payer_id, base_cost,code,patient_id,encounter_id
HAVING COUNT(*)>1

-- Failed date conversions
SELECT COUNT(*) start_NULL_check FROM silver.medications WHERE start IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.medications WHERE start IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.medications WHERE start IS NOT NULL

-- Patients exist in silver
SELECT COUNT(*) FROM silver.medications m
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = m.patient_id
)

-- encounters exist in silver
SELECT COUNT(*) FROM silver.medications m
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = m.encounter_id
)

-- payer exist in silver
SELECT COUNT(*) FROM silver.medications m
WHERE NOT EXISTS (
    SELECT 1 FROM silver.payers p WHERE p.id = m.payer_id
)

-- Negative cost check
SELECT COUNT(*) FROM silver.medications
WHERE base_cost < 0 or payer_coverage<0 or dispenses<0 or totalcost<0

-- ========================
-- silver.observations
-- ========================

-- Row count check (Silver may differ from Bronze due to deduplication)
SELECT COUNT(*) counted_silver_rows FROM silver.observations
SELECT COUNT(*) counted_bronze_rows FROM bronze.observations

-- Critical NULL check (encounter_id NULLs are expected)
SELECT COUNT(*) FROM silver.observations WHERE patient_id IS NULL OR code IS NULL

-- Separately document expected NULL encounter_ids
SELECT COUNT(*) AS null_encounter_id_count
FROM silver.observations
WHERE encounter_id IS NULL

-- Duplicate check (dedup applied in Silver)
SELECT date, patient_id, encounter_id, code, value, units, type, COUNT(*)
FROM silver.observations
GROUP BY date, patient_id, encounter_id, code, value, units, type
HAVING COUNT(*) > 1

-- Failed date conversions
SELECT COUNT(*) date_NULL_check FROM silver.observations WHERE date IS NULL

-- FK orphan checks
SELECT COUNT(*) FROM silver.observations o
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = o.patient_id
)

-- Encounters exist (excluding expected NULLs)
SELECT COUNT(*) FROM silver.observations o
WHERE encounter_id IS NOT NULL
AND NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = o.encounter_id
)

-- Type domain validation
SELECT DISTINCT type FROM silver.observations
-- Expected: numeric, text
    
-- ========================
-- silver.organizations
-- ========================

-- Row count check
SELECT COUNT(*) counted_silver_rows FROM silver.organizations
SELECT COUNT(*) counted_bronze_rows FROM bronze.organizations

-- Check if keys are not NULL
SELECT * 
FROM silver.organizations
WHERE id IS NULL

-- Check if there are unexpected duplicates
SELECT id,COUNT(*)
FROM silver.organizations
GROUP BY id
HAVING COUNT(*)>1

-- Negative value check
SELECT COUNT(*) FROM silver.organizations
WHERE revenue < 0 OR utilization < 0

-- State data check
SELECT DISTINCT state 
FROM silver.organizations
ORDER BY state

-- Important columns check
SELECT COUNT(*) FROM silver.organizations
WHERE name IS NULL OR city IS NULL OR state IS NULL

-- Check for double spaces in name
SELECT id, REPLACE(TRIM(name), '  ', ' ') 
FROM silver.organizations
WHERE REPLACE(TRIM(name), '  ', ' ') LIKE '%  %'

-- ========================
-- silver.patients
-- ========================

-- Row count check
SELECT COUNT(*) counted_silver_rows FROM silver.patients
SELECT COUNT(*) counted_bronze_rows FROM bronze.patients

-- Check if keys are not NULL
SELECT * 
FROM silver.patients
WHERE id IS NULL

-- Check if there are unexpected duplicates
SELECT id,COUNT(*) AS key_duplicates
FROM silver.patients
GROUP BY id
HAVING COUNT(*)>1

-- Failed start date conversions
SELECT COUNT(*) birthdate_NULL_check FROM silver.patients WHERE birthdate IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.patients WHERE birthdate IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.patients WHERE birthdate IS NOT NULL

-- checks if birthdates are before deathdates
SELECT COUNT(*) FROM silver.patients
WHERE deathdate < birthdate

-- Gender column validity check
SELECT DISTINCT gender
FROM silver.patients

-- Ethnicity column validity check
SELECT DISTINCT ethnicity
FROM silver.patients

-- Ethnicity column validity check
SELECT DISTINCT marital
FROM silver.patients

-- value negativity check
SELECT healthcare_coverage,healthcare_expenses
FROM silver.patients
WHERE healthcare_coverage<0 or healthcare_expenses<0

-- Verify no numbers remain in names after Silver cleaning
SELECT COUNT(*) FROM silver.patients
WHERE first LIKE '%[0-9]%'
OR last LIKE '%[0-9]%'
OR maiden LIKE '%[0-9]%'
-- Expected: 0 rows

-- invalid deathdate (over the current date)
SELECT COUNT(*) FROM silver.patients
WHERE deathdate > GETDATE()

-- No one over 150 years old
SELECT COUNT(*) FROM silver.patients
WHERE DATEDIFF(YEAR, birthdate, GETDATE()) > 150

-- ========================
-- silver.payer_transitions
-- ========================

-- Checking if silver row count matches bronze
SELECT COUNT(*) counted_silver_rows FROM silver.payer_transitions
SELECT COUNT(*) counted_bronze_rows FROM bronze.payer_transitions

-- Check if keys are not NULL
SELECT * 
FROM silver.payer_transitions
WHERE patient_id IS NULL or payer_id IS NULL

-- Check if there are unexpected duplicates
SELECT patient_id,payer_id,start_year,COUNT(*) AS duplicate_count
FROM silver.payer_transitions
GROUP BY patient_id,payer_id,start_year
HAVING COUNT(*)>1

-- Failed start_year conversions
SELECT COUNT(*) start_NULL_check FROM silver.payer_transitions WHERE start_year IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_start FROM bronze.payer_transitions WHERE start_year IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.payer_transitions WHERE start_year IS NOT NULL
SELECT COUNT(*) counted_bronze_start FROM bronze.payer_transitions WHERE end_year IS NOT NULL
SELECT COUNT(*) counted_silver_start FROM silver.payer_transitions WHERE end_year IS NOT NULL

-- checks if stops are before start_year
SELECT COUNT(*) FROM silver.payer_transitions
WHERE end_year < start_year

-- Patients exist in silver
SELECT COUNT(*) FROM silver.payer_transitions pt
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients p WHERE p.id = pt.patient_id
)

-- Payers exist in silver
SELECT COUNT(*) FROM silver.payer_transitions pt
WHERE NOT EXISTS (
    SELECT 1 FROM silver.payers p WHERE p.id = pt.payer_id
)

-- Ownership domain validation
-- Note: some records have NULL ownership - Synthea generation artifact
SELECT DISTINCT ownership
FROM silver.payer_transitions
-- Expected: Self, Guardian, Spouse, NULL

-- ========================
-- silver.payers
-- ========================

-- Row count check
SELECT COUNT(*) counted_silver_rows FROM silver.payers
SELECT COUNT(*) counted_bronze_rows FROM bronze.payers

-- PK NULL check
SELECT COUNT(*) FROM silver.payers WHERE id IS NULL

-- Duplicate check
SELECT id, COUNT(*) AS duplicate_count
FROM silver.payers
GROUP BY id
HAVING COUNT(*) > 1

-- Name NULL check
SELECT COUNT(*) FROM silver.payers WHERE name IS NULL

-- Negative financial values
SELECT COUNT(*) FROM silver.payers
WHERE amount_covered < 0
OR amount_uncovered < 0
OR revenue < 0

-- Negative count columns
SELECT COUNT(*) FROM silver.payers
WHERE covered_encounters < 0
OR uncovered_encounters < 0
OR covered_medications < 0
OR uncovered_medications < 0
OR covered_procedures < 0
OR uncovered_procedures < 0
OR covered_immunizations < 0
OR uncovered_immunizations < 0

-- QOLS avg range check [0,1] - as stated before
-- Note: capped in Silver layer, should return 0 rows
SELECT COUNT(*) FROM silver.payers
WHERE qols_avg < 0 OR qols_avg > 1

-- State domain validation
SELECT DISTINCT state_headquartered
FROM silver.payers
ORDER BY state_headquartered

-- ========================
-- silver.procedures
-- ========================

-- Row count check
SELECT COUNT(*) counted_silver_rows FROM silver.procedures
SELECT COUNT(*) counted_bronze_rows FROM bronze.procedures

-- Composite key NULL check
SELECT COUNT(*) FROM silver.procedures
WHERE patient_id IS NULL OR encounter_id IS NULL OR code IS NULL

-- Duplicate check
SELECT date, patient_id, encounter_id, code, COUNT(*)
FROM silver.procedures
GROUP BY date, patient_id, encounter_id, code
HAVING COUNT(*) > 1

-- Failed date conversions
SELECT COUNT(*) date_NULL_check FROM silver.procedures WHERE date IS NULL

-- Compare non-null dates between bronze and silver
SELECT COUNT(*) counted_bronze_date FROM bronze.procedures WHERE date IS NOT NULL
SELECT COUNT(*) counted_silver_date FROM silver.procedures WHERE date IS NOT NULL

-- No future dates
SELECT COUNT(*) FROM silver.procedures
WHERE date > GETDATE()

-- Negative cost check
SELECT COUNT(*) FROM silver.procedures
WHERE base_cost < 0

-- FK orphan checks
SELECT COUNT(*) FROM silver.procedures p
WHERE NOT EXISTS (
    SELECT 1 FROM silver.patients pt WHERE pt.id = p.patient_id
)

SELECT COUNT(*) FROM silver.procedures p
WHERE NOT EXISTS (
    SELECT 1 FROM silver.encounters e WHERE e.id = p.encounter_id
)

-- ========================
-- silver.providers
-- ========================

-- Row count check
SELECT COUNT(*) counted_silver_rows FROM silver.providers
SELECT COUNT(*) counted_bronze_rows FROM bronze.providers

-- PK NULL check
SELECT COUNT(*) FROM silver.providers WHERE id IS NULL

-- Duplicate check
SELECT id, COUNT(*) AS duplicate_count
FROM silver.providers
GROUP BY id
HAVING COUNT(*) > 1

-- NULL check on important columns
SELECT COUNT(*) FROM silver.providers
WHERE name IS NULL OR specialty IS NULL OR organization_id IS NULL

-- FK orphan check - organization exists
SELECT COUNT(*) FROM silver.providers p
WHERE NOT EXISTS (
    SELECT 1 FROM silver.organizations o WHERE o.id = p.organization_id
)

-- Gender domain validation
SELECT DISTINCT gender FROM silver.providers

-- Specialty domain validation
SELECT DISTINCT specialty FROM silver.providers
ORDER BY specialty

-- State domain validation
SELECT DISTINCT state FROM silver.providers
ORDER BY state

-- Negative utilization check
SELECT COUNT(*) FROM silver.providers
WHERE utilization < 0

-- Name number cleaning verification
-- Expected: 0 rows after Silver cleaning
SELECT COUNT(*) FROM silver.providers
WHERE name LIKE '%[0-9]%'
