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

