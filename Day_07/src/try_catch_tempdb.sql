-- ============================================================================
-- Day_07: TRY...CATCH & Transaktionen in tempdb
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- ============================================================================
-- TEIL 1: Einfaches Transaktionsbeispiel
-- ============================================================================

-- Bereinigung alter Demotabellen
IF OBJECT_ID('dbo.transtest', 'U') IS NOT NULL DROP TABLE dbo.transtest;
GO

-- Erstellung der physikalischen Demotabelle in tempdb
CREATE TABLE dbo.transtest (
    wert TINYINT
);
GO

-- Start der Transaktion
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO dbo.transtest (wert) VALUES (1);
    INSERT INTO dbo.transtest (wert) VALUES (2);

    -- HINWEIS: Um einen Konvertierungsfehler zu erzwingen, der in den CATCH-Block
    -- springt und ein Rollback auslöst, entferne das '--' vor der folgenden Zeile:
    -- INSERT INTO dbo.transtest (wert) VALUES ('a'); 

    INSERT INTO dbo.transtest (wert) VALUES (3);
    PRINT 'Erfolgreich';

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    PRINT 'FEHLER';
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
END CATCH;
GO

-- Verifikation des Tabelleninhalts
SELECT * FROM dbo.transtest;
GO

-- Bereinigung
TRUNCATE TABLE dbo.transtest;
DROP TABLE dbo.transtest;
GO

-- ============================================================================
-- TEIL 2: Fortgeschrittenes Beispiel (Temporäre Tabelle & XACT_STATE)
-- ============================================================================

-- Bereinigung
IF OBJECT_ID('tempdb..#TempKunden') IS NOT NULL DROP TABLE #TempKunden;
GO

CREATE TABLE #TempKunden (
    KundenID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    [Alter] INT CHECK ([Alter] >= 18) -- Volljährige Kunden (Konsistenz-Constraint)
);
GO

BEGIN TRY
    BEGIN TRANSACTION;

    PRINT 'Starte Transaktion...';
    PRINT 'Aktueller XACT_STATE: ' + CAST(XACT_STATE() AS VARCHAR(5));

    -- Kunde 1: Gültiger Datensatz
    INSERT INTO #TempKunden (KundenID, Name, [Alter])
    VALUES (1, 'Tobias Boyke', 25);
    PRINT 'Kunde 1 eingefügt.';

    -- Kunde 2: Ungültiger Datensatz (verletzt Check-Constraint: Alter < 18)
    -- Dies wirft eine Exception und springt sofort in den CATCH-Block.
    INSERT INTO #TempKunden (KundenID, Name, [Alter])
    VALUES (2, 'Maxi Musterkind', 12); 
    PRINT 'Kunde 2 eingefügt. (Sollte nicht erreicht werden)';

    -- Wenn alles erfolgreich war: Commit
    COMMIT TRANSACTION;
    PRINT 'Transaktion erfolgreich committed!';
END TRY
BEGIN CATCH
    PRINT '==========================================================';
    PRINT 'FEHLER AUFGETRETEN!';
    PRINT 'Fehlernummer: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Fehlermeldung: ' + ERROR_MESSAGE();
    PRINT 'Fehlerschwere (Severity): ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT '==========================================================';

    -- Überprüfung des Transaktionsstatus mittels XACT_STATE()
    PRINT 'Status der Transaktion im CATCH-Block (XACT_STATE): ' + CAST(XACT_STATE() AS VARCHAR(5));

    IF (XACT_STATE() = 1 OR XACT_STATE() = -1)
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Rollback der Transaktion erfolgreich durchgeführt.';
    END
    ELSE
    BEGIN
        PRINT 'Kein Rollback nötig, da keine aktive Transaktion existiert.';
    END
END CATCH;
GO

-- Verifikation
SELECT * FROM #TempKunden;
GO

-- Bereinigung
IF OBJECT_ID('tempdb..#TempKunden') IS NOT NULL DROP TABLE #TempKunden;
GO