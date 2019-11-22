# Sadece et üretimi yapan şirketler için bir flag oluşturalım.
UPDATE meat_poultry_egg_inspect
SET meat_processing = 
CASE WHEN activities LIKE '%Meat%'
THEN TRUE ELSE False END;

# Sadece kümes hayvanı eti üreten şirketler için bir flag oluşturalım.
UPDATE meat_poultry_egg_inspect
SET poultry_processing =
CASE WHEN activities LIKE '%Poultry%'
THEN True ELSE False END;

# Sadece et üretimi kümes hayvanı eti üretimi ve her ikisini birden yapan şirket sayısını bulalım.
SELECT 
	(SELECT count(*)
	 FROM meat_poultry_egg_inspect
	 WHERE meat_processing = True)
	 AS meat_processing_companies,
	
	(SELECT count(*) 
	 FROM meat_poultry_egg_inspect
	 WHERE poultry_processing = True)
	 AS poultry_processing_companies,
	
	(SELECT count(*)
	 FROM meat_poultry_egg_inspect
	 WHERE meat_processing = True AND poultry_processing = True)
	 AS meat_poultry_processing_companies;