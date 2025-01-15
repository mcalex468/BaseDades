# DDL en PostgreSQL

## Comandos Básicos de DDL

### 1. **CREATE**
Crea objetos en la base de datos, como tablas.

```sql
CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    salario DECIMAL(10, 2)
);
```

Comentarios de tabla y de columnas.
```sql
COMMENT ON TABLE empleados IS 'Comentario de la Tabla Empleados'
COMMENT ON COLUMN empleados.nombre IS 'Nombre completo del empleado';
COMMENT ON COLUMN empleados.fecha_nacimiento IS 'Fecha de nacimiento del empleado';
COMMENT ON COLUMN empleados.salario IS 'Salario base mensual del empleado';
```

### 2. **MODIFICAR o AÑADIR**
Modifica la estructura de los objetos existentes.

- **Agregar una columna**:

```sql
ALTER TABLE empleados ADD COLUMN edad INT;
```

- **Agregar un nuevo constraint**:

```sql
ALTER TABLE empleados ADD CONSTRAINT new_constraint_name PRIMARY KEY (id);
```

- **Modificar el tipo de datos de una columna**:

```sql
ALTER TABLE empleados ALTER COLUMN salario TYPE DECIMAL(12, 2);
```

- **Renombrar una columna**:

```sql
ALTER TABLE empleados RENAME COLUMN nombre TO nombre_completo;
```

- **Renombrar una tabla**:

```sql
ALTER TABLE empleados RENAME TO trabajadores;
```

### 3. **DROP**
Elimina objetos de la base de datos.

- **Eliminar una columna**:

```sql
ALTER TABLE empleados DROP COLUMN edad;
```

- **Eliminar una tabla**:

```sql
DROP TABLE empleados;
```

- **Eliminar un constraint existente**:

```sql
ALTER TABLE empleados DROP CONSTRAINT old_constraint_name;
```

### 4. **TRUNCATE**
Elimina todos los registros de una tabla sin borrar su estructura.

```sql
TRUNCATE TABLE empleados;
```

---

