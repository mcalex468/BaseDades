-- EXAMEN 23

DO $$
DECLARE
    v_ciutat TEXT;
    v_row RECORD;
    v_existeix INTEGER;

    CURSOR c_transportistes(ciutat TEXT) IS
        SELECT DISTINCT et.nom_emptransport, et.nif_emptransport, d.ciutat_desti
        FROM Desti d
        JOIN Trasllat t ON t.cod_desti = d.cod_desti
        JOIN Trasllat_EmpresaTransport tet ON tet.nif_empresa = t.nif_empresa AND tet.cod_residu = t.cod_residu
            AND tet.data_enviament = t.data_enviament AND tet.cod_desti = t.cod_desti
        JOIN EmpresaTransportista et ON et.nif_emptransport = tet.nif_emptransport
        WHERE d.ciutat_desti = ciutat;

BEGIN
    RAISE NOTICE 'Introdueix la ciutat:';
    v_ciutat := TRIM(BOTH FROM readline());

    -- Comprovem si existeix alguna entrada amb la ciutat
    SELECT COUNT(*) INTO v_existeix
    FROM Desti
    WHERE ciutat_desti = v_ciutat;

    IF v_existeix = 0 THEN
        RAISE NOTICE 'No existeix cap trasllat cap a la ciutat %', v_ciutat;
    ELSE
        OPEN c_transportistes(v_ciutat);
        LOOP
            FETCH c_transportistes INTO v_row;
            EXIT WHEN NOT FOUND;
            RAISE NOTICE 'L''empresa transportista amb nom % i % ha portat residus a la ciutat %',
                v_row.nom_emptransport, v_row.nif_emptransport, v_row.ciutat_desti;
        END LOOP;
        CLOSE c_transportistes;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- EX 2
CREATE OR REPLACE FUNCTION func_comprv_res(codi_res DECIMAL)
RETURNS BOOLEAN AS $$
DECLARE
    existeix BOOLEAN := FALSE;
BEGIN
    SELECT TRUE INTO existeix
    FROM residu_constituent
    WHERE cod_residu = codi_res
    LIMIT 1;

    RETURN existeix;
    EXCEPTION
    WHEN OTHERS THEN
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- comprovar cuantitat
CREATE OR REPLACE FUNCTION func_comprv_quant(q DECIMAL)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN q >= 0;
END;
$$ LANGUAGE plpgsql;

-- Procediment
CREATE OR REPLACE PROCEDURE proc_mod_quant(codi_res DECIMAL, q_afegir DECIMAL)
LANGUAGE plpgsql
AS $$
DECLARE
    fila residu_constituent%ROWTYPE;
    nova_quantitat DECIMAL;
BEGIN
    IF NOT func_comprv_res(codi_res) THEN
        RAISE NOTICE 'Error: No existeix el codi de residu %', codi_res;
        RETURN;
    END IF;

    IF NOT func_comprv_quant(q_afegir) THEN
        RAISE NOTICE 'Error: La quantitat introduïda és negativa: %', q_afegir;
        RETURN;
    END IF;

    FOR fila IN
        SELECT * FROM residu_constituent WHERE cod_residu = codi_res
    LOOP
        nova_quantitat := fila.quantitat + q_afegir;

        UPDATE residu_constituent
        SET quantitat = nova_quantitat
        WHERE nif_empresa = fila.nif_empresa
          AND cod_residu = fila.cod_residu
          AND cod_constituent = fila.cod_constituent;

        RAISE NOTICE 'La quantitat del residu % amb constituent % de l`empresa % s`ha modificat. L`anterior quantitat era % i ara la quantitat és %',
            fila.cod_residu, fila.cod_constituent, fila.nif_empresa, fila.quantitat, nova_quantitat;
    END LOOP;
END;
$$;

-- JOC PROVES
-- Crides al procediment amb proves
CALL proc_mod_quant(2030, 5);  -- Cas correcte
CALL proc_mod_quant(9999, 10); -- Codi de residu inexistent
CALL proc_mod_quant(2030, -3); -- Quantitat negativa

-- EXERCICI 3
CREATE TABLE MYEMPS AS
SELECT * FROM EMPLOYEES;

CREATE OR REPLACE FUNCTION trig_emps_dept()
RETURNS trigger AS $$
DECLARE
    num_empleats INTEGER;
