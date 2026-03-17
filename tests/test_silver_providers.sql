-- PK Null Check
SELECT id
FROM bronze.providers
WHERE id IS NULL

-- PK duplicate check
SELECT id, COUNT(*) counted
FROM bronze.providers
GROUP BY id
HAVING COUNT(*)>1

-- FK check
SELECT organization FROM bronze.providers
WHERE organization NOT IN (SELECT id FROM bronze.organizations)

-- gender distinction column check
SELECT DISTINCT(gender)
FROM bronze.providers

-- specialty distinction column check
SELECT DISTINCT(specialty)
FROM bronze.providers

-- Space check
SELECT id
FROM bronze.providers
WHERE id!=TRIM(id) or organization!=TRIM(organization) or state!=TRIM(state) or zip!=TRIM(zip)

-- name string check
SELECT name
FROM bronze.providers
WHERE name LIKE '%[0-9]%';

-- Negative utilization check
SELECT id, utilization
FROM bronze.providers
WHERE utilization < 0

-- State domain validation
SELECT DISTINCT state
FROM bronze.providers
ORDER BY state
