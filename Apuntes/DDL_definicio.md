
# DDL en PostgreSQL

## Comandes Bàsiques de DDL

### 1. **CREATE**
Crea objectes a la base de dades, com taules.

```sql
CREATE TABLE empleats (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100),
    salari DECIMAL(10, 2)
);
```

Comentaris de taula i de columnes.

```sql
COMMENT ON TABLE empleats IS 'Comentari de la Taula Empleats'
COMMENT ON COLUMN empleats.nom IS 'Nom complet de l'empleat';
COMMENT ON COLUMN empleats.data_naixement IS 'Data de naixement de l'empleat';
COMMENT ON COLUMN empleats.salari IS 'Salari base mensual de l'empleat';
```

### 2. **MODIFICAR o AFEGIR**
Modifica l'estructura dels objectes existents.

- **Afegir una columna**:

```sql
ALTER TABLE empleats ADD COLUMN edat INT;
```

- **Afegir una nova restricció**:

```sql
ALTER TABLE empleats ADD CONSTRAINT nova_restriccio PRIMARY KEY (id);
```

- **Modificar el tipus de dades d'una columna**:

```sql
ALTER TABLE empleats ALTER COLUMN salari SET DATA TYPE DECIMAL(12, 2);
```

- **Canviar el nom d'una columna**:

```sql
ALTER TABLE empleats RENAME COLUMN nom TO nom_complet;
```

- **Canviar el nom d'una taula**:

```sql
ALTER TABLE empleats RENAME TO treballadors;
```

### 3. **DROP**
Elimina objectes de la base de dades.

- **Eliminar una columna**:

```sql
ALTER TABLE empleats DROP COLUMN edat;
```

- **Eliminar una taula**:

```sql
DROP TABLE empleats;
```

- **Eliminar una restricció existent**:

```sql
ALTER TABLE empleats DROP CONSTRAINT antiga_restriccio;
```

### 4. **TRUNCATE**
Elimina tots els registres d'una taula sense eliminar la seva estructura.

```sql
TRUNCATE TABLE empleats;
```
