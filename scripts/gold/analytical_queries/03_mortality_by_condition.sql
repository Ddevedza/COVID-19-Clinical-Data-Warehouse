-- =============================================
-- Conditions most associated with deceased patients
-- =============================================
-- Insight: Chronic congestive heart failure
--			leads to most deaths (89.47% mortality)
--			rate, followed by suspected lung 
--			cancer (86.66%) and Non-small cell
--			carcinoma of lung TNM stage (85.71%).
--			Cases under 10 patients are excluded
--			as they don't have enough data to make
--			a valid assumption.
-- =============================================

-- Total deceased patients per condition
WITH deceased_conditions  AS(
SELECT
	c.description,
	COUNT(DISTINCT c.patient_key) AS deceased_patient_count
FROM gold.fact_condition c
LEFT JOIN gold.dim_patient p
	ON c.patient_key = p.patient_key
WHERE is_deceased=1
GROUP BY c.description
HAVING COUNT(DISTINCT c.patient_key) > 10), -- conditions with less than 10 patients are excluded

-- total patients per a condition
total_per_condition AS (
SELECT
	c.description,
	COUNT(DISTINCT c.patient_key) AS total_patient_count
FROM gold.fact_condition c
GROUP BY c.description
)
SELECT
	dc.description AS condition_name,
	tp.total_patient_count,
	dc.deceased_patient_count,
	CAST(dc.deceased_patient_count AS FLOAT) 
        / tp.total_patient_count * 100 AS mortality_rate_pct -- percentage of patients with this condition who are deceased
FROM deceased_conditions  dc	
LEFT JOIN total_per_condition tp ON dc.description=tp.description
ORDER BY mortality_rate_pct DESC
