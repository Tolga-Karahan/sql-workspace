# Aggregate fonksiyonları, birden fazla satırda bulunan değerler üzerinde işlem yaparak
# tek bir değer döndürür. Bazı aggregate fonksiyonları aşağıdaki gibidir:

# count() fonksiyonu satır sayısını sayar. count(*) kullanımı NULL değerler de dahil olmak
# üzere tablodaki tüm satır sayısını verir. count(column_name) kullanımı, argüman olarak
# verilen sütundaki NULL içermeyen satır sayısını verir. count() fonksiyonunu DISTINCT
# keywordü ile birlikte kullanırsak sütun içerisindeki unique değer sayısını elde ederiz.
SELECT count(DISTINCT libname);

# max() ve min() fonksiyonları argüman olarak aldığı sütunun maksimum ve minimum elemanlarını
# döndürür. Bazen negatif değerler ve ya çok yüksek değerler çeşitli durumları temsil etmek için
# kullanılabilirler. Bu durumda sütun üzerindeki istatistikler hatalı çıkabilir. Bunu önceden
# tespit etmek için max() ve min() fonksiyonlarını kullanabiliriz. Tablolar oluşturulurken
# böyle bir kullanım yerine, negatif ve ya çok büyük değerler için NULL kullanabiliriz. Sebebini
# açıklamak içinse flag görevi görecek bir sütun ekleyerek daha doğru bir tasarım yapmış oluruz.
SELECT max(visits), min(visits)
FROM pls_fy2014_pupld14a;

# GROUP BY ifadesi ile bir veya birden fazla sütun kullanarak gruplar oluşturabiliriz ve bu 
# gruplar üzerinde aggregation fonksiyonları kullanabiliriz. SELECT ifadesi ile seçtiğimiz
# sütunlar ya bir aggregate fonksiyonunun argümanı olmalıdır ya da GROUP BY ifadesi ile birlikte
# kullanılmalıdır. 
SELECT stabr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr
ORDER BY stabr DESC;

# Birden fazla sütun üzerinden de gruplama yapabiliriz.
SELECT stabr, stataddr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr, stataddr
ORDER BY stabr ASC, count(*) DESC;

# 2009 ve 2014 yılında açık olan kütüphanelerdeki ziyaretçi değişimine bakalım.
SELECT sum(l2009.visits) AS visits_09,
	   sum(l2014.visits) AS visits_14,
	   sum(l2009.visits) - sum(l2014.visits) AS difference
FROM pls_fy2009_pupld09a l2009 JOIN pls_fy2014_pupld14a l2014
ON l2009.fscskey = l2014.fscskey
WHERE l2009.visits >= 0 AND l2014.visits >= 0;

# 2009 ve 2014 yılında açık olan kütüphanelerdeki ziyaretçi değişimini eyaletlere göre inceleyelim.
SELECT l2009.stabr,
       sum(l2009.visits) AS visits_09,
       sum(l2014.visits) AS visits_14,
       round((CAST(sum(l2009.visits) AS numeric (10, 1)) - sum(l2014.visits))
	   / sum(l2009.visits) * 100, 2) AS percent_change
FROM pls_fy2009_pupld09a l2009 JOIN pls_fy2014_pupld14a l2014
ON l2009.fscskey = l2014.fscskey
GROUP BY l2009.stabr
ORDER BY percent_change DESC;