BEGIN
    IF TG_OP = 'INSERT' THEN
        SELECT COUNT(*) INTO num_empleats
        FROM myemps
        WHERE department_id = NEW.department_id;

        IF num_empleats >= 30 THEN
            RAISE EXCEPTION 'Error: No es pot insertar l`empleat amb codi % doncs el número de treballadors del departament % no pot ser mes gran de 30',
            NEW.employee_id, NEW.department_id;
        END IF;

    ELSIF TG_OP = 'UPDATE' AND NEW.department_id != OLD.department_id THEN
        SELECT COUNT(*) INTO num_empleats
        FROM myemps
        WHERE department_id = NEW.department_id;

        IF num_empleats >= 30 THEN
            RAISE EXCEPTION 'Error: No es pot modificar l`empleat amb codi % doncs el número de treballadors del departament % no pot ser mes gran de 30',
            NEW.employee_id, NEW.department_id;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_emps_dept
BEFORE INSERT OR UPDATE ON myemps
FOR EACH ROW
EXECUTE FUNCTION trig_emps_dept();

-- JOC PROVES
-- Prova d’inserir empleats fins superar 30 en un departament
-- Suposa que el departament 50 ja té 30 empleats
INSERT INTO myemps (employee_id, department_id, first_name, ...) VALUES (300, 50, 'Nom', ...);
-- Prova de modificar un empleat perquè canviï a un departament que ja en té 30
UPDATE myemps SET department_id = 50 WHERE employee_id = 101;

-- EXERICI 4
CREATE TABLE baixaemps (
    employee_id NUMERIC(6,0) PRIMARY KEY,
    manager_id NUMERIC(6,0),
    salary NUMERIC(8,2),
    data_baixa TIMESTAMP(6) NOT NULL,
    usuari TEXT NOT NULL
);

-- TRIGG
CREATE OR REPLACE FUNCTION trig_elim_emps()
RETURNS trigger AS $$
BEGIN
    INSERT INTO baixaemps(employee_id, manager_id, salary, data_baixa, usuari)
    VALUES (OLD.employee_id, OLD.manager_id, OLD.salary, NOW(), CURRENT_USER);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trig_elim_emps
AFTER DELETE ON myemps
FOR EACH ROW
EXECUTE FUNCTION trig_elim_emps();

-- JOC PROVES
-- Eliminar un empleat que no sigui manager (per exemple, el 197)
DELETE FROM myemps WHERE employee_id = 197;

-- Comprovar el contingut de baixaemps
SELECT * FROM baixaemps;


/*
-- EXAMEN 24

Exercici 1 (2 punts). BBDD cemed
L'objectiu d'aquest exercici és implementar un procediment que utilitzant un cursor amb paràmetre modifiqui determinades
 dates d'extracció de les mostres d'un pacient. Implementeu un procediment anomenant proc_act_mostra al qual li passarem 
 el primer cognom d'un pacient i una data. Controlarem que el DNI del pacient es trobi a la taula MOSTRA, i si no existeix
  s'haurà de llançar una excepció amb un missatge. També controlarem si la data que passem com a paràmetre és més antiga 
  que l'u de gener del 2001. Si és més antiga s'ha de llançar una excepció amb un missatge. Si el DNI del pacient existeix
   a la taula MOSTRA i la data no és més antiga que l'u de gener del 2001, actualitzarem la data d'extracció de les mostres 
   del pacient utilitzant un cursor, però només actualitzareu les dates d'extracció que no siguin de l'any 2021. Si la data d
   'extracció de la mostra del pacient que passeu el cognom com a paràmetre no és de l'any 2021, actualitzareu la data d'extracció
    amb la nova data que heu passat com a paràmetre. Amb el cursor comprovareu cada data d'extracció de les mostres del pacient 
    i si la data no correspon a l'any 2021 l'actualitzareu. Captureu qualsevol altre tipus d'errors dins del procediment i 
    reporteu-los al nivell superior mitjançant excepcions mostrant el codi i el missatge associat a l'error.
Proveu el procediment executant les següents sentències: 
CALL proc_act_mostra ('Rocafort', '1998-01-01'); 
CALL proc_act_mostra ('Barranco', '2001-01-01'); 
CALL proc_act_mostra ('Rocafort', '2002-01-01');
*/


