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
# böyle bir kullanım yerine, negatif ve ya çok büyük değerler için NULL kullanabiliriz. Sebenini
# açıklamak içinse flag görevi görecek bir sütun ekleyerek daha doğru bir tasarım yapmış oluruz.
SELECT max(visits), min(visits)
FROM pls_fy2014_pupld14a;

# GROUP BY ifadesi ile bir veya birden fazla sütun kullanarak gruplar oluşturabiliriz ve bu 
# gruplar üzerinde aggregation fonksiyonlarıı kullanabiliriz. 
SELECT stabr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr
ORDER BY stabr DESC;

# Birden fazla sütun üzerinden de gruplama yapabiliriz.
SELECT stabr, stataddr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr, stataddr
ORDER BY stabr ASC, count(*) DESC;






