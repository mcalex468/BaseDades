-- E 23

-- Exercici 1: Funció func_num_clients
-- Aquesta funció retorna el número de clients assignats a un venedor
CREATE OR REPLACE FUNCTION func_num_clients(par_vendedor_id vendedores.vendedor_id%TYPE)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    var_num_clients INTEGER;
BEGIN
    -- Comptem el nombre de clients assignats al venedor amb ID par_vendedor_id
    SELECT COUNT(*)
    INTO var_num_clients
    FROM clients
    WHERE vendedor_id = par_vendedor_id;

    RETURN var_num_clients;
END;
$$ LANGUAGE plpgsql;

-- Bloc anònim per demanar l'ID del venedor i mostrar el nombre de clients assignats
DO $$
DECLARE
    v_vendedor_id vendedores.vendedor_id%TYPE;
    v_num_clients INTEGER;
BEGIN
    -- Demanem l'ID del venedor (exemple fixat)
    v_vendedor_id := 105;  -- Exemple d'ID de venedor

    -- Cridem la funció per obtenir el número de clients
    v_num_clients := func_num_clients(v_vendedor_id);

    -- Mostrem el resultat
    RAISE NOTICE 'El venedor amb id % té % clients assignats.', v_vendedor_id, v_num_clients;
END;
$$ LANGUAGE plpgsql;

-- Exercici 2: Procediment proc_baixa_ven
-- Procediment per donar de baixa un venedor i reassignar els seus clients al venedor amb menys clients assignats
CREATE OR REPLACE PROCEDURE proc_baixa_ven(par_vendedor_id vendedores.vendedor_id%TYPE)
LANGUAGE plpgsql AS $$
DECLARE
    var_vendedor_min_id vendedores.vendedor_id%TYPE;
BEGIN
    -- Trobem el venedor amb menys clients assignats
    SELECT vendedor_id
    INTO var_vendedor_min_id
    FROM (
        SELECT vendedor_id, COUNT(*) as num_clients
        FROM clients
        GROUP BY vendedor_id
        ORDER BY num_clients
        LIMIT 1
    ) AS min_vendedor;

    -- Reassignem els clients del venedor que es baixa al venedor amb menys clients
    UPDATE clients
    SET vendedor_id = var_vendedor_min_id
    WHERE vendedor_id = par_vendedor_id;

    -- Actualitzem el camp 'titulo' del venedor per marcar-lo com a "Baixa"
    UPDATE vendedores
    SET titulo = 'Baixa'
    WHERE vendedor_id = par_vendedor_id;
END;
$$ LANGUAGE plpgsql;

-- Bloc anònim per demanar l'ID del venedor a donar de baixa i cridar el procediment
DO $$
DECLARE
    v_vendedor_id vendedores.vendedor_id%TYPE;
BEGIN
    -- Demanem l'ID del venedor (exemple fixat)
    v_vendedor_id := 105;  -- Exemple d'ID de venedor

    -- Cridem el procediment per donar de baixa el venedor
    CALL proc_baixa_ven(v_vendedor_id);
    RAISE NOTICE 'El venedor amb ID % ha estat donat de baixa.', v_vendedor_id;
END;
$$ LANGUAGE plpgsql;

-- Exercici 3: Funcions per obtenir informació del producte
-- Tipus TYPE per a emmagatzemar els resultats
CREATE TYPE info_producte AS (
    num_venedors INTEGER,
    num_clients INTEGER,
    mitja_imports NUMERIC,
    min_quantitat INTEGER,
    max_quantitat INTEGER
);

-- Funció per obtenir el número de venedors que han venut un producte
CREATE OR REPLACE FUNCTION func_num_venedors(par_producte_id products.product_id%TYPE, par_fabricant_id manufacturers.manufacturer_id%TYPE)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    var_num_venedors INTEGER;
BEGIN
    SELECT COUNT(DISTINCT v.vendedor_id)
    INTO var_num_venedors
    FROM ventas v
    JOIN products p ON v.product_id = p.product_id
    WHERE p.product_id = par_producte_id AND p.manufacturer_id = par_fabricant_id;

    RETURN var_num_venedors;
END;
$$ LANGUAGE plpgsql;

-- Funció per obtenir el número de clients que han comprat un producte
CREATE OR REPLACE FUNCTION func_num_clients(par_producte_id products.product_id%TYPE, par_fabricant_id manufacturers.manufacturer_id%TYPE)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    var_num_clients INTEGER;
BEGIN
    SELECT COUNT(DISTINCT c.client_id)
    INTO var_num_clients
    FROM ventas v
    JOIN clients c ON v.client_id = c.client_id
    JOIN products p ON v.product_id = p.product_id
    WHERE p.product_id = par_producte_id AND p.manufacturer_id = par_fabricant_id;

    RETURN var_num_clients;
