/*
=====================================================================
Stored Procedure: Load Gold Layer (Silver -> Gold)
=====================================================================
Creating batch loading for gold data. This procedure truncates and
reloads all gold tables from silver, applying:
    - Dimensional modeling (star schema)
    - Surrogate key generation (IDENTITY)
    - Derived columns (age, is_deceased, is_active, full_name)
    - Business logic standardization (gender, marital status)
    - Denormalization (provider + organization attributes combined)
    - Date dimension generation (1900-01-01 to 2100-12-31)

Load order:
    1. Dimensions (dim_date, dim_patient, dim_organization,
                   dim_provider, dim_payer)
    2. Fact tables (fact_encounter, fact_condition,
                    fact_observation, fact_medication, fact_procedure)
=====================================================================
*/

GO

INSERT INTO gold.dim_patient (
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
    first AS first_name,
    last AS last_name,
    -- Combining first and last into a single display name
    -- ISNULL handles edge cases where first or last is NULL
    ISNULL(first,'') + ' ' + ISNULL(last,'') AS full_name,
    birthdate,
    deathdate, -- NULL preserved intentionally (means alive)
    -- Age calculated at deathdate for deceased patients, otherwise today
    DATEDIFF(YEAR, birthdate,
        CASE
            WHEN deathdate IS NOT NULL THEN deathdate
            ELSE GETDATE()
        END
    ) AS age,
    -- Deceased flag: 1 = deceased, 0 = alive
    CASE
        WHEN deathdate IS NOT NULL THEN 1
        ELSE 0
    END AS is_deceased,
    -- Standardizing gender values from source
    CASE
        WHEN LOWER(gender) IN ('f', 'female') THEN 'female'
        WHEN LOWER(gender) IN ('m', 'male') THEN 'male'
        ELSE 'unknown'
    END AS gender,
    race,
    ethnicity,
    -- Standardizing marital status values from source
    CASE
        WHEN LOWER(marital) IN ('m', 'married') THEN 'married'
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

GO 

TRUNCATE TABLE gold.dim_organization;

INSERT INTO gold.dim_organization (
    organization_id,
	organization_name,
	organization_address,
	organization_city,
	organization_state,
	organization_zip,
	organization_phone,
	revenue,
	utilization
)

SELECT
	id as organization_id,
	name AS organization_name, -- aliased for clarity
	address AS organization_address,
	city AS organization_city,
	state AS organization_state,
	zip AS organization_zip,
	phone AS organization_phone,
	revenue, -- total organization revenue (kept for reference)
	utilization -- total encounter count at this organization
FROM silver.organizations

GO

TRUNCATE TABLE gold.dim_payer;

INSERT INTO gold.dim_payer (
    payer_id,
    payer_name,
    payer_address,
    payer_city,
    payer_state,
    payer_zip,
    payer_phone,
    amount_covered,
    amount_uncovered,
    revenue,
    qols_avg,
    member_months
)
SELECT
    id AS payer_id,
    name AS payer_name,
    ISNULL(address, 'unknown') AS payer_address,  -- NULL handling for missing address data
    ISNULL(city, 'unknown') AS payer_city,
    ISNULL(state_headquartered, 'unknown') AS payer_state,
    ISNULL(zip, 'unknown') AS payer_zip,
    ISNULL(phone, 'unknown') AS payer_phone,
    amount_covered,
    amount_uncovered,
    revenue,
    qols_avg,   -- capped to [0,1] in Silver layer
    member_months
FROM silver.payers;

GO
	
TRUNCATE TABLE gold.dim_provider;

INSERT INTO gold.dim_provider (
    provider_id,
    provider_name,
    gender,
    specialty,
    city,
    state,
    zip,
    utilization,
    organization_name,
    organization_city,
    organization_state
)
SELECT
    p.id AS provider_id,
    p.name AS provider_name,
    CASE
		WHEN LOWER(gender) IN ('f', 'female') THEN 'female' -- in case lower gender f or female, it is turned to female
		WHEN LOWER(gender) IN ('m', 'male') THEN 'male'
		ELSE 'unknown' -- unknown in any other case
	END AS gender,
    p.specialty,
    p.city,
    p.state,
    p.zip,
    p.utilization,
    o.name AS organization_name,
    o.city AS organization_city,
    o.state AS organization_state
FROM silver.providers p
LEFT JOIN silver.organizations o
ON o.id = p.organization_id;

GO

-- Generate dates from 1900-01-01 to 2100-12-31
WITH date_cte AS (
    SELECT CAST('1900-01-01' AS DATE) AS full_date
    UNION ALL
    SELECT DATEADD(DAY, 1, full_date)
    FROM date_cte
    WHERE full_date < '2100-12-31'
)
INSERT INTO gold.dim_date (
    date_key,
    full_date,
    year,
    month,
    month_name,
    quarter,
    quarter_name,
    day_of_month,
    day_of_week,
    day_name,
    is_weekend,
    is_weekday
)
SELECT
    -- date_key as integer YYYYMMDD for fast joining
    CAST(FORMAT(full_date, 'yyyyMMdd') AS INT) AS date_key,
    full_date,
    YEAR(full_date) AS year,
    MONTH(full_date) AS month,
    DATENAME(MONTH, full_date) AS month_name,
    DATEPART(QUARTER, full_date) AS quarter,
    'Q' + CAST(DATEPART(QUARTER, full_date) AS NVARCHAR) AS quarter_name,
    DAY(full_date) AS day_of_month,
    DATEPART(WEEKDAY, full_date) AS day_of_week,
    DATENAME(WEEKDAY, full_date) AS day_name,
    CASE WHEN DATEPART(WEEKDAY, full_date) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    CASE WHEN DATEPART(WEEKDAY, full_date) IN (1, 7) THEN 0 ELSE 1 END AS is_weekday
FROM date_cte
OPTION (MAXRECURSION 0);

GO

TRUNCATE TABLE gold.fact_encounter;

INSERT INTO gold.fact_encounter (
	encounter_id,
	patient_key,
	organization_key,
	provider_key,
	payer_key,
	date_key,
	encounterclass,
	description,
	reasondescription,
	base_encounter_cost,
	total_claim_cost,
	payer_coverage
)
SELECT
    e.id AS encounter_id,
    p.patient_key,
    o.organization_key,
    pr.provider_key,
    py.payer_key,
    d.date_key,
    e.encounterclass,
    e.description,
    e.reasondescription,
    e.base_encounter_cost,
    e.total_claim_cost,
    e.payer_coverage
FROM silver.encounters e
LEFT JOIN gold.dim_patient p ON p.patient_id = e.patient_id
LEFT JOIN gold.dim_organization o ON o.organization_id = e.organization_id
LEFT JOIN gold.dim_provider pr ON pr.provider_id = e.provider_id
LEFT JOIN gold.dim_payer py ON py.payer_id = e.payer_id
LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(e.start, 'yyyyMMdd') AS INT)

