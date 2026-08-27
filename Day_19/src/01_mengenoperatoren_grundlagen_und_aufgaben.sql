-- ============================================================================
-- 📅 Day_19: Mengenoperatoren (Set Operators: UNION, INTERSECT, EXCEPT)
-- Datei: Day_19/src/01_mengenoperatoren_grundlagen_und_aufgaben.sql
-- Autor: Tobias Boyke
-- Datum: 27.08.2026
-- Dozent: Tom S.
-- Single Source of Truth: ProjektDB
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📚 THEORETISCHE GRUNDREGELN FÜR MENGENOPERATOREN
-- ============================================================================
-- 1. Gleiche Spaltenanzahl: Alle SELECT-Abfragen müssen exakt dieselbe Anzahl
--    an Ausgabespalten besitzen.
-- 2. Kompatible Datentypen: Korrespondierende Spalten müssen vom selben oder
--    einem implizit konvertierbaren Datentyp sein (Type Precedence).
-- 3. Spaltennamen-Vererbung: Die Spaltenbezeichnungen der ERSTEN SELECT-Abfrage
--    bestimmen die Überschriften der gesamten Ergebnismenge.
-- 4. Globales ORDER BY: Eine Sortierung (ORDER BY) darf NUR EINMAL ganz am
--    Ende des gesamten Statements stehen.
-- 5. NULL-Gleichheit: Mengenoperatoren betrachten NULL = NULL (im Gegensatz zu
--    Standard-WHERE-Vergleichen mit 3VL).
-- ============================================================================


-- ============================================================================
-- 📝 Aufgabe 10.1: UNION (Eindeutige Städte aus Mitarbeiter und Abteilung)
--
-- Aufgabenstellung:
-- Erstellen Sie eine Liste mit allen Städten, in denen entweder ein Mitarbeiter
-- wohnt oder aber eine Abteilung ihren Sitz hat. Jede Stadt soll nur einmal
-- angezeigt werden.
--
-- Erwartetes Ergebnis: 9 Zeilen (inkl. NULL)
-- ============================================================================

SELECT ort
FROM Mitarbeiter
UNION
SELECT ort
FROM Abteilung;
GO


-- ============================================================================
-- 📝 Aufgabe 10.2: UNION ALL (Alle Städte aus Mitarbeiter und Kunde mit Duplikaten)
--
-- Aufgabenstellung:
-- Erstellen Sie eine Liste mit allen Städten, in denen entweder Mitarbeiter
-- wohnen oder Kunden ihren Sitz haben. Doppelte Einträge sollen nicht
-- weggefiltert werden.
--
-- Erwartetes Ergebnis: 21 Zeilen (15 Mitarbeiter + 6 Kunden)
-- ============================================================================

SELECT ort
FROM Mitarbeiter
UNION ALL
SELECT ort
FROM Kunde;
GO


-- ============================================================================
-- 📝 Aufgabe 10.3: UNION ALL mit globaler Sortierung (ORDER BY)
--
-- Aufgabenstellung:
-- Geben Sie die Liste aus Aufgabe 10.2 jetzt sortiert nach dem Städtenamen aus.
--
-- Erwartetes Ergebnis: 21 Zeilen (NULLs zuerst, gefolgt von alphabetischer Reihenfolge)
-- ============================================================================

SELECT ort
FROM Mitarbeiter
UNION ALL
SELECT ort
FROM Kunde
ORDER BY ort ASC;
GO


-- ============================================================================
-- 📝 Aufgabe 10.4: UNION mit Filterbedingungen und Aliasing
--
-- Aufgabenstellung:
-- Finden Sie die Ids der Mitarbeiter, die entweder der Abteilung a1 (id = 1)
-- angehören oder nach dem 1.1.2019 in ihr Projekt eingetreten sind.
-- Die Ids sollen aufsteigend sortiert ausgegeben werden.
--
-- Erwartetes Ergebnis: 7 Zeilen (2581, 9031, 9912, 17000, 18316, 28559, 29346)
-- ============================================================================

-- Variante 1: Reiner UNION-Mengenoperator
SELECT id
FROM Mitarbeiter
WHERE abt_id = 1
UNION
SELECT mit_id AS id
FROM Arbeit
WHERE einst_dat > '2019-01-01'
ORDER BY id ASC;
GO

-- Variante 2: Vergleichslösung mit Subquery und OR
SELECT id
FROM Mitarbeiter
WHERE abt_id = 1
   OR id IN (
       SELECT mit_id
       FROM Arbeit
       WHERE einst_dat > '2019-01-01'
   )
ORDER BY id ASC;
GO


-- ============================================================================
-- 📝 Aufgabe 10.5: Der Mengenoperatoren-Vierklang (Mitarbeiter- vs. Abteilungssitz)
--
-- Aufgabenstellung:
-- Die Wohnorte der Mitarbeiter und die Standorte der Abteilungen sollen
-- ausgewertet werden:
-- a) Orte, an denen entweder Mitarbeiter wohnen oder Abteilungen sind. (UNION)
-- b) Orte, an denen sowohl Mitarbeiter als auch Abteilungen sind. (INTERSECT)
-- c) Orte, an denen Mitarbeiter wohnen, aber keine Abteilungen sind. (EXCEPT)
-- d) Orte, an denen Abteilungen sind, aber keine Mitarbeiter wohnen. (EXCEPT)
-- ============================================================================

