# Procedimientos y Funciones en PL/pgSQL

## 🔹 1. Tipos de Datos Personalizados (`CREATE TYPE`)
En PL/pgSQL, podemos crear tipos de datos personalizados para almacenar múltiples valores en una estructura.

### **Ejemplo: Crear un tipo de datos para almacenar información de localización y país**
```sql
CREATE TYPE loc_pais_type AS (
    vr_nom_pais VARCHAR(25),
    vr_num_loc  NUMERIC
);
```

---

## 🔹 2. Funciones (`CREATE FUNCTION`)
Las funciones devuelven un valor y pueden ser utilizadas en `SELECT`, `INSERT`, `UPDATE`, etc.

### **Ejemplo: Función que devuelve el número de localizaciones en un país**
```sql
CREATE OR REPLACE FUNCTION func_loc_pais(par_nom_pais countries.country_name%TYPE)
RETURNS loc_pais_type AS $$
DECLARE
    var_loc_pais loc_pais_type;
BEGIN
    SELECT par_nom_pais, COUNT(l.location_id)
    INTO var_loc_pais.vr_nom_pais, var_loc_pais.vr_num_loc
    FROM locations l
    JOIN countries c ON l.country_id = c.country_id
    WHERE c.country_name ILIKE par_nom_pais;

    RETURN var_loc_pais;
END;
$$ LANGUAGE plpgsql;
```

### **Llamar a la función**
```sql
SELECT func_loc_pais('Italy');
```

---

## 🔹 3. Procedimientos (`CREATE PROCEDURE`)
Los procedimientos pueden ejecutar acciones pero **no devuelven valores directamente**.

### **Ejemplo: Procedimiento que muestra el número de localizaciones en un país**
```sql
CREATE OR REPLACE PROCEDURE proc_loc_pais(p_country_name countries.country_name%TYPE) AS $$
DECLARE
    var_loc_pais loc_pais_type;
BEGIN
    SELECT func_loc_pais(p_country_name) INTO var_loc_pais;
    RAISE NOTICE 'El país % tiene % localizaciones.', var_loc_pais.vr_nom_pais, var_loc_pais.vr_num_loc;
END;
$$ LANGUAGE plpgsql;
```

### **Llamar al procedimiento**
```sql
CALL proc_loc_pais('Italy');
```

---

## 🔹 4. Uso de `ROWTYPE` para manejar registros completos
`%ROWTYPE` permite manejar todas las columnas de una tabla como una sola variable.

### **Ejemplo: Procedimiento que obtiene información de un empleado**
```sql
CREATE OR REPLACE PROCEDURE proc_emp_info(emp_id_param employees.employee_id%TYPE) AS $$
DECLARE
    emp_row employees%ROWTYPE;
    job_row jobs%ROWTYPE;
BEGIN
    SELECT * INTO emp_row FROM employees WHERE employee_id = emp_id_param;
    SELECT * INTO job_row FROM jobs WHERE job_id = emp_row.job_id;

    RAISE NOTICE 'Codi Empleat: %  Nom: %  Càrrec: %  Salari: %',
        emp_row.employee_id, emp_row.first_name, job_row.job_title, emp_row.salary;
END;
$$ LANGUAGE plpgsql;
```

---

## 🔹 5. Manejo de Errores con `RAISE EXCEPTION`
Podemos generar errores personalizados cuando las condiciones no se cumplen.

### **Ejemplo: Procedimiento para dar de alta un trabajo con validaciones**
```sql
CREATE OR REPLACE PROCEDURE proc_alta_job(
    p_job_id jobs.job_id%TYPE,
    p_job_title jobs.job_title%TYPE,
    p_min_salary jobs.min_salary%TYPE,
    p_max_salary jobs.max_salary%TYPE
) AS $$
BEGIN
    IF p_min_salary < 0 OR p_max_salary < 0 THEN
        RAISE EXCEPTION 'ERROR: No pueden ser negativos los salarios';
    END IF;
    IF p_min_salary > p_max_salary THEN
        RAISE EXCEPTION 'ERROR: El salario mínimo (%) no puede ser mayor que el máximo (%)', p_min_salary, p_max_salary;
    END IF;
    
    INSERT INTO jobs(job_id, job_title, min_salary, max_salary)
    VALUES (p_job_id, p_job_title, p_min_salary, p_max_salary);
END;
$$ LANGUAGE plpgsql;
```

---

## 🔹 6. Uso de `LOOP`, `FOR` y `WHILE` en PL/pgSQL
Podemos usar bucles para recorrer secuencias de valores.

