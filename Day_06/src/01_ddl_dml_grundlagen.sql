-- ============================================================================
-- Day_06: 01_ddl_dml_grundlagen.sql
-- Thema: Weitere Übungsaufgaben zu DDL & DML (Datenbank, Tabellen, Data Insert)
-- Datum: 10.08.2026 | Dozent: Tom S. | Autor: Tobias Boyke
-- Dialekt: T-SQL (Microsoft SQL Server)
-- ============================================================================

USE tempdb;
GO

-- 1. UMGEBUNG BEREINIGEN
IF OBJECT_ID('dbo.Abteilung', 'U') IS NOT NULL DROP TABLE dbo.Abteilung;
IF OBJECT_ID('dbo.Mitarbeiter', 'U') IS NOT NULL DROP TABLE dbo.Mitarbeiter;
GO

-- ============================================================================
-- TEIL 1: DDL (DATA DEFINITION LANGUAGE)
-- Erstellung von Tabellen mit Primärschlüssel, Fremdschlüssel & Constraints
-- ============================================================================

-- Tabelle 1: Abteilung (Elterntabelle)
CREATE TABLE dbo.Abteilung (
    AbteilungID INT IDENTITY(1, 1) CONSTRAINT PK_Abteilung PRIMARY KEY,
    AbteilungsName NVARCHAR(50) NOT NULL CONSTRAINT UQ_AbteilungsName UNIQUE,
    Standort NVARCHAR(50) NOT NULL DEFAULT 'Hauptsitz'
);
GO

-- Tabelle 2: Mitarbeiter (Kindtabelle mit FK)
CREATE TABLE dbo.Mitarbeiter (
    MitarbeiterID INT IDENTITY(1000, 1) CONSTRAINT PK_Mitarbeiter PRIMARY KEY,
    Vorname NVARCHAR(50) NOT NULL,
    Nachname NVARCHAR(50) NOT NULL,
    Email VARCHAR(100) NOT NULL CONSTRAINT UQ_Mitarbeiter_Email UNIQUE,
    Gehalt DECIMAL(10, 2) NOT NULL CONSTRAINT CHK_Mitarbeiter_Gehalt CHECK (Gehalt >= 0.00),
    Eintrittsdatum DATE NOT NULL DEFAULT GETDATE(),
    AbteilungID INT NULL CONSTRAINT FK_Mitarbeiter_Abteilung REFERENCES dbo.Abteilung(AbteilungID) ON DELETE SET NULL
);
GO

-- ============================================================================
-- TEIL 2: DML (DATA MANIPULATION LANGUAGE)
-- Einfügen von Daten in Tabellen (Single-Row, Multi-Row, INSERT INTO ... SELECT)
-- ============================================================================

-- Einfügen in Abteilung (Multi-Row Insert)
INSERT INTO dbo.Abteilung (AbteilungsName, Standort)
VALUES
    ('IT-Entwicklung', 'Hamburg'),
    ('Personalwesen', 'Berlin'),
    ('Vertrieb', 'München'),
    ('Marketing', 'Hamburg');
GO

-- Einfügen in Mitarbeiter mit expliziter Spaltenliste
INSERT INTO dbo.Mitarbeiter (Vorname, Nachname, Email, Gehalt, Eintrittsdatum, AbteilungID)
VALUES
    ('Tobias', 'Boyke', 'tobias.boyke@example.de', 5500.00, '2026-08-01', 1),
    ('Max', 'Mustermann', 'max.mustermann@example.de', 4200.00, '2026-08-05', 1),
    ('Erika', 'Musterfrau', 'erika.musterfrau@example.de', 4800.00, '2026-07-15', 2),
    ('Hans', 'Peter', 'hans.peter@example.de', 3900.00, '2026-08-10', 3);
GO

-- ============================================================================
-- TEIL 3: VALIDIERUNG & DML-ABFRAGEN
-- ============================================================================

SELECT
    a.AbteilungsName,
    a.Standort,
    m.MitarbeiterID,
    m.Vorname,
    m.Nachname,
    m.Gehalt,
    m.Eintrittsdatum
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Abteilung AS a ON m.AbteilungID = a.AbteilungID;
GO
