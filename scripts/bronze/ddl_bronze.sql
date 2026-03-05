/*

DDL Script : Create Bronze Tables

-------------------------------------------------------------------

Creating tables with existing table based data

As it is a bronze layer, all data is not transformed - it is in its original/unaltered state
*/

--if it already exists
IF OBJECT_ID('bronze.allergies','U') IS NOT NULL
	DROP TABLE bronze.allergies; -- drop it
CREATE TABLE bronze.allergies( -- then create it
	-- defining data for each table
	start NVARCHAR(50),
	stop NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500)
);

IF OBJECT_ID('bronze.careplans','U') IS NOT NULL
	DROP TABLE bronze.careplans;
CREATE TABLE bronze.careplans(
	id NVARCHAR(255),
	start NVARCHAR(50),
	stop NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR (255),
	code NVARCHAR(50),
	description NVARCHAR (500),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255)
);

IF OBJECT_ID('bronze.conditions','U') IS NOT NULL
	DROP TABLE bronze.conditions;
CREATE TABLE bronze.conditions(
	start NVARCHAR(50),
	stop NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500)
);

IF OBJECT_ID('bronze.devices','U') IS NOT NULL
	DROP TABLE bronze.devices;
CREATE TABLE bronze.devices(
	start NVARCHAR(50),
	stop NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	udi NVARCHAR(255)
);

IF OBJECT_ID('bronze.encounters','U') IS NOT NULL
	DROP TABLE bronze.encounters;
CREATE TABLE bronze.encounters(
	id NVARCHAR(255),
	start NVARCHAR(50),
	stop NVARCHAR(50),
	patient NVARCHAR(255),
	organization NVARCHAR(255),
	payer NVARCHAR (255),
	provider NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_encounter_cost DECIMAL(18,2),
	total_claim_cost DECIMAL(18,2),
	payer_coverage DECIMAL(18,2),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255)
);

IF OBJECT_ID('bronze.imaging_studies','U') IS NOT NULL
	DROP TABLE bronze.imaging_studies;
CREATE TABLE bronze.imaging_studies(
	id NVARCHAR(255),
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	bodysite_code NVARCHAR(50),
	bodysite_description NVARCHAR(255),
	modality_code NVARCHAR(50),
	modality_description NVARCHAR(255),
	sop_code NVARCHAR(50),
	sop_description NVARCHAR(255)
);

IF OBJECT_ID('bronze.immunizations','U') IS NOT NULL
	DROP TABLE bronze.immunizations;
CREATE TABLE bronze.immunizations(
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_cost DECIMAL(18,2)
);

IF OBJECT_ID('bronze.medications','U') IS NOT NULL
	DROP TABLE bronze.medications;
CREATE TABLE bronze.medications(
	start NVARCHAR(50),
	stop NVARCHAR(50),
	patient NVARCHAR(255),
	payer NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_cost DECIMAL(18,2),
	payer_coverage DECIMAL(18,2),
	dispenses INT,
	totalcost DECIMAL(18,2),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255)
);

IF OBJECT_ID('bronze.observations','U') IS NOT NULL
	DROP TABLE bronze.observations;
CREATE TABLE bronze.observations(
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	value NVARCHAR(50),
	units NVARCHAR(50),
	type NVARCHAR(50)
);

IF OBJECT_ID('bronze.organizations','U') IS NOT NULL
	DROP TABLE bronze.organizations;
CREATE TABLE bronze.organizations(
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
	utilization INT
);

IF OBJECT_ID('bronze.patients','U') IS NOT NULL
	DROP TABLE bronze.patients;
CREATE TABLE bronze.patients(
	id NVARCHAR(255),
	birthdate NVARCHAR(50),
	deathdate NVARCHAR(50),
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
	healthcare_coverage DECIMAL(18,2)
);

IF OBJECT_ID('bronze.payer_transitions','U') IS NOT NULL
	DROP TABLE bronze.payer_transitions;
CREATE TABLE bronze.payer_transitions(
	patient NVARCHAR(255),
	start_year INT,
	end_year INT,
	payer NVARCHAR(255),
	ownership NVARCHAR(50)
);

IF OBJECT_ID('bronze.payers','U') IS NOT NULL
	DROP TABLE bronze.payers;
CREATE TABLE bronze.payers (
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
	member_months INT
);

IF OBJECT_ID('bronze.procedures','U') IS NOT NULL
	DROP TABLE bronze.procedures;
CREATE TABLE bronze.procedures(
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	base_cost DECIMAL(18,2),
	reasoncode  NVARCHAR(50),
	reasondescription NVARCHAR(255)
);

IF OBJECT_ID('bronze.providers','U') IS NOT NULL
	DROP TABLE bronze.providers;
CREATE TABLE bronze.providers(
	id NVARCHAR(255),
	organization NVARCHAR(255),
	name NVARCHAR(255),
	gender NVARCHAR(50),
	specialty NVARCHAR(50),
	address NVARCHAR(255),
	city NVARCHAR(255),
	state NVARCHAR(50),
	zip NVARCHAR(50),
	lat DECIMAL(18,6),
	lon DECIMAL(18,6),
	utilization INT
);

IF OBJECT_ID('bronze.supplies','U') IS NOT NULL
	DROP TABLE bronze.supplies;
CREATE TABLE bronze.supplies(
	date NVARCHAR(50),
	patient NVARCHAR(255),
	encounter NVARCHAR(255),
	code NVARCHAR(50),
	description NVARCHAR(500),
	quantity INT
);
