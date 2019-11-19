# Analiz etmemiz gereken veriler kirli olabilir. Bu durumda veri içerisinde hatalar, kayıp değerler
# ve ya sorguların verimsiz çalışmasına sebep olan organizasyon problemleri bulunabilir. Dosya
# formatları arasında dönüşümler yapılırken ve ya sütunlar için yanlış veri tipleri seçildiğinde
# veri kaybı oluşabilir. İmla hataları ve karmaşık sütun isimleri analizi zorlaştırabilir. 

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

# Aynı şirkete ait birden fazla tesis bulunabilir. Dolayısıyla şirkete kayıtlı birden fazla adres
# bulunabilir. Bu adresleri şirkete göre gruplama yaparak bulabiliriz. Ayrıca gruplama sonucunda
# aynı şirket isminin farklı şekillerde yazılması sebebiyle tutarsızlıklar bulunup bulunmadığını
# görebiliriz.
SELECT company,
       count(*) AS company_counts
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company; 

# Posta kodu gibi bazı kodlar standart uzunluklara sahiptir. Verilerin bu standartlara uyup uymadığını
# anlamak için length() fonksiyonunu kullanabiliriz. length() fonksiyonu bir string içerisinde bulunan
# karakter sayısını verir.
SELECT length(zip),
       count(*)
FROM meat_poultry_egg_inspect
GROUP BY length(zip) ASC;

# Posta kodu standart uzunluktan az olan şirketlerden hangi eyalette kaç tane bulunduğunu gösterelim.
SELECT st,
       count(*) AS st_count
WHERE length(zip) < 5
GROUP BY st
ORDER BY st;

# Veritabanları oluşturulduktan sonra nadiren aynı kalır. Yeni tablolar, sütunlar eklenir, veri tipleri
# ve değerler değiştirilir. Veritabanında değişiklikler yapılırken yaygın olarak kullanılan iki komut
# ALTER TABLE ve UPDATE komutlarıdır. ALTER TABLE komutu sütun eklemek, değiştirmek, düşürmek ve benzer
# işlevleri sağlar. UPDATE komutu ise tablolarda bulunan verileri değiştirmemizi sağlar.

# ALTER TABLE ifadesi ile tabloların yapılarını değiştiririz. Bazı yaygın işlemler aşağıdaki gibidir:

# Tabloya yeni bir sütun eklerken ALTER TABLE ifadesini şu şekilde kullanırız. Bu ifade sadece sütunu
# ekler, ayrıca sütunu veriler ile doldurmak gereklidir.
ALTER TABLE table_name ADD COLUMN column data_type;

# Tablodan bir sütunu silerken ise ALTER TABLE ifadesini şu şekilde kullanırız:
ALTER TABLE table_name DROP COLUMN column;

# Tablodaki bir sütunun veri tipini şu şekilde değiştiririz:
ALTER TABLE table_name ALTER COLUMN column SET DATA TYPE data_type;

# Tablodaki bir sütuna NOT NULL constraint ekleyelim, tabi constraint ekleyeceğimiz sütun constraint
# şartlarını karşılamalıdır:
ALTER TABLE table_name ALTER COLUMN column SET NOT NULL;

# Tablodaki bir sütunda var olan NOT NULL constrainti şu şekilde sileriz:
ALTER TABLE table_name ALTER COLUMN column DROP NOT NULL;

# Bir sütunun tamamında ve ya bir bölümünde verileri değiştirmek için UPDATE ifadesini kullanırız.
# Sütunda bulunan tüm değerleri aşağıdaki gibi değiştirebiliriz:
UPDATE table_name
SET column=value;
# value ile belirtilen kısıma herhangi bir değer, başka bir sütun ve ya değer üreten bir sorgu yazabiliriz.

# Aynı anda birden fazla sütuna ait değeri de değiştirebiliriz:
UPDATE table_name
SET column1=value1,
    column2=value2;

# Eğer sütunun sadece belirli bir kriteri karşılayan bir alt kümesini değiştirmek istiyorsak WHERE ifadesini
# kullanabiliriz.
UPDATE table_name
SET column1=value1
WHERE criteria;

# Başka bir tabloya ait bir sütunu kullanarakta değerleri değiştirebiliriz. EXISTS ile verilerin NULL olmasını
# engelledik.
UPDATE table1
SET col1= (SELECT col2
           FROM table2
           WHERE table1.col1 = table2.col2)
WHERE EXISTS (SELECT col2
              FROM table2
              WHERE table1.col1 = table2.col2);

# Veriler üzerinde değişiklik yapmadan önce tablomuzu yedeklemek isteyebiliriz. Yedek tabloda indeksler yeniden
# oluşturulmaz.
CREATE TABLE meat_poultry_egg_inspect_backup AS 
SELECT * FROM meat_poultry_egg_inspect;

