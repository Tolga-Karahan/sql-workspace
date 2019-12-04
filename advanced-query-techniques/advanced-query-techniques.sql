# Başka sorguların çıktılarını girdi olarak kullanmamız ve ya kategorik değişkenler üretmemiz
# gerekebilir. Bu gibi durumlarda daha ileri SQL sorgu tekniklerini kullanırız.

# WHERE ifadesi ile sorguları filtrelerken karşılaştırma olarak kullanacağımız değerleri
# önceden bilmiyorsak bir alt sorgu kullanabiliriz. Örneğin eyalet nüfus bilgilerini içeren
# tablomuzda nüfusu 90. yüzdelikten büyük olan eyaletleri göstermek istiyor olabiliriz.
SELECT state_us_abbreviation,
       geo_name,
       p0010001
FROM us_counties_2010
WHERE p0010001 > (SELECT percentile_cont(0.9) 
                  WITHIN GROUP (ORDER BY p0010001)
                  FROM us_counties_2010)
ORDER BY p0010001 DESC;

# Büyük bir tablonun üzerinde çalışmaktansa tablonun kopyasını üretip gereksiz satırları sildikten
# sonra çok daha küçük bir tablo üzerinde çalışabiliriz.
CREATE TABLE us_counties_2010_copy AS
	SELECT * FROM us_counties_2010;

DELETE FROM us_counties_2010_copy
WHERE p0010001 < (SELECT percentile_cont(.9) 
	              WITHIN GROUP (ORDER BY p0010001)
				  FROM us_counties_2010_copy
				  );

# Sorgunun sonucunda bir tablo dönüyorsa bu tablo FROM ifadesinde kullanılabilir. Bu tablolar
# derived table olarak adlandırılır. Derived table kullanarak bir sütun üzerindeki mean ve
# medyanı ve farklarını hesaplayabiliriz.
SELECT calcs.mean - calcs.median AS mean_median_diff
FROM (
	 SELECT avg(p0010001) as mean,
            percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) AS median
            FROM us_counties_2010
	 )
AS calcs;

# Türetilmiş tablolar üzerinden join de yapabiliriz. Örneğin bir milyon kişi başına düşen et,
# tavuk ve yumurta üretim tesisinin hangi eyaletlerde en fazla olduğunu bulmak isteyelim. Fakat
# üretim tesislerinin bulunduğu tabloda nüfus bilgisi bulunmuyor. Dolayısıyla ilk önce her bir
# eyaletteki toplam et, tavuk ve yumurta üretim tesisinin sayısını bulmalı ardından eyalet nüfus
# bilgilerini tutan tablo üzerinden her bir eyaletin nüfusunu hesaplamalıyız. Sonuç olarak bu
# türetilmiş tabloları birleştirerek hesaplamalarımızı yapabiliriz.
SELECT plants.st,
       plants.plant_count,
       census.state_pop,
       round(
           CAST(plants.plant_count AS numeric(10, 2)) / census.state_pop * 1000000, 1
       	) AS plants_per_million
FROM
	(
		SELECT st,
		       count(*) AS plant_count
		FROM meat_poultry_egg_inspect
		GROUP BY st
	) 
	AS plants
JOIN
	(
		SELECT state_us_abbreviation,
		       sum(p0010001) AS state_pop
		FROM us_counties_2010
		GROUP BY state_us_abbreviation
	) 
	AS census
ON plants.st = census.state_us_abbreviation
ORDER BY plants_per_million DESC;

# Alt sorgular ile yeni sütunlarda oluşturabiliriz. Örneğin her bir ilçenin yanına medyan ilçe
# nüfusunu ekleyip karşılaştırma yapabiliriz.
SELECT state_us_abbreviation,
       geo_name,
       p0010001 AS pop,
       (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
        FROM us_counties_2010) AS median_pop
FROM us_counties_2010
ORDER BY pop DESC;

# Yeni oluşturulan sütunda hep aynı değeri kullanmaktansa her bir ilçe nüfusunun medyandan ne 
# kadar saptığını hesaplayabiliriz. Farkı +-1000 arasında olan satırları alalım.
SELECT state_us_abbreviation,
       geo_name,
       p0010001 AS pop,
       p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
       FROM us_counties_2010) AS diff_from_median
FROM us_counties_2010
WHERE p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)
       FROM us_counties_2010) between -1000 AND 1000
ORDER BY diff_from_median;

# Alt sorguları IN ifadesi ile birlikte kullanarak birden fazla değer üzerinden karşılaştırma
# yapabiliriz. Benzer şekilde NOT IN ifadesini de bir alt sorgu ile kullanabiliriz. Burada
# dikkat etmemizi gerektiren bir nokta şudur ki, eğer NOT IN ifadesi ile kullandığımız alt
# sorgu NULL değer üretiyorsa; o zaman NOT IN ifadesi herhangi bir satır dönmez. Bu nedenle
# Null değerler söz konusu ise EXISTS/NOT EXISTS kullanmalıyız.
SELECT first_name,
       last_name
FROM employees
WHERE id IN(
	SELECT id
	FROM retirees);

# EXISTS ifadesini bir alt sorgu ile kullanarak basitçe True/False konrolü yapabiliriz. Eğer
# alt sorgu en azından bir satır döndürürse EXISTS ifadesi True olarak hesaplanır. Aşağıdaki
# sorgu retirees tablosundan bir tane satır bile dönerse seçilen tüm employee tablosu 
# sütunlarını yazdırır.
SELECT first_name,
       last_name
