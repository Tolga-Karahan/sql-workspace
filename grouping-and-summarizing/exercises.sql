# Kütüphane kullanımındaki düşüş ile internete bağlanan cihaz kullanımı arasında
# negatif bir korrelasyon olup olmadığını inceleyelim.
SELECT l2014.stabr, 
       round((CAST(sum(l2014.gpterms) AS numeric(10, 1)) - sum(l2009.gpterms)) /
       	sum(l2009.gpterms) * 100, 2) AS net_computers_used_change,
       round((CAST(sum(l2014.pitusr) AS numeric(10, 1)) - sum(l2009.pitusr)) /
       	sum(l2009.pitusr) * 100, 2) AS net_computers_used_by_year_change
FROM pls_fy2009_pupld09a l2009 JOIN pls_fy2014_pupld14a l2014
ON l2009.fscskey = l2014.fscskey
WHERE l2009.gpterms >= 0 AND
      l2009.pitusr >= 0 AND
      l2014.gpterms >= 0 AND
      l2014.pitusr >= 0
GROUP BY l2014.stabr
ORDER BY net_computers_used_change DESC, net_computers_used_by_year_change DESC;

# Eyaletler yerine bölgelere göre ziyaretçi değişimine bakalım.
SELECT l2014.obereg,
        round((CAST(sum(l2014.visits) AS numeric(10,1)) - sum(l2009.visits)) /
       	sum(l2009.visits) * 100, 2) AS visits_pct_change
FROM pls_fy2009_pupld09a l2009 JOIN pls_fy2014_pupld14a l2014
ON l2009.fscskey = l2014.fscskey
WHERE l2009.visits >= 0 AND l2014.visits >= 0
GROUP BY l2014.obereg
ORDER BY visits_pct_change DESC;

# 2009 ve ya 2014 tablolarının herhangi birinde olmayan kütüphaneleri gösterelim.
SELECT l2009.stabr,
       l2009.libname AS lib_name_09,
       l2014.stabr,
       l2014.libname AS lib_name_14
FROM pls_fy2009_pupld09a l2009 FULL OUTER JOIN pls_fy2014_pupld14a l2014
ON l2009.fscskey = l2014.fscskey
WHERE l2009.fscskey IS NULL OR l2014.fscskey IS NULL;