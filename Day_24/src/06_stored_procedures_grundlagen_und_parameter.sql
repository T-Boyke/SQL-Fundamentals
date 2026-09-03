-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Prozedurale Programmierung
-- Datei: 06_stored_procedures_grundlagen_und_parameter.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: Stored Procedures Grundlagen – CREATE OR ALTER, Parameter, OUTPUT & RETURN
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- THEORIE: Gespeicherte Prozeduren (Stored Procedures) in T-SQL
-- ----------------------------------------------------------------------------
-- 1. Was ist eine Stored Procedure?
--    - Ein benannter, vorkompilierter Block von T-SQL-Anweisungen, der dauerhaft
--      in der Datenbank gespeichert wird (sys.procedures).
--    - Namenskonvention: 'usp_Name' (User Stored Procedure). Niemals 'sp_', da 'sp_'
--      vom SQL Server für System-Prozeduren im master reserviert ist!
--
-- 2. Warum Stored Procedures? (Die 4 Kernvorteile):
--    a) Performance & Execution Plan Caching:
--       Beim ersten Aufruf optimiert und kompiliert der SQL Server die Prozedur.
--       Der Ausführungsplan landet im Plan-Cache und wird wiederverwendet.
--    b) Sicherheit & Berechtigungskapselung (Least Privilege):
--       Benutzer benötigen KEINE Rechte auf Tabellen (z. B. Gehalt, Mitarbeiter),
--       sondern nur 'GRANT EXECUTE ON dbo.usp_...'! Über Ownership Chaining
--       greift die Prozedur autorisiert auf die Tabellen zu.
--    c) Schutz vor SQL Injection:
--       Eingabeparameter werden streng typisiert und niemals als nackter SQL-Text ausgeführt.
--    d) Wartbarkeit & Zentralisierung:
--       Geschäftslogik liegt zentral in der Datenbank und muss bei Änderungen
--       nicht in Dutzenden Client-Anwendungen angepasst werden.
--
-- 3. Parameter-Arten:
--    - Input-Parameter: Werte werden beim Aufruf übergeben (optional mit Defaultwert).
--    - OUTPUT-Parameter: Werte werden von der Prozedur berechnet und an den Aufrufer
--      zurückgegeben.
--    - RETURN-Wert: Gibt IMMER einen ganzzahligen Statuscode zurück (INT, z. B. 0 = Erfolg).
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Einfache Prozedur ohne Parameter (Stammdaten-Übersicht)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Einfache Prozedur ohne Parameter erstellen & aufrufen';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_AbteilungsUebersicht
AS
BEGIN
    SET NOCOUNT ON; -- Unterdrückt "X Zeilen betroffen" Meldungen für bessere Performance

    PRINT '>>> Ausführung: dbo.usp_AbteilungsUebersicht';
    
    SELECT a.id AS AbteilungsID,
           a.kuerzel AS Kuerzel,
           a.bezeichnung AS Abteilung,
           a.ort AS Standort,
           COUNT(m.id) AS AnzahlMitarbeiter
    FROM dbo.Abteilung AS a
    LEFT JOIN dbo.Mitarbeiter AS m ON a.id = m.abt_id
    GROUP BY a.id, a.kuerzel, a.bezeichnung, a.ort;
END;
GO

-- Aufruf mit EXECUTE / EXEC:
EXEC dbo.usp_AbteilungsUebersicht;
GO


-- ----------------------------------------------------------------------------
-- 2. Prozedur mit Eingabeparametern & Default-Werten
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Prozedur mit Eingabeparametern & Default-Wert';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_GetMitarbeiterNachOrt
    @gesuchterOrt NVARCHAR(50) = 'München', -- Defaultwert: München
    @mindestGehalt DECIMAL(10, 2) = 0.00   -- Defaultwert: 0 EUR
AS
BEGIN
    SET NOCOUNT ON;

    PRINT CONCAT('Suche Mitarbeiter in Standort "', @gesuchterOrt, '" mit Mindestgehalt >= ', @mindestGehalt, ' EUR...');

    SELECT m.id AS Personalnummer,
           m.vorname AS Vorname,
           m.nachname AS Nachname,
           m.ort AS Wohnort,
           a.bezeichnung AS Abteilung,
           g.gehalt AS Monatsgehalt
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
    WHERE m.ort = @gesuchterOrt
      AND g.gehalt >= @mindestGehalt
    ORDER BY g.gehalt DESC;
END;
GO

-- Testlauf A: Aufruf mit Standardwerten (München, >= 0 EUR)
PRINT '--- Test A: Aufruf ohne Parameter (nutzt Defaults) ---';
EXEC dbo.usp_GetMitarbeiterNachOrt;

-- Testlauf B: Aufruf mit expliziten benannten Parametern (Best Practice!)
PRINT '--- Test B: Aufruf mit benannten Parametern (Ulm, >= 3000 EUR) ---';
EXEC dbo.usp_GetMitarbeiterNachOrt 
    @gesuchterOrt = 'Ulm',
    @mindestGehalt = 3000.00;
