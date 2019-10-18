# New York eyaletindeki en yüksek kızılderili yüzdesine sahip ilçe
SELECT	geo_name, 
		state_us_abbreviation, 
		round(CAST(p0010005 AS numeric(6,1)) / p0010001 * 100, 2)
		AS "indian/alaska_native_alone_pct"
FROM us_counties_2010
WHERE state_us_abbreviation = 'NY'
ORDER BY "indian/alaska_native_alone_pct" DESC
LIMIT 1;

# 2010 CA ve NY nüfus medyanları
SELECT
	(SELECT percentile_cont(0.5)
			WITHIN GROUP (ORDER BY p0010001)
	FROM us_counties_2010
	WHERE state_us_abbreviation = 'CA')
	AS "CA_median",
	
	(SELECT percentile_cont(0.5)
			WITHIN GROUP (ORDER BY p0010001)
	FROM us_counties_2010
	WHERE state_us_abbreviation = 'NY')
	AS "NY_median";

