# Sorguları tekrar tekrar kullanabileceğimiz viewlar şeklinde kaydedebiliriz.
# Fonksiyonlar tanımlayarak veri üzerinde kendi işlemlerimizi yapabiliriz.
# Triggerlar, tablo üzerinde belirli bir olay gerçekleştiği zaman fonksiyonların
# otomatik olarak koşulmasını sağlar. Bu teknikler sayesinde tekrarlı işleri 
# azaltabiliriz ve verinin bütünlüğünün korunmasını sağlarız.

# Viewlar kaydedilmiş bir sorguyu kullanarak tekrar oluşturabildiğimiz sanal
# tablolardır. View'a her eriştiğimizde kaydedilen sorgu koşar ve sonuçları
# gösterir. Viewlar ile diğer tablolarda yaptığımız gibi işlemler yapabiliriz.
# Viewlar her erişildiği zaman sorguyu koşarlar fakat bir tablo gibi veriyi
# saklamazlar. Materialized view denilen bir view türü, view tarafından üretilen
# veriyi cache de saklar. Viewların avantajlarını şu şekilde verebiliriz:

# Viewlar sayesinde tekrarlamalardan kurtuluruz. Sorguyu bir kez yazarız
# ve gerek duyduğumuzda sonuçlara erişiriz.

#  Sadece gerekli sütunlar gösterilerek kullanıcılar için karmaşıklık azaltılır.

# Tablolardaki sadece belirli sütunlara erişim sağlandığı için güvenliği artırır.

# ABD'deki şehirlerin olduğu tabloyu kullanarak, 16 sütundan 4 tanesini seçelim
# ve sadece Nevada eyaletindeki şehirleri alarak bir view oluşturalım.
CREATE OR REPLACE VIEW nevada_counties_2010 AS
	SELECT geo_name,
	       state_fips,
	       county_fips,
	       p0010001 AS pop_2010
	FROM us_counties_2010
	WHERE state_us_abbreviation = 'NV'
	ORDER BY county_fips;

# View oluştururken kullandığımız ifade de REPLACE keywordü eğer böyle bir view
# zaten bulunuyorsa o viewin değiştirilmesi gerektiğini belirtir. Burada PostgreSQL
# bazı sınırlamalara sahiptir. Yer değiştirilecek olan view ile yeni tanımlanan view
# aynı sütun isimlerine, veri tiplerine ve aynı sütun sırasına sahip olmalıdır. Asıl
# view ile sütunlar eşleştikten sonra, sütun listesine ilaveten yeni sütunlar eklenebilir.

# Viewları düşürmek için de DROP keywordünü kullanırız: DROP VIEW view_name

# Eyaletlerin 2000 ve 2010 arasındaki nüfus değişimini hesaplamak istediğimizi düşünelim.
# Eğer bu değişimi görmeye sürekli ihtiyaç duyuyorsak bunun için bir view oluşturabiliriz.
CREATE OR REPLACE VIEW county_pop_change AS
	SELECT c2010.geo_name,
	       c2010.state_us_abbreviation AS st
	       c2010.state_fips,
	       c2010.county_fips,
	       c2000.p0010001 AS pop_2000
	       c2010.p0010001 AS pop_2010
	       ROUND((CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) /
	            c2000.p0010001 * 100, 1) AS pct_change_of_pop
	FROM us_counties_2000 c2000 JOIN us_counties_2010 c2010
	ON c2000.state_fips = c2010.state_fips AND
	   c2000.county_fips = c2010.county_fips
	ORDER BY c2010.state_fips, c2010.county_fips;

# View'in oluşturulduğu asıl tablo üzerinde UPDATE ve INSERT sorguları koşabiliriz. Fakat
# bazı şartlar sağlanmalıdır. View tek bir tablo sorgulanarak oluşturulmuş olmalıdır ve
# yine view oluşturulurken kullanılan sorgu DISTINCT, GROUP BY ve bir dizi başka ifadeyi
# içermemelidir. View üzerinde yaptığımız değişiklikler asıl tabloya da yansır!

