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

