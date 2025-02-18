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

/*1. Calcular el nombre empleats que realitzen cada ofici a cada departament.
Les dades que es visualitzen són: codi del departament, ofici i nombre empleats.*/
SELECT departament_id, job_id ,COUNT(employee_id),
FROM employees  
GROUP BY departament_id, job_id
ORDER BY 1, 2

/*2.	Mostra el nom del departament i el número d'emplets que té cada departament. */
SELECT d.departament_name, COUNT(e.employee_id) AS "NumEmpleats"
FROM employees e , departament dada
WHERE d.departament_id = e.departament_id
GROUP BY 1;

/*3.	Mostra el número d'empletas del departmant de 'SALES'. */
SELECT d.departament_name, COUNT(e.employee_id) AS "NumeroEmpl"
FROM employees e , departament d
WHERE e.departament_id=d.departament_id
AND LOWER(d.departament_name) ILIKE 'sales'
GROUP BY 1;

/*4.	Mostra quants departaments diferents hi ha a Seattle. */
SELECT DISTINCT(departament_id) AS "TotalDepartaments", l.city
FROM departaments d , locations l
WHERE d.location_id = l.location_id
GROUP BY 2
HAVING LOWER(l.city) ILIKE 'seattle';


/*5.	Mostra per cada cap (manager_id), la suma dels salaris dels seus 
empleats, però només, per aquells casos en els quals la suma del salari 
dels seus empleats sigui més gran que 50000.*/
SELECT SUM(salary) AS "SumaSalari", manager_id 
FROM employees 
GROUP BY 2
HAVING SUM(salary) > 50000;


/*6.	Mostra per cada cap (manager_id) quants empleats tenen al seu carrec i 
quin és el salari màxim, però només per aquells caps amb més de 6 empleats 
al seu càrrec.*/
SELECT manager_id, COUNT(*) AS "NumEmpl" , MAX(salary) AS "SalariEmpl"
FROM employees
GROUP BY manager_id
HAVING COUNT(*) > 6

/*7.	Fes al mateix que a la consulta anterior, però només per aquells 
caps que tinguin com a id_manager_id 100, 121 o 122. Ordena els resultats
per manager_id*/
SELECT manager_id, COUNT(*) AS "NumEmpl" , MAX(salary) AS "SalariEmpl"
FROM employees
WHERE manager_id IN ('100','121','122')
GROUP BY manager_id
HAVING COUNT(*) > 6
ORDER BY manager_id;

-- JOINS --
/*1. Mostra el nom de l’empleat, el nom del departament on treballa i l'id del seu cap.
Fes servir primer JOIN i USING i després o resols amb JOIN ON.*/
SELECT e.firts_name, d.departament_name, e.manager_id
FROM employees e JOIN  departments d
ON e.departament_id=d.departament_id

SELECT e.firts_name, d.departament_name, e.manager_id
FROM employees e JOIN  departments d
USING (departament_id);

/*2. Mostra la ciutat i el nom del departament de la localització 1400 (LOCATION_ID=1400).
Primer ho resols fent servir JOIN ON i després fent servir JOIN USING.*/
SELECT l.city, d.departament_name
FROM locations l JOIN departaments d
ON l.location_id=d.location_id
WHERE location_id = '1400';

SELECT l.city, d.departament_name
FROM locations l JOIN departaments d
USING(location_id)
WHERE location_id = '1400';

/*3. Mostra el cognom i la data de contractació de qualsevol empleat contractat després de
l’empleat Davies. Fes servir JOIN.*/
SELECT e.first_name, e.last_name, e.hire_date AS "DataContractacio"
FROM employees e JOIN employees d
ON e.hire_date > d.hire_date
WHERE LOWER(d.first_name) = 'Davies';

