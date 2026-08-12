-- ============================================================================
-- Day_06: 03_uebungsaufgaben_ddl_dml.sql
-- Thema: 10. Aufgabe - Umfassende Übungsaufgaben zu DDL und DML
-- Datum: 10.08.2026 | Dozent: Tom S. | Autor: Tobias Boyke
-- Dialekt: T-SQL (Microsoft SQL Server)
-- ============================================================================

USE tempdb;
GO

-- 1. BEREINIGUNG SÄMTLICHER ÜBUNGS-TABELLEN
IF OBJECT_ID('dbo.ProjektZuweisung', 'U') IS NOT NULL DROP TABLE dbo.ProjektZuweisung;
IF OBJECT_ID('dbo.Projekt', 'U') IS NOT NULL DROP TABLE dbo.Projekt;
IF OBJECT_ID('dbo.KundenArchiv', 'U') IS NOT NULL DROP TABLE dbo.KundenArchiv;
IF OBJECT_ID('dbo.KundenStamm', 'U') IS NOT NULL DROP TABLE dbo.KundenStamm;
GO

-- ============================================================================
-- ÜBUNG 1: DDL - ANLEGEN EINES SCHEMAS MIT INLINE- UND TABELLEN-CONSTRAINTS
-- ============================================================================

-- Erstellung der Tabelle KundenStamm
CREATE TABLE dbo.KundenStamm (
    KundenID INT IDENTITY(100, 1) CONSTRAINT PK_KundenStamm PRIMARY KEY,
    FirmenName NVARCHAR(100) NOT NULL,
    KontaktEmail VARCHAR(120) NOT NULL CONSTRAINT UQ_KundenStamm_Email UNIQUE,
    StatusFlag VARCHAR(10) NOT NULL DEFAULT 'Aktiv' CONSTRAINT CHK_KundenStamm_Status CHECK (StatusFlag IN ('Aktiv', 'Inaktiv', 'Gesperrt')),
    ErstelltAm DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- ============================================================================
-- ÜBUNG 2: DML - DATENBEFÜLLUNG (INSERT INTO ... VALUES)
-- ============================================================================

INSERT INTO dbo.KundenStamm (FirmenName, KontaktEmail, StatusFlag)
VALUES
    ('Alpha Consulting GmbH', 'info@alpha-consulting.de', 'Aktiv'),
    ('Beta Logistics AG', 'contact@beta-logistics.com', 'Aktiv'),
    ('Gamma Tech Systems', 'support@gamma-tech.de', 'Inaktiv');
GO

-- ============================================================================
-- ÜBUNG 3: DDL - SCHEMA-ANPASSUNG MIT ALTER TABLE (SPALTE HINZUFÜGEN & LÖSCHEN)
-- ============================================================================

-- 1. Spalte "Telefon" hinzufügen
ALTER TABLE dbo.KundenStamm ADD Telefon VARCHAR(30) NULL;
GO

-- 2. Spalte "StatusFlag" ändern (Datentyp vergrößern)
ALTER TABLE dbo.KundenStamm ALTER COLUMN StatusFlag VARCHAR(20) NOT NULL;
GO

-- 3. Überflüssige Testspalte hinzufügen und direkt wieder mit DROP COLUMN löschen
ALTER TABLE dbo.KundenStamm ADD TestNotiz NVARCHAR(100) NULL;
GO

ALTER TABLE dbo.KundenStamm DROP COLUMN TestNotiz;
GO

-- ============================================================================
-- ÜBUNG 4: DML - MIGRATION PER INSERT INTO ... SELECT
-- ============================================================================

-- DDL: Erstellung einer Archiv-Tabelle
CREATE TABLE dbo.KundenArchiv (
    ArchivID INT IDENTITY(1, 1) CONSTRAINT PK_KundenArchiv PRIMARY KEY,
    OriginalKundenID INT NOT NULL,
    FirmenName NVARCHAR(100) NOT NULL,
    KontaktEmail VARCHAR(120) NOT NULL,
    ArchiviertAm DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

-- DML: Kopieren aller inaktiven Kunden in die Archiv-Tabelle
INSERT INTO dbo.KundenArchiv (OriginalKundenID, FirmenName, KontaktEmail)
SELECT
    KundenID,
    FirmenName,
    KontaktEmail
FROM dbo.KundenStamm
WHERE StatusFlag = 'Inaktiv';
GO

-- DML: Inaktive Kunden aus dem Hauptstamm entfernen
DELETE FROM dbo.KundenStamm
WHERE StatusFlag = 'Inaktiv';
GO

-- ============================================================================
-- ÜBUNG 5: BEZIEHUNGSTABELLE (N:M) ANLEGEN & MIT DML BEFÜLLEN
-- ============================================================================

CREATE TABLE dbo.Projekt (
    ProjektID INT IDENTITY(1, 1) CONSTRAINT PK_Projekt PRIMARY KEY,
    ProjektName NVARCHAR(100) NOT NULL,
    Budget DECIMAL(12, 2) NOT NULL CONSTRAINT CHK_Projekt_Budget CHECK (Budget > 0)
);
GO

CREATE TABLE dbo.ProjektZuweisung (
    KundenID INT NOT NULL CONSTRAINT FK_Zuweisung_Kunde REFERENCES dbo.KundenStamm(KundenID),
    ProjektID INT NOT NULL CONSTRAINT FK_Zuweisung_Projekt REFERENCES dbo.Projekt(ProjektID),
    ZuweisungsDatum DATE NOT NULL DEFAULT GETDATE(),
    Rolle NVARCHAR(50) NOT NULL DEFAULT 'Auftraggeber',
    CONSTRAINT PK_ProjektZuweisung PRIMARY KEY (KundenID, ProjektID)
);
GO

-- Befüllung
INSERT INTO dbo.Projekt (ProjektName, Budget)
VALUES
    ('Cloud Migration 2026', 150000.00),
    ('ERP Implementation', 350000.00);

INSERT INTO dbo.ProjektZuweisung (KundenID, ProjektID, Rolle)
VALUES
    (100, 1, 'Hauptauftraggeber'),
    (101, 2, 'Co-Sponsor');
GO

-- ============================================================================
-- VALIDIERUNG DER ÜBUNGSERGEBNISSE
-- ============================================================================

SELECT * FROM dbo.KundenStamm;
SELECT * FROM dbo.KundenArchiv;

SELECT
    k.FirmenName,
    p.ProjektName,
    p.Budget,
    pz.Rolle,
    pz.ZuweisungsDatum
FROM dbo.ProjektZuweisung AS pz
INNER JOIN dbo.KundenStamm AS k ON pz.KundenID = k.KundenID
INNER JOIN dbo.Projekt AS p ON pz.ProjektID = p.ProjektID;
GO
