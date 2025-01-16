-- MODIFICACIONS TAULES --
/*Afegir un nou camp a la taula Fitxa, anomenat cp que serà el codi postal. Serà
de tipus varchar(5).*/
ALTER TABLE Fitxa ADD COLUMN cp VARCHAR(5)
/*Comprovar que s’ha creat correctament el camp a la taula.*/
/d fitxa
/* Canviar el nom del nou camp cp. S’ha de dir Codi_Postal.*/
ALTER TABLE Fitxa RENAME COLUMN cp TO Codi_Postal
/d Fitxa
/* Canviar el nom de la restricció anomendada PK_Fitxa. S’ha de dir PrimKey_Fitxa*/
ALTER TABLE Fitxa RENAME CONSTRAINT PK_Fitxa TO PrimKey_Fitxa
/* Modificar la longitud del tipus de dada del camp Codi_Postal. La nova longitud és VARCHAR(10).*/
ALTER TABLE Fitxa ALTER COLUMN Codi_Postal SET DATA TYPE VARCHAR(10)
/* Modificar el tipus de dades del camp Codi_Postal. a El nou tipus de dades per aquest camp és
NUMERIC(5). Si et salta l’error busca per internet com es podria fer.*/

/*i) Elimina la restricció CK_Upper_Prov de la taula FITXA i comprova el canvi.*/
ALTER TABLE Fitxa DROP CONSTRAINT CK_Upper_Prov

/*j) Canvia el nom de la taula FITXA. S’ha de dir ENTRADA i comprova el canvi.
k) Elimina la taula ENTRADA i Comprovar que la taula està eliminada.*/
ALTER TABLE Fitxa RENAME TABLE Entrada
---
DROP TABLE Entrada  /d
/*f) Buida tota la taula amb una sola sentència.*/
TRUNCATE Fitxa;
/*m) Eliminar el registre amb DNI = 45824852.*/
DELETE FROM FITXA WHERE DNI = 45824852;
 /* Crea una seqüència perquè el camp product_id es pugui autoincrementar.
Que comenci per 1, que incrementi 1 i el valor màxim sigui 99999.*/
CREATE SEQUENCE seq_product_id
START WITH 1
INCREMENT 1
MAX VALUE 99999

/*a) (1 punt). Afegeix els següents camps a la taula ORDERF:
cost_ship DOUBLE PRECISION DEFAULT 1500,
logistic_cia VARCHAR(100),
others VARCHAR(250),*/
ALTER TABLE ORDERF ADD COLUMN cost_ship DOUBLE PRECISION DEFAULT 1500;
ALTER TABLE ORDERF ADD COLUMN logistic_cia VARCHAR(100);
ALTER TABLE ORDERF ADD COLUMN others VARCHAR(250);

ALTER TABLE ORDERF DROP COLUMN others;

/*Modifica els valors del camp discount de la taula ORDER_DETAILS dels
registres que la quntitat sigui més gran que 2. El nou descompte serà 7.5. Comprova que s'ha
efectuat el canvi. */
UPDATE ORDER_DETAILS
SET discount = 7.5
WHERE quntity > 2

SELECT * FROM ORDER_DETAILS;


-- CONSULTES BASIQUES --

/*2. Crea una consulta per a mostrar el cognom de l’empleat i el número de departament
d’empleat amb id 176.*/
SELECT last_name, departament_id
FROM employees
WHERE employee_id = 176;
/*4. Crea una consulta per mostrar el cognom de l’empleat, l’identificador del càrrec (JOB:ID) i
la data de contractació dels empleats contractats entre el 20 de febrer de 1998 i l'1 de maig de
1998. Ordenar la consulta en ordre ascendent per data de contractació.*/
SELECT last_name, job_id, hire_date
FROM employees
WHERE hire_date BETWEEN '20/02/1998' AND '1/05/19998'
ORDER BY hire_date;
/*6. Crea una consulta per mostrar el cognom i la data de contractació de tots els empleats
contractats l'any 1998.*/
SELECT last_name, hire_date
FROM employees
WHERE TO CHAR(hire_date 'YYYY') LIKE '1998';
/*8. Crea una consulta per a mostrar el cognom, el salari i la comissió de tots els empleats que
tenen comissions. Ordenar les dades en ordre descendent de salaris i comissions.*/
SELECT last_name,salary,comission_ptc
FROM employees
WHERE comission_ptc IS NOT NULL
ORDER BY salary,comission_ptc DESC;
/*11. Crea una consulta per a mostrar el cognom, el càrrec (JOB_ID) i el salari de tots els
empleats on els càrrecs siguin representants de vendes (AC_ACCOUNT) o encarregats de
stock (AD_ASST) i els salaris no siguin iguals a 2500, 3500 ni 7000.*/
SELECT last_name, job_id, salary
FROM employees
WHERE (job_id ='AC_ACCOUNT' OR job_id='AD_ASST') 
AND (salary NOT IN ('2500','3500','7000'));
-- AGRUPACIONS --

