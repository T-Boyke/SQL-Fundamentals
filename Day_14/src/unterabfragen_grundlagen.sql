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
-- 1.6 Besondere Mengen-Vergleichsoperatoren: ALL, ANY und SOME
-- ------------------------------------------------------------------------------

-- A) ALL-Operator: Bedingung muss für ALLE Elemente der Subquery TRUE sein.
-- Beispiel: Finde den Mitarbeiter mit der kleinsten ID innerhalb jeder Abteilung
-- (Minimum pro Gruppe ohne GROUP BY mit vollständigen Datensätzen)
SELECT *
FROM Mitarbeiter AS m1
WHERE id <= ALL (
    SELECT id
    FROM Mitarbeiter AS m2
    WHERE m2.abt_id = m1.abt_id
);

-- Äquivalente Abfrage mit ANY (entspricht IN / kleiner als Maximum):
-- Wer verdient mehr als mindestens ein Mitarbeiter der Abteilung 2?
SELECT vorname, nachname, gehalt
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS g ON m.id = g.mit_id
WHERE gehalt > ANY (
    SELECT gehalt
    FROM Gehalt
    INNER JOIN Mitarbeiter ON Gehalt.mit_id = Mitarbeiter.id
    WHERE abt_id = 2
);

-- ------------------------------------------------------------------------------
-- 1.7 Der EXISTS und NOT EXISTS Operator (Prüfung auf Zeilen-Existenz)
-- ------------------------------------------------------------------------------

-- A) EXISTS: Liefert TRUE, wenn die Subquery mindestens 1 Zeile liefert
-- Finde alle Mitarbeiter, die in mindestens einem Projekt arbeiten:
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
WHERE EXISTS (
    SELECT 1
    FROM Arbeit AS a
    WHERE a.mit_id = m.id
);

-- B) NOT EXISTS: Liefert TRUE, wenn die Subquery 0 Zeilen liefert
-- Finde alle Mitarbeiter, die noch NIE einen Umsatz verbucht haben (sicher vor NULL-Werten):
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM Umsatz AS u
    WHERE u.mit_id = m.id
);

-- Finde alle Abteilungen, denen kein Mitarbeiter zugeordnet ist:
SELECT abt.id, abt.bezeichnung
FROM Abteilung AS abt
WHERE NOT EXISTS (
    SELECT 1
    FROM Mitarbeiter AS m
    WHERE m.abt_id = abt.id
);

-- ------------------------------------------------------------------------------
-- 1.8 DML-Unterabfragen: INSERT, UPDATE & DELETE
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


/* ==============================================================================
   TEIL 3: PRAKTISCHE ÜBUNGEN (ProjektDB 05 - Subqueries 2: Korrelierte Unterabfragen)
   ============================================================================== */

-- ------------------------------------------------------------------------------
-- Aufgabe 5.9:
-- Geben Sie eine Liste der Projekt-Ids und Aufgaben aus und nennen Sie dazu den Namen des Mitarbeiters.
-- Sortieren Sie die Ausgabe nach Projekt-Id und Aufgabe.
-- Nutzen Sie eine korrelierte Unterabfrage im SELECT.
-- Erwartetes Ergebnis: 20 Zeilen (pro_id, aufgabe, nachname)
-- ------------------------------------------------------------------------------
SELECT pro_id, 
       aufgabe,
       (SELECT nachname 
        FROM Mitarbeiter 
        WHERE id = Arbeit.mit_id) AS nachname
FROM Arbeit
ORDER BY pro_id, aufgabe;

-- ------------------------------------------------------------------------------
-- Aufgabe 5.10:
-- Erweitern Sie die Abfrage aus Aufgabe 5.9 und geben Sie zusätzlich auch den Projektnamen aus.
-- Nutzen Sie zwei korrelierte Unterabfragen im SELECT.
-- Erwartetes Ergebnis: 20 Zeilen (pro_id, bezeichnung, aufgabe, nachname)
-- ------------------------------------------------------------------------------
SELECT pro_id,
       (SELECT bezeichnung 
        FROM Projekt 
        WHERE id = Arbeit.pro_id) AS bezeichnung,
       aufgabe,
       (SELECT nachname 
        FROM Mitarbeiter 
        WHERE id = Arbeit.mit_id) AS nachname
FROM Arbeit
ORDER BY pro_id, aufgabe;

-- ------------------------------------------------------------------------------
-- Aufgabe 5.11:
-- Geben Sie eine Liste aller Abteilungsnamen aus. Geben Sie dazu aus, wie viele Mitarbeiter in der Abteilung arbeiten.
-- Nutzen Sie eine korrelierte Unterabfrage im SELECT.
-- Erwartetes Ergebnis: Beratung (2), Diagnose (3), Freigabe (3), Einkauf (4), Verkauf (3)
-- ------------------------------------------------------------------------------
SELECT bezeichnung,
       (SELECT COUNT(*) 
        FROM Mitarbeiter 
        WHERE abt_id = Abteilung.id) AS anzahl
FROM Abteilung;

-- ------------------------------------------------------------------------------
-- Aufgabe 5.12:
-- Geben Sie eine Liste aller Mitarbeiter-Ids mit Gehalt aus.
-- Geben Sie dazu auch den Namen des Mitarbeiters aus.
-- Nutzen Sie eine korrelierte Unterabfrage im SELECT.
-- Erwartetes Ergebnis: 15 Zeilen (mit_id, nachname, gehalt)
-- ------------------------------------------------------------------------------
SELECT mit_id,
       (SELECT nachname 
        FROM Mitarbeiter 
        WHERE id = Gehalt.mit_id) AS nachname,
       gehalt
FROM Gehalt;

-- ------------------------------------------------------------------------------
-- Aufgabe 5.13:
-- Erweitern Sie die Abfrage aus Aufgabe 5.12 und geben Sie zusätzlich noch das Durchschnitts-Gehalt
-- aller Mitarbeiter aus. Zeigen Sie anschließend noch die Differenz des Mitarbeiters zum Durchschnitt an.
-- Erwartetes Ergebnis: 15 Zeilen (mit_id, nachname, gehalt, durchschnitt, differenz)
-- ------------------------------------------------------------------------------
SELECT mit_id,
       (SELECT nachname 
        FROM Mitarbeiter 
        WHERE id = Gehalt.mit_id) AS nachname,
       gehalt,
       (SELECT AVG(gehalt) FROM Gehalt) AS durchschnitt,
       gehalt - (SELECT AVG(gehalt) FROM Gehalt) AS differenz
FROM Gehalt;

-- ------------------------------------------------------------------------------
-- Aufgabe 5.14:
-- Zeigen Sie die Mitarbeiternamen und Abteilungsnamen der Mitarbeiter an, die im Projekt "Apollo" arbeiten.
-- Nutzen Sie zwei verschachtelte Unterabfragen und eine korrelierte Unterabfrage im SELECT.
-- Erwartetes Ergebnis: Meier (Diagnose), Huber (Freigabe), Krüger (Verkauf), Mozer (Beratung), Probst (Diagnose)
-- ------------------------------------------------------------------------------
SELECT nachname,
       (SELECT bezeichnung 
        FROM Abteilung 
        WHERE id = Mitarbeiter.abt_id) AS abteilung
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
GO

