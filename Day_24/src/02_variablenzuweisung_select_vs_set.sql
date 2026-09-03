-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Variablen & Kontrollstrukturen
-- Datei: 02_variablenzuweisung_select_vs_set.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: Variablenzuweisung aus Abfragen (SELECT vs. SET) & Fallstricke
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- THEORIE: Variablenzuweisung über Abfragen ([test declare von select])
-- ----------------------------------------------------------------------------
-- In T-SQL gibt es zwei Wege, um Daten aus Tabellen in Variablen zu speichern:
--
-- 1. Syntax mit SELECT:
--    SELECT @variable = spalte FROM tabelle WHERE bedingung;
--    - Erlaubt die Zuweisung MEHRERER Variablen in einem einzigen Statement.
--    - Hohe Performance, da nur ein einziger Tabellenzugriff erfolgt.
--
-- 2. Syntax mit SET und skalarer Unterabfrage:
--    SET @variable = (SELECT spalte FROM tabelle WHERE bedingung);
--    - ANSI-SQL Standard für skalare Zuweisungen.
--    - Pro SET-Befehl kann nur genau EINE Variable zugewiesen werden.
--
-- 3. DER GROSSE VERHALTENSUNTERSCHIED BEI RANDFÄLLEN:
--    ┌──────────────────────────┬──────────────────────┬──────────────────────┐
--    │ Szenario                 │ SELECT @var = col    │ SET @var = (SELECT)  │
--    ├──────────────────────────┼──────────────────────┼──────────────────────┤
--    │ Genau 1 Zeile            │ @var = Wert          │ @var = Wert          │
--    │ Mehrere Zeilen (> 1)     │ Kein Fehler! Letzter │ FEHLER 512!          │
--    │                          │ Zeilenwert gewinnt   │ (Subquery liefert    │
--    │                          │ (nicht-determinist.) │ mehrere Zeilen)      │
--    │ Keine Zeilen (0 Treffer) │ Variable behält      │ Variable wird        │
--    │                          │ vorherigen Wert!     │ explizit NULL!       │
--    └──────────────────────────┴──────────────────────┴──────────────────────┘
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Einfache Variablenzuweisung aus einer Tabelle mit SELECT
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Einfache Zuweisung mit SELECT auf ProjektDB';
PRINT '======================================================================';

DECLARE @mit_id INT = 25348;
DECLARE @mitarbeiterName NVARCHAR(100);
DECLARE @abteilungsId INT;

-- Wertzuweisung direkt aus der Mitarbeiter-Tabelle
SELECT @mitarbeiterName = CONCAT(vorname, ' ', nachname),
       @abteilungsId = abt_id
FROM dbo.Mitarbeiter
WHERE id = @mit_id;

PRINT 'Gefundener Mitarbeiter (ID ' + CAST(@mit_id AS NVARCHAR(10)) + '): ' + @mitarbeiterName;
PRINT 'Zugehörige Abteilungs-ID: ' + CAST(@abteilungsId AS NVARCHAR(10));
GO


-- ----------------------------------------------------------------------------
-- 2. Parallele Zuweisung mehrerer Variablen in EINEM Schritt
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Parallele Zuweisung mehrerer Variablen (SELECT-Vorteil)';
PRINT '======================================================================';

-- Wir ermitteln Stammdaten, Gehalt und Projektinformationen in einer Abfrage
DECLARE @suchId INT = 28559;
DECLARE @vname NVARCHAR(50);
DECLARE @nname NVARCHAR(50);
DECLARE @wohnort NVARCHAR(50);
DECLARE @monatsgehalt DECIMAL(10, 2);

-- Ein einziger JOIN-Select befüllt alle 4 Variablen atomar und performant:
SELECT @vname = m.vorname,
       @nname = m.nachname,
       @wohnort = m.ort,
       @monatsgehalt = g.gehalt
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
WHERE m.id = @suchId;

PRINT 'Personalakte für ID ' + CAST(@suchId AS NVARCHAR(10)) + ':';
PRINT '  Name: ' + @vname + ' ' + @nname;
PRINT '  Wohnort: ' + @wohnort;
PRINT '  Gehalt: ' + CAST(@monatsgehalt AS NVARCHAR(20)) + ' EUR';
GO


-- ----------------------------------------------------------------------------
-- 3. Aggregierte Werte direkt in Variablen zuweisen
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Aggregationen in Variablen (SUM, AVG, COUNT, MAX)';
PRINT '======================================================================';

DECLARE @gesamtMitarbeiter INT;
DECLARE @durchschnittsGehalt DECIMAL(10, 2);
DECLARE @hoechstesGehalt DECIMAL(10, 2);
DECLARE @gesamtBudgetProjekte DECIMAL(12, 2);

