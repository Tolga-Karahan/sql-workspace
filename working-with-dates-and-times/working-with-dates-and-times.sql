# Zaman ile ilgili veri tiplerini inceleyelim:

# date: Sadece tarih bilgisini tutar. Default PostgreSQL formatı ISO 8601 formatı olan YYYY-MM-DD'dir.

# time: Sadece zaman bilgisini tutar. with time zone ifadesini eklersek zaman bölgeleride dikkate alınır.
# Zaman için ISO 8601 formatı HH:MM:SS'dir. 

# timestamp: Tarih ve zamanı birlikte tutar. with time zone ifadesini eklersek zaman bölgeleride dikkate
# alınır. 

# interval: Belirlenen birimde aralık uzunluğunu tutar.

# ANSI SQL ve PostgreSQL fonksiyonlarını kullanarak tarih ve zaman verileri üzerinde çalışabiliriz.
# date_part(text, value) PostgreSQL fonksiyonunu kullanarak tarih ve zaman verilerinden istediğimiz
# kısımları çıkartabiliriz.
SELECT
	date_part('year', CAST('1994-09-23 08:03:17 GMT' AS timestamp with time zone)) AS "year",
	date_part('day', '1994-09-23 08:03:17 GMT'::timestamptz) AS "day",
	date_part('week', '1994-09-23 08:03:17 GMT'::timestamptz) AS "week",
	date_part('quarter', '1994-09-23 08:03:17 GMT'::timestamptz) AS "quarter",
	date_part('epoch', '1994-09-23 08:03:17 GMT'::timestamptz) AS "epoch",
	date_part('timezone_hour', '1994-09-23 08:03:17 GMT'::timestamptz) AS "tz"

# Tarih ve zaman verileri üzerinden herhangi bir parçayı çıkartmak için ANSI SQL extract(text from value)
# fonksiyonunu da kullanabiliriz. Aşağıda saat bileşenini tarih ve zaman verisinden çıkartınca belirlediğimiz
# saatin dönmediğini görebiliriz. Çünkü kodun koştuğu bilgisayarın zaman dilimi ve ya veritabanında belirlenen
# zaman dilimi referans alınır.
SELECT
	extract('hour' from '1994-23-09 08:03:17 GMT'::timestamptz)

# Üzerinde çalıştığımız veri kümesinde tarih ve zaman bileşenleri ayrı ayrı olabilir. Bu durumda bu bileşenleri
# birleştirerek tarih, zaman ve tarih ve zaman sütunları oluşturmak isteyebiliriz.

# make_date(year, month, day) fonksiyonu ile bir tarih sütunu oluşturabiliriz.

# make_time(hour, minute, second) fonksiyonu ile bir zaman sütunu oluşturabiliriz.

# make_timestamptz(year, month, day, hour, minute, second, timezone) fonksiyonu ile bir zaman ve tarih sütunu
# oluşturabiliriz. second parametresi double, timezone ise string veri tipindedir.

SELECT
	make_date(1994, 9, 23) AS "date",
	make_time(8, 3, 17.4) AS "time",
	make_timestamptz(1994, 9, 23, 8, 3, 17.4, 'Europe/Istanbul') AS "timestamp"

# Bir sorgu içerisinde güncel tarih ve zamana ihtiyaç duyarsak aşağıdaki SQL fonksiyonlarını kullanabiliriz:

# current_date, güncel tarihi döndürür.

# current_time, güncel zamanı döndürür.

# current_timestamp, güncel tarih ve zamanı döndürür.

# localtime, güncel zamanı zaman bölgesini dikkate almadan döndürür.

# localtimestamp, güncel tarih ve zamanı zaman bölgesini dikkate almadan döndürür.

