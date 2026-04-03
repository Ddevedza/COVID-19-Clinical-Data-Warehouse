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


CREATE OR ALTER PROCEDURE gold.load_gold
AS
BEGIN
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

    BEGIN TRY
        SET @batch_start_time = GETDATE();

        PRINT '========================================'
        PRINT 'Loading Gold Layer'
        PRINT '========================================'

        -------------------------------------------------
        -- dim_patient
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.dim_patient'
        PRINT '----------------------------------------'

        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);

        PRINT '>> Truncating Table: gold.dim_patient'
        TRUNCATE TABLE gold.dim_patient;

        PRINT '>> Inserting Data Into: gold.dim_patient'
        INSERT INTO gold.dim_patient (
            patient_id, first_name, last_name, full_name,
            birthdate, deathdate, age, is_deceased,
            gender, race, ethnicity, marital_status,
            birthplace, address, city, state, county, zip,
            healthcare_expenses, healthcare_coverage
        )
        SELECT
            id, first, last,
            ISNULL(first,'') + ' ' + ISNULL(last,''),
            birthdate, deathdate,
            DATEDIFF(YEAR, birthdate,
                CASE WHEN deathdate IS NOT NULL THEN deathdate ELSE GETDATE() END),
            CASE WHEN deathdate IS NOT NULL THEN 1 ELSE 0 END,
            CASE
                WHEN LOWER(gender) IN ('f','female') THEN 'female'
                WHEN LOWER(gender) IN ('m','male') THEN 'male'
                ELSE 'unknown'
            END,
            race, ethnicity,
            CASE
                WHEN LOWER(marital) IN ('m','married') THEN 'married'
                WHEN LOWER(marital) IN ('s','single') THEN 'single'
                ELSE 'unknown'
            END,
            birthplace, address, city, state, county, zip,
            healthcare_expenses, healthcare_coverage
        FROM silver.patients;

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' sec';


        -------------------------------------------------
        -- dim_organization
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.dim_organization'

        SET @start_time = GETDATE();
        TRUNCATE TABLE gold.dim_organization;

        INSERT INTO gold.dim_organization (
            organization_id, organization_name, organization_address,
            organization_city, organization_state, organization_zip,
            organization_phone, revenue, utilization
        )
        SELECT
            id, name, address, city, state, zip, phone, revenue, utilization
        FROM silver.organizations;

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
        SET @end_time = GETDATE();
        PRINT '>> Duration: ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) AS NVARCHAR) + ' sec';


        -------------------------------------------------
        -- dim_payer
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.dim_payer'

        SET @start_time = GETDATE();
        TRUNCATE TABLE gold.dim_payer;

        INSERT INTO gold.dim_payer (
            payer_id, payer_name, payer_address, payer_city,
            payer_state, payer_zip, payer_phone,
            amount_covered, amount_uncovered, revenue,
            qols_avg, member_months
        )
        SELECT
            id, name,
            ISNULL(address,'unknown'),
            ISNULL(city,'unknown'),
            ISNULL(state_headquartered,'unknown'),
            ISNULL(zip,'unknown'),
            ISNULL(phone,'unknown'),
            amount_covered, amount_uncovered, revenue,
            qols_avg, member_months
        FROM silver.payers;

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);
        SET @end_time = GETDATE();


        -------------------------------------------------
        -- dim_provider
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.dim_provider'

        SET @start_time = GETDATE();
        TRUNCATE TABLE gold.dim_provider;

        INSERT INTO gold.dim_provider (
            provider_id, provider_name, gender, specialty,
            city, state, zip, utilization,
            organization_name, organization_city, organization_state
        )
        SELECT
            p.id, p.name,
            CASE
                WHEN LOWER(gender) IN ('f','female') THEN 'female'
                WHEN LOWER(gender) IN ('m','male') THEN 'male'
                ELSE 'unknown'
            END,
            p.specialty, p.city, p.state, p.zip, p.utilization,
            o.name, o.city, o.state
        FROM silver.providers p
        LEFT JOIN silver.organizations o ON o.id = p.organization_id;

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- dim_date
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.dim_date'

        SET @start_time = GETDATE();

        WITH date_cte AS (
            SELECT CAST('1900-01-01' AS DATE) AS full_date
            UNION ALL
            SELECT DATEADD(DAY,1,full_date)
            FROM date_cte
            WHERE full_date < '2100-12-31'
        )
        INSERT INTO gold.dim_date (
            date_key, full_date, year, month, month_name,
            quarter, quarter_name, day_of_month,
            day_of_week, day_name, is_weekend, is_weekday
        )
        SELECT
            CAST(FORMAT(full_date,'yyyyMMdd') AS INT),
            full_date,
            YEAR(full_date),
            MONTH(full_date),
            DATENAME(MONTH,full_date),
            DATEPART(QUARTER,full_date),
            'Q'+CAST(DATEPART(QUARTER,full_date) AS NVARCHAR),
            DAY(full_date),
            DATEPART(WEEKDAY,full_date),
            DATENAME(WEEKDAY,full_date),
            CASE WHEN DATEPART(WEEKDAY,full_date) IN (1,7) THEN 1 ELSE 0 END,
            CASE WHEN DATEPART(WEEKDAY,full_date) IN (1,7) THEN 0 ELSE 1 END
        FROM date_cte
        OPTION (MAXRECURSION 0);

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- fact_encounter
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.fact_encounter'

        TRUNCATE TABLE gold.fact_encounter;

        INSERT INTO gold.fact_encounter (
            encounter_id, patient_key, organization_key,
            provider_key, payer_key, date_key,
            encounterclass, description, reasondescription,
            base_encounter_cost, total_claim_cost, payer_coverage
        )
        SELECT
            e.id, p.patient_key, o.organization_key,
            pr.provider_key, py.payer_key, d.date_key,
            e.encounterclass, e.description, e.reasondescription,
            e.base_encounter_cost, e.total_claim_cost, e.payer_coverage
        FROM silver.encounters e
        LEFT JOIN gold.dim_patient p ON p.patient_id = e.patient_id
        LEFT JOIN gold.dim_organization o ON o.organization_id = e.organization_id
        LEFT JOIN gold.dim_provider pr ON pr.provider_id = e.provider_id
        LEFT JOIN gold.dim_payer py ON py.payer_id = e.payer_id
        LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(e.start,'yyyyMMdd') AS INT);

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- fact_condition
        -------------------------------------------------
        PRINT 'Loading gold.fact_condition'

        TRUNCATE TABLE gold.fact_condition;

        INSERT INTO gold.fact_condition(
            patient_key, encounter_key, date_key,
            start_date, end_date, code, description, is_active
        )
        SELECT
            p.patient_key, e.encounter_key, d.date_key,
            c.start, c.stop, c.code, c.description,
            CASE WHEN c.stop IS NULL THEN 1 ELSE 0 END
        FROM silver.conditions c
        LEFT JOIN gold.dim_patient p ON p.patient_id=c.patient_id
        LEFT JOIN gold.fact_encounter e ON e.encounter_id=c.encounter_id
        LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(c.start,'yyyyMMdd') AS INT);

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- fact_observation
        -------------------------------------------------
        PRINT 'Loading gold.fact_observation'

        TRUNCATE TABLE gold.fact_observation;

        INSERT INTO gold.fact_observation(
            patient_key, encounter_key, date_key,
            observation_date, code, value, units, description
        )
        SELECT
            p.patient_key, e.encounter_key, d.date_key,
            o.date, o.code, o.value,
            CASE WHEN o.units IS NULL THEN 'none' ELSE o.units END,
            o.description
        FROM silver.observations o
        LEFT JOIN gold.dim_patient p ON p.patient_id=o.patient_id
        LEFT JOIN gold.fact_encounter e ON e.encounter_id=o.encounter_id
        LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(o.date,'yyyyMMdd') AS INT);

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- fact_medication
        -------------------------------------------------
        PRINT 'Loading gold.fact_medication'

        TRUNCATE TABLE gold.fact_medication;

        INSERT INTO gold.fact_medication(
            patient_key, payer_key, encounter_key, date_key,
            start_date, end_date, code, medication_description,
            base_cost, payer_coverage, dispenses, totalcost,
            reason_code, reason_description
        )
        SELECT
            p.patient_key, py.payer_key, fe.encounter_key, d.date_key,
            m.start, m.stop, m.code, m.description,
            m.base_cost, m.payer_coverage, m.dispenses, m.totalcost,
            m.reasoncode, m.reasondescription
        FROM silver.medications m
        LEFT JOIN gold.dim_patient p ON p.patient_id = m.patient_id
        LEFT JOIN gold.dim_payer py ON py.payer_id = m.payer_id
        LEFT JOIN gold.fact_encounter fe ON fe.encounter_id = m.encounter_id
        LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(m.start,'yyyyMMdd') AS INT);

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- fact_procedure
        -------------------------------------------------
        PRINT 'Loading gold.fact_procedure'

        TRUNCATE TABLE gold.fact_procedure;

        INSERT INTO gold.fact_procedure (
            patient_key, encounter_key, date_key,
            procedure_date, code, procedure_description,
            base_cost, reason_code, reason_description
        )
        SELECT
            pa.patient_key, fe.encounter_key, d.date_key,
            pr.date, pr.code, pr.description,
            pr.base_cost, pr.reasoncode, pr.reasondescription
        FROM silver.procedures pr
        LEFT JOIN gold.dim_patient pa ON pa.patient_id = pr.patient_id
        LEFT JOIN gold.fact_encounter fe ON fe.encounter_id = pr.encounter_id
        LEFT JOIN gold.dim_date d ON d.date_key = CAST(FORMAT(pr.date,'yyyyMMdd') AS INT);

        PRINT '>> Rows Inserted: ' + CAST(@@ROWCOUNT AS NVARCHAR);


        -------------------------------------------------
        -- END
        -------------------------------------------------
        SET @batch_end_time = GETDATE();

        PRINT '=========================================='
        PRINT 'Gold Load Completed'
        PRINT 'Total Duration: ' + CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + ' sec'
        PRINT '=========================================='

    END TRY

    BEGIN CATCH
        PRINT '=========================================='
        PRINT 'ERROR IN GOLD LOAD'
        PRINT 'Message: ' + ERROR_MESSAGE();
        PRINT 'Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================='
    END CATCH
END;

GO

EXEC gold.load_gold;
GO