GO


-- ----------------------------------------------------------------------------
-- 2b. Best Practice: Optionale Parameter mit Standardwerten (Such-Kaskade)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2b. Optionale Parameter mit Standardwerten (= NULL) & Kaskadenlogik';
PRINT '======================================================================';

-- ARCHITEKTUR-HINWEIS (Vorlesung Tom S.):
-- Wird ein Parameter mit '= NULL' deklariert, ist seine Übergabe optional.
-- Über eine IF...ELSE IF...ELSE Kaskade werden die unterschiedlichen
-- Suchszenarien getrennt voneinander ausgeführt:
-- 1. Suche nach Primärschlüssel-ID (höchste Selektivität / Clustered Index Seek)
-- 2. Suche nach Name/Muster (sekundäre Selektivität)
-- 3. Fallback ohne Filter (mit defensiver TOP-Begrenzung zum Schutz des Servers)
-- Vorteil gegenüber Catch-All 'WHERE (@id IS NULL OR id = @id)':
-- Der Query Optimizer kann für JEDEN Zweig einen maßgeschneiderten Ausführungsplan
-- erstellen, ohne in Parameter-Sniffing-Fallen zu tappen!

CREATE OR ALTER PROCEDURE dbo.usp_SucheMitarbeiter
    @mitarbeiterId INT = NULL,          -- Optionaler Parameter 1
    @nachname NVARCHAR(50) = NULL,      -- Optionaler Parameter 2
    @wohnort NVARCHAR(50) = NULL        -- Optionaler Parameter 3
AS
BEGIN
    SET NOCOUNT ON;

    PRINT '>>> Ausführung dbo.usp_SucheMitarbeiter';

    -- Variante A: Suche nach ID, wenn sie übergeben wurde (höchste Priorität)
    IF @mitarbeiterId IS NOT NULL
    BEGIN
        PRINT CONCAT('  [Zweig A] Gezielte Suche nach MitarbeiterID = ', @mitarbeiterId);
        SELECT id, vorname, nachname, abt_id, ort, chef_id
        FROM dbo.Mitarbeiter
        WHERE id = @mitarbeiterId;
    END
    -- Variante B: Suche nach Nachname (Präfix-Suche via LIKE)
    ELSE IF @nachname IS NOT NULL
    BEGIN
        PRINT CONCAT('  [Zweig B] Mustersuche nach Nachname LIKE "', @nachname, '%"');
        SELECT id, vorname, nachname, abt_id, ort, chef_id
        FROM dbo.Mitarbeiter
        WHERE nachname LIKE @nachname + '%'
        ORDER BY nachname, vorname;
    END
    -- Variante C: Suche nach Wohnort
    ELSE IF @wohnort IS NOT NULL
    BEGIN
        PRINT CONCAT('  [Zweig C] Suche nach Wohnort = "', @wohnort, '"');
        SELECT id, vorname, nachname, abt_id, ort, chef_id
        FROM dbo.Mitarbeiter
        WHERE ort = @wohnort
        ORDER BY nachname;
    END
    -- Variante D: Keine Filterparameter übergeben (Fallback)
    ELSE
    BEGIN
        PRINT '  [Zweig D] Keine Filter übergeben: Lade die ersten 10 Mitarbeiter (TOP 10)...';
        SELECT TOP (10) id, vorname, nachname, abt_id, ort, chef_id
        FROM dbo.Mitarbeiter
        ORDER BY id;
    END;
END;
GO

-- Testlauf 1: Suche nach ID (Variante A)
PRINT '--- Test 1: Aufruf mit @mitarbeiterId = 25348 ---';
EXEC dbo.usp_SucheMitarbeiter @mitarbeiterId = 25348;

-- Testlauf 2: Suche nach Name (Variante B - nutzt Default für ID)
PRINT '--- Test 2: Aufruf mit @nachname = "K" ---';
EXEC dbo.usp_SucheMitarbeiter @nachname = 'K';

-- Testlauf 3: Aufruf ganz ohne Parameter (Variante D - Fallback TOP 10)
PRINT '--- Test 3: Aufruf ohne Parameter (nutzt alle Defaults = NULL) ---';
EXEC dbo.usp_SucheMitarbeiter;
GO


-- ----------------------------------------------------------------------------
-- 2c. Vorlesungs-Original: SucheKunden mit optionalen Parametern
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2c. Vorlesungs-Original: dbo.usp_SucheKunden auf ProjektDB';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_SucheKunden
    @kundenId INT = NULL,          -- Optionaler Parameter 1
    @firmenName NVARCHAR(100) = NULL -- Optionaler Parameter 2
