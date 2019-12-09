# Waikiki'de ki yüksek hava sıcaklıklarını, grupları daha da daraltarak inceleyelim
WITH waikiki_temp_analysis (temp_group) AS
	(SELECT CASE WHEN max_temp >= 90 THEN 'Hell'
		         WHEN max_temp BETWEEN 88 AND 89 THEN 'Almost Hell'
		         WHEN max_temp BETWEEN 86 AND 87 THEN 'Too Hot'
				 WHEN max_temp BETWEEN 84 AND 85 THEN 'Hot'
				 WHEN max_temp BETWEEN 82 AND 83 THEN 'Almost Hot'
				 WHEN max_temp BETWEEN 80 AND 81 THEN 'Warm'
				 ELSE 'Cold'
			END
	 FROM temperature_readings
	 WHERE station_name = 'WAIKIKI 717.2 HI US'
	)
SELECT temp_group,
       count(*)
FROM waikiki_temp_analysis
GROUP BY temp_group
ORDER BY count(*) DESC;

# Dondurma tercihi anketi ile oluşturduğumuz pivot tablosunun transpozunu alalım.
SELECT *
FROM crosstab('SELECT flavor,
	                  office,
	                  count(*)
	           FROM ice_cream_survey
	           GROUP BY flavor, office
	           ORDER BY flavor',
	           'SELECT office
	            FROM ice_cream_survey
	            GROUP BY office
	            ORDER BY office')
AS (flavor varchar(20),
	Uptown bigint,
	Midtown bigint,
	Downtown bigint
);