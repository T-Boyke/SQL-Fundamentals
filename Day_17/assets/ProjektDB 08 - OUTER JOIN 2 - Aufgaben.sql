-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- Aufgabe 8.9
--
-- Zeigen Sie alle Mitarbeiter mit Id und nachname an
-- und geben Sie dazu die vom Mitarbeiter getätigten
-- Umsätze aus. Hat der Mitarbeiter noch keine Umsätze
-- getätigt, soll in der Spalte Umsatz 0 angezeigt werden.
--
--      id     nachname  umsatz
--      2581   Kaufmann  100000,00
--      5765   Schäfer   0,00
--      9031   Meier     0,00
--      9912   Wolf      0,00
--      10102  Huber     500,00
--      10102  Huber     500,00
--      ...
--      (36 Zeilen)



-- Aufgabe 8.10
--
-- Überarbeiten Sie die Abfrage aus Aufgabe 8.9.
-- Zeigen Sie diesmal nur die Mitarbeiter an, die
-- noch keine Umsätze getätigt haben.
--
--      id     nachname  umsatz
--      5765   Schäfer   0,00
--      9031   Meier     0,00
--      9912   Wolf      0,00
--      12121  Richter   0,00
--      18316  Müller    0,00
--      20204  Fuchs     0,00
--      ...
--      (11 Zeilen)



-- Aufgabe 8.11
--
-- Überarbeiten Sie die Abfrage aus Aufgabe 8.9.
-- Gruppieren Sie über die Mitarbeiter und geben 
-- Sie statt der einzelnen Umsätze die Summe der
-- Umsätze für jeden Mitarbeiter aus. Fehlende
-- Umsätze sollen weiterhin mit 0 angezeigt werden.
--
--      id     nachname  umsatz
--      2581   Kaufmann  100000,00
--      5765   Schäfer   0,00
--      9031   Meier     0,00
--      9912   Wolf      0,00
--      10102  Huber     18000,00
--      12121  Richter   0,00
--      ...
--      (15 Zeilen)



-- Aufgabe 8.12
--
-- Überarbeiten Sie die Abfrage aus Aufgabe 8.11.
-- Zeigen Sie nur die Mitarbeiter an, die weniger
-- als 100000 Umsatz erreicht haben.
--
--      id     nachname  umsatz
--      5765   Schäfer   0,00
--      9031   Meier     0,00
--      9912   Wolf      0,00
--      10102  Huber     18000,00
--      12121  Richter   0,00
--      17000  Krüger    20000,00
--      ...
--      (13 Zeilen)



-- Aufgabe 8.13
--
-- Zeigen Sie alle Mitarbeiter der Abteilung 2 mit Id
-- und Nachname an und geben Sie dazu die vom Mitarbeiter 
-- getätigten Umsätze aus. Hat der Mitarbeiter noch keine 
-- Umsätze getätigt, soll in der Spalte Umsatz eine 0 
-- angezeigt werden.
--
--      id     nachname  umsatz
--      2581   Kaufmann  100000
--      9031   Meier     0
--      29346  Probst    0



-- Aufgabe 8.14
--
-- Zeigen Sie alle Mitarbeiter mit Id und Nachname an
-- und geben Sie dazu aus, an welchem Tag der Mitarbeiter
-- zum ersten Mal einen Umsatz erzielt hat und wann er
-- zum letzten Mal einen Umsatz erzielt hat.
--
--      id     nachname  erster      letzter
--      2581   Kaufmann  2019-05-01  2019-05-01
--      5765   Schäfer   NULL        NULL
--      9031   Meier     NULL        NULL
--      9912   Wolf      NULL        NULL
--      10102  Huber     2018-10-01  2019-01-01
--      12121  Richter   NULL        NULL
--      ...
--      (15 Zeilen)



-- Aufgabe 8.15
--
-- Listen Sie alle Mitarbeiter mit m_nr und m_name
-- auf. Zusätzlich soll das Projekt genannt werden,
-- in dem der Mitarbeiter Projektleiter ist. Sollte 
-- es kein passendes Projekt geben, soll '- k. A. -'
-- statt des Projektnamens angezeigt werden.
--
--      id     nachname  projekt
--      2581   Kaufmann  Merkur
--      5765   Schäfer   Pluto
--      9031   Meier     - k. A. -
--      9912   Wolf      - k. A. -
--      10102  Huber     Apollo
--      12121  Richter   - k. A. -
--      ...
--      (15 Zeilen)


