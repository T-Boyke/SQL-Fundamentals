-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- Aufgabe 20.1
--
-- Finden Sie die Namen und Id aller Abteilungen, 
-- die in Ulm ihren Sitz haben.
--
--      bezeichnung  id
--      Verkauf      5



-- Aufgabe 20.2
--
-- Nennen Sie die Vor- und Nachnamen aller Mitarbeiter,
-- deren Personalnummer größer oder gleich 23456 ist.
--
--      vorname  nachname
--      Rolf     Schubert
--      Hans     Keller
--      Lena     Albrecht
--      Sibille  Mozer
--      Andreas  Probst



-- Aufgabe 20.3
--
-- Gesucht werden Mitarbeiter-Id, Projektnummer und Aufgabe 
-- der Mitarbeiter, die in den Projekten 1, 2 oder 3 als
-- Gruppenleiter tätig sind.
--
--      mit_id  pro_id  aufgabe
--      9031    1       Gruppenleiter
--      10102   3       Gruppenleiter



-- Aufgabe 20.4
--
-- Finden Sie die Id, den Umsatz und das Datum für alle 
-- Mitarbeiter, die im Jahr 2018 Umsätze von weniger als 
-- 1000 € hatten. Relevant sind die einzelnen Umsätze,
-- nicht die Summe.
--
--      mit_id  umsatz  datum
--      10102   500,00  2018-10-01
--      10102   500,00  2018-10-02
--      10102   500,00  2018-11-01
--      10102   500,00  2018-11-02
--      10102   500,00  2018-12-09
--      10102   500,00  2018-12-10
--      10102   500,00  2018-12-28



-- Aufgabe 20.5
--
-- Nennen Sie Personalnummer und Nachnamen der Mitarbeiter, 
-- die nicht in den Abteilungen 2, 3 und 4 arbeiten.
--
--      id     nachname
--      17000  Krüger
--      18316  Müller
--      24321  Schubert
--      27365  Albrecht
--      28559  Mozer



-- Aufgabe 20.6
--
-- Finden Sie alle Mitarbeiter, deren Personalnummer 
-- entweder 29346, 28559 oder 25348 ist.
--
--      id     nachname  vorname  abt_id  ort       chef_id
--      25348  Keller    Hans     3       München   2581
--      28559  Mozer     Sibille  1       Ulm       2581
--      29346  Probst    Andreas  2       Augsburg  2581



-- Aufgabe 20.7
--
-- Nennen Sie alle Mitarbeiter, deren Wohnort 
-- weder München noch Landshut ist.
--
--      id     nachname  vorname   abt_id   ort       chef_id
--      9912   Wolf      Klaus     4        Heidenheim  22222
--      17000  Krüger    Martin    5        Ulm         22222
--      18316  Müller    Gabriele  1        Rosenheim   2581
--      20204  Fuchs     Dirk      4        Fürth       22222
--      28559  Mozer     Sibille   1        Ulm         2581
--      29346  Probst    Andreas   2        Augsburg    2581



-- Aufgabe 20.8
--
-- Nennen Sie die Id der Mitarbeiter, die Projektleiter sind 
-- und vor oder nach 2018 in ihren Projekten eingestellt wurden.
--
--      mit_id
--      2581
--      22222



-- Aufgabe 20.9
--
-- Finden Sie die Personal- und Projektnummer aller Mitarbeiter, 
-- die in den Projekten 1 oder 5 arbeiten und deren Aufgabe noch 
-- nicht festgelegt ist.
--
--      mit_id  pro_id
--      17000   1
--      17000   5
--      28559   1



-- Aufgabe 20.10
--
-- Geben Sie die Firmennamen aller Kunden aus. Sortieren
-- Sie die Ausgabe aufsteigend nach dem Firmennamen.
--
--      firma
--      100% Sonderzeichen AG
--      Finanzamt Ulm
--      Frankreich-Reisen GmbH
--      Getränke Schneider
--      Im- und Export AG
--      Technische Produkte oHG



