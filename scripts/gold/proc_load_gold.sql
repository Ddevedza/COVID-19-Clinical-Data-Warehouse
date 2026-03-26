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

TRUNCATE TABLE gold.dim_organizations;

INSERT INTO gold.dim_organizations (
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
    covered_encounters,
    uncovered_encounters,
    covered_medications,
    uncovered_medications,
    covered_procedures,
    uncovered_procedures,
    covered_immunizations,
    uncovered_immunizations,
    unique_customers,
    qols_avg,   -- already capped to [0,1] in Silver layer
    member_months
FROM silver.payers;

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