/*
Exercici 2 (1,5 punts). BBDD cemed
Volem conèixer la utilització dels diferents consultoris on es fan les visites. Creeu una funció anomenada func_nivell_cons que retorni un missatge informatiu segons la ubicació del consultori que passem com a paràmetre. No s'ha d'imprimir el missatge, s'ha de retornar una variable amb el contingut del missatge. Segons el número de visites que s'hagin realitzat al consultori retornarem un missatge o un altre:
• Si al consultori s'han realitzat menys de 3 visites la funció retorna el missatge 'El consultori té poca ocupació'.
.
• Si al consultori s'han realitzat entre 3 i 4 visites la funció retoma el missatge 'El consultori té una ocupació mitjana'.
• Si al consultori s'han realitzat més de 4 visites la funció retorna el missatge 'El consultori té una alta ocupació'.
Proveu la funció passant com a paràmetre la ubicació 'pis 1 porta 3'.
Modifiqueu la funció func_nivell_cons de manera que controli els casos següents, indicant-ho en el missatge que es mostra a l'usuari:
⚫ La ubicació del consultori que ens han passat com a paràmetre no existeix.
•
No s'ha realitzat cap visita en aquest consultori.
Per prova la primera causística executeu:
SELECT func_nivell cons ('pis 4 porta 3');
Per prova la segona causistica executeu:
SELECT func_nivell cons ('pis 2 porta 10');
*/


/*
Exercici 3 (1,25 punts). BBDD HR
Programa un tipus de dades TYPE personalitzat anomenat loc_pais_type. 
Aquest tipus de dades no deixa fer servir dades del tipus %ROWTYPE ni %TYPE 
perquè són dades d'usuari. Aquest tipus de dades ha de poder guardar el nom 
del país i el número de localitzacions.
Programa una funció anomenada func_loc_pais que calculi el número de localitzacions
 que hi ha al país que li passes el nom del país com a paràmetre, i retorni el 
 resultat utilitzant una variable TYPE del tipus de dades creat anteriorment loc_pais_type.
Programa un procediment anomenat proc_loc_pais que cridi la funció func_loc_pais i
 mostri el missatge: 'El país (COUNTRY_NAME) té (X) localitzacions'.
Al procediment i la funció se'ls ha de passar com a paràmetre el nom del país.
Programa un bloc anònim que demanarà a l'usuari el nom del país i cridi el 
procediment proc_loc_pais. Prova el procediment escrivint per pantalla 'Italy'.
*/
/*
Exercici 4 (1 punt). BBDD Training
Crea un procediment anomenat proc_dadesven que mostri l'identificador i el nom dels
 representants de vendes (venedors). Mostrar també un camp anomenat "result" que 
 mostri 0 si la quota del venedro és inferior a les vendes, en cas contrari ha de
  mostrar 1 a no ser que sigui director d'oficina, en aquest cas ha de mostrar 2.
   Utilitza l'estructura de control de flux CASE i una variable RECORD.
*/

/*
Crea una funció anomenada func_clientsnomes que retorni tots els noms els clients 
que no hagin comprat res durant el mes que passem com a paràmetre.
Prova la funció executant la següent sentència: SELECT func_clientsnomes (12);
*/

/*
Exercici 6 (1 punt) BBDD HR
Programa un trigger anomenat trig_control_act_loc a la taula LOCATIONS que 
cada vegada que es modifiqui el codi postal d'una localització es guardi 
en una taula auxiliar anomenada AUDITLOCS IID de la localització afectada,
 l'antic codi postal, el nou codi postal i la data de la modificació. 
 Aquest trigger també ha d'impedir que s'elimini una localització llançant 
 una excepció amb el missatge d'error corresponent. 
Escriu el joc de proves per provar el funcionament del trigger.
*/

