-- ============================================================================
-- 📅 Day_15: ProjektDB 06 - INNER JOIN 1 - Lösungen
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 21.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- Aufgabe 6.1
-- Schreiben Sie eine Abfrage, die alle Mitarbeiter aus der Abteilung 4 ausgibt.
-- Geben Sie die Felder vorname, nachname und Abteilungsname aus.
--
-- Erwartetes Ergebnis:
-- vorname  nachname  bezeichnung
-- Klaus    Wolf      Einkauf
-- Ursula   Richter   Einkauf
-- Dirk     Fuchs     Einkauf
-- Anke     Vogel     Einkauf

SELECT m.vorname, m.nachname, a.bezeichnung
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a ON m.abt_id = a.id
WHERE a.id = 4;

-- Aufgabe 6.2
-- Schreiben Sie eine Abfrage, die alle Projekte mit den zugehörigen Projektleitern ausgibt.
-- Geben Sie alle Daten aus der Projekt-Tabelle und zusätzlich Id und Einstell-Datum 
-- aus der Arbeit-Tabelle aus. Sortieren Sie das Ergebnis nach der Projekt-ID.
--
-- Erwartetes Ergebnis:
-- id  kuerzel  bezeichnung  mittel     kunde_id  mit_id  einst_dat
-- 1   AP       Apollo       120000,00  3         10102   2018-10-01
-- 3   MK       Merkur       186500,00  1         2581    2019-10-15
-- 4   PL       Pluto        88500,00   4         5765    2018-07-20
-- 5   AR       Ariane       165000,00  2         22222   2019-01-01

SELECT p.id, p.kuerzel, p.bezeichnung, p.mittel, p.kunde_id, a.mit_id, a.einst_dat
FROM Projekt AS p
INNER JOIN Arbeit AS a ON p.id = a.pro_id
WHERE a.aufgabe = 'Projektleiter'
ORDER BY p.id ASC;

-- Aufgabe 6.3
-- Verändern Sie die Abfrage aus Aufgabe 6.2, indem Sie statt der Mitarbeiter-Id 
-- den Nachnamen des Mitarbeiters in das Ergebnis einbauen.
--
-- Erwartetes Ergebnis:
-- id  kuerzel  bezeichnung  mittel     kunde_id  nachname  einst_dat
-- 1   AP       Apollo       120000,00  3         Huber     2018-10-01
-- 3   MK       Merkur       186500,00  1         Kaufmann  2019-10-15
-- 4   PL       Pluto        88500,00   4         Schäfer   2018-07-20
-- 5   AR       Ariane       165000,00  2         Vogel     2019-01-01

SELECT p.id, p.kuerzel, p.bezeichnung, p.mittel, p.kunde_id, m.nachname, a.einst_dat
FROM Projekt AS p
INNER JOIN Arbeit AS a ON p.id = a.pro_id
INNER JOIN Mitarbeiter AS m ON a.mit_id = m.id
WHERE a.aufgabe = 'Projektleiter'
ORDER BY p.id ASC;

-- Aufgabe 6.4
-- Erweitern Sie die Abfrage aus Aufgabe 6.3, indem Sie zusätzlich die Bezeichnung 
-- der Abteilung in das Ergebnis einbauen.
--
-- Erwartetes Ergebnis:
-- id  kuerzel  bezeichnung  mittel     kunde_id  nachname  einst_dat   bezeichnung
-- 1   AP       Apollo       120000,00  3         Huber     2018-10-01  Freigabe
-- 3   MK       Merkur       186500,00  1         Kaufmann  2019-10-15  Diagnose
-- 4   PL       Pluto        88500,00   4         Schäfer   2018-07-20  Freigabe
-- 5   AR       Ariane       165000,00  2         Vogel     2019-01-01  Einkauf

SELECT p.id, p.kuerzel, p.bezeichnung AS pro_bezeichnung, p.mittel, p.kunde_id, m.nachname, a.einst_dat, abt.bezeichnung AS abt_bezeichnung
FROM Projekt AS p
INNER JOIN Arbeit AS a ON p.id = a.pro_id
INNER JOIN Mitarbeiter AS m ON a.mit_id = m.id
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id
WHERE a.aufgabe = 'Projektleiter'
ORDER BY p.id ASC;

-- Aufgabe 6.5
-- Erstellen Sie eine Abfrage, die die Mitarbeiter mit allen zusätzlichen Informationen 
-- zu Abteilung, Gehalt, Arbeit und Projekt ausgibt. Geben Sie dabei keine Spalten doppelt aus.
--
-- Erwartetes Ergebnis: 20 Zeilen

SELECT m.id, m.nachname, m.vorname, m.abt_id, m.ort, m.chef_id,
       abt.kuerzel, abt.bezeichnung AS abt_bezeichnung, abt.ort AS abt_ort,
       g.gehalt,
       arb.aufgabe, arb.einst_dat,
       p.id AS pro_id, p.bezeichnung AS pro_bezeichnung, p.kunde_id
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id
INNER JOIN Gehalt AS g ON m.id = g.mit_id
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Projekt AS p ON arb.pro_id = p.id;

-- Aufgabe 6.6
-- Geben Sie für die Projekte die mit "A" beginnen die unten gezeigten Informationen aus. 
-- Sortieren Sie die Ausgabe nach dem Projektnamen aufsteigend und der Mitarbeiter-Id absteigend.
--
-- Erwartetes Ergebnis:
-- bezeichnung  firma                    mit_id  aufgabe
-- Apollo       Frankreich-Reisen GmbH   29346   Sachbearbeiter
-- Apollo       Frankreich-Reisen GmbH   28559   NULL
-- Apollo       Frankreich-Reisen GmbH   17000   NULL
-- Apollo       Frankreich-Reisen GmbH   10102   Projektleiter
-- Apollo       Frankreich-Reisen GmbH   9031    Gruppenleiter
-- Ariane       Technische Produkte oHG  22222   Projektleiter
-- Ariane       Technische Produkte oHG  17000   NULL
-- Ariane       Technische Produkte oHG  9912    Sachbearbeiter

SELECT p.bezeichnung, k.firma, arb.mit_id, arb.aufgabe
FROM Projekt AS p
INNER JOIN Kunde AS k ON p.kunde_id = k.id
INNER JOIN Arbeit AS arb ON p.id = arb.pro_id
WHERE p.bezeichnung LIKE 'A%'
ORDER BY p.bezeichnung ASC, arb.mit_id DESC;

-- Aufgabe 6.7
-- Finden Sie Namen und Vornamen aller Mitarbeiter, die im Projekt Merkur arbeiten.
--
-- Erwartetes Ergebnis:
-- nachname  vorname
-- Kaufmann  Brigitte
-- Meier     Rainer
-- Huber     Petra
-- Schubert  Rolf

SELECT m.nachname, m.vorname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Projekt AS p ON arb.pro_id = p.id
WHERE p.bezeichnung = 'Merkur';

-- Aufgabe 6.8
-- Nennen Sie Namen und Vornamen aller Projektleiter, deren Abteilung den Standort München hat.
--
-- Erwartetes Ergebnis:
-- nachname  vorname
-- Kaufmann  Brigitte
-- Vogel     Anke

SELECT m.nachname, m.vorname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS arb ON m.id = arb.mit_id
INNER JOIN Abteilung AS abt ON m.abt_id = abt.id
WHERE arb.aufgabe = 'Projektleiter' 
  AND abt.ort = 'München';

GO
