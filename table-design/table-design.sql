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
# kullanarak; foreign key in referansladığı primary key in bulunduğu tabloda bir kayıt silindiğinde, foreign key
# in bulunduğu tabloda da karşılık düşen kaydın silinmesini sağlayabiliriz. Syntax şu şekildedir:
CREATE TABLE registrations(
	registration_id char(7),
	registration_date date,
	license_id char(10) REFERENCES licenses (license_id) ON DELETE CASCADE,
	COSNTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);


# CHECK constraint ile bir sütuna eklenen verinin belirli bir kriteri karşılayıp karşılamadığını kontrol edebiliriz.
# Kriter karşılanmıyorsa veritabanı hata döndürür. CHECK constraint ile tutarsız verilerin eklenmesinin önüne geçebiliriz.
# PRIMARY KEY'lerde olduğu gibi sütun ve ya tablo üzerinden CHECK constraint tanımlayabiliriz. 
CREATE TABLE check_constraint_example(
	employee_id bigserial,
	employee_role varchar(30),
	salary integer,
	CONSTRAINT employee_key PRIMARY KEY (employee_id),
	CONSTRAINT check_role_in_list CHECK (employe_role IN ('Admin', 'Staff')),
	CONSTRAINT check_salary_not_zero CHECK (salary > 0)
);

 # Sütunlar üzerinden de kontrol yapabiliriz.
 CONSTRAINT sale_check CHECK (sale_price < retail_price)

# UNIQUE constraint kullanarak bir sütundaki tüm değerlerin unique olduğundan emin olabiliriz. PRIMARY KEY den farkı
# birden fazla NULL değerler içerebilmesidir.
CREATE TABLE unique_constraint_example(
	contact_id char(10),
	first_name varchar(30),
	last_name varchar(30),
	email varchar(100),
	CONSTRAINT contact_key PRIMARY KEY (contact_id),
	CONSTRAINT email_unique UNIQUE (email)
);

# NOT NULL constraint kullanarak bir sütunda NULL değer bulunmadığından emin olabiliriz. Basitçe NULL bulunmasını
# istemediğimiz sütunun yanında NOT NULL keywordünü kullanarabiliriz.
CREATE TABLE not_null_example(
	employee_id char(10),
	first_name varchar(30) NOT NULL,
	last_name varchar(30) NOT NULL,
	CONSTRAINT employee_key PRIMARY KEY (employee_id)
);

# Tablolar oluşturulduktan sonra constraint eklemek ve ya çıkarmak istiyorsak ALTER TABLE ifadesini kullanırız.
# Primary key, foreign key ve ya unique constraintlerini silmek için şu syntaxı kullanırız:
ALTER TABLE table_name DROP constraint_name;

# Not null constrainti silmek için sütunu belirtmeliyiz. Bu nedenle ALTER COLUMN ifadesini de kullanırız.
ALTER TABLE table_name ALTER COLUMN column_name DROP NOT NULL;

# Tablolar oluşturulduktan sonra constraint eklemek istiyorsak, constraint ekleyeceğimiz sütunlardaki değerler
# bu constraintleri karşılıyor olmalıdır. 
# ADD keywordünü ALTER TABLE ifadesi ile kullanarak constraint ekleyebiliriz.
ALTER TABLE table_name ADD CONSTRAINT constraint_name CONSTRAINT_TYPE (column);

# SET keywordünü ALTER TABLE ve ALTER COLUMN ifadeleri ile kullanarak NOT NULL constraint ekleyebiliriz.
ALTER TABLE table_name ALTER COLUMN column_name SET NOT NULL; 
