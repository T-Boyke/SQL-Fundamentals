-- ============================================================================
-- Day_08: Probeklausur - Teil 4 Musterlösung
-- Datum: 12.08.2026 | Dozent: Tom Selig | Autor: Tobias Boyke
-- Dialekt: T-SQL (Microsoft SQL Server)
-- ============================================================================

USE tempdb;
GO

-- 1. UMGEBUNG BEREINIGEN (Falls Tabellen bereits existieren)
IF OBJECT_ID('dbo.Kunde', 'U') IS NOT NULL DROP TABLE dbo.Kunde;
IF OBJECT_ID('dbo.Ansprechpartner', 'U') IS NOT NULL DROP TABLE dbo.Ansprechpartner;
GO

-- ============================================================================
-- TEIL 4 - AUFGABE 1: DDL (Tabellenerstellung Tabelle Kunde & Ansprechpartner)
-- ============================================================================
-- Anforderung:
-- - Erstellen Sie das SQL-Statement, um die Tabelle Kunde anzulegen.
-- - Sinnvolle Datentypen wählen (NULL/NOT NULL optional).
-- - Spalte KundenNr soll automatisch durch die Datenbank befüllt werden,
--   beginnend bei KundenNr 100 mit Schrittweite 1.
-- - AP_ID als Foreign Key zu Ansprechpartner(ID).
-- - Alle notwendigen Schlüssel (PK, FK) definieren.

-- Zunächst erstellen wir die Referenztabelle Ansprechpartner:
CREATE TABLE dbo.Ansprechpartner (
    ID INT CONSTRAINT PK_Ansprechpartner PRIMARY KEY,
    Vorname NVARCHAR(50) NULL,
    Nachname NVARCHAR(50) NULL,
    Telefon VARCHAR(30) NULL,
    Email VARCHAR(100) NULL
);
GO

-- Erstellung der Zieltabelle Kunde gemäß Aufgabenstellung:
CREATE TABLE dbo.Kunde (
    KundenNr INT IDENTITY(100, 1) CONSTRAINT PK_Kunde PRIMARY KEY,
    Vorname NVARCHAR(50) NULL,
    Nachname NVARCHAR(50) NULL,
    Telefon VARCHAR(30) NULL,
    Geburtsdatum DATE NULL,
    AP_ID INT CONSTRAINT FK_Kunde_Ansprechpartner REFERENCES dbo.Ansprechpartner(ID)
);
GO

-- ============================================================================
-- TEIL 4 - VORBEREITUNG FÜR DML TESTS
-- ============================================================================
-- Einfügen von Test-Ansprechpartnern (ID 42 sowie IDs im Bereich 1..99)
INSERT INTO dbo.Ansprechpartner (ID, Vorname, Nachname, Telefon, Email)
VALUES
    (42, 'Erika', 'Mustermann', '030/1234567', 'erika.m@example.com'),
    (10, 'Hans', 'Peter', '040/987654', 'hans.p@example.com'),
    (150, 'Klaus', 'Dieter', '089/5554433', 'klaus.d@example.com');
GO

-- ============================================================================
-- TEIL 4 - AUFGABE 2: DML (INSERT Datensatz Maria Müller)
-- ============================================================================
-- Anforderung:
-- Schreiben Sie ein SQL-Statement, um in die Tabelle "Kunde" einen Datensatz
-- für den Kunden Maria Müller einzufügen. Der zugeordnete Ansprechpartner von
-- Frau Müller hat die ID 42. Weitere Informationen liegen nicht vor.

INSERT INTO dbo.Kunde (Vorname, Nachname, AP_ID)
VALUES ('Maria', 'Müller', 42);
GO

-- Kontrollabfrage nach Insert (KundenNr startet automatisch bei 100)
SELECT
    KundenNr,
    Vorname,
    Nachname,
    Telefon,
    Geburtsdatum,
    AP_ID
FROM dbo.Kunde;
GO

-- ============================================================================
-- TEIL 4 - AUFGABE 3: DML (UPDATE Telefon und Geburtsdatum)
-- ============================================================================
-- Anforderung:
-- Schreiben Sie ein SQL-Statement, mit dem Sie bei Frau Müller die Telefon-Nr.
-- 0123/987654-321 und das Geburtsdatum 1. Februar 1975 ergänzen.
-- Frau Müller hat die KundenNr 1234.

UPDATE dbo.Kunde
SET
    Telefon = '0123/987654-321',
    Geburtsdatum = '1975-02-01'
WHERE KundenNr = 1234;
GO

-- Test-Update auch auf den eben angelegten Datensatz (KundenNr 100) zur Verifikation:
UPDATE dbo.Kunde
SET
    Telefon = '0123/987654-321',
    Geburtsdatum = '1975-02-01'
WHERE Nachname = 'Müller' AND Vorname = 'Maria';
GO

-- Kontrollabfrage nach Update
SELECT
    KundenNr,
    Vorname,
    Nachname,
    Telefon,
    Geburtsdatum,
    AP_ID
FROM dbo.Kunde;
GO

-- ============================================================================
-- TEIL 4 - AUFGABE 4: DML (DELETE Ansprechpartner ID 1 bis 99)
-- ============================================================================
-- Anforderung:
-- Schreiben Sie ein SQL-Statement, mit dem Sie alle Ansprechpartner löschen
-- können, die eine ID im Bereich von 1 bis 99 haben.

-- Zum Testen entfernen wir vorübergehend die FK-Referenz auf ID 10
DELETE FROM dbo.Ansprechpartner
WHERE ID BETWEEN 1 AND 99 AND ID <> 42;
GO

-- Das exakte Klausur-Statement lautet:
-- DELETE FROM dbo.Ansprechpartner WHERE ID BETWEEN 1 AND 99;

-- Kontrollabfrage nach Delete
SELECT
    ID,
    Vorname,
    Nachname,
    Telefon,
    Email
FROM dbo.Ansprechpartner;
GO
