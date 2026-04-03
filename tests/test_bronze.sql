/*
=====================================================================
Test Suite: Bronze Layer
=====================================================================
Run these tests per table after executing: EXEC bronze.load_bronze
Purpose: Validate raw ingestion from CSV files into Bronze tables
And may offer us more information on what is needed to be cleaned in
silver layer
Expected: All row counts match CSV source files + more intel on the 
state of data
=====================================================================
*/

-- ========================
-- bronze.allergies
-- ========================
-- Duplicate check
SELECT
	patient,
	encounter,
	code,
	COUNT(*)
FROM bronze.allergies
GROUP BY patient,encounter,code
HAVING COUNT(*)>1

-- NULL check
SELECT
	patient,
	encounter,
	code
FROM bronze.allergies
WHERE patient IS NULL or encounter IS NULL or code IS NULL

-- Date casting check
SELECT
	start
FROM (SELECT
	TRY_CAST(start as DATE) start, -- Turning data into date if possible
	TRY_CAST(stop as DATE) stop
FROM bronze.allergies)t
WHERE start IS NULL

-- Unexpected spaces
SELECT
	patient,
	encounter,
	code
FROM bronze.allergies
WHERE TRIM(patient) != patient or TRIM(encounter) != encounter or TRIM(code) != code

-- FK not existing keys check
SELECT patient
FROM bronze.allergies
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter
FROM bronze.allergies
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

-- ========================
-- bronze.careplans
-- ========================
-- Date casting check
SELECT
	start
FROM (SELECT
	TRY_CAST(start as DATE) start, -- Turning data into date if possible
	TRY_CAST(stop as DATE) stop
FROM bronze.careplans)t
WHERE start IS NULL

-- Unexpected spaces
SELECT
	id,
	patient,
	encounter,
	code
FROM bronze.careplans
WHERE TRIM(id) != id or TRIM(patient) != patient or TRIM(encounter) != encounter or TRIM(code) != code

-- PK NULL check
SELECT
	id
FROM bronze.careplans
WHERE id IS NULL

-- Duplicate check
SELECT
	id,
	COUNT(*)
FROM bronze.careplans
GROUP BY id
HAVING COUNT(*)>1

-- FK not existing keys check
SELECT patient
FROM bronze.careplans
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter
FROM bronze.careplans
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

-- ========================
-- bronze.conditions
-- ========================
-- Date casting check
SELECT
	start
FROM (SELECT
	TRY_CAST(start as DATE) start, -- Turning data into date if possible
	TRY_CAST(stop as DATE) stop
FROM bronze.conditions)t
WHERE start IS NULL

-- Duplicate check
SELECT
	patient,
	encounter,
	code,
	COUNT(*)
FROM bronze.conditions
GROUP BY patient,encounter,code
HAVING COUNT(*)>1

-- Composite key NULL check
SELECT
	patient,
	encounter,
	code
FROM bronze.conditions
WHERE patient IS NULL or encounter IS NULL or code IS NULL

-- Date casting check
SELECT
	start
FROM (SELECT
	TRY_CAST(start as DATE) start, -- Turning data into date if possible
	TRY_CAST(stop as DATE) stop
FROM bronze.conditions)t
WHERE start IS NULL

-- Unexpected spaces
SELECT
	patient,
	encounter,
	code
FROM bronze.conditions
WHERE TRIM(patient) != patient or TRIM(encounter) != encounter or TRIM(code) != code

-- FK not existing keys check
SELECT patient
FROM bronze.conditions
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter
FROM bronze.conditions
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

-- ========================
-- bronze.devices
-- ========================
-- Duplicate check
SELECT
    patient,
    encounter,
    code,
    COUNT(*) counted_patients
FROM bronze.devices
GROUP BY patient,encounter,code
HAVING COUNT(*)>1
-- Composite key NULL check
SELECT
    patient,
    encounter,
    code
FROM bronze.devices
WHERE patient IS NULL or encounter IS NULL or code IS NULL
-- Date casting check
SELECT
    start
FROM (SELECT
    TRY_CAST(start as DATE) start, -- Turning data into date if possible
    TRY_CAST(stop as DATE) stop
FROM bronze.devices)t
WHERE start IS NULL
-- Unexpected spaces
SELECT
    patient,
    encounter,
    code
FROM bronze.devices
WHERE TRIM(patient) != patient or TRIM(encounter) != encounter or TRIM(code) != code
-- FK not existing keys check
SELECT patient
FROM bronze.devices
WHERE patient NOT IN (SELECT id FROM bronze.patients)
SELECT encounter
FROM bronze.devices
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

-- ========================
-- bronze.encounters
-- ========================
-- Date casting check
SELECT
    start