### **Ejemplo: Uso de `FOR` para mostrar números**
```sql
DO $$
DECLARE
    var_max INTEGER := 10;
BEGIN
    FOR i IN 1..var_max LOOP
        RAISE NOTICE 'Número: %', i;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
```

---

## 🔹 7. Modificar la Comisión de un Empleado Según su Salario
```sql
CREATE OR REPLACE PROCEDURE proc_mod_com(p_id_emp employees.employee_id%TYPE) AS $$
DECLARE
    v_salary employees.salary%TYPE;
    v_new_commission employees.commission_pct%TYPE;
BEGIN
    SELECT salary INTO v_salary FROM employees WHERE employee_id = p_id_emp;

    IF v_salary < 3000 THEN
        v_new_commission := 0.1;
    ELSIF v_salary BETWEEN 3000 AND 7000 THEN
        v_new_commission := 0.15;
    ELSE
        v_new_commission := 0.2;
    END IF;

    UPDATE employees SET commission_pct = v_new_commission WHERE employee_id = p_id_emp;
END;
$$ LANGUAGE plpgsql;
```

```sql
-- Procedimiento para insertar el departamento
CREATE PROCEDURE proc_alta_dept() AS $$
    DECLARE
        v_dept_id departments.department_id%TYPE;
        v_dept_name departments.department_name%TYPE;
        v_manager_id departments.manager_id%TYPE;
        v_loc_id departments.location_id%TYPE;
    BEGIN
        -- Asignar los valores
        v_dept_id := 10;  -- Ejemplo de valor
        v_dept_name := 'Departamento de Ejemplo';  -- Ejemplo de valor
        v_manager_id := 5;  -- Ejemplo de valor
        v_loc_id := 100;  -- Ejemplo de valor

        -- Insertar el nuevo departamento
        INSERT INTO departments (department_id, department_name, manager_id, location_id)
        VALUES (v_dept_id, v_dept_name, v_manager_id, v_loc_id);

        RAISE NOTICE 'Departamento insertado correctamente';
    END;
$$ LANGUAGE plpgsql;

-- Función para comprobar si el departamento existe
CREATE OR REPLACE FUNCTION func_compv_dept() RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    var_dptId departments.department_id%TYPE;
BEGIN
    -- Supongamos que el ID del departamento es 10
    SELECT department_id INTO var_dptId FROM departments WHERE department_id = 10;
    RAISE NOTICE 'Departamento encontrado';
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Función para comprobar si el manager existe
CREATE OR REPLACE FUNCTION func_compv_mng() RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    var_manager departments.manager_id%TYPE;
BEGIN
    -- Supongamos que el ID del manager es 5
    SELECT manager_id INTO var_manager FROM departments WHERE manager_id = 5;
    RAISE NOTICE 'Manager encontrado';
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Función para comprobar si la ubicación existe
CREATE OR REPLACE FUNCTION func_compv_loc() RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    var_location departments.location_id%TYPE;
BEGIN
    -- Supongamos que el ID de la ubicación es 100
    SELECT location_id INTO var_location FROM departments WHERE location_id = 100;
    RAISE NOTICE 'Ubicación encontrada';
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Bloque anónimo para llamar al procedimiento con valores validados
DO $$
    DECLARE
        v_dept_id departments.department_id%TYPE := 10;
        v_dept_name departments.department_name%TYPE := 'Departamento de Ejemplo';
        v_manager_id departments.manager_id%TYPE := 5;
        v_loc_id departments.location_id%TYPE := 100;
    BEGIN
        -- Validaciones con funciones
        IF func_compv_dept() THEN
            RAISE NOTICE 'El ID del departamento ya existe.';
        ELSE
            RAISE NOTICE 'El ID del departamento no existe.';
        END IF;

        IF func_compv_mng() THEN
            RAISE NOTICE 'El ID del manager existe.';
        ELSE
            RAISE NOTICE 'El ID del manager no existe.';
        END IF;

        IF func_compv_loc() THEN
            RAISE NOTICE 'El ID de la ubicación existe.';
        ELSE
            RAISE NOTICE 'El ID de la ubicación no existe.';
        END IF;

        -- Llamar al procedimiento para insertar el nuevo departamento
        CALL proc_alta_dept();
    END;
$$ LANGUAGE plpgsql;

```

---

## 🔹 Conclusión
- **`CREATE FUNCTION`** → Retorna valores, se usa en `SELECT`
- **`CREATE PROCEDURE`** → No retorna valores, ejecuta acciones
- **`DO $$`** → Bloques anónimos
- **Manejo de errores** con `RAISE EXCEPTION`
- **Bucle** con `FOR`, `WHILE`, `LOOP`
- **Tipos personalizados** con `CREATE TYPE`


