-- ============================================================================
-- Day_04: DDL (Data Definition Language) Demonstration
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- 1. SCHEMATA ERSTELLEN
-- Schemata dienen zur logischen Gruppierung von Datenbankobjekten.
-- Falls das Schema existiert, loeschen wir die abhaengigen Objekte zuerst.
IF OBJECT_ID('Schule.Anmeldungen', 'U') IS NOT NULL DROP TABLE Schule.Anmeldungen;
IF OBJECT_ID('Schule.Schueler', 'U') IS NOT NULL DROP TABLE Schule.Schueler;
IF OBJECT_ID('Schule.Kurse', 'U') IS NOT NULL DROP TABLE Schule.Kurse;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Schule')
BEGIN
    DROP SCHEMA Schule;
END
GO

CREATE SCHEMA Schule;
GO

-- 2. TABELLEN ERSTELLEN (CREATE TABLE)
-- Definition von Spalten, Datentypen und Integritaetsbedingungen (Constraints)

-- Tabelle: Schueler
CREATE TABLE Schule.Schueler (
    SchuelerID INT IDENTITY(1,1) PRIMARY KEY, -- Auto-Inkrement, Primärschlüssel
    Name NVARCHAR(100) NOT NULL,              -- Unicode-Zeichenkette, Pflichtfeld
    [Alter] TINYINT NOT NULL,                 -- Kleine Ganzzahl (0-255)
    RegistriertSeit DATE DEFAULT GETDATE(),   -- Standardwert: Aktuelles Datum

    -- Table Constraint: Schueler muessen mindestens 6 Jahre alt sein
    CONSTRAINT CHK_Schueler_Alter CHECK ([Alter] >= 6)
);
GO

-- Tabelle: Kurse
CREATE TABLE Schule.Kurse (
    KursID INT PRIMARY KEY,
    Titel VARCHAR(50) NOT NULL UNIQUE,        -- Eindeutiger Titel, darf nicht doppelt sein
    Gebuehr DECIMAL(6,2) DEFAULT 0.00         -- Exakte Festkommazahl, z.B. 129.50 €
);
GO

-- Tabelle: Anmeldungen (Koppeltabelle fuer M:N-Beziehung)
CREATE TABLE Schule.Anmeldungen (
    SchuelerID INT NOT NULL,
    KursID INT NOT NULL,
    Note TINYINT,

    -- Zusammengesetzter Primärschlüssel
    CONSTRAINT PK_Anmeldungen PRIMARY KEY (SchuelerID, KursID),

    -- Fremdschluessel-Verknuepfungen (Referenzielle Integritaet)
    CONSTRAINT FK_Anmeldungen_Schueler FOREIGN KEY (SchuelerID) 
        REFERENCES Schule.Schueler(SchuelerID) ON DELETE CASCADE,
        
    CONSTRAINT FK_Anmeldungen_Kurse FOREIGN KEY (KursID) 
        REFERENCES Schule.Kurse(KursID) ON DELETE NO ACTION,

    -- Validierungs-Check fuer Schulnoten (1 bis 6)
    CONSTRAINT CHK_Anmeldungen_Note CHECK (Note BETWEEN 1 AND 6)
);
GO

-- 3. STRUKTUR AENDERN (ALTER TABLE)
-- Wir fuegen nachtraeglich eine Spalte fuer E-Mail-Adressen in Schueler hinzu
ALTER TABLE Schule.Schueler
ADD Email VARCHAR(150);
GO

-- 4. VERIFIKATION
-- Wir lassen uns die erstellten Objekte anzeigen
SELECT 
    t.name AS Tabelle,
    s.name AS SchemaName,
    c.name AS Spalte,
    ty.name AS Datentyp,
    c.max_length AS MaxLaenge
FROM sys.tables AS t
INNER JOIN sys.schemas AS s ON t.schema_id = s.schema_id
INNER JOIN sys.columns AS c ON t.object_id = c.object_id
INNER JOIN sys.types AS ty ON c.user_type_id = ty.user_type_id
WHERE s.name = 'Schule'
ORDER BY t.name, c.column_id;
GO
