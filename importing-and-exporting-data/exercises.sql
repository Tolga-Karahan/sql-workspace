COPY movies
FROM 'PATH'
WITH (FORMAT CSV, HEADER, DELIMITER ':');

COPY(
	SELECT geo_name, state_us_abbreviation, housing_unit_count_100_percent
	FROM us_counties_2010
	ORDER BY housing_unit_count_100_percent DESC
	LIMIT 20)
TO '/home/apeiron/20_most_housing_states.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