END;
$$ LANGUAGE plpgsql;

-- Funció per obtenir la mitjana d'import de les comandes d'un producte
CREATE OR REPLACE FUNCTION func_mitja_imports(par_producte_id products.product_id%TYPE, par_fabricant_id manufacturers.manufacturer_id%TYPE)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE
    var_mitja_imports NUMERIC;
BEGIN
    SELECT AVG(v.import)
    INTO var_mitja_imports
    FROM ventas v
    JOIN products p ON v.product_id = p.product_id
    WHERE p.product_id = par_producte_id AND p.manufacturer_id = par_fabricant_id;

    RETURN var_mitja_imports;
END;
$$ LANGUAGE plpgsql;

-- Funció per obtenir la quantitat mínima d'un producte en una comanda
CREATE OR REPLACE FUNCTION func_min_quantitat(par_producte_id products.product_id%TYPE, par_fabricant_id manufacturers.manufacturer_id%TYPE)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    var_min_quantitat INTEGER;
BEGIN
    SELECT MIN(v.quantity)
    INTO var_min_quantitat
    FROM ventas v
    JOIN products p ON v.product_id = p.product_id
    WHERE p.product_id = par_producte_id AND p.manufacturer_id = par_fabricant_id;

    RETURN var_min_quantitat;
END;
$$ LANGUAGE plpgsql;

-- Funció per obtenir la quantitat màxima d'un producte en una comanda
CREATE OR REPLACE FUNCTION func_max_quantitat(par_producte_id products.product_id%TYPE, par_fabricant_id manufacturers.manufacturer_id%TYPE)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE
    var_max_quantitat INTEGER;
BEGIN
    SELECT MAX(v.quantity)
    INTO var_max_quantitat
    FROM ventas v
    JOIN products p ON v.product_id = p.product_id
    WHERE p.product_id = par_producte_id AND p.manufacturer_id = par_fabricant_id;

    RETURN var_max_quantitat;
END;
$$ LANGUAGE plpgsql;

-- Bloc anònim per demanar l'ID del producte i fabricant, cridar les funcions i mostrar els resultats
DO $$
DECLARE
    v_producte_id products.product_id%TYPE;
    v_fabricant_id manufacturers.manufacturer_id%TYPE;
    v_info_producte info_producte;
BEGIN
    -- Demanem els identificadors del producte i fabricant (exemples fixats)
    v_producte_id := 1001;  -- Exemple d'ID de producte
    v_fabricant_id := 500;  -- Exemple d'ID de fabricant

    -- Cridem les funcions per obtenir la informació del producte
    v_info_producte.num_venedors := func_num_venedors(v_producte_id, v_fabricant_id);
    v_info_producte.num_clients := func_num_clients(v_producte_id, v_fabricant_id);
    v_info_producte.mitja_imports := func_mitja_imports(v_producte_id, v_fabricant_id);
    v_info_producte.min_quantitat := func_min_quantitat(v_producte_id, v_fabricant_id);
    v_info_producte.max_quantitat := func_max_quantitat(v_producte_id, v_fabricant_id);

    -- Mostrem els resultats
    RAISE NOTICE 'Número de venedors: %, Número de clients: %, Mitjana imports: %, Min Quantitat: %, Max Quantitat: %',
        v_info_producte.num_venedors,
        v_info_producte.num_clients,
        v_info_producte.mitja_imports,
        v_info_producte.min_quantitat,
        v_info_producte.max_quantitat;
END;
$$ LANGUAGE plpgsql;

-- Exercici 4: Funció func_total_imports
-- Aquesta funció retorna la suma dels imports de les comandes d'un venedor
CREATE OR REPLACE FUNCTION func_total_imports(par_vendedor_id vendedores.vendedor_id%TYPE)
RETURNS NUMERIC LANGUAGE plpgsql AS $$
DECLARE
    var_total_imports NUMERIC;
BEGIN
    SELECT SUM(v.import)
    INTO var_total_imports
    FROM ventas v
    WHERE v.vendedor_id = par_vendedor_id;

    RETURN var_total_imports;
END;
$$ LANGUAGE plpgsql;

-- Bloc anònim per demanar l'ID del venedor i mostrar el missatge segons el total d'import
DO $$
DECLARE
    v_vendedor_id vendedores.vendedor_id%TYPE;
    v_total_imports NUMERIC;
