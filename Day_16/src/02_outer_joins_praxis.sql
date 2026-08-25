-- ============================================================================
-- 📅 Day_16: OUTER JOINs (LEFT, RIGHT, FULL OUTER JOIN) & Anti-Joins
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 24.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 TEIL 1: INNER vs. LEFT OUTER JOIN (Grundlegendes Prinzip)
-- ============================================================================

-- 1.1 INNER JOIN: Zeigt NUR Kunden, die mindestens 1 Projekt haben.
-- Kunde '100% Sonderzeichen AG' (ID 6) hat KEIN Projekt und fällt weg! (5 Zeilen)
SELECT k.id AS kunde_id, k.firma, p.id AS projekt_id, p.bezeichnung AS projekt
FROM Kunde AS k
INNER JOIN Projekt AS p ON k.id = p.kunde_id;
GO

-- 1.2 LEFT JOIN: Behält ALLE Kunden (auch ohne Projekt).
-- '100% Sonderzeichen AG' erscheint mit projekt_id = NULL und projekt = NULL! (6 Zeilen)
SELECT k.id AS kunde_id, k.firma, p.id AS projekt_id, p.bezeichnung AS projekt
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id;
GO

-- ============================================================================
-- 📝 TEIL 2: RIGHT OUTER JOIN vs. FULL OUTER JOIN
-- ============================================================================

-- 2.1 RIGHT JOIN: Behält alle Zeilen der RECHTEN Tabelle.
-- (Aus didaktischer Sicht entspricht 'A LEFT JOIN B' exakt 'B RIGHT JOIN A')
SELECT k.firma, p.bezeichnung AS projekt
FROM Projekt AS p
RIGHT JOIN Kunde AS k ON p.kunde_id = k.id; -- noqa: CV08
GO

-- 2.2 FULL OUTER JOIN: Die vollständige Vereinigung.
-- Behält alle Zeilen aus BEIDEN Tabellen. Fehlende Partner werden mit NULL aufgefüllt.
SELECT m.nachname, u.datum, u.umsatz
FROM Mitarbeiter AS m
FULL OUTER JOIN Umsatz AS u ON m.id = u.mit_id;
GO

-- ============================================================================
-- 📝 TEIL 3: ANTI-JOIN (Exklusion / Suche nach verwaisten Datensätzen)
-- ============================================================================

-- 3.1 Finde Kunden, die bisher KEIN Projekt beauftragt haben
SELECT k.id, k.firma, k.ort
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id
WHERE p.id IS NULL;
GO

-- 3.2 Finde Mitarbeiter, die noch KEINEN Umsatz erzielt haben
SELECT m.id, m.nachname, m.vorname
FROM Mitarbeiter AS m
LEFT JOIN Umsatz AS u ON m.id = u.mit_id
WHERE u.id IS NULL;
GO

-- ============================================================================
-- 📝 TEIL 4: DER GROSSE KLASSIKER: 'ON' vs. 'WHERE' BEIM LEFT JOIN
-- ============================================================================

-- ⚠️ SZENARIO: Wir wollen ALLE Kunden sehen und dazu ihre Projekte mit Budget >= 100.000 €.
-- Kunden mit kleineren Projekten oder ohne Projekte sollen trotzdem in der Liste bleiben!

-- 4.1 RICHTIG: Filterbedingung im 'ON'
-- Die Bedingung 'p.mittel >= 100000' entscheidet nur darüber, OB ein Projekt gejoint wird.
-- Alle 6 Kunden bleiben im Ergebnis erhalten!
SELECT k.firma, p.bezeichnung, p.mittel
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id 
                      AND p.mittel >= 100000;
GO

-- 4.2 FALSCH (Häufiger Bug!): Filterbedingung im 'WHERE'
-- Das 'WHERE p.mittel >= 100000' wird NACH dem Join ausgeführt.
-- Da NULL >= 100000 UNKNOWN ergibt, fliegen alle Kunden ohne passendes Projekt raus!
-- Der LEFT JOIN wurde unbemerkt zu einem INNER JOIN degradiert!
SELECT k.firma, p.bezeichnung, p.mittel
FROM Kunde AS k
LEFT JOIN Projekt AS p ON k.id = p.kunde_id
WHERE p.mittel >= 100000;
GO
