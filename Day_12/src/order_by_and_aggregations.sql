-- ============================================================================
-- 📅 Day_12: ORDER BY, Aggregatfunktionen & Gruppierung
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 18.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 TEIL 1: Experimente & Unterrichtsbeispiele
-- ============================================================================

-- 1.1 Grundlagen ORDER BY (Sortierung auf- und absteigend)
-- Standardmäßig wird aufsteigend (ASC) sortiert.
SELECT abt_id, CONCAT(vorname, ' ', nachname) AS name
FROM Mitarbeiter
ORDER BY abt_id DESC, name ASC;

-- 1.2 Begrenzung mit TOP (Anzahl oder Prozent)
-- TOP ohne ORDER BY liefert unvorhersehbare Datensätze. Daher immer mit ORDER BY nutzen!
SELECT TOP (2) *
FROM Mitarbeiter
ORDER BY id;

-- TOP mit Prozentangabe (z. B. die obersten 35.37% der Zeilen)
SELECT TOP (35.37) PERCENT *
FROM Mitarbeiter
ORDER BY id;

-- 1.3 Gleichstände mit WITH TIES behandeln
-- Falls die nachfolgenden Zeilen den gleichen Wert im ORDER BY haben wie die letzte 
-- zugelassene Zeile, werden diese ebenfalls ausgegeben.
SELECT TOP (3) WITH TIES *
FROM Mitarbeiter
ORDER BY abt_id;

-- 1.4 Handling von NULL-Werten beim Sortieren (T-SQL / MS SQL Server)
-- Standardmäßig gelten NULL-Werte als die kleinsten Werte (stehen bei ASC ganz oben).
-- So sortiert man das Gehalt absteigend, schiebt Mitarbeiter ohne Gehalt (NULL) aber ans Ende:
SELECT vorname, nachname, gehalt
FROM Mitarbeiter
ORDER BY 
    CASE WHEN gehalt IS NULL THEN 1 ELSE 0 END ASC, 
    gehalt DESC;

-- 1.5 CONCAT im SELECT und WHERE
-- Im WHERE kann der Spaltenalias (name) nicht verwendet werden, da WHERE vor SELECT ausgeführt wird.
-- Im ORDER BY kann der Spaltenalias verwendet werden, da ORDER BY nach SELECT ausgeführt wird.
SELECT CONCAT(vorname, ' ', nachname) AS name, abt_id
FROM Mitarbeiter
WHERE CONCAT(vorname, ' ', nachname) LIKE '%Müller%'
ORDER BY name ASC;

-- Performantere Alternative ohne CONCAT im WHERE:
SELECT CONCAT(vorname, ' ', nachname) AS name
FROM Mitarbeiter
WHERE nachname = 'Müller' AND vorname = 'Max';

-- 1.6 Aggregatfunktionen ohne Gruppierung
-- Aggregatfunktionen (COUNT, MIN, MAX, AVG, SUM) fassen Werte einer Spalte zusammen.
SELECT COUNT(*) AS anzahl FROM Kunde;
SELECT COUNT(*) FROM Kunde WHERE ort LIKE '%e%';
SELECT COUNT(*) AS alle, COUNT(aufgabe) AS aufgaben, COUNT(DISTINCT aufgabe) AS einmal FROM Arbeit;
SELECT MIN(gehalt) AS min_gehalt, MAX(gehalt) AS max_gehalt, AVG(gehalt) AS avg_gehalt, SUM(gehalt) AS sum_gehalt FROM Gehalt;

-- 1.7 GROUP BY & HAVING (Die Gruppierung)
-- Goldene Regel: Alle Spalten im SELECT, die keine Rechenfunktion haben, müssen im GROUP BY stehen!
SELECT mit_id, SUM(umsatz) AS gesamtumsatz
FROM Umsatz
GROUP BY mit_id;

-- Umgang mit NULL-Werten in der Gruppierungsspalte und in den Summen (ISNULL bzw. COALESCE)
SELECT 
    ISNULL(mit_id, 0) AS mitarbeiter, 
    ISNULL(SUM(umsatz), 0) AS gesamtumsatz
FROM Umsatz
GROUP BY mit_id;

-- HAVING filtert fertige Gruppen (nach GROUP BY), während WHERE einzelne Zeilen vorab filtert.
SELECT mit_id, SUM(umsatz) AS gesamt
FROM Umsatz
GROUP BY mit_id
HAVING SUM(umsatz) > 50000;

-- 1.8 STRING_AGG (Namen in eine Zeile komprimieren)
-- Wenn man nach abt_id gruppieren und die Mitarbeiter-Namen kommagetrennt anzeigen möchte:
SELECT 
    abt_id, 
    COUNT(*) AS anzahl,
    STRING_AGG(CONCAT(vorname, ' ', nachname), ', ') AS mitarbeiter_namen
FROM Mitarbeiter
GROUP BY abt_id;
GO


-- ============================================================================
-- 📝 TEIL 2: Offizielle Übungsaufgaben (Kapitel 3 & 4)
-- ============================================================================

-- ============================================================================
-- ORDER BY (Aufgaben 3.1 - 3.7)
-- ============================================================================

-- Aufgabe 3.1
-- Geben Sie die Firmennamen aller Kunden aus. Sortieren Sie die Ausgabe aufsteigend nach dem Firmennamen.
SELECT firma
FROM Kunde
ORDER BY firma ASC;

