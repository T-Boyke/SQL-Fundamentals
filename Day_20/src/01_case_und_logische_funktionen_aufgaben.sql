-- ============================================================================
-- SQL-Fundamentals: Day 20 - T-SQL Funktionen & CASE-Ausdrücke
-- Datei: 01_case_und_logische_funktionen_aufgaben.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 28.08.2026
-- Single Source of Truth (SoT): ProjektDB
-- ============================================================================

USE ProjektDB;
GO

SET LANGUAGE german;
GO

-- ============================================================================
-- THEORIE: CASE-Ausdrücke und logische Funktionen
-- ----------------------------------------------------------------------------
-- 1. Einfacher CASE (Simple CASE):
--    CASE <ausdruck> WHEN <wert1> THEN <ergebnis1> ... ELSE <default> END
-- 2. Durchsuchter CASE (Searched CASE / Komplexer CASE):
--    CASE WHEN <bedingung1> THEN <ergebnis1> ... ELSE <default> END
-- 3. Logische Funktionen:
--    - IIF(bedingung, wenn_wahr, wenn_falsch) -> Ternärer Operator
--    - ISNULL(ausdruck, ersatz)              -> 2 Argumente, Typ von ausdruck
--    - COALESCE(val1, val2, ..., valN)        -> N Argumente, Typ höchster Rang
-- ============================================================================


-- ============================================================================
-- Aufgabe 9.1: Projektkategorisierung nach Mitteln (CASE)
-- ----------------------------------------------------------------------------
-- Geben Sie eine Liste aller Projekte aus, in der Sie diese nach den 
-- verfügbaren Mitteln in Kategorien einteilen:
--   weniger als  90.000 => Kategorie 1
--   weniger als 135.000 => Kategorie 2
--   weniger als 170.000 => Kategorie 3
--   ab 170.000          => Kategorie 4
--
-- Erwartetes Ergebnis:
--   bezeichnung  kategorie
--   Apollo       2
--   Gemini       2
--   Merkur       4
--   Pluto        1
--   Ariane       3
-- ============================================================================

PRINT '=== Aufgabe 9.1: Projekt-Kategorisierung ===';

SELECT bezeichnung,
       CASE
           WHEN mittel < 90000.00 THEN 1
           WHEN mittel < 135000.00 THEN 2
           WHEN mittel < 170000.00 THEN 3
           ELSE 4
       END AS kategorie
FROM Projekt;
GO


-- ============================================================================
-- Aufgabe 9.2: Mitarbeiter-Kategorisierung (Standort vs. Abteilung)
-- ----------------------------------------------------------------------------
-- Kategorisieren Sie Ihre Mitarbeiter. 
-- - Mitarbeiter in Abteilung 'Einkauf' kommen in Kategorie A.
-- - Mitarbeiter aus anderen Abteilungen kommen in Kategorie B.
-- - Wer in Landshut oder Rosenheim wohnt (auf dem Land), kommt auf jeden Fall in Kategorie F.
--
-- Erwartetes Ergebnis: 15 Zeilen
-- ============================================================================

PRINT '=== Aufgabe 9.2: Mitarbeiter-Kategorisierung (A / B / F) ===';

SELECT m.id,
       m.nachname,
       m.ort,
       a.bezeichnung,
       CASE
           WHEN m.ort IN ('Landshut', 'Rosenheim') THEN 'F'
           WHEN a.bezeichnung = 'Einkauf' THEN 'A'
           ELSE 'B'
       END AS kategorie
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;
GO


-- ============================================================================
-- Aufgabe 9.3: Erweiterte Mitarbeiter-Kategorisierung mit Projektvolumen
-- ----------------------------------------------------------------------------
-- Erweitern Sie die Abfrage aus Aufgabe 9.2. Mitarbeiter aus Kategorie B 
-- sollen feiner unterteilt werden:
-- - Wenn sie an einem Projekt mit mehr als 100.000 Mitteln arbeiten => Kategorie B1
-- - Sonst => Kategorie B2
--
-- Erwartetes Ergebnis: 15 Zeilen
-- ============================================================================

PRINT '=== Aufgabe 9.3: Erweiterte Kategorisierung (B1 / B2) ===';

SELECT m.id,
       m.nachname,
       m.ort,
       a.bezeichnung,
       CASE
           WHEN m.ort IN ('Landshut', 'Rosenheim') THEN 'F'
           WHEN a.bezeichnung = 'Einkauf' THEN 'A'
           WHEN EXISTS (
               SELECT 1
               FROM Arbeit AS ar
               INNER JOIN Projekt AS p ON ar.pro_id = p.id
               WHERE ar.mit_id = m.id AND p.mittel > 100000.00
           ) THEN 'B1'
           ELSE 'B2'
       END AS kategorie
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;
GO

-- Alternative Variante 9.3: Flacher CASE-Ausdruck
SELECT m.id,
       m.nachname,
       m.ort,
       a.bezeichnung,
       CASE
           WHEN m.ort IN ('Landshut', 'Rosenheim') THEN 'F'
           WHEN a.bezeichnung = 'Einkauf' THEN 'A'
           WHEN EXISTS (
               SELECT 1
               FROM Arbeit AS ar
               INNER JOIN Projekt AS p ON ar.pro_id = p.id
               WHERE ar.mit_id = m.id AND p.mittel > 100000.00
           ) THEN 'B1'
           ELSE 'B2'
       END AS kategorie
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;
GO


-- ============================================================================
-- Aufgabe 9.4: Arbeiter-Klassifizierung nach Eintritts-Wochentag
-- ----------------------------------------------------------------------------
-- Kategorisieren Sie Arbeiter in Ihren Projekten.
-- - Wochenende (Samstag / Sonntag) => 'Arbeitstier'
-- - Montag oder Dienstag           => 'Fleissig'
-- - Rest                           => 'Faulenzer'
-- Nutzen Sie CASE und DATENAME(dw, <Datum>).
--
-- Erwartetes Ergebnis: 20 Zeilen
-- ============================================================================

PRINT '=== Aufgabe 9.4: Wochentags-Kategorisierung (DATENAME & CASE) ===';

SELECT a.einst_dat,
       DATENAME(dw, a.einst_dat) AS wochentag,
       CASE
           WHEN DATENAME(dw, a.einst_dat) IN ('Samstag', 'Sonntag') THEN 'Arbeitstier'
           WHEN DATENAME(dw, a.einst_dat) IN ('Montag', 'Dienstag') THEN 'Fleissig'
           ELSE 'Faulenzer'
       END AS kategorie
FROM Arbeit AS a;
GO

-- Alternative Variante 9.4: Sprachunabhängig mit DATEPART(weekday, ...) & @@DATEFIRST
SELECT a.einst_dat,
       DATENAME(dw, a.einst_dat) AS wochentag,
       CASE
           -- Bei SET DATEFIRST 1 (Montag=1, ..., Samstag=6, Sonntag=7)
           WHEN DATEPART(dw, a.einst_dat) IN (6, 7) THEN 'Arbeitstier'
           WHEN DATEPART(dw, a.einst_dat) IN (1, 2) THEN 'Fleissig'
           ELSE 'Faulenzer'
       END AS kategorie_sprachunabhaengig
FROM Arbeit AS a;
GO
