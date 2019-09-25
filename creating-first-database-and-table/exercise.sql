CREATE TABLE animals (
	id bigserial,
	name varchar(50),
	kind varchar(50)
);

CREATE TABLE animal_specifics (
	kind varchar(50),
	life_expectancy numeric,
	origin varchar(50),
	average_height numeric,
	average_weight numeric,
	agressive boolean,
);

INSERT INTO animals (name, kind)
VALUES ('Tolga', 'Homo Sapiens'),
       ('Boncuk', 'Felis Catus');
		
INSERT INTO animal_specifics (kind, life_expectancy, origin, average_height, average_weight, agressive)
VALUES ('Homo Sapiens', 70, 'World', 170, 70, TRUE),
       ('Felis Catus', 10, 'World', 20, 10, TRUE);