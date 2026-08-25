-- ============================================================================
-- 📅 Day_17: OUTER JOINs (Teil 2) - Aggregationen, Nullwert-Handling & Multi-Joins
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 25.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 TEIL 1: OUTER JOIN & Aggregationen (SUM, COUNT, MIN, MAX)
-- ============================================================================

-- 1.1 Einzelzeilen-Darstellung (1:n Multiplikation mit ISNULL-Ersatz)
-- Ein Mitarbeiter mit 10 Umsätzen erzeugt 10 Zeilen.
-- Mitarbeiter ohne Umsatz erhalten 1 Zeile mit '0.00'.
SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz,
       u.datum
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
ORDER BY m.id ASC;
GO

-- 1.2 Aggregation mit SUM() und Nullwert-Behandlung
-- ⚠️ ACHTUNG: SUM(NULL) ergibt NULL! Daher muss ISNULL um das SUM() gewickelt werden.
SELECT m.id,
       m.nachname,
       ISNULL(SUM(u.umsatz), 0.00) AS gesamtumsatz,
       COUNT(u.id) AS anzahl_umsaetze
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
ORDER BY gesamtumsatz DESC;
GO

-- 1.3 Datums-Aggregation mit MIN() und MAX()
-- MIN/MAX über NULL-Werte liefern NULL (keine Verfälschung durch Ersatzdaten).
SELECT m.id,
       m.nachname,
       MIN(u.datum) AS erster_umsatz,
       MAX(u.datum) AS letzter_umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname;
GO

-- ============================================================================
-- 📝 TEIL 2: Die Dreiwertige Logik (3VL) in der HAVING-Klausel
-- ============================================================================

-- ⚠️ DAS PROBLEM: Wir suchen Mitarbeiter mit weniger als 100.000 € Umsatz.
-- Mitarbeiter OHNE Umsatz haben SUM(u.umsatz) = NULL.
-- In SQL ist 'NULL < 100000' UNKNOWN (wird im HAVING wie FALSE behandelt).

-- ❌ FALSCH: Filtert alle Mitarbeiter mit 0 Umsätzen versehentlich heraus! (Nur 2 Zeilen)
SELECT m.id, m.nachname, SUM(u.umsatz) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
HAVING SUM(u.umsatz) < 100000;
GO

-- ✅ RICHTIG (Variante A): Nullwert vor dem Vergleich durch ISNULL abfangen (13 Zeilen)
SELECT m.id, m.nachname, ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
HAVING ISNULL(SUM(u.umsatz), 0.00) < 100000;
GO

-- ✅ RICHTIG (Variante B): Explizites Prüfen auf IS NULL im HAVING (13 Zeilen)
SELECT m.id, m.nachname, ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
HAVING SUM(u.umsatz) < 100000 
    OR SUM(u.umsatz) IS NULL;
GO

-- ============================================================================
-- 📝 TEIL 3: Filterung auf die linke Tabelle (WHERE) vs. rechte Tabelle (ON)
-- ============================================================================

-- Szenario: Zeige alle Mitarbeiter der Abteilung 2 und deren Umsätze.
-- Da der Filter auf die linke Tabelle (m.abt_id = 2) wirkt, MUSS er ins WHERE!
SELECT m.id, m.nachname, m.abt_id,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
WHERE m.abt_id = 2;
GO

-- ============================================================================
-- 📝 TEIL 4: Multi-Table OUTER JOIN mit Rollen-Filterung (Projektleiter)
-- ============================================================================

-- Szenario: Alle 15 Mitarbeiter auflisten. Wenn jemand Projektleiter ist, 
-- soll der Projektname genannt werden, sonst '- k. A. -'.

-- ❌ FALSCH: Bedingung im WHERE macht den LEFT JOIN zum INNER JOIN
-- (Liefert nur noch die 3 Projektleiter, alle 12 anderen Mitarbeiter fliegen raus!)
SELECT m.id, m.nachname, p.bezeichnung AS projekt
FROM Mitarbeiter AS m
LEFT JOIN Arbeit AS arb ON m.id = arb.mit_id
LEFT JOIN Projekt AS p ON arb.pro_id = p.id
WHERE arb.aufgabe = 'Projektleiter';
GO

-- ✅ RICHTIG: Bedingung in der ON-Klausel des LEFT JOINs
-- Filtert nur die Zeilen der Arbeit-Tabelle vor dem Joinen.
-- Alle 15 Mitarbeiter bleiben vollständig erhalten!
SELECT m.id,
       m.nachname,
       ISNULL(p.bezeichnung, '- k. A. -') AS projekt
FROM Mitarbeiter AS m
LEFT JOIN Arbeit AS arb ON m.id = arb.mit_id 
                       AND arb.aufgabe = 'Projektleiter'
LEFT JOIN Projekt AS p ON arb.pro_id = p.id
ORDER BY m.id ASC;
GO

-- ============================================================================
-- 📝 TEIL 5: Nullwert-Funktionen im direkten Vergleich
-- ============================================================================

-- Vergleich: ISNULL (T-SQL) vs. COALESCE (ANSI-SQL) vs. CASE WHEN
-- noqa: disable=ST02
SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz_isnull,
       COALESCE(u.umsatz, 0.00) AS umsatz_coalesce,
       CASE 
           WHEN u.umsatz IS NOT NULL THEN u.umsatz 
           ELSE 0.00 
       END AS umsatz_case
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id;
-- noqa: enable=ST02
GO
