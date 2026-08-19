-- ============================================================================
-- Day 13: Wiederholung Teil 1 - Grundlagen, Filterung, LIKE & Sortierung
-- Datenbank: ProjektDB
-- Autor: Tobias Boyke
-- ============================================================================

USE ProjektDB;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.1
-- Finden Sie die Namen und Id aller Abteilungen, die in Ulm ihren Sitz haben.
-- ----------------------------------------------------------------------------
SELECT bezeichnung, id
FROM Abteilung
WHERE ort = 'Ulm';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.2
-- Nennen Sie die Vor- und Nachnamen aller Mitarbeiter,
-- deren Personalnummer größer oder gleich 23456 ist.
-- ----------------------------------------------------------------------------
SELECT vorname, nachname
FROM Mitarbeiter
WHERE id >= 23456;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.3
-- Gesucht werden Mitarbeiter-Id, Projektnummer und Aufgabe der Mitarbeiter, 
-- die in den Projekten 1, 2 oder 3 als Gruppenleiter tätig sind.
-- ----------------------------------------------------------------------------
SELECT mit_id, pro_id, aufgabe
FROM Arbeit
WHERE pro_id IN (1, 2, 3) 
  AND aufgabe = 'Gruppenleiter';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.4
-- Finden Sie die Id, den Umsatz und das Datum für alle Mitarbeiter, 
-- die im Jahr 2018 Umsätze von weniger als 1000 € hatten. 
-- Relevant sind die einzelnen Umsätze, nicht die Summe.
-- ----------------------------------------------------------------------------
SELECT mit_id, umsatz, datum
FROM Umsatz
WHERE YEAR(datum) = 2018 
  AND umsatz < 1000;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.5
-- Nennen Sie Personalnummer und Nachnamen der Mitarbeiter, 
-- die nicht in den Abteilungen 2, 3 und 4 arbeiten.
-- ----------------------------------------------------------------------------
SELECT id, nachname
FROM Mitarbeiter
WHERE abt_id NOT IN (2, 3, 4);
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.6
-- Finden Sie alle Mitarbeiter, deren Personalnummer 
-- entweder 29346, 28559 oder 25348 ist.
-- ----------------------------------------------------------------------------
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE id IN (29346, 28559, 25348);
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.7
-- Nennen Sie alle Mitarbeiter, deren Wohnort weder München noch Landshut ist.
-- ----------------------------------------------------------------------------
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE ort NOT IN ('München', 'Landshut');
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.8
-- Nennen Sie die Id der Mitarbeiter, die Projektleiter sind 
-- und vor oder nach 2018 in ihren Projekten eingestellt wurden.
-- ----------------------------------------------------------------------------
SELECT mit_id
FROM Arbeit
WHERE aufgabe = 'Projektleiter' 
  AND (YEAR(beginn) < 2018 OR YEAR(beginn) > 2018);
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.9
-- Finden Sie die Personal- und Projektnummer aller Mitarbeiter, 
-- die in den Projekten 1 oder 5 arbeiten und deren Aufgabe noch nicht festgelegt ist.
-- ----------------------------------------------------------------------------
SELECT mit_id, pro_id
FROM Arbeit
WHERE pro_id IN (1, 5) 
  AND aufgabe IS NULL;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.10
-- Geben Sie die Firmennamen aller Kunden aus. 
-- Sortieren Sie die Ausgabe aufsteigend nach dem Firmennamen.
-- ----------------------------------------------------------------------------
SELECT firma
FROM Kunde
ORDER BY firma ASC;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.11
-- Geben Sie alle Umsätze des Jahres 2019 sortiert nach der Id der Mitarbeiter aus. 
-- Bei gleicher Id soll nach Datum absteigend sortiert werden.
-- ----------------------------------------------------------------------------
SELECT id, mit_id, datum, umsatz
FROM Umsatz
WHERE YEAR(datum) = 2019
ORDER BY mit_id ASC, datum DESC;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.12
-- Gesucht werden Mitarbeiter-id, Projekt-Id und Aufgabe der Mitarbeiter, 
-- die entweder im Projekt 3 arbeiten, oder aber Gruppenleiter in einem beliebigen Projekt sind.
-- Sortieren Sie die Ausgabe nach der Projekt-Id und dann nach der Aufgabe.
-- ----------------------------------------------------------------------------
SELECT mit_id, pro_id, aufgabe
FROM Arbeit
WHERE pro_id = 3 OR aufgabe = 'Gruppenleiter'
ORDER BY pro_id ASC, aufgabe ASC;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.13
-- Finden Sie Namen und Personalnummer aller Mitarbeiter, 
-- deren Name mit dem Buchstaben "M" beginnt.
-- ----------------------------------------------------------------------------
SELECT nachname, id
FROM Mitarbeiter
WHERE nachname LIKE 'M%';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.14
-- Nennen Sie Namen, Vornamen und Id aller Mitarbeiter, 
-- deren Nachname als zweiten Buchstaben ein "u" hat.
-- ----------------------------------------------------------------------------
SELECT nachname, vorname, id
FROM Mitarbeiter
WHERE nachname LIKE '_u%';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.15
-- Nennen Sie Vor- und Nachname aller Mitarbeiter, deren  
-- Nachname nicht mit "er" und nicht mit "t" endet.
-- ----------------------------------------------------------------------------
SELECT vorname, nachname
FROM Mitarbeiter
WHERE nachname NOT LIKE '%er' 
  AND nachname NOT LIKE '%t';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.16
-- Wie kann man nach dem Unterstrich (_) oder dem Prozentzeichen (%) mit LIKE suchen?
-- Finden Sie alle Kunden, in deren Datensatz ein solches Sonderzeichen vorkommt.
-- ----------------------------------------------------------------------------
SELECT firma, ort
FROM Kunde
WHERE firma LIKE '%[%]%' 
   OR ort LIKE '%[_]%'
   OR firma LIKE '%[_]%' 
   OR ort LIKE '%[%]%';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.17
-- Nennen Sie alle Mitarbeiter, deren Nachname mindestens drei Vokale enthält.
-- ----------------------------------------------------------------------------
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE nachname LIKE '%[aeiou]%[aeiou]%[aeiou]%';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.18
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau fünf Buchstaben besteht.
-- ----------------------------------------------------------------------------
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE vorname LIKE '_____';
-- Alternative: WHERE LEN(vorname) = 5;
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.19
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau sechs Buchstaben besteht 
-- und deren Vorname nicht mit einem Vokal endet.
-- ----------------------------------------------------------------------------
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE vorname LIKE '_____[^aeiou]';
-- Alternative: WHERE LEN(vorname) = 6 AND vorname NOT LIKE '%[aeiou]';
GO

-- ----------------------------------------------------------------------------
-- Aufgabe 20.20
-- Finden Sie alle Mitarbeiter, bei deren Nachname der vorletzte Buchstabe kein Vokal ist.
-- ----------------------------------------------------------------------------
SELECT id, nachname, vorname, abt_id, ort, chef_id
FROM Mitarbeiter
WHERE nachname LIKE '%[^aeiou]_';
GO
