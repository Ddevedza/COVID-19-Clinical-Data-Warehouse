TRUNCATE TABLE silver.allergies;

INSERT INTO silver.allergies (
	start,
	stop,
	patient_id,
	encounter_id,
	code,
	description
	)
SELECT
	TRY_CAST(start as DATETIME) start, -- Turning data into date if possible
	TRY_CAST(stop as DATETIME) stop,
	TRIM(patient) patient_id,
	TRIM(encounter) encounter_id,
	TRIM(code) code,
	description
FROM bronze.allergies;

GO

TRUNCATE TABLE silver.careplans;

INSERT INTO silver.careplans (
	id,
	start,
	stop,
	patient_id,
	encounter_id,
	code,
	description,
	reasoncode,
	reasondescription
	)

SELECT 
	TRIM(id) id,
	TRY_CAST(start as DATETIME) start, -- Turning data into date if possible
	TRY_CAST(stop as DATETIME) stop,
	TRIM(patient) patient_id,
	TRIM(encounter) encounter_id,
	TRIM(code) code,
	description,
	TRIM(reasoncode) reasoncode,
	reasondescription
FROM bronze.careplans;

GO
	
TRUNCATE TABLE silver.conditions;

INSERT INTO silver.conditions (
	start,
	stop,
	patient_id,
	encounter_id,
	code,
	description
	)
SELECT
	TRY_CAST(start as DATETIME) start, -- Turning data into date if possible
	TRY_CAST(stop as DATETIME) stop,
	TRIM(patient) patient_id,
	TRIM(encounter) encounter_id,
	TRIM(code) code,
	description
FROM bronze.conditions;

GO

TRUNCATE TABLE silver.devices;

INSERT INTO silver.devices (
    start,
    stop,
    patient_id,
    encounter_id,
    code,
    description,
    udi
    )
SELECT
    TRY_CAST(start as DATETIME) start, -- Turning data into date if possible
    TRY_CAST(stop as DATETIME) stop,
    TRIM(patient) patient_id,
    TRIM(encounter) encounter_id,
    TRIM(code) code,
    description,
    TRIM(udi)
FROM bronze.devices;

GO

TRUNCATE TABLE silver.encounters;

INSERT INTO silver.encounters (
    id,
    start,
    stop,
    patient_id,
    organization_id,
    payer_id,
    provider_id,
    encounterclass,
    code,
    description,
    base_encounter_cost,
    total_claim_cost,
    payer_coverage,
    reasoncode,
    reasondescription
)
SELECT
    TRIM(id) AS id,
    TRY_CAST(start AS DATETIME) AS start,
    TRY_CAST(stop AS DATETIME) AS stop,
    TRIM(patient) AS patient_id,
    TRIM(organization) organization_id,
    TRIM(payer) payer_id,
    TRIM(provider) provider_id,
    LOWER(TRIM(encounterclass)) encounterclass,
    TRIM(code) AS code,
    description,
    base_encounter_cost,
    total_claim_cost,
    payer_coverage,
    TRIM(reasoncode) AS reasoncode,
    reasondescription
FROM bronze.encounters;

GO

TRUNCATE TABLE silver.imaging_studies;

INSERT INTO silver.imaging_studies (
    id,
    [date],
    patient_id,
    encounter_id,
    bodysite_code,
    bodysite_description,
    modality_code,
    modality_description,
    sop_code,
    sop_description
)
SELECT
    TRIM(id) AS id,
    TRY_CAST([date] AS DATETIME) AS [date],
    TRIM(patient) AS patient_id,
    TRIM(encounter) AS encounter_id,
    TRIM(bodysite_code) AS bodysite_code,
    TRIM(bodysite_description),
    TRIM(modality_code) AS modality_code,
    modality_description,
    TRIM(sop_code) AS sop_code,
    sop_description
FROM bronze.imaging_studies;

GO

TRUNCATE TABLE silver.immunizations;

INSERT INTO silver.immunizations (
    [date],
    patient_id,
    encounter_id,
    code,
    description,
    base_cost
)
SELECT
    TRY_CAST([date] AS DATE) AS [date],
    TRIM(patient) AS patient_id,
    TRIM(encounter) AS encounter_id,
    TRIM(code) AS code,
    description,
    base_cost
FROM bronze.immunizations;

GO

TRUNCATE TABLE silver.medications;

INSERT INTO silver.medications (
    start,
    stop,
    patient_id,
    payer_id,
    encounter_id,
    code,
    description,
    base_cost,
    payer_coverage,
    dispenses,
    totalcost,
    reasoncode,
    reasondescription
)

SELECT
    start,
    stop,
    patient_id,
    payer_id,
    encounter_id,
    code,
    description,
    base_cost,
    payer_coverage,
    dispenses,
    totalcost,
    reasoncode,
    reasondescription
