-- =============================================
-- View: gold.vw_condition_prevalence
-- Description: Condition occurence count
--				along with total diagnoses, 
--				active cases and resolved cases
-- Grain: One row diagnosis code
-- =============================================

CREATE VIEW gold.vw_condition_prevalence AS
SELECT
	code,
	description AS condition_name, 
	COUNT(DISTINCT patient_key) AS patient_count, -- total patients
	COUNT(*) AS total_diagnoses, -- total diagnoses
	SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_cases, -- total active cases
    SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) AS resolved_cases -- total resolved cases
FROM gold.fact_condition
GROUP BY code,description;
