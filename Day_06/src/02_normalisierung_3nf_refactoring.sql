-- ============================================================================
-- Day_06: 02_normalisierung_3nf_refactoring.sql
-- Thema: Umwandlung bestehender Tabellen in die 3. Normalform (3NF Refactoring)
--        - Erstellung neuer Tabellen (DDL)
--        - Datenmigration (DML)
--        - Änderung bestehender Tabellen & Löschen von Spalten (ALTER TABLE / DROP COLUMN)
-- Datum: 10.08.2026 | Dozent: Tom S. | Autor: Tobias Boyke
-- Dialekt: T-SQL (Microsoft SQL Server)
-- ============================================================================

USE tempdb;
GO

-- 1. BEREINIGUNG ALTER TEST-TABELLEN
IF OBJECT_ID('dbo.Bestellposition_3NF', 'U') IS NOT NULL DROP TABLE dbo.Bestellposition_3NF;
IF OBJECT_ID('dbo.Bestellung_3NF', 'U') IS NOT NULL DROP TABLE dbo.Bestellung_3NF;
IF OBJECT_ID('dbo.Artikel_3NF', 'U') IS NOT NULL DROP TABLE dbo.Artikel_3NF;
IF OBJECT_ID('dbo.Kunde_3NF', 'U') IS NOT NULL DROP TABLE dbo.Kunde_3NF;
IF OBJECT_ID('dbo.BestellErfassung', 'U') IS NOT NULL DROP TABLE dbo.BestellErfassung;
GO

-- ============================================================================
-- SCHRITT 1: AUSGANGSLAGE - UNNORMALISIERTE ALT-TABELLE (1NF/2NF-VERLETZUNG)
-- ============================================================================

CREATE TABLE dbo.BestellErfassung (
    ErfassungsID INT IDENTITY(1, 1) CONSTRAINT PK_BestellErfassung PRIMARY KEY,
    BestellNr INT NOT NULL,
    BestellDatum DATE NOT NULL,
    KundenNr INT NOT NULL,
    KundenName NVARCHAR(100) NOT NULL,
    KundenOrt NVARCHAR(50) NOT NULL,
    ArtikelID INT NOT NULL,
    ArtikelBezeichnung NVARCHAR(100) NOT NULL,
    Einzelpreis DECIMAL(10, 2) NOT NULL,
    Menge INT NOT NULL
);
GO

-- Befüllen der unnormalisierten Alttabelle mit Testdaten (DML)
INSERT INTO dbo.BestellErfassung
    (BestellNr, BestellDatum, KundenNr, KundenName, KundenOrt, ArtikelID, ArtikelBezeichnung, Einzelpreis, Menge)
VALUES
    (5001, '2026-08-01', 101, 'Hans Müller', 'Hamburg', 201, 'Laptop Pro 15', 1200.00, 1),
    (5001, '2026-08-01', 101, 'Hans Müller', 'Hamburg', 202, 'Maus Wireless', 25.50, 2),
    (5002, '2026-08-02', 102, 'Erika Muster', 'Berlin', 203, 'Tastatur Ergonomisch', 79.90, 1),
    (5003, '2026-08-03', 101, 'Hans Müller', 'Hamburg', 202, 'Maus Wireless', 25.50, 5);
GO

-- ============================================================================
-- SCHRITT 2: DDL - ERSTELLUNG DER 3NF-ZIELTABELLEN
-- ============================================================================

-- 1. Ziel-Tabelle: Kunde_3NF
CREATE TABLE dbo.Kunde_3NF (
    KundenNr INT CONSTRAINT PK_Kunde_3NF PRIMARY KEY,
    KundenName NVARCHAR(100) NOT NULL,
    KundenOrt NVARCHAR(50) NOT NULL
);
GO

-- 2. Ziel-Tabelle: Artikel_3NF
CREATE TABLE dbo.Artikel_3NF (
    ArtikelID INT CONSTRAINT PK_Artikel_3NF PRIMARY KEY,
    ArtikelBezeichnung NVARCHAR(100) NOT NULL,
    Einzelpreis DECIMAL(10, 2) NOT NULL
);
GO