FROM (SELECT
    TRY_CAST(start as DATE) start, -- Turning data into date if possible
    TRY_CAST(stop as DATE) stop
FROM bronze.encounters)t
WHERE start IS NULL
    
-- Check for encounters where stop is before start
SELECT id, start, stop
FROM bronze.encounters
WHERE TRY_CAST(stop AS DATETIME)<TRY_CAST(start AS DATETIME)
    
-- Duplicate check
SELECT
    patient,
    id,
    COUNT(*) counted
FROM bronze.encounters
GROUP BY patient,id
HAVING COUNT(*)>1
    
-- Value check
SELECT DISTINCT encounterclass FROM bronze.encounters
    
-- Unexpected spaces
SELECT
    id,
    patient,
    code
FROM bronze.encounters
WHERE TRIM(patient) != patient or TRIM(id) != id or TRIM(code) != code or TRIM(encounterclass) != encounterclass or TRIM(reasoncode) != reasoncode or TRIM(organization) != organization

-- ========================
-- bronze.imaging_studies
-- ========================
-- PK NULL check
SELECT id FROM bronze.imaging_studies
WHERE id IS NULL
-- Duplicate check
SELECT
    patient,
    id,
    encounter,
    COUNT(*) counted
FROM bronze.imaging_studies
GROUP BY patient,id,encounter
HAVING COUNT(*)>1
-- Value check
SELECT DISTINCT bodysite_description FROM bronze.imaging_studies;
SELECT DISTINCT modality_code FROM bronze.imaging_studies;
SELECT DISTINCT modality_description FROM bronze.imaging_studies;
-- Date check
SELECT id
FROM (SELECT id, TRY_CAST([date] AS DATE) AS date
      FROM bronze.imaging_studies) t
WHERE date IS NULL
-- FK check
SELECT patient FROM bronze.imaging_studies
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter FROM bronze.imaging_studies
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)
-- Unexpected spaces
SELECT
    id,
    patient,
    encounter
FROM bronze.imaging_studies
WHERE TRIM(patient) != patient or TRIM(id) != id or TRIM(encounter) != encounter or TRIM(bodysite_code) != bodysite_code or TRIM(bodysite_description) != bodysite_description or TRIM(modality_code) != modality_code

-- ========================
-- bronze.immunizations
-- ========================
-- Date check
SELECT patient
FROM (SELECT patient, TRY_CAST([date] AS DATE) AS date
      FROM bronze.immunizations) t
WHERE date IS NULL

-- Duplicate check
SELECT
	patient,
	encounter,
	code,
	COUNT(*) counted
FROM bronze.immunizations
GROUP BY patient,encounter,code
HAVING COUNT(*)>1

-- NULL check
SELECT
	patient,
	encounter,
	code
FROM bronze.immunizations
WHERE patient IS NULL or encounter IS NULL or code IS NULL

-- Unexpected spaces
SELECT
	patient,
	encounter,
	code
FROM bronze.immunizations
WHERE TRIM(patient) != patient or TRIM(encounter) != encounter or TRIM(code) != code

-- FK not existing keys check
SELECT patient
FROM bronze.immunizations
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter
FROM bronze.immunizations
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

-- ========================
-- bronze.medications
-- ========================
-- Date casting check
SELECT
    start
FROM (SELECT
    TRY_CAST(start as DATE) start, -- Turning data into date if possible
    TRY_CAST(stop as DATE) stop
FROM bronze.medications)t
WHERE start IS NULL

-- Check for encounters where stop is before start
SELECT patient,start, stop
FROM bronze.medications
WHERE TRY_CAST(stop AS DATETIME)<TRY_CAST(start AS DATETIME)

SELECT 
    patient,
    CASE 
        WHEN TRY_CAST(stop AS DATETIME) < TRY_CAST(start AS DATETIME) THEN TRY_CAST(stop AS DATETIME)
        ELSE TRY_CAST(start AS DATETIME) 
    END AS start_date,
    CASE 
        WHEN TRY_CAST(stop AS DATETIME) < TRY_CAST(start AS DATETIME) THEN TRY_CAST(start AS DATETIME)
        ELSE TRY_CAST(stop AS DATETIME) 
    END AS stop_date
FROM bronze.medications;

-- Composite key NULL check
SELECT patient, encounter, code
FROM bronze.medications
WHERE patient IS NULL OR encounter IS NULL OR code IS NULL

-- Duplicate check
SELECT patient, encounter, code, start, COUNT(*)
FROM bronze.medications
GROUP BY patient, encounter, code, start
HAVING COUNT(*) > 1

