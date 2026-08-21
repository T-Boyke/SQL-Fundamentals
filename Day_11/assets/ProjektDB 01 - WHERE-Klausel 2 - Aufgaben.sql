-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


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



-- Aufgabe 1.10
--
-- Nennen Sie Namen und Mittel aller Projekte, deren 
-- finanzielle Mittel zwischen 95.000 und 120.000 EURO liegen.
--
--      bezeichnung  mittel
--      Apollo       120000,00
--      Gemini       95000,00



-- Aufgabe 1.11
--
-- Nennen Sie die Id der Mitarbeiter, die Projektleiter sind 
-- und vor oder nach 2018 in ihren Projekten eingestellt wurden.
--
--      mit_id
--      2581
--      22222



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



-- Aufgabe 1.13
--
-- Finden Sie die Id und die Aufgabe aller Mitarbeiter,
-- die im Projekt 5 arbeiten, aber nicht Sachbearbeiter sind.
--
--      mit_id  aufgabe
--      17000   NULL
--      22222   Projektleiter


