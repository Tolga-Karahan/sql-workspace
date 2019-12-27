# Her bir eyaletin toplam alanını bulalım.
SELECT statefp10 AS st,
       sum(
       	  round(
       	       (ST_Area(geom::geography))::numeric, 2
       	       )
       	  ) AS total_area
FROM county_shapes
GROUP BY st
ORDER BY total_area DESC;

# Oakleaf Greenmarket ve Columbia Farmers Market arasındaki uzaklığı bulalım.
WITH 
	oakleaf_green_market_coordinates (coordinates) AS(
	
	SELECT geog_point
	FROM farmers_markets
	WHERE market_name = 'The Oakleaf Greenmarket'
),

	columbia_farmers_coordinates (coordinates) AS(

	SELECT geog_point
	FROM farmers_markets
	WHERE market_name = 'Columbia Farmers Market'
)

SELECT ST_Distance(ogc.coordinates,
                   cfc.coordinates)
FROM oakleaf_green_market_coordinates ogc CROSS JOIN
     columbia_farmers_coordinates cfc;

# Pazarların olduğu tabloda şehir(county) sütunu eksik olan pazarlar var. Eksik olan şehirleri, şehirlerin
# uzamsal bilgilerinin tutulduğu counties_shapes tablosu ile uzamsal birleştirme yaparak bulalım.
SELECT markets.market_name,
	   counties.name10
FROM farmers_markets markets JOIN county_shapes counties
     ON ST_Intersects(markets.geog_point,
                      ST_SetSRID(counties.geom::geography, 4326))
WHERE markets.county IS NULL;