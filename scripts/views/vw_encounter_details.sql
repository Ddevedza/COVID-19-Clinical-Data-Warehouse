-- =============================================
-- View: gold.vw_encounter_details
-- Description: One row per clinical encounter
--              with patient, provider, organization
--              and payer attributes joined in.
-- Grain: One row per encounter
-- Note: Patient names repeat across multiple rows
--       as each row represents a distinct visit
-- =============================================

CREATE VIEW gold.vw_encounter_details AS
SELECT
    e.encounter_id, --
    p.full_name AS patient_name, -- full patient name
    p.age,
    p.gender,
    pr.provider_name, -- doctor who provided the care
    pr.specialty, -- docto's field
    o.organization_name, -- organization in which the healthcare is provided
    o.organization_city, -- organizations city
    py.payer_name, -- who payers for the healthcare provision
    e.encounterclass, 
    e.description, -- ecnounter description
    e.reasondescription, -- reason of the encounter
    d.full_date AS encounter_date, -- full date of encounter
    d.year AS encounter_year,
    d.month_name AS encounter_month,
    e.base_encounter_cost,
    e.total_claim_cost,
    e.payer_coverage
FROM gold.fact_encounter e
LEFT JOIN gold.dim_patient p ON p.patient_key = e.patient_key
LEFT JOIN gold.dim_organization o ON o.organization_key = e.organization_key
LEFT JOIN gold.dim_provider pr ON pr.provider_key = e.provider_key
LEFT JOIN gold.dim_payer py ON py.payer_key = e.payer_key
LEFT JOIN gold.dim_date d ON d.date_key = e.date_key
