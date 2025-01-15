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

### 2. **ALTER**
Modifica la estructura de los objetos existentes.

- **Agregar una columna**:

```sql
ALTER TABLE empleados ADD COLUMN edad INT;
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

#### 2.1 Alters Diferentes

- **Crear un nuevo constraint con el nuevo nombre**:

```sql
ALTER TABLE empleados ADD CONSTRAINT new_constraint_name PRIMARY KEY (id);
```

- **Eliminar un constraint existente**:

```sql
ALTER TABLE empleados DROP CONSTRAINT old_constraint_name;
```

- **Modificar el tipo de datos**:

```sql
ALTER TABLE empleados ALTER COLUMN salario TYPE DECIMAL(12, 2);
```

### 3. **Renombrar Columnas y Tablas**

- **Renombrar una columna**:

```sql
ALTER TABLE empleados RENAME COLUMN nombre TO nombre_completo;
```

- **Renombrar una tabla**:

```sql
ALTER TABLE empleados RENAME TO trabajadores;
```

### 4. **Agregar y Eliminar Columnas**

- **Agregar una columna nueva**:

```sql
ALTER TABLE empleados ADD COLUMN fecha_ingreso DATE;
```

- **Eliminar una columna**:

```sql
ALTER TABLE empleados DROP COLUMN fecha_ingreso;
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

### 4. **TRUNCATE**
Elimina todos los registros de una tabla sin borrar su estructura.

```sql
TRUNCATE TABLE empleados;
```

---