# Örneğin çalışanlara ait bilgilerin olduğu bir employees tablosunda sadece departman idsi
# 1 olan vergi departmanına ait çalışanların isimlerinin değiştirilebilmesini fakat maaş
# bilgisinin değiştirilememesini ve ya başka departmandan çalışanların eklenememesini
# istiyorsak bir view oluşturabiliriz:
CREATE OR REPLACE VIEW employees_tax_dept AS
	SELECT emp_id,
	       first_name,
	       last_name,
	       dept_id
	FROM employees
	WHERE dept_id = 1
	ORDER BY emp_id
	WITH LOCAL CHECK OPTION;

# WITH LOCAL CHECK OPTION ifadesini kullandığımız için, bu view üzerinde sadece WHERE
# ifadesinde tanımlanan koşulu sağlayan INSERT VE UPDATE sorguları koşulabilir. View
# kullanarak veri silebiliriz. Böylece asıl tabloda da karşılık düşen kayıt silinir.

# PostgreSQL'de kendi fonksiyonlarımızı da yazabiliriz. Örnek olarak farklı zamanlardaki
# iki değer arasındaki yüzdelik değişimi hesaplayan ve sonucu kullanıcının argüman ile
# belirttiği ondalık basamağa yuvarlayan bir fonksiyon yazalım.
CREATE OR REPLACE FUNCTION
percent_change(new_value numeric,
               old_value numeric,
               decimal_places integer DEFAULT 1)
RETURNS numeric AS
'SELECT ROUND((new_value - old_value) / old_value * 100,
             decimal_places);'
LANGUAGE SQL
IMMUTABLE
RETURNS NULL ON NULL INPUT;

# CREATE OR REPLACE FUNCTION ifadesinden sonra fonksiyon ismini ve aldığı argümanları
# veri tipleri ile birlikte fonksiyon headerında yazdık. Ardından RETURNS keywordü ile
# geri dönecek değerin tipini belirledik AS keywordünden sonra ise argümanları kullanan
# sorguyu yazdık. Sondaki ifadeler dil olarak düz SQL kullandığımızı, veritabanında bir
# değişiklik yapılmamasını ve NULL girdi alındığında yine NULL döndürülmesini belirtir.
# Düz SQL ile fonksiyon yazmanın yanı sıra PostgreSQL spesifik dil olarak PL/pgSQL'de
# kullanabiliriz. PL/pgSQL standart SQL'de bulunmayan özellikler kazandırır.

# Rutin güncellemeleri basitleştirmek içinde fonksiyonlar yazabiliriz. Örneğin personelin
# bulunduğu hayali bir tabloda çalıştıkları seneye göre personele izin ataması yapalım.
CREATE OR REPLACE FUNCTION update_annual_leaves()
RETURNS void AS $$
BEGIN
	UPDATE employees
	SET annual_leave = 
		CASE WHEN (now() - hire_date) <= '2 years'::interval THEN 14
			 WHEN (now() - hire_date) BETWEEN '2 years' :: interval
			                          AND '5 years' :: interval THEN 20
			 ELSE 30
		END;
	RAISE NOTICE 'annual leaves updated!';
END;
$$ LANGUAGE plpgsql;

# PostgreSQL'de, fonksiyon komutlarını içeren stringin başı ve sonu '$$' karakteri ile
# belirtilir. Zorunlu olmasa da bir kabul gören bir kullanım alışkanlığıdır. Ayrıca tek
# tırnak, fonksiyon komutlarının içerisinde yine tırnak işareti bulunması nedeniyle
# sorunlara yol açabilir. $$, yerine $text$ formatını da kullanabiliriz.

# Python dilini kullanarakta PostgreSQL fonksiyonları yazabiliriz. Bunun için plpython3u
# uzantısını eklememiz gerekir.
CREATE EXTENSION plpython3u;

# ABD'deki il isimlerinin sonundaki County kelimesini silen bir fonksiyon yazalım.
CREATE OR REPLACE FUNCTION trim_county(input_string text)
RETURNS text AS $$
	import re
	cleaned = re.sub(r' County', '', input_string)
	return cleaned
$$ LANGUAGE plpython3u;

