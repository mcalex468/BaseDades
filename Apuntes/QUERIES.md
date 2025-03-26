## QUERIES

### Group By

Utilitzem el GROUP BY , quan a l'enunciat volem agrupar els resultats, per algun camp. Altra pista important, si hi han agrupacions hi ha group by, per tant HAVING i GROUP BY estan casats.
--> Pista : "Mostra per cada cap (manager_id) / De les seves vendes ..."

Mostra per cada cap (manager_id) quants empleats tenen al seu carrec i quin és el salari
màxim, però només per aquells caps amb més de 6 empleats al seu càrrec.

```sql
SELECT e.manager_id, COUNT(e.employee_id) AS Num_Employees,MAX(e.salary) AS Max_Salary
FROM employees e
GROUP BY e.manager_id
HAVING COUNT(Num_Employees) > 6;
```

Podem posar al COUNT(\*) o COUNT(e.employee_id) ja que es el mateix , asterisc o clau primaria.

### Having

El HAVING , s'utilitza normalment quan utilitzem FUNCIONS d'AGREGACIONS ( SUM() AVG() COUNT() ... ) y utilitzem GROUP BY llavors no es posa WHERE y utilitzem el HAVING com si fos un WHERE .

```sql
SELECT manager_id AS "Id Manager", SUM(salary) AS "Suma Salary"
FROM employees
GROUP BY manager_id
HAVING SUM(salary)>15000;
```

## JOIN'S

El **JOIN** és una operació utilitzada per combinar files de dues o més taules en una base de dades, basant-se en una columna comuna entre elles. L'objectiu principal d'un JOIN és combinar informació que està distribuïda en diferents taules, a través d'una clau comuna.

### Natural Join

Suposem que tenim les taules `employees` i `departments`, amb la columna comuna `department_id` (que és present en ambdues taules). Podem utilitzar **NATURAL JOIN** per combinar les dues taules, sense utilitzar ON o USING:

```sql
SELECT e.first_name, d.department_name
FROM employees e NATURAL JOIN departments d;
```

## INNER JOIN's

### Join

Suposem que tenim les taules `employees` i `departments`, amb la columna comuna `department_id` (que és present en ambdues taules). Per realitzar el **JOIN normal** utilitzem **`ON`** per especificar la condició de la columna comuna.

```sql
SELECT e.first_name, d.department_name
FROM employees e JOIN departments d
ON e.department_id = d.department_id;
```

### Join (USING)

Suposem que tenim les taules `employees` i `departments`, amb la columna comuna `department_id` (que és present en ambdues taules). Podem utilitzar **`USING`** per simplificar la unió:

```sql
SELECT e.first_name, d.department_name
FROM employees e JOIN departments d
USING (department_id);
```

## OUTER JOIN's

### LEFT Join

Si volem mostrar tots els empleats inclosos els nulls al igualar
les taules, hem de utilitzar LEFT o RIGTH per agafar totes les dades de la taula desitjada.

```sql
/*2. Mostra els noms de tots els venedors i si tenen una oficina assignada mostra la ciutat on es
troba l'oficina.*/
SELECT r.nombre, o.ciudad AS "CiutatOficina"
FROM repventas r
LEFT JOIN  oficinas o ON r.oficina_rep = o.oficina;
```

### Rigth Join

Si utilitzem un RIGHT JOIN, mostrarem totes les files de la taula dreta (en aquest cas, la taula oficinas) incloses aquelles que no tinguin coincidència amb la taula esquerra (repventas).

```sql
/* Mostra totes les oficines i, si tenen un venedor assignat, el nom del venedor. */
SELECT o.ciudad AS "CiutatOficina", r.nombre AS "NomVenedor"
FROM oficinas o
RIGHT JOIN repventas r ON o.oficina = r.oficina_rep;
```

# SUBCONSULTA

Utilitzem subconsultes, per obtenir un resulat mitjançant una resposta no directa sino que es la resposta de la subconsulta. Es recomanable primer fer el filtre (subconsulta), i despres la principal.

```sql
/*Mostra el nom i el salari dels empleats que el seu salari superi la mitja del salari dels treballadors (SUBCONSULTA)*/
SELECT nom, salari
FROM empleats
WHERE salari > (
    SELECT AVG(salari)
    FROM empleats
);
```

# SUBCONSULTA CORRELACIONADA

Utilitzem subconsulta correlacionada, en comptes de fer join i group by, igualem les dues taules a la subconsulta,