-- Aufgabe 3.2
-- Geben Sie alle Umsätze des Jahres 2019 sortiert nach Datum aus. 
-- Bei gleichem Datum sollen die größeren Umsätze zuerst genannt werden.
SELECT id, mit_id, datum, umsatz
FROM Umsatz
WHERE YEAR(datum) = 2019
ORDER BY datum ASC, umsatz DESC;

-- Aufgabe 3.3
-- Geben Sie alle Daten der Mitarbeiter aus. Sortieren Sie die Ausgabe nach Abteilungs-Nr. aufsteigend. 
-- Innerhalb der Abteilung sollen die Mitarbeiter ohne bekannten Wohnort am Ende stehen.
SELECT *
FROM Mitarbeiter
ORDER BY abt_id ASC, IIF(ort IS NULL, 1, 0) ASC, ort ASC;
-- Alternativ mit CASE WHEN (Standard-T-SQL):
-- ORDER BY abt_id ASC, (CASE WHEN ort IS NULL THEN 1 ELSE 0 END) ASC, ort ASC;

-- Aufgabe 3.4
-- Geben Sie die Id und die Aufgabe von allen Mitarbeitern aus, die Projektleiter sind. 
-- Sortieren Sie die Ausgabe nach der Mitarbeiter-Id.
SELECT mit_id, aufgabe
FROM Arbeit
WHERE aufgabe = 'Projektleiter'
ORDER BY mit_id ASC;

-- Aufgabe 3.5
-- Gesucht werden Mitarbeiter-id, Projekt-Id und Aufgabe der Mitarbeiter, 
-- die entweder im Projekt 2 arbeiten, oder aber Projektleiter in einem beliebigen Projekt sind.
-- Sortieren Sie die Ausgabe nach der Projekt-Id und dann nach der Aufgabe.
SELECT mit_id, pro_id, aufgabe
FROM Arbeit
WHERE pro_id = 2 OR aufgabe = 'Projektleiter'
ORDER BY pro_id ASC, aufgabe ASC;

-- Aufgabe 3.6
-- Selektieren Sie die drei größten Umsätze, die im Jahr 2018 gemacht wurden.
SELECT TOP (3) *
FROM Umsatz
WHERE YEAR(datum) = 2018
ORDER BY umsatz DESC;

-- Aufgabe 3.7
-- Selektieren Sie erneut die drei größten Umsätze aus dem Jahr 2018. 
-- Verwenden Sie diesmal zusätzlich die Klausel WITH TIES.
SELECT TOP (3) WITH TIES *
FROM Umsatz
WHERE YEAR(datum) = 2018
ORDER BY umsatz DESC;
GO


-- ============================================================================
-- Aggregatfunktionen (Aufgaben 4.3 - 4.6)
-- ============================================================================

-- Aufgabe 4.3
-- Nennen Sie die kleinste Personalnummer der Mitarbeiter.
SELECT MIN(id) AS minimum
FROM Mitarbeiter;

-- Aufgabe 4.4
-- Berechnen Sie die Summe der finanziellen Mittel aller Projekte.
SELECT SUM(mittel) AS summe
FROM Projekt;

-- Aufgabe 4.5
-- Berechnen Sie den arithmetischen Mittelwert der Geldbeträge, die höher als 92336,10 Euro sind.
SELECT AVG(mittel) AS durchschnitt
FROM Projekt
WHERE mittel > 92336.1;

-- Aufgabe 4.6
-- Ermitteln Sie den höchsten, einzelnen Umsatz, der bisher erzielt wurde.
SELECT MAX(umsatz) AS umsatz
FROM Umsatz;
GO


-- ============================================================================
-- Aggregatfunktionen mit Gruppierung (Aufgaben 4.7 - 4.11)
-- ============================================================================

-- Aufgabe 4.7
-- Finden Sie heraus, wie viele verschiedene Aufgaben in jedem Projekt ausgeübt werden. 
-- Nullwerte sollen nicht gezählt werden!
SELECT pro_id, COUNT(DISTINCT aufgabe) AS anzahl
FROM Arbeit
GROUP BY pro_id;

-- Aufgabe 4.8
-- Finden Sie heraus, wieviele Mitarbeiter in jedem Projekt arbeiten.
SELECT pro_id, COUNT(mit_id) AS anzahl
FROM Arbeit
GROUP BY pro_id;

-- Aufgabe 4.9
-- Gruppieren Sie die Reihen der Tabelle "Arbeit" nach den vorhandenen Aufgaben 
-- und zählen Sie die Anzahl der Mitarbeiter abhängig von der jeweiligen Aufgabe.
SELECT aufgabe, COUNT(*) AS anzahl
FROM Arbeit
GROUP BY aufgabe
ORDER BY aufgabe;

-- Aufgabe 4.10
-- Wie viele "echte" Aufgaben nehmen die Mitarbeiter wahr, deren Id größer als 20000 ist?
SELECT mit_id, COUNT(aufgabe) AS anzahl
FROM Arbeit
WHERE mit_id > 20000
GROUP BY mit_id
ORDER BY mit_id;

-- Aufgabe 4.11
-- Zählen Sie, wie viele Mitarbeiter in jedem Jahr für mindestens ein Projekt eingestellt wurden.
SELECT YEAR(eintritt) AS Jahr, COUNT(id) AS Anzahl
FROM Mitarbeiter
WHERE id IN (SELECT DISTINCT Arbeit.mit_id FROM Arbeit)
GROUP BY YEAR(eintritt);
GO