-- Mitarbeiter- und Gehaltsstatistiken
SELECT @gesamtMitarbeiter = COUNT(*),
       @durchschnittsGehalt = AVG(gehalt),
       @hoechstesGehalt = MAX(gehalt)
FROM dbo.Gehalt;

-- Projekt-Budgetsumme
SELECT @gesamtBudgetProjekte = SUM(mittel)
FROM dbo.Projekt;

PRINT 'ProjektDB Unternehmens-Kennzahlen:';
PRINT '  Anzahl Gehaltsempfänger: ' + CAST(@gesamtMitarbeiter AS NVARCHAR(10));
PRINT '  Durchschnittsgehalt:     ' + CAST(@durchschnittsGehalt AS NVARCHAR(20)) + ' EUR';
PRINT '  Spitzengehalt:           ' + CAST(@hoechstesGehalt AS NVARCHAR(20)) + ' EUR';
PRINT '  Gesamtes Projektbudget:  ' + CAST(@gesamtBudgetProjekte AS NVARCHAR(20)) + ' EUR';
GO


-- ----------------------------------------------------------------------------
-- 4. DIE FALLSTRICKE: Verhalten bei MEHREREN Zeilen (> 1 Treffer)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. Randfall: Mehrere Zeilen (> 1 Treffer)';
PRINT '======================================================================';

-- Fall A: Zuweisung mit SELECT bei mehreren Treffern
-- Die Abteilung 1 (oder Wohnort München) hat mehrere Mitarbeiter!
DECLARE @testName NVARCHAR(50) = 'VorherigerWert';

-- T-SQL wirft HIER KEINEN FEHLER! Die Variable wird zeilenweise überschrieben.
-- Welcher Nachname am Ende in @testName steht, ist ohne ORDER BY nicht garantiert!
SELECT @testName = nachname
FROM dbo.Mitarbeiter
WHERE abt_id = 1;

PRINT 'Ergebnis mit SELECT (Letzter verarbeiteter Datensatz gewinnt): ' + @testName;

-- Fall B: Zuweisung mit SET und skalarer Unterabfrage
-- ACHTUNG: Die folgende Zeile wirft Laufzeitfehler 512!
-- Fehler: "Die Unterabfrage hat mehr als einen Wert zurückgegeben. Das ist unzulässig..."
/*
DECLARE @fehlerTest NVARCHAR(50);
SET @fehlerTest = (SELECT nachname FROM dbo.Mitarbeiter WHERE abt_id = 1);
PRINT @fehlerTest;
*/
PRINT 'HINWEIS: SET @var = (SELECT ...) wirft Fehler 512 bei Mehrfachtreffern!';
GO


-- ----------------------------------------------------------------------------
-- 5. DIE FALLSTRICKE: Verhalten bei NULL Zeilen (0 Treffer)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 5. Randfall: Keine Zeilen (0 Treffer) - DIE HÄUFIGSTE FEHLERQUELLE!';
PRINT '======================================================================';

-- Fall A: SELECT @var = ... wenn keine Zeile gefunden wird
DECLARE @testWert NVARCHAR(50) = 'Original-Inhalt';

-- Abfrage nach einer ID, die garantiert nicht existiert:
SELECT @testWert = nachname
FROM dbo.Mitarbeiter
WHERE id = -99999;

-- ACHTUNG: @testWert wird NICHT auf NULL gesetzt! Der alte Wert bleibt unverändert!
PRINT 'SELECT bei 0 Treffern: Variable bleibt -> ' + @testWert;

-- Fall B: SET @var = (SELECT ...) wenn keine Zeile gefunden wird
DECLARE @setWert NVARCHAR(50) = 'Original-Inhalt';

SET @setWert = (SELECT nachname FROM dbo.Mitarbeiter WHERE id = -99999);

-- HIER wird @setWert explizit auf NULL gesetzt:
PRINT 'SET bei 0 Treffern: Variable wird -> ' + ISNULL(@setWert, '[JETZT NULL]');
GO


-- ----------------------------------------------------------------------------
-- 6. Best Practice: Sicheres Abfragemuster zur Zuweisung
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 6. Best Practice: Saubere Initialisierung & Trefferprüfung';
PRINT '======================================================================';

DECLARE @gesuchteId INT = 99999; -- Existiert nicht
DECLARE @gefundenerOrt NVARCHAR(50) = NULL; -- IMMER explizit auf NULL vorinitialisieren!

SELECT @gefundenerOrt = ort
FROM dbo.Mitarbeiter
WHERE id = @gesuchteId;

IF @gefundenerOrt IS NULL
BEGIN
    PRINT 'Status: Kein Mitarbeiter mit ID ' + CAST(@gesuchteId AS NVARCHAR(10)) + ' gefunden.';
END
ELSE
BEGIN
    PRINT 'Status: Mitarbeiter wohnhaft in ' + @gefundenerOrt;
END;
GO
