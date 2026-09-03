-- ============================================================================
-- SQL-Fundamentals: Day 24 - T-SQL Prozedurale Programmierung
-- Datei: 08_tsql_functions_vs_stored_procedures.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 03.09.2026
-- Fokus: T-SQL User-Defined Functions (UDF) & Gegenüberstellung zu Stored Procedures
-- Datenbank: ProjektDB (Single Source of Truth)
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- THEORIE: User-Defined Functions (UDF) vs. Stored Procedures (SP)
-- ----------------------------------------------------------------------------
-- Die Unterscheidung zwischen Stored Procedures und benutzerdefinierten
-- Funktionen ist eine der zentralen Grundlagen von T-SQL und ein absoluter
-- IHK-Prüfungsklassiker!
--
-- DIE 3 ARTEN VON T-SQL FUNKTIONEN:
-- 1. Skalare Funktionen (Scalar UDF):
--    - Gibt genau EINEN einzelnen Wert (INT, VARCHAR, DECIMAL...) zurück.
--    - WICHTIG: Muss beim Aufruf IMMER mit zweigliedrigem Namen (Schema.Name,
--      z. B. 'dbo.udf_...') aufgerufen werden!
--    - Kann überall stehen, wo ein Spaltenausdruck erlaubt ist (SELECT, WHERE, ORDER BY).
--
-- 2. Inline-Tabellenwertfunktionen (Inline Table-Valued Functions - iTVF):
--    - Gibt eine Tabelle zurück ('RETURNS TABLE').
--    - Besitzt KEIN BEGIN...END, sondern nur ein einzelnes 'RETURN (SELECT ...)'.
--    - Performance-Champion: Wird vom Optimizer wie eine parametrisierte VIEW behandelt!
--
-- 3. Mehrfachanweisungs-Tabellenwertfunktionen (Multi-Statement TVF - MSTVF):
--    - Besitzt BEGIN...END und deklariert eine explizite Tabellenvariable.
--    - Befüllt die Tabelle schrittweise über Logik.
--
-- DER GROSSE VERGLEICH (IHK-KOMPENDIUM):
-- ┌───────────────────────┬─────────────────────────────┬─────────────────────────────┐
-- │ Kriterium             │ Stored Procedure (SP)       │ User-Defined Function (UDF) │
-- ├───────────────────────┼─────────────────────────────┼─────────────────────────────┤
-- │ Primärer Zweck        │ Ausführen von Aktionen      │ Berechnen & Transformieren  │
-- │ Rückgabewert          │ Optional (Resultsets,       │ Zwingend genau EIN Wert     │
-- │                       │ OUTPUT, RETURN-Status-INT)  │ (Skalar oder TABLE)         │
-- │ DML-Erlaubnis         │ JA (INSERT, UPDATE, DELETE, │ NEIN! Strikt Read-Only      │
-- │ (Seiteneffekte)       │ TRUNCATE, Temp-Tabellen)    │ (Darf DB-Zustand nicht      │
-- │                       │                             │ verändern! Keine DML)       │
-- │ Transaktionen (TCL)   │ JA (BEGIN TRAN, COMMIT...)  │ NEIN! Transaktionsbefehle   │
-- │                       │                             │ sind streng verboten!       │
-- │ Aufruf / Syntax       │ Nur eigenständig via EXEC   │ Direkt in Abfragen (SELECT, │
-- │                       │ (kann nicht in SELECT/WHERE)│ WHERE, JOIN, HAVING)        │
-- │ OUTPUT-Parameter      │ JA (@param Typ OUTPUT)      │ NEIN (nur normale Inputs)   │
-- │ Aufruf anderer Objekte│ Darf SPs und UDFs aufrufen  │ Darf KEINE SPs aufrufen     │
-- └───────────────────────┴─────────────────────────────┴─────────────────────────────┘
-- ============================================================================


-- ----------------------------------------------------------------------------
-- 1. Skalare Funktion (Scalar UDF): Nettogehalt berechnen
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 1. Skalare Funktion: dbo.udf_BerechneNettoGehalt';
PRINT '======================================================================';

CREATE OR ALTER FUNCTION dbo.udf_BerechneNettoGehalt (
    @bruttoGehalt DECIMAL(10, 2),
    @steuersatzProzent DECIMAL(4, 2) = 35.00 -- Default: 35% Abzüge
)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    -- Validierung: Wenn Bruttogehalt NULL oder negativ, NULL zurückgeben
    IF @bruttoGehalt IS NULL OR @bruttoGehalt <= 0
        RETURN 0.00;

    DECLARE @netto DECIMAL(10, 2);
    SET @netto = ROUND(@bruttoGehalt * (1.00 - (@steuersatzProzent / 100.00)), 2);

    RETURN @netto;
END;
GO

-- Verwendung der Skalarfunktion direkt in der SELECT- und WHERE-Klausel:
-- WICHTIG: dbo.-Präfix ist für skalare UDFs in T-SQL ZWINGEND erforderlich!
SELECT m.id AS Personalnummer,
       m.vorname,
       m.nachname,
       g.gehalt AS Brutto,
       dbo.udf_BerechneNettoGehalt(g.gehalt, 30.00) AS Netto_30Prozent,
       dbo.udf_BerechneNettoGehalt(g.gehalt, DEFAULT) AS Netto_Standard35Prozent
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
WHERE dbo.udf_BerechneNettoGehalt(g.gehalt, DEFAULT) >= 2500.00;
GO


