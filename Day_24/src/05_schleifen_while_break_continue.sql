-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Prozedurale Programmierung
-- Datei: 05_schleifen_while_break_continue.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: Iterative Ablaufsteuerung mit WHILE, BREAK, CONTINUE & Batching
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- THEORIE: Iterative Kontrollstrukturen in T-SQL
-- ----------------------------------------------------------------------------
-- 1. Die WHILE-Schleife:
--    - T-SQL besitzt als einzigen Schleifentyp die 'WHILE'-Schleife (kein FOR/DO-WHILE).
--    - Syntax:
--      WHILE <bedingung>
--      BEGIN
--          -- Anweisungsblock
--      END;
--    - Die Bedingung wird VOR jedem Schleifendurchlauf geprüft (kopfgesteuert).
--    - Ist die Bedingung von Beginn an FALSE, wird die Schleife 0-mal ausgeführt.
--
-- 2. Schleifensteuerung:
--    - BREAK:    Beendet die innerste Schleife SOFORT und setzt die Ausführung
--                hinter dem END der Schleife fort.
--    - CONTINUE: Bricht den AKTUELLEN Durchlauf ab und springt sofort an den Anfang
--                der WHILE-Bedingung für den nächsten Durchlauf.
--
-- 3. RBAR (Row-By-Agonizing-Row) vs. Mengenorientierung (Set-Based SQL):
--    - ACHTUNG: In 95% der Fälle sind relationale Mengenoperationen (JOIN, UPDATE,
--      INSERT ... SELECT) um ein Vielfaches schneller als iterative WHILE-Schleifen!
--    - Wann sind WHILE-Schleifen trotzdem sinnvoll und Best Practice?
--      a) Batching riesiger Datenmengen (z. B. 10.000 Zeilen pro Batch löschen/archivieren,
--         um Lock Escalation und Transaktionsprotokoll-Überlauf zu verhindern).
--      b) Schrittweise Wartungsjobs, Reorganisationen oder externe API-Aufrufe.
--      c) Generierung von Testdaten oder Simulationen.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Grundlegende zählergesteuerte WHILE-Schleife
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Grundlegende zählergesteuerte WHILE-Schleife';
PRINT '======================================================================';

DECLARE @zaehler INT = 1;
DECLARE @maxDurchlaeufe INT = 5;

WHILE @zaehler <= @maxDurchlaeufe
BEGIN
    PRINT CONCAT('Schleifendurchlauf #', @zaehler, ' von ', @maxDurchlaeufe);
    
    -- WICHTIG: Manuelle Erhöhung der Zählervariable (sonst Endlosschleife!)
    SET @zaehler = @zaehler + 1;
END;

PRINT '>>> Schleife erfolgreich beendet.';
GO


-- ----------------------------------------------------------------------------
-- 2. Vorzeitiger Abbruch mit BREAK (Notbremse / Schwellenwert-Erreichung)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Vorzeitiger Abbruch mit BREAK';
PRINT '======================================================================';

DECLARE @runde INT = 1;
DECLARE @abbruchSchwelle INT = 4;

WHILE @runde <= 10
BEGIN
    PRINT CONCAT('  Verarbeite Runde: ', @runde);

    IF @runde = @abbruchSchwelle
    BEGIN
        PRINT CONCAT('  [BREAK] Abbruchschwelle (', @abbruchSchwelle, ') erreicht! Schleife wird vorzeitig beendet.');
        BREAK; -- Verlässt sofort den gesamten WHILE-Block
    END;

    SET @runde = @runde + 1;
END;

PRINT '>>> Ausführung nach dem BREAK fortgesetzt.';
GO


-- ----------------------------------------------------------------------------
-- 3. Iteration überspringen mit CONTINUE (Filtern im Schleifenzyklus)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Überspringen mit CONTINUE (Nur ungerade Zahlen verarbeiten)';
PRINT '======================================================================';

DECLARE @zahl INT = 0;

WHILE @zahl < 8
BEGIN
    SET @zahl = @zahl + 1;

    -- Gerade Zahlen überspringen
    IF @zahl % 2 = 0
    BEGIN
        PRINT CONCAT('  Zahl ', @zahl, ' ist gerade -> CONTINUE (überspringe Verarbeitung)');
        CONTINUE; -- Springt sofort an den Schleifenkopf zurück
    END;

    -- Diese Verarbeitung erfolgt NUR für ungerade Zahlen:
    PRINT CONCAT('  >>> [VERARBEITUNG] Ungerade Zahl identifiziert: ', @zahl);