-- a) Vereinigungsmenge (UNION -> 9 Zeilen)
SELECT ort
FROM Mitarbeiter
UNION
SELECT ort
FROM Abteilung;
GO

-- b) Schnittmenge (INTERSECT -> 2 Zeilen: München, Ulm)
SELECT ort
FROM Mitarbeiter
INTERSECT
SELECT ort
FROM Abteilung;
GO

-- c) Differenzmenge Mitarbeiter \ Abteilung (EXCEPT -> 6 Zeilen: NULL, Augsburg, Fürth, Heidenheim, Landshut, Rosenheim)
SELECT ort
FROM Mitarbeiter
EXCEPT
SELECT ort
FROM Abteilung;
GO

-- d) Differenzmenge Abteilung \ Mitarbeiter (EXCEPT -> 1 Zeile: Stuttgart)
SELECT ort
FROM Abteilung
EXCEPT
SELECT ort
FROM Mitarbeiter;
GO


-- ============================================================================
-- 📝 Aufgabe 10.6: INTERSECT (Mitarbeiter in Projekt 1 UND Projekt 3)
--
-- Aufgabenstellung:
-- Erstellen Sie eine Liste der Mitarbeiter, die sowohl im Projekt 1 als auch
-- im Projekt 3 arbeiten.
--
-- Erwartetes Ergebnis: Petra Huber, Rainer Meier
-- ============================================================================

-- Variante 1: INTERSECT über gejointe Tabellen
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.pro_id = 1
INTERSECT
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.pro_id = 3;
GO

-- Variante 2: INTERSECT auf ID-Ebene mit anschließendem Stammdaten-Join
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
WHERE m.id IN (
    SELECT a1.mit_id
    FROM Arbeit AS a1
    WHERE a1.pro_id = 1
    INTERSECT
    SELECT a2.mit_id
    FROM Arbeit AS a2
    WHERE a2.pro_id = 3
);
GO


-- ============================================================================
-- 📝 Aufgabe 10.7: INTERSECT vs. EXCEPT (Projekt 4/5 und Gehalt < 4000)
--
-- Aufgabenstellung:
-- Erstellen Sie eine Liste der Mitarbeiter, die in den Projekten 4 oder 5
-- arbeiten und weniger als 4000 verdienen.
-- a) Nutzen Sie den INTERSECT-Operator
-- b) Nutzen Sie den EXCEPT-Operator
--
-- Erwartetes Ergebnis: Dirk Fuchs, Klaus Wolf, Lena Albrecht, Ursula Richter
-- ============================================================================

-- Teil a) Lösung mit INTERSECT
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.pro_id IN (4, 5)
INTERSECT
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS g ON m.id = g.mit_id
WHERE g.gehalt < 4000.00;
GO

-- Teil b) Lösung mit EXCEPT (Projekt 4/5 OHNE Gehalt >= 4000)
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.pro_id IN (4, 5)
EXCEPT
SELECT m.vorname,
       m.nachname
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS g ON m.id = g.mit_id
WHERE g.gehalt >= 4000.00;
GO


-- ============================================================================
-- 📝 Aufgabe 10.8: UNION ALL (Mitarbeiter- und Kundenliste konsolidieren)
--
-- Aufgabenstellung:
-- Erstellen Sie eine Liste aller Mitarbeiter, kombiniert mit einer Liste
-- aller Kunden. Geben Sie Firma bzw. Namen und die Stadt aus.
--
-- Erwartetes Ergebnis: 21 Zeilen
-- ============================================================================

SELECT CONCAT(vorname, ' ', nachname) AS firma,
       ort
FROM Mitarbeiter
UNION ALL
SELECT firma,
       ort
FROM Kunde;
GO


-- ============================================================================
-- 📝 Aufgabe 10.9: Dreifacher UNION ALL (Mitarbeiter + Kunden + Abteilungen)
--
-- Aufgabenstellung:
-- Erweitern Sie die Abfrage aus Aufgabe 10.8 und geben Sie auch noch die
-- Abteilungen mit Bezeichnung und Stadt in der Liste aus.
--
-- Erwartetes Ergebnis: 26 Zeilen (15 Mitarbeiter + 6 Kunden + 5 Abteilungen)
-- ============================================================================

SELECT CONCAT(vorname, ' ', nachname) AS bezeichnung,
       ort
FROM Mitarbeiter
UNION ALL
SELECT firma AS bezeichnung,
       ort
FROM Kunde
UNION ALL
SELECT bezeichnung,
       ort
FROM Abteilung;
GO


-- ============================================================================
-- 📝 Aufgabe 10.10: UNION ALL mit statischer Kategorisierung
--
-- Aufgabenstellung:
-- Um die Übersichtlichkeit zu erhöhen, soll in der Liste markiert werden,
-- ob es sich um eine Abteilung, einen Mitarbeiter oder einen Kunden handelt.
--
-- Erwartetes Ergebnis: 26 Zeilen mit Spalten: bezeichnung, ort, kategorie
-- ============================================================================

SELECT CONCAT(vorname, ' ', nachname) AS bezeichnung,
       ort,
       'Mitarbeiter' AS kategorie
FROM Mitarbeiter
UNION ALL
SELECT firma AS bezeichnung,
       ort,
       'Kunde' AS kategorie
FROM Kunde
UNION ALL
SELECT bezeichnung,
       ort,
       'Abteilung' AS kategorie
FROM Abteilung;
GO
