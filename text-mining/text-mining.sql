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


# Eğer olay aynı gün içerisinde gerçekleşmiş ise sadece tek tarih bilgisi yer almakta. Dolayısıyla 1. tarih
# verisini ikinci saat verisi ile birleştirerek 2. tarih sütununu güncellememiz gerekir. 1. ve 2. tarih
# sütunlarını hep birlikte koşullu yapı kullanarak güncelleyelim:
UPDATE crime_reports
SET date_1 =
	(
		CAST(
			(regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] || ' ' ||
			(regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] 
			AS timestamp with time zone)
	),

	date_2 =
	(	CASE
			WHEN
				(regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})') IS NULL AND
					regexp_match(original_text, '\/\d{2}\n(\d{4})') IS NOT NULL)
			THEN
				CAST((regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] || ' ' ||
					(regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] || 'UTC+3'
				    AS timestamp with time zone)
			WHEN
				(regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})') IS NOT NULL AND
					regexp_match(original_text, '\/\d{2}\n(\d{4})') IS NOT NULL)
			THEN
				CAST((regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{2})'))[1] || ' ' ||
					(regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] || 'UTC+3'
				    AS timestamp with time zone)
			ELSE
				NULL
		END  
	),

	street      = (regexp_match(original_text, 'hrs.\n(\d+ .+(?:?:Sq.|Plz.|Ter.|Rd.|Dr.))'))[1],
	city        = (regexp_match(original_text, '(?:Sq.|Plz.|Ter.|Rd.|Dr.)\n(\w+ \w+|\w+)\n'))[1],
	crime_type  = (regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.+):'))[1],
	description = (regexp_match(original_text, ':\s(.+)(?:C0|SO)'))[1],
	case_number = (regexp_match(original_text, '(?:SO|C0)\d+)'))[1];

# Regexleri WHERE ifadesi ile birlikte kullanarak filtreleme yapabiliriz. ~ ile başlayan regexler
# case sensitive, ~* ile başlayan regexler ise case insensitive olurlar. Başlarına ! koyarak
# tümleyenlerini alabiliriz.
SELECT geo_name
FROM us_counties_2010
WHERE geo_name ~* '.+ash.+' AND geo_name !~ 'Wash.+';

# Bazı diğer kullanışlı regex fonksiyonlarına bakalım:

# regexp_replace(text, pattern, replacement), fonksiyonu argüman olarak aldığı stringi argüman olarak
# aldığı patern ile eşleştirir ve replacement argümanı ile belirtilen string ile değiştirir.
SELECT regexp_replace('23/09/2004', '\d{4}', '1994');

# regexp_split_to_table(text, pattern) fonksiyonu, argüman olarak aldığı stringi argüman olarak aldığı
# paterne göre ayırır.
SELECT regexp_split_to_table('one, two, three', ',');

# regexp_split_to_array(text, pattern) fonksiyonu ise stringi paterne göre böler ve sonucu dizi olarak
# döndürür.
SELECT regexp_split_to_array('one, two, three', ',');

# PostgreSQL, bir full text search motoruna sahiptir. Büyük miktarlarda metin içerisinden bilgi çıkartmaya
# çalışırken bu motordan faydalanmak kullanışlı olabilir. PostgreSQL implementasyonunda iki veri tipi
# bulunmaktadır. tsvector, aranacak metni temsil eder ve optimize bir şekilde tutulmasını sağlar. tsquery,
# sorgu terimlerini ve operatörlerini temsil eder.

# tsvector, metni lexeme denilen sıralı anlam birimleri halinde tutar. Böylece kelimeler eklentilerinden
# bağımszız bir şekilde kök sözcük olarak tutulur ve asıl metindeki pozisyonları kaydedilir. the, it gibi
# arama açısından önemli olmayan kelimeler silinir. to_tsvector(string), fonksiyonu ile bir stringi
# tsvector formatına dönüştürebiliriz.
SELECT to_tsvector('I am walking across the sitting room to sit with you.');  

# tsquery veri tipi tam metin arama sorgusunu temsil eder ve yine leximeler halinde organize edilir. Aynı
# zamanda operatörlerde içerir(&, |, ! vs gibi...). <-> operatörü komşu ve ya belirlenen uzaklıktaki 
# kelimeler için arama yapmayı sağlar. to_tsquery(search_query), fonksiyonuna aramak istediğimiz kelimeleri
# ve operatörleri sağlayan tsquery karşılığını elde edebiliriz.
SELECT to_tsquery('walking & sitting');  

