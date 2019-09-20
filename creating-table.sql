CREATE TABLE teachers (
	id bigserial,
	first_name varchar(25),
	last_name  varchar(50),
	school     varchar(50),
	hire_date  date,
	salary	   numeric
);
	
/* bigserial veri tipi her satır eklediğimizde otomatik olarak artan 
bir integer veri tipidir. */
