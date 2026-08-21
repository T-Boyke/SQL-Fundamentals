-- ============================================================================
-- 📅 Day_11: DQL-Grundlagen, WHERE-Klausel & Pattern Matching (LIKE)
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 17.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 TEIL 1: Experimente & Vorlesungsbeispiele (2026-08-17)
-- ============================================================================

-- 1.1 SELECT-Klausel: Berechnungen und Aliase (ohne FROM)
SELECT 'abc' AS spalte1, 5 * 5 AS spalte2;

-- 1.2 SELECT mit FROM und Spaltenauswahl
SELECT firma, ort 
FROM Kunde;

-- 1.3 Alle Spalten abfragen (Sternchen-Operator)
SELECT * 
FROM Kunde;

-- 1.4 String-Funktionen und Berechnungen im SELECT
SELECT CONCAT(vorname, ' ', nachname) AS name
FROM Mitarbeiter;

-- 1.5 Duplikate entfernen mit DISTINCT
SELECT DISTINCT ort
FROM Mitarbeiter;

-- 1.6 Filtern mit der WHERE-Klausel (Vergleichsoperatoren)
SELECT *
FROM Kunde
WHERE ort = 'Ulm';

-- 1.7 Mehrere Bedingungen mit logischem AND verknüpfen
SELECT *
FROM Mitarbeiter
WHERE abt_id = 4 AND ort = 'München';

-- 1.8 Logische Rangfolge: NOT hat Vorrang vor AND, AND hat Vorrang vor OR!
-- Tipp: Immer explizit mit Klammern arbeiten, um Logikfehler zu vermeiden.

-- 1.9 Der NULL-Wert und die Dreiwertige Logik (Three-Valued Logic)
-- WICHTIG: Jeder relationale Vergleich mit NULL ergibt UNKNOWN (weder TRUE noch FALSE)!
-- Daher liefert die folgende Abfrage KEINE Zeilen:
-- SELECT * FROM Mitarbeiter WHERE ort = NULL; -- FEHLERHAFT!

-- Korrekte Syntax für NULL-Prüfungen:
SELECT *
FROM Mitarbeiter
WHERE ort IS NULL;

SELECT *
FROM Mitarbeiter
WHERE ort IS NOT NULL;

-- 1.10 Bereichs- und Mengenoperatoren (BETWEEN und IN)
SELECT *
FROM Mitarbeiter
WHERE id BETWEEN 9000 AND 10000;

SELECT *
FROM Mitarbeiter
WHERE ort IN ('Ulm', 'Fürth');

-- 1.11 Pattern Matching mit LIKE & Wildcards
-- Wildcard %: Beliebige Zeichenkette beliebiger Länge (auch 0 Zeichen)
SELECT *
FROM Mitarbeiter
WHERE nachname LIKE 'S%'; -- Beginnt mit S

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE 'S%e'; -- Beginnt mit S und endet auf e

-- Wildcard _: Genau ein beliebiges Zeichen
SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '_a%'; -- Zweiter Buchstabe ist a

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '_a%n_'; -- Zweiter Buchstabe a, vorletzter Buchstabe n

-- Zeichenklasse [abc]: Genau ein Zeichen aus der angegebenen Menge
SELECT *
FROM Mitarbeiter
WHERE ort LIKE '[AF]%'; -- Ort beginnt mit A oder F

-- Negierte Zeichenklasse [^abc]: Genau ein Zeichen, das NICHT in der Menge liegt
-- Hinweis: Negierte Zeichenklassen filtern NULL-Werte automatisch heraus!
SELECT *
FROM Mitarbeiter
WHERE ort LIKE '[^AF]%';

-- Zeichenbereich [0-9] bzw. [A-Z]: Zeichen aus einem alphanumerischen Bereich
SELECT *
FROM Mitarbeiter
WHERE nachname LIKE '[T-Z]%';

SELECT *
FROM Mitarbeiter
WHERE nachname LIKE '%[^M-Z]';

-- Sonderzeichen maskieren: [%] oder [_]
SELECT *
FROM Kunde
WHERE firma LIKE '%[%]%';

GO

-- ============================================================================
-- 📂 TEIL 2: Aufgabenreihe ProjektDB 01 - WHERE-Klausel 1 (Aufgaben 1.1 – 1.7)
-- ============================================================================

-- Aufgabe 1.1
-- Finden Sie die Namen und Id aller Abteilungen, die in München ihren Sitz haben.
SELECT bezeichnung, id
FROM Abteilung
WHERE ort = 'München';

-- Aufgabe 1.2
-- Nennen Sie die Vor- und Nachnamen aller Mitarbeiter, deren Personalnummer >= 20000 ist.
SELECT vorname, nachname
FROM Mitarbeiter
WHERE id >= 20000;

-- Aufgabe 1.3
-- Finden Sie alle Projekte, deren Finanzmittel mehr als 129.960,01 $ betragen.
-- Der fiktive Umrechnungskurs liegt bei 1,083 $ für 1 Euro.
SELECT id, kuerzel, bezeichnung, mittel, kunde_id
FROM Projekt
WHERE mittel * 1.083 > 129960.01;

-- Aufgabe 1.4
-- Gesucht werden Mitarbeiter-Id, Projektnummer und Aufgabe der Mitarbeiter, 
-- die im Projekt 2 Sachbearbeiter sind.
SELECT mit_id, pro_id, aufgabe
FROM Arbeit
WHERE pro_id = 2 AND aufgabe = 'Sachbearbeiter';

-- Aufgabe 1.5
-- Finden Sie Id, Umsatz und Datum für alle Mitarbeiter, die im Jahr 2018 
-- Umsätze von mindestens 5000 € hatten.
SELECT mit_id, umsatz, datum
FROM Umsatz
WHERE umsatz >= 5000 
  AND YEAR(datum) = 2018;

