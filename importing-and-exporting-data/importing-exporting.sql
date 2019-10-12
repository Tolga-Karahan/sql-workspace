# PostgreSQL'de veritabanına tablo yazmak ve ya tabloları diske yazmak için COPY
# komutunu kullanıyoruz. Farklı veritabanı yönetim araçları farklı formatlarda
# dosyalar kullanabilir fakat çoğu csv gibi bir karakter ile ayrılan değerler
# içeren tipte metin dosyalarını tanır. Dolayısıyla bu formatı kullanabiliriz.
# İçerisinde ayırıcı karakteri bulunduran sütunlarda tırnak işareti kullanarak
# karışıklığı engelleriz. Tolga, Karahan, "Civelek Sokak, Bilir apt." gibi...

# Veritabanına bir dosya import edeceğimiz zaman dosyayı incelemeli ve verilerin
# girileceği tabloyu oluşturmalıyız. Ardından aşağıdaki gibi bir SQL ifadesi ile
# dosyamızı veritabanımıza import edebiliriz.

COPY table_name
FROM 'file_path'
WITH (FORMAT CSV, HEADER);

# Yukarıdaki ifade de WITH komutu ile dosya formatımızı belirliyoruz ve header
# satırının import işlemine dahil edilmemesini belirtiyoruz. Çünkü PostgreSQL
# header satırı kullanmaz. Import işlemi yapılırken HEADER Kullanıldığında 
# import edilen dosyadaki header satırı göz ardı edilir, export işlemi yapılırken
# HEADER kullanıldığında ise dosyaya header satırı da eklenir. Format olarak TEXT
# ve ya BINARY de kullanabiliriz. TEXT tab ile ve ya ASCII karşılığını belirttiğimiz
# bir karakter ile ayrılmış dosyaları temsil ederken; BINARY, karakterlerin byte
# dizileri olarak kaydedildiği formatı temsil eder. Formatı CSV olarak belirlediğimiz
# için ayrıca ayırıcı karakteri belirtmemize gerek yok. Farklı bir ayırıcı karakter
# kullanılıyorsa WITH komutu ile DELIMITER komutu ve tek bir karakter kullanarak 
# ayırıcı karakteri belirtebiliriz.

COPY table_name
FROM 'file_path'
WITH (FORMAT TEXT, HEADER, DELIMITER '|');

# Okunacak dosyada aynı sütun içerisinde birden fazla ',' varsa CSV okunurken formatı
# bozar. Bu nedenle dosyada ilave ',' karakterleri içeren sütunlar çift tırnak içinde
# yazılmalı. Eğer dosyada ayırıcı karakteri içeren sütun karışıklık olmaması için
# tırnak işareti haricinde bir karakter kullanıyorsa QUOTE komutu ve tek bir karakter
# kullanarak bu karakteri tanımlayabiliriz.

COPY table_name
FROM 'file_path'
WITH (FORMAT CSV, HEADER, QUOTE '/');

# Bazı egzersizler
COPY us_counties_2010 
FROM '/home/apeiron/Documents/my-repos/sql-workspace/us_counties_2010.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM us_counties_2010;

SELECT geo_name, state_us_abbreviation, area_land
FROM us_counties_2010
ORDER BY area_land DESC
LIMIT 5;

SELECT geo_name, state_us_abbreviation, internal_point_lat, internal_point_lon
FROM us_counties_2010
ORDER BY internal_point_lat DESC, internal_point_lon DESC
LIMIT 5;

# Verileri yükleyeceğimiz tablodaki sütunların bir alt kümesini seçmek isteyebiliriz.
# Bu durumda tablo isminden sonra almak istediğimiz sütunları belirtiriz. Eğer verileri
# yükleyeceğimiz tablo ilave sütunlar içeriyorsa basitçe bu sütunlar boş kalır.
COPY supervisor_salaries (town, supervisor, salary) 
FROM 'path'
WITH (FORMAT CSV, HEADER);

# Verileri yükleyeceğimiz dosyada tüm sütunlar olmadığı için COPY komutunu kullanarak
# verileri çekerken sütunların bir alt kümesini belirtiriz. Fakat dosyada bulunmayan
# sütunlar için varsayılan değerler atamak istiyorsak temporary table kullanabiliriz.
# Geçici tablolar veritabanı oturumu bitene kadar sürer. Veriler üzerinde ara işlemler
# yapmak için kullanılabilirler. 

# Dosyadan çekilecek verileri ilk olarak geçici tablonun içerisine alırız. Bunun için
# geçici tabloyu oluşturmalıyız. Geçici tablo oluşturulurken LIKE komutu kullanılarak
# oluşturulan önceki tablonun aynısı oluşturulabilir. Ardından geçici tablonun içinde
# bulunan veriler bir INSERT INTO ifadesi içersinde kullanılarak veriler asıl tabloya
# kopyalanır ve dosyada bulunmayan 'county' sütunu için varsayılan değerler kullanılır.
CREATE TEMPORARY TABLE supervisor_salaries_temp (LIKE supervisor_salaries);

COPY supervisor_salaries_temp (town, supervisor, salary)
FROM 'path'
WITH (FORMAT CSV, HEADER);

INSERT INTO supervisor_salaries
SELECT town, 'Some County', supervisor, salary
FROM supervisor_salaries_temp;

DROP TABLE supervisor_salaries_temp;

# COPY komutunu kullanarak tüm veriyi exportta edebiliriz. HEADER argümanı ile dosyaya
# sütun başlıklarının da yazılmasını, DELIMITER argümanı ile sütunları ayıracak karakteri
# belirtiriz. Dosya pathini belirtirken istediğimiz dosya formatını belirtebiliriz.
COPY supervisor_salaries
TO 'path'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

# Tüm sütunları değil sütunların bir alt kümesini de dosyaya yazabiliriz.
COPY supervisor_salaries (column1, column2, ... , columnn)
TO 'path'
WITH (FORMAT CSV, HEADER, DELIMITER '|');


# COPY içerisine bir sorgu yerleştirerek yazmak istediğimiz sütunları filtreleyebiliriz.
COPY(
	SELECT geo_name, state_us_abbreviation, population_count_100_percent
	FROM us_counties_2010
	WHERE geo_name ILIKE 'T%'
)
TO '/home/apeiron/restricted_copy.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

# Remote veritabanlarından okumak ve ya yazmak için PostgreSQL'in import/export wizardını
# kullanmak gerekebilir.