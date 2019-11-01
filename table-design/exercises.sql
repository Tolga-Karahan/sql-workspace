CREATE TABLE albums(
	album_id bigserial CONSTRAINT album_key PRIMARY KEY,
	album_catalog_code varchar(100) NOT NULL,
	album_title text NOT NULL,
	album_artist text NOT NULL,
	album_release_date date CHECK (date BETWEEN '01-01-1970' AND '30-12-2019'),
	album_genre varchar(40),
	album_description text
);

CREATE TABLE songs(
	song_id bigserial CONSTRAINT song_key PRIMARY KEY,
	song_title text NOT NULL,
	song_artist text,
	album_id bigint REFERENCES albums(album_id) ON DELETE CASCADE
);

# album_catalog_code primary key olarak kullanılabilir. Böylece fazlada sütun oluşturmayız.
# album_title, album_artist, album_genre, song_title sütunlarını indeksleyebiliriz. Bu sütunlar
# WHERE keywordü ile sık sık kullanılabilir. Ayrıca birleştirme işlemini daha hızlı yapabilmek
# için foreign key olan album_id sütununu da indeksleyebiliriz.