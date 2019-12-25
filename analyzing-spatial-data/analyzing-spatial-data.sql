# Uzamsal verilerin saklanmasını, analiz edilmesini, değiştirilmesini ve gösterilmesini sağlayan
# GIS(Geographic Information System) tabanlı uygulamalar günümüzde yaygın olarak kullanılmaktadır.
# Uzamsal veri 2 ve ya 3 boyutlu olabilir, yer ve ya nesnelerin şekillerine dair bilgi verir. 
# Geometrik şekiller haritalardaki yollar, göller ve diğer şeylerin özelliklerini temsil edebilir.
# PostgreSQL'de uzamsal veriler üzerinde çalışabilmek için PostGIS uzantısını yüklememiz gerekir.
# Daha karmaşık uzamsal veriler yaratabilmemiz için birden fazla noktayı birleştirmemiz gerekir.
# ISO ve OGC simple feature standard denilen standartlar altında 2 ve 3 boyutlu şekilleri oluşturmak
# ve erişmek için temel geometrileri tanımlamıştır. PostGIS bu standartları destekler. Tanımlanan
# geometriler şunlardır:

# Point: 2 ve ya 2 boyutlu düzlemde tek bir yeri temsil eder.

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
# POLYGON((32.4 65.7, 37.6 -45.3, -54.8 -32.3, 65.3 -67.4))
# MULTIPOINT(-65.3 54.2, 64.7 12.5)
# MULTILINESTRING((-54.9 12.6, -54.9 91.6), (15.6 -34.8, 12.8 37.5), (66.6 31.0, -45.7 23.1, 12.7 32.5))
# MULTIPOLYGON(((32.4 65.7, 37.6 -45.3, -54.8 -32.3), (65.3 -67.4, 12.7 65.2, -17.8 93.8)))

# Dünyanın yuvarlak olması nedeniyle harita uygulamalarında projeksiyonu yapılır. Bu projeksiyon ise
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

