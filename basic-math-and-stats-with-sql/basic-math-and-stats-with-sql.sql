# '+', '-', '*' ve '/' operatörleri ANSI SQL'de bulunur. Diğer operatörler
# PostgreSQL'e özgüdür. Mod için '%', üs alma için '^', karekök için '|/',
# küpkök için '||/', faktöriyel için '!' operatörlerini kullanıyoruz.

# Integerlardan oluşan işlemlerde sonuç tipi integer, işlemde herhangi bir
# numeric bulunması durumunda sonuç numeric, bir floating-point sayı
# bulunması durumunda double precision a sahip bir floating-point sayı,
# üs alma, kök operatörleri ve faktöriyel işlemleri numeric ve floating-point
# sonuçlar döndürür.

SELECT 2 + 3;
SELECT 8 ||/;
SELECT 5!;
SELECT ||/ 2 ^ 3;
SELECT CAST(11 AS numeric(3, 1)) / 3;

# Parantezler kullanarak işlem önceliklerini değiştirebiliriz.
SELECT (2 + 3) * 4;

# Veri üzerinden Asya kökenli olanların nüfusa oranını bulalım.
SELECT geo_name,
	state_us_abbreviation AS state,
	(CAST(p0010006 AS numeric(8,1)) / p0010001) * 100 AS "pct_asian"
FROM us_counties_2010
ORDER BY pct_asian DESC;

# Sayısal değerler içeren sütunlarda belirli bir periyottaki yüzdelik değişime
# bakmak faydalı bilgiler sağlayabilir. Bir tablo tasarlayalım ve yüzdelik
# değişimleri veren bir sütun oluşturalım.
CREATE TABLE spendings (
	department varchar(20),
	spending_2018 numeric(10,2),
	spending_2019 numeric(10,2)
);

INSERT INTO spendings
VALUES
	('Building', 517218, 475321),
	('Bills', 746528, 854129),
	('Tax', 321475, 364781),
	('Operations', 65128, 324789);

SELECT department,
	round((spending_2019 - spending_2018) / spending_2018 * 100, 5) AS spending_pct_change
FROM spendings
ORDER BY spending_pct_change DESC;

# Aynı sütun üzerinde sum(), avg() gibi fonksiyonlar kullanarak aggregate yapabiliriz.
SELECT sum(p0010001) AS "County Sum",
       round(avg(p0010001), 2) AS "County Average"
FROM us_counties_2010;

# ANSI SQL ve ya PostgreSQL'de medyan için bir fonksiyon bulunmaz. Medyanı ve diğer
# yüzdelik dilimleri bulmak için percentile() fonksiyonunu kullanabiliriz. Çünkü
# medyan zaten 50. yüzdelik dilime eşit. ANSI SQL'de yüzdelik dilimleri hesaplamak
# için iki tane fonksiyon var: percentile_cont() ve percentile_disc(n). İlk fonksiyon
# yüzdelik dilimleri sürekli değişkenler olarak hesaplar, yani sonucun veri kümesinde
# bulunan bir değere eşit olması gerekmez. İkinci fonksiyon ise sonucu yuvarlayarak
# veri kümesinde bulunan bir değere eşitler.
CREATE TABLE percentile_test (
	numbers smallint
);

INSERT INTO percentile_test 
VALUES (1), (2), (3), (4), (5), (6);

SELECT 
	percentile_cont(0.5) 
	WITHIN GROUP (ORDER BY numbers),
	percentile_disc(0.5)
	WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

SELECT sum(p0010001) AS "County_Sum",
	   round(avg(p0010001), 2) AS "County_Average",
	   percentile_cont(.5)
	   WITHIN GROUP (ORDER BY p0010001) AS "County_Median"
FROM us_counties_2010;

# Birden fazla yüzdelik dilim hesaplamak isteyebiliriz. Örneğin çeyreklere bakabiliriz.
# Tek seferde tüm noktaları vermek için SQL array veri tipini kullanmalıyız.
SELECT percentile_cont(array[.25, .5, .75])
       WITHIN GROUP (ORDER BY p0010001)
       AS "Quartiles"
FROM us_counties_2010;

# Array veri tipi üzerinde çalışan çeşitli fonksiyonlar var. unnest() fonksiyonu sonuçları
# satırda göstererek daha kolay okunabilir hale getiriyor.
SELECT unnest(
	percentile_cont(array[0.25, 0.5, 0.75])
	WITHIN GROUP (ORDER BY p0010001)	
) AS "Quartiles"
FROM us_counties_2010;

# Standart SQL'de mod için de bir fonksiyon bulunmaz. Sütun üzerinden mod bulmak için
# PostgreSQL fonksiyonu olan mode() fonksiyonunu kullanabiliriz.
SELECT mode() WITHIN GROUP (ORDER BY p0010001)
FROM us_counties_2010;