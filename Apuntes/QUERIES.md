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

### Having

El HAVING , s'utilitza normalment quan utilitzem FUNCIONS d'AGREGACIONS ( SUM() AVG() COUNT() ... ) y utilitzem GROUP BY llavors no es posa WHERE y utilitzem el HAVING com si fos un WHERE . 

```sql
SELECT manager_id AS "Id Manager", SUM(salary) AS "Suma Salary"
FROM employees
GROUP BY manager_id
HAVING SUM(salary)>15000;
```
