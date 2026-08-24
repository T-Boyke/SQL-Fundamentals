-- Nutzen Sie die ProjektDB-Datenbank, um die folgenden
-- Aufgaben zu lösen


-- Aufgabe 6.9
--
-- Nennen Sie einmalig die Namen der Projekte, in denen die 
-- Mitarbeiter arbeiten, die ein Gehalt von mindestens 
-- 5.000 € beziehen.
--
--      bezeichnung
--      Apollo
--      Ariane
--      Gemini



-- Aufgabe 6.10
--
-- Erstellen Sie das Kartesische Produkt auf Mitarbeiter- und Abteilungs-Tabelle
--
--      id     nachname  vorname   abt_id  ort         chef_id  id  kuerzel  bezeichnung  ort
--      2581   Kaufmann  Brigitte  2       NULL        NULL     1   BE       Beratung     München
--      5765   Schäfer   Sabine    3       Landshut    2581     1   BE       Beratung     München
--      9031   Meier     Rainer    2       NULL        2581     1   BE       Beratung     München
--      9912   Wolf      Klaus     4       Heidenheim  22222    1   BE       Beratung     München
--      10102  Huber     Petra     3       Landshut    2581     1   BE       Beratung     München
--      12121  Richter   Ursula    4       München     22222    1   BE       Beratung     München
--      ...
--      (75 Zeilen)



-- Aufgabe 6.11
--
-- Finden Sie alle Mitarbeiter und dazu alle Abteilungen, in denen 
-- diese Mitarbeiter NICHT arbeiten.
--
--      id     nachname  vorname   abt_id  ort         chef_id  id  kuerzel  bezeichnung  ort
--      2581   Kaufmann  Brigitte  2       NULL        NULL     1   BE       Beratung     München
--      5765   Schäfer   Sabine    3       Landshut    2581     1   BE       Beratung     München
--      9031   Meier     Rainer    2       NULL        2581     1   BE       Beratung     München
--      9912   Wolf      Klaus     4       Heidenheim  22222    1   BE       Beratung     München
--      10102  Huber     Petra     3       Landshut    2581     1   BE       Beratung     München
--      12121  Richter   Ursula    4       München     22222    1   BE       Beratung     München
--      ...
--      (60 Zeilen)



-- Aufgabe 6.12
--
-- Nennen Sie die Abteilungsnamen der Mitarbeiter, die 
-- am 01.01.2019 eingestellt wurden.
--
--		bezeichnung
--		Freigabe
--		Einkauf



-- Aufgabe 6.13
--
-- Nennen Sie Namen und Vornamen aller Projektleiter, deren 
-- Abteilung den Standort Stuttgart hat.
--
--      nachname  vorname
--      Schäfer   Sabine
--      Huber     Petra



-- Aufgabe 6.14
--
-- Nennen Sie einmalig die Namen der Projekte, in denen 
-- Mitarbeiter arbeiten, die zur Abteilung Beratung gehören.
--
--      bezeichnung
--      Apollo
--      Gemini



-- Aufgabe 6.15
--
-- Nennen Sie die Kunden, an deren Projekten Mitarbeiter
-- arbeiten, die mindestens 5.000 € Gehalt bekommen. Nennen
-- Sie zu den Kunden auch die Anzahl dieser Mitarbeiter.
--
--      firma                    mitarbeiter
--      Finanzamt Ulm            2
--      Frankreich-Reisen GmbH   2
--      Technische Produkte oHG  1


