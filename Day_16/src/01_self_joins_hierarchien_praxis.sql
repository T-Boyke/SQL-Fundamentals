-- ============================================================================
-- 📅 Day_16: SELF JOINs (Selbstreferenzielle Tabellenverknüpfungen)
-- Datenbank: ProjektDB (MS SQL Server)
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 24.08.2026
-- ============================================================================

USE ProjektDB;
GO

-- ============================================================================
-- 📝 TEIL 1: GRUNDLAGEN DES SELF JOINS (Hierarchien & Vorgesetzte)
-- ============================================================================
-- Ein SELF JOIN verknüpft eine Tabelle mit sich selbst.
-- ZWINGEND: Es müssen unterschiedliche Tabellen-Aliasse (z. B. 'm' und 'c')
-- vergeben werden, damit der SQL Server weiß, welche Rolle die Tabelle einnimmt.

-- 1.1 Einfacher INNER SELF JOIN (Mitarbeiter & Vorgesetzter)
-- Hinweis: Mitarbeiter ohne Chef (Top-Level wie Brigitte Kaufmann mit chef_id = NULL)
-- fallen beim INNER JOIN heraus!
SELECT m.id AS mitarbeiter_id,
       m.vorname + ' ' + m.nachname AS mitarbeiter_name,
       c.id AS chef_id,
       c.vorname + ' ' + c.nachname AS chef_name
FROM Mitarbeiter AS m
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id
ORDER BY c.nachname, m.nachname;
GO

-- 1.2 LEFT SELF JOIN (Alle Mitarbeiter inklusive Geschäftsführung)
-- Durch LEFT JOIN bleibt auch die Chefin ohne Vorgesetzten im Resultset (Chef = NULL / 'Kein Vorgesetzter')
SELECT m.id AS mitarbeiter_id,
       m.vorname + ' ' + m.nachname AS mitarbeiter_name,
       ISNULL(c.vorname + ' ' + c.nachname, '⭐ Geschäftsführung (Kein Chef)') AS vorgesetzter
FROM Mitarbeiter AS m
LEFT JOIN Mitarbeiter AS c ON m.chef_id = c.id
ORDER BY m.id;
GO

-- ============================================================================
-- 📝 TEIL 2: VERGLEICHE INNERHALB DER HIERARCHIE (Gehaltsvergleiche)
-- ============================================================================

-- 2.1 Wer verdient mehr als der eigene Chef?
-- Multi-Table Self-Join: Mitarbeiter (m) + Gehalt (gm) verknüpft mit Chef (c) + Gehalt (gc)
SELECT m.nachname AS mitarbeiter,
       gm.gehalt AS gehalt_mitarbeiter,
       c.nachname AS chef,
       gc.gehalt AS gehalt_chef,
       (gm.gehalt - gc.gehalt) AS gehaltsvorsprung
FROM Mitarbeiter AS m
INNER JOIN Gehalt AS gm ON m.id = gm.mit_id
INNER JOIN Mitarbeiter AS c ON m.chef_id = c.id
INNER JOIN Gehalt AS gc ON c.id = gc.mit_id
WHERE gm.gehalt > gc.gehalt;
GO

-- ============================================================================
-- 📝 TEIL 3: HORIZONTALE SELF JOINS (Kollegen- & Paarfindungen)
-- ============================================================================

-- 3.1 Mitarbeiter, die im selben Wohnort leben (ohne Duplikate / Selbst-Paarung)
-- Trick: Der Operator 'm1.id < m2.id' verhindert:
-- 1. Dass ein Mitarbeiter mit sich selbst gepaart wird (m1.id = m2.id)
-- 2. Dass Paare spiegelverkehrt doppelt auftauchen (A-B und B-A)
SELECT m1.ort,
       m1.vorname + ' ' + m1.nachname AS kollege_1,
       m2.vorname + ' ' + m2.nachname AS kollege_2
FROM Mitarbeiter AS m1
INNER JOIN Mitarbeiter AS m2 ON m1.ort = m2.ort 
                            AND m1.id < m2.id
WHERE m1.ort IS NOT NULL
ORDER BY m1.ort;
GO

-- 3.2 Mitarbeiter, die in derselben Abteilung arbeiten
SELECT a.bezeichnung AS abteilung,
       m1.nachname AS mitarbeiter_1,
       m2.nachname AS mitarbeiter_2
FROM Mitarbeiter AS m1
INNER JOIN Mitarbeiter AS m2 ON m1.abt_id = m2.abt_id 
                            AND m1.id < m2.id
INNER JOIN Abteilung AS a ON m1.abt_id = a.id
ORDER BY a.bezeichnung, m1.nachname;
GO