/*4. Mostra el nom i cognom dels empleats, el nom del departament on treballen i el nom de la
ciutat on es troba el departament. Fes servir primer JOIN i USING i després o resols amb
JOIN ON.*/
SELECT e.first_name, e.last_name, d.departament_name,l.city
FROM employees e JOIN departaments d USING(departament_id)
JOIN locations l USING(location_id);

SELECT e.first_name, e.last_name, d.departament_name,l.city
FROM employees e JOIN departaments d ON e.departament_id=d.departament_id
JOIN locations l ON d.location_id=l.location_id

/*5. Mostra l'id del departament i el cognom de l’empleat de tots els empleats que treballin al
mateix departament que un empleat donat. Assignar a cada columna una etiqueta adequada.
Fes servir JOIN.*/
SELECT e.departament_id,e.last_name
FROM employees e JOIN employees e1
ON e.departament_id = e1.departament_id
WHERE e1.last_name = 'Davies';

/*1. Mostra els noms de tots els venedors i si tenen assigant un cap mostra el nom del seu cap
com a "cap.*/
SELECT r.nombre AS "NomVenedors" , d.director AS "Cap"
FROM repventas r LEFT JOIN d repventas
ON r.director = d.num_empl

/*3. Mostra els noms de tots els venedors i si tenen assigant un cap mostra el nom del seu cap
com a "cap", si tenen una oficina assignada mostra la ciutat on es troba l'oficina, i si l'oficina
té assignat un director mostra també el nom del director de l'oficina on treballa el venedor
com a "director". Només es pot utilitzar JOINs.*/
SELECT r.nombre,d.director, o.ciudad 
FROM repventas r LEFT JOIN oficinas o ON r.oficina_rep=o.oficina
LEFT JOIN repventas d ON o.dir=d.num_empl

/*PROVA EXAMEN*/
-- Consultes Basiques
/*3.	 Crea una consulta per a mostrar el cognom i el número de departament de tots els empleats 
que els seus salari no estiguin dins del rang 5000 i 12000.*/
SELECT last_name,departament_id
FROM employees
WHERE salary NOT IN 5000 BETWEEN 12000;
/*4.	Crea una consulta per mostrar el cognom de l’empleat, l’identificador del càrrec (JOB:ID) i la data de contractació
dels empleats contractats entre el 20 de febrer de 1998 i l'1 de maig de 1998. Ordenar la consulta en ordre ascendent per data de contractació.*/
SELECT last_name, job_id, hire_date
FROM employees
WHERE hire_date BETWEEN '20-02-1998' AND '01-05-1998'
ORDER BY hire_date

/*8.	Crea  una consulta per a mostrar el cognom, el salari i la comissió de tots els empleats que tenen comissions. Ordenar les dades en ordre 
descendent de salaris i comissions.*/
SELECT last_name, salary, comission_ptc
FROM employees
WHERE comission_ptc IS NOT NULL
ORDER BY salary, comission_ptc DESC;
/*11.	Crea una consulta per a mostrar el cognom, el càrrec (JOB_ID) i el salari de tots els empleats on els càrrecs siguin 
representants de vendes (AC_ACCOUNT) o encarregats de stock (AD_ASST) i els salaris no siguin iguals a 2500, 3500 ni 7000*/
SELECT last_name, job_id, salary
FROM employees
WHERE (job_id = 'AC_ACCOUNT' OR job_id = 'AD_ASST')
AND salary NOT IN ('2500','3500','7000')
--Funcions i Agrupacions
/*2.	Mostra els empleats que han sigut contractas durant el més de maig.*/
SELECT *  FROM employees WHERE TO_CHAR(hire_date, 'MM') = '05';

/*4.	Calcula quants empleats hi ha en  cada departament.*/
SELECT COUNT(employee_id), departament_id
FROM employees
GROUP BY departament_id
/*7.	 Mostra per cada manager el manager_id, el nombre d'emplets que té al seu carrec i la mitja 
dels salaris d'aquests empleats.*/
SELECT manager_id, COUNT(employee_id) AS "NumEmpleats", AVG(salary)
FROM employees
GROUP BY manager_id;
--Consultes Multitaula

