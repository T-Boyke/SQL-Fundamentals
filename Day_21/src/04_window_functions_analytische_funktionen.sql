-- ============================================================================
-- SQL-Fundamentals: Day 21 - Fortgeschrittene T-SQL Techniken
-- Datei: 04_window_functions_analytische_funktionen.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 31.08.2026
-- Fokus: Analytische Fensterfunktionen (Ranking, Aggregation, Offset, Frames)
-- Datenbank: ProjektDB (SoT)
-- ============================================================================

-- ============================================================================
-- THEORIE: Analytische Fensterfunktionen (Window Functions)
-- ----------------------------------------------------------------------------
-- Fensterfunktionen berechnen Werte über ein Subset von Zeilen ("Fenster"),
-- OHNE dass die Zeilen wie bei GROUP BY zu einer einzigen Ergebniszeile
-- kollabieren. Jede Eingabezeile bleibt im Ergebnis vollständig erhalten!
--
-- Anatomie der OVER()-Klausel:
--   FUNCTION() OVER (
--       [PARTITION BY spalte1, spalte2]  -- Unterteilung der Datenmenge
--       [ORDER BY spalte3 ASC|DESC]       -- Sortierung innerhalb des Fensters
--       [ROWS BETWEEN <start> AND <end>]  -- Fensterrahmen (Frame-Spezifikation)
--   )
--
-- 1. Ranking-Funktionen:
--    - ROW_NUMBER(): Fortlaufende 1, 2, 3, 4 (ohne Gleichstand)
--    - RANK(): Rangfolge mit Lücken bei Gleichstand (1, 2, 2, 4)
--    - DENSE_RANK(): Rangfolge OHNE Lücken bei Gleichstand (1, 2, 2, 3)
--    - NTILE(n): Teilt das Fenster in n gleich große Buckets/Quantile
--
-- 2. Aggregierende Fensterfunktionen:
--    - SUM(), AVG(), MIN(), MAX(), COUNT() über Partitionen
--    - Kumulierte Summen (Running Totals) mittels Frame-Spezifikation:
--      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--
-- 3. Offset- & Navigationsfunktionen:
--    - LAG(spalte, offset): Wert der vorherigen Zeile
--    - LEAD(spalte, offset): Wert der nächsten Zeile
--    - FIRST_VALUE(spalte): Erster Wert im Fenster
--    - LAST_VALUE(spalte): Letzter Wert im Fenster (Achtung: Default-Frame!)
--
-- 4. Benannte Fenster (T-SQL WINDOW Clause):
--    - WINDOW W1 AS (PARTITION BY ... ORDER BY ...)
-- ============================================================================

USE master;
GO

USE ProjektDB;
GO


-- ============================================================================
-- 1. Ranking Window Functions: Gehalts- und Umsatzhierarchien
-- ============================================================================

PRINT '--- 1.1 Gehalts-Rangfolgen (ROW_NUMBER vs RANK vs DENSE_RANK vs NTILE) ---';
SELECT g.mit_id,
       m.nachname,
       g.gehalt,
       ROW_NUMBER() OVER(ORDER BY g.gehalt DESC) AS rnk_row_number,
       RANK()       OVER(ORDER BY g.gehalt DESC) AS rnk_rank,
       DENSE_RANK() OVER(ORDER BY g.gehalt DESC) AS rnk_dense_rank,
       NTILE(4)     OVER(ORDER BY g.gehalt DESC) AS gehalt_quartil
FROM Gehalt AS g
INNER JOIN Mitarbeiter AS m ON g.mit_id = m.id
ORDER BY g.gehalt DESC;
GO

PRINT '--- 1.2 Umsatz-Rangfolge pro Mitarbeiter (Partitionierung) ---';
SELECT u.id,
       u.mit_id,
       m.nachname,
       u.datum,
       u.umsatz,
       RANK() OVER(PARTITION BY u.mit_id ORDER BY u.datum) AS chronologische_nr_ma,
       RANK() OVER(ORDER BY u.datum) AS chronologische_nr_gesamt
