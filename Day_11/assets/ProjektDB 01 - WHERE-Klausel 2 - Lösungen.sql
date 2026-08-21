-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:
USE ProjektDB;

-- =====
-- WHERE
-- =====

-- Aufgabe 1.8
--
-- Finden Sie alle Mitarbeiter, deren Personalnummer 
-- entweder 29346, 28559 oder 25348 ist.
--
--      id     nachname  vorname  abt_id  ort       chef_id
--      25348  Keller    Hans     3       München   2581
--      28559  Mozer     Sibille  1       Ulm       2581
--      29346  Probst    Andreas  2       Augsburg  2581

SELECT *
FROM Mitarbeiter
WHERE id IN (29346, 28559,25348);

-- Aufgabe 1.9
--
-- Nennen Sie alle Mitarbeiter, deren Wohnort 
-- weder München noch Ulm ist.
--
--      id     nachname  vorname   abt_id  ort         chef_id
--      5765   Schäfer   Sabine    3       Landshut    2581
--      9912   Wolf      Klaus     4       Heidenheim  22222
--      10102  Huber     Petra     3       Landshut    2581
--      18316  Müller    Gabriele  1       Rosenheim   2581
--      20204  Fuchs     Dirk      4       Fürth       22222
--      29346  Probst    Andreas   2       Augsburg    2581

SELECT *
FROM Mitarbeiter
WHERE ort NOT IN ('München', 'Ulm');

-- Aufgabe 1.10
--
-- Nennen Sie Namen und Mittel aller Projekte, deren 
-- finanzielle Mittel zwischen 95.000 und 120.000 EURO liegen.
--
--      bezeichnung  mittel
--      Apollo       120000,00
--      Gemini       95000,00

SELECT bezeichnung, mittel
FROM Projekt
WHERE mittel BETWEEN 95000 AND 120000;

-- Aufgabe 1.11
--
-- Nennen Sie die Id der Mitarbeiter, die Projektleiter sind 
-- und vor oder nach 2018 in ihren Projekten eingestellt wurden.
--
--      mit_id
--      2581
--      22222

SELECT mit_id
FROM Arbeit
WHERE aufgabe = 'Projektleiter'
	--AND YEAR(einst_dat) <> 2018;
	--AND einst_dat NOT BETWEEN '20180101' AND '20181231';
	AND (einst_dat < '20180101' OR einst_dat > '20181231');

-- Aufgabe 1.12
--
-- Finden Sie die Personal- und Projektnummer aller Mitarbeiter, 
-- die in den Projekten 1 oder 5 arbeiten und deren Aufgabe noch 
-- nicht festgelegt ist.
--
--      mit_id  pro_id
--      17000   1
--      17000   5
--      28559   1

SELECT mit_id, pro_id
FROM Arbeit
WHERE pro_id IN (1, 5) AND aufgabe IS NULL;

-- Aufgabe 1.13
--
-- Finden Sie die Id und die Aufgabe aller Mitarbeiter,
-- die im Projekt 5 arbeiten, aber nicht Sachbearbeiter sind.
--
--      mit_id  aufgabe
--      17000   NULL
--      22222   Projektleiter

SELECT mit_id, aufgabe
FROM Arbeit
WHERE pro_id = 5 AND (aufgabe <> 'Sachbearbeiter' OR aufgabe IS NULL);
