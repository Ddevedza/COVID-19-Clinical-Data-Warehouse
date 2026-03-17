-- PK NULL check
SELECT id
FROM bronze.organizations
WHERE id IS NULL

-- Unwanted spaces check
SELECT id,state
FROM bronze.organizations
WHERE TRIM(id)!=id or TRIM(state)!=state or TRIM(zip)!=zip or TRIM(phone)!=phone

-- Duplicate check
SELECT id, COUNT(*)
FROM bronze.organizations
GROUP BY id
HAVING COUNT(*) > 1

-- Negative values check (revenue and utilization should be positive)
SELECT id, revenue, utilization
FROM bronze.organizations
WHERE revenue < 0 OR utilization < 0

-- Distinct states (sanity check - should all be valid US state codes)
SELECT DISTINCT state
FROM bronze.organizations
ORDER BY state
