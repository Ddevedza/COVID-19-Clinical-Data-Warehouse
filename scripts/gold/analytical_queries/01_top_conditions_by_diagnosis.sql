-- =============================================
-- Top 10 most appeared conditions
-- by total diagnosis count
-- =============================================
-- Insight: Acute conditions dominate total diagnosis
--          counts — viral sinusitis, acute bronchitis
--          and viral pharyngitis rank highest due to
--          repeated seasonal occurrences. Chronic
--          conditions like obesity, prediabetes and
--          hypertension rank lower in total count
--          but show significantly higher active case
--          rates, reflecting their persistent nature.
-- =============================================
SELECT TOP 10 *
FROM gold.vw_condition_prevalence
ORDER BY total_diagnoses DESC

-- =============================================
-- Top 10 conditions by unique patient count
-- =============================================
-- Insight: Rankings by unique patient count are
--          similar to total diagnosis count, with
--          acute respiratory conditions still leading.
--          However chronic conditions like obesity
--          and hypertension maintain high patient
--          counts, confirming they affect a broad
--          portion of the population persistently.
-- =============================================
SELECT TOP 10 *
FROM gold.vw_condition_prevalence
ORDER BY patient_count DESC
