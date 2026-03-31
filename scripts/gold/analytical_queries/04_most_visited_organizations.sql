-- =============================================
-- Most visited organizations by encounter count
-- =============================================
-- Insight: Most visited organization is 
--			"VA Boston Healthcare System Jamaica Plain Campus"
--			with 3,217 visits generating 415,456.05$ in 
--			total revenue per encounter, with additional 
--			information of dollars covered by patients 
--			themselves
-- =============================================

SELECT
	organization_name,
	COUNT(encounter_id) AS organization_encounter_count,
	SUM(total_claim_cost) AS revenue, -- Total revenue in dolars
	SUM(total_claim_cost) - SUM(payer_coverage) AS patient_out_of_pocket -- how many patients payed the treatment themselves
FROM gold.vw_encounter_details
GROUP BY organization_name
ORDER BY COUNT(encounter_id) DESC
