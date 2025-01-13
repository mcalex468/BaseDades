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

## Casos Prácticos Avanzados

### 1. **Renombrar Constraints**
En PostgreSQL no es posible renombrar directamente un constraint. Es necesario eliminar el constraint existente y crearlo nuevamente.

- **Eliminar un constraint existente**:

```sql
ALTER TABLE empleados DROP CONSTRAINT old_constraint_name;
```

- **Crear un nuevo constraint con el nuevo nombre**:

```sql
ALTER TABLE empleados ADD CONSTRAINT new_constraint_name PRIMARY KEY (id);
```

### 2. **Cambiar el Tipo o Tamaño de una Columna**

- **Modificar el tipo de datos**:

```sql
ALTER TABLE empleados ALTER COLUMN salario TYPE DECIMAL(12, 2);
```

- **Cambiar una columna para que no acepte valores nulos**:

```sql
ALTER TABLE empleados ALTER COLUMN nombre SET NOT NULL;
```

- **Permitir valores nulos en una columna**:

```sql
ALTER TABLE empleados ALTER COLUMN nombre DROP NOT NULL;
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

### 5. **Eliminar Todos los Registros de una Tabla**

```sql
TRUNCATE TABLE empleados;
```

---