GO 

TRUNCATE TABLE gold.fact_condition;

INSERT INTO gold.fact_condition(
	patient_key,
	encounter_key,
	date_key,
	start_date,
	end_date,
	code,
	description,
	is_active
)
SELECT
	p.patient_key,
	e.encounter_key,
	d.date_key,
	c.start AS start_date,
	c.stop AS end_date,
	c.code,
	c.description,
	-- Checking if patients condition is still active defined by end date - is_active
	CASE 
		WHEN c.stop IS NULL THEN 1
		ELSE 0
	END AS is_active
FROM silver.conditions c
LEFT JOIN gold.dim_patient p ON p.patient_id=c.patient_id
LEFT JOIN gold.fact_encounter e ON e.encounter_id=c.encounter_id
LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(c.start, 'yyyyMMdd') AS INT);

GO 

TRUNCATE TABLE gold.fact_observation;

INSERT INTO gold.fact_observation(
	patient_key,
	encounter_key,
	date_key,
	observation_date,
	code,
	value,
	units,
	description
)

SELECT 
	p.patient_key,
	e.encounter_key,
	d.date_key,
	o.date AS observation_date,
	o.code,
	o.value,
	CASE WHEN o.units IS NULL THEN 'none'
	ELSE o.units
	END AS unit,
	o.description
FROM silver.observations o
LEFT JOIN gold.dim_patient p ON p.patient_id=o.patient_id
LEFT JOIN gold.fact_encounter e ON e.encounter_id=o.encounter_id
LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(o.date, 'yyyyMMdd') AS INT);


GO 

TRUNCATE TABLE gold.fact_medication;

INSERT INTO gold.fact_medication(
	patient_key,
	payer_key,
	encounter_key,
	date_key,
	start_date,
	end_date,
	code,
	medication_description,
	base_cost,
	payer_coverage,
	dispenses,
	totalcost,
	reason_code,
	reason_description
)

SELECT
    p.patient_key,
    py.payer_key,
    fe.encounter_key,
    d.date_key,
    m.start AS start_date,
    m.stop AS end_date,
    m.code,
    m.description AS medication_description,
    m.base_cost,
    m.payer_coverage,
    m.dispenses,
    m.totalcost,
    m.reasoncode,
    m.reasondescription
FROM silver.medications m
LEFT JOIN gold.dim_patient p ON p.patient_id = m.patient_id
LEFT JOIN gold.dim_payer py ON py.payer_id = m.payer_id
LEFT JOIN gold.fact_encounter fe ON fe.encounter_id = m.encounter_id
LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(m.start, 'yyyyMMdd') AS INT)
