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
	make_time(1994, 9, 23, 8, 3, 17.4, 'Europe/Istanbul') AS "timestamp"

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