/*6. Mostra el número de països que tenen cadascun dels continents que tinguin com
identificador de regió 1,2 o 3;*/
SELECT COUNT(country_id), region_id
FROM countries
WHERE region_id IN (1,2,3);
/*3. Mostra els oficis (job_title) diferents que hi ha a la base de dades.*/
SELECT DISTINCT(job_id) AS "Oficis"
FROM employees;
/*4. Calcula quants empleats hi ha en cada departament.*/
SELECT COUNT(employee_id), departament_id
FROM employees
GROUP BY departament_id;
/*7. Mostra per cada manager el manager_id, el nombre d'emplets que té al seu carrec i la mitja
dels salaris d'aquests empleats.*/
SELECT manager_id, COUNT(employee_id) AS "NumEmpl" AVG(salary) AS "MitjaSalary"
FROM employees
GROUP BY manager_id
ORDER BY1;
/*8. Mostra l’id del departament i el número d’empleats dels departaments amb més de 4
empleats.*/
SELECT departament_id,COUNT(employee_id) AS "NumEmpleats"
FROM employees
GROUP BY departament_id
HAVING COUNT(employee_id) > 4
ORDER BY 2;

-- CONSULTES MULTI TAULA -- 
/* 1.	Mostra el nom del departament, el nom i el cognom dels
 empleats que el seu departament sigui 'Sales'.*/
SELECT d.departament_name, e.first_name, e.last_name
FROM departaments d, employees e
WHERE d.departament_id = e.departament_id
AND LOWER(departament_name) LIKE 'sales';
/* 2. Mostra el nom del departament i totes les dades dels empleats que
no treballen en el departament 'IT' ni 'Purchasing' */
SELECT d.departament_name, e.(*)
FROM departaments d , employees e
WHERE d.departament_id = e.departament_id 
AND departament_name NOT IN ('IT','Purchasing')
/* 4. Mostra la ciutat i totes les dades dels departaments 
que es troben al codi postal '98199'. */
SELECT l.city, d.(*)
FROM locations l , departaments d
WHERE l.location = d.location
AND l.codi_postal LIKE '98199';

/* 8. Mostra el nom, el cognom i el nom del departament i la 
ciutat dels empleats que treballen a Seattle.*/
SELECT e.first_name,e.last_name,d.departament_name,l.city
FROM employees e, departaments d , locations l 
WHERE e.departament_id = d.departament_id AND d.location = l.location
AND lower(l.city) LIKE 'seattle';

/* 11. Mostra el cognom dels empleats que tinguin el mateix ofici 
que el seu cap, el nom del cap i mostra també el nom de l'ofici (job_title).*/
SELECT e.last_name,c.first_name AS "NomCap",j.job_title 
FROM employees e, employees c, jobs j
WHERE e.manager_id = c.employee_id AND e.job_id = j.job_id
-- el ultimo AND es la premisa del mismo trabajo que su jefe 
AND e.job_id = c.job_id

-- JOINS --

/*1. Mostra els noms de tots els venedors i si tenen assigant un cap mostra el nom del seu cap
com a "cap.*/
SELECT r.nombre AS "NomVenedors" , d.director AS "Cap"
FROM repventas r LEFT JOIN d repventas
ON r.director = d.num_empl



