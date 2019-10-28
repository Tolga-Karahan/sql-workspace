# Veri kalitesi ve tutarlılığını sağlamak için sınırlamaların kullanılması önemlidir.
# Sınırlamaları, tablodaki sütunları tanımlarken sütun üzerinde ve ya tablo sütunlarını
# tanımladıktan sonra tablo içerisindeki bir ve ya birden fazla sütun üzerinde tanımlayabiliriz.

# Primary key tablodaki satırları unique olarak tanımlar. Bir ve ya birden fazla sütundan 
# oluşabilir. Değerleri unique olmalıdır ve kayıp değer bulunduramaz. Primary keyler sayesinde
# referans tutarlılığı sağlanır. Yani birbiri ile ikişkili olan tabloların satırları eşleşen
# değerlere sahip olur. Tablomuzdaki sütunlardan biri primary key olabilecek koşulları sağlıyorsa
# bu sütunu seçerek natural key olarak kullanabiliriz. Primary key olarak kullanabileceğimiz bir
# sütun bulunmuyorsa böyle bir sütunu oluşturup yapay değerler ile doldurabiliriz. Bu durumda
# bir surrogate key kullanmış oluruz.

# Primary key tanımını sütunu tanımlarken yapalım
CREATE TABLE natural_key_example(
	license_id char(10) CONSTRAINT license_key PRIMARY KEY,
	first_name varchar(30),
	last_name varchar(30)
);

# Primary key tanımını sütunları tanımladıktan sonra yapalım. Bu syntax ile composite key yapabiliriz.
CREATE TABLE natural_key_example(
	license_id char(10),
	first_name varchar(30),
	last_name varchar(30),
	CONSTRAINT license_key PRIMARY KEY(license_id)
);

# Composite natural key tanımlayalım.
CREATE TABLE composite_natural_key_example(
	student_id char(10),
	school_day date,
	attendance boolean,
	CONSTRAINT student_id_date_key PRIMARY KEY(student_id, school_day)
);

# Tablomuzda primary key olarak kullanabileceğimiz sütun ve ya sütunlar bulunmuyorsa tasarımımızda
# sıkıntılar bulunabilir. Yine de aynı şekilde devam etmek istiyorsak surrogate key kullanabiliriz.
# En basit surrogate key auto-incrementing integerları kullanmaktır. 
CREATE TABLE surrogate_key_example(
	order_number bigserial,
	product_name varchar(50),
	order_date date,
	CONSTRAINT order_key PRIMARY KEY(order_number)
);

# Foreign key tanımlayarak ilişkili olan tablolarda bulunan verilerin, birbiri ile ilişkili olmasını
# garanti altına alabiliriz. Bir tablodaki foreign key, başka bir tablodaki aynı değerlere sahip bir
# primary key ile eşleşir ve tablolar arasında ilişki kurmamızı sağlar. Foreign key olarak tanımladığımız
# sütun, sadece referansladığı primary keyin sahip olduğu değerler içerisinden bir değer alabilir.
# Foreign keyleri REFERENCES keywordü ile tanımlıyoruz.
CREATE TABLE licenses(
	license_id char(10),
	first_name varchar(30),
	last_name varchar(30),
	CONSTRAINT license_key PRIMARY KEY (license_id)
);

CREATE TABLE registrations(
	registration_id char(7),
	registration_date date,
	license_id char(10) REFERENCES licenses (license_id),
	CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

# registrations tablosundaki herhangi bir satır licenses tablosundaki herhangi bir satır ile eşleşmediğinde
# aracın kim tarafından kayıt ettirildiğini bulamayacağımız için license_id sütununu foreign key olarak
# tanımladık. Böylece yeni bir araç kayıt ettirildiğinde girilen license_id, licenses tablosunda bulunmuyorsa
# hata alınır. Foreign key tanımladığımız zaman verileri ekleme ve silme sırası önem kazanır. Verileri eklerken
# öncelikle foreign key in referansladığı primary key in bulunuduğu tabloya kayıt eklemeliyiz. Aksi takdirde hata
# alırız. Verileri silerken ise tersten gitmeliyiz. Verileri silerken hata almak istemiyorsak, CASCADE keywordünü
# kullanarak; foreign key in referansladığı primary key in bulunduğu tabloda bir kayıt silindiğinde, foreign key in
# bulunduğu tabloda da karşılık düşen kaydın silinmesini sağlayabiliriz. Syntax şu şekildedir:
CREATE TABLE registrations(
	registration_id char(7),
	registration_date date,
	license_id char(10) REFERENCES licenses (license_id) ON DELETE CASCADE,
	COSNTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);


