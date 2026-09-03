-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Variablen & Kontrollstrukturen
-- Datei: 01_variablen_declare_set_und_print.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: DECLARE, Scope (Gültigkeitsbereich), SET, PRINT & String-Konvertierung
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- THEORIE: Variablen in Transact-SQL (T-SQL)
-- ----------------------------------------------------------------------------
-- 1. Was ist eine lokale Variable?
--    - Ein benannter Speicherplatz im Arbeitsspeicher für die Dauer eines Batches.
--    - Syntax: DECLARE @variablen_name Datentyp [= initialwert];
--    - Das Zeichen '@' ist zwingend erforderlich (kennzeichnet lokale Variablen).
--    - Ohne explizite Initialisierung besitzt jede deklarierte Variable den Wert NULL.
--
-- 2. Gültigkeitsbereich (Batch-Scope):
--    - Eine lokale Variable existiert NUR innerhalb des Batches, in dem sie
--      deklariert wurde.
--    - Ein Batch endet an der Anweisung 'GO'. Nach einem 'GO' ist die Variable
--      dem SQL Server vollkommen unbekannt!
--
-- 3. Wertzuweisung mit SET:
--    - Syntax: SET @variablen_name = ausdruck;
--    - SET ist der ANSI-SQL-Standard zur Zuweisung eines Skalarwerts.
--    - Pro SET-Anweisung kann genau EINE Variable zugewiesen werden.
--
-- 4. Bildschirmausgabe mit PRINT:
--    - Gibt Zeichenfolgen in den 'Messages'-Reiter (Meldungen) von SSMS/DataGrip aus.
--    - Erfordert Zeichenketten (VARCHAR/NVARCHAR). Nicht-String-Typen müssen
--      mittels CAST() oder CONVERT() umgewandelt werden, oder sicher mit CONCAT().
--    - PRINT vs. SELECT: PRINT erzeugt Debug-/Statusmeldungen, SELECT liefert ein
--      tabellarisches Resultset (Data Grid) zurück.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Deklaration und Initialisierung von Variablen
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Deklaration und Initialisierung';
PRINT '======================================================================';

-- Einzelne Deklaration mit Initialwert
DECLARE @vorname NVARCHAR(50) = 'Tobias';
DECLARE @nachname NVARCHAR(50) = 'Boyke';
DECLARE @personalnummer INT = 25348;
DECLARE @gehalt DECIMAL(10, 2) = 4850.50;
DECLARE @istAktiv BIT = 1;
DECLARE @erfassungsdatum DATE = GETDATE();

-- Ausgabe der deklarierten Werte
PRINT 'Mitarbeiter: ' + @vorname + ' ' + @nachname;
PRINT 'Personalnummer: ' + CAST(@personalnummer AS NVARCHAR(10));
PRINT 'Gehalt: ' + CAST(@gehalt AS NVARCHAR(20)) + ' EUR';
PRINT 'Status Aktiv: ' + CAST(@istAktiv AS NVARCHAR(1));
PRINT 'Erfasst am: ' + CONVERT(NVARCHAR(10), @erfassungsdatum, 104); -- Format: TT.MM.JJJJ
GO


-- ----------------------------------------------------------------------------
-- 2. Mehrfach-Deklaration in einer einzigen DECLARE-Anweisung
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Kompakte Mehrfach-Deklaration';
PRINT '======================================================================';

-- Variablen können kommagetrennt in einem Statement deklariert werden
DECLARE @test INT = 100,
        @faktor DECIMAL(4, 2) = 1.19,
        @ergebnis DECIMAL(10, 2),
        @bezeichnung NVARCHAR(50) = 'ProjektDB-Berechnung';

-- Berechnung und Wertzuweisung mit SET
SET @ergebnis = @test * @faktor;

PRINT 'Testwert: ' + CAST(@test AS NVARCHAR(10));
PRINT 'Faktor: ' + CAST(@faktor AS NVARCHAR(10));
PRINT 'Ergebnis (inkl. MwSt): ' + CAST(@ergebnis AS NVARCHAR(20));
PRINT 'Bezeichnung: ' + @bezeichnung;
GO


-- ----------------------------------------------------------------------------
-- 3. Der Batch-Scope (Gültigkeitsbereich) und das 'GO'-Statement
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Batch-Scope Demonstration';
PRINT '======================================================================';

