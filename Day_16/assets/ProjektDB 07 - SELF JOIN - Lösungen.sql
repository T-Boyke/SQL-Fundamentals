-- ============================================================================
-- 📅 Day_16: ProjektDB 07 - SELF JOIN - Lösungen
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 24.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- Aufgabe 7.1
-- Finden Sie alle Abteilungen, an deren Standorten 
-- sich weitere Abteilungen befinden. Geben Sie jeweils
-- die Ids, Namen und Städte der Abteilungen aus.
--
-- Erwartetes Ergebnis:
-- id  bezeichnung  ort      id  bezeichnung  ort
-- 1   Beratung     München  1   Beratung     München
-- 2   Diagnose     München  1   Beratung     München
-- 4   Einkauf      München  1   Beratung     München
-- 1   Beratung     München  2   Diagnose     München
-- 2   Diagnose     München  2   Diagnose     München
-- 4   Einkauf      München  2   Diagnose     München
-- ...
-- (11 Zeilen: München 3*3=9, Stuttgart 1*1=1, Ulm 1*1=1)
-- ============================================================================

SELECT a1.id, a1.bezeichnung, a1.ort,
       a2.id AS abt2_id, a2.bezeichnung AS abt2_bezeichnung, a2.ort AS abt2_ort
FROM Abteilung AS a1
INNER JOIN Abteilung AS a2 ON a1.ort = a2.ort;
GO

-- ============================================================================
-- Aufgabe 7.2
-- Überarbeiten Sie die Abfrage aus Aufgabe 7.1.
-- Diesmal sollen nur Zeilen ins Ergebnis übernommen 
-- werden, bei denen die Abteilungen sich unterscheiden.
--
-- Erwartetes Ergebnis:
-- id  bezeichnung  ort      id  bezeichnung  ort
-- 1   Beratung     München  2   Diagnose     München
-- 1   Beratung     München  4   Einkauf      München
-- 2   Diagnose     München  1   Beratung     München
-- 2   Diagnose     München  4   Einkauf      München
-- 4   Einkauf      München  1   Beratung     München
-- 4   Einkauf      München  2   Diagnose     München
-- (6 Zeilen)
-- ============================================================================

SELECT a1.id, a1.bezeichnung, a1.ort,
       a2.id AS abt2_id, a2.bezeichnung AS abt2_bezeichnung, a2.ort AS abt2_ort
FROM Abteilung AS a1
INNER JOIN Abteilung AS a2 ON a1.ort = a2.ort
WHERE a1.id <> a2.id;
GO

-- ============================================================================
-- Aufgabe 7.3
-- Überarbeiten Sie die Abfrage aus Aufgabe 7.2.
-- Diesmal soll jede Kombination nur einmal angezeigt 
-- werden. D.h. A-B ist das gleiche wie B-A.
--
-- Erwartetes Ergebnis:
-- id  bezeichnung  ort      id  bezeichnung  ort
-- 2   Diagnose     München  1   Beratung     München
-- 4   Einkauf      München  1   Beratung     München
-- 4   Einkauf      München  2   Diagnose     München
-- (3 Zeilen)
-- ============================================================================

SELECT a1.id, a1.bezeichnung, a1.ort,
       a2.id AS abt2_id, a2.bezeichnung AS abt2_bezeichnung, a2.ort AS abt2_ort
FROM Abteilung AS a1
INNER JOIN Abteilung AS a2 ON a1.ort = a2.ort 
                          AND a1.id > a2.id;
GO

-- ============================================================================
-- Aufgabe 7.4
-- Finden Sie heraus, ob es Mitarbeiter gibt, die einen 
-- Kollegen oder eine Kollegin aus derselben Abteilung 
-- in ihrem Wohnort haben (Stichwort Fahrgemeinschaft).
--
-- Erwartetes Ergebnis:
-- id     abt_id  nachname  ort
-- 5765   3       Schäfer   Landshut
-- 10102  3       Huber     Landshut
-- 12121  4       Richter   München
-- 22222  4       Vogel     München
-- ============================================================================

SELECT DISTINCT m1.id, m1.abt_id, m1.nachname, m1.ort
FROM Mitarbeiter AS m1
INNER JOIN Mitarbeiter AS m2 ON m1.abt_id = m2.abt_id
                            AND m1.ort = m2.ort
                            AND m1.id <> m2.id
