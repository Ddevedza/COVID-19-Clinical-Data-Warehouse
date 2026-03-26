/*
=====================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
=====================================================================
Creating batch loading for silver data. This procedure truncates and
reloads all silver tables from bronze, applying:
    - Data type casting (NVARCHAR -> DATE, DATE, INT, DECIMAL)
    - String standardization (TRIM, LOWER, TRANSLATE)
    - NULL handling and preservation
    - Deduplication (ROW_NUMBER)
    - Data quality fixes (date swaps, value capping)
*/

-- Creating procedure for silver batch data loading
CREATE OR ALTER PROCEDURE silver.load_silver  
AS 
BEGIN
	DECLARE @start_time DATE, @end_time DATE, @batch_start_time DATE, @batch_end_time DATE; -- defining time variables so we can check each separate execution, along with total batch execution
-- Start of the procedure

    BEGIN TRY
        SET @batch_start_time = GETDATE();
	    PRINT '========================================' -- prints for nice viewing
	    PRINT 'Loading Silver Layer'
	    PRINT '========================================'

        PRINT '----------------------------------------'
        PRINT 'Loading silver.allergies'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE(); -- table exec measuring
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
	    PRINT '>> Truncating Table: silver.allergies'
        TRUNCATE TABLE silver.allergies;
	    PRINT '>> Inserting Data Into: silver.allergies';
        INSERT INTO silver.allergies (
	        start,
	        stop,
	        patient_id,
	        encounter_id,
	        code,
	        description
	        )
        SELECT
	        TRY_CAST(start as DATE) start, -- Turning data into DATE if possible
	        TRY_CAST(stop as DATE) stop,
	        TRIM(patient) patient_id,
	        TRIM(encounter) encounter_id,
	        TRIM(code) code,
	        description
        FROM bronze.allergies;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        -- Loading silver.careplans
        PRINT '----------------------------------------'
        PRINT 'Loading silver.careplans'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
		PRINT '>> Truncating Table: silver.careplans';
        TRUNCATE TABLE silver.careplans;
        PRINT '>> Inserting Data Into: silver.careplans';
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
	        TRY_CAST(start as DATE) start, -- Turning data into date if possible
	        TRY_CAST(stop as DATE) stop,
	        TRIM(patient) patient_id,
	        TRIM(encounter) encounter_id,
	        TRIM(code) code,
	        description,
	        TRIM(reasoncode) reasoncode,
	        reasondescription
        FROM bronze.careplans;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.conditions'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.conditions';
        TRUNCATE TABLE silver.conditions;

        PRINT '>> Inserting Data Into: silver.conditions';
        INSERT INTO silver.conditions (
	        start,
	        stop,
	        patient_id,
	        encounter_id,
	        code,
	        description
	        )
        SELECT
	        TRY_CAST(start as DATE) start, -- Turning data into date if possible
	        TRY_CAST(stop as DATE) stop,
	        TRIM(patient) patient_id,
	        TRIM(encounter) encounter_id,
	        TRIM(code) code,
	        description
        FROM bronze.conditions;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.devices'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.devices';
        TRUNCATE TABLE silver.devices;

        PRINT '>> Inserting Data Into: silver.devices';
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
            TRY_CAST(start as DATE) start, -- Turning data into DATE if possible
            TRY_CAST(stop as DATE) stop,
            TRIM(patient) patient_id,
            TRIM(encounter) encounter_id,
            TRIM(code) code,
            description,
            TRIM(udi)
        FROM bronze.devices;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.encounters'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.encounters';
        TRUNCATE TABLE silver.encounters;

        PRINT '>> Inserting Data Into: silver.encounters';
        INSERT INTO silver.encounters (
            id,
            start,
            stop,
            patient_id,
            organization_id,
			provider_id,
            payer_id,
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
            TRY_CAST(start AS DATE) AS start,
            TRY_CAST(stop AS DATE) AS stop,
            TRIM(patient) AS patient_id,
            TRIM(organization) organization_id,
            TRIM(provider) provider_id,
			TRIM(payer) payer_id,
            LOWER(TRIM(encounterclass)) encounterclass,
            TRIM(code) AS code,
            description,
            base_encounter_cost,
            total_claim_cost,
            payer_coverage,
            TRIM(reasoncode) AS reasoncode,
            reasondescription
        FROM bronze.encounters;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.imaging_studies'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.imaging_studies';
        TRUNCATE TABLE silver.imaging_studies;

        PRINT '>> Inserting Data Into: silver.imaging_studies';
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
            TRY_CAST([date] AS DATE) AS [date],
            TRIM(patient) AS patient_id,
            TRIM(encounter) AS encounter_id,
            TRIM(bodysite_code) AS bodysite_code,
            bodysite_description,
            TRIM(modality_code) AS modality_code,
            modality_description,
            TRIM(sop_code) AS sop_code,
            sop_description
        FROM bronze.imaging_studies;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.immunizations'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.immunizations';
        TRUNCATE TABLE silver.immunizations;

        PRINT '>> Inserting Data Into: silver.immunizations';
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
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.medications'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.medications';
        TRUNCATE TABLE silver.medications;

        PRINT '>> Inserting Data Into: silver.medications';
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
                    WHEN TRY_CAST(stop AS DATE) < TRY_CAST(start AS DATE) THEN TRY_CAST(stop AS DATE)
                    ELSE TRY_CAST(start AS DATE) 
                END AS start,
                CASE 
                    WHEN TRY_CAST(stop AS DATE) < TRY_CAST(start AS DATE) THEN TRY_CAST(start AS DATE)
                    ELSE TRY_CAST(stop AS DATE) 
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
        WHERE rn = 1;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.observations'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.observations';
        TRUNCATE TABLE silver.observations;

        -- Note: ~30k observations have NULL encounter_id
        -- In Synthea these represent derived patient-level metrics,
        -- administrative recordings, or generation artifacts
        -- NULL encounter_id is preserved intentionally
        PRINT '>> Inserting Data Into: silver.observations';
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
            TRY_CAST([date] AS DATE) AS [date],
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
            WHERE rn<2; -- duplicated values are removed, as they are complete duplicates(achieved on the same date)
            -- they were completely removed
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.organizations'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.organizations';
        TRUNCATE TABLE silver.organizations;

        PRINT '>> Inserting Data Into: silver.organizations';
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
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.patients'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.patients';
        TRUNCATE TABLE silver.patients;

        PRINT '>> Inserting Data Into: silver.patients';
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
            -- Source birthdate format is YY/MM/DD (format code 11)
			-- TRY_CONVERT handles this correctly where TRY_CAST would fail or misinterpret
			-- As we don't have more information on the actual dates and possible interpretations I subtracted 100 years in two cases:
			--   1. Birthdate lands in the future (SQL Server misread century as 2000s)
			--   2. Birthdate is greater than deathdate after deathdate is century-corrected first
			CASE 
			    WHEN TRY_CONVERT(DATE, birthdate, 11) > GETDATE()
			        THEN DATEADD(YEAR, -100, TRY_CONVERT(DATE, birthdate, 11))
			    WHEN TRY_CONVERT(DATE, birthdate, 11) > (
			        CASE 
			            WHEN TRY_CONVERT(DATE, deathdate, 11) > GETDATE()
			            THEN DATEADD(YEAR, -100, TRY_CONVERT(DATE, deathdate, 11))
			        ELSE TRY_CONVERT(DATE, deathdate, 11) END)
			        THEN DATEADD(YEAR, -100, TRY_CONVERT(DATE, birthdate, 11))
			    ELSE TRY_CONVERT(DATE, birthdate, 11)
			END AS birthdate,
			CASE 
			    WHEN TRY_CONVERT(DATE, deathdate, 11) > GETDATE()
			        THEN DATEADD(YEAR, -100, TRY_CONVERT(DATE, deathdate, 11))
			    ELSE TRY_CONVERT(DATE, deathdate, 11)
			END AS deathdate,
            TRIM(ssn) AS ssn,
            TRIM(drivers) AS drivers,
            TRIM(passport) AS passport,
            TRIM(prefix) AS prefix,
            -- Remove trailing numbers from first, last  and maiden name
            REPLACE( 
                TRANSLATE(first, '0123456789', '##########'), -- Translating number values in a string with a #
                '#',
                '' -- so we can replace it into empty string - ''
            ) AS first,
            REPLACE( 
                TRANSLATE(last, '0123456789', '##########'), -- Translating number values in a string with a #
                '#',
                '' -- so we can replace it into empty string - ''
            ) AS last,
            TRIM(suffix) AS suffix,
            REPLACE( 
                TRANSLATE(maiden, '0123456789', '##########'), -- Translating number values in a string with a #
                '#',
                '' -- so we can replace it into empty string - ''
            ) AS maiden,
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
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.payer_transitions'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.payer_transitions';
        TRUNCATE TABLE silver.payer_transitions;

        PRINT '>> Inserting Data Into: silver.payer_transitions';
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
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.payers'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.payers';
        TRUNCATE TABLE silver.payers;

        PRINT '>> Inserting Data Into: silver.payers';
        INSERT INTO silver.payers (
            id,
            name,
            address,
            city,
            state_headquartered,
            zip,
            phone,
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
            qols_avg,
            member_months
        )
        SELECT
            TRIM(id) AS id,
            name,
            address,
            city,
            TRIM(state_headquartered) AS state_headquartered,
            TRIM(zip) AS zip,
            TRIM(phone) AS phone,
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
            -- Capping qols_avg to valid range [0,1]
            -- NO_INSURANCE payer can produce values slightly above 1 in Synthea
            CASE 
                WHEN qols_avg > 1 THEN 1
                WHEN qols_avg < 0 THEN 0
            ELSE qols_avg
        END AS qols_avg,
            member_months
        FROM bronze.payers;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.procedures'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.procedures';
        TRUNCATE TABLE silver.procedures;

        PRINT '>> Inserting Data Into: silver.procedures';
        INSERT INTO silver.procedures (
            date,
            patient_id,
            encounter_id,
            code,
            description,
            base_cost,
            reasoncode,
            reasondescription
        )
        SELECT
            TRY_CAST(date AS DATE),
            TRIM(patient) AS patient_id,
            TRIM(encounter) AS encounter_id,
            TRIM(code) AS code,
            description,
            base_cost,
            TRIM(reasoncode) AS reasoncode,
            reasondescription
        FROM bronze.procedures;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.providers'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.providers';
        TRUNCATE TABLE silver.providers;

        PRINT '>> Inserting Data Into: silver.providers';
        INSERT INTO silver.providers (
            id,
            organization_id,
            name,
            gender,
            specialty,
            address,
            city,
            state,
            zip,
            lat,
            lon,
            utilization
        )
        SELECT
            TRIM(id) AS id,
            TRIM(organization) AS organization_id,
            REPLACE( 
                TRANSLATE(name, '0123456789', '##########'), -- Translating number values in a string with a #
                '#',
                '' -- so we can replace it into empty string - ''
            ) AS name,
            TRIM(gender) AS gender,
            TRIM(specialty) AS specialty,
            address,
            city,
            state,
            TRIM(zip) AS zip,
            lat,
            lon,
            utilization
        FROM bronze.providers;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        PRINT '----------------------------------------'
        PRINT 'Loading silver.supplies'
        PRINT '----------------------------------------'
        SET @start_time = GETDATE();
        PRINT '>> Start Time: ' + CONVERT(NVARCHAR(19), @start_time, 120);
        PRINT '>> Truncating Table: silver.supplies';
        TRUNCATE TABLE silver.supplies;

        PRINT '>> Inserting Data Into: silver.supplies';
        INSERT INTO silver.supplies (
            date, 
	        patient_id, 
	        encounter_id, 
	        code, 
	        description, 
	        quantity
        )
        SELECT
            TRY_CAST([date] AS DATE),
            TRIM(patient) AS patient_id,
            TRIM(encounter) AS encounter_id,
            TRIM(code) AS code,
            description,
            quantity
        FROM bronze.supplies;
        SET @end_time = GETDATE();
        PRINT '>> End Time: ' + CONVERT(NVARCHAR(19), @end_time, 120);
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> -------------';

        SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
		PRINT '=========================================='
		
	END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING Silver LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END

GO

EXEC silver.load_silver; -- exec the whole load
GO

GO

EXEC silver.load_silver; -- exec the whole load
GO
