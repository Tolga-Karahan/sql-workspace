# 2000 yılında ilçeyken 2010 yılında statüsü değişen ve ya kaldırıan yerleri bulalım
SELECT c2000.state_us_abbreviation AS state,
       c2000.geo_name
FROM us_counties_2000 AS c2000 LEFT JOIN us_counties_2010 AS c2010
ON c2000.state_fips = c2010.state_fips  
	AND c2000.county_fips = c2010.county_fips
WHERE c2010.county_fips IS NULL;

# İlçe nüfusularının medyan değişim yüzdelerini bulalım
SELECT percentile_cont(0.5)
       WITHIN GROUP (ORDER BY 
       	round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
			/ c2000.p0010001 * 100, 1 ))
FROM us_counties_2000 AS c2000 LEFT JOIN us_counties_2010 AS c2010
ON c2000.state_fips = c2010.state_fips  
	AND c2000.county_fips = c2010.county_fips;

# 2000 ve 2010 yılları arasında en fazla nüfus kaybına uğrayan ilçeyi bulalım
SELECT c2000.state_us_abbreviation AS state,
       c2000.geo_name, 
       round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001)
			/ c2000.p0010001 * 100, 1 ) AS pct_change
FROM us_counties_2000 AS c2000 LEFT JOIN us_counties_2010 AS c2010
ON c2000.state_fips = c2010.state_fips  
	AND c2000.county_fips = c2010.county_fips
ORDER BY pct_change
LIMIT 1;