# Triggerlar tablolar ve ya viewlar üzerinde belirlenen bir olay gerçekleştiğinde, örneğin
# bir ekleme, güncelleme ve ya silme işlemi, otomatik olarak bir fonksiyonun koşulmasını
# sağlar. Trigger, bir olay her gerçekleştiğinde tetiklenebilir ve ya sadece işlem yapıldığı
# zaman tetiklenebilir. Mesela 20 tane satır silinmiş ise silinen her bir satır için ve ya
# tüm işlem için bir kez tetiklenebilirler.

# Örneğin bir okulun veritabanında, öğrenci notları her değiştirildiğinde bu değişim takip
# edilmek isteniyor olabilir. Her bir not değişiminde eski notu, yeni notu ve değişiklik
# zamanını loglamak isteyebiliriz. Bunun için üç tane şeye ihtiyacımız var:
# 1) Logların tutulacağı bir tablo
# 2) Bir trigger
# 3) Triggerın koşacağı fonksiyon

CREATE TABLE grades(
	student_id bigint,
	course_id  bigint,
	course varchar(30) NOT NULL,
	grade varchar(5) NOT NULL,
	PRIMARY KEY (student_id, course_id)
);

INSERT INTO grades
VALUES
	(1, 1, 'Mat 2', '53'),
	(1, 2, 'İngilizce', '100'),
	(1, 3, 'Programlama', '100'),
	(1, 4, 'OS', 43);

CREATE TABLE grades_history(
	student_id bigint NOT NULL,
	course_id  bigint NOT NULL,
	old_grade  varchar(5) NOT NULL,
	new_grade  varchar(5) NOT NULL,
	change_time timestamp with time zone NOT NULL,
	course varchar(30) NOT NULL,
	PRIMARY KEY (student_id, course_id, change_time)
);

# Triggerın koşacağı fonksiyonu tanımlayalım.
CREATE OR REPLACE FUNCTION record_if_grade_changed()
RETURNS trigger AS
$$
BEGIN
	IF NEW.grade != OLD.grade
	THEN
		INSERT INTO grades_history
		VALUES (OLD.student_id,
			    OLD.course_id,
			    OLD.grade,
			    NEW.grade,
			    now(),
			    OLD.course);
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

# Triggerımızı tanımlayalım.
CREATE TRIGGER grades_update
	AFTER UPDATE
		ON grades
	FOR EACH ROW
	EXECUTE PROCEDURE record_if_grade_changed();

# Bir diğer örnekte girilen sıcaklık değerlerini otomatik olarak sınıflandıran
# bir trigger yazalım. Böylece değerler girildikten sonra ayrıca kategorinin
# çıkartılması yerine bu işlem otomatize edilmiş olur.
CREATE TABLE temperature_test(
	station_name varchar(50),
	observation_date date,
	max_temp integer,
	min_temp integer,
	max_temp_group varchar(40),
	PRIMARY KEY (station_name, observation_date)
);

CREATE OR REPLACE FUNCTION assign_categories()
	RETURNS trigger AS 
$$
BEGIN
	CASE
		WHEN NEW.max_temp >= 40 THEN NEW.max_temp_group = 'Too Hot';
		WHEN NEW.max_temp BETWEEN 30 AND 39 THEN NEW.max_temp_group = 'Hot';
		WHEN NEW.max_temp BETWEEN 20 AND 29 THEN NEW.max_temp_group = 'Pleasant';
		WHEN NEW.max_temp BETWEEN 10 AND 19 THEN NEW.max_temp_group = 'Cold';
		WHEN NEW.max_temp BETWEEN 0 AND 9 THEN NEW.max_temp_group = 'Freezing';
		ELSE NEW.max_temp = 'Inhumane';
	END CASE;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER temp_insert
	BEFORE INSERT
		ON temperature_test
	FOR EACH ROW
	EXECUTE PROCEDURE assign_categories();

INSERT INTO temperature_test(station_name, observation_date, max_temp, min_temp)
VALUES ('Samsun', '01/01/2020', 35, 4);

SELECT *
FROM temperature_test;