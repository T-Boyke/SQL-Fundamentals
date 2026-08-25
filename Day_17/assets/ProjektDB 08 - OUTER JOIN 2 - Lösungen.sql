-- ============================================================================
-- 📅 Day_17: ProjektDB 08 - OUTER JOIN 2 - Lösungen
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 25.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- Aufgabe 8.9
-- Zeigen Sie alle Mitarbeiter mit Id und nachname an
-- und geben Sie dazu die vom Mitarbeiter getätigten
-- Umsätze aus. Hat der Mitarbeiter noch keine Umsätze
-- getätigt, soll in der Spalte Umsatz 0 angezeigt werden.
--
-- Erwartetes Ergebnis:
-- id     nachname  umsatz
-- 2581   Kaufmann  100000,00
-- 5765   Schäfer   0,00
-- 9031   Meier     0,00
-- 9912   Wolf      0,00
-- 10102  Huber     500,00
-- 10102  Huber     500,00
-- ...
-- (36 Zeilen)
-- ============================================================================

SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id;
GO

-- ============================================================================
-- Aufgabe 8.10
-- Überarbeiten Sie die Abfrage aus Aufgabe 8.9.
-- Zeigen Sie diesmal nur die Mitarbeiter an, die
-- noch keine Umsätze getätigt haben.
--
-- Erwartetes Ergebnis:
-- id     nachname  umsatz
-- 5765   Schäfer   0,00
-- 9031   Meier     0,00
-- 9912   Wolf      0,00
-- 12121  Richter   0,00
-- 18316  Müller    0,00
-- 20204  Fuchs     0,00
-- ...
-- (11 Zeilen)
-- ============================================================================

SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
WHERE u.id IS NULL;
GO

-- ============================================================================
-- Aufgabe 8.11
-- Überarbeiten Sie die Abfrage aus Aufgabe 8.9.
-- Gruppieren Sie über die Mitarbeiter und geben 
-- Sie statt der einzelnen Umsätze die Summe der
-- Umsätze für jeden Mitarbeiter aus. Fehlende
-- Umsätze sollen weiterhin mit 0 angezeigt werden.
--
-- Erwartetes Ergebnis:
-- id     nachname  umsatz
-- 2581   Kaufmann  100000,00
-- 5765   Schäfer   0,00
-- 9031   Meier     0,00
-- 9912   Wolf      0,00
-- 10102  Huber     18000,00
-- 12121  Richter   0,00
-- ...
-- (15 Zeilen)
-- ============================================================================

SELECT m.id,
       m.nachname,
       ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname;
GO

-- ============================================================================
-- Aufgabe 8.12
-- Überarbeiten Sie die Abfrage aus Aufgabe 8.11.
-- Zeigen Sie nur die Mitarbeiter an, die weniger
-- als 100000 Umsatz erreicht haben.
--
-- Erwartetes Ergebnis:
-- id     nachname  umsatz
-- 5765   Schäfer   0,00
-- 9031   Meier     0,00
-- 9912   Wolf      0,00
-- 10102  Huber     18000,00
-- 12121  Richter   0,00
-- 17000  Krüger    20000,00
-- ...
-- (13 Zeilen)
-- ============================================================================

-- Variante 1 (⭐ Empfohlen: Mit ISNULL im HAVING gegen die 3VL NULL-Falle):
SELECT m.id,
       m.nachname,
       ISNULL(SUM(u.umsatz), 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname
HAVING ISNULL(SUM(u.umsatz), 0.00) < 100000;
GO

-- Variante 2 (Explizites OR IS NULL):
-- SELECT m.id,
--        m.nachname,
--        ISNULL(SUM(u.umsatz), 0.00) AS umsatz
-- FROM Mitarbeiter AS m
-- LEFT JOIN Umsatz AS u ON m.id = u.mit_id
-- GROUP BY m.id, m.nachname
-- HAVING SUM(u.umsatz) < 100000 OR SUM(u.umsatz) IS NULL;
-- GO

-- ============================================================================
-- Aufgabe 8.13
-- Zeigen Sie alle Mitarbeiter der Abteilung 2 mit Id
-- und Nachname an und geben Sie dazu die vom Mitarbeiter 
-- getätigten Umsätze aus. Hat der Mitarbeiter noch keine 
-- Umsätze getätigt, soll in der Spalte Umsatz eine 0 
-- angezeigt werden.
--
-- Erwartetes Ergebnis:
-- id     nachname  umsatz
-- 2581   Kaufmann  100000,00
-- 9031   Meier     0,00
-- 29346  Probst    0,00
-- ============================================================================

SELECT m.id,
       m.nachname,
       ISNULL(u.umsatz, 0.00) AS umsatz
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
WHERE m.abt_id = 2;
GO

-- ============================================================================
-- Aufgabe 8.14
-- Zeigen Sie alle Mitarbeiter mit Id und Nachname an
-- und geben Sie dazu aus, an welchem Tag der Mitarbeiter
-- zum ersten Mal einen Umsatz erzielt hat und wann er
-- zum letzten Mal einen Umsatz erzielt hat.
--
-- Erwartetes Ergebnis:
-- id     nachname  erster      letzter
-- 2581   Kaufmann  2019-05-01  2019-05-01
-- 5765   Schäfer   NULL        NULL
-- 9031   Meier     NULL        NULL
-- 9912   Wolf      NULL        NULL
-- 10102  Huber     2018-10-01  2019-01-01
-- 12121  Richter   NULL        NULL
-- ...
-- (15 Zeilen)
-- ============================================================================

SELECT m.id,
       m.nachname,
       MIN(u.datum) AS erster,
       MAX(u.datum) AS letzter
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
GROUP BY m.id, m.nachname;
GO

-- ============================================================================
-- Aufgabe 8.15
-- Listen Sie alle Mitarbeiter mit m_nr und m_name
-- auf. Zusätzlich soll das Projekt genannt werden,
-- in dem der Mitarbeiter Projektleiter ist. Sollte 
-- es kein passendes Projekt geben, soll '- k. A. -'
-- statt des Projektnamens angezeigt werden.
--
-- Erwartetes Ergebnis:
-- id     nachname  projekt
-- 2581   Kaufmann  Merkur
-- 5765   Schäfer   Pluto
-- 9031   Meier     - k. A. -
-- 9912   Wolf      - k. A. -
-- 10102  Huber     Apollo
-- 12121  Richter   - k. A. -
-- ...
-- (15 Zeilen)
-- ============================================================================

SELECT m.id,
       m.nachname,
       ISNULL(p.bezeichnung, '- k. A. -') AS projekt
FROM Mitarbeiter AS m
LEFT JOIN Arbeit AS arb ON m.id = arb.mit_id 
                       AND arb.aufgabe = 'Projektleiter'
LEFT JOIN Projekt AS p ON arb.pro_id = p.id;
GO