-- Aufgabe 20.11
--
-- Geben Sie alle Umsätze des Jahres 2019 sortiert nach der
-- Id der Mitarbeiter aus. Bei gleicher Id soll nach Datum
-- absteigend sortiert werden.
--
--      id  mit_id  datum       umsatz
--      21  2581    2019-05-01  100000,00
--      10  10102   2019-01-01  4500,00
--      20  25348   2019-05-01  150,00
--      19  25348   2019-04-01  15,00
--      18  25348   2019-03-01  1500,00
--      17  25348   2019-02-01  150000,00



-- Aufgabe 20.12
--
-- Gesucht werden Mitarbeiter-id, Projekt-Id und Aufgabe 
-- der Mitarbeiter, die entweder im Projekt 3 arbeiten, 
-- oder aber Gruppenleiter in einem beliebigen Projekt sind.
-- Sortieren Sie die Ausgabe nach der Projekt-Id und dann 
-- nach der Aufgabe.
--
--      mit_id  pro_id  aufgabe
--      9031    1       Gruppenleiter
--      24321   3       NULL
--      10102   3       Gruppenleiter
--      2581    3       Projektleiter
--      9031    3       Sachbearbeiter
--      12121   4       Gruppenleiter



-- Aufgabe 20.13
--
-- Finden Sie Namen und Personalnummer aller Mitarbeiter, 
-- deren Name mit dem Buchstaben "M" beginnt.
--
--      nachname  id
--      Meier     9031
--      Müller    18316
--      Mozer     28559



-- Aufgabe 20.14
--
-- Nennen Sie Namen, Vornamen und Id aller Mitarbeiter, 
-- deren Nachname als zweiten Buchstaben ein "u" hat.
--
--      nachname  vorname   id
--      Huber     Petra     10102
--      Fuchs     Dirk      20204



-- Aufgabe 20.15
--
-- Nennen Sie Vor- und Nachname aller Mitarbeiter, deren  
-- Nachname nicht mit "er" und nicht mit "t" endet.
--
--      vorname   nachname
--      Brigitte  Kaufmann
--      Klaus     Wolf
--      Dirk      Fuchs
--      Anke      Vogel



-- Aufgabe 20.16
--
-- Wie kann man nach dem Unterstrich (_) oder dem Prozentzeichen (%)
-- mit LIKE suchen? Finden Sie alle Kunden, in deren Datensatz ein 
-- solches Sonderzeichen vorkommt.
--
--      firma                  ort
--      100% Sonderzeichen AG  Baden_Baden



-- Aufgabe 20.17
--
-- Nennen Sie alle Mitarbeiter, deren Nachname mindestens 
-- drei Vokale enthält.
--
--      id     nachname  vorname   abt_id  ort    chef_id
--      2581   Kaufmann  Brigitte  2       NULL   NULL
--      9031   Meier     Rainer    2       NULL   2581



-- Aufgabe 20.18
-- 
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau fünf
-- Buchstaben besteht.
--
--      id     nachname  vorname  abt_id  ort         chef_id
--      9912   Wolf      Klaus    4       Heidenheim  22222
--      10102  Huber     Petra    3       Landshut    2581



-- Aufgabe 20.19
--
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau sechs
-- Buchstaben besteht und deren Vorname nicht mit einem Vokal endet.
--
--      id     nachname  vorname  abt_id  ort    chef_id
--      9031   Meier     Rainer   2       NULL   2581
--      17000  Krüger    Martin   5       Ulm    22222



-- Aufgabe 20.20
--
-- Finden Sie alle Mitarbeiter, bei deren Nachname der vorletzte
-- Buchstabe kein Vokal ist.
--
--      id     nachname  vorname   abt_id  ort         chef_id
--      2581   Kaufmann  Brigitte  2       NULL        NULL
--      9912   Wolf      Klaus     4       Heidenheim  22222
--      20204  Fuchs     Dirk      4       Fürth       22222
--      24321  Schubert  Rolf      5       München     22222
--      27365  Albrecht  Lena      5       NULL        22222
--      29346  Probst    Andreas   2       Augsburg    2581


