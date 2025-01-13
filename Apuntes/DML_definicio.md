# Data Manipulation Language (DML) en SQL

## ¿Qué es DML?
El **Data Manipulation Language (DML)** es un subconjunto del lenguaje SQL que se utiliza para **gestionar y manipular los datos** almacenados en las tablas de una base de datos. Este lenguaje incluye comandos para realizar operaciones básicas como insertar, actualizar, eliminar y recuperar información.

DML permite interactuar con los datos existentes en una base de datos sin modificar su estructura.

---

## Principales Comandos de DML

### 1. **INSERT**: Insertar datos
El comando `INSERT` se utiliza para agregar nuevos registros a una tabla.

**Sintaxis básica:**
```sql
INSERT INTO nombre_tabla (columna1, columna2, ...)
VALUES (valor1, valor2, ...);
```

**Ejemplo:**
```sql
INSERT INTO empleados (id, nombre, puesto, salario)
VALUES (1, 'Juan Pérez', 'Gerente', 50000);
```

---

### 2. **UPDATE**: Actualizar datos
El comando `UPDATE` permite modificar registros existentes en una tabla.

**Sintaxis básica:**
```sql
UPDATE nombre_tabla
SET columna1 = valor1, columna2 = valor2, ...
WHERE condición;
```

**Ejemplo:**
```sql
UPDATE empleados
SET salario = 55000
WHERE id = 1;
```

> ⚠️ **Nota:** Es importante usar una cláusula `WHERE` para evitar actualizar todos los registros de la tabla.

---

### 3. **DELETE**: Eliminar datos
El comando `DELETE` se utiliza para eliminar registros de una tabla.

**Sintaxis básica:**
```sql
DELETE FROM nombre_tabla
WHERE condición;
```

**Ejemplo:**
```sql
DELETE FROM empleados
WHERE id = 1;
```

> ⚠️ **Nota:** Sin una cláusula `WHERE`, todos los registros de la tabla serán eliminados.

---

### 4. **SELECT**: Recuperar datos
El comando `SELECT` se utiliza para consultar y recuperar datos de una o varias tablas.

**Sintaxis básica:**
```sql
SELECT columna1, columna2, ...
FROM nombre_tabla
WHERE condición;
```

**Ejemplo:**
```sql
SELECT nombre, puesto
FROM empleados
WHERE salario > 40000;
```

---

## Características clave de DML
- **Orientado a los datos:** Se centra en manipular los datos dentro de las tablas.
- **Transaccional:** Las operaciones de DML son parte de una transacción. Esto significa que los cambios realizados pueden confirmarse o deshacerse utilizando los comandos `COMMIT` y `ROLLBACK`.
  
  - **COMMIT:** Confirma los cambios realizados por las operaciones DML.
    ```sql
    COMMIT;
    ```

  - **ROLLBACK:** Deshace los cambios realizados por las operaciones DML si aún no se han confirmado.
    ```sql
    ROLLBACK;
    ```

---

## Ejemplo de una Transacción Completa
```sql
BEGIN TRANSACTION;

-- Insertar un nuevo empleado
INSERT INTO empleados (id, nombre, puesto, salario)
VALUES (2, 'Ana López', 'Analista', 45000);

-- Actualizar el salario de un empleado existente
UPDATE empleados
SET salario = 60000
WHERE id = 1;

-- Si ocurre algún error, deshacer los cambios
ROLLBACK;

-- Si todo está bien, confirmar los cambios
COMMIT;
```