AS
BEGIN
    SET NOCOUNT ON;

    -- Variante A: Suche nach ID, wenn sie übergeben wurde
    IF @kundenId IS NOT NULL
    BEGIN
        SELECT id, firma, ort FROM dbo.Kunde WHERE id = @kundenId;
    END
    -- Variante B: Suche nach Name, wenn ID fehlt aber Name da ist
    ELSE IF @firmenName IS NOT NULL
    BEGIN
        SELECT id, firma, ort FROM dbo.Kunde WHERE firma LIKE @firmenName + '%';
    END
    -- Variante C: Keine Parameter übergeben
    ELSE
    BEGIN
        SELECT TOP (100) id, firma, ort FROM dbo.Kunde ORDER BY id;
    END;
END;
GO

-- Aufruftest
EXEC dbo.usp_SucheKunden @firmenName = 'A';
GO


-- ----------------------------------------------------------------------------
-- 3. Prozedur mit OUTPUT-Parametern (Werte an den Aufrufer zurückliefern)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Prozedur mit OUTPUT-Parametern';
PRINT '======================================================================';

CREATE OR ALTER PROCEDURE dbo.usp_BerechneAbteilungsStatistik
    @abteilungsKuerzel NVARCHAR(10),                 -- INPUT
    @anzahlMitarbeiter INT OUTPUT,                    -- OUTPUT
    @durchschnittsGehalt DECIMAL(10, 2) OUTPUT,       -- OUTPUT
    @summeGehaelter DECIMAL(12, 2) OUTPUT             -- OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    -- Standard-Initialisierung der Ausgabewerte
    SET @anzahlMitarbeiter = 0;
    SET @durchschnittsGehalt = 0.00;
    SET @summeGehaelter = 0.00;

    -- Prüfung: Existiert die Abteilung?
    IF NOT EXISTS (SELECT 1 FROM dbo.Abteilung WHERE kuerzel = @abteilungsKuerzel)
    BEGIN
        PRINT CONCAT('[FEHLER] Abteilung mit Kürzel "', @abteilungsKuerzel, '" existiert nicht!');
        RETURN -1; -- Negativer Return-Code signalisiert Fehler
    END;

    -- Aggregat-Werte direkt in die OUTPUT-Parameter schreiben
    SELECT @anzahlMitarbeiter = COUNT(m.id),
           @durchschnittsGehalt = ISNULL(AVG(g.gehalt), 0.00),
           @summeGehaelter = ISNULL(SUM(g.gehalt), 0.00)
    FROM dbo.Abteilung AS a
    LEFT JOIN dbo.Mitarbeiter AS m ON a.id = m.abt_id
    LEFT JOIN dbo.Gehalt AS g ON m.id = g.mit_id
    WHERE a.kuerzel = @abteilungsKuerzel;

    RETURN 0; -- 0 = Erfolg
END;
GO

-- Aufruf und Auswertung der OUTPUT-Parameter im Client-Batch:
DECLARE @anz INT;
DECLARE @avg DECIMAL(10, 2);
DECLARE @sum DECIMAL(12, 2);
DECLARE @status INT;

-- WICHTIG: Das Schlüsselwort OUTPUT muss sowohl bei der Deklaration
-- in der Prozedur als auch BEIM AUFRUF angegeben werden!
EXEC @status = dbo.usp_BerechneAbteilungsStatistik
    @abteilungsKuerzel = 'BE',
    @anzahlMitarbeiter = @anz OUTPUT,
    @durchschnittsGehalt = @avg OUTPUT,
    @summeGehaelter = @sum OUTPUT;

PRINT CONCAT('Rückgabestatus der Prozedur: ', @status);
IF @status = 0
BEGIN
    PRINT '>>> ERGEBNIS DER ABTEILUNG BE:';
    PRINT CONCAT('    Mitarbeiteranzahl:   ', @anz);
    PRINT CONCAT('    Durchschnittsgehalt: ', FORMAT(@avg, 'N2', 'de-DE'), ' EUR');
    PRINT CONCAT('    Gehaltssumme Monat:  ', FORMAT(@sum, 'N2', 'de-DE'), ' EUR');
END;
GO


-- ----------------------------------------------------------------------------
-- 4. Metadaten & Systemkatalog-Inspektion von Stored Procedures
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. Inspektion von Prozeduren in Systemkatalogen';
PRINT '======================================================================';

-- Alle benutzerdefinierten Prozeduren auflisten
SELECT name AS ProzedurName,
       object_id AS ObjektID,
       create_date AS ErstelltAm,
       modify_date AS GeaendertAm
FROM sys.procedures
WHERE is_ms_shipped = 0
ORDER BY name;

-- Parameter einer Prozedur untersuchen
SELECT p.name AS ParameterName,
       TYPE_NAME(p.user_type_id) AS Datentyp,
       p.max_length AS MaxLaenge,
       p.is_output AS IstOutputParameter,
       p.has_default_value AS HatDefaultWert
FROM sys.parameters AS p
WHERE p.object_id = OBJECT_ID('dbo.usp_BerechneAbteilungsStatistik')
ORDER BY p.parameter_id;
GO
