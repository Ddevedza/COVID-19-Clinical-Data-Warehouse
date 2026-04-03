-- ========================
-- gold.dim_patient
-- ========================
-- Row count vs silver
SELECT COUNT(*) FROM silver.patients
SELECT COUNT(*) FROM gold.dim_patient

-- No duplicate natural keys
SELECT patient_id, COUNT(*) FROM gold.dim_patient
GROUP BY patient_id HAVING COUNT(*) > 1

-- No negative ages
SELECT COUNT(*) FROM gold.dim_patient WHERE age < 0

-- No future birthdates
SELECT COUNT(*) FROM gold.dim_patient WHERE birthdate > GETDATE()

-- is_deceased flag consistency
SELECT COUNT(*) FROM gold.dim_patient
WHERE (is_deceased = 1 AND deathdate IS NULL)
OR (is_deceased = 0 AND deathdate IS NOT NULL)

-- ========================
-- gold.dim_organization
-- ========================

-- Duplication PM check
SELECT organization_id, COUNT(*) FROM gold.dim_organization
GROUP BY organization_id HAVING COUNT(*) > 1

-- ========================
-- gold.dim_provider
-- ========================
-- Duplication PM check
SELECT provider_id, COUNT(*) FROM gold.dim_provider
GROUP BY provider_id HAVING COUNT(*) > 1

-- ========================
-- gold.dim_payer
-- ========================
-- Duplication PM check
SELECT payer_id, COUNT(*) FROM gold.dim_payer
GROUP BY payer_id HAVING COUNT(*) > 1

-- QOLS still in valid range
SELECT COUNT(*) FROM gold.dim_payer
WHERE qols_avg < 0 OR qols_avg > 1

-- ========================
-- gold.fact_encounter
-- ========================
-- Row count validity check
SELECT COUNT(*) FROM silver.encounters
SELECT COUNT(*) FROM gold.fact_encounter

-- NULL surrogate keys
SELECT COUNT(*) FROM gold.fact_encounter WHERE patient_key IS NULL
SELECT COUNT(*) FROM gold.fact_encounter WHERE organization_key IS NULL
SELECT COUNT(*) FROM gold.fact_encounter WHERE provider_key IS NULL
SELECT COUNT(*) FROM gold.fact_encounter WHERE payer_key IS NULL
SELECT COUNT(*) FROM gold.fact_encounter WHERE date_key IS NULL

-- No duplicate encounter_ids
SELECT encounter_id, COUNT(*) FROM gold.fact_encounter
GROUP BY encounter_id HAVING COUNT(*) > 1

-- No negative costs
SELECT COUNT(*) FROM gold.fact_encounter
WHERE base_encounter_cost < 0
OR total_claim_cost < 0
OR payer_coverage < 0

-- Referential integrity
SELECT f.patient_key FROM gold.fact_encounter f
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_patient p WHERE p.patient_key = f.patient_key)

SELECT f.date_key FROM gold.fact_encounter f
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_date d WHERE d.date_key = f.date_key)

-- ========================
-- gold.fact_condition
-- ========================

-- Row count validity check
SELECT COUNT(*) FROM silver.conditions
SELECT COUNT(*) FROM gold.fact_condition

SELECT COUNT(*) FROM gold.fact_condition WHERE patient_key IS NULL
SELECT COUNT(*) FROM gold.fact_condition WHERE date_key IS NULL

-- is_active flag consistency
SELECT COUNT(*) FROM gold.fact_condition
WHERE (is_active = 1 AND end_date IS NOT NULL)
OR (is_active = 0 AND end_date IS NULL)

-- ========================
-- gold.fact_observation
-- ========================

-- Row count validity check
SELECT COUNT(*) FROM silver.observations
SELECT COUNT(*) FROM gold.fact_observation

-- patient_key should never be NULL
SELECT COUNT(*) FROM gold.fact_observation WHERE patient_key IS NULL
-- encounter_key NULLs expected (~30k)
SELECT COUNT(*) FROM gold.fact_observation WHERE encounter_key IS NULL

-- ========================
-- gold.fact_medication
-- ========================

-- Row count validity check
SELECT COUNT(*) FROM silver.medications
SELECT COUNT(*) FROM gold.fact_medication

-- Row count validity check
SELECT COUNT(*) FROM gold.fact_medication WHERE patient_key IS NULL
SELECT COUNT(*) FROM gold.fact_medication WHERE payer_key IS NULL

-- No negative costs
SELECT COUNT(*) FROM gold.fact_medication
WHERE base_cost < 0 OR payer_coverage < 0 OR totalcost < 0

-- No negative dispenses
SELECT COUNT(*) FROM gold.fact_medication WHERE dispenses <= 0

-- ========================
-- gold.fact_procedure
-- ========================

-- Row count validity check
SELECT COUNT(*) FROM silver.procedures
SELECT COUNT(*) FROM gold.fact_procedure

-- Row count validity check
SELECT COUNT(*) FROM gold.fact_procedure WHERE patient_key IS NULL
SELECT COUNT(*) FROM gold.fact_procedure WHERE date_key IS NULL

-- No negative costs
SELECT COUNT(*) FROM gold.fact_procedure WHERE base_cost < 0

