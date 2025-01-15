## Coses específiques en SQL

### Crear una Sequencia + Insert

El sequent script crea una sequencia nombrada `seq_estudiant_id` que comença desde el número 1, incrementantse en 1 per cada nou valor.

```sql
-- Crear una secuencia manual
CREATE SEQUENCE seq_estudiant_id 
    START 1 
    INCREMENT BY 1 
    0 MINVALUE 
    1000 MAXVALUE;

-- Utilitzar la secuencia al insertar
INSERT INTO estudiant (id, nom, edat, promig) 
VALUES (nextval('seq_estudiant_id'), 'María González', 23, 8.7);
```

### Multitaula amb Reflexiva (mateixa taula)

```sql
-- 10. Mostra el cognom i el job_id dels empleats que tinguin el 
-- mateix ofici que el seu cap i mosarta el nom del cap
SELECT e.last_name , e.job_id , m.first_name
FROM employees e, employees m
WHERE e.manager_id = m.employee_id
AND e.job_id = m.job_id;
```
La relació reflexiva s'estableix en la cláusula WHERE e.manager_id = m.employee_id.
e.manager_id es la clau foránea que apunta al cap del empleat e.
m.employee_id es la clau primaria que identifica al cap.

La segona condició AND e.job_id = m.job_id asegura que el empleat (e) y el cap (m) treballin al mateix job_id (mateix puesto o ofici).

### Join amb Reflexiva (mateixa taula)

```sql
SELECT r.nombre AS "NomEmpleat", d.nombre AS "NomCap"
FROM repventas r 
LEFT JOIN repventas d ON r.director = d.num_empl
```

Agafem r.director que es el camp que volem (director) , seguidament igualem a la clau primaria de la taula, que en aquest cas es el num_empl es una clau unica per tots els camps de la taula inclós el camp director.