## QUERIES

### Group By
Utilitzem el GROUP BY , quan a l'enunciat volem agrupar els resultats, per algun camp.
--> Pista : "Mostra per cada cap (manager_id) ..."

Mostra per cada cap (manager_id) quants empleats tenen al seu carrec i quin és el salari
màxim, però només per aquells caps amb més de 6 empleats al seu càrrec.

```sql
SELECT e.manager_id, COUNT(e.employee_id) AS Num_Employees,MAX(e.salary) AS Max_Salary
FROM employees e 
GROUP BY e.manager_id
HAVING COUNT(Num_Employees) > 6;
```

Podem posar al COUNT(*) o COUNT(e.employee_id) ja que es el mateix , asterisc o clau primaria.

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

## INNER JOINs
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
## OUTER JOINs

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