BEGIN
    -- Demanem l'ID del venedor (exemple fixat)
    v_vendedor_id := 105;  -- Exemple d'ID de venedor

    -- Cridem la funció per obtenir el total d'import
    v_total_imports := func_total_imports(v_vendedor_id);

    -- Mostrem el missatge corresponent segons el total d'import
    IF v_total_imports < 20000 THEN
        RAISE NOTICE 'Import baix';
    ELSIF v_total_imports BETWEEN 20000 AND 50000 THEN
        RAISE NOTICE 'Import mitjà';
    ELSE
        RAISE NOTICE 'Import elevat';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Exercici 5: Funció func_clients_ven
-- Aquesta funció retorna tota la informació dels clients assignats a un venedor
CREATE OR REPLACE FUNCTION func_clients_ven(par_vendedor_id vendedores.vendedor_id%TYPE)
RETURNS TABLE(client_id INTEGER, client_name VARCHAR, client_email VARCHAR) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT c.client_id, c.client_name, c.client_email
    FROM clients c
    WHERE c.vendedor_id = par_vendedor_id;
END;
$$ LANGUAGE plpgsql;

-- Cridar la funció directament des de la consola
SELECT * FROM func_clients_ven(105);

-- Exercici 6: Funció func_clients_no_mes
-- Aquesta funció retorna tots els codis dels clients que no hagin comprat res durant el mes passat
CREATE OR REPLACE FUNCTION func_clients_no_mes(par_mes INTEGER)
RETURNS TABLE(client_id INTEGER) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT c.client_id
    FROM clients c
    LEFT JOIN ventas v ON c.client_id = v.client_id
    WHERE EXTRACT(MONTH FROM v.sale_date) != par_mes OR v.sale_date IS NULL;
END;
$$ LANGUAGE plpgsql;

-- Cridar la funció directament des de la consola
SELECT * FROM func_clients_no_mes(12);

-- Exercici 7: Procediment proc_dades_director
-- Procediment per mostrar les dades del director d'una oficina
CREATE OR REPLACE PROCEDURE proc_dades_director(par_oficina_id offices.office_id%TYPE)
LANGUAGE plpgsql AS $$
DECLARE
    var_director offices%ROWTYPE;
BEGIN
    -- Obtenim les dades del director de l'oficina
    SELECT *
    INTO var_director
    FROM offices
    WHERE office_id = par_oficina_id;

    -- Mostrem les dades
    RAISE NOTICE 'Director de l''oficina %: %', var_director.office_id, var_director.director_name;
END;
$$ LANGUAGE plpgsql;

-- Bloc anònim per demanar l'ID de l'oficina i cridar el procediment
DO $$
DECLARE
    v_oficina_id offices.office_id%TYPE;
BEGIN
    -- Demanem l'ID de l'oficina (exemple fixat)
    v_oficina_id := 1;  -- Exemple d'ID d'oficina

    -- Cridem el procediment per obtenir les dades del director
    CALL proc_dades_director(v_oficina_id);
END;
$$ LANGUAGE plpgsql;


-- E 24

-- Exercici 1: Procediment proc_act_mostra
-- El procediment modifica les dates d'extracció de les mostres d'un pacient

