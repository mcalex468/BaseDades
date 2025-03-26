# PROCEDIMENTS Y FUNCIONS

```sql
-- Ex 1 Excepcions Diverses Funcions
CREATE PROCEDURE proc_alta_dept(
    p_dept_id departments.department_id%TYPE,
    p_dept_name departments.department_name%TYPE,
    p_manager_id departments.manager_id%TYPE,
    p_loc_id departments.location_id%TYPE
) AS $$
    BEGIN
    INSERT INTO departments (department_id, department_name, manager_id, location_id)
    VALUES (p_dept_id,p_dept_name,p_manager_id,p_loc_id);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION func_compv_dept(param_dptId departments.department_id%TYPE) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    var_dptId departments.department_id%TYPE;
BEGIN
    SELECT department_id INTO STRICT var_dptId FROM departments WHERE department_id = param_dptId;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
    WHEN OTHERS THEN RAISE EXCEPTION 'ERROR GENERAL';
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION func_compv_mng(p_manager departments.manager_id%TYPE) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    var_manager departments.manager_id%TYPE;
BEGIN
    SELECT manager_id INTO STRICT var_manager FROM departments WHERE manager_id = p_manager;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
    WHEN OTHERS THEN RAISE EXCEPTION 'ERROR GENERAL';
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION func_compv_loc(p_loc_id departments.location_id%TYPE) RETURNS BOOLEAN LANGUAGE plpgsql AS $$
DECLARE
    var_location departments.location_id%TYPE;
BEGIN
    SELECT location_id INTO STRICT var_location FROM departments WHERE location_id = p_loc_id;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN FALSE;
    WHEN OTHERS THEN RAISE EXCEPTION 'ERROR GENERAL';
END;
$$ LANGUAGE plpgsql;

-- Bloque anónimo para llamar al procedimiento con valores validados
DO $$
    DECLARE
        v_dept_id departments.department_id%TYPE := :v_iddept;
        v_dept_name departments.department_name%TYPE := :v_nomdept;
        v_manager_id departments.manager_id%TYPE := :v_idmng;
        v_loc_id departments.location_id%TYPE := :v_idloc;
    BEGIN
        -- Validaciones con funciones
        IF func_compv_dept(v_dept_id) THEN
            RAISE EXCEPTION 'Error: El ID del departamento ya existe.';
        END IF;

        IF NOT func_compv_mng(v_manager_id) THEN
            RAISE EXCEPTION 'Error: El ID del manager no existe.';
        END IF;

        IF NOT func_compv_loc(v_loc_id) THEN
            RAISE EXCEPTION 'Error: El ID de la ubicación no existe.';
        END IF;

        -- Llamar al procedimiento para insertar el nuevo departamento
        CALL proc_alta_dept(v_dept_id, v_dept_name, v_manager_id, v_loc_id);
        RAISE NOTICE 'Departamento insertado correctamente';

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error: %', SQLERRM;
    END;
$$ LANGUAGE plpgsql;
```