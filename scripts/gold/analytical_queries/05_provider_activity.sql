-- =============================================
-- Most active providers by encounter count
-- with patient outcome breakdown
-- =============================================
-- Insight: Gaynell Streich takes the top place
--          with 3,983 patient encounters in total.
--          This busiest doctor's statistic showcase
--          that in average each patient visited
--          108 times.
-- =============================================
SELECT
    pr.provider_name,
    pr.specialty,
    COUNT(e.encounter_id) AS encounter_count,
    COUNT(DISTINCT e.patient_key) AS unique_patients,
    CAST(COUNT(e.encounter_id) AS FLOAT) 
        / NULLIF(COUNT(DISTINCT e.patient_key), 0) AS avg_encounters_per_patient,
    COUNT(DISTINCT CASE WHEN p.is_deceased = 1 THEN e.patient_key END) AS deceased_patient_count,
    COUNT(DISTINCT CASE WHEN p.is_deceased = 0 THEN e.patient_key END) AS alive_patient_count
FROM gold.fact_encounter e
LEFT JOIN gold.dim_patient p ON e.patient_key = p.patient_key
LEFT JOIN gold.dim_provider pr ON e.provider_key = pr.provider_key
GROUP BY pr.provider_name, pr.specialty
ORDER BY encounter_count DESC

-- =============================================
-- Most active providers by patient count
-- with patient outcome breakdown
-- =============================================
-- Insight: When ranked by unique patients, Vern Powlowski
--          leads with 81 unique patients despite ranking
--          3rd by total encounter count, suggesting he
--          sees a broader but less frequent patient base
--          compared to the top encounter count providers.
-- =============================================
SELECT
    pr.provider_name,
    pr.specialty,
    COUNT(DISTINCT e.patient_key) AS unique_patients,
    COUNT(DISTINCT CASE WHEN p.is_deceased = 1 THEN e.patient_key END) AS deceased_patient_count,
    COUNT(DISTINCT CASE WHEN p.is_deceased = 0 THEN e.patient_key END) AS alive_patient_count,
    COUNT(e.encounter_id) AS encounter_count,
    CAST(COUNT(e.encounter_id) AS FLOAT) 
        / NULLIF(COUNT(DISTINCT e.patient_key), 0) AS avg_encounters_per_patient
FROM gold.fact_encounter e
LEFT JOIN gold.dim_patient p ON e.patient_key = p.patient_key
LEFT JOIN gold.dim_provider pr ON e.provider_key = pr.provider_key
GROUP BY pr.provider_name, pr.specialty
ORDER BY unique_patients DESC
