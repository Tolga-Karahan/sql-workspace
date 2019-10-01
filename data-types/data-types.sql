/* Karakter tabanlı veri tipleri olarak char, varchar ve ya text tiplerini
kullanabiliriz. char ve varchar standart SQL'de bulunurken text sadece
PostgreSQL'de bulunur. */

/* SQL standardı integer olarak smallint, integer ve bigint tiplerini sağlar.
Sırası ile 2, 4 ve 8 byte bellek alanı kaplarlar. smallint tipinin sınırları
-32768 ve +32767 arasıdır. 2.1 milyardan daha büyük sayılar kullanacaksak
sütun tipini bigint yapmalıyız. Belirlenen veri tipinin aralığının dışında
bir veriyi tabloya eklemek istediğimiz out of range hatası alırız.

Yukarıda belirtilen integer tiplerinin otomatik artan versiyonları olan serial
tipleri PostgreSQL'e özgüdür ve her satır eklendiğinde otomatik artarlar.  */

/* Decimal veri tipleri bir tam sayı kısım ve decimal pointten sonra gelen bir
fraction kısmı bulunduran sayılar için kullanılır. 

Fixed-Point sayıları numeric(precision, scale) ve ya decimal(precision, scale)
şeklinde tanımlayabiliriz. precision toplam digit sayısını scale ise decimal
pointten sonra gelebilecek digit sayısını belirler. Eğer scale değeri vermezsek
decimal pointten sonra digit olmayacağı için pratikte bir integer tanımlarız.
Eğer precision ve scale argümanlarından ikisinide sağlamazsak bu argümanlar için
varsayılan maksimum değerler kullanılır. PostgreSQL'de decimal pointten önce 
131.072 ve decimal pointten sonra 16.383 olur. 

Floating-point tipler real ve double precision olarak ikiye ayrılır. real tipi
6 digite kadar precisiona izin verir double precision ise 15 digite kadar izin
verir. Bu tipte decimal point sabit değil değişkendir. Floating-point sayılarda
matematiksel işlemlerde hassaslık problemleri vardır. Dolayısıyla hassas işlemler
yapılacaksa bu veri tipi tercih edilmemelidir. Örneğin para ile ilgili işlemler
için numeric ve ya decimal tipleri tercih edilmelidir. İşlemler arttıkça sayıları
tam olarak temsil edememenin verdiği handikapta büyüyerek artar. */

-- Fixed-point ve floating point tiplerin nasıl tutulduğunu karşılaştıralım.
CREATE TABLE decimal_formats (
	fixed_column numeric(20, 5),
	real_column real,
	double_column double precision
);

INSERT INTO decimal_formats
VALUES  (.7, .7, .7),
		(7.14782, 7.14782, 7.14782),
		(7.147829876, 7.147829876, 7.147829876);
		
COPY decimal_formats TO '/home/apeiron/Desktop/decimal_formats.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- Tabloları aşağıdaki formattaki gibi diske yazabiliriz.
COPY teachers TO '/home/apeiron/Desktop/teachers.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

# Zaman ve tarih bilgisinin birlikte tutulduğu formata timestamp denir. Veritabanı
# serverından faydalanarak o anki zamanı elde edebiliriz. Dünyanın farklı noktalarındaki
# zamanları karşılaştırabilmek için 'with time zone' keywordünü ekleriz. Bunun PostgreSQL'deki
# karşılığı 'timestamptz' olmaktadır.

# date tipi sadece tarihi, time tipi sadece zamanı tutar. time tipi ile de 'with time zone'
# keywordunu kullanmalıyız. Aksi takdirde farklı zaman bölgeleri arasında karşılaştırmalar
# yapamayız. interval tipi sadece bir zaman periyodunun uzunluğunu tutar.

CREATE TABLE date_time_types(
	timestamp_column timestamp with time zone,
	interval_column interval
);

INSERT INTO date_time_types
VALUES  ('2019-09-30 23:14 GMT+3', '25 years'),
		('2019-09-30 23:14 -8', '1 month'),
		('2019-09-30 23:14 Australia/Melbourne', '1 century'),
		(now(), '1 week');
		
COPY date_time_types TO '/home/apeiron/date_time_types.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

# Yukarıdaki örnekte timestamp with time zone ve interval tiplerine sahip iki sütunu bulunan
# bir tablo oluşturuldu. İlk timestamp GMT+3 zaman bölgesini; -8, UTC'ye göre kaymayı gösteriyor.
# -8, yani UTC'nin 8 saat gerisinde bulunulması dolayısıyla Birleşik Krallık'ın batısını kastediyor.
# Australia/Melbourne ile ise standart time zone database kullanılmıştır. Dördüncü satırda ise
# PostgreSQL fonksiyonu olan now() kullanılarak makinenin donanımından faydalanılarak o anki
# transaction zamanı kullanılmış. Girilen tarihlerin bulunduğu zaman bölgesi bilgisi kullanılarak
# timestamplar bizim bulunduğumuz zaman bölgesindeki tarihlere çevirilir. Bu nedenle aynı tarihleri
# girsekte zaman bölgelerini farklı belirlediğimiz için dönüşümler sonucunda farklı tarihler elde
# edilir.

# interval değerleri timestamplerden çıkartarak örneğin çeşitli dönem sonlarını bulabiliriz. Örneğin
# bir kiracının kontrat tarihi ve süresini kullanarak kontrat bitiş tarihini hesaplayabiliriz.

SELECT timestamp_column,
		interval_column,
		timestamp_column + interval_column AS new_date
FROM date_time_types;

# Farklı veri tipleri arasındaki dönüşümleri CAST() fonksiyonu ile yapabiliriz fakat orjinal tip ile
# dönüştürülmek istendiği tip birbiri ile uyumlu olmalı. Aşağıda timestamp veri tipinin varchar tipine
# dönüştürülmesi gösterilmiştir. Argüman olarak 12 karakter kullanıldığından orjinal timestampta sadece
# 12 karakter alınır.

SELECT timestamp_column, CAST(timestamp_columns AS varchar(12))
FROM date_time_types;

# Bir başka örnek...
SELECT CAST(fixed_column AS integer), 
	   CAST(fixed_column AS varchar(5))
FROM decimal_formats;

# Aynı dönüşümleri '::' operatörü ile de yapmak mümkündür. Fakat bu sadece PostgreSQL'de yapılabilir.
SELECT fixed_column::integer,
	   fixed_column::varchar(10)
FROM decimal_formats;

