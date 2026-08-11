-- ============================================================================
-- Day_07: TRY...CATCH & Transaktionen in tempdb (Lokale temporäre Tabellen)
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- 1. EINFÜHRUNG: Arbeiten mit lokalen temporären Tabellen (#Table) in tempdb
-- Temporäre Tabellen werden in tempdb erzeugt.
-- Wir fügen einen CHECK Constraint hinzu, um Validierungsfehler zu provozieren.
IF OBJECT_ID('tempdb..#TempKunden') IS NOT NULL DROP TABLE #TempKunden;
GO

CREATE TABLE #TempKunden (
    KundenID INT PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    [Alter] INT CHECK ([Alter] >= 18) -- Volljährige Kunden (Konsistenz-Constraint)
);
GO

-- 2. MUSTER: Robustes Transaktionshandling mit TRY...CATCH und XACT_STATE()
-- Wir versuchen zwei Kunden einzufügen. Einer verletzt den Constraint.
-- Das Safe-Rollback-Muster stellt sicher, dass keine unvollständigen Daten verbleiben.

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
    -- XACT_STATE() = 1  -> Aktiv & committbar
    -- XACT_STATE() = -1 -> Aktiv & NICHT committbar (doomed)
    -- XACT_STATE() = 0  -> Keine aktive Transaktion
    
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

-- 3. VERIFIKATION: Wurde die Atomarität (Atomicity) gewahrt?
-- Ergebnis: Die Tabelle ist leer, da die gesamte Transaktion zurückgerollt wurde.
SELECT * FROM #TempKunden;
GO

-- 4. Bereinigung der temporären Tabelle
IF OBJECT_ID('tempdb..#TempKunden') IS NOT NULL DROP TABLE #TempKunden;
GO
