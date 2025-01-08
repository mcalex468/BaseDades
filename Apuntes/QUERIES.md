## QUERIES

### Having

```sql
SELECT manager_id AS "Id Manager", SUM(salary) AS "Suma Salary"
FROM employees
GROUP BY manager_id
HAVING SUM(salary)>15000;
```
El HAVING , s'utilitza normalment quan utilitzem FUNCIONS d'AGREGACIONS ( SUM() AVG() COUNT() ... ) y utilitzem GROUP BY llavors no es posa WHERE y utilitzem el HAVING com si fos un WHERE . 