# Bu fonksiyonlar sorgu ve ya transactionın başlangıç zamanını dikkate alır. Eğer sorgu icrası boyunca geçen
# saat zamanı dikkate alınarak, işlemin yapıldığı zamanın kullanılmasını istiyorsak PostgreSQL fonksiyonu 
# clock_timestamp() ı kullanabiliriz. Böylece örneğin her satır değiştirildiğinde o satır için o anki zaman
# kullanılır.
CREATE TABLE current_time_comparison(
	time_id bigserial,
	current timestamp with time zone,
	clock_current timestamp with time zone
);

INSERT INTO current_time_comparison (current, clock_current)
	(SELECT current_timestamp, clock_timestamp()
		FROM generate_series(1, 1000));

# Zaman bölgeleri, tarih ve zaman verisinin geçerli olduğu bölgeyi yansıtır. SHOW timezone; komutu ile 
# serverımızın bulunduğu zaman bölgesini öğrenebiliriz. Aşağıdaki sorgu ile zaman bölgelerinin isimlerini,
# kısaltmalarını ve UTC offsetlerini görebiliriz:
SELECT * 
FROM pg_timezone_names;

# WHERE keywordü ile zaman bölgelerini filtreleyebiliriz:
SELECT * 
FROM pg_timezone_names
WHERE name LIKE 'Europe%';

# Serverın default zaman bölgesi ve daha pek çok konfügürasyon parametresi postgresql.conf dosyasında bulunur.
# SET timezone TO komutu ile konfügürasyon dosyasını değiştirmeksizin, sadece bulunduğumuz oturum içerisinde
# zaman bölgesini değiştirebiliriz.
SET timezone TO 'GMT';

# AT TIME ZONE ifadesi ile seçtiğimiz zaman ve tarih bilgisini belirttiğimiz zaman bölgesinde alabiliriz.
SELECT testtime AT TIME ZONE '+03'
FROM testtimezone;

# Tarih ve zaman verileri üzerinde de aritmetik işlemler yapabiliriz.
SELECT '1994/09/23'::date - '1994/09/20'::date;

# date ve interval tipinde verileri toplayabiliriz.
SELECT '1994/09/23'::date + '25 years'::interval;

