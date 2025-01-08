## Crear y Usar Secuencias en SQL

Las secuencias son objetos de base de datos que generan números únicos, muy útiles para gestionar claves primarias u otras columnas que requieran valores únicos. A continuación, se muestra cómo crear una secuencia manual y utilizarla al insertar datos en una tabla.

### Crear una Secuencia

El siguiente script crea una secuencia llamada `seq_estudiante_id` que comienza desde el número 1, incrementándose en 1 para cada nuevo valor.

```sql
-- Crear una secuencia manual
CREATE SEQUENCE seq_estudiante_id 
    START 1 
    INCREMENT BY 1 
    NO MINVALUE 
    NO MAXVALUE 
    CACHE 1;

-- Usar la secuencia al insertar
INSERT INTO estudiantes (id, nombre, edad, promedio) 
VALUES (nextval('seq_estudiante_id'), 'María González', 23, 8.7);