FROM Umsatz AS u
INNER JOIN Mitarbeiter AS m ON u.mit_id = m.id
ORDER BY u.datum;
GO


-- ============================================================================
-- 2. Aggregierende Fensterfunktionen & Frame-Definitionen
-- ============================================================================

PRINT '--- 2.1 Aggregation ohne Zeilenverlust & Prozentualer Anteil ---';
SELECT u.id,
       u.mit_id,
       m.nachname,
       u.datum,
       u.umsatz,
       SUM(u.umsatz) OVER(PARTITION BY u.mit_id) AS mitarbeiter_gesamtumsatz,
       MIN(u.umsatz) OVER(PARTITION BY u.mit_id) AS mitarbeiter_min_umsatz,
       SUM(u.umsatz) OVER()                      AS unternehmen_gesamtumsatz,
       CAST(u.umsatz * 100.0 / SUM(u.umsatz) OVER(PARTITION BY u.mit_id) AS DECIMAL(5, 2)) AS prozent_an_ma_umsatz,
       CAST(u.umsatz * 100.0 / SUM(u.umsatz) OVER() AS DECIMAL(5, 2)) AS prozent_an_unternehmensumsatz
FROM Umsatz AS u
INNER JOIN Mitarbeiter AS m ON u.mit_id = m.id
ORDER BY u.mit_id, u.datum;
GO

PRINT '--- 2.2 Kumulierte Summen (Running Totals: ASC und DESC) ---';
SELECT u.id,
       u.mit_id,
       m.nachname,
       u.datum,
       u.umsatz,
       -- Kumulierte Summe vom ersten Eintrag bis zur aktuellen Zeile:
       SUM(u.umsatz) OVER(
           PARTITION BY u.mit_id 
           ORDER BY u.datum, u.id
           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS kumulierter_umsatz_asc,
       -- Verbleibende Restsumme von der aktuellen Zeile bis zum Ende:
       SUM(u.umsatz) OVER(
           PARTITION BY u.mit_id 
           ORDER BY u.datum, u.id
           ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
       ) AS verbleibender_umsatz_desc
FROM Umsatz AS u
INNER JOIN Mitarbeiter AS m ON u.mit_id = m.id
ORDER BY u.mit_id, u.datum, u.id;
GO


-- ============================================================================
-- 3. Offset- und Navigationsfunktionen (LAG, LEAD, FIRST/LAST_VALUE)
-- ============================================================================

PRINT '--- 3.1 Zeilensprünge mit LAG und LEAD (Umsatzvergleich zum Vorgänger) ---';
SELECT u.mit_id,
       m.nachname,
       u.datum,
       u.umsatz,
       LAG(u.umsatz, 1, 0.00) OVER(PARTITION BY u.mit_id ORDER BY u.datum) AS vorheriger_umsatz,
       u.umsatz - LAG(u.umsatz, 1, u.umsatz) OVER(PARTITION BY u.mit_id ORDER BY u.datum) AS differenz_zum_vorgaenger,
       LEAD(u.umsatz, 1) OVER(PARTITION BY u.mit_id ORDER BY u.datum) AS naechster_umsatz
FROM Umsatz AS u
INNER JOIN Mitarbeiter AS m ON u.mit_id = m.id
ORDER BY u.mit_id, u.datum;
GO

PRINT '--- 3.2 FIRST_VALUE, LAST_VALUE und die T-SQL WINDOW-Klausel ---';
SELECT m.id,
       m.vorname,
       m.nachname,
       m.ort,
       FIRST_VALUE(m.nachname) OVER W_ORT AS erster_nachname_im_ort,
       -- Wichtig: Ohne Frame-Erweiterung liefert LAST_VALUE nur die aktuelle Zeile!
       LAST_VALUE(m.nachname) OVER(
           W_ORT 
           ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
       ) AS letzter_nachname_im_ort
FROM Mitarbeiter AS m
WINDOW W_ORT AS (PARTITION BY m.ort ORDER BY m.nachname)
ORDER BY m.ort, m.nachname;
GO