CREATE OR REPLACE PROCEDURE proc_act_mostra(
    p_cognom_pacient VARCHAR,
    p_data DATE
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_dni VARCHAR;
    v_data_extraccio DATE;
BEGIN
    -- Comprovem si el pacient existeix a la taula MOSTRA
    SELECT dni, data_extraccio
    INTO v_dni, v_data_extraccio
    FROM mostra
    WHERE cognom_pacient = p_cognom_pacient
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE NOTICE 'El pacient amb cognom % no existeix a la taula MOSTRA', p_cognom_pacient;
        RETURN;
    END IF;

    -- Comprovem si la data és més antiga que l'1 de gener de 2001
    IF p_data < '2001-01-01' THEN
        RAISE NOTICE 'La data proporcionada és més antiga que l''1 de gener de 2001';
        RETURN;
    END IF;

    -- Actualitzem les dates d'extracció si la data no és de l'any 2021
    IF v_data_extraccio < '2021-01-01' THEN
        UPDATE mostra
        SET data_extraccio = p_data
        WHERE cognom_pacient = p_cognom_pacient
        AND data_extraccio < '2021-01-01';
    END IF;

    RAISE NOTICE 'Dates d''extracció actualitzades amb èxit.';
END;
$$;
-- Cridem el procediment amb exemples
-- CALL proc_act_mostra('Rocafort', '1998-01-01');
-- CALL proc_act_mostra('Barranco', '2001-01-01');
-- CALL proc_act_mostra('Rocafort', '2002-01-01');


-- Exercici 2: Funció func_nivell_cons
-- Aquesta funció retorna un missatge segons el nombre de visites al consultori

CREATE OR REPLACE FUNCTION func_nivell_cons(p_ubicacio VARCHAR)
RETURNS VARCHAR
LANGUAGE plpgsql
AS
$$
DECLARE
    v_visites INTEGER;
    v_missatge VARCHAR(100);
BEGIN
    -- Comptem el nombre de visites al consultori
    SELECT COUNT(*)
    INTO v_visites
    FROM visites
    WHERE ubicacio = p_ubicacio;

    -- Control de les diferents casuístiques
    IF v_visites < 3 THEN
        v_missatge := 'El consultori té poca ocupació';
    ELSIF v_visites BETWEEN 3 AND 4 THEN
        v_missatge := 'El consultori té una ocupació mitjana';
    ELSIF v_visites > 4 THEN
        v_missatge := 'El consultori té una alta ocupació';
    ELSE
        v_missatge := 'La ubicació del consultori no existeix o no hi ha visites registrades';
    END IF;

    RETURN v_missatge;
END;
$$;

-- Exemple de crida de la funció amb una ubicació no existent
-- SELECT func_nivell_cons('pia 4 porta 3');
-- Exemple de crida de la funció amb una ubicació existent sense visites
-- SELECT func_nivell_cons('pis 2 porta 10');


-- Exercici 3: Tipus personalitzat loc_pais_type i funció/procediment associats

-- Crear el tipus de dades personalitzat
CREATE TYPE loc_pais_type AS (
    nom_pais VARCHAR(100),
    num_localitzacions INTEGER
);

-- Funció per calcular el nombre de localitzacions d'un país
CREATE OR REPLACE FUNCTION func_loc_pais(p_nom_pais VARCHAR)
RETURNS loc_pais_type
LANGUAGE plpgsql
AS
$$
DECLARE
    v_num_localitzacions INTEGER;
BEGIN
    -- Comptem el nombre de localitzacions per país
    SELECT COUNT(*)
    INTO v_num_localitzacions
    FROM localitzacions
    WHERE country = p_nom_pais;

    RETURN (p_nom_pais, v_num_localitzacions);
END;
$$;

-- Procediment per mostrar el nombre de localitzacions d'un país
CREATE OR REPLACE PROCEDURE proc_loc_pais(p_nom_pais VARCHAR)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_loc_pais loc_pais_type;
BEGIN
    -- Cridem la funció per obtenir les dades
    v_loc_pais := func_loc_pais(p_nom_pais);

    -- Mostrem el missatge amb la informació del país
    RAISE NOTICE 'El país % té % localitzacions.', v_loc_pais.nom_pais, v_loc_pais.num_localitzacions;
END;
$$;

-- Bloc anònim per cridar el procediment amb un exemple
DO $$
DECLARE
    v_depid departments.department_id%TYPE := 10; -- Paràmetre de prova
BEGIN
    -- Cridem el procediment per 'Italy'
    CALL proc_loc_pais('Italy');
END;
$$;


-- Exercici 4: Procediment proc_dadesven
-- Procediment per mostrar les dades dels venedors i el seu resultat

CREATE OR REPLACE PROCEDURE proc_dadesven
LANGUAGE plpgsql
AS
$$
DECLARE
    v_resulto INTEGER;
BEGIN
    -- Mostrem les dades dels venedors amb la condició de les seves vendes
    FOR v_vendedor IN
        SELECT v.vendedor_id, v.nombre, v.quota, v.ventas, o.tipo
        FROM vendedors v
        JOIN oficines o ON v.oficina_id = o.oficina_id
    LOOP
        -- Calculem el resultat amb CASE
        v_resulto := CASE
                        WHEN v_vendedor.quota < v_vendedor.ventas THEN 0
                        WHEN v_vendedor.tipo = 'Director' THEN 2
                        ELSE 1
                    END;

        -- Mostrem les dades
        RAISE NOTICE 'Venedor: %, Resultat: %', v_vendedor.nombre, v_resulto;
    END LOOP;
END;
$$;


-- Exercici 5: Funció func_clients_nomes
-- Funció per obtenir els clients que no hagin comprat res durant el mes indicat

CREATE OR REPLACE FUNCTION func_clients_nomes(p_mes INTEGER)
RETURNS TABLE(client_name VARCHAR)
LANGUAGE plpgsql
AS
$$
BEGIN
    RETURN QUERY
    SELECT c.client_name
    FROM clients c
    LEFT JOIN ventas v ON c.client_id = v.client_id
    WHERE EXTRACT(MONTH FROM v.sale_date) != p_mes OR v.sale_date IS NULL;
END;
$$;

-- Prova de la funció
-- SELECT * FROM func_clients_nomes(12);

