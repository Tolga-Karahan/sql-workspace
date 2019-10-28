# Veritabanlarını modellerken her bir tablonun bir entity e karşılık gelmesini
# sağlarız. Çünkü bu şekilde gereksiz bilgi tutmak, anomaliler, gereksiz işlem
# gibi durumlardan kurtulmuş oluruz. Örneğin iki bin tane çalışanın bulunduğu
# tabloya iki bin kez çalıştığı departmanı, departmanın lokasyonunu vs. eklemeyiz.
# Çünkü bu durumda veriler tekrar eder ve dört bin tane girdi tutmak zorunda
# kalırız. Fakat örneğin sadece on tane departman varsa ve bu departmanları
# ayrı bir tabloda tutarsak sadece on satırlık bir tablomuz olur. Tabloların
# birleşik olması verilerin güncellenmesinde de gereksiz işlemlere neden olur.
# Dolayısıyla farklı entityler farklı tablolarda tutulur gerekirse birleştirilir.

# Bir tablodaki satırları başka bir tablodaki satırlar ile ilişkilendirmek için
# join işlemlerini kullanıyoruz. Sorgu içerisinde tabloları bağlamak için
# JOIN ... ON ifadesini kullanırız. JOIN ifadesinin farklı versiyonları vardır.
# Birleştirme işlemi her iki tabloda da bulunan belirttiğimiz sütunlar içerisinde
# eşleşen değerler üzerinden yapılır. 

# En basit JOIN sorgusu aşağıdaki gibidir. Basitçe ON keywordü ile belirtilen
# sütunlar içerisinde değerlerin eşleştiği satırlar alınır. Sadece eşitlik
# kullanılmak zorunda değildir. Boolean sonuç veren herhangi bir karşılaştırma
# kullanılabilir.
SELECT *
FROM table_a JOIN table_b 
ON table_a.key_column = table_b.foreign_key_column

# Çeşitli JOIN tipleri şu şekildedir:

# JOIN ve ya INNER JOIN, basitçe belirlenen sütunlar üzerinde eşleşme olan satırları
# ve seçilen sütunları döndürür.  

# LEFT JOIN, soldaki tablodaki tüm satırları ve sağ tablodan eşleşme olan satırları
# birleştirir; seçilen sütunları döndürür. Sol tablodaki, eşleşme bulunmayan satırların sağ 
# tabloya ait sütunlarında boş değerler bulunur.

# RIGHT JOIN, sağdaki tablodaki tüm satırları ve sol tablodan eşleşme olan satırları
# birleştirir; seçilen sütunları döndürür. Sağ tablodaki, eşleşme bulunmayan satırların sol
# tabloya ait sütunlarında boş değerler bulunur.

# FULL OUTER JOIN, sol ve sağ tabloların her ikisinden de tüm satırları alır. 
# Eşleşme bulunan satırlar için karşılık düşen tablodaki değerleri koyar, eşleşme
# olmayan satırlar için karşılık düşen tablonun sütunlarına boş değerler koyulur.

# CROSS JOIN, basitçe kartezyen çarpım yapar ve her iki tablodan da satırların tüm
# kombinasyonlarını döndürür.

# Tablolar arasında çeşitli ilişkiler bulunur:

# Sol tablodaki(ve ya tersi) her bir satıra karşılık sağ tabloda da bir satır eşleşiyorsa
# bu ilişki one-to-one ilişkidir.

# Sol tablodaki(ve ya tersi) her bir satıra karşılık sağ tabloda birden fazla satır eşleşiyorsa
# bu ilişki one-to-many ilişkisidir.

# Sol tablodaki(ve ya tersi) birden fazla satır sağ tablodaki birden fazla satır ile eşleşiyorsa
# bu ilişki many-to-many ilişkisidir. 

CREATE TABLE schools_left(
	id integer CONSTRAINT left_id_key PRIMARY KEY,
	left_school varchar(30)	
);

INSERT INTO schools_left VALUES 
	(1, 'Oak Street School'),
    (2, 'Roosevelt High School'),
    (4, 'Washington Middle School'),
    (6, 'Jefferson High School');

# JOIN işlemi sonucunda elde ettiğimiz tablo birleştirdiğimiz her iki tablodan gelen aynı isimli
# sütunlara sahip olabileceğinden bu sütunları tablo ismi ile referanslamak gerekir.
SELECT schools_left.id,
       schools_left.left_school,
       schools_right.right_school
FROM schools_left LEFT JOIN schools_right
ON schools_left.id = schools_right.id;

# JOIN işlemleri yaparken SQL sorgumuzu daha düzenli tutmak için FROM ifadesinden sonra alias 
# tanımlayarak tablo isimlerini kısaltabiliriz.
SELECT lt.id,
       lt.left_school,
       rt.right_school
FROM left_school AS lt JOIN right_school AS rt
ON lt.id = rt.id;

# Birden fazla tabloyuda JOIN ifadesi ile birleştirebiliriz.
CREATE TABLE enrollments(
	id integer CONSTRAINT enr_school_key PRIMARY,
	enrollment integer
);

CREATE TABLE grades(
	id integer CONSTRAINT grd_school_key PRIMARY KEY,
	grade varchar(10)
);

INSERT INTO enrollments VALUES
	(1, 360),
    (2, 1001),
    (5, 450),
    (6, 927);

INSERT INTO grades VALUES
	(1, 'K-3'),
    (2, '9-12'),
    (5, '6-8'),
    (9-12);

SELECT lt.id,
       lt.left_school,
       en.enrollment,
       gr.grade
FROM schools_left AS lt LEFT JOIN enrollments AS en
	ON lt.id = en.id
LEFT JOIN grades AS gr
	ON lt.id = gr.id;

# Aynı sütunlara fakat farklı zamanlara ait girdilere sahip tabloları birleştirerek
# değişimi hesaplamak isteyebiliriz.
SELECT c2010.geo_name,
       c2010.state_us_abbreviation AS state,
       c2010.p0010001 AS pop_2010,
       c2000.p0010001 AS pop_2000,
       round((CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) 
       	/ c2000.p0010001 * 100) AS pct_change
FROM us_counties_2010 AS c2010 INNER JOIN us_counties_2000 c2000
ON c2010.state_fips = c2000.state_fips 
	AND c2010.county_fips = c2000.county_fips
	AND c2010.p0010001 != c2000.p0010001
ORDER BY pct_change DESC; 

