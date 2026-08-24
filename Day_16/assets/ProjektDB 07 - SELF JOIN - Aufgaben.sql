-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- Aufgabe 7.1
--
-- Finden Sie alle Abteilungen, an deren Standorten 
-- sich weitere Abteilungen befinden. Geben Sie jeweils
-- die Ids, Namen und Städte der Abteilungen aus.
--
--      id  bezeichnung  ort      id  bezeichnung  ort
--      1   Beratung     München  1   Beratung     München
--      2   Diagnose     München  1   Beratung     München
--      4   Einkauf      München  1   Beratung     München
--      1   Beratung     München  2   Diagnose     München
--      2   Diagnose     München  2   Diagnose     München
--      4   Einkauf      München  2   Diagnose     München
--      ...
--      (11 Zeilen)



-- Aufgabe 7.2
--
-- Überarbeiten Sie die Abfrage aus Aufgabe 7.1.
-- Diesmal sollen nur Zeilen ins Ergebnis übernommen 
-- werden, bei denen die Abteilungen sich unterscheiden.
--
--      id  bezeichnung  ort      id  bezeichnung  ort
--      1   Beratung     München  2   Diagnose     München
--      1   Beratung     München  4   Einkauf      München
--      2   Diagnose     München  1   Beratung     München
--      2   Diagnose     München  4   Einkauf      München
--      4   Einkauf      München  1   Beratung     München
--      4   Einkauf      München  2   Diagnose     München



-- Aufgabe 7.3
--
-- Überarbeiten Sie die Abfrage aus Aufgabe 7.2.
-- Diesmal soll jede Kombination nur einmal angezeigt 
-- werden. D.h. A-B ist das gleiche wie B-A.
--
--      id  bezeichnung  ort      id  bezeichnung  ort
--      2   Diagnose     München  1   Beratung     München
--      4   Einkauf      München  1   Beratung     München
--      4   Einkauf      München  2   Diagnose     München



-- Aufgabe 7.4
--
-- Finden Sie heraus, ob es Mitarbeiter gibt, die einen 
-- Kollegen oder eine Kollegin aus derselben Abteilung 
-- in ihrem Wohnort haben (Stichwort Fahrgemeinschaft).
--
--      id     abt_id  nachname  ort
--      5765   3       Schäfer   Landshut
--      10102  3       Huber     Landshut
--      12121  4       Richter   München
--      22222  4       Vogel     München



-- Aufgabe 7.5
--
-- Geben Sie die Mitarbeiter-Id, die Projektnummer und 
-- die Aufgabe der Mitarbeiter aus, die im gleichen 
-- Projekt die gleiche Aufgabe ausführen. Sortieren Sie
-- die Ausgabe ggf. sinnvoll.
--
--      mit_id  pro_id  aufgabe
--      25348   2       Sachbearbeiter
--      28559   2       Sachbearbeiter
--      20204   4       Sachbearbeiter
--      27365   4       Sachbearbeiter



-- Aufgabe 7.6
--
-- Ermitteln Sie die Mitarbeiter mit Id, Vorname, Nachname
-- und dem Nachnamen des Vorgesetzten.
-- 
--      id     vorname   nachname  chef
--      5765   Sabine    Schäfer   Kaufmann
--      9031   Rainer    Meier     Kaufmann
--      9912   Klaus     Wolf      Vogel
--      10102  Petra     Huber     Kaufmann
--      12121  Ursula    Richter   Vogel
--      ...
--      (15 Zeilen)



-- Aufgabe 7.7
--
-- Finden Sie die Abteilungen, in denen die beiden Vorgesetzten
-- Mitarbeiter arbeiten
--
--      id  kuerzel  bezeichnung  ort
--      2   DI       Diagnose     München
--      4   EK       Einkauf      München



-- Aufgabe 7.8
--
-- Ermitteln Sie, welche Mitarbeiter in der gleichen
-- Stadt wohnen wie ihre Vorgesetzten.
--
--      vorname  nachname  ort      chef_ort
--      Ursula   Richter   München  München
--      Rolf     Schubert  München  München



-- Aufgabe 7.9
--
-- Ermitteln Sie, welche Mitarbeiter im gleichen Projekt
-- arbeiten wie ihre Vorgesetzten.
--
--      nachname  pro_id  chef_name  chef_pro_id
--      Huber     3       Kaufmann   3
--      Meier     3       Kaufmann   3
--      Krüger    5       Vogel      5
--      Wolf      5       Vogel      5


