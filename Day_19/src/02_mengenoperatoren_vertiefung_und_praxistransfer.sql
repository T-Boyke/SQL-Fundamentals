-- ============================================================================
-- 📅 Day_19: Fortgeschrittene Mengenoperatoren, Performance & Praxistransfer
-- Datei: Day_19/src/02_mengenoperatoren_vertiefung_und_praxistransfer.sql
-- Autor: Tobias Boyke
-- Datum: 27.08.2026
-- Dozent: Tom S.
-- Single Source of Truth: ProjektDB
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 1. OPERATOR-PRÄZEDENZ & KLAMMERUNG BEI MENGENOPERATOREN
-- ============================================================================
-- In SQL Server / ANSI SQL hat INTERSECT eine HÖHERE Priorität als UNION
-- und EXCEPT.
-- Standard-Reihenfolge: A UNION B INTERSECT C wird ausgewertet als:
-- A UNION (B INTERSECT C).
-- Durch Klammern (...) kann die Auswertungsreihenfolge explizit erzwungen werden!
-- ============================================================================

-- Beispiel: Mitarbeiter aus Abt 1 UNION Mitarbeiter aus Landshut INTERSECT Projekt 1
-- Ohne Klammern: Erst (Landshut INTERSECT Projekt 1), dann UNION mit Abt 1
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
WHERE m.abt_id = 1
UNION
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
WHERE m.ort = 'Landshut'
INTERSECT
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.pro_id = 1;
GO

-- Mit expliziter Klammerung: (Abt 1 UNION Landshut) INTERSECT Projekt 1
(
    SELECT m.id, m.vorname, m.nachname
    FROM Mitarbeiter AS m
    WHERE m.abt_id = 1
    UNION
    SELECT m.id, m.vorname, m.nachname
    FROM Mitarbeiter AS m
    WHERE m.ort = 'Landshut'
)
INTERSECT
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.pro_id = 1;
GO


-- ============================================================================
-- 2. NULL-WERTE IN MENGENOPERATOREN (NULL = NULL GLEICHHEIT)
-- ============================================================================
-- Im regulären WHERE führt 'NULL = NULL' zu UNKNOWN (3VL).
-- In Mengenoperatoren (UNION, INTERSECT, EXCEPT) gelten NULL-Werte jedoch
-- als IDENTISCH und werden dedupliziert bzw. abgeglichen!
-- ============================================================================

-- Demonstration: Mitarbeiter ohne Wohnort (ort IS NULL) im Mengenabgleich
SELECT ort
FROM Mitarbeiter
WHERE ort IS NULL
UNION
SELECT ort
FROM Mitarbeiter
WHERE ort IS NULL;
-- Ergebnis: Genau 1 Zeile mit NULL (Deduplizierung greift trotz NULL!)
GO


-- ============================================================================
-- 3. PRAXIS-TRANSFER: DELTA-DETEKTION & TABELLEN-VERGLEICH (AUDIT PATTERN)
-- ============================================================================
-- Mit EXCEPT lässt sich in Sekunden ermitteln, ob zwei Tabellen oder
-- Abfrageergebnisse exakt identisch sind oder wo Abweichungen vorliegen.
-- ============================================================================

-- Prüfen: Gibt es Kundenstandorte, die weder als Mitarbeiterwohnort noch
-- als Abteilungsstandort existieren?
SELECT ort FROM Kunde
EXCEPT
(
    SELECT ort FROM Mitarbeiter
    UNION
    SELECT ort FROM Abteilung
);
-- Ergebnis: Baden_Baden (Einziger Kundenstandort ohne Firmenpräsenz)
GO


-- ============================================================================
-- 4. VERGLEICH: MENGENOPERATOREN VS. JOINS & SUBQUERIES (ÄQUIVALENZMUSTER)
-- ============================================================================

-- Szenario: Alle Mitarbeiter finden, die in KEINEM Projekt arbeiten (Anti-Join)

-- Variante A: Mit EXCEPT (Mengenoperation)
SELECT id, vorname, nachname
FROM Mitarbeiter
EXCEPT
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS a ON m.id = a.mit_id;
GO

-- Variante B: Mit NOT EXISTS (Korrelierte Subquery)
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM Arbeit AS a
    WHERE a.mit_id = m.id
);
GO

-- Variante C: Mit LEFT JOIN ... WHERE a.mit_id IS NULL (Outer Join Anti-Pattern)
SELECT m.id, m.vorname, m.nachname
FROM Mitarbeiter AS m
LEFT JOIN Arbeit AS a ON m.id = a.mit_id
WHERE a.mit_id IS NULL;
GO


-- ============================================================================
-- 5. PRAXIS-USE-CASE: 360-GRAD FIRMEN-KONTROLSPIEGEL
-- ============================================================================
-- Konsolidierung aller monetären Transaktionen und Budgets:
-- 1. Gehälter (Personalkosten)
-- 2. Projektbudgets (Investitionen)
-- 3. Umsatzerlöse (Erträge)
-- ============================================================================

SELECT 'Personalkosten' AS finanz_kategorie,
       m.nachname AS referenz_objekt,
       g.gehalt AS betrag,
       'Monatlich' AS rhythmus
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS g ON m.id = g.mit_id
UNION ALL
SELECT 'Projektbudget' AS finanz_kategorie,
       p.bezeichnung AS referenz_objekt,
       p.mittel AS betrag,
       'Einmalig' AS rhythmus
FROM Projekt AS p
UNION ALL
SELECT 'Umsatzerloes' AS finanz_kategorie,
       CONCAT('Umsatz-ID #', u.id) AS referenz_objekt,
       u.umsatz AS betrag,
       CONVERT(VARCHAR(10), u.datum, 120) AS rhythmus
FROM Umsatz AS u
ORDER BY finanz_kategorie ASC, betrag DESC;
GO
