# Söylev, rapor, basın yayınları ve diğer dökümanlar aracılığıyla elde ettiğimiz metinlerden
# veri çıkartabiliriz. Bu veri kaynakları genellikle unstructured ve ya semi-structured
# formatta bulunurlar. Metinleri structured hale getirerek analiz edebiliriz. Örneğin
# tarihler, kodlar gibi bazı elemanları metinden çıkartarak bir tabloya yükleyebilir ve
# analiz edebiliriz. PostgreSQL'in metin analiz araçlarını da kullanabiliriz. Örneğin
# tüm metin üzerinden arama yapabiliriz. 

# Standart SQL ve PostgreSQL string fonksiyonlarını kullanarak stringleri istediğimiz
# formata dönüştürebiliriz. Bazı fonksiyonları inceleyelim:

# Stringlerde bulunan karakterleri büyük ve ya küçük harflere dönüştürmek için fonksiyonlar
# kullanabiliriz. upper(string) fonksiyonu string içerisinde bulunan tüm alfabetik karakterleri
# büyük harflere dönüştürür. Alfabetik olmayan karakterler ise dönüştürülmez. lower(string)
# fonksiyonu string içerisinde bulunan tüm alfabetik karakterleri küçük harflere dönüştürür.
# initcap(string) fonksiyonu string içerisinde bulunan her kelimenin ilk harfini büyük harfe
# dönüştürür. initcap(string) fonksiyonu PostgreSQL'e özgü bir fonksiyondur.

# Bazı string fonksiyonları ise argüman olarak aldığı string hakkında bilgiler döndürür.
# Örneğin char_length(string) fonksiyonu boşluklarda dahil olmak üzere stringte bulunan
# karakter sayısını verir. position(substring in string) fonksiyonu belirtilen alt stringin
# string içerisinde başladığı indisi döndürür.

# Stringler içerisinden karakter silmek için de string fonksiyonlarını kullanabiliriz.
# trim(characters from string) fonksiyonu ile string içerisinden, characters argümanı ile
# belirttiğimiz istenmeyen karakteri silebiliriz. trim fonksiyonunun opsiyonları vardır.
# Eğer karakterleri stringin başından silmek istiyorsak leading characters from string, 
# stringin sonundan silmek istiyorsak trailing characters from string formatında argüman
# göndeririz. leading ve ya trailing argümanlarını kullanmazsak argüman olarak belirtilen
# karakterler ile eşleşen tüm karakterler silinir. trim fonksiyonuna bir argüman vermezsek
# varsayılan olarak string içerisindeki boşlukları siler.

# left(string, number) ve right(string, number) fonksiyonları ile sırasıyla stringin solundan
# ve sağından number argümanı ile belirtilen kadar karakter döndürülür. 

# replace(string, from, to) fonksiyonu ile string içerisindeki karakterleri replace edebiliriz.
# from argümanı ile belirtilen karakterler to argümanı ile belirtilen karakterler ile yer
# değiştirir.

# Aradığımız stringler belirli formatlara uyuyorsa bu formatları regex ile ifade ederek eşleştirme
# yapabiliriz. Ardından paternleri WHERE ifadesi ile birlikte kullanarak filtreleme yapabiliriz ve 
# ya regex fonksiyonlarını kullanarak aynı paternleri taşıyan metinleri çıkartabilir ve üzerinde
# çalışabiliriz. Regex notasyonunu inceleyelim:

