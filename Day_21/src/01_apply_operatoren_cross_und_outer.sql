-- ============================================================================
-- SQL-Fundamentals: Day 21 - Fortgeschrittene T-SQL Techniken
-- Datei: 01_apply_operatoren_cross_und_outer.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 31.08.2026
-- Fokus: CROSS APPLY & OUTER APPLY (Korrelierte Tabellenausdrücke)
-- Datenbanken: WeitereBeispiele & ProjektDB (SoT)
-- ============================================================================

-- ============================================================================
-- THEORIE: Der APPLY-Operator in T-SQL
-- ----------------------------------------------------------------------------
-- Der APPLY-Operator führt einen Tabellenausdruck (Subquery oder TVF) für
-- JEDE Zeile der linken Tabelle individuell aus (zeilenweise Korrelation).
--
-- 1. CROSS APPLY:
--    - Gibt nur Zeilen der linken Tabelle zurück, für die der rechte
--      Tabellenausdruck mindestens eine Ergebniszeile liefert.
--    - Entspricht der Semantik eines INNER JOIN.
--
-- 2. OUTER APPLY:
--    - Gibt ALLE Zeilen der linken Tabelle zurück.
--    - Liefert der rechte Tabellenausdruck keine Zeile, werden die Spalten
--      mit NULL aufgefüllt.
--    - Entspricht der Semantik eines LEFT OUTER JOIN.
--
-- Hauptanwendungsfälle:
--    a) "Top-N pro Gruppe" Abfragen (z.B. neuester Eintrag, höchster Wert).
--    b) Dynamischer Aufruf von Inline Table-Valued Functions (TVF) mit
--       Spaltenwerten der äußeren Abfrage als Parameter.
--    c) Berechnungen / String-Splitting pro Datensatz.
-- ============================================================================


-- ============================================================================
-- TEIL 1: WeitereBeispiele (Person & Fahrzeug)
-- ============================================================================

USE WeitereBeispiele;
GO

-- ----------------------------------------------------------------------------
-- Szenario: Person mit dem jeweils neuesten Fahrzeug (höchstes Baujahr)
-- ----------------------------------------------------------------------------

PRINT '--- 1.1 Lösung mit 2x LEFT JOIN (Self-Anti-Join / Höchstwert) ---';
SELECT p.PersID,
       p.Name,
       f.FzgID,
       f.Modell,
       f.Baujahr
FROM Person AS p
LEFT JOIN Fahrzeug AS f 
    ON p.PersID = f.PersID
LEFT JOIN Fahrzeug AS f2 
    ON p.PersID = f2.PersID 
    AND f.Baujahr < f2.Baujahr
WHERE f2.FzgID IS NULL;
GO

PRINT '--- 1.2 Elegante Lösung mit OUTER APPLY (Top 1 pro Person) ---';
-- Bei Mary (kein Auto) liefert der Subquery 0 Zeilen -> OUTER APPLY behält Mary mit NULLs
SELECT p.PersID,
       p.Name,
       a.FzgID,
       a.Modell,
       a.Baujahr
FROM Person AS p
OUTER APPLY
(
    SELECT TOP (1) 
           f.FzgID,
           f.Modell,
           f.Baujahr
    FROM Fahrzeug AS f
    WHERE f.PersID = p.PersID
    ORDER BY f.Baujahr DESC
) AS a;
GO

PRINT '--- 1.3 Lösung mit CROSS APPLY (Nur Personen mit Fahrzeug) ---';
-- Mary wird hier herausgefiltert, da kein Fahrzeug existiert
SELECT p.PersID,
       p.Name,
       a.FzgID,
       a.Modell,
       a.Baujahr
FROM Person AS p
CROSS APPLY
(
    SELECT TOP (1) 
           f.FzgID,
           f.Modell,
           f.Baujahr
    FROM Fahrzeug AS f
    WHERE f.PersID = p.PersID
    ORDER BY f.Baujahr DESC
) AS a;
GO


-- ============================================================================
-- TEIL 2: Single Source of Truth (ProjektDB)
-- ============================================================================

USE ProjektDB;
GO

-- ----------------------------------------------------------------------------
-- Szenario: Alle Mitarbeiter und dazu der Datensatz mit dem höchsten Einzelumsatz
-- ----------------------------------------------------------------------------

PRINT '--- 2.1 Höchster Mitarbeiterumsatz mit CROSS APPLY ---';
SELECT m.id AS mitarbeiter_id,
       m.vorname,
       m.nachname,
       m.ort,
       a.id AS umsatz_id,
       a.datum AS umsatz_datum,
       a.umsatz AS hoechster_umsatz
FROM Mitarbeiter AS m
CROSS APPLY
(
    SELECT TOP (1) 
           u.id,
           u.datum,
           u.umsatz
    FROM Umsatz AS u
    WHERE u.mit_id = m.id
    ORDER BY u.umsatz DESC, u.datum DESC
) AS a
ORDER BY a.umsatz DESC;
GO

PRINT '--- 2.2 Alle Mitarbeiter (inkl. ohne Umsatz) mit OUTER APPLY ---';
SELECT m.id AS mitarbeiter_id,
       m.vorname,
       m.nachname,
       COALESCE(a.umsatz, 0.00) AS hoechster_umsatz,
       a.datum AS umsatz_datum
FROM Mitarbeiter AS m
OUTER APPLY
(
    SELECT TOP (1) 
           u.datum,
           u.umsatz
    FROM Umsatz AS u
    WHERE u.mit_id = m.id
    ORDER BY u.umsatz DESC, u.datum DESC
) AS a
ORDER BY hoechster_umsatz DESC;
GO

PRINT '--- 2.3 Vergleich: Gleiche Logik mit 2x LEFT JOIN ---';
SELECT m.id AS mitarbeiter_id,
       m.vorname,
       m.nachname,
       u1.id AS umsatz_id,
       u1.datum AS umsatz_datum,
       u1.umsatz AS hoechster_umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u1 
    ON m.id = u1.mit_id
LEFT JOIN Umsatz AS u2 
    ON m.id = u2.mit_id 
    AND (u1.umsatz < u2.umsatz 
         OR (u1.umsatz = u2.umsatz AND u1.datum < u2.datum))
WHERE u2.id IS NULL
ORDER BY u1.umsatz DESC;
GO

PRINT '--- 2.4 Top-2 Umsätze pro Mitarbeiter mit CROSS APPLY ---';
-- Zeigt die Stärke von APPLY: Top-N Abfragen sind trivial konfigurierbar
SELECT m.nachname,
       a.datum,
       a.umsatz
FROM Mitarbeiter AS m
CROSS APPLY
(
    SELECT TOP (2) 
           u.datum,
           u.umsatz
    FROM Umsatz AS u
    WHERE u.mit_id = m.id
    ORDER BY u.umsatz DESC
) AS a
ORDER BY m.nachname ASC, a.umsatz DESC;
GO
