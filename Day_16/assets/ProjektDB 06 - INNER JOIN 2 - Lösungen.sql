-- ============================================================================
-- 📅 Day_16: ProjektDB 06 - INNER JOIN 2 - Lösungen
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 24.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- Aufgabe 6.9
-- Nennen Sie einmalig die Namen der Projekte, in denen die 
-- Mitarbeiter arbeiten, die ein Gehalt von mindestens 5.000 € beziehen.
--
-- Erwartetes Ergebnis:
-- bezeichnung
-- Apollo
-- Ariane
-- Gemini
-- ============================================================================

SELECT DISTINCT p.bezeichnung
FROM Projekt AS p
INNER JOIN Arbeit AS arb ON p.id = arb.pro_id
INNER JOIN Gehalt AS g ON arb.mit_id = g.mit_id
WHERE g.gehalt >= 5000;
GO

-- ============================================================================
-- Aufgabe 6.10
-- Erstellen Sie das Kartesische Produkt auf Mitarbeiter- und Abteilungs-Tabelle
--
-- Erwartetes Ergebnis:
-- id     nachname  vorname   abt_id  ort         chef_id  id  kuerzel  bezeichnung  ort
-- 2581   Kaufmann  Brigitte  2       NULL        NULL     1   BE       Beratung     München
-- ...
-- (75 Zeilen: 15 Mitarbeiter * 5 Abteilungen)
-- ============================================================================

-- Moderne SQL-92 Syntax (Expliziter CROSS JOIN):
SELECT m.id, m.nachname, m.vorname, m.abt_id, m.ort, m.chef_id,
       a.id AS abt_tabelle_id, a.kuerzel, a.bezeichnung, a.ort AS abt_ort
FROM Mitarbeiter AS m
CROSS JOIN Abteilung AS a;
GO

-- ============================================================================
-- Aufgabe 6.11
-- Finden Sie alle Mitarbeiter und dazu alle Abteilungen, in denen 
-- diese Mitarbeiter NICHT arbeiten.
--
-- Erwartetes Ergebnis:
-- id     nachname  vorname   abt_id  ort         chef_id  id  kuerzel  bezeichnung  ort
-- 2581   Kaufmann  Brigitte  2       NULL        NULL     1   BE       Beratung     München
-- ...
-- (60 Zeilen: 75 Zeilen Kartesisches Produkt minus 15 tatsächliche Zuordnungen)
-- ============================================================================

-- Variante 1 (⭐ Best Practice - SQL-92 CROSS JOIN mit WHERE-Filter):
SELECT m.id, m.nachname, m.vorname, m.abt_id, m.ort, m.chef_id,
       a.id AS abt_tabelle_id, a.kuerzel, a.bezeichnung, a.ort AS abt_ort
FROM Mitarbeiter AS m
CROSS JOIN Abteilung AS a
WHERE m.abt_id <> a.id;
GO

-- Variante 2 (SQL-92 INNER JOIN als Theta-Join über Ungleichheit):
SELECT m.id, m.nachname, m.vorname, m.abt_id, m.ort, m.chef_id,
       a.id AS abt_tabelle_id, a.kuerzel, a.bezeichnung, a.ort AS abt_ort
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id <> a.id;
GO

-- Variante 3 (Veraltete SQL-89 Syntax mit Komma-Trennung):
SELECT m.id, m.nachname, m.vorname, m.abt_id, m.ort, m.chef_id,
       a.id AS abt_tabelle_id, a.kuerzel, a.bezeichnung, a.ort AS abt_ort
FROM Mitarbeiter AS m, Abteilung AS a
WHERE m.abt_id <> a.id;
GO

-- ============================================================================
-- Aufgabe 6.12
-- Nennen Sie die Abteilungsnamen der Mitarbeiter, die 
-- am 01.01.2019 eingestellt wurden.
--
-- Erwartetes Ergebnis:
-- bezeichnung
-- Freigabe
-- Einkauf
-- ============================================================================

SELECT DISTINCT a.bezeichnung
FROM Abteilung AS a
INNER JOIN Mitarbeiter AS m ON a.id = m.abt_id
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
WHERE arb.einst_dat = '2019-01-01';
GO

-- ============================================================================
-- Aufgabe 6.13
-- Nennen Sie Namen und Vornamen aller Projektleiter, deren 
-- Abteilung den Standort Stuttgart hat.
--
-- Erwartetes Ergebnis:
-- nachname  vorname
-- Schäfer   Sabine
-- Huber     Petra
-- ============================================================================

SELECT DISTINCT m.nachname, m.vorname
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
WHERE arb.aufgabe = 'Projektleiter'
  AND a.ort = 'Stuttgart';
GO

-- ============================================================================
-- Aufgabe 6.14
-- Nennen Sie einmalig die Namen der Projekte, in denen 
-- Mitarbeiter arbeiten, die zur Abteilung Beratung gehören.
--
-- Erwartetes Ergebnis:
-- bezeichnung
-- Apollo
-- Gemini
-- ============================================================================

SELECT DISTINCT p.bezeichnung
FROM Projekt AS p
INNER JOIN Arbeit AS arb ON p.id = arb.pro_id
INNER JOIN Mitarbeiter AS m ON arb.mit_id = m.id
INNER JOIN Abteilung AS a ON m.abt_id = a.id
WHERE a.bezeichnung = 'Beratung';
GO

-- ============================================================================
-- Aufgabe 6.15
-- Nennen Sie die Kunden, an deren Projekten Mitarbeiter
-- arbeiten, die mindestens 5.000 € Gehalt bekommen. Nennen
-- Sie zu den Kunden auch die Anzahl dieser Mitarbeiter.
--
-- Erwartetes Ergebnis:
-- firma                    mitarbeiter
-- Finanzamt Ulm            2
-- Frankreich-Reisen GmbH   2
-- Technische Produkte oHG  1
-- ============================================================================

SELECT k.firma,
       COUNT(DISTINCT arb.mit_id) AS mitarbeiter
FROM Kunde AS k
INNER JOIN Projekt AS p ON k.id = p.kunde_id
INNER JOIN Arbeit AS arb ON p.id = arb.pro_id
INNER JOIN Gehalt AS g ON arb.mit_id = g.mit_id
WHERE g.gehalt >= 5000
GROUP BY k.firma
ORDER BY k.firma ASC;
GO