WHERE m1.ort IS NOT NULL
ORDER BY m1.id ASC;
GO

-- ============================================================================
-- Aufgabe 7.5
-- Geben Sie die Mitarbeiter-Id, die Projektnummer und 
-- die Aufgabe der Mitarbeiter aus, die im gleichen 
-- Projekt die gleiche Aufgabe ausführen. Sortieren Sie
-- die Ausgabe ggf. sinnvoll.
--
-- Erwartetes Ergebnis:
-- mit_id  pro_id  aufgabe
-- 25348   2       Sachbearbeiter
-- 28559   2       Sachbearbeiter
-- 20204   4       Sachbearbeiter
-- 27365   4       Sachbearbeiter
-- ============================================================================

SELECT DISTINCT a1.mit_id, a1.pro_id, a1.aufgabe
FROM Arbeit AS a1
INNER JOIN Arbeit AS a2 ON a1.pro_id = a2.pro_id
                       AND a1.aufgabe = a2.aufgabe
                       AND a1.mit_id <> a2.mit_id
WHERE a1.aufgabe IS NOT NULL
ORDER BY a1.pro_id ASC, a1.mit_id ASC;
GO

-- ============================================================================
-- Aufgabe 7.6
-- Ermitteln Sie die Mitarbeiter mit Id, Vorname, Nachname
-- und dem Nachnamen des Vorgesetzten.
-- 
-- Erwartetes Ergebnis:
-- id     vorname   nachname  chef
-- 5765   Sabine    Schäfer   Kaufmann
-- 9031   Rainer    Meier     Kaufmann
-- 9912   Klaus     Wolf      Vogel
-- 10102  Petra     Huber     Kaufmann
-- 12121  Ursula    Richter   Vogel
-- ...
-- (15 Zeilen)
-- ============================================================================

SELECT m.id, m.vorname, m.nachname, c.nachname AS chef
FROM Mitarbeiter AS m
LEFT JOIN Mitarbeiter AS c ON m.chef_id = c.id
ORDER BY m.id ASC;
GO

-- ============================================================================
-- Aufgabe 7.7
-- Finden Sie die Abteilungen, in denen die beiden Vorgesetzten
-- Mitarbeiter arbeiten
--
-- Erwartetes Ergebnis:
-- id  kuerzel  bezeichnung  ort
-- 2   DI       Diagnose     München
-- 4   EK       Einkauf      München
-- ============================================================================

-- Variante 1: Über SELF JOIN (Mitarbeiter mit Chef verknüpft)
SELECT DISTINCT a.id, a.kuerzel, a.bezeichnung, a.ort
FROM Abteilung AS a
INNER JOIN Mitarbeiter AS chef ON a.id = chef.abt_id
INNER JOIN Mitarbeiter AS mit ON mit.chef_id = chef.id
ORDER BY a.id ASC;
GO

-- ============================================================================
-- Aufgabe 7.8
-- Ermitteln Sie, welche Mitarbeiter in der gleichen
-- Stadt wohnen wie ihre Vorgesetzten.
--
-- Erwartetes Ergebnis:
-- vorname  nachname  ort      chef_ort
-- Ursula   Richter   München  München
-- Rolf     Schubert  München  München
-- ============================================================================

SELECT m.vorname, m.nachname, m.ort, c.ort AS chef_ort
FROM Mitarbeiter AS m
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id
WHERE m.ort = c.ort
  AND m.ort IS NOT NULL;
GO

-- ============================================================================
-- Aufgabe 7.9
-- Ermitteln Sie, welche Mitarbeiter im gleichen Projekt
-- arbeiten wie ihre Vorgesetzten.
--
-- Erwartetes Ergebnis:
-- nachname  pro_id  chef_name  chef_pro_id
-- Huber     3       Kaufmann   3
-- Meier     3       Kaufmann   3
-- Krüger    5       Vogel      5
-- Wolf      5       Vogel      5
-- ============================================================================

SELECT m.nachname,
       am.pro_id,
       c.nachname AS chef_name,
       ac.pro_id AS chef_pro_id
FROM Mitarbeiter AS m
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id
INNER JOIN Arbeit AS am ON m.id = am.mit_id
INNER JOIN Arbeit AS ac ON c.id = ac.mit_id 
                       AND am.pro_id = ac.pro_id
ORDER BY c.nachname ASC, m.nachname ASC;
GO
