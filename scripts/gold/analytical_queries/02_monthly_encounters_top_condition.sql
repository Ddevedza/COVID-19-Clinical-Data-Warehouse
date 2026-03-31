-- ============================================================
-- Monthly encounter count with top condition
-- ============================================================
-- Insight: Viral sinusitis is consistently the 
--          top diagnosed condition every month
--          regardless of season, suggesting it
--          is the dominant acute condition in
--          this patient population year-round.
--          Thus this analytic is created without 
--          Viral sinusitis so we can have a further
--          look at other possible conditions.
--          Acute viral pharyngitis and acute bronchitis
--          alternate as the most common condition month
--          to month with no clear seasonal pattern,
--          suggesting they are endemic rather than seasonal
--          in this patient population.
--          Encounter counts peak in summer months
--          (May-July) and dip in February.
-- ============================================================

-- Monthly encounter number
WITH MonthlyEncounters AS (
    SELECT
        d.month,
        d.month_name,
        COUNT(e.encounter_key) AS encounter_count
    FROM gold.fact_encounter e
    LEFT JOIN gold.dim_date d ON d.date_key = e.date_key
    GROUP BY d.month, d.month_name
),
-- Conditions count + conditions ranked, per month
RankedConditions  AS (
    SELECT
        d.month,
        c.description AS top_condition,
        COUNT(*) AS condition_count,
        ROW_NUMBER() OVER (
            PARTITION BY d.month
            ORDER BY COUNT(*) DESC
        ) AS rank_num
    FROM gold.fact_condition c
    LEFT JOIN gold.dim_date d ON d.date_key = c.date_key
    WHERE c.description != 'Viral sinusitis (disorder)' -- viral sinusitis is excluded as it is most appeared in all cases
    GROUP BY d.month, c.description

)
SELECT
    me.month,
    me.month_name,
    me.encounter_count,
    rc.top_condition,
    rc.condition_count AS top_condition_count
FROM MonthlyEncounters me
LEFT JOIN RankedConditions rc 
    ON rc.month = me.month 
    AND rc.rank_num = 1 -- rank one as we want to catch the top condition
ORDER BY me.month ASC
