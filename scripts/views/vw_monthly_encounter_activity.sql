-- =============================================
-- View: gold.vw_monthly_encounter_activity
-- Description: number of encounters per year/month,
--				along with patient encounter count
-- Grain: One row per year/month combination
-- Note: total cost is presented with avg per patient and total coverage
-- =============================================

CREATE VIEW gold.vw_monthly_encounter_activity AS
SELECT
	d.year,
	d.month,
	d.month_name,
	d.quarter_name,
	COUNT(e.encounter_key) AS encounter_count, -- total encounter cost
	COUNT(DISTINCT e.patient_key) AS unique_patients, -- total patient in the specific encounter
	SUM(e.total_claim_cost) AS total_cost, -- total cost 
	AVG(e.total_claim_cost) AS avg_cost_per_encounter, -- average cost per encounter
    SUM(e.payer_coverage) AS total_payer_coverage -- total payer coverage
FROM gold.fact_encounter e
LEFT JOIN gold.dim_date d ON d.date_key = e.date_key
GROUP BY
	d.year,
	d.month,
	d.month_name,
	d.quarter,
	d.quarter_name
