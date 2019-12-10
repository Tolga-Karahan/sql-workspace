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