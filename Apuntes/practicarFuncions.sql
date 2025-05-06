/*Crear un procediment anomenat proc_elim_nous_emps que eliminarà els dos empleats més nous d’un
departament que introduirem el nom per pantalla.
Per fer aquest procediment s’ha de tenir en compte:
S’ha de crear una funció anomenada func_comprv_dept oque comprovarà si el nom del departament existeix a
la base dades utilitzant el bloc d’excepcions. Aquesta funció es crida dins el procediment.
El procediment ha d’utilitzar un cursor que al SELECT es pot utilitzar el LIMIT per limitar a dues les files que
retorna. Quan s’executi el procediment es mostrarà el següent missatge: "L`empleat <FIRST_NAME>,<
LAST_NAME>, amb id <EMPLOYEE_ID> serà eliminat.*/

CREATE OR REPLACE FUNCTION func_comprv_dept(param_dept_name DEPARTMENTS.department_name%TYPE)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
DECLARE
    var_deptId departments.department_id%TYPE;
BEGIN
    SELECT department_id INTO STRICT var_deptId
    FROM departments
    WHERE department_name = param_dept_name;
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'ERROR GENERAL';
END;
$$;

CREATE OR REPLACE PROCEDURE proc_elim_nous_emps(param_dept_name departments.department_name%TYPE)
LANGUAGE plpgsql AS $$
DECLARE
    rec_empleat RECORD;
    dept_id departments.department_id%TYPE;
BEGIN
    -- Obtenir ID del departament
    SELECT department_id INTO dept_id
    FROM departments
    WHERE department_name = param_dept_name;

    -- Bucle amb SELECT directe (no es pot fer LIMIT en cursor amb variable no inicialitzada abans)
    FOR rec_empleat IN
        SELECT employee_id, first_name, last_name
        FROM employees
        WHERE department_id = dept_id
        ORDER BY hire_date DESC
        LIMIT 2
    LOOP
        RAISE NOTICE 'L`empleat %, %, amb id % serà eliminat.',
            rec_empleat.first_name, rec_empleat.last_name, rec_empleat.employee_id;

        DELETE FROM employees WHERE employee_id = rec_empleat.employee_id;
    END LOOP;
END;
$$;

DO $$
DECLARE
    nom_dept DEPARTMENTS.department_name%TYPE :=: vdeptName;
BEGIN
    IF func_comprv_dept(nom_dept) THEN
        CALL proc_elim_nous_emps(nom_dept);
    ELSE
        RAISE NOTICE 'Aquest departament no existeix';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'ERROR GENERAL';
END;
$$;


/*
Exercici 2
Crear un Trigger que cada vegada que es realitzin canvis a la taula LOCATIONS en el camp de CITY han de
quedar enregistrats. El pasos a seguir són:
Crea la taula anomenada canvis_locations on registrarem els nous valors
CREATE TABLE canvis_locations (
id INT GENERATED ALWAYS AS IDENTITY,
location_id numeric(11) NOT NULL,
city_old VARCHAR(30) NOT NULL,
city_new VARCHAR(30) not null,
changed_on TIMESTAMP(6) NOT NULL);
Crea una funció de trigger anomenada func_registrar_canvis_loc() i el seu trigger corresponent anomenat
trig_registrar_canvis_loc que comprovi si el nou nom de la ciutat (city) és diferent de l’antic nom de ciutat, i si
és així, que faci un insert amb els valors corresponents a la taula canvis_locations.
Crea també una funció anomenada func_registrar_canvis() que executarà el trigger anomenat
trig_gravar_operacions de tipus statement-level i que s'executarà després de les sentències UPDATE. La
funció executada per aquest trigger guardarà les següents dades de l'execució a la taula canvis.
CREATE TABLE canvis (
id serial,
timestamp_ TIMESTAMP WITH TIME ZONE default NOW(),
nom_trigger text,
tipus_trigger text,
nivell_trigger text,
ordre text );
Has de fer el joc de proves per comprovar el funcionament dels disparadors.
*/
CREATE TABLE canvis_locations (
id INT GENERATED ALWAYS AS IDENTITY,
location_id numeric(11) NOT NULL,
city_old VARCHAR(30) NOT NULL,
city_new VARCHAR(30) not null,
changed_on TIMESTAMP(6) NOT NULL);

CREATE OR REPLACE FUNCTION func_registrar_canvis_loc() 


CREATE TRIGGER trig_registrar_canvis_loc
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
EXECUTE FUNCTION func_registrar_canvis_loc();




/*
Exercici 3
Crea un procediment anomenat proc_mostrar_emp_dept, que li passaràs com a paràmetre el nom d'un
departament i mostrarà l'ID, el nom i el cognom de l'empleat més antic del departament.
El procediment mostrarà el missatge: "L`empleat més antic del <DEPARTMENT_NAME> té l`ID
<EMPLOYEE_ID> i es diu <FIRST_NAME LAST_NAME>"
Per fer aquest procediment has de tenir en compte el següent:
Has de crear una variable tipus TYPE anomenada dades_emp_type que pugui emmagatzemar l'ID, nom i
cognom d'un empleat.
Has de crear una funció anomenada func_emp_mes_antic qué retornarà una variable del tipus dades_emp_type
amb l'ID, nom i cognom de l’empleat més antic del departament que li passes el nom com a paràmetre.
Aquesta funció la cridaras des del procediment proc_mostrar_emp_dept.
Has de crear també una funció anomenada func_comprv_dep que comprovarà si el departament existeix a la
taula DEPARTMENTS. Aquesta funció ha de retornar TRUE si el departament existeix i FALSE si no existeix
utilitzant una excepció. Aquesta funció la cridaras en el procediment proc_mostrar_emp_dept que llançarà
una excepció amb el missatge "El departament no existeix" en cas que retorni FALSE i que cridarà la funció
func_emp_mes_antic si retorna TRUE. Realitza el joc de proves corresponent.
*/


