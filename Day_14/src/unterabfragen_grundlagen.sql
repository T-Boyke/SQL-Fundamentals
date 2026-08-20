/* ==============================================================================
   SQL-Fundamentals: Day 14 - Unterabfragen (Subqueries / Subselects)
   Datenbank: ProjektDB
   Autor: Tobias Boyke
   Dozent: Tom S.
   Datum: 20.08.2026
   ============================================================================== */

USE ProjektDB;
GO

/* ==============================================================================
   TEIL 1: VORLESUNGSBEISPIELE & DEMO-SKRIPTE
   ============================================================================== */

-- ------------------------------------------------------------------------------
-- 1.1 Subquery in der SELECT-Klausel (Skalare Unterabfrage)
-- ------------------------------------------------------------------------------

-- Zwei-Schritt-Verfahren (manuell):
-- Schritt 1: Durchschnittsgehalt ermitteln
SELECT AVG(gehalt) AS durchschnitt
FROM Gehalt;
-- Ergebnis: z. B. 3633.3333

-- Schritt 2: Statischen Wert in Abfrage einsetzen
SELECT *, 3633.3333 AS durchschnitt
FROM Gehalt;

-- Ein-Schritt-Verfahren (dynamisch mit skalarer Subquery):
SELECT *, 
       (SELECT AVG(gehalt) FROM Gehalt) AS durchschnitt
FROM Gehalt;

-- Mathematische Berechnung mit der Subquery (Differenz zum Durchschnitt):
SELECT *, 
       gehalt - (SELECT AVG(gehalt) FROM Gehalt) AS differenz
FROM Gehalt;

-- ------------------------------------------------------------------------------
-- 1.2 Korrelierte Unterabfrage in der SELECT-Klausel
-- ------------------------------------------------------------------------------
-- Die innere Abfrage greift auf Werte der äußeren Abfrage zu (Gehalt.mit_id)
SELECT *, 
       gehalt - (SELECT AVG(gehalt) FROM Gehalt) AS differenz,
       (SELECT CONCAT(vorname, ' ', nachname) 
        FROM Mitarbeiter 
        WHERE id = Gehalt.mit_id) AS name
FROM Gehalt;

-- ------------------------------------------------------------------------------
-- 1.3 Subquery in der WHERE-Klausel (Mehrwertige Unterabfrage mit IN)
-- ------------------------------------------------------------------------------

-- Zwei-Schritt-Verfahren:
-- Schritt 1: Abteilungs-IDs in München ermitteln (1, 2, 4)
SELECT id
FROM Abteilung
WHERE ort = 'München';

-- Schritt 2: Mitarbeiter dieser Abteilungen filtern
SELECT * 
FROM Mitarbeiter
WHERE abt_id IN (1, 2, 4);

-- Ein-Schritt-Verfahren mit Subquery:
SELECT *
FROM Mitarbeiter
WHERE abt_id IN (SELECT id 
                 FROM Abteilung 
                 WHERE ort = 'München');

-- ------------------------------------------------------------------------------
-- 1.4 Korrelierte Unterabfrage in der WHERE-Klausel
-- ------------------------------------------------------------------------------
-- Finde alle Mitarbeiter mit mehr als 5 getätigten Umsätzen
SELECT *
FROM Mitarbeiter AS m
WHERE (SELECT COUNT(*) 
       FROM Umsatz AS u 
       WHERE u.mit_id = m.id) > 5;

-- ------------------------------------------------------------------------------
-- 1.5 Unterabfrage in der FROM-Klausel (Derived Table / Virtuelle Tabelle)
-- ------------------------------------------------------------------------------
-- WICHTIG: In T-SQL ist der Alias ('AS team') zwingend vorgeschrieben!
SELECT team.nachname, team.gehalt
FROM (
    SELECT id, nachname, gehalt, abt_id 
    FROM Mitarbeiter 
    WHERE gehalt > 3000
) AS team
WHERE team.abt_id = 2;

-- ------------------------------------------------------------------------------
-- 1.6 DML-Unterabfragen: INSERT, UPDATE & DELETE
-- ------------------------------------------------------------------------------

-- A) INSERT INTO ... SELECT (ohne VALUES)
-- INSERT INTO Mitarbeiter_Archiv (id, nachname, vorname)
-- SELECT id, nachname, vorname 
-- FROM Mitarbeiter 
-- WHERE abt_id = 3;

-- B) UPDATE mit Subquery
-- UPDATE Mitarbeiter
-- SET gehalt = gehalt * 1.10
-- WHERE id IN (
--     SELECT mit_id 
--     FROM Arbeit 
--     WHERE pro_id = (SELECT id FROM Projekt WHERE bezeichnung = 'Apollo')
-- );

-- C) DELETE mit Subquery
-- DELETE FROM Umsatz
-- WHERE mit_id IN (
--     SELECT id 
--     FROM Mitarbeiter 
--     WHERE abt_id = (SELECT id FROM Abteilung WHERE bezeichnung = 'Marketing')
-- );
GO


