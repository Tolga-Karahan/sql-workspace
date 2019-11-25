# SQL standardı analiz için bazı istatistik fonksiyonlarını sağlamaktadır. 
# Çalışacağımız tabloyu oluşturalım ve verileri okuyalım.
CREATE TABLE acs_2011_2015_stats(
	geoid varchar(14) CONSTRAINT geoid_key PRIMARY KEY,
	county varchar(50) NOT NULL,
	st varchar(20) NOT NULL,
	pct_travel_60_min numeric(5,3) NOT NULL,
	pct_bachelors_higher numeric(5,3) NOT NULL,
	pct_masters_higher numeric(5,3) NOT NULL,
	median_hh_income integer,
	CHECK (pct_masters_higher <= pct_bachelors_higher)
);

COPY acs_2011_2015_stats
FROM 'path_to_data'
WITH (FORMAT CSV, HEADER);

# SQL kullanarak değişkenlerin korrelasyonuna bakabiliriz. Bunun için corr(Y, X) fonksiyonunu kullanıyoruz.
# Medyan hane geliri ve lisans derecesi arasında korrelasyon olup olmadığına bakalım. 
SELECT corr(median_hh_income, pct_bachelors_higher)
    AS bachelors_income_r
FROM acs_2011_2015_stats;

# Bazı diğer korrelasyonlara bakalım. round fonksiyonunu kullanabilmek için CAST fonksiyonu ile floating-point 
# değerden numeric veri tipine dönüşüm gerekiyor.
SELECT round(
	        CAST(corr(median_hh_income, pct_travel_60_min) AS numeric), 2)
	        AS income_travel_r,

	   round(
	   	    CAST(corr(pct_bachelors_higher, pct_travel_60_min) AS numeric), 2)
	        AS bachelor_travel_r
FROM acs_2011_2015_stats;

# Lineer regresyon ile bağımlı bir değişken ile bağımsız değişken arasındaki lineer ilişkiyi bulabiliriz.
# Y = bX + a, ifadesinde eğimi regr_slope(Y,X) fonksiyonu ile y eksenini kesen noktayı ise regr_intercept(Y,X)
# fonksiyonu ile bulabiliriz.
SELECT round(
            CAST(regr_slope(median_hh_income, pct_bachelors_higher) AS numeric), 2)
            AS slope,

        round(
        	CAST(regr_intercept(median_hh_income, pct_bachelors_higher) AS numeric), 2)
        	AS intercept
FROM acs_2011_2015_stats;  

# Korrelasyon katsayısı r'nin karesi bize bağımsız değişkenin bağımlı değişkendeki varyansı ne kadar açıklayabildiğini
# gösterir. SQL'de regr_r2(Y,X) fonksiyonu ile r-squared değerini hesaplayabiliriz.
SELECT round(
			CAST(regr_r2(median_hh_income, pct_bachelors_higher) AS numeric), 2)
			AS r_squared
FROM acs_2011_2015_stats;

# SQL fonksiyonları rank() ve dense_rank() fonksiyonlarını kullanarak ranklama yapabiliriz. Bu iki fonksiyonda
# bir pencere boyutu kullanarak belirlediğimiz sayıda satır üzerinden işlem yapar. Fakat her bir satır için bir
# sonuç döndürürler. Malzeme üreten firmalar ve üretim sayılarını içeren bir tablo oluşturalım ve bu tablo 
# üzerinden ranklama yapalım.
CREATE TABLE widget_companies (
id bigserial,
company varchar(30) NOT NULL,
widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
('Morse Widgets', 125000),
('Springfield Widget Masters', 143000),
('Best Widgets', 196000),
('Acme Inc.', 133000),
('District Widget Inc.', 201000),
('Clarke Amalgamated', 620000),
('Stavesacre Industries', 244000),
('Bowers Widget Emporium', 201000);

# rank() fonksiyonu sayı eşitliği olması durumunda sırada bir boşluk oluşmasına izin verir. dense_rank()
# fonksiyonu ise sırada bir boşluk oluşmasına izin vermez.
SELECT
	company,
	rank() OVER (ORDER BY widget_output DESC),
	dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies;

# Tüm satırlar için değil bazı satır grupları için ranklama yapmak istiyorsak PARTITION BY ifadesini kullanırız.
# Bu kullanımı gösterebilmek için bir market tablosu oluşturalım ve markette bulunan her bir kategoriye göre satışlar
# üzerinden ranklama yapalım.
CREATE TABLE store_sales (
store varchar(30),
category varchar(30) NOT NULL,
unit_sales bigint NOT NULL,
CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
('Broders', 'Cereal', 1104),
('Wallace', 'Ice Cream', 1863),
('Broders', 'Ice Cream', 2517),
('Cramers', 'Ice Cream', 2112),
('Broders', 'Beer', 641),
('Cramers', 'Cereal', 1003),
('Cramers', 'Beer', 640),
('Wallace', 'Cereal', 980),
('Wallace', 'Beer', 988);

SELECT 
		company,
		category,
		unit_sales,
		rank() OVER (PARTITION BY category ORDER BY store_sales DESC)
FROM store_sales;

# Ham veri üzerinden ranklama yapmak yanıltıcı sonuçlar üretebilir. Örneğin iki şehri işlenen suç vakaları
# arasından ranklarsak, karşılaşılan vaka çok olan şehrin daha problemli olduğunu düşünebiliriz ama aynı
# zamanda bu şehirlerin nüfuslarını da dikkate almak gerekir. Bunun için oranları kullanabiliriz. Örneğin
# her 1000 kişi için işlenen suç oranına bakabiliriz.
CREATE TABLE fbi_crime_data_2015 (
	st varchar(20),
	city varchar(50),
	population integer,
	violent_crime integer,
	property_crime integer,
	burglary integer,
	larceny_theft integer,
	motor_vehicle_theft integer,
	CONSTRAINT st_city_key PRIMARY KEY (st, city)
);

COPY fbi_crime_data_2015
FROM 'path_to_data'
WITH (FORMAT CSV, HEADER);

SELECT 
	city,
	st,
	population,
	property_crime,
	round(CAST(property_crime AS numeric) / population * 1000, 1)
	AS prp_crm_per_1000
FROM fbi_crime_data_2015
WHERE population > 500000
ORDER BY CAST(property_crime AS numeric) / population * 1000 DESC;