# New York taksilerinin verilerini içeren veri kümemizi import edelim.
CREATE TABLE nyc_yellow_taxi_trips_2016_06_01(
	trip_id bigserial PRIMARY KEY,
	vendor_id varchar(1) NOT NULL,
	tpep_pickup_datetime timestamp with time zone NOT NULL,
	tpep_dropoff_datetime timestamp with time zone NOT NULL,
	passenger_count integer NOT NULL,
	trip_distance numeric(8,2) NOT NULL,
	pickup_longitude numeric(18,15) NOT NULL,
	pickup_latitude numeric(18,15) NOT NULL,
	rate_code_id varchar(2) NOT NULL,
	store_and_fwd_flag varchar(1) NOT NULL,
	dropoff_longitude numeric(18,15) NOT NULL,
	dropoff_latitude numeric(18,15) NOT NULL,
	payment_type varchar(1) NOT NULL,
	fare_amount numeric(9,2) NOT NULL,
	extra numeric(9,2) NOT NULL,
	mta_tax numeric(5,2) NOT NULL,
	tip_amount numeric(9,2) NOT NULL,
	tolls_amount numeric(9,2) NOT NULL,
	improvement_surcharge numeric(9,2) NOT NULL,
	total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips_2016_06_01 (
vendor_id,
tpep_pickup_datetime,
tpep_dropoff_datetime,
passenger_count,
trip_distance,
pickup_longitude,
pickup_latitude,
rate_code_id,
store_and_fwd_flag,
dropoff_longitude,
dropoff_latitude,
payment_type,
fare_amount,
extra,
mta_tax,
tip_amount,
tolls_amount,
improvement_surcharge,
total_amount
)
FROM 'path_to_data'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

CREATE INDEX tpep_pickup_idx
ON nyc_yellow_taxi_trips_2016_06_01 (tpep_pickup_datetime);

# Müşteri yoğunluklarına göre saatleri sıralayalım.
SELECT date_part('hour', tpep_pickup_datetime) AS "pickup_hour",
       sum(passenger_count) AS "customer_sum"
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY pickup_hour
ORDER BY customer_sum;

# Taksi seferlerinin frekanslarına göre saatleri sıralayalım.
SELECT date_part('hour', tpep_pickup_datetime) AS "pickup_hour",
       count(*) AS freq
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY pickup_hour
ORDER BY freq DESC;

# Elde ettiğimiz sonuçları sonradan görselleştirme yapmak için bir dosyaya da yazabiliriz.
COPY (
		SELECT date_part('hour', tpep_pickup_datetime) AS "pickup_hour",
		       count(*) AS freq
		FROM nyc_yellow_taxi_trips_2016_06_01
		GROUP BY pickup_hour
		ORDER BY freq DESC)
TO 'path_to_file'
WITH (FORMAT CSV, HEADER);

# Yolculuk sürelerine göre saatleri sıralayalım.
SELECT date_part('hour', tpep_pickup_datetime) AS "pickup_hour",
       percentile_cont(0.5) WITHIN GROUP (
           ORDER BY tpep_dropoff_datetime - tpep_pickup_datetime)
           AS "median_trip_interval"
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY pickup_hour
ORDER BY median_trip_interval DESC;

# Tren servisi tablomuzu oluşturalım. Bu veride ABD'yi boydan boya kat eden ve 4 zaman bölgesi içerisinden
# geçen bir tren seferi ile ilgili veriler var. 4 tane zaman bölgesi söz konusu olduğu için hesaplamalara
# dikkat edilmeli.
CREATE TABLE train_rides(
	trip_id bigserial PRIMARY KEY,
	segment varchar(50) NOT NULL,
	departure timestamp with time zone NOT NULL,
	arrival timestamp with time zone NOT NULL
);

INSERT INTO train_rides (segment, departure, arrival)
VALUES ('Chicago to New York', '2017-11-13 21:30 CST', '2017-11-14 18:23 EST'),
	   ('New York to New Orleans', '2017-11-15 14:15 EST', '2017-11-16 19:32 CST'),
	   ('New Orleans to Los Angeles', '2017-11-17 13:45 CST', '2017-11-18 9:00 PST'),
	   ('Los Angeles to San Francisco', '2017-11-19 10:10 PST', '2017-11-19 21:24 PST'),
	   ('San Francisco to Denver', '2017-11-20 9:10 PST', '2017-11-21 18:38 MST'),
	   ('Denver to Chicago', '2017-11-22 19:10 MST', '2017-11-23 14:50 CST');

SET TIME ZONE 'US/Central';

# Her bir segmenti, kalkış saatini ve yolculuk süresini gösterelim.
SELECT segment,
       to_char(departure, 'YYYY-MM-DD HH12:MI a.m. TZ') AS departure,
       arrival - departure AS segment_time
FROM train_rides;

# Segmentler arası toplam yolculuk süresini bulmak için sum() fonksiyonunu OVER keywordü ile birlikte
# kullanarak running sum hesaplayabiliriz. Fakat 24 saatten fazla süren yolculuklarda süre gün ve zaman
# olarak, 24 saatin altında süren yolculuklar için ise sadece zaman olarak verildiği için günler ve zaman
# kendi arasında toplanır ve istenmeyen bir sonuç ortaya çıkar. Bunun etrafından aşağıdaki syntax ile
# dolaşabiliriz:
SELECT segment,
       arrival - departure AS "segment_time",
       sum(date_part('epoch', arrival - departure))
           OVER (ORDER BY trip_id) * interval '1 second' AS "cumulative_time"
FROM train_rides;

# epoch argümanı ile 1 Ocak 1970 tarihinden itibaren geçen saniyeleri tarihten çıkartıyoruz ve arından 
# bir interval ile çarparak veri tipini intervala çeviriyoruz.