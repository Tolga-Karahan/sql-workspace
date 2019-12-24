# Alvarez, Jr. and Williams, Sr. örneğinde olduğu gibi soneklerden önce virgüllerden kurtulmak
# istiyorsak regexp_replace fonksiyonunu ve '(,)\s[A-Z][a-z].' paternini kullanarak virgülleri
# kaldırabiliriz. 
SELECT  regexp_replace('Alvarez, Jr.', ',\s[A-Z][a-z].', '');

# Eğer isimlerdeki son ekleri bir sütuna koymak için yakalamak istiyorsak regexp_match fonksiyonunu
# kullanabiliriz.
SELECT (regexp_match('Alvarez, Jr.', ',\s([A-Z][a-z].)'))[1];

# Başkanlara ait konuşma metinlerinde 5 ve daha fazla geçen, 5 ve daha fazla karaktere sahip unique
# kelimeleri bulalım. Kelimeleri gösterirken sonlarında bulunan nokta ve virgülleri silelim.
SELECT regexp_replace(sq.words, '[.,]$', ''),
       sq.word_count
FROM (SELECT regexp_split_to_table(speech_text, '\s') AS words,
			 COUNT(*) AS word_count
	  FROM president_speeches
	  GROUP BY words) sq
WHERE sq.word_count >= 5 AND
      length(sq.words) >= 5;