/* 3. Mostra els noms de les ciutats que els noms dels departaments tinguin una u en la segona posició. */
SELECT l.city, d.departament_name
FROM departaments d WHERE locations l d.location_id = d.location_id AND d.departament_name LIKE '%u_';
/* 5. Mostra el job_title i totes les dades dels empleats que el seu job_title sigui Programmer.*/
SELECT j.job_title, e.*
FROM jobs j WHERE employees e e.job_id=j.job_id AND LOWER(job_title) LIKE 'programmer';
/* 9. Mostra els noms de tots els departaments i la ciutat i país on estiguin ubicats.*/
SELECT d.departament_name,l.city,c.country_name
FROM departaments d WHERE locations l d.location_id=l.location_id 
AND l.country_id=c.country_id;
/* 11. Mostra el cognom dels empleats que tinguin el mateix ofici que el seu cap, el nom del cap i mostra 
també el nom de l'ofici (job_title).*/
SELECT e.last_name AS "CognomEmpl",c.first_name AS "NomCap",j.job_title AS "Ofici"
FROM employees e WHERE employees c e.manager_id=c.employee_id 
AND e.job_id=j.job_id 
AND e.job_id=c.job_id

-- Agrupacions Multitaula
/*1.	Calcular el nombre empleats que realitzen cada ofici a cada departament. 
Les dades que es visualitzen són: codi del departament, ofici i nombre empleats.*/
SELECT departament_id, job_id, COUNT(employee_id)
FROM employees 
GROUP BY departament_id, job_id
ORDER BY 1,2;
/*2.	Mostra el nom del departament i el número d'emplets que té cada departament. */
SELECT d.departament_name AS "NomDept" , COUNT(*) AS "NumeroEmpleats"
FROM departaments d WHERE employees e d.departament_id=e.departament_id
GROUP BY d.departament_name;
/*3.	Mostra el número d'empletas del departmant de 'SALES'. */
SELECT COUNT(e.*), d.departament_name
FROM employees e WHERE departaments d e.departament_id=d.departament_id
AND LOWER(d.departament_name) LIKE 'sales'
GROUP BY d.departament_name;

/*5.	Mostra per cada cap (manager_id), la suma dels salaris dels seus empleats, però només, per aquells
casos en els quals la suma del salari dels seus empleats sigui més gran que 50000.*/
SELECT manager_id, SUM(salary) AS "SumSalari"
FROM employees e 
GROUP BY manager_id
HAVING SUM(salary) > 50000;
-- JOINS
/*3.	Mostra el cognom i la data de contractació de qualsevol empleat contractat després de l’empleat Davies. Fes servir JOIN.*/
SELECT e.last_name,e.hire_date
FROM employees e JOIN employees d
ON ( e.hire_date > d.hire_date ) 
AND  LOWER(e.first_name) LIKE 'davies';

/*5.	Mostra l'id del departament i el cognom de l’empleat de tots els empleats que treballin al 
mateix departament  que un empleat donat. Assignar a cada columna una etiqueta adequada. Fes servir JOIN.*/
SELECT e.departament_id, e.last_name,
FROM employees e JOIN  
ON e.departament_id=
WHERE e.

/*Ex2. Mostra els noms de tots els venedors i si tenen una oficina assignada mostra la ciutat on es troba l'oficina.*/
SELECT r.nombre, o.ciudad
FROM repventas r LEFT JOIN oficinas o 
ON r.oficina_rep=o.oficina

-- SUBCONSULTA 
-- Trobar els empleats que treballen al mateix departament que 'Steven King'.
SELECT *
FROM employees
WHERE departament_id = ( SELECT departament_id
                         FROM employees
                         WHERE LOWER(first_name) = 'steven'
                         AND LOWER(last_name) = 'king');

