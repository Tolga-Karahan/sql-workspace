SELECT last_name, first_name, school
FROM teachers
ORDER BY school, last_name DESC; 

SELECT *
FROM teachers
WHERE salary > 40000 AND first_name LIKE 'S%';

SELECT last_name, first_name, salary, hire_date
FROM teachers
WHERE hire_date >= '2010-01-01' 
ORDER BY salary DESC;
