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
            id,
            first,
            last,
            ISNULL(first,'') + ' ' + ISNULL(last,''),
            birthdate,
            deathdate,
            DATEDIFF(YEAR, birthdate,
                CASE 
                    WHEN deathdate IS NOT NULL THEN deathdate
                    ELSE GETDATE()
                END),
            CASE WHEN deathdate IS NOT NULL THEN 1 ELSE 0 END,
            CASE
                WHEN LOWER(gender) IN ('f','female') THEN 'female'
                WHEN LOWER(gender) IN ('m','male') THEN 'male'
                ELSE 'unknown'
            END,
            race,
            ethnicity,
            CASE
                WHEN LOWER(marital) IN ('m','married') THEN 'married'
                WHEN LOWER(marital) IN ('s','single') THEN 'single'
                ELSE 'unknown'
            END,
            birthplace,
            address,
            city,
            state,
            county,
            zip,
            healthcare_expenses,
            healthcare_coverage
        FROM silver.patients;

        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- dim_organization
        -------------------------------------------------
        PRINT '----------------------------------------'
        PRINT 'Loading gold.dim_organization'
        PRINT '----------------------------------------'

        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);

        PRINT '>> Truncating Table: gold.dim_organization'
        TRUNCATE TABLE gold.dim_organization;

        PRINT '>> Inserting Data Into: gold.dim_organization'
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
            id,
            name,
            address,
            city,
            state,
            zip,
            phone,
            revenue,
            utilization
        FROM silver.organizations;

        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';


        -------------------------------------------------
        -- (Repeat SAME pattern for ALL remaining tables)
        -------------------------------------------------

        SET @batch_end_time = GETDATE();

        PRINT '=========================================='
        PRINT 'Loading Gold Layer is Completed'
        PRINT '   - Total Load Duration: ' 
              + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) 
              + ' seconds'
        PRINT '=========================================='

    END TRY

    BEGIN CATCH
        PRINT '=========================================='
        PRINT 'ERROR OCCURRED DURING LOADING GOLD LAYER'
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================='
    END CATCH
END;

GO

EXEC gold.load_gold;
GO
