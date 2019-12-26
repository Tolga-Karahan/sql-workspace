# Uzamsal verilerin saklanmasını, analiz edilmesini, değiştirilmesini ve gösterilmesini sağlayan
# GIS(Geographic Information System) tabanlı uygulamalar günümüzde yaygın olarak kullanılmaktadır.
# Uzamsal veri 2 ve ya 3 boyutlu olabilir ve yer ve ya nesnelerin şekillerine dair bilgi verir. 
# Geometrik şekiller haritalardaki yollar, göller ve diğer şeylerin özelliklerini temsil edebilir.
# PostgreSQL'de uzamsal veriler üzerinde çalışabilmek için PostGIS uzantısını yüklememiz gerekir.
# Daha karmaşık uzamsal veriler yaratabilmemiz için birden fazla noktayı birleştirmemiz gerekir.
# ISO ve OGC simple feature standard denilen standartlar altında 2 ve 3 boyutlu şekilleri oluşturmak
# ve erişmek için temel geometrileri tanımlamıştır. PostGIS bu standartları destekler. Tanımlanan
# geometriler şunlardır:

# Point: 2 ve ya 3 boyutlu düzlemde tek bir yeri temsil eder.

# LineString: 2 ve ya daha fazla noktanın bir doğru ile birleştirilmesi yoluyla oluşturulan şekildir.
# Örneğin yolları ve patikaları bu şekilde gösterebiliriz.

# Polygon: Her biri bir LineString ile oluşturulmuş 3 ve ya daha fazla köşe içeren 2 boyutlu yapıdır.
# Ülkeleri, eyaletleri, binaları, büyük su parçalarını bu şekilde gösterebiliriz.   

# MultiPoint: Bir dizi noktadan oluşur. Örneğin bu noktalar bir perakende zincirinin farklı yerlerdeki
# mağazalarını gösterebilir.

# MultiLineString: Bir dizi LineString'den oluşur. Örneğin devamlılığı olmayan yol parçalarını göstermek
# için kullanabiliriz.

# MultiPolygon: Bir dizi Polygon'dan oluşur. Örneğin bir yol tarafından bölünmüş arazi parçalarını bu
# şekilde aynı nesne ile gösterebiliriz.

# Geometriler WKT(Well Known Text) formatlarına sahiptir. Bu formatta geometrinin ismi, geometriye göre
# değişen sayıda parantez ve geometrinin koordinatları kullanılır. Koordinat belirtilirken önce boylam
# belirtilir. Bazı örnekler aşağıdaki gibidir:

# POINT(-64.3 74.5)
# LINESTRING(24.3 -47.5, 12.5 65.3)
# POLYGON((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 65.3 -67.4, 32.4 65.7))
# MULTIPOINT(-65.3 54.2, 64.7 12.5)
# MULTILINESTRING((-54.9 12.6, -54.9 91.6), (15.6 -34.8, 12.8 37.5), (66.6 31.0, -45.7 23.1, 12.7 32.5))
# MULTIPOLYGON(((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 32.4 65.7), (65.3 -67.4, 12.7 65.2, -17.8 93.8, 65.3 -67.4)))

# Dünyanın yuvarlak olması nedeniyle harita uygulamalarında projeksiyon yapılır. Bu projeksiyon ise
# büyüklüklerin gerçekte olduğundan sapmasına neden olur. Dolayısıyla coğrafik veriler ile çalışırken
# hesaplamaların tutarlı olabilmesi için verilerin hazırlandığı koordinat sistemine dikkat edilmelidir.

# PostGIS ve pek çok diğer GIS uygulamalarında ilk önce kullandığımız koordinat sistemini belirtmemiz
# gerekir. Koordinat sistemini belirtirken SRID'yi kullanırız. GPS tarafından da kullanılan en güncel
# WGS(World Geodetic System) standardı WGS 84'tür. WGS 84 kullanmak için SRID olarak 4326'yı belirleriz.
# PostgreSQL'de PostGIS uzantısını aktif hale getirdiğimizde SRID'leri ve bunların WKT karşılıklarını
# tutan spatial_ref_sys tablosu oluşturulur. 

