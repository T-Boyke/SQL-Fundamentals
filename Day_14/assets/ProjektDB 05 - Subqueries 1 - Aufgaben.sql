-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- ======================
-- Einfache Unterabfragen
-- ======================

-- Aufgabe 5.1
--
-- Nennen Sie Personalnummer und Name des Mitarbeiters 
-- mit der kleinsten Personalnummer. Nutzen Sie eine 
-- einfache Unterabfrage.
--
--      id    nachname
--      2581  Kaufmann



-- Aufgabe 5.2
--
-- Nennen Sie die Abteilungsnummern der Mitarbeiter, die 
-- in Projekt 3 arbeiten. Nutzen Sie eine einfache 
-- Unterabfrage.
--
--      abt_id
--      a2
--      a2
--      a3
--      a5



-- Aufgabe 5.3
--
-- Erstellen Sie eine Liste der Ids aller Mitarbeiter, 
-- deren Gehalt über dem  Durchschnitt liegt. Nutzen 
-- Sie eine einfache Unterabfrage.
--
--      mit_id
--      5765
--      9031
--      17000
--      22222
--      28559
--      29346



-- Aufgabe 5.4
--
-- Nennen Sie die Nummern aller Projekte, in denen Mitarbeiter
-- arbeiten, deren Personalnummer kleiner als die Nummer des 
-- Mitarbeiters namens Müller ist. Nutzen Sie eine einfache 
-- Unterabfrage.
--
--      pro_id
--      1
--      3
--      4
--      5



-- Aufgabe 5.5
--
-- Nennen Sie die Namen aller Mitarbeiter, die in einer 
-- Abteilung in Ulm arbeiten. Nutzen Sie eine einfache 
-- Unterabfrage.
--
--      nachname  vorname
--      Krüger    Martin
--      Schubert  Rolf
--      Albrecht  Lena



-- Aufgabe 5.6
--
-- Finden Sie die Personalnummer des Projektleiters, 
-- der in dieser Position als letzter einstellt wurde.
-- Nutzen Sie eine einfache Unterabfrage.
--
--      mit_id
--      2581



-- Aufgabe 5.7
--
-- Nennen Sie die Namen aller Mitarbeiter, die im Projekt "Apollo" 
-- arbeiten. Nutzen Sie zwei verschachtelte Unterabfragen.
--
--      nachname
--      Meier
--      Huber
--      Krüger
--      Mozer
--      Probst



-- Aufgabe 5.8
--
-- Zeigen Sie Abteilungsnummer und den Namen der Abteilungen 
-- für die Mitarbeiter an, die am Projekt "Apollo" mitarbeiten. 
-- Nutzen Sie drei verschachtelte Unterabfragen.
--
--      id  bezeichnung
--      1   Beratung
--      2   Diagnose
--      3   Freigabe
--      5   Verkauf