# *, satırbaşını belirten karakter haricinde tüm karakterler ile eşleşir.
# [FGz], köşeli parantez içerisindeki herhangi bir karakter ile eşleşir. Bu örnekte F, G ve ya z...
# [a-z], - kullandığımız zaman bir aralık belirtmiş oluruz. Burada tüm küçük harfler ile eşleşir.
# [^a-z], ^ kullandığımız zaman tümleyenini alırız. Bu örnekte küçük harf olmayan tüm karakterler
# ile eşleşir. 
# \w, herhangi bir harf, numara ve ya _ ile eşleşir.
# \d, herhangi bir dijit ile eşleşir.
# \s, bir boşluk karakteri ile eşleşir.
# \t, bir tab karakteri ile eşleşir.
# \n, yeni satır karakteri ile eşleşir.
# \r, satırbaşı karakteri ile eşleşir.
# ^, stringin başından itibaren eşleştirme yap anlamına gelir.
# $, stringin sonuna kadar eşleştirme yap anlamına gelir.
# ?, solundaki paterni 0 ve ya 1 kez eşleştir anlamına gelir.
# +, solundaki paterni 1 ve ya daha fazla sayıda eşleştir anlamına gelir.
# {m}, solundaki paterni tam olarak m kez eşleştir anlamına gelir.
# {m, n}, solundaki paterni m-n kez eşleştirir.
# |, soldaki ve ya sağdaki paterni eşleştirir.
# (), öncelik belirtmek ve ya belirtilen patern grubunu yakalamak için kullanılır. Sonuç olarak 
# sadece yakalanan grup döner.
# (?:), grup oluşturur fakat yakalamaz.

# Basit regex kullanarak çeşitli karakterleri eşleyebiliriz ve kaç tane ve nerede eşleneceklerini
# belirtebiliriz. substring(string from regex) fonksiyonu ile string içerisinde regex eşleştirebiliriz.

# Üzerinde çalışacağımız veriyi yükleyelim.
CREATE TABLE crime_reports(
	crime_id bigserial PRIMARY KEY,
	date_1 timestamp with time zone,
	date_2 timestamp with time zone,
	street varchar(250),
	city varchar(200),
	crime_type varchar(100),
	description text,
	case_number varchar(50),
	original_text text NOT NULL
);

COPY crime_reports
FROM '/home/tkarahan/Documents/my-repositories/practical-sql/crime_reports.csv'
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

# Eşleştirme yapabilmek için regexp_match(string, regex) fonksiyonunu kullanabiliriz.
# Her satırda ilk eşleşmeyi döndürür. Eğer eşleşme yoksa geriye NULL döndürür. regexp_match
# fonksyionu PostgreSQL'e özgü bir fonksiyondur.

# Orijinal metinden tarihleri çıkartalım:
SELECT crime_id,
       regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;

# İki tane tarih bilgisi olan metinlerden her iki tarihi de çıkartalım:
SELECT crime_id,
       regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports;

# regexp_match fonksiyonu sadece bulduğu ilk eşleşmeyi döndürür. Her bir metinde bulunan tüm eşleşmeleri
# almak için regexp_matches(string, regexp, flag) fonksiyonunu 'g' flagı ile kullanmalıyız. Böylece ikinci
# tarih bulunan metinlerden ikinci tarihi de çekmiş oluruz.

# Orijinal metini incelediğimiz zaman tarihlerin '-' ile ayrıldığını görürüz. Dolayısıyla '-' karakteri
# ile başlayan paternler arayarak ikinci tarihi de bulabiliriz. Fakat sonuçta '-' karakterinin gözükmemesi
# için grup oluşturarak sadece istediğimiz kısmı yakalamalıyız.
SELECT crime_id,
       regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})')
FROM crime_reports;

# İlk tarih, şehir, suç tipi ve suç idsini birlikte çıkartan bir sorgu yazalım.
SELECT regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
       regexp_match(original_text, '(?: Sq.|Plz.|Ter.|Rd.|Dr.)\n(\w+ \w+|\w+)\n') AS city,
       regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
       regexp_match(original_text, '(?:C0|SO)\d+') AS crime_id
FROM crime_reports;

# regexp_match fonksiyonu geriye text dizisi döndürdüğü için elde edilen sütun tipi text[] olur ve değerler
# süslü parantez içerisinde bulunur. Bu ise UPDATE işlemlerinde problemlere neden olabilir. Dolayısıyla
# verileri dizi olarak değil değer olarak elde etmek için dizi notasyonundan faydalanırız.
SELECT (regexp_match(original_text, '(?:C0|SO)\d+'))[1] AS crime_id
FROM crime_reports;

# Tablodaki zaman verisini timstamptz olacak şekilde güncelleyelim.
UPDATE crime_reports
SET date_1 = (
	CAST(
		(regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] || ' ' ||
    	(regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] || ' UTC+3'
		AS timestamp with time zone
		)
);   
