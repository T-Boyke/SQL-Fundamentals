-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- =====
-- WHERE
-- =====

-- Aufgabe 1.1
--
-- Finden Sie die Namen und Id aller Abteilungen, 
-- die in München ihren Sitz haben.
--
--      bezeichnung  id
--      Beratung     1
--      Diagnose     2
--      Einkauf      4



-- Aufgabe 1.2
--
-- Nennen Sie die Vor- und Nachnamen aller Mitarbeiter,
-- deren Personalnummer größer oder gleich 20000 ist.
--
--      vorname  nachname
--      Dirk     Fuchs
--      Anke     Vogel
--      Rolf     Schubert
--      Hans     Keller
--      Lena     Albrecht
--      Sibille  Mozer
--      Andreas  Probst



-- Aufgabe 1.3
--
-- Finden Sie alle Projekte, deren Finanzmittel mehr als 
-- 129.960,01 $ betragen. Der fiktive Umrechnungskurs soll 
-- bei 1,083 $ für 1 Euro liegen. Die Mittel des Projekts
-- sind in Euro angegeben!
--
--      id  kuerzel  bezeichnung  mittel     kd_id
--      3   MK       Merkur       186500,00  1
--      5   AR       Ariane       165000,00  2



-- Aufgabe 1.4
--
-- Gesucht werden Mitarbeiter-Id, Projektnummer und Aufgabe 
-- der Mitarbeiter, die im Projekt 2 Sachbearbeiter sind.
--
--      mit_id  pro_id  aufgabe
--      25348   2       Sachbearbeiter
--      28559   2       Sachbearbeiter



-- Aufgabe 1.5
--
-- Finden Sie die Id, den Umsatz und das Datum für alle 
-- Mitarbeiter, die im Jahr 2018 Umsätze von mindestens 
-- 5000 € hatten.
--
--      mit_id  umsatz    datum
--      10102   5000,00   2018-11-01
--      10102   5000,00   2018-12-23
--      25348   15000,00  2018-05-02
--      25348   15000,00  2018-10-11
--      17000   5000,00   2018-03-03
--      17000   5000,00   2018-03-04
--      17000   5000,00   2018-03-05
--      17000   5000,00   2018-03-06



-- Aufgabe 1.6
--
-- Gesucht wird einmalig die Personalnummer der Mitarbeiter, 
-- die entweder im Projekt 1 oder 5 oder in beiden arbeiten.
--
--      mit_id
--      9031
--      9912
--      10102
--      17000
--      22222
--      28559
--      29346



-- Aufgabe 1.7
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