# Tablomuzu analiz ederken eyalet bilgilerinin olduğu st sütununda NULL değerler olduğunu görmüştük. Bu değerleri
# bulduktan sonra UPDATE ifadesi ile güncelleyelim. Tablomuzu yedeklememize rağmen ekstra önlem olarak işlem
# yapacağımız sütunu da yedekleyebiliriz.
ALTER TABLE meat_poultry_egg_inspect ADD COLUMN st_copy varchar(2);
UPDATE meat_poultry_egg_inspect
SET st_copy=st;

UPDATE meat_poultry_egg_inspect
SET st = 'MN'
WHERE est_number = 'V18677A';

UPDATE meat_poultry_egg_inspect
SET st = 'AL'
WHERE est_number = 'M45319+P45319';

UPDATE meat_poultry_egg_inspect
SET st = 'WI'
WHERE est_number = 'M263A+P263A+V263A';

# Güncelleme işlemi hatasız tamamlanmışsa yedeklemek için oluşturduğumu sütunu düşürebiliriz.
ALTER TABLE meat_poultry_egg_inspect DROP COLUMN st_copy;

# Tablomuzun company sütununda Armour-Eckrich Meats firmasına ait yazım farklılıkları nedeniyle
# tutarsızlıklar oluşmuştu. Bu ise verileri gruplarken yanlış aggregation yapılmasına neden oluyordu.
# Aynı firmaya ait farklı yazım şekillerini Armour-Eckrich Meats olarak standart hale getirelim.
UPDATE meat_poultry_egg_inspect
SET company = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%'; 

# Tablomuzda posta kodu sütununda tutarsızlıklar vardı. Bazı satırlardaki veriler standart 6 hane uzunluğun
# altındaydı ve bunun sebebi posta kodunun başında bulunan sıfırların silinmesiydi. Başta bulunan bu sıfırları
# posta kodlarına ekleyerek bu tutarsızlığı ortadan kaldıralım. Puerto Rico ve Virgin Islands'da bulunan 
# şirketlerin posta kodlarının başına iki tane sıfır, diğer eyaletlerde bulunan şirketlerin posta kodlarının
# başına ise bir tane sıfır koymamız gerekli. Stringleri birbirine eklemek için '||' operatörünü kullanacağız.
UPDATE meat_poultry_egg_inspect
SET zip = '00' || zip
WHERE st in ('PR', 'VI') AND length(zip) = 3;

UPDATE meat_poultry_egg_inspect
SET zip = '0' || zip
WHERE st in ('CT', 'MA', 'ME', 'NH', 'NJ', 'RI', 'VT') AND length(zip) = 4;

 # Bir tablodaki değerleri güncellemek için başka bir tablonun içeriğine ihtiyaç duyabiliriz. Hayvancılık
 # şirketlerinin bulunduğu tablomuzda her bir şirketin ait olduğu eyalet tutulmaktaydı. Farklı eyaletler
 # üzerinden bölgeler oluşturulduğu ve bu bölgelere atanan tarihler üzerinden şirketlerin teftiş edileceğini
 # düşünelim. Fakat bizim tablomuzda bu bölgere ait bilgi bulunmadığından şirketlerin teftiş edileceği tarihleri
 # içeren bir sütun oluşturamıyoruz. Eyaletlerin ve bu eyaletin yer aldığı bölge bilgisinin başka bir tabloda
 # tutulduğunu düşünürsek, teftiş tarihleri için oluşturacağımız sütunu bu tablo bağlamında doldurabiliriz.
 # Örneğin New England bölgesindeki şirketlerin teftiş tarihini '2019-12-01' olarak belirleyelim.
 CREATE TABLE state_regions(
	st varchar(2) CONSTRAINT st_key PRIMARY KEY,
	region varchar(20) NOT NULL	
);

COPY state_regions
FROM 'path_to_file'
WITH (FORMAT CSV, HEADER);

ALTER TABLE meat_poultry_egg_inspect ADD COLUMN inspect_date date;

UPDATE meat_poultry_egg_inspect inspect
SET inspect_date = '2019-12-01'
WHERE EXISTS (SELECT state_regions.region
 	          FROM state_regions
 	          WHERE inspect.st = state_regions.st
 	              AND state_regions.region = 'New England');

# Bölgelere göre teftiş tarihlerini içeren üçüncü bir tabloyu senaryomuza eklersek sorgu şu şekilde olur:
UPDATE meat_poultry_egg_inspect inspect
SET inspect_date = (SELECT dt.inspect_date
 	                FROM state_regions reg JOIN region_dates dt
 	                ON reg.region = dt.region
				    WHERE inspect.st = reg.st)
WHERE EXISTS (SELECT reg_dt.region
 	          FROM (SELECT reg.st, reg.region, dt.inspect_date
 	                FROM state_regions reg JOIN region_dates dt
 	                ON reg.region = dt.region) reg_dt
              WHERE inspect.st = reg_dt.st);
