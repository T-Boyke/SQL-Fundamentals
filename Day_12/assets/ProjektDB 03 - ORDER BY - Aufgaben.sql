-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:


-- ========
-- ORDER BY
-- ========

-- Aufgabe 3.1
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



-- Aufgabe 3.2
--
-- Geben Sie alle Umsätze des Jahres 2019 sortiert nach Datum
-- aus. Bei gleichem Datum sollen die größeren Umsätze zuerst
-- genannt werden.
--
--      id  mit_id  datum       umsatz
--      10  10102   2019-01-01  4500,00
--      17  25348   2019-02-01  150000,00
--      18  25348   2019-03-01  1500,00
--      19  25348   2019-04-01  15,00
--      21  2581    2019-05-01  100000,00
--      20  25348   2019-05-01  150,00



-- Aufgabe 3.3
--
-- Geben Sie alle Daten der Mitarbeiter aus. Sortieren Sie die
-- Ausgabe nach Abteilungs-Nr. aufsteigend. Innerhalb der
-- Abteilung sollen die Mitarbeiter ohne bekannten Wohnort
-- am Ende stehen.
--
--      id     nachname  vorname   abt_id  ort        chef_id
--      28559  Mozer     Sibille   1       Ulm        2581
--      18316  Müller    Gabriele  1       Rosenheim  2581
--      29346  Probst    Andreas   2       Augsburg   2581
--      2581   Kaufmann  Brigitte  2       NULL       NULL
--      9031   Meier     Rainer    2       NULL       2581
--      25348  Keller    Hans      3       München    2581
--      ..
--      (15 Zeilen)



-- Aufgabe 3.4
--
-- Geben Sie die Id und die Aufgabe von allen Mitarbeitern
-- aus, die Projektleiter sind. Sortieren Sie die Ausgabe 
-- nach der Mitarbeiter-Id.
--
--      mit_id  aufgabe
--      2581    Projektleiter
--      5765    Projektleiter
--      10102   Projektleiter
--      22222   Projektleiter



-- Aufgabe 3.5
--
-- Gesucht werden Mitarbeiter-id, Projekt-Id und Aufgabe 
-- der Mitarbeiter, die entweder im Projekt 2 arbeiten, 
-- oder aber Projektleiter in einem beliebigen Projekt sind.
-- Sortieren Sie die Ausgabe nach der Projekt-Id und dann 
-- nach der Aufgabe.
--
--      mit_id  pro_id  aufgabe
--      10102   1       Projektleiter
--      18316   2       NULL
--      29346   2       NULL
--      25348   2       Sachbearbeiter
--      28559   2       Sachbearbeiter
--      2581    3       Projektleiter
--      5765    4       Projektleiter
--      22222   5       Projektleiter



-- Aufgabe 3.6
--
-- Selektieren Sie die drei größten Umsätze, die im Jahr
-- 2018 gemacht wurden.
--
--      id  mit_id  datum       umsatz
--      15  25348   2018-05-02  15000,00
--      16  25348   2018-10-11  15000,00
--      4   10102   2018-11-01  5000,00



-- Aufgabe 3.7
--
-- Selektieren Sie erneut die drei größten Umsätze aus dem
-- Jahr 2018. Verwenden Sie diesmal zusätzlich die Klausel 
-- WITH TIES.
--
--      id  mit_id  datum       umsatz
--      15  25348   2018-05-02  15000,00
--      16  25348   2018-10-11  15000,00
--      22  17000   2018-03-03  5000,00
--      23  17000   2018-03-04  5000,00
--      24  17000   2018-03-05  5000,00
--      25  17000   2018-03-06  5000,00
--      4   10102   2018-11-01  5000,00
--      8   10102   2018-12-23  5000,00