-- Aufgabe 1.6
-- Gesucht wird einmalig die Personalnummer der Mitarbeiter, 
-- die entweder im Projekt 1 oder 5 oder in beiden arbeiten.
SELECT DISTINCT mit_id
FROM Arbeit
WHERE pro_id IN (1, 5);

-- Aufgabe 1.7
-- Nennen Sie Personalnummer und Nachnamen der Mitarbeiter, 
-- die nicht in den Abteilungen 2, 3 und 4 arbeiten.
SELECT id, nachname
FROM Mitarbeiter
WHERE abt_id NOT IN (2, 3, 4) OR abt_id IS NULL;

GO

-- ============================================================================
-- 📂 TEIL 3: Aufgabenreihe ProjektDB 01 - WHERE-Klausel 2 (Aufgaben 1.8 – 1.13)
-- ============================================================================

-- Aufgabe 1.8
-- Finden Sie alle Mitarbeiter, deren Personalnummer entweder 29346, 28559 oder 25348 ist.
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE id IN (29346, 28559, 25348);

-- Aufgabe 1.9
-- Nennen Sie alle Mitarbeiter, deren Wohnort weder München noch Ulm ist.
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE ort NOT IN ('München', 'Ulm');

-- Aufgabe 1.10
-- Nennen Sie Namen und Mittel aller Projekte, deren finanzielle Mittel zwischen 
-- 95.000 und 120.000 EURO liegen.
SELECT bezeichnung, mittel
FROM Projekt
WHERE mittel BETWEEN 95000 AND 120000;

-- Aufgabe 1.11
-- Nennen Sie die Id der Mitarbeiter, die Projektleiter sind und vor oder nach 2018 
-- in ihren Projekten eingestellt wurden.
SELECT mit_id
FROM Arbeit
WHERE aufgabe = 'Projektleiter'
  AND (einst_dat < '2018-01-01' OR einst_dat > '2018-12-31');

-- Aufgabe 1.12
-- Finden Sie Personal- und Projektnummer aller Mitarbeiter, die in den Projekten 1 oder 5 
-- arbeiten und deren Aufgabe noch nicht festgelegt ist (NULL).
SELECT mit_id, pro_id
FROM Arbeit
WHERE pro_id IN (1, 5) 
  AND aufgabe IS NULL;

-- Aufgabe 1.13
-- Finden Sie Id und Aufgabe aller Mitarbeiter, die im Projekt 5 arbeiten, 
-- aber nicht Sachbearbeiter sind.
SELECT mit_id, aufgabe
FROM Arbeit
WHERE pro_id = 5 
  AND (aufgabe <> 'Sachbearbeiter' OR aufgabe IS NULL);

GO

-- ============================================================================
-- 📂 TEIL 4: Aufgabenreihe ProjektDB 02 - LIKE-Operator (Aufgaben 3.1 – 3.10)
-- ============================================================================

-- Aufgabe 3.1
-- Finden Sie Namen und Personalnummer aller Mitarbeiter, deren Name mit dem Buchstaben "K" beginnt.
SELECT nachname, id
FROM Mitarbeiter
WHERE nachname LIKE 'K%';

-- Aufgabe 3.2
-- Nennen Sie Namen, Vornamen und Id aller Mitarbeiter, deren Vorname als 2. Buchstaben ein "a" hat.
SELECT nachname, vorname, id
FROM Mitarbeiter
WHERE vorname LIKE '_a%';

-- Aufgabe 3.3
-- Finden Sie Abteilungs-Id und Standort aller Abteilungen, die sich an Orten befinden, 
-- die mit einem Buchstaben zwischen "N" und "Z" beginnen.
SELECT id, ort
FROM Abteilung
WHERE ort LIKE '[N-Z]%';

-- Aufgabe 3.4
-- Finden Sie Id, Nachnamen und Vornamen aller Mitarbeiter, deren Name nicht mit K-P beginnt 
-- und deren Vorname nicht mit U beginnt.
SELECT id, nachname, vorname
FROM Mitarbeiter
WHERE nachname LIKE '[^K-P]%' 
  AND vorname NOT LIKE 'U%';

-- Aufgabe 3.5
-- Nennen Sie Vor- und Nachname aller Mitarbeiter, deren Name nicht mit "er" endet.
SELECT vorname, nachname
FROM Mitarbeiter
WHERE nachname NOT LIKE '%er';

-- Aufgabe 3.6
-- Finden Sie alle Kunden, in deren Datensatz Sonderzeichen (_ oder %) vorkommen.
SELECT firma, ort
FROM Kunde
WHERE firma LIKE '%[%_]%' 
   OR ort LIKE '%[%_[]%';

-- Aufgabe 3.7
-- Nennen Sie alle Mitarbeiter, deren Vorname mindestens drei Vokale enthält.
SELECT id, vorname, nachname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE vorname LIKE '%[aeiou]%[aeiou]%[aeiou]%';

-- Aufgabe 3.8
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau sieben Buchstaben besteht.
SELECT id, vorname, nachname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE vorname LIKE '_______';

-- Aufgabe 3.9
-- Finden Sie alle Mitarbeiter mit genau 6 Buchstaben im Vornamen, der NICHT mit einem Vokal endet.
SELECT id, vorname, nachname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE vorname LIKE '_____[^aeiou]';

-- Aufgabe 3.10
-- Finden Sie alle Mitarbeiter, bei deren Vorname der vorletzte Buchstabe ein Vokal ist.
SELECT id, vorname, nachname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE vorname LIKE '%[aeiou]_';

GO