# WGS 84'ün WKT karşılığını görmek için şu sorgudan yararlanabiliriz:
SELECT srtext
FROM spatial_ref_sys
WHERE SRID = 4326;

# PostGIS veritabanımıza 5 tane veri tipi ekler. Biz geography ve geometry veri tiplerini kullanacağız.
# İki veri tipi de geometriler halinde uzamsal verileri ve SRID'leri tutabilir fakat farkları vardır.

# geography veri tipi küresel yapı üzerine kuruludur. Yuvarlak dünya koordinatlarını kullanır. Bu sayede
# hesaplamalar dünyanın eğriliğini de dikkate alır ve birim olarak metre kullanılır. Fakat aynı nedenle
# matematik daha karmaşık olabilir ve daha az sayıda fonksiyon bulunur. Dünyanın eğriliği de hesaba
# katıldığı için uzaklık hesaplamaları daha isabetli olur. Bu nedenle büyük alanları kapsayan uzamsal 
# veriler üzerinde çalışırken geography veri tipini kullanmalıyız.

# geometry veri yapısı Öklit uzayı üzerine kuruludur. Dolayısıyla eğrilik dikkate alınmaz. Uzaklık
# hesaplamaları daha az duyarlılığa sahiptir. Hesaplamalar seçilen koordinat sisteminin birimine göre
# ifade edilir. Daha çok fonksiyon desteği vardır ve daha hızlı çalışır.

# PostGIS'te şekilleri WKT ve ya koordinatları kullanarak oluşturabiliriz. Fonksiyon isimlerinin çoğu
# ST(spatial type) harfleri ile başlar. 

# ST_GeomFromText(WKT, SRID) fonksiyonu, WKT ile belirtilen şekli geometri veri tipinde oluşturur. SRID
# argümanı opsiyoneldir. 
SELECT ST_GeomFromText('POINT(-64.3 74.5)', 4326);
SELECT ST_GeomFromText('LINESTRING(24.3 -47.5, 12.5 65.3)', 4326);
SELECT ST_GeomFromText('POLYGON((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 61.3 -67.4, 32.4 65.7))', 4326);
SELECT ST_GeomFromText('MULTIPOLYGON(((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 32.4 65.7),
	(65.3 -67.4, 12.7 65.2, -17.8 93.8, 65.3 -67.4)))', 4326);
SELECT ST_GeomFromText('MULTILINESTRING((-54.9 12.6, -54.9 91.6), (15.6 -34.8, 12.8 37.5),
	(66.6 31.0, -45.7 23.1, 12.7 32.5))', 4326);

# ST_GeogFromText(WKT) fonksiyonu WKT ile belirtilen şekli geography veri tipinde oluşturur. 
# ST_GeogFromText(EKWT) fonksiyonu aynı işlevi extended WKT ile yerine getirir. Extended WKT,WKT ve
# SRID bilgilerini içerir. 
SELECT ST_GeogFromText('SRID=4326;MULTIPOLYGON(((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 32.4 65.7),
	(65.3 -67.4, 12.7 65.2, -17.8 93.8, 65.3 -67.4)))');

# Ayrıca her bir şekile özel fonksiyonlar bulunmaktadır. Bu fonksiyonları kullanarakta şekiller oluşturabiliriz.

# Point fonksiyonları ve örnek kullanımları şu şekildedir:
SELECT ST_PointFromText('POINT(72.8, -64.3)', 4326); 
SELECT ST_MakePoint(72.8, -64.3);
SELECT ST_SetSRID(ST_MakePoint(72.8, -64.3), 4326); # 4 argümanlı versiyonuda bulunur. 4. argüman zaman verisi tutar.

