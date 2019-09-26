/* Karakter tabanlı veri tipleri olarak char, varchar ve ya text tiplerini
kullanabiliriz. char ve varchar standart SQL'de bulunurken text sadece
PostgreSQL'de bulunur. */

/* SQL standardı integer olarak smallint, integer ve bigint tiplerini sağlar.
Sırası ile 2, 4 ve 8 byte bellek alanı kaplarlar. smallint tipinin sınırları
-32768 ve +32767 arasıdır. 2.1 milyardan daha büyük sayılar kullanacaksak
sütun tipini bigint yapmalıyız. Belirlenen veri tipinin aralığının dışında*
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
VALUES (.7, .7, .7),
		(7.14782, 7.14782, 7.14782),
		(7.147829876, 7.147829876, 7.147829876);
		
COPY decimal_formats TO '/home/apeiron/Desktop/decimal_formats.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- Tabloları aşağıdaki formattaki gibi diske yazabiliriz.
COPY teachers TO '/home/apeiron/Desktop/teachers.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