FROM employees
WHERE EXISTS(
	SELECT id
	FROM retirees);

# Aşağıdaki sorgu ise idlerde eşleşme olan satırları döndürür.
SELECT first_name,
       last_name
FROM employees
WHERE EXISTS (
	SELECT id
	FROM retirees
	WHERE id = employees.id);

# Sorgu içerisinde kullanabileceğimiz geçici tabloları oluşturmanın bir diğer yöntemi SQL Common Table
# Expression sintaksıdır. Tabloyu oluşturduğumuz ifadeyi ilk önce yazarız. Tablonun isminin yanındaki
# sütunlar, sırasıyla AS keywordünden sonra gelen alt sorgudaki karşılık düşen sütunları referanslar. 
WITH
	large_counties(geo_name, st, p0010001)
AS
	(
		SELECT geo_name, state_us_abbreviation, p0010001
		FROM us_counties_2010
		WHERE p0010001 >= 100000
	)
SELECT st, count(*) AS count
FROM large_counties
GROUP BY st
ORDER BY count DESC;

# Aynı işlemler CTE sintaksı kullanılmadan da yapılabilir. CTE sintaksının sağladığı avantajlar; verilerin
# daha karmaşık analizlerden önce hazırlanmasını sağlaması, ana sorguda aynı alt sorgunun tekrarlanmasına
# gerek kalmaması ve daha okunabilir bir format sunmasıdır.

# Nüfusa göre en fazla et, tavuk ve yumurta üretimine sahip eyaletleri bulduğumuz sorguyu CTE ile tekrar
# yazalım.
WITH
	counties (st, pop) AS (
		SELECT state_us_abbreviation, count(p0010001)
		FROM us_counties_2010
		GROUP BY state_us_abbreviation
		),

	plants (st, plants) AS (
		SELECT st, count(*)
		FROM meat_poultry_egg_inspect
		GROUP BY st
		)
SELECT st,
       pop,
       plants,
       round(CAST(plants AS numeric(10, 2)) / pop * 1000000, 2) AS plants_per_pop
FROM counties JOIN plants
ON counties.st = plants.st
ORDER BY plants_per_pop DESC;

# CTE sintaksını tekrar tekrar yazdığımız alt sorgular için de kullanabiliriz.
WITH us_counties_median AS
	(SELECT percentile_cont(.5)
	 WITHIN GROUP (ORDER BY p0010001) AS counties_median_pop
	 FROM us_counties_2010)

SELECT geo_name,
       state_us_abbreviation AS st,
       p0010001 AS total_pop,
       p0010001 - counties_median_pop AS diff_from_median
FROM us_counties_2010 CROSS JOIN us_counties_median
WHERE p0010001 - counties_median_pop 
	BETWEEN -1000 AND 1000;

# Crosstab kullanarak verileri tablolar halinde özetleyebilir ve değişkenleri karşılaştırabiliriz.
# ANSI SQL crosstab için bir fonksiyon sunmuyor bu nedenle PostgreSQL crosstab() fonksiyonunu
# kullanmalıyız. crosstab() fonksiyonunu kullanabilmek için tablefunc modülünü yüklemeliyiz:
CREATE EXTENSION tablefunc;

# Bir şirketin çalışanlarına dondurma etkinliği yapmak istediğini varsayalım. Bu nedenle şirkete ait
# farklı ofislerde çalışanların tercihlerini öğrenmek için bir anket yapılsın. Elde edilen anket
# verilerini bir crosstab yaparak inceleyelim. 
SELECT *
FROM crosstab('SELECT office,
	                  flavor,
	                  count(*)
	           FROM ice_cream_survey
	           GROUP BY office, flavor
	           ORDER BY office',
	           'SELECT flavor
	           FROM ice_cream_survey
	           GROUP BY flavor
	           ORDER BY flavor')
AS (office varchar(20),
    chocolate bigint,
    strawberry bigint,
    vanilla bigint);
# Yukarıdaki sorguda crosstab() fonksiyonunun ilk argümanı verileri üretirken, ikinci argüman
# sütunlardaki kategorik değerleri belirler.

# Bir başka örnekte ABD'de dört farklı yerde bulunan istasyonların yıllık hava ölçümleri verisi
# var. Her bir istasyonun aylık medyan en yüksek sıcaklık değerine göre crosstab oluşturalım.
SELECT *
FROM crosstab('SELECT station_name AS "station",
	                  date_part(''month'', observation_date) AS "month",
	                  percentile_cont(.5) WITHIN GROUP (ORDER BY max_temp)
	                  AS "median_max_temp"
	           FROM temperature_readings
	           GROUP BY station, month
	           ORDER BY station',

	           'SELECT date_part(''month'', observation_date) AS "month"
	            FROM temperature_readings
	            GROUP BY month
	            ORDER BY month')
				# ve ya 1-12 aylar için şu sorguda kullanılabilir
				# 'SELECT month 
				# FROM generate_series(1,12) month'
AS (station varchar(50),
jan numeric(3,0),
feb numeric(3,0),
mar numeric(3,0),
apr numeric(3,0),
may numeric(3,0),
jun numeric(3,0),
jul numeric(3,0),
aug numeric(3,0),
sep numeric(3,0),
oct numeric(3,0),
nov numeric(3,0),
dec numeric(3,0)
);