/* ==============================================================================
   TEIL 2: PRAKTISCHE ÜBUNGEN (ProjektDB 05 - Subqueries 1)
   ============================================================================== */

-- ------------------------------------------------------------------------------
-- Aufgabe 5.1:
-- Nennen Sie Personalnummer und Name des Mitarbeiters mit der kleinsten Personalnummer.
-- Nutzen Sie eine einfache Unterabfrage.
-- Erwartetes Ergebnis: id = 2581, nachname = Kaufmann
-- ------------------------------------------------------------------------------
SELECT id, nachname
FROM Mitarbeiter
WHERE id = (SELECT MIN(id) FROM Mitarbeiter);

-- ------------------------------------------------------------------------------
-- Aufgabe 5.2:
-- Nennen Sie die Abteilungsnummern der Mitarbeiter, die in Projekt 3 arbeiten.
-- Nutzen Sie eine einfache Unterabfrage.
-- Erwartetes Ergebnis: a2, a2, a3, a5 (bzw. 2, 2, 3, 5)
-- ------------------------------------------------------------------------------
SELECT abt_id
FROM Mitarbeiter
WHERE id IN (SELECT mit_id 
             FROM Arbeit 
             WHERE pro_id = 3);

-- ------------------------------------------------------------------------------
-- Aufgabe 5.3:
-- Erstellen Sie eine Liste der Ids aller Mitarbeiter, deren Gehalt über dem Durchschnitt liegt.
-- Nutzen Sie eine einfache Unterabfrage.
-- Erwartetes Ergebnis: mit_id: 5765, 9031, 17000, 22222, 28559, 29346
-- ------------------------------------------------------------------------------
SELECT mit_id
FROM Gehalt
WHERE gehalt > (SELECT AVG(gehalt) FROM Gehalt);

-- ------------------------------------------------------------------------------
-- Aufgabe 5.4:
-- Nennen Sie die Nummern aller Projekte, in denen Mitarbeiter arbeiten,
-- deren Personalnummer kleiner als die Nummer des Mitarbeiters namens Müller ist.
-- Nutzen Sie eine einfache Unterabfrage.
-- Erwartetes Ergebnis: pro_id: 1, 3, 4, 5
-- ------------------------------------------------------------------------------
SELECT DISTINCT pro_id
FROM Arbeit
WHERE mit_id < (SELECT id 
                FROM Mitarbeiter 
                WHERE nachname = 'Müller');

-- ------------------------------------------------------------------------------
-- Aufgabe 5.5:
-- Nennen Sie die Namen aller Mitarbeiter, die in einer Abteilung in Ulm arbeiten.
-- Nutzen Sie eine einfache Unterabfrage.
-- Erwartetes Ergebnis: Krüger Martin, Schubert Rolf, Albrecht Lena
-- ------------------------------------------------------------------------------
SELECT nachname, vorname
FROM Mitarbeiter
WHERE abt_id IN (SELECT id 
                 FROM Abteilung 
                 WHERE ort = 'Ulm');

-- ------------------------------------------------------------------------------
-- Aufgabe 5.6:
-- Finden Sie die Personalnummer des Projektleiters, der in dieser Position als letzter eingestellt wurde.
-- Nutzen Sie eine einfache Unterabfrage.
-- Erwartetes Ergebnis: mit_id = 2581
-- ------------------------------------------------------------------------------
SELECT mit_id
FROM Arbeit
WHERE aufgabe = 'Projektleiter' 
  AND beginn = (SELECT MAX(beginn) 
                FROM Arbeit 
                WHERE aufgabe = 'Projektleiter');

-- ------------------------------------------------------------------------------
-- Aufgabe 5.7:
-- Nennen Sie die Namen aller Mitarbeiter, die im Projekt "Apollo" arbeiten.
-- Nutzen Sie zwei verschachtelte Unterabfragen.
-- Erwartetes Ergebnis: Meier, Huber, Krüger, Mozer, Probst
-- ------------------------------------------------------------------------------
SELECT nachname
FROM Mitarbeiter
WHERE id IN (
    SELECT mit_id
    FROM Arbeit
    WHERE pro_id = (
        SELECT id
        FROM Projekt
        WHERE bezeichnung = 'Apollo'
    )
);

-- ------------------------------------------------------------------------------
-- Aufgabe 5.8:
-- Zeigen Sie Abteilungsnummer und den Namen der Abteilungen für die Mitarbeiter an,
-- die am Projekt "Apollo" mitarbeiten.
-- Nutzen Sie drei verschachtelte Unterabfragen.
-- Erwartetes Ergebnis: 1 Beratung, 2 Diagnose, 3 Freigabe, 5 Verkauf
-- ------------------------------------------------------------------------------
SELECT id, bezeichnung
FROM Abteilung
WHERE id IN (
    SELECT abt_id
    FROM Mitarbeiter
    WHERE id IN (
        SELECT mit_id
        FROM Arbeit
        WHERE pro_id = (
            SELECT id
            FROM Projekt
            WHERE bezeichnung = 'Apollo'
        )
    )
);
GO