-- 3. Ziel-Tabelle: Bestellung_3NF
CREATE TABLE dbo.Bestellung_3NF (
    BestellNr INT CONSTRAINT PK_Bestellung_3NF PRIMARY KEY,
    BestellDatum DATE NOT NULL,
    KundenNr INT NOT NULL CONSTRAINT FK_Bestellung_Kunde REFERENCES dbo.Kunde_3NF(KundenNr)
);
GO

-- 4. Ziel-Tabelle: Bestellposition_3NF (Koppeltabelle)
CREATE TABLE dbo.Bestellposition_3NF (
    BestellNr INT NOT NULL CONSTRAINT FK_Position_Bestellung REFERENCES dbo.Bestellung_3NF(BestellNr),
    ArtikelID INT NOT NULL CONSTRAINT FK_Position_Artikel REFERENCES dbo.Artikel_3NF(ArtikelID),
    Menge INT NOT NULL CONSTRAINT CHK_Menge_Pos CHECK (Menge > 0),
    CONSTRAINT PK_Bestellposition_3NF PRIMARY KEY (BestellNr, ArtikelID)
);
GO

-- ============================================================================
-- SCHRITT 3: DML - MIGRATION DER DATEN IN DAS 3NF-SCHEMA
-- ============================================================================

-- 1. Kunden migrieren (SELECT DISTINCT verhindert Duplikate)
INSERT INTO dbo.Kunde_3NF (KundenNr, KundenName, KundenOrt)
SELECT DISTINCT
    KundenNr,
    KundenName,
    KundenOrt
FROM dbo.BestellErfassung;
GO

-- 2. Artikel migrieren
INSERT INTO dbo.Artikel_3NF (ArtikelID, ArtikelBezeichnung, Einzelpreis)
SELECT DISTINCT
    ArtikelID,
    ArtikelBezeichnung,
    Einzelpreis
FROM dbo.BestellErfassung;
GO

-- 3. Bestellungen migrieren
INSERT INTO dbo.Bestellung_3NF (BestellNr, BestellDatum, KundenNr)
SELECT DISTINCT
    BestellNr,
    BestellDatum,
    KundenNr
FROM dbo.BestellErfassung;
GO

-- 4. Bestellpositionen migrieren
INSERT INTO dbo.Bestellposition_3NF (BestellNr, ArtikelID, Menge)
SELECT
    BestellNr,
    ArtikelID,
    Menge
FROM dbo.BestellErfassung;
GO

-- ============================================================================
-- SCHRITT 4: DDL - ÄNDERUNG BESTEHENDER TABELLEN & LÖSCHEN REDUNDANTER SPALTEN
-- (Demonstration von ALTER TABLE & DROP COLUMN an der Alttabelle)
-- ============================================================================

-- Angenommen, die Alttabelle soll als schlanke Schnittstellentabelle erhalten bleiben:
-- Wir löschen alle redundanten Spalten, die sich nun in 3NF-Tabellen befinden.
ALTER TABLE dbo.BestellErfassung DROP COLUMN KundenName;
ALTER TABLE dbo.BestellErfassung DROP COLUMN KundenOrt;
ALTER TABLE dbo.BestellErfassung DROP COLUMN ArtikelBezeichnung;
ALTER TABLE dbo.BestellErfassung DROP COLUMN Einzelpreis;
GO

-- Spalte hinzufügen / ändern als weiteres DDL-Beispiel:
ALTER TABLE dbo.BestellErfassung ADD StatusMessage NVARCHAR(50) NULL DEFAULT 'Migriert';
GO

-- ============================================================================
-- SCHRITT 5: VALIDIERUNG & PROBEMIGRATIONS-ABFRAGE
-- ============================================================================

-- Abfrage der neu erstellten 3NF-Struktur über JOINs
SELECT
    b.BestellNr,
    b.BestellDatum,
    k.KundenName,
    k.KundenOrt,
    a.ArtikelBezeichnung,
    bp.Menge,
    a.Einzelpreis,
    (bp.Menge * a.Einzelpreis) AS GesamtPreisPosition
FROM dbo.Bestellung_3NF AS b
INNER JOIN dbo.Kunde_3NF AS k ON b.KundenNr = k.KundenNr
INNER JOIN dbo.Bestellposition_3NF AS bp ON b.BestellNr = bp.BestellNr
INNER JOIN dbo.Artikel_3NF AS a ON bp.ArtikelID = a.ArtikelID;
GO
