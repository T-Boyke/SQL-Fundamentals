-- ============================================================================
-- Day_08: Probeklausur - Teil C Musterlösung
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- 1. UMGEBUNG BEREINIGEN (Falls vorhanden)
IF OBJECT_ID('RentACar.Buchung', 'U') IS NOT NULL DROP TABLE RentACar.Buchung;
IF OBJECT_ID('RentACar.Kunde', 'U') IS NOT NULL DROP TABLE RentACar.Kunde;
IF OBJECT_ID('RentACar.Fahrzeug', 'U') IS NOT NULL DROP TABLE RentACar.Fahrzeug;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'RentACar')
BEGIN
    DROP SCHEMA RentACar;
END
GO

-- Schema erstellen
CREATE SCHEMA RentACar;
GO

-- ============================================================================
-- AUFGABE 1: DDL (Tabellen und Constraints)
-- ============================================================================

-- Tabelle: Kunde
CREATE TABLE RentACar.Kunde (
    KundenNr INT IDENTITY(1, 1) CONSTRAINT PK_Kunde PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    EMail VARCHAR(150) NOT NULL UNIQUE
);
GO

-- Tabelle: Fahrzeug
CREATE TABLE RentACar.Fahrzeug (
    Kennzeichen VARCHAR(20) CONSTRAINT PK_Fahrzeug PRIMARY KEY,
    Typ NVARCHAR(50) NOT NULL,
    Tagespreis DECIMAL(6, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT CHK_Fahrzeug_Tagespreis CHECK (Tagespreis >= 0.00)
);
GO

-- Tabelle: Buchung (Koppeltabelle)
CREATE TABLE RentACar.Buchung (
    KundenNr INT NOT NULL,
    Kennzeichen VARCHAR(20) NOT NULL,
    Startdatum DATE NOT NULL,
    Enddatum DATE NOT NULL,

    -- Composite Primary Key
    CONSTRAINT PK_Buchung PRIMARY KEY (KundenNr, Kennzeichen, Startdatum),

    -- Foreign Keys
    CONSTRAINT FK_Buchung_Kunde FOREIGN KEY (KundenNr)
        REFERENCES RentACar.Kunde (KundenNr) ON DELETE CASCADE,
    CONSTRAINT FK_Buchung_Fahrzeug FOREIGN KEY (Kennzeichen)
        REFERENCES RentACar.Fahrzeug (Kennzeichen) ON DELETE CASCADE,

    -- Logical Constraint (Enddatum darf nicht vor Startdatum liegen)
    CONSTRAINT CHK_Buchung_Daten CHECK (Enddatum >= Startdatum)
);
GO

-- ============================================================================
-- AUFGABE 2: DML (Datenbefüllung)
-- ============================================================================

-- Kunden einpflegen (IDENTITY wird automatisch vergeben)
INSERT INTO RentACar.Kunde (Name, EMail)
VALUES
    ('Tobias Boyke', 'tobias.boyke@example.de'),
    ('Max Muster', 'max.muster@example.de');

-- Fahrzeuge einpflegen
INSERT INTO RentACar.Fahrzeug (Kennzeichen, Typ, Tagespreis)
VALUES
    ('HH-TB-2026', 'VW Golf 8', 49.99),
    ('B-MM-8888', 'Audi A4 Avant', 79.50);

-- Buchungen einpflegen
INSERT INTO RentACar.Buchung (KundenNr, Kennzeichen, Startdatum, Enddatum)
VALUES
    (1, 'HH-TB-2026', '2026-08-12', '2026-08-15'),
    (2, 'B-MM-8888', '2026-08-14', '2026-08-16');
GO

-- Kontrollabfrage
SELECT
    k.Name AS Kunde,
    f.Typ AS Fahrzeug,
    f.Kennzeichen,
    b.Startdatum,
    b.Enddatum,
    DATEDIFF(day, b.Startdatum, b.Enddatum) AS Tage,
    DATEDIFF(day, b.Startdatum, b.Enddatum) * f.Tagespreis AS Gesamtpreis
FROM RentACar.Buchung AS b
INNER JOIN RentACar.Kunde AS k ON b.KundenNr = k.KundenNr
INNER JOIN RentACar.Fahrzeug AS f ON b.Kennzeichen = f.Kennzeichen;
GO

-- ============================================================================
-- AUFGABE 3: Transaktionshandling mit TRY...CATCH & XACT_STATE()
-- ============================================================================

-- Wir simulieren eine Buchung. Falls eine logische Verletzung vorliegt,
-- wird die Transaktion abgebrochen.
BEGIN TRY
    BEGIN TRANSACTION;

    PRINT 'Starte Buchungstransaktion...';

    -- Parameter definieren
    DECLARE @KundenNr INT = 1;
    DECLARE @Kennzeichen VARCHAR(20) = 'B-MM-8888';
    DECLARE @Startdatum DATE = '2026-08-20';
    DECLARE @Enddatum DATE = '2026-08-18'; -- FEHLER: Enddatum vor Startdatum!

    -- Validierungs-Check vor dem Insert (oder durch Check-Constraint ausgelöst)
    IF @Enddatum < @Startdatum
    BEGIN
        -- Eigenen Fehler werfen
        THROW 50001, 'Fehler: Das Enddatum darf nicht vor dem Startdatum liegen.', 1;
    END

    -- Insert durchführen
    INSERT INTO RentACar.Buchung (KundenNr, Kennzeichen, Startdatum, Enddatum)
    VALUES (@KundenNr, @Kennzeichen, @Startdatum, @Enddatum);

    COMMIT TRANSACTION;
    PRINT 'Buchung erfolgreich eingetragen.';
END TRY
BEGIN CATCH
    PRINT '==========================================================';
    PRINT 'BUCHUNG FEHLGESCHLAGEN!';
    PRINT 'Fehlermeldung: ' + ERROR_MESSAGE();
    PRINT '==========================================================';

    -- Überprüfung und Rollback
    IF (XACT_STATE() = 1 OR XACT_STATE() = -1)
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Rollback der Transaktion erfolgreich durchgeführt. Daten konsistent.';
    END
END CATCH;
GO
