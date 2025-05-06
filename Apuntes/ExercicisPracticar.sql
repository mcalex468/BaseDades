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


