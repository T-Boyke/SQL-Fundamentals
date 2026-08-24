-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- Aufgabe 8.1
--
-- Zeigen Sie die Id, Firma und die Stadt aller Kunden
-- an. Zeigen Sie dazu außerdem den Namen der Abteilungen 
-- an, die am Ort des Kunden ihren Sitz haben (bilden Sie 
-- den Join über den Ort).
--
--      id  firma                    ort          bezeichnung
--      1   Im- und Export AG        München      Beratung
--      1   Im- und Export AG        München      Diagnose
--      1   Im- und Export AG        München      Einkauf
--      2   Technische Produkte oHG  Ulm          Verkauf
--      3   Frankreich-Reisen GmbH   Saarlouis    NULL
--      4   Getränke Schneider       Heidenheim   NULL
--      5   Finanzamt Ulm            Fürth        NULL
--      6   100% Sonderzeichen AG    Baden_Baden  NULL



-- Aufgabe 8.2
--
-- Ändern Sie die Abfrage aus Aufgabe 8.1, so dass alle
-- Abteilungen angezeigt werden, und dazu die passenden
-- Kunden im selben Ort.
--
--      id    firma                    ort      bezeichnung
--      1     Im- und Export AG        München  Beratung
--      1     Im- und Export AG        München  Diagnose
--      NULL  NULL                     NULL     Freigabe
--      1     Im- und Export AG        München  Einkauf
--      2     Technische Produkte oHG  Ulm      Verkauf



-- Aufgabe 8.3
--
-- Überarbeiten Sie die Abfrage aus der Aufgabe 8.1.
-- Statt NULL soll in der Spalte für die Abteilung der
-- Text '- k. A. -' angezeigt werden.
--
--      id  firma                    ort          bezeichnung
--      1   Im- und Export AG        München      Beratung
--      1   Im- und Export AG        München      Diagnose
--      1   Im- und Export AG        München      Einkauf
--      2   Technische Produkte oHG  Ulm          Verkauf
--      3   Frankreich-Reisen GmbH   Saarlouis    - k. A. -
--      4   Getränke Schneider       Heidenheim   - k. A. -
--      5   Finanzamt Ulm            Fürth        - k. A. -
--      6   100% Sonderzeichen AG    Baden_Baden  - k. A. -



-- Aufgabe 8.4
--
-- Geben Sie eine Liste aller Kunden aus. Geben Sie zu den
-- Kunden auch das Projekt aus, sofern vorhanden.
--
--      firma                    ort          bezeichnung
--      Im- und Export AG        München      Merkur
--      Technische Produkte oHG  Ulm          Ariane
--      Frankreich-Reisen GmbH   Saarlouis    Apollo
--      Getränke Schneider       Heidenheim   Pluto
--      Finanzamt Ulm            Fürth        Gemini
--      100% Sonderzeichen AG    Baden_Baden  NULL



-- Aufgabe 8.5
--
-- Geben Sie jetzt nur die Kunden aus, zu denen es kein
-- Projekt gibt.
--
--      firma                  ort          bezeichnung
--      100% Sonderzeichen AG  Baden_Baden  NULL



-- Aufgabe 8.6
--
-- Geben Sie eine Liste der Kunden mit Firma und Stadt aus.
-- Geben Sie dazu die Nachnamen der Mitarbeiter aus, die
-- im selben Ort wohnen.
--
--      firma                   ort         nachname
--      Im- und Export AG       München     Richter
--      Im- und Export AG       München     Vogel
--      Im- und Export AG       München     Schubert
--      Im- und Export AG       München     Keller
--      Frankreich-Reisen GmbH  Saarlouis   NULL
--      Getränke Schneider      Heidenheim  Wolf
--      ...
--      (10 Zeilen)



-- Aufgabe 8.7
--
-- Geben Sie wieder die Liste der Kunden aus. Geben Sie
-- diesmal dazu die Anzahl Mitarbeiter aus, die am selben
-- Ort wohnen.
--
--      firma                    ort          mitarbeiter
--      100% Sonderzeichen AG    Baden_Baden  0
--      Finanzamt Ulm            Fürth        1
--      Getränke Schneider       Heidenheim   1
--      Im- und Export AG        München      4
--      Frankreich-Reisen GmbH   Saarlouis    0
--      Technische Produkte oHG  Ulm          2



-- Aufgabe 8.8
--
-- Ergänzen Sie die Abfrage aus Aufgabe 8.7 und geben 
-- Sie zusätzlich noch die Anzahl Abteilungen aus, die
-- es am Ort des Kunden gibt.
--
--      firma                    stadt        mitarbeiter  abteilungen
--      100% Sonderzeichen AG    Baden_Baden  0            0
--      Finanzamt Ulm            Fürth        1            0
--      Getränke Schneider       Heidenheim   1            0
--      Im- und Export AG        München      4            3
--      Frankreich-Reisen GmbH   Saarlouis    0            0
--      Technische Produkte oHG  Ulm          2            1


