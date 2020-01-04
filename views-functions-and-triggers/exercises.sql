# New York taksilerinin saate göre sefer sayısını veren bir view yazalım
CREATE OR REPLACE VIEW trips_per_hour AS
	SELECT extract(hour from tpep_pickup_datetime) AS trip_hour,
	       COUNT(*)
	FROM nyc_yellow_taxi_trips_2016_06_01
	GROUP BY extract(hour from tpep_pickup_datetime)
	ORDER BY trip_hour;

# Faklı ölçeklerde değişkenlerin oranlarını karşılaştırmak yanıltıcı olabilir.
# Bu nedenle mesela her bin birim için oran hesaplayan bir fonksiyon yazalım.
CREATE OR REPLACE FUNCTION
rate_by_thousands(observerd_number numeric,
				  base_number numeric,
				  decimal_places integer DEFAULT 1)
RETURNS numeric AS 
$$
BEGIN
	SELECT ROUND(observerd_number / base_number * 1000, decimal_places);
END;
$$
LANGUAGE plpgsql
IMMUTABLE
RETURNS NULL ON NULL INPUT;

# Et ve tavuk üreticilerinin bulunduğu tabloya yeni bir kayıt girildiğinde
# otomatik olarak teftiş tarihini ekleyen bir trigger yazalım.
CREATE OR REPLACE FUNCTION assign_inspect_date()
RETURNS TRIGGER AS
$$
BEGIN
	NEW.inspect_date = (SELECT dt.inspect_date
					    FROM state_regions reg JOIN region_dates dt
					    ON reg.region = dt.region
					    WHERE reg.st = NEW.st);
	RETURN NEW;
END;
$$
LANGUAGE plpgsql
IMMUTABLE;

CREATE TRIGGER insert_inspect
	BEFORE INSERT
		ON meat_poultry_egg_inspect
	FOR EACH ROW
	EXECUTE PROCEDURE assign_inspect_date();

# Triggerımızı deneyelim.
INSERT INTO meat_poultry_egg_inspect (est_number, city, st)
VALUES ('dsfsf', 'ameriga', 'CA');

SELECT *
FROM meat_poultry_egg_inspect
WHERE est_number = 'dsfsf';