-- ----------------------------------------------------------------------------
-- 2. Inline-Tabellenwertfunktion (iTVF): Parametrisierte Sicht (Best Practice)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 2. Inline Table-Valued Function: dbo.itvf_ProjektMitarbeiterListe';
PRINT '======================================================================';

-- ACHTUNG: Kein BEGIN...END! Reines parametrisiertes SELECT!
CREATE OR ALTER FUNCTION dbo.itvf_ProjektMitarbeiterListe (
    @projektId INT
)
RETURNS TABLE
AS
RETURN (
    SELECT p.id AS ProjektID,
           p.kuerzel AS ProjektKuerzel,
           p.bezeichnung AS ProjektName,
           m.id AS MitarbeiterID,
           CONCAT(m.vorname, ' ', m.nachname) AS MitarbeiterName,
           arb.aufgabe AS RolleImProjekt,
           arb.einst_dat AS Beginn
    FROM dbo.Projekt AS p
    INNER JOIN dbo.Arbeit AS arb ON p.id = arb.pro_id
    INNER JOIN dbo.Mitarbeiter AS m ON arb.mit_id = m.id
    WHERE p.id = @projektId
);
GO

-- Aufruf in der FROM-Klausel wie eine ganz normale Tabelle:
SELECT *
FROM dbo.itvf_ProjektMitarbeiterListe(1);

-- Kombination mit CROSS APPLY (ruft die Funktion für jedes Projekt dynamisch auf):
SELECT p.kuerzel, p.mittel, team.MitarbeiterName, team.RolleImProjekt
FROM dbo.Projekt AS p
CROSS APPLY dbo.itvf_ProjektMitarbeiterListe(p.id) AS team;
GO


-- ----------------------------------------------------------------------------
-- 3. Mehrfachanweisungs-Tabellenwertfunktion (Multi-Statement TVF)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 3. Multi-Statement TVF: dbo.mstvf_AbteilungsAuswertung';
PRINT '======================================================================';

CREATE OR ALTER FUNCTION dbo.mstvf_AbteilungsAuswertung (
    @mindestMitarbeiter INT = 1
)
RETURNS @ErgebnisTabelle TABLE (
    AbteilungsID INT,
    Kuerzel NVARCHAR(10),
    Bezeichnung NVARCHAR(50),
    MitarbeiterAnzahl INT,
    DurchschnittsGehalt DECIMAL(10, 2),
    Status NVARCHAR(30)
)
AS
BEGIN
    -- Befüllung der Tabellenvariable mit Logik
    INSERT INTO @ErgebnisTabelle (AbteilungsID, Kuerzel, Bezeichnung, MitarbeiterAnzahl, DurchschnittsGehalt, Status)
    SELECT a.id,
           a.kuerzel,
           a.bezeichnung,
           COUNT(m.id),
           ISNULL(AVG(g.gehalt), 0.00),
           CASE 
               WHEN COUNT(m.id) >= 3 THEN 'Große Abteilung'
               WHEN COUNT(m.id) >= 1 THEN 'Kleine Abteilung'
               ELSE 'Vakant / Leer'
           END
    FROM dbo.Abteilung AS a
    LEFT JOIN dbo.Mitarbeiter AS m ON a.id = m.abt_id
    LEFT JOIN dbo.Gehalt AS g ON m.id = g.mit_id
    GROUP BY a.id, a.kuerzel, a.bezeichnung
    HAVING COUNT(m.id) >= @mindestMitarbeiter;

    RETURN;
END;
GO

-- Abfrage der Multi-Statement Funktion:
SELECT * 
FROM dbo.mstvf_AbteilungsAuswertung(1)
ORDER BY MitarbeiterAnzahl DESC;
GO


-- ----------------------------------------------------------------------------
-- 4. Demonstration der Restriktionen von Funktionen (Warum UDFs keine SPs sind)
-- ----------------------------------------------------------------------------
PRINT '======================================================================';
PRINT '>>> 4. Restriktionen von Funktionen (Seiteneffekt-Verbot)';
PRINT '======================================================================';

-- HINWEIS: Folgender Code ist absichtlich auskommentiert, da der T-SQL-Compiler
-- ihn mit Fehlern ablehnen würde:

/*
CREATE OR ALTER FUNCTION dbo.udf_VerboteneAktionen()
RETURNS INT
AS
BEGIN
    -- FEHLER 1: DML auf permanente Tabellen ist in Funktionen verboten!
    -- INSERT INTO dbo.Mitarbeiter (vorname, nachname) VALUES ('Test', 'User');
    
    -- FEHLER 2: Transaktionsbefehle sind in Funktionen verboten!
    -- BEGIN TRANSACTION;
    -- COMMIT;

    -- FEHLER 3: Stored Procedures dürfen in Funktionen nicht aufgerufen werden!
    -- EXEC dbo.usp_AbteilungsUebersicht;

    -- FEHLER 4: PRINT ist in Funktionen nicht zulässig!
    -- PRINT 'Testausgabe';

    RETURN 1;
END;
GO
*/

PRINT '>>> Fazit: Funktionen sind strikt deterministisch/read-only ohne Seiteneffekte!';
PRINT '    Für schreibende DML-Operationen, Transaktionen und Workflows MÜSSEN';
PRINT '    Stored Procedures verwendet werden!';
GO
