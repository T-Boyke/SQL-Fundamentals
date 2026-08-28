-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:
USE ProjektDB;
GO
SET LANGUAGE german;
GO

-- ==========
-- Funktionen
-- ==========

-- Aufgabe 9.5
--
-- Generieren Sie Codes für Ihre Mitarbeiter. Der Code soll
-- bestehen aus:
--      - Erster Buchstabe Nachname
--      - Vierter Buchstabe Nachname (groß)
--      - Letzter Buchstabe Vorname (groß)
--      - Abteilungskürzel rückwärts (EK => KE)
--
--      nachname  vorname   kuerzel  code
--      Kaufmann  Brigitte  DI       KFEID
--      Schäfer   Sabine    FR       SÄERF
--      Meier     Rainer    DI       MERID
--      Wolf      Klaus     EK       WFSKE
--      Huber     Petra     FR       HEARF
--      Richter   Ursula    EK       RHAKE

SELECT m.nachname,
       m.vorname,
       abt.kuerzel,
       CONCAT(
           LEFT(m.nachname, 1),
           UPPER(SUBSTRING(m.nachname, 4, 1)),
           UPPER(RIGHT(m.vorname, 1)),
           REVERSE(abt.kuerzel)
       ) AS code
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id;
GO


-- Aufgabe 9.6
--
-- Geben Sie den Vor- und Nachnamen der Mitarbeiter
-- in einer Spalte aus. Nutzen Sie die Funktionen
-- CONCAT() und ggf. TRIM().
--
--      name
--      Brigitte Kaufmann
--      Sabine Schäfer
--      Rainer Meier
--      Klaus Wolf
--      Petra Huber
--      Ursula Richter
--      ...
--      (15 Zeilen)

SELECT CONCAT(TRIM(vorname), ' ', TRIM(nachname)) AS name
FROM Mitarbeiter;
GO


-- Aufgabe 9.7
--
-- Geben Sie den Vor- und Nachnamen der Mitarbeiter,
-- gefolgt vom Wohnort in einer Spalte aus. Wenn kein
-- Wohnort vorhanden ist, soll der Text 'unbekannt'
-- erscheinen.
--
--      mitarbeiter
--      Brigitte Kaufmann, unbekannt
--      Sabine Schäfer, Landshut
--      Rainer Meier, unbekannt
--      Klaus Wolf, Heidenheim
--      Petra Huber, Landshut
--      Ursula Richter, München
--      ...
--      (15 Zeilen)

SELECT CONCAT(
           TRIM(vorname), ' ', 
           TRIM(nachname), ', ', 
           COALESCE(ort, 'unbekannt')
       ) AS mitarbeiter
FROM Mitarbeiter;
GO


-- Aufgabe 9.8
--
-- Geben Sie die Kurzform des Mitarbeiternamens
-- in einer Spalte aus. Das erste Zeichen eines
-- Textes können Sie mit LEFT() oder SUBSTRING()
-- ermitteln.
--
--      name
--      B. Kaufmann
--      S. Schäfer
--      R. Meier
--      K. Wolf
--      P. Huber
--      U. Richter
--      ...
--      (15 Zeilen)

SELECT CONCAT(LEFT(TRIM(vorname), 1), '. ', TRIM(nachname)) AS name
FROM Mitarbeiter;
GO


-- Aufgabe 9.9
--
-- Geben Sie die Nachnamen der Mitarbeiter aus und sortieren
-- Sie die Ausgabe nach der Länge der Namen aufsteigend. Bei
-- gleicher Länge des Namens soll alphabetisch absteigend
-- sortiert werden.
--
--      nachname
--      Wolf
--      Vogel
--      Mozer
--      Meier
--      Huber
--      Fuchs
--      ...
--      (15 Zeilen)

SELECT nachname
FROM Mitarbeiter
ORDER BY LEN(nachname) ASC, nachname DESC;
GO


-- Aufgabe 9.10
--
-- Zeigen Sie die Namen aller Mitarbeiter an und geben Sie
-- dazu die Position des ersten Vokals an. Nutzen Sie die
-- Funktion PATINDEX() um den Vokal zu finden.
--
--      nachname  erster_vokal
--      Kaufmann  2
--      Schäfer   4
--      Meier     2
--      Wolf      2
--      Huber     2
--      Richter   2
--      ...
--      (15 Zeilen)

SELECT nachname,
       PATINDEX('%[aeiouäöü]%', LOWER(nachname)) AS erster_vokal
FROM Mitarbeiter;
GO


-- Aufgabe 9.11
--
-- Berechnen Sie die Anzahl der Tage (brutto), die Sie bereits
-- in diesem Modul verbringen durften (oder mussten). Nutzen Sie
-- die Funktionen DATEDIFF() und GETDATE().
--
--      tage_in_modul
--      23

-- Berechnung bezogen auf den Aufgabenblatt-Startpunkt (01.08.2024):
SELECT DATEDIFF(day, '2024-08-01', GETDATE()) AS tage_in_modul;

-- Berechnung bezogen auf den aktuellen August-Zyklus 2026:
SELECT DATEDIFF(day, '2026-08-03', GETDATE()) AS tage_in_modul_2026;
GO


-- Aufgabe 9.12
--
-- Schreiben Sie eine Abfrage, die das heutige Datum formatiert
-- ausgibt. Nutzen Sie dazu die Datumsfunktionen DATENAME(),
-- DATEPART() und GETDATE() sowie die Funktion CONCAT().
--
--      datum_formatiert
--      Heute ist Freitag, der 16. August des Jahres 2024 in der 33. Kalenderwoche

SELECT CONCAT(
           'Heute ist ', 
           DATENAME(dw, GETDATE()), 
           ', der ', 
           DATEPART(dd, GETDATE()), 
           '. ', 
           DATENAME(mm, GETDATE()), 
           ' des Jahres ', 
           DATEPART(yy, GETDATE()), 
           ' in der ', 
           DATEPART(wk, GETDATE()), 
           '. Kalenderwoche'
       ) AS datum_formatiert;
GO


-- Aufgabe 9.13
--
-- Der wievielte Tag des Jahres ist heute?
--
--      datum       tag_des_jahres
--      2024-08-16  229

SELECT CAST(GETDATE() AS DATE)        AS datum,
       DATEPART(dayofyear, GETDATE()) AS tag_des_jahres;
GO


-- Aufgabe 9.14
--
-- Kategorisieren Sie Ihre Mitarbeiter. Mitarbeiter, die ein
-- Gehalt unter 4000 bekommen sind Kategorie A, die anderen
-- sind Kategorie B. Versuchen Sie IIF() statt CASE zu verwenden.
--
--      mit_id  gehalt   kategorie
--      2581    3000,00  A
--      5765    4500,00  B
--      9031    4000,00  B
--      9912    3500,00  A
--      10102   3500,00  A
--      12121   3000,00  A

SELECT g.mit_id,
       g.gehalt,
       IIF(g.gehalt < 4000.00, 'A', 'B') AS kategorie
FROM Gehalt AS g;
GO
