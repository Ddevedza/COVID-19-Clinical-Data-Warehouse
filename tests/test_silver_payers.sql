-- FK NULL check
SELECT 
	id
FROM bronze.payers
WHERE id IS NULL

-- Duplicate check
SELECT id, COUNT(*)
FROM bronze.payers
GROUP BY id
HAVING COUNT(*) > 1

-- Unexpected spaces
SELECT id, name
FROM bronze.payers
WHERE TRIM(id) != id OR TRIM(state_headquartered) != state_headquartered OR TRIM(zip) != zip OR TRIM(phone) != phone

-- Negative financial values
SELECT id, name, amount_covered, amount_uncovered, revenue,
    covered_encounters, uncovered_encounters,
    covered_medications, uncovered_medications,
    covered_procedures, uncovered_procedures,
    covered_immunizations, uncovered_immunizations
FROM bronze.payers
WHERE amount_covered < 0 
OR amount_uncovered < 0 
OR revenue < 0
OR covered_encounters < 0 OR uncovered_encounters < 0
OR covered_medications < 0 OR uncovered_medications < 0
OR covered_procedures < 0 OR uncovered_procedures < 0
OR covered_immunizations < 0 OR uncovered_immunizations < 0

-- State domain validation
SELECT DISTINCT state_headquartered
FROM bronze.payers
ORDER BY state_headquartered


-- QOLS average sanity check (Quality of Life Score - should be between 0 and 1)
SELECT id, name, qols_avg
FROM bronze.payers
WHERE qols_avg < 0 OR qols_avg > 1
