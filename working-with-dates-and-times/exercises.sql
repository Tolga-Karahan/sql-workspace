# Taksi yolculuk zamanlarını hesaplayalım ve büyükten küçüğe sıralayalım.
SELECT (tpep_dropoff_datetime - tpep_pickup_datetime) AS "trip_interval"
FROM nyc_yellow_taxi_trips_2016_06_01
ORDER BY trip_interval DESC;

# New York'ta 1 Ocak 2100 olduğunda Londra, Johannesburg, Moskova ve Melbourne'de
# zamanın ne olacağını bulalım.
SELECT '2100-01-01 US/Eastern'::timestamptz AT TIME ZONE 'GMT' AS "time_in_london",
       '2100-01-01 US/Eastern'::timestamptz AT TIME ZONE 'GMT+2' AS "time_in_johannesburg",
       '2100-01-01 US/Eastern'::timestamptz AT TIME ZONE 'GMT+3' AS "time_in_moscow",
       '2100-01-01 US/Eastern'::timestamptz AT TIME ZONE 'GMT+11' AS "time_in_melbourne";

# Taksi verisinde toplam ücret/yolculuk süresi ve toplam ücret/mesafe arasında korrelasyon ve
# r^2 katsayılarını bulalım.
SELECT
		corr(total_amount, 
			 date_part('epoch', tpep_dropoff_datetime - tpep_pickup_datetime)
 			 AS "corr_total_amount_interval",
		regr_r2(total_amount, 
			date_part('epoch', tpep_dropoff_datetime - tpep_pickup_datetime))
			AS "r_squared_total_amount_interval",
		corr(total_amount, trip_distance)
			AS "corr_total_amount_trip_distance",
		regr_r2(total_amount, trip_distance)
			AS "r_squared_total_amount_trip_distance"
FROM nyc_yellow_taxi_trips_2016_06_01;