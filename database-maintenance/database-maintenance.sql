# Veritabanı dosyalarının büyüyüp çok fazla yer kaplamasını PostgreSQL VACUUM komutu
# ile önleyebiliriz. PostgreSQL tablolarının boyutu rutin işlemler nedeniyle büyüyebilir.
# Örneğin herhangi bir satırdaki bir değeri güncellediğimizde, satırın yeni bir versiyonu
# oluşturulur fakat eskisi silinmez. Bu ölü satırlar kullanıcı tarafından görülemese de
# yer kaplarlar. Benzer şekilde bir satırı sildiğimizde de satır görünmez olsa da tablo
# içerisinde ölü satır olarak yer kaplamaya devam eder. Bu satırların korunmasının nedeni
# birden fazla transaction gerçekleşen veritabanlarında bazı transactionların bu satırları
# kullanmasıdır. VACUUM aracı bu ölü satırlar tarafından kaplanan alanın, geri alınması
# mümkün olan kısımlarını, tekrar kullanabilmek için kullanılır. Geri alınması mümkün
# olan alan diskin kullanımına açılmaz. Bunun yerine işaretlenerek veritabanı için tekrar
# kullanılabilecek durumda olduğu belirtilir ve ihtiyaç durumunda kullanılır. Eğer kullanım
# dışı alanı diske döndürme istiyorsak VACUUM FULL komutunu kullanmamız gerekir. Böylece
# tablonun yeni bir versiyonu oluşturulur ve kullanılmayan alan diske geri verilir. Haricen
# kullanmasakta PostgreSQL'e ait autovacuum süreci arkaplanda çalışır ve veritabanını takip
# ederek gerektiğinde VACUUM komutunu çalıştırılır. 

# Güncelleme işlemleri ile veritabanı boyutunun nasıl büyüdüğüne bakalım.
CREATE TABLE vacuum_test(
	integer_column integer
);   

# Tablonun oluşturulduktan sonraki boyutuna bakalım.
SELECT pg_size_pretty(
	pg_total_relation_size('vacuum_test')
);

# Tabloya 500bin satır ekleyerek boyutuna bakalım.
INSERT INTO vacuum_test
SELECT * FROM generate_series(1, 500000);

# Tekrar tablo boyutunu kontrol edelim.
SELECT pg_size_pretty(
	pg_total_relation_size('vacuum_test')
);

# Şimdi tablodaki satırları güncelleyelim ve boyuta tekrar bakalım.
UPDATE vacuum_test
SET integer_column = integer_column + 1;

SELECT pg_size_pretty(
	pg_total_relation_size('vacuum_test')
);

# Güncellemeden sonra boyuta baktığımızda tablo boyutunun iki katına çıktığımı görüyoruz.
# Çünkü var olan satırlar güncellense de eski satırlar silinmedi. Sadece kullanıcı için
# görünmez oldular. Dolayısıyla tablolara sorgular ile yeni satırlar eklenmese de sık
# güncelleme yapılan tabloların boyutları ciddi miktarlarda artabilir.

# autovacuum süreci PostgreSQL veritabanlarını izler ve bir tablodaki ölü satır sayısında
# çok fazla artış olduğunda VACUUM komutunu çalıştırır. Varsayılan olarak her dakikada bir
# çalışır. autovacuum süreci arkaplanda çalıştığı için etkisi sorgulanmadığı sürece görülmez.
# Süreç istatistiklerini görmek için sistemin sağladığı pg_stat_all_tables viewını sorgulayabiliriz.
SELECT relname,
       last_vacuum,
       last_autovacuum,
       vacuum_count,
       autovacuum_count
FROM pg_stat_all_tables
WHERE relname='vacuum_test';

# VACUUM komutunu kendimiz aşağıdaki gibi çalıştırabiliriz, yukarıda belirtildiği gibi geri
# alınan alan doğrudan diske değil veritabanına sağlanır:
VACUUM vacuum_test;

# VACUUM komutunu bir tablo ismi sağlamadan çalıştırırsak tüm veritabanı için çalışır.

# Eğer kullanılabilir alanı diske de döndürmek istiyorak VACUUM FULL komutunu kullanmalıyız:
VACUUM FULL vacuum_test;