END;
GO


-- ----------------------------------------------------------------------------
-- 4. Iteratives Durchlaufen einer Ergebnismenge (Cursor-Alternative mit TempTable)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. Zeilenweises Abarbeiten via WHILE & Temp-Tabelle (ProjektDB)';
PRINT '======================================================================';

-- Ziel: Wir möchten alle Projekte schrittweise durchlaufen und deren Budget auswerten
-- (Cursor-Ersatz mittels temporärer Arbeitstabelle)

-- 1. Temporäre Tabelle mit IDENTITY-Zähler anlegen und mit ProjektDB-Daten füllen
IF OBJECT_ID('tempdb..#TempProjekte') IS NOT NULL
    DROP TABLE #TempProjekte;

CREATE TABLE #TempProjekte (
    laufendeNummer INT IDENTITY(1, 1) PRIMARY KEY,
    projektId INT,
    kuerzel NVARCHAR(10),
    bezeichnung NVARCHAR(50),
    mittel DECIMAL(12, 2)
);

INSERT INTO #TempProjekte (projektId, kuerzel, bezeichnung, mittel)
SELECT id, kuerzel, bezeichnung, mittel
FROM dbo.Projekt
ORDER BY id;

-- 2. Schleifenvariablen definieren
DECLARE @zeilenIndex INT = 1;
DECLARE @gesamtZeilen INT;
DECLARE @aktKuerzel NVARCHAR(10);
DECLARE @aktName NVARCHAR(50);
DECLARE @aktBudget DECIMAL(12, 2);

SELECT @gesamtZeilen = COUNT(*) FROM #TempProjekte;

PRINT CONCAT('Starte schrittweise Verarbeitung von ', @gesamtZeilen, ' Projekten:');

-- 3. WHILE-Schleife über die Zeilen
WHILE @zeilenIndex <= @gesamtZeilen
BEGIN
    SELECT @aktKuerzel = kuerzel,
           @aktName = bezeichnung,
           @aktBudget = mittel
    FROM #TempProjekte
    WHERE laufendeNummer = @zeilenIndex;

    PRINT CONCAT('  [Projekt ', @zeilenIndex, '/', @gesamtZeilen, '] ', 
                 @aktKuerzel, ' - ', @aktName, ' | Budget: ', 
                 FORMAT(@aktBudget, 'N2', 'de-DE'), ' EUR');

    -- Nächster Schritt
    SET @zeilenIndex = @zeilenIndex + 1;
END;

-- Aufräumen
DROP TABLE #TempProjekte;
PRINT '>>> Temporäre Projekttabelle bereinigt.';
GO


-- ----------------------------------------------------------------------------
-- 5. Best Practice: Batch-Verarbeitung zur Vermeidung von Lock Escalation
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 5. Industrieller Standard: Chunk-weises Batching mit WHILE';
PRINT '======================================================================';

-- Simulation: In großen Systemen werden historische Logs oder Umsätze nicht
-- auf einmal mit einem gigantischen DELETE gelöscht (Gefahr von Tabellensperren),
-- sondern in handlichen "Chunks" (z. B. TOP 1000) gelöscht, bis @@ROWCOUNT = 0 ist:

/*
MUSTERCODE FÜR GROSSDATEN-ARCHIVIERUNG:

DECLARE @batchGroesse INT = 1000;
DECLARE @geloeschteZeilen INT = 1;

WHILE @geloeschteZeilen > 0
BEGIN
    DELETE TOP (@batchGroesse)
    FROM dbo.AuditLog
    WHERE erstellDatum < DATEADD(YEAR, -3, GETDATE());

    SET @geloeschteZeilen = @@ROWCOUNT;
    PRINT CONCAT('Batch abgeschlossen: ', @geloeschteZeilen, ' Zeilen gelöscht.');

    -- Kurze Pause zur Entlastung des Transaktionsprotokolls
    WAITFOR DELAY '00:00:01';
END;
*/

PRINT 'HINWEIS: WHILE-Schleifen sind das Mittel der Wahl für chunk-basierte ETL- & Archivierungs-Batches.';
GO
