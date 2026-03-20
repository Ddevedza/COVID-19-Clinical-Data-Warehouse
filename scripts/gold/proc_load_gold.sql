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
