-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:
USE ProjektDB;
GO
SET LANGUAGE german;
GO

-- ==============
-- CASE-Ausdrücke
-- ==============

-- Aufgabe 9.1
--
-- Geben Sie eine Liste aller Projekte aus, in der 
-- Sie diese nach den verfügbaren Mitteln in 
-- Kategorien einteilen:
--  weniger als  90.000 => Kategorie 1
--  weniger als 135.000 => Kategorie 2
--  weniger als 170.000 => Kategorie 3
--  ab 170.000          => Kategorie 4
--
--      bezeichnung  kategorie
--      Apollo       2
--      Gemini       2
--      Merkur       4
--      Pluto        1
--      Ariane       3

SELECT bezeichnung,
       CASE
           WHEN mittel < 90000.00 THEN 1
           WHEN mittel < 135000.00 THEN 2
           WHEN mittel < 170000.00 THEN 3
           ELSE 4
       END AS kategorie
FROM Projekt;
GO


-- Aufgabe 9.2
--
-- Kategorisieren Sie Ihre Mitarbeiter. Mitarbeiter, 
-- die in der Abteilung 'Einkauf' arbeiten, kommen 
-- in Kategorie A. Mitarbeiter aus anderen Abteilungen 
-- kommen in Kategorie B. Aber wer in Landshut oder 
-- Rosenheim wohnt (also auf dem Land), der kommt auf 
-- jeden Fall in Kategorie F.
--
--      id     nachname  ort         bezeichnung  kategorie
--      2581   Kaufmann  NULL        Diagnose     B
--      5765   Schäfer   Landshut    Freigabe     F
--      9031   Meier     NULL        Diagnose     B
--      9912   Wolf      Heidenheim  Einkauf      A
--      10102  Huber     Landshut    Freigabe     F
--      12121  Richter   München     Einkauf      A
--      ...
--      (15 Zeilen)

SELECT m.id,
       m.nachname,
       m.ort,
       a.bezeichnung,
       CASE
           WHEN m.ort IN ('Landshut', 'Rosenheim') THEN 'F'
           WHEN a.bezeichnung = 'Einkauf' THEN 'A'
           ELSE 'B'
       END AS kategorie
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;
GO


-- Aufgabe 9.3
--
-- Erweitern Sie die Abfrage aus Aufgabe 9.2. Mitarbeiter 
-- aus der Kategorie b sollen noch feiner unterteilt werden: 
-- Wenn Sie an einem Projekt mit mehr als 100.000 Mitteln 
-- arbeiten, sollen sie in Kategorie B1 fallen, sonst in 
-- Kategorie B2.
--
--      id     nachname  ort         bezeichnung  kategorie
--      2581   Kaufmann  NULL        Diagnose     B1
--      5765   Schäfer   Landshut    Freigabe     F
--      9031   Meier     NULL        Diagnose     B1
--      9912   Wolf      Heidenheim  Einkauf      A
--      10102  Huber     Landshut    Freigabe     F
--      12121  Richter   München     Einkauf      A
--      ...
--      (15 Zeilen)

SELECT m.id,
       m.nachname,
       m.ort,
       a.bezeichnung,
       CASE
           WHEN m.ort IN ('Landshut', 'Rosenheim') THEN 'F'
           WHEN a.bezeichnung = 'Einkauf' THEN 'A'
           WHEN EXISTS (
               SELECT 1
               FROM Arbeit AS ar
               INNER JOIN Projekt AS p ON ar.pro_id = p.id
               WHERE ar.mit_id = m.id AND p.mittel > 100000.00
           ) THEN 'B1'
           ELSE 'B2'
       END AS kategorie
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id;
GO


-- Aufgabe 9.4
-- 
-- Kategorisieren Sie Arbeiter in Ihren Projekten. Wer am
-- Wochenende in ein Projekt eingetreten ist, ist ein
-- Arbeitstier, wer am Montag oder Dienstag angefangen hat 
-- ist fleissig, und der Rest ist ein Faulenzer. Benutzen
-- Sie diesmal CASE. Den Wochentag bekommen Sie mit der
-- Funktion DATENAME(dw, <Datum>).
--
--      einst_dat   wochentag   kategorie
--      2019-10-15  Dienstag    Fleissig
--      2018-07-20  Freitag     Faulenzer
--      2019-04-15  Montag      Fleissig
--      2018-11-15  Donnerstag  Faulenzer
--      2019-01-17  Donnerstag  Faulenzer
--      2018-10-01  Montag      Fleissig
--      ...
--      (20 Zeilen)

SELECT a.einst_dat,
       DATENAME(dw, a.einst_dat) AS wochentag,
       CASE
           WHEN DATENAME(dw, a.einst_dat) IN ('Samstag', 'Sonntag') THEN 'Arbeitstier'
           WHEN DATENAME(dw, a.einst_dat) IN ('Montag', 'Dienstag') THEN 'Fleissig'
           ELSE 'Faulenzer'
       END AS kategorie
FROM Arbeit AS a;
GO
