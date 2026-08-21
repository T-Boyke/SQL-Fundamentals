-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen
USE ProjektDB;

-- Aufgabe 3.1
--
-- Finden Sie Namen und Personalnummer aller Mitarbeiter, 
-- deren Name mit dem Buchstaben "K" beginnt.
--
--      nachname  id
--      Kaufmann  2581
--      Krüger    17000
--      Keller    25348

SELECT nachname, id
FROM Mitarbeiter
WHERE nachname LIKE 'K%';

-- Aufgabe 3.2
--
-- Nennen Sie Namen, Vornamen und Id aller Mitarbeiter, 
-- deren Vorname als zweiten Buchstaben ein "a" hat.
--
--      nachname  vorname   id
--      Schäfer   Sabine    5765
--      Meier     Rainer    9031
--      Krüger    Martin    17000
--      Müller    Gabriele  18316
--      Keller    Hans      25348

SELECT nachname, vorname, id
FROM Mitarbeiter
WHERE vorname LIKE '_a%';

-- Aufgabe 3.3
--
-- Finden Sie Abteilungs-Id und Standort aller Abteilungen, die 
-- sich in den Orten befinden, die mit einem Buchstaben zwischen 
-- "N" und "Z" beginnen.
--
--      id  ort
--      3   Stuttgart
--      5   Ulm

SELECT id, ort
FROM Abteilung
WHERE ort LIKE '[N-Z]%';

-- Aufgabe 3.4
--
-- Finden Sie Id, Nachnamen und Vornamen aller Mitarbeiter, deren 
-- Namen nicht mit den Buchstaben K, L, M, N, O und P beginnen,
-- und deren Vornamen nicht mit dem Buchstaben U beginnen.
--
--      id     nachname  vorname
--      5765   Schäfer   Sabine
--      9912   Wolf      Klaus
--      10102  Huber     Petra
--      20204  Fuchs     Dirk
--      22222  Vogel     Anke
--      24321  Schubert  Rolf
--      27365  Albrecht  Lena

SELECT id, nachname, vorname
FROM Mitarbeiter
WHERE nachname LIKE '[^K-P]%' AND vorname NOT LIKE 'U%';

-- Aufgabe 3.5
--
-- Nennen Sie Vor- und Nachname aller Mitarbeiter, deren Name 
-- nicht mit "er" endet.
--
--      vorname   nachname
--      Brigitte  Kaufmann
--      Klaus     Wolf
--      Dirk      Fuchs
--      Anke      Vogel
--      Rolf      Schubert
--      Lena      Albrecht
--      Andreas   Probst

SELECT vorname, nachname
FROM Mitarbeiter
WHERE nachname NOT LIKE '%er';

-- Aufgabe 3.6
--
-- Wie kann man nach dem Unterstrich (_) oder dem Prozentzeichen (%)
-- mit LIKE suchen? Finden Sie alle Kunden, in deren Datensatz ein 
-- solches Sonderzeichen vorkommt.
--
--      firma                  ort
--      100% Sonderzeichen AG  Baden_Baden

SELECT firma, ort
FROM Kunde
WHERE firma LIKE '%[%_]%' OR ort LIKE '%[%_[]%';

-- Aufgabe 3.7
--
-- Nennen Sie alle Mitarbeiter, deren Vorname mindestens 
-- drei Vokale enthält.
--
--      id     vorname   nachname  abt_id  ort        chef_id
--      2581   Brigitte  Kaufmann  2       NULL       NULL
--      5765   Sabine    Schäfer   3       Landshut   2581
--      9031   Rainer    Meier     2       NULL       2581
--      12121  Ursula    Richter   4       München    22222
--      18316  Gabriele  Müller    1       Rosenheim  2581
--      28559  Sibille   Mozer     1       Ulm        2581
--      29346  Andreas   Probst    2       Augsburg   2581

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '%[aeiou]%[aeiou]%[aeiou]%';

-- Aufgabe 3.8
-- 
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau sieben
-- Buchstaben besteht.
--
--      id     vorname  nachname  abt_id  ort       chef_id
--      28559  Sibille  Mozer     1       Ulm       2581
--      29346  Andreas  Probst    2       Augsburg  2581

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '_______';

SELECT *
FROM Mitarbeiter
WHERE LEN(TRIM(vorname)) = 7;

-- Aufgabe 3.9
--
-- Finden Sie alle Mitarbeiter, deren Vorname aus genau sechs
-- Buchstaben besteht und deren Vorname nicht mit einem Vokal endet.
--
--      id     vorname  nachname  abt_id  ort    chef_id
--      9031   Rainer   Meier     2       NULL   2581
--      17000  Martin   Krüger    5       Ulm    22222

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '_____[^aeiou]';

-- Aufgabe 3.10
--
-- Finden Sie alle Mitarbeiter, bei deren Vorname der vorletzte
-- Buchstabe ein Vokal ist.
--
--      id     vorname  nachname  abt_id  ort         chef_id
--      9031   Rainer   Meier     2       NULL        2581
--      9912   Klaus    Wolf      4       Heidenheim  22222
--      17000  Martin   Krüger    5       Ulm         22222
--      29346  Andreas  Probst    2       Augsburg    2581

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '%[aeiou]_';
