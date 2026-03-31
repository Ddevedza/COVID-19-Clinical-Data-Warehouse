-- =============================================
-- View: gold.vw_patient_summary
-- Description: Patient demographics with
--              encounter and condition counts
-- =============================================

CREATE VIEW gold.vw_patient_summary AS
SELECT
	gdp.full_name,
	gdp.age,
	-- Turning 0/1 for is_deceased into human reading output yes/no
	CASE WHEN 
		gdp.is_deceased=1 THEN 'yes'
		ELSE 'no'
	END AS is_deceased,
	gdp.gender,
	gdp.race,
    gdp.state,
	COUNT(DISTINCT gfe.encounter_key) as encounter_count,
	COUNT(DISTINCT gfc.condition_key) as condition_count
FROM gold.dim_patient gdp
LEFT JOIN gold.fact_encounter gfe ON gfe.patient_key=gdp.patient_key
LEFT JOIN gold.fact_condition gfc ON gfc.patient_key=gdp.patient_key
GROUP BY
    gdp.patient_key,
    gdp.full_name,
    gdp.age,
    gdp.is_deceased,
    gdp.gender,
    gdp.race,
    gdp.state;