/*
Exercici 7 (1,75 punts) BBDD Training
L'objectiu d'aquest exercici és crear un disparador o Trigger que tingui acualitzat
 automaticament el stock (existències) dels productes a la base de dades.
Quan donem d'alta una nova comanada (pedido) el Trigger comprovarà si el client 
existeix a la base de dades i si la quantitat de la comanda no és superior al 
stock del producte existent. Si el client existeix i la quantitat de producte en
 stcock és igual o superior a la quantitat de la comanda el Trigger permetrà 
 introduir la comanda a la base de dades i a més actualitzarà el stock restant
  la quatitat de producte de la nova comanda de les existencies del producte a
   la base de dades. Si el cient no existeix o la quantitat de producte en stcock
    és inferior a la quantitat de la comanda s'informarà a l'usuari i no permetrà
     donar d'alta la nova comanda.Crea primer una funció que comprovi si un determinat
      client existeix a la base de dades. La funció s'anomena func_existeixclient i 
      li passem com a paràmetre el codi d'un client. La funció retornarà TRUE si 
      els client existeix i FALSE si no existeix.

Comprova el funcionament de la funció func_existeixclient executant les següents sentències:
select func_existeixclient (2111);
select func_existeixclient (99);
Crea una funció que comprovi si tenim prou stok d'un determinat producte. La funció 
s'anomena func_stockok i li passem com a paràmetres una quantitat de producte 
INTEGER, un codi de fabricant CHAR(3) i el codi del producte CHAR(5). La 
funció retomarà TRUE si la quantitat que passem com a paràmetre és igual o 
superior a la quantitat existent a la base de dades i FALSE si la quantitat
 que passem com a paràmetre és inferior a la quantitat existent a la base de dades.
Comprova el funcionament de la funció func_stockok executant les següents sentències: select func_stockok (210, 'rei', '2a45c'); select func_stockok (213, 'rei', '2a45c')
select func_stockok (213, rei','2a4bf');


Crea el Trigger anomenat trig_altacomanda que utilitzarà les funcions func_existeixclient i func_stockok 
per permetre o no l'alta de comanda i fer l'actualització del stcock del producte si es dona d'alta la comanda. 
En cas que es doni d'alta la comanda el Trigger ha de mostrar a l'usuari les existències del producte abans i
 després de l'actualització. Si la comanda no es pot fer es mostra el missatge 'No hi ha prou sctock del producte %', <id_producto>;
Comprova el funcionament del Trigger trig_altaComanda executant les següents sentències: 
insert into pedidos values (12, now(), 2111,105, 'aci', '41003',400, 12.0); insert into pedidos values (11, now (), 2111,105, 'aci', '41003', 200, 12.0);
*/

/*
Exercici 8 (1 punt). BBDD training
Crea una vista de nom clie_paul_view que conté el número de client, el nom de empresa i el límit de crèdit de tots els clients 
assignats al representant de vendes "Paul Cruz". Crea també les tres regles corresponents per que es puguin fer els inserts, els
 updates i els deletes correctament a la taula CLIENTES en en cas que es vulguin fer a la nova vista creada.
Realitza les proves corresponents per comprovar que les regles creades funcionen correctament.
*/
/*
Exercici 9 (0,75 punt). BBDD training
Crea una vista de nom clients_vip_view que mostri únicament aquells clients que la suma dels imports de les seves comandes 
superin 30000. Crea també les tres regles corresponents per que es puguin fer els inserts, els updates i els deletes correctament 
a la taula CLIENTES en en cas que es vulguin fer a la nova vista creada.
Realitza les proves corresponents per comprovar que les regles creades funcionen correctament.*/

Exercici 1
CREATE OR REPLACE PROCEDURE proc_info_pacients(p_dni_metge NUMERIC)
LANGUAGE plpgsql
AS $$
DECLARE
    existeix_metge INTEGER;

    CURSOR cur_pacients IS
        SELECT DISTINCT p.dni, p.cognom1, p.data_naix, p.telefon, p.mail, m.cognom1 AS cognom_metge
        FROM visita v
        JOIN pacient pa ON v.dni_pacient = pa.dni_pacient
        JOIN persona p ON pa.dni_pacient = p.dni
        JOIN metge me ON v.dni_metge = me.dni_metge
        JOIN persona m ON me.dni_metge = m.dni
        WHERE me.dni_metge = p_dni_metge;

    rec_pacient RECORD;
    contador INTEGER := 0;

BEGIN
    SELECT COUNT(*) INTO existeix_metge
    FROM metge
    WHERE dni_metge = p_dni_metge;

    IF existeix_metge = 0 THEN
        RAISE EXCEPTION 'Error El metge amb DNI % no existeix', p_dni_metge;
    END IF;

    OPEN cur_pacients;

    LOOP
        FETCH cur_pacients INTO rec_pacient;
        EXIT WHEN NOT FOUND;

        RAISE NOTICE 'Pacient: DNI=%, Cognom=%, Naixement=%, Telèfon=%',
            rec_pacient.dni, rec_pacient.cognom1, rec_pacient.data_naix, rec_pacient.telefon;

        UPDATE persona
        SET mail = LOWER(rec_pacient.cognom_metge) || '_' || rec_pacient.mail
        WHERE dni = rec_pacient.dni;

        contador := contador + 1;
    END LOOP;

    CLOSE cur_pacients;

    IF contador = 0 THEN
        RAISE EXCEPTION 'Error! El metge amb DNI % no té cap visita registrada', p_dni_metge;
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Codi de l''error: %, Missatge: %', SQLSTATE, SQLERRM;
END;
$$;