DECLARE @scopeTest NVARCHAR(50) = 'Ich lebe nur in diesem Batch!';
PRINT 'Innerhalb des Batches: ' + @scopeTest;

-- ACHTUNG: Die folgende Zeile ist auskommentiert, da sie nach dem GO einen Fehler werfen würde:
-- GO
-- PRINT @scopeTest; -- FEHLER: Die Skalarvariable "@scopeTest" muss deklariert werden!
GO


-- ----------------------------------------------------------------------------
-- 4. Berechnungen, Funktionen und Wertzuweisungen mit SET
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. SET mit Berechnungen und Systemfunktionen';
PRINT '======================================================================';

DECLARE @basiswert DECIMAL(10, 2) = 2500.00;
DECLARE @bonus DECIMAL(10, 2);
DECLARE @gesamtvergütung DECIMAL(10, 2);
DECLARE @angemeldeterUser NVARCHAR(100);
DECLARE @datenbankName NVARCHAR(50);

-- SET mit arithmetischer Berechnung
SET @bonus = @basiswert * 0.15;
SET @gesamtvergütung = @basiswert + @bonus;

-- SET mit integrierten SQL Server Funktionen
SET @angemeldeterUser = SUSER_NAME();
SET @datenbankName = DB_NAME();

PRINT 'Basisgehalt: ' + CAST(@basiswert AS NVARCHAR(20)) + ' EUR';
PRINT 'Bonus (15%): ' + CAST(@bonus AS NVARCHAR(20)) + ' EUR';
PRINT 'Gesamt: ' + CAST(@gesamtvergütung AS NVARCHAR(20)) + ' EUR';
PRINT 'Ausgeführt von User: ' + @angemeldeterUser;
PRINT 'In Datenbank: ' + @datenbankName;
GO


-- ----------------------------------------------------------------------------
-- 5. Der Fallstrick: NULL-Handling bei PRINT & String-Konvertierung
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 5. String-Verkettung, NULL-Fallen & CONCAT-Best-Practice';
PRINT '======================================================================';

DECLARE @teil1 NVARCHAR(20) = 'Status: ';
DECLARE @teil2 NVARCHAR(20) = NULL; -- Unbekannter Wert
DECLARE @teil3 NVARCHAR(20) = 'Abgeschlossen';

-- PROBLEM: Standardmäßig gilt: Etwas + NULL = NULL!
-- Wenn @teil2 NULL ist, wird die gesamte Meldung zu NULL und PRINT gibt nichts aus!
PRINT '--- Versuch mit klassischem Plus-Operator (+) ---';
PRINT @teil1 + @teil2 + @teil3; -- Ergibt NULL (leere Meldungszeile!)

-- LÖSUNG 1: Absicherung mit ISNULL() oder COALESCE()
PRINT '--- Lösung 1: ISNULL() ---';
PRINT @teil1 + ISNULL(@teil2, '[UNBEKANNT]') + ' -> ' + @teil3;

-- LÖSUNG 2: Moderne CONCAT()-Funktion (konvertiert NULL automatisch zu leerem String)
PRINT '--- Lösung 2: CONCAT() (Best Practice) ---';
PRINT CONCAT(@teil1, @teil2, ' [via CONCAT] -> ', @teil3);
GO


-- ----------------------------------------------------------------------------
-- 6. Gegenüberstellung: PRINT vs. SELECT
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 6. Gegenüberstellung: PRINT (Meldungen) vs. SELECT (Data Grid)';
PRINT '======================================================================';

DECLARE @infoMsg NVARCHAR(100) = 'Dies ist eine reine Statusmeldung für das Protokoll.';
DECLARE @zaehler INT = 42;

-- PRINT schreibt in das Ausgabefenster (Reiter "Meldungen" / Console Output)
PRINT '>>> PRINT-Ausgabe: ' + @infoMsg + ' (Zähler: ' + CAST(@zaehler AS NVARCHAR(10)) + ')';

-- SELECT liefert ein tabularisches Resultset an den Client (Reiter "Ergebnisse" / Grid View)
SELECT @zaehler AS ZaehlerWert,
       @infoMsg AS InfoText,
       GETDATE() AS Zeitstempel;
GO
