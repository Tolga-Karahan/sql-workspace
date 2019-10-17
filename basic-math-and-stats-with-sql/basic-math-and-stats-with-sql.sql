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





