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