FROM(
    SELECT
        CASE 
            WHEN TRY_CAST(stop AS DATETIME) < TRY_CAST(start AS DATETIME) THEN TRY_CAST(stop AS DATETIME)
            ELSE TRY_CAST(start AS DATETIME) 
        END AS start,
        CASE 
            WHEN TRY_CAST(stop AS DATETIME) < TRY_CAST(start AS DATETIME) THEN TRY_CAST(start AS DATETIME)
            ELSE TRY_CAST(stop AS DATETIME) 
        END AS stop,
        TRIM(patient) AS patient_id,
        TRIM(payer) AS payer_id,
        TRIM(encounter) AS encounter_id,
        TRIM(code) AS code,
        description,
        base_cost,
        payer_coverage,
        dispenses,
        totalcost,
        TRIM(reasoncode) AS reasoncode,
        reasondescription,
        -- Deduplication: where duplicate prescriptions exist for same patient/encounter/code/start,
        -- keep the record with the latest stop date
        ROW_NUMBER() OVER (
            PARTITION BY patient, encounter, code, start
            ORDER BY TRY_CAST(stop AS DATE) DESC
        ) AS rn
    FROM bronze.medications
) t
WHERE rn = 1

GO

TRUNCATE TABLE silver.observations;

-- Note: ~30k observations have NULL encounter_id
-- In Synthea these represent derived patient-level metrics,
-- administrative recordings, or generation artifacts
-- NULL encounter_id is preserved intentionally
INSERT INTO silver.observations (
    [date],
    patient_id,
    encounter_id,
    code,
    description,
    value,
    units,
    type
)
SELECT
    TRY_CAST([date] AS DATETIME) AS [date],
    TRIM(patient) AS patient_id,
    TRIM(encounter) AS encounter_id,
    TRIM(code) AS code,
    description,
    TRIM([value]) AS value,
    TRIM(units) AS units,
    TRIM([type]) AS type
    FROM (
        SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY date, patient, encounter, code, value, units, type
            ORDER BY (SELECT NULL)
        ) AS rn
        FROM bronze.observations)t
    WHERE rn<2 -- duplicated values are removed, as they are complete duplicates(achieved on the same date)
    -- they were completely removed

GO

TRUNCATE TABLE silver.organizations;

INSERT INTO silver.organizations (
    id,
    name,
    address,
    city,
    state,
    zip,
    lat,
    lon,
    phone,
    revenue,
    utilization
)
SELECT
    TRIM(id) AS id,
    name,
    address,
    city,
    TRIM(state),
    TRIM(zip) AS zip,
    lat,
    lon,
    TRIM(phone) AS phone,
    revenue,
    utilization
FROM bronze.organizations;

GO

TRUNCATE TABLE silver.patients;

INSERT INTO silver.patients (
    id,
    birthdate,
    deathdate,
    ssn,
    drivers,
    passport,
    prefix,
    first,
    last,
    suffix,
    maiden,
    marital,
    race,
    ethnicity,
    gender,
    birthplace,
    address,
    city,
    state,
    county,
    zip,
    lat,
    lon,
    healthcare_expenses,
    healthcare_coverage
)
SELECT
    TRIM(id) AS id,
    TRY_CAST(birthdate AS DATETIME) AS birthdate,
    TRY_CAST(deathdate AS DATETIME) AS deathdate,
    TRIM(ssn) AS ssn,
    TRIM(drivers) AS drivers,
    TRIM(passport) AS passport,
    TRIM(prefix) AS prefix,
    -- Remove trailing numbers from first, last  and maiden name
    CASE 
        WHEN PATINDEX('%[0-9]%', first) > 0 
        THEN LEFT(TRIM(first), PATINDEX('%[0-9]%', TRIM(first)) - 1)
        ELSE TRIM(first)
    END AS first,
    CASE 
        WHEN PATINDEX('%[0-9]%', last) > 0 
        THEN LEFT(TRIM(last), PATINDEX('%[0-9]%', TRIM(last)) - 1)
        ELSE TRIM(last)
    END AS last,
    TRIM(suffix) AS suffix,
    CASE 
        WHEN PATINDEX('%[0-9]%', maiden) > 0 
        THEN LEFT(TRIM(maiden), PATINDEX('%[0-9]%', TRIM(maiden)) - 1)
        ELSE TRIM(maiden)
    END AS maiden,
    TRIM(marital) AS marital,
    TRIM(race) AS race,
    TRIM(ethnicity),
    TRIM(gender) AS gender,
    birthplace,
    address,
    city,
    state,
    county,
    TRIM(zip) AS zip,
    lat,
    lon,
    healthcare_expenses,
    healthcare_coverage
FROM bronze.patients;

GO

TRUNCATE TABLE silver.payer_transitions;

INSERT INTO silver.payer_transitions (
    patient_id,
    start_year,
    end_year,
    payer_id,
    ownership
)
SELECT
    TRIM(patient) AS patient_id,
    start_year,
    end_year,
    TRIM(payer) AS payer_id,
    TRIM(ownership) AS ownership
FROM bronze.payer_transitions;
