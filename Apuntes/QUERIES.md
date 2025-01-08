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

Suposem que tenim les taules `employees` i `departments`, amb la columna comuna `department_id` (que és present en ambdues taules). Podem utilitzar **NATURAL JOIN** per combinar les dues taules:

```sql
SELECT e.first_name, d.department_name
FROM employees e NATURAL JOIN departments d;
```

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