--  Llistar els empleats que guanyen més que 'Nancy Greenberg'
SELECT *
FROM employees
WHERE salary > (SELECT salary
                FROM employees
                WHERE UPPER(first_name) LIKE 'NANCY' AND UPPER(last_name)='GREENBERG')

-- Localització d'oficines d'un departament específic
SELECT *
FROM locations 
WHERE location_id = (SELECT location_id
                     FROM departments
                     WHERE departament_name = 'IT');

                    
/*Preparació Examen 2*/
-- Consultes Facils
/*1️⃣ Mostra el nom, cognom i salari de tots els empleats que guanyen més de 5000 euros.
2️⃣ Llista els empleats que treballen al departament 50.
3️⃣ Mostra el nom i salari dels empleats el nom dels quals comenci per 'J'.
4️⃣ Mostra el nom del departament i la quantitat d'empleats que hi treballen.*/
SELECT first_name, salary
FROM employees
WHERE salary > 5000;

SELECT *
FROM employees
WHERE departament_id = '50';

SELECT first_name
FROM employees
WHERE first_name LIKE 'J%';

SELECT departament_name, COUNT(departament_id) AS "Quantitat Empleats"
FROM departments 
--3. Calcula el màxim salari per cadascun dels
 -- grups d'empleats classificats per tipus de treball (Job_id)
SELECT job_id,MAX(salary)
FROM employees
GROUP BY job_id;

--7. Ara mostra la suma dels sous dels empleats per cada 
--ofici, però mosta només els que la suma sigui superior a 60000 
SELECT job_id, SUM(salary)
FROM employees
GROUP BY job_id
HAVING SUM(salary) > 60000;

--5. Mostra quant guanyen en total tots
-- els empleats que són Stock Manager (job_id= ST_MAN).
SELECT job_id,SUM(salary)
FROM employees
WHERE job_id = 'ST_MAN'
GROUP BY job_id;


-- Consultes Multitaula
SELECT e.first_name,e.last_name,d.departament_name
FROM employees e , departments d 
WHERE e.departament_id=d.departament_id

SELECT employee_id,l.city
FROM employees e, locations l
WHERE e.location_id
/* 3.	Mostra totes les dades dels empleats 
que treballen en el departament de Marketing*/
SELECT e.*,d.departament_name
FROM employees e , departaments d
WHERE e.departament_id=d.departament_id
AND d.departament_name like 'Marketing';

/*6.	Mostra l’identificador d'empleat, 
el cognom i l'ofici (job_title) dels empleats del departament 80.*/
SELECT e.employee_id,j.job_title
FROM employees e , departments d
WHERE e.departament_id=d.departament_id
AND d.departament_id = 80;

/* 8.	Mostra  el cognom, nom d’ofici i nom de departament de tots 
els empleats que el seu cognom comença per ‘a’ i tingui més de 6 lletres.*/
SELECT last_name,job_title,departament_name
FROM employees e , departaments d , jobs j 
WHERE e.departament_id=d.departament_id AND j.jobs_id=e.jobs_id
AND LOWER(first_name) LIKE 'a%' AND length(last_name) > 6;

/* 9.	Mostra el nom i cognom dels empleats conjuntament amb el 
nom i cognom del seu corresponent cap, ordenat pel cognom del cap.*/
SELECT e.first_name,e.last_name,c.first_name, c.last_name
FROM employees e , employees c
WHERE e.manager_id=c.employee_id
ORDER BY c.last_name;


/*14.	A la taula empleats, visualitza, per tots els caps (manager_id) el número d'empleats que té 
al seu carrec i la mitja dels salaris d'aquests empleats. Reanomena els camps com "id cap"
"Num Empleats" i "Mitjana Salari". El camp del salari mostra'l com número enter sense
decimals.*/

SELECT manager_id AS "Id Cap",COUNT(employee_id) AS "Num Empleats", ROUND(AVG(salary),1) AS "Mitja Salary"
FROM employees
GROUP BY manager_id;

-- Joins
/*3.	Mostra el número d'empletas del departmanet anomenat 'Sales'.
Reanomena el número d'empleats com a "Num Empleats".*/
SELECT COUNT(e.employee_id) AS "Num Empleats"
FROM employees e JOIN departaments d USING(departament_id)
WHERE departament_name LIKE 'Sales' 

/*4.	Mostra el nom del continent i el número de països de cada continent.*/
SELECT r.region_name,COUNT(c.country_id)
FROM regions r JOIN countries c USING(region_id)
GROUP BY r.region_name


/*2.	Mostra el cognom i la data de contractació per a tots els empleats contractats
 abans que els seus directors,  juntament amb els cognoms i data de contractació dels 
 directors. Anomenar les columnes com a "Employee", "Emp Hiredate", "Manager" i
 "Mgr Hiredate" respectivament. Fes servir JOIN.*/
SELECT e.first_name AS "Emp",e.hire_date AS "Emp Hiredate",d.last_name AS "Manager" ,d.hire_date AS "MGR Hiredate"
FROM employees e JOIN employees d
ON e.manager_id=d.employee_id AND e.hire_date < d.hire_date;

-- Left
SELECT *.e
FROM employees e 
LEFT JOIN departaments d ON e.departament_id=d.departament_id;

-- Rigth
SELECT e.*,d.departament_name
FROM employees e
RIGHT JOIN departaments d USING(departament_id);

-- Subconsultes
-- =,>,<,IN, NOT IN, ANY, ALL



/*1.	Mostra els departaments en els que hi hagi persones amb noms 
que comencen  per la lletra A. */

SELECT departament_name
FROM departaments d
WHERE departament_id IN ( SELECT departament_id
                          FROM employees
                          WHERE first_name LIKE 'A%');

/*3.	Mostra els cognoms dels empleats que treballin en un departament amb un codi més 
alt que el codi del departament  de Vendes (Sales) (fer-ho mitjançant subconsulta i 
mitjançant consulta multitaula)*/
SELECT last_name
FROM employees
WHERE departament_id > ( SELECT departament_id
                         FROM departments
                         WHERE departament_name LIKE 'Sales');

/*4.	Mostra els cognoms i els salaris dels empleats
que tenen un salari inferior al salari mitja (AVG(salary))*/
SELECT last_name, salary 
FROM employees
WHERE salary < ( SELECT AVG(salary)
                 FROM employees);

/*6.	Mostra els cognoms de tots els empleats que no treballin al departament on
 treballa Steven King.*/
 SELECT last_name
 FROM employees
 WHERE departament_id <> ( SELECT departament_id
                           FROM employees
                           WHERE first_name='Steven'
                           AND last_name='King'); 

/*10.	Mostra el nom i l'edat de totes les persones de l'equip de vendes que 
dirigeixen una oficina. Utilitza una Subconsulta.*/
SELECT nombre,edad
FROM repventas
WHERE num_empl IN ( SELECT dir
                    FROM oficinas );

/*8.	Mostra els noms dels departaments que estan a Seattle.*/
SELECT departament_name
FROM departaments 
WHERE location_id = ( SELECT location_id
                        FROM locations
                        WHERE city = 'Seattle');

-- JOIN
/*3.	Mostra el número d'empletas del departmanet anomenat 'Sales'. 
Reanomena el número d'empleats com a "Num Empleats".*/
SELECT d.departament_id,COUNT(e.employee_id) AS "Num Empleats"
FROM employees e JOIN departaments d USING(departament_id)
WHERE d.departament_name LIKE 'Sales';


/*4.	Mostra el nom del continent i el número de països de cada continent.*/
SELECT r.region_name, COUNT(c.country_id)
FROM regions r JOIN countries c ON r.region_id=c.region_id
GROUP BY 1;