# LineString fonksiyonları ve örnek kullanımları şu şekildedir:
SELECT ST_LineFromText('LINESTRING(-67.2 13.4, -37.4 -68.9)', 4326);
SELECT ST_MakeLine(ST_MakePoint(-67.2, 13.4), ST_MakePoint(-37.4, -68.9));

# Polygon fonksiyonları ve örnek kullanımları şu şekildedir:
SELECT ST_PolygonFromText('POLYGON((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 61.3 -67.4, 32.4 65.7))', 4326);
SELECT ST_MakePolygon(ST_GeomFromText('LINESTRING(24.3 -47.5, 12.5 65.3, 24.3 -47.5)'), 4326);
SELECT ST_MPolyFromText('MULTIPOLYGON(((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 32.4 65.7),
	(65.3 -67.4, 12.7 65.2, -17.8 93.8, 65.3 -67.4)))', 4326);

# ABD'de doğrudan tarım ürünleri satışı yapılan marketlere ait bilgiler içeren verimizi yükleyelim.
CREATE TABLE farmers_markets(
	fmid bigint PRIMARY KEY,
	market_name varchar(100) NOT NULL,
	street varchar(180),
	city varchar(60),
	county varchar(25),
	st varchar(20) NOT NULL,
	zip varchar(10),
	longitude numeric(10, 7),
	latitude numeric(10, 7),
	organic varchar(1) NOT NULL
);

COPY farmers_markets
FROM 'path_to_data'
WITH (FORMAT CSV, HEADER);

# Uzamsal sorgular çalıştırmak için enlem ve boylam verilerini tek bir sütunda toplayalım.
# ABD'ye ait uzamsal veriler üzerinde çalıştığımızdan verilerin kapsadığı alan çok geniş. Dolayısıyla
# uzaklıkların tutarlı olması için geography veri tipini kullanmalıyız.
ALTER TABLE farmers_markets ADD COLUMN geog_point geography(POINT, 4326);

UPDATE farmers_markets
SET geog_point = 
	ST_SetSRID(
		    ST_MakePoint(longitude, latitude),
		    4326)::geography;				 	

# Sorguları hızlandırmak için yeni eklediğimiz sütunu indeksleyelim.
# PostgreSQL varsyılan olarak indeks için B-Tree kullanır. Fakat B-Tree basit karşılaştırma operatörleri
# ile sıralayabildiğimiz, arayabildiğimiz veriler için kullanışlıdır. Uzamsal veriler daha karmaşık
# olduğu için Generalized Search Tree kullandık.
CREATE INDEX market_pts_idx ON farmers_markets USING GIST (geog_point);

# Yeni oluşturduğumuz sütunu inceleyelim.
SELECT longitude,
       latitude,
       geog_point,
       ST_AsText(geog_point)
FROM farmers_markets
WHERE longitude IS NOT NULL;

# ST_DWithin() fonksiyonu ile belirtilen iki uzamsal nesnenin belirtilen uzaklık içerisinde olup olmadığını
# görebiliriz. Uzaklık belirtilen değer içerisinde ise true değilse false döndürür. Poligonlar için ise 
# ST_DFullyWithin() fonksiyonunu kullanmalıyız. Des Moines'te bulunan Downtown Farmers pazarından 10km uzaklık
# dahilinde olan diğer pazarları bulalım.
SELECT st,
       city,
       market_name
FROM farmers_markets
WHERE ST_DWithin(geog_point,
                 ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
                 10000)
ORDER BY market_name;

# Diğer pazarların Downtown pazarına tam olarak mesafesini de ölçelim. Bunun için ST_Distance() fonksiyonunu
# kullanabiliriz.
SELECT st,
       city,
       market_name,
       round(
       	    ST_Distance(geog_point,
                        ST_GeogFromText('POINT(-93.6204386 41.5853202)'))::numeric(10,5), 2)
            AS distance
FROM farmers_markets
WHERE ST_DWithin(geog_point,
                 ST_GeogFromText('POINT(-93.6204386 41.5853202)'),
                 10000)
ORDER BY distance;