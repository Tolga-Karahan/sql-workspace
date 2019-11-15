# Analiz etmemiz gereken veriler kirli olabilir. Bu durumda veri içerisinde hatalar,
# kayıp değerler ve ya sorguların verimsiz çalışmasına sebep olan organizasyon problemleri
# bulunabilir. Dosya formatları arasında dönüşümler yapılırken ve ya sütunlar için yanlış
# veri tipleri seçildiğinde veri kaybı oluşabilir. İmla hataları ve karmaşık sütun isimleri
# analizi zorlaştırabilir. 

# FSIS Meat, Poultry and Egg Inspection verisini import ederek üzerinde çalışalım.
CREATE TABLE meat_poultry_egg_inspect(
	est_number varchar(50) CONSTRAINT est_key PRIMARY KEY,
	company varchar(100),
	street varchar(100),
	city varchar(30),
	st varchar(2),
	zip varchar(5),
	phone varchar(14),
	grant_date date,
	activities text,
	dbas text
);

COPY meat_poultry_egg_inspect
FROM 'path_to_file'
WITH (FORMAT CSV, HEADER);

CREATE INDEX company_idx ON meat_poultry_egg_inspect (company);

# Şirket adreslerinde yanlışlıkla bir tekrarlanma olup olmadığına bakalım.
SELECT company,
       city,
       street,
       st,
       count(*) AS company_count
FROM meat_poultry_egg_inspect
GROUP BY company, city, street, st
HAVING count(*) > 1;

# Eyalet sütunu NULL olan satır olup olmadığına bakalım. NULL değerlerin başta ve ya sonda
# gösterilmesi için ORDER BY ifadesine NULLS FIRST ve ya NULLS LAST ekleyebiliriz.
SELECT st,
       count(*) AS st_count
FROM meat_poultry_egg_inspect
GROUP BY st
ORDER BY st NULLS FIRST;

# Eyalet kodu bulunmayan şirketleri inceleyelim.
SELECT est_number,
       company,
       st,
       city,
       street,
       zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;

# Aynı şirkete ait birden fazla lokasyon bulunabilir. Bu lokasyonları şirkete göre gruplama yaparak
# bulabiliriz. Ayrıca gruplama sonucunda aynı şirket isminin farklı şekillerde yazılması sebebiyle
# tutarsızlıklar bulunup bulunmadığını görebiliriz.
SELECT company,
       count(*) AS company_counts
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company; 

# Posta kodu gibi bazı kodların uzunlukları standarttır. Verilerin bu standartlara uyup uymadığını
# anlamak için legth() fonksiyonunu kullanabiliriz. length() fonksiyonu bir string içerisinde bulunan
# karakter sayısını verir.
SELECT length(zip),
       count(*)
FROM meat_poultry_egg_inspect
GROUP BY length(zip) ASC;

