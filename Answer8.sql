UPDATE [dataanalyst].[dbo].[country_vaccination_stats]
SET daily_vaccinations = 0
WHERE country IN (
    SELECT country
    FROM [dataanalyst].[dbo].[country_vaccination_stats]
    GROUP BY country
    HAVING COUNT(*) = SUM(CASE WHEN daily_vaccinations IS NULL THEN 1 ELSE 0 END)
);

WITH MedianCTE AS (
    SELECT 
        country, 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY daily_vaccinations) OVER (PARTITION BY country) AS median_daily_vaccinations
    FROM 
        country_vaccination_stats
    WHERE 
        daily_vaccinations IS NOT NULL
)
UPDATE cvs
SET daily_vaccinations = median_daily_vaccinations
FROM 
    country_vaccination_stats cvs
INNER JOIN MedianCTE ON cvs.country = MedianCTE.country
WHERE 
    cvs.daily_vaccinations IS NULL;

