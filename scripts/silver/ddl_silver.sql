/*

DDL Script : Create silver Tables

-------------------------------------------------------------------

Creating tables with existing table based data

As it is a silver layer, all data is not transformed - it is in its original/unaltered state
*/

--if it already exists
IF OBJECT_ID('silver.allergies','U') IS NOT NULL
	DROP TABLE silver.allergies; -- drop it
CREATE TABLE silver.allergies( -- then create it
	-- defining data for each table
	start DATETIME,
	stop DATETIME,
	patient_id NVARCHAR(255),
	encounter_id NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- metadata when the table was created
);

IF OBJECT_ID('silver.careplans','U') IS NOT NULL
	DROP TABLE silver.careplans;
CREATE TABLE silver.careplans(
	id NVARCHAR(255),
	start DATE,
	stop DATE,
	patient_id NVARCHAR(255),
	encounter_id NVARCHAR (255),
	code NVARCHAR(50),
	description NVARCHAR (500),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.conditions','U') IS NOT NULL
	DROP TABLE silver.conditions; -- drop it
CREATE TABLE silver.conditions( -- then create it
	-- defining data for each table
	start DATETIME,
	stop DATETIME,
	patient_id NVARCHAR(255),
	encounter_id NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	dwh_create_date DATETIME2 DEFAULT GETDATE() -- metadata when the table was created
);

IF OBJECT_ID('silver.devices','U') IS NOT NULL
    DROP TABLE silver.devices; -- drop it
CREATE TABLE silver.devices( -- then create it
    -- defining data for each table
    start DATETIME,
    stop DATETIME,
    patient_id NVARCHAR(255),
    encounter_id NVARCHAR(255),
    code NVARCHAR(50),
    description NVARCHAR(500),
    udi NVARCHAR(255),
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- metadata when the table was created
);

IF OBJECT_ID('silver.encounters','U') IS NOT NULL
	DROP TABLE silver.encounters;
CREATE TABLE silver.encounters(
	id NVARCHAR(255),
	start DATETIME,
	stop DATETIME,
	patient_id NVARCHAR(255),
	organization_id NVARCHAR(255),
	payer_id NVARCHAR (255),
	provider_id NVARCHAR(255),
	encounterclass NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_encounter_cost DECIMAL(18,2),
	total_claim_cost DECIMAL(18,2),
	payer_coverage DECIMAL(18,2),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.imaging_studies','U') IS NOT NULL
	DROP TABLE silver.imaging_studies;
CREATE TABLE silver.imaging_studies(
	id NVARCHAR(255),
	date DATETIME,
	patient_id NVARCHAR(255),
	encounter_id NVARCHAR(255),
	bodysite_code NVARCHAR(50),
	bodysite_description NVARCHAR(255),
	modality_code NVARCHAR(50),
	modality_description NVARCHAR(255),
	sop_code NVARCHAR(50),
	sop_description NVARCHAR(255),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.immunizations','U') IS NOT NULL
	DROP TABLE silver.immunizations;
CREATE TABLE silver.immunizations(
	date DATETIME,
	patient_id NVARCHAR(255),
	encounter_id NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_cost DECIMAL(18,2),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.medications','U') IS NOT NULL
	DROP TABLE silver.medications;
CREATE TABLE silver.medications(
	start DATETIME,
	stop DATETIME,
	patient_id NVARCHAR(255),
	payer_id NVARCHAR(255),
	encounter_id NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_cost DECIMAL(18,2),
	payer_coverage DECIMAL(18,2),
	dispenses INT,
	totalcost DECIMAL(18,2),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.observations','U') IS NOT NULL
	DROP TABLE silver.observations;
CREATE TABLE silver.observations(
	[date] DATETIME,
	patient_id NVARCHAR(255),
	encounter_id NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	value NVARCHAR(50),
	units NVARCHAR(50),
	type NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.organizations','U') IS NOT NULL
	DROP TABLE silver.organizations;
CREATE TABLE silver.organizations(
	id NVARCHAR(255),
	name NVARCHAR(255),
	address NVARCHAR(255),
	city NVARCHAR(255),
	state NVARCHAR(50),
	zip NVARCHAR(50),
	lat DECIMAL(18,6),
	lon DECIMAL(18,6),
	phone NVARCHAR(50),
	revenue DECIMAL(18,2),
	utilization INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.patients','U') IS NOT NULL
	DROP TABLE silver.patients;
CREATE TABLE silver.patients(
	id NVARCHAR(255),
	birthdate DATETIME,
	deathdate DATETIME,
	ssn NVARCHAR(50),
	drivers NVARCHAR(50),
	passport NVARCHAR(50),
	prefix NVARCHAR(50),
	first NVARCHAR(50),
	last NVARCHAR(50),
	suffix NVARCHAR(50),
	maiden NVARCHAR(255),
	marital NVARCHAR(50),
	race NVARCHAR(50),
	ethnicity NVARCHAR(255),
	gender NVARCHAR(50),
	birthplace NVARCHAR(255),
	address NVARCHAR(255),
	city NVARCHAR(50),
	state NVARCHAR(50),
	county NVARCHAR(50),
	zip NVARCHAR(50),
	lat DECIMAL(18,6),
	lon DECIMAL(18,6),
	healthcare_expenses DECIMAL(18,2),
	healthcare_coverage DECIMAL(18,2),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.payer_transitions','U') IS NOT NULL
	DROP TABLE silver.payer_transitions;
CREATE TABLE silver.payer_transitions(
	patient_id NVARCHAR(255),
	start_year INT,
	end_year INT,
	payer_id NVARCHAR(255),
	ownership NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.payers','U') IS NOT NULL
	DROP TABLE silver.payers;
CREATE TABLE silver.payers (
	id NVARCHAR(255),
	name NVARCHAR(255),
	address NVARCHAR(255),
	city NVARCHAR(255),
	state_headquartered NVARCHAR(50),
	zip NVARCHAR(50),
	phone NVARCHAR(50),
	amount_covered DECIMAL(18,2),
	amount_uncovered DECIMAL(18,2),
	revenue DECIMAL(18,2),
	covered_encounters INT,
	uncovered_encounters INT,
	covered_medications INT,
	uncovered_medications INT,
	covered_procedures INT,
	uncovered_procedures INT,
	covered_immunizations INT,
	uncovered_immunizations INT,
	unique_customers INT,
	qols_avg FLOAT,
	member_months INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.procedures','U') IS NOT NULL
	DROP TABLE silver.procedures;
CREATE TABLE silver.procedures(
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_cost DECIMAL(18,2),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.providers','U') IS NOT NULL
	DROP TABLE silver.providers;
CREATE TABLE silver.providers(
	id NVARCHAR(255),
	organization NVARCHAR(255),
	name NVARCHAR(255),
	gender NVARCHAR(50),
	speciality NVARCHAR(50),
	address NVARCHAR(255),
	city NVARCHAR(255),
	state NVARCHAR(50),
	zip NVARCHAR(50),
	lat DECIMAL(18,6),
	lon DECIMAL(18,6),
	utilization INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);

IF OBJECT_ID('silver.supplies','U') IS NOT NULL
	DROP TABLE silver.supplies;
CREATE TABLE silver.supplies(
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	quantity INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
