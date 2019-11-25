# Aşağıdaki sorguyu koştuğumuzda medyan gelir ile korrelasyon ve r^2 değerinin
# 25 yaş üstü bachelor derecesi olan insan sayısına göre daha düşük olduğunu görüyoruz.
# Yani medyan geliri tahmin etmede bachelor derecesi olan insan sayısı daha iyi bir
# kestirici görevi görüyor. 
SELECT 
		round(
			CAST(corr(median_hh_income, pct_masters_higher) AS numeric), 2)
		AS corr_masters_income,

		round(
			CAST(regr_r2(median_hh_income, pct_masters_higher AS numeric), 3)
		AS r_squared_masters_income
FROM acs_2011_2015_stats;

# Motorlu araç çalınması ve şiddet suçu oranlarına bakalım.
SELECT
		city,
		st,
		population,
		round(
			CAST(motor_vehicle_theft AS numeric) / population * 1000, 2)
		AS motor_vehicle_theft_rate,

		round(
			CAST(violent_crime AS numeric) / population * 1000, 2)
		AS violent_crime_rate
FROM fbi_crime_data_2015
WHERE population > 500000
ORDER BY CAST(motor_vehicle_theft AS numeric) / population * 1000,
		CAST(violent_crime AS numeric) / population * 1000;

# Kütüphaneler tablosundaki kütüphaneleri 1000 kişiye göre ziyaret oranı ile ranklayalım.
SELECT 
		stabr,
		city,
		libname,
		popu_lsa,
		rank() OVER (ORDER BY popu_lsa DESC)
		AS rank_visiting_per_1000
FROM pls_fy2014_pupld14a
WHERE visits > 250000;