-- SUBCONSULTA 
/*1.	Mostra els departaments en els que hi hagi persones amb noms que comencen per la lletra A. */
SELECT departament_name
FROM departments  
WHERE departament_id IN ( SELECT departament_id
                          FROM employees
                          WHERE first_name LIKE 'A%');

/*5.	Mostra els cognom de tots els empleats que el seu lloc de treball sigui Sales Manager.*/
SELECT last_name
FROM employees
WHERE job_id IN ( SELECT job_id
                  FROM jobs
                  WHERE job_title 'Sales manager');

/*11.	Mostra el nom i l'edat de totes les persones de l'equip de vendes que no dirigeixen una oficina. Utilitza una
Subconsulta.*/
SELECT nombre, edad
FROM repventas v
WHERE num_empl != ALL ( SELECT dir 
                       FROM oficinas );

-- AVANÇADA
/*5. 	Mostra el id i el número d'empleats del departament que té més empleats.*/
SELECT departament_id, COUNT(employee_id)
FROM employees
GROUP BY departament_id
HAVING COUNT(employee_id) = ( SELECT MAX(c)
                              FROM ( SELECT COUNT(employee_id) AS c
                                               FROM employees
                                               GROUP BY departament_id ) AS d );


/*6. Fes servir la consulta anterior per trobar el nom del departament que més empleats té.*/
SELECT e.departament_id, COUNT(e.employee_id), d.departament_name
FROM departaments d , employees e
WHERE d.departament_id=e.departament_id 
GROUP BY 1,3
HAVING COUNT(e.employee_id) IN ( SELECT MAX(c)
                                 FROM ( SELECT COUNT(employee_id) AS c
                                        FROM employees
                                        GROUP BY departament_id ) AS d );

-- SUBCONSULTA CORRELACIONADA

/*Exercici 1. BBDD Training
Mostrar totes les dades dels venedors que la suma total dels imports de les comandes que ha tramitat
és més petit de 30000. (Utilitza una subconsulta correlacionada).*/
SELECT v.*
FROM repventas v
WHERE 30000 > (SELECT SUM(importe)
               FROM pedidos p
               WHERE v.num_empl=p.rep); 

/*Exercici 2. BBDD Training
Mostrar totes les dades d’aquells clients que la suma dels imports de les seves comandes sigui inferior
a 20000. (Utilitza una subconsulta correlacionada).
*/
SELECT c.*
FROM clients c
WHERE 20000 > (SELECT SUM(importe)
               FROM pedidos p
               WHERE c.num_clie=p.clie);
/*Exercici 3. BBDD Training
Mostrar les següents dades de les comandes tramitades per cada venedor: nom_venedor,
quantitat_comandes, import_total, import_minim, import_maxim, importe_promig. Si el venedor no
ha fet cap comanda no el mostris. (Utilitza subconsultes correlaciondes per mostrar els resultat quan
pertorqui).*/
SELECT v.nombre,
(SELECT COUNT(num_pedido) FROM pedidos p WHERE v.num_empl=p.rep),
(SELECT SUM(importe) FROM pedidos p WHERE v.num_empl=p.rep),
(SELECT MAX(importe) FROM pedidos p WHERE v.num_empl=p.rep),
(SELECT MIN(importe) FROM pedidos p WHERE v.num_empl=p.rep),
(SELECT AVG(importe) FROM pedidos p WHERE v.num_empl=p.rep)
FROM repventas v
WHERE (SELECT COUNT(num_pedido) FROM pedidos p WHERE v.num_empl=p.rep) > 0;
/*Exercici 5. BBDD Training
Mostra l'identificador dels clients que han fet més compres (que ha fet més comandes) i el número de
comandes que ha fet.*/
SELECT p.clie, COUNT(p.num_pedido)
FROM pedidos
GROUP BY 1
HAVING COUNT(p.num_pedido) = (SELECT MAX(c)
                              FROM ( SELECT SUM(num_pedido) AS c
                                     FROM pedidos
                                     GROUP BY clie) AS a );