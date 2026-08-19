-- ============================================================================
-- Day 13: Wiederholung Teil 2 - Aggregatfunktionen, Gruppierung & HAVING
-- Datenbank: ProjektDB
-- Autor: Tobias Boyke
-- ============================================================================

USE ProjektDB;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.1
-- Nennen Sie die kleinste Personalnummer der Mitarbeiter.
-- ----------------------------------------------------------------------------
SELECT MIN(id) AS minimum
FROM Mitarbeiter;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.2
-- Berechnen Sie die Summe aller Gehälter der Mitarbeiter.
-- ----------------------------------------------------------------------------
SELECT SUM(gehalt) AS summe
FROM Gehalt;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.3
-- Berechnen Sie den arithmetischen Mittelwert der Projekt-Mittel, 
-- die kleiner als 100.000 Euro sind.
-- ----------------------------------------------------------------------------
SELECT AVG(mittel) AS durchschnitt
FROM Projekt
WHERE mittel < 100000;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.4
-- Ermitteln Sie den kleinsten Umsatz, der je erzielt wurde.
-- ----------------------------------------------------------------------------
SELECT MIN(umsatz) AS umsatz
FROM Umsatz;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.5
-- Finden Sie heraus, in wie vielen verschiedenen Projekten die 
-- einzelnen Aufgaben ausgeübt werden. Nullwerte sollen nicht berücksichtigt werden!
-- ----------------------------------------------------------------------------
SELECT aufgabe, COUNT(DISTINCT pro_id) AS anzahl
FROM Arbeit
WHERE aufgabe IS NOT NULL
GROUP BY aufgabe;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.6
-- Finden Sie heraus, wieviele Mitarbeiter in jedem Projekt arbeiten.
-- ----------------------------------------------------------------------------
SELECT pro_id, COUNT(mit_id) AS anzahl
FROM Arbeit
GROUP BY pro_id;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.7
-- Gruppieren Sie die Reihen der Tabelle Arbeit nach den 
-- vorhandenen Aufgaben und zählen Sie die Anzahl der unterschiedlichen Mitarbeiter je Aufgabe.
-- ----------------------------------------------------------------------------
SELECT aufgabe, COUNT(DISTINCT mit_id) AS anzahl
FROM Arbeit
GROUP BY aufgabe;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.8
-- Wie viele "echte" Aufgaben nehmen die Mitarbeiter wahr, deren Id kleiner als 20000 ist?
-- ----------------------------------------------------------------------------
SELECT mit_id, COUNT(aufgabe) AS anzahl
FROM Arbeit
WHERE mit_id < 20000
GROUP BY mit_id;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.9
-- Nennen Sie alle Projekte (pro_id), mit denen weniger als vier Mitarbeiter befasst sind.
-- ----------------------------------------------------------------------------
SELECT pro_id, COUNT(mit_id) AS mitarbeiter
FROM Arbeit
GROUP BY pro_id
HAVING COUNT(mit_id) < 4;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.10
-- Finden Sie alle Mitarbeiter, die in mehr als einem Projekt arbeiten.
-- ----------------------------------------------------------------------------
SELECT mit_id, COUNT(pro_id) AS projekte
FROM Arbeit
GROUP BY mit_id
HAVING COUNT(pro_id) > 1;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.11
-- Ermitteln Sie die Tage, an denen mehr als 50.000 € Umsatz generiert wurde.
-- ----------------------------------------------------------------------------
SELECT datum, SUM(umsatz) AS umsatz
FROM Umsatz
GROUP BY datum
HAVING SUM(umsatz) > 50000;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 21.12
-- Ermitteln Sie, welche Gehälter jeweils nur von genau einem Mitarbeiter bezogen werden.
-- ----------------------------------------------------------------------------
SELECT gehalt, COUNT(mit_id) AS mitarbeiter
FROM Gehalt
GROUP BY gehalt
HAVING COUNT(mit_id) = 1;
GO