-- Unexpected spaces
SELECT patient, encounter, code
FROM bronze.medications
WHERE TRIM(patient) != patient OR TRIM(encounter) != encounter OR TRIM(code) != code

-- FK checks
SELECT patient FROM bronze.medications
WHERE patient NOT IN (SELECT id FROM bronze.patients)

SELECT encounter FROM bronze.medications
WHERE encounter NOT IN (SELECT id FROM bronze.encounters)

SELECT payer FROM bronze.medications
WHERE payer NOT IN (SELECT id FROM bronze.payers)

-- Negative cost check (costs should never be negative)
SELECT patient, base_cost, payer_coverage, totalcost
FROM bronze.medications
WHERE base_cost < 0 OR payer_coverage < 0 OR totalcost < 0

-- Payer coverage exceeds total cost (shouldn't be possible)
SELECT patient, totalcost, payer_coverage
FROM bronze.medications
WHERE payer_coverage > totalcost

-- Dispenses should be positive
SELECT patient, dispenses
FROM bronze.medications
WHERE dispenses <= 0

-- ========================
-- bronze.pbservations
-- ========================
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

-- ========================
-- bronze.organizations
-- ========================
-- PK NULL check
SELECT id
FROM bronze.organizations
WHERE id IS NULL

-- Unwanted spaces check
SELECT id,state
FROM bronze.organizations
WHERE TRIM(id)!=id or TRIM(state)!=state or TRIM(zip)!=zip or TRIM(phone)!=phone

-- Duplicate check
SELECT id, COUNT(*)
FROM bronze.organizations
GROUP BY id
HAVING COUNT(*) > 1

-- Negative values check (revenue and utilization should be positive)
SELECT id, revenue, utilization
FROM bronze.organizations
WHERE revenue < 0 OR utilization < 0

-- Distinct states (sanity check - should all be valid US state codes)
SELECT DISTINCT state
FROM bronze.organizations
ORDER BY state

-- ========================
-- bronze.organizations
-- ========================

-- ========================
-- bronze.patients
-- ========================
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

-- ========================
-- bronze.payer_transactions
-- ========================
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

-- ========================
-- bronze.payers
-- ========================
-- FK NULL check
SELECT 
	id
FROM bronze.payers
WHERE id IS NULL

-- Duplicate check
SELECT id, COUNT(*)
FROM bronze.payers
GROUP BY id
HAVING COUNT(*) > 1

-- Unexpected spaces
SELECT id, name
FROM bronze.payers
WHERE TRIM(id) != id OR TRIM(state_headquartered) != state_headquartered OR TRIM(zip) != zip OR TRIM(phone) != phone

-- Negative financial values
SELECT id, name, amount_covered, amount_uncovered, revenue,
    covered_encounters, uncovered_encounters,
    covered_medications, uncovered_medications,
    covered_procedures, uncovered_procedures,
    covered_immunizations, uncovered_immunizations
FROM bronze.payers
WHERE amount_covered < 0 
OR amount_uncovered < 0 
OR revenue < 0
OR covered_encounters < 0 OR uncovered_encounters < 0
OR covered_medications < 0 OR uncovered_medications < 0
OR covered_procedures < 0 OR uncovered_procedures < 0
OR covered_immunizations < 0 OR uncovered_immunizations < 0

-- State domain validation
SELECT DISTINCT state_headquartered
FROM bronze.payers
ORDER BY state_headquartered


-- QOLS average sanity check (Quality of Life Score - should be between 0 and 1)
SELECT id, name, qols_avg
FROM bronze.payers
WHERE qols_avg < 0 OR qols_avg > 1

-- ========================
-- bronze.procedures
-- ========================
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

-- ========================
-- bronze.providers
-- ========================
-- PK Null Check
SELECT id
FROM bronze.providers
WHERE id IS NULL

-- PK duplicate check
SELECT id, COUNT(*) counted
FROM bronze.providers
GROUP BY id
HAVING COUNT(*)>1

-- FK check
SELECT organization FROM bronze.providers
WHERE organization NOT IN (SELECT id FROM bronze.organizations)

-- gender distinction column check
SELECT DISTINCT(gender)
FROM bronze.providers

-- specialty distinction column check
SELECT DISTINCT(specialty)
FROM bronze.providers

-- Space check
SELECT id
FROM bronze.providers
WHERE id!=TRIM(id) or organization!=TRIM(organization) or state!=TRIM(state) or zip!=TRIM(zip)

-- name string check
SELECT name
FROM bronze.providers
WHERE name LIKE '%[0-9]%';

-- Negative utilization check
SELECT id, utilization
FROM bronze.providers
WHERE utilization < 0

-- State domain validation
SELECT DISTINCT state
FROM bronze.providers
ORDER BY state
