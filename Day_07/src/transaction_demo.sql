-- ============================================================================
-- Day_07: SQL Server Transaktionen & ACID-Prinzip Demo
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- Setup Demotabelle für Bankkonten (Klassisches ACID-Beispiel)
IF OBJECT_ID('dbo.BankKonten', 'U') IS NOT NULL DROP TABLE dbo.BankKonten;
GO

CREATE TABLE dbo.BankKonten (
    KontoID INT NOT NULL PRIMARY KEY,
    Inhaber NVARCHAR(50) NOT NULL,
    Saldo DECIMAL(10,2) NOT NULL CHECK (Saldo >= 0.00) -- Verhindert Überziehung (Konsistenz)
);
GO

-- Testdaten einflechten
INSERT INTO dbo.BankKonten (KontoID, Inhaber, Saldo)
VALUES 
(1, 'Tobias Boyke', 1000.00),
(2, 'Max Mustermann', 500.00);
GO

-- 1. EINFÜHRUNG: Erfolgreiche Transaktion (Geldüberweisung)
BEGIN TRANSACTION; -- Startet die Transaktion

BEGIN TRY
    -- Schritt 1: Geld abheben bei Tobias
    UPDATE dbo.BankKonten
    SET Saldo = Saldo - 200.00
    WHERE KontoID = 1;

    -- Schritt 2: Geld einzahlen bei Max
    UPDATE dbo.BankKonten
    SET Saldo = Saldo + 200.00
    WHERE KontoID = 2;

    -- Wenn alles klappt: Commit (Änderungen dauerhaft speichern)
    COMMIT TRANSACTION;
    PRINT 'Transaktion erfolgreich gebucht und committed.';
END TRY
BEGIN CATCH
    -- Falls ein Fehler auftritt (z.B. Check Constraint verletzt): Rollback
    ROLLBACK TRANSACTION;
    PRINT 'Fehler aufgetreten. Transaktion wurde komplett zurückgerollt.';
    PRINT ERROR_MESSAGE();
END CATCH;
GO

-- Prüfen: Beide Konten wurden korrekt geändert.
SELECT * FROM dbo.BankKonten;
GO

-- 2. DEMO: Fehlgeschlagene Transaktion (Atomarität / Atomicity Schutz)
BEGIN TRANSACTION;

BEGIN TRY
    -- Schritt 1: Geld abheben bei Tobias (900 € - Saldo ist aktuell 800 €)
    -- Das würde den Saldo auf -100 € setzen -> Verstoß gegen den CHECK Constraint!
    UPDATE dbo.BankKonten
    SET Saldo = Saldo - 900.00
    WHERE KontoID = 1;

    -- Schritt 2: Geld einzahlen bei Max (Sollte nie ausgeführt werden bzw. zurückgerollt werden)
    UPDATE dbo.BankKonten
    SET Saldo = Saldo + 900.00
    WHERE KontoID = 2;

    COMMIT TRANSACTION;
    PRINT 'Transaktion erfolgreich.';
END TRY
BEGIN CATCH
    -- Der SQL Server wirft einen Fehler beim ersten Update.
    -- Wir rollen alles zurück. Keine Halbbuchungen!
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    PRINT 'Transaktion abgebrochen und Rollback durchgeführt!';
    PRINT 'Grund: ' + ERROR_MESSAGE();
END CATCH;
GO

-- Prüfen: Konten haben immer noch den Stand nach der ersten erfolgreichen Buchung.
-- Tobias: 800.00 €, Max: 700.00 € (Keine Teilbuchung hat überlebt).
SELECT * FROM dbo.BankKonten;
GO