```sql
/*Exercici 1.
Mostrar totes les dades dels venedors que la suma total dels imports de les comandes que ha tramitat és més petit de 30000. (subconsulta correlacionada).*/

-- Subconsulta Normal
SELECT v.*
FROM repventas v
WHERE num_empl IN ( SELECT rep
                    FROM pedidos p
                    GROUP BY rep
                    HAVING SUM(p.importe) < 30000 );
-- Subconsulta Correlacionada
SELECT v.*
FROM repventas v
WHERE 30000 > ( SELECT SUM(importe)
                FROM pedidos p
                WHERE v.num_empl=p.rep);
```

### Operadores Subconsultas

= (Igual)
Se usa cuando la subconsulta devuelve un único valor (escalar).

```sql
    /*Ejemplo: Obtener empleados cuyo salario es igual al salario promedio de la empresa.*/

    SELECT *
    FROM empleats
    WHERE salari = (SELECT AVG(salari) FROM empleats);
```

IN (Está en la lista)
Se usa cuando la subconsulta devuelve múltiples valores y queremos comprobar si un valor está en ese conjunto.

```sql
    /*Ejemplo: Obtener empleados que trabajan en departamentos con sede en "Barcelona".*/

    SELECT *
    FROM empleats
    WHERE id_departament IN (SELECT id_departament FROM departaments WHERE ciutat = 'Barcelona');
```

NOT IN (No está en la lista)
Lo contrario de IN, filtra aquellos valores que no están en la subconsulta.

```sql
    /*Ejemplo: Obtener empleados que no trabajen en departamentos de Barcelona.*/

    SELECT *
    FROM empleats
    WHERE id_departament NOT IN (SELECT id_departament FROM departaments WHERE ciutat = 'Barcelona');
```

Cuidado con NULL en NOT IN: Si la subconsulta devuelve algún NULL, el resultado será vacío, porque NULL es un valor desconocido y NOT IN no sabe cómo manejarlo.

<> (Distinto de)
Similar a NOT IN, pero solo funciona cuando la subconsulta devuelve un **único valor**.

```sql
    /*Ejemplo: Obtener empleados cuyo salario no sea el promedio de la empresa.*/

    SELECT *
    FROM empleats
    WHERE salari <> (SELECT AVG(salari) FROM empleats);
```

< ANY (Menor que al menos uno)
Se usa cuando la subconsulta devuelve múltiples valores.
< ANY --> MIN

```sql
    /*Ejemplo: Obtener empleados cuyo salario sea menor que al menos un salario del departamento de "IT".*/

    SELECT *
    FROM empleats
    WHERE salari < ANY (SELECT salari FROM empleats WHERE id_departament = 'IT');
Traducción: "Dame los empleados cuyo salario sea menor que alguno de los salarios de IT". Es como un OR.
```

> ANY (Mayor que al menos uno)
> Similar a < ANY, pero buscando valores mayores.

```sql
    /*Ejemplo: Obtener empleados cuyo salario sea mayor que al menos un salario del departamento de "IT".*/

    SELECT *
    FROM empleats
    WHERE salari > ANY (SELECT salari FROM empleats WHERE id_departament = 'IT');
```

Traducción: "Dame empleados que ganan más que el peor pagado de IT".

< ALL (Menor que todos)
Se usa para comparar con todos los valores de la subconsulta.

```sql
    /*Ejemplo: Obtener empleados cuyo salario sea menor que todos los salarios del departamento de "IT".*/

    SELECT *
    FROM empleats
    WHERE salari < ALL (SELECT salari FROM empleats WHERE id_departament = 'IT');
```

Traducción: "Dame los empleados cuyo salario sea menor que el más bajo de IT". Es como un AND.

> ALL (Mayor que todos)
> ALL --> MAX

```sql
    /*Ejemplo: Obtener empleados cuyo salario sea mayor que todos los salarios del departamento de "IT".*/

SELECT *
FROM empleats
WHERE salari > ALL (SELECT salari FROM empleats WHERE id_departament = 'IT');
```
```sql
    /*Ejemplo: Obtener empleados cuyo salario sea mayor que todos los salarios del departamento de "IT".*/

SELECT *
FROM empleats
WHERE salari > ALL (SELECT salari FROM empleats WHERE id_departament = 'IT');
```
```sql
    /*Ejemplo: Obtener empleados cuyo salario sea mayor que todos los salarios del departamento de "IT".*/

SELECT *
FROM empleats
WHERE salari > ALL (SELECT salari FROM empleats WHERE id_departament = 'IT');
```