EX1 (segunda version)
CREATE OR REPLACE PROCEDURE proc_info_pacients(p_dni_metge INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    v_existeix BOOLEAN;
    v_te_visites BOOLEAN;
    v_cognom_metge PERSONA.cognom1%TYPE;
    v_email_pacient PACIENT.email%TYPE;
    
    curs_pacients CURSOR FOR
        SELECT DISTINCT p.dni, p.cognom1, p.data_naix, p.telefon, p.email
        FROM visita v
        JOIN pacient p ON v.dni_pacient = p.dni
        WHERE v.dni_metge = p_dni_metge;

    v_pacient RECORD;
BEGIN
    SELECT EXISTS (SELECT 1 FROM metge WHERE dni = p_dni_metge) INTO v_existeix;
    IF NOT v_existeix THEN
        RAISE EXCEPTION 'Error! El metge amb DNI % no existeix.', p_dni_metge;
    END IF;

    SELECT EXISTS (SELECT 1 FROM visita WHERE dni_metge = p_dni_metge) INTO v_te_visites;
    IF NOT v_te_visites THEN
        RAISE EXCEPTION 'Error! El metge amb DNI % no té cap visita registrada.', p_dni_metge;
    END IF;

    SELECT cognom1 INTO v_cognom_metge
    FROM persona
    WHERE dni = p_dni_metge;

    FOR v_pacient IN curs_pacients LOOP
        RAISE NOTICE 'Pacient: DNI=%, Cognom=%, Naixement=%, Telèfon=%',
            v_pacient.dni, v_pacient.cognom1, v_pacient.data_naix, v_pacient.telefon;

        UPDATE pacient
        SET email = LOWER(v_cognom_metge || '_' || v_pacient.email)
        WHERE dni = v_pacient.dni;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error detectat: Codi=%, Missatge=%', SQLSTATE, SQLERRM;
END;
$$;

Exercici 2
CREATE TABLE ingressos_visites (
    total NUMERIC(14,3)
);

INSERT INTO ingressos_visites (total) VALUES (0);


CREATE OR REPLACE FUNCTION func_comprovar_data(data DATE)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    IF data <= CURRENT_DATE THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$;


CREATE OR REPLACE PROCEDURE proc_act_ingressos()
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(14,3);
BEGIN
    SELECT COALESCE(SUM(preu), 0) INTO v_total FROM visita;

    UPDATE ingressos_visites
    SET total = v_total;
END;
$$;

CREATE OR REPLACE FUNCTION func_act_ingressos()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC(14,3);
BEGIN
    UPDATE ingressos_visites
    SET total = total + NEW.preu;

    SELECT total INTO v_total FROM ingressos_visites;
    RAISE NOTICE 'Els ingressos actuals per les visites són %', v_total;

    RETURN NEW;
END;
$$;


CREATE TRIGGER trig_act_ingressos
AFTER INSERT ON visita
FOR EACH ROW
EXECUTE FUNCTION func_act_ingressos();


CREATE OR REPLACE FUNCTION func_visit_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NOT func_comprovar_data(NEW.data_visita) THEN
            RAISE EXCEPTION 'Data incorrecte';
        END IF;

    ELSIF TG_OP = 'UPDATE' THEN
        IF NEW.preu <> OLD.preu THEN
            RAISE EXCEPTION 'No es pot modificar el preu';
        END IF;

        IF NOT func_comprovar_data(NEW.data_visita) THEN
            RAISE EXCEPTION 'Data incorrecte';
        END IF;

    ELSIF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'No es pot eliminar una visita';
    END IF;

    RETURN NEW;
END;
$$;


CREATE TRIGGER trig_visit_audit
BEFORE INSERT OR UPDATE OR DELETE ON visita
FOR EACH ROW
EXECUTE FUNCTION func_visit_audit();