# Metin ve arama terimleri tam metin arama veri tiplerine dönüştürüldükten sonra @@ operatörü ile herhangi
# bir sorgunun metin ile eşleşip eşleşmediğini kontrol edebiliriz. 
SELECT to_tsvector('I am walking across the sitting room to sit with you.') @@
	to_tsquery('walking & sitting');

SELECT to_tsvector('I am walking across the sitting room to sit with you.') @@
	to_tsquery('walking & running');

# Sorgu ve metin eşleşiyorsa t, eşleşmiyorsa ise f sonucunu alırız.

# Pratik için bazı ABD başkanlarına ait konuşma metinleri üzerinde çalışacağız. Verimizi import edelim.
CREATE TABLE president_speeches(
	sotu_id serial PRIMARY KEY,
	president varchar(100) NOT NULL,
	title varchar(250) NOT NULL,
	speech_date date NOT NULL,
	speech_text text NOT NULL,
	search_speech_text tsvector
);

COPY president_speeches (president, title, speech_date, speech_text)
FROM '/home/tkarahan/Documents/my-repositories/sql-workspace/data/sotu-1946-1977.csv'
WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@');

# İlgili sütunu asıl metnin tsvector karşılığı ile dolduralım.
UPDATE president_speeches
SET search_speech_text = to_tsvector('english', speech_text);

# Daha hızlı işlem yapabilmek için tsvectorleri içeren sütunu indeksleyelim. PostgreSQL tam metin arama
# uygulamaları için indeks olarak GIN(Generalized Inverted Index) indeks tipini öneriyor.
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);

# Konuşma metninin içerisinde Vietnam geçen ABD başkanlarını bulalım.
SELECT president,
       title,
       speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;

# ts_headline() fonksiyonu ile eşleşme olan kelimeleri ve komşu sözcükleri gösterebiliriz. Fonksiyonun
# argümanları ile çıktıyı formatlayabiliriz.
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('Vietnam'),
       	           'StartSel = <,
       	            Stopsel  = >,
       	            MinWords = 7,
       	            MaxWords = 9,
       	            MaxFragments = 1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;

# Aramalarda birden fazla terimde kullanabiliriz. Örneğin konuşma metinlerinde transportation kelimesi olan
# fakat roads kelimesi olmayan başkanlara bakalım. Yani yollara değinmeksizin daha genel olarak ulaşımdan
# bahsedilen konuşmaları bulalım.
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('transportation & !roads'),
       	           'StartSel = <,
       	            Stopsel  = >,
       	            MinWords = 7,
       	            MaxWords = 9,
       	            MaxFragments = 1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('transportation & !roads')
ORDER BY speech_date;

# <-> operatörü ile komşu sözcükler üzerinden eşleştirme yapabiliriz. Konuşma metinlerinde cold kelimesini
# war kelimesinin takip ettiği başkanları bulalım. '-' işareti yerine bir sayı yazarsak hemen komşu olan
# kelimeler için değil belirtilen sayı kadar uzaklık bulunan kelimeler için eşleşme yapılır.
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('cold <-> war'),
       	           'StartSel = <,
       	            StopSel  = >,
       	            MinWords = 5,
       	            MaxWords = 7,
       	            MaxFragments = 1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('cold <-> war')
ORDER BY speech_date;

# Sonuçları arama terimlerimize göre ranklayarak en alakalı eşleşmeleri görebiliriz. ts_rank() fonksiyonu
# aranan leximelerin ne kadar sık metinde bulunduğuna göre ranklama yapar. ts_rank_cd() fonksiyonu ise
# aranan leximelerin birbirlerine ne kadar yakın olduğu üzerinden ranklama yapar. 

# war, security, threat ve enemy kelimelerini en sık içeren metinleri ts_rank() fonksiyonu ile ranklayalım.
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('war & security & threat & enemy'),
       	           'StartSel = <,
       	            StopSel  = >,
       	            MinWords = 5,
       	            MaxWords = 7,
       	            MaxFragments = 1'),
       ts_rank(search_speech_text, to_tsquery('war & security & threat & enemy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC;

# Aranan terimlerin sıklığına göre ranklamak, aranan metnin uzunluğuna da duyarlıdır. Bu nedenle ts_rank()
# fonksiyonuna üçüncü bir argüman olarak 2 değerini sağlayarak rankın metin uzunluğuna göre normalize
# edilmesini sağlayabiliriz.
SELECT president,
       speech_date,
       ts_headline(speech_text, to_tsquery('war & security & threat & enemy'),
       	           'StartSel = <,
       	            StopSel  = >,
       	            MinWords = 5,
       	            MaxWords = 7,
       	            MaxFragments = 1'),
       ts_rank(search_speech_text, to_tsquery('war & security & threat & enemy'), 2) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC;