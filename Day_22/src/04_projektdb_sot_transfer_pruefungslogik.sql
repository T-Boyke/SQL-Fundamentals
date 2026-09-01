-- ============================================================================
-- SQL-Fundamentals: Day 22 - IHK-Prüfungstraining
-- Datei: 04_projektdb_sot_transfer_pruefungslogik.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 01.09.2026
-- Fokus: Transfer der IHK-Prüfungsmuster (AP 2021 S & AP 2022 W) auf die ProjektDB (SoT)
-- ============================================================================

USE master;
GO

USE ProjektDB;
GO

-- ============================================================================
-- TEIL 1: TRANSFER AP 2021 S (Mitgliederbewertung & Vermittlung)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Transfer 1 (zu 2021S Aufgabe a): Extremwert-Suche mit skalarer Subquery
-- IHK-Analogon: "Geben Sie alle Attribute des Projekts mit dem höchsten Budget aus."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 1: Projekt mit maximalem Budget (Subquery) ---';

SELECT id,
       kuerzel,
       bezeichnung,
       mittel,
       kunde_id
FROM Projekt
WHERE mittel = (
    SELECT MAX(mittel) 
    FROM Projekt
);
GO

-- ----------------------------------------------------------------------------
-- Transfer 2 (zu 2021S Aufgabe b): Aggregation, Join & Sortierung
-- IHK-Analogon: "Ermitteln Sie die Abteilungen sortiert nach dem Durchschnittsgehalt."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 2: Abteilungs-Gehaltsspiegel (AVG, JOIN, GROUP BY) ---';

SELECT a.id AS abt_id,
       a.bezeichnung AS abteilungsname,
       COUNT(m.id) AS anzahl_mitarbeiter,
       CAST(AVG(g.gehalt) AS DECIMAL(10, 2)) AS durchschnittsgehalt,
       FORMAT(AVG(g.gehalt), 'C', 'de-DE') AS avg_gehalt_formatiert
FROM Abteilung AS a
INNER JOIN Mitarbeiter AS m 
    ON a.id = m.abt_id
INNER JOIN Gehalt AS g 
    ON m.id = g.mit_id
GROUP BY a.id, a.bezeichnung
ORDER BY AVG(g.gehalt) DESC;
GO

-- ----------------------------------------------------------------------------
-- Transfer 3 (zu 2021S Aufgabe c): Multi-Table Verknüpfung mit Bereichsfilter
-- IHK-Analogon: "Ermitteln Sie alle Mitarbeiter, die an Projekten mit Budget >= 100.000 € arbeiten."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 3: Multi-Table Projektbesetzung mit Filter ---';

SELECT m.id AS mitarbeiter_id,
       CONCAT(m.vorname, ' ', m.nachname) AS mitarbeiter_name,
       p.bezeichnung AS projekt_name,
       k.firma AS kunde,
       ar.aufgabe,
       ar.einst_dat AS projekt_start,
       FORMAT(p.mittel, 'C', 'de-DE') AS projektbudget
FROM Mitarbeiter AS m
INNER JOIN Arbeit AS ar 
    ON m.id = ar.mit_id
INNER JOIN Projekt AS p 
    ON ar.pro_id = p.id
INNER JOIN Kunde AS k 
    ON p.kunde_id = k.id
WHERE p.mittel >= 100000.00
  AND ar.einst_dat >= '2019-01-01'
ORDER BY p.mittel DESC, m.nachname ASC;
GO

-- ----------------------------------------------------------------------------
-- Transfer 4 (zu 2021S Aufgabe d): Archivierung inaktiver Mitarbeiter (ETL-Muster)
-- IHK-Analogon: "Mitarbeiter ohne Projekteinsatz in MitarbeiterArchiv transferieren."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 4: DDL & ETL-Archivierung inaktiver Mitarbeiter ---';

IF OBJECT_ID('MitarbeiterArchiv', 'U') IS NOT NULL
    DROP TABLE MitarbeiterArchiv;

-- 4.1 DDL der Archivtabelle
CREATE TABLE MitarbeiterArchiv (
    id INT NOT NULL,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    abt_id INT NULL,
    ort VARCHAR(50) NULL,
    chef_id INT NULL,
    archiviertAm DATETIME DEFAULT GETDATE(),
    CONSTRAINT pk_MitarbeiterArchiv PRIMARY KEY (id)
);
GO

-- 4.2 DML Transfer inaktiver Mitarbeiter (Mitarbeiter ohne Zuordnung in Arbeit)
INSERT INTO MitarbeiterArchiv (id, vorname, nachname, abt_id, ort, chef_id)
SELECT m.id,
       m.vorname,
       m.nachname,
       m.abt_id,
       m.ort,
       m.chef_id
FROM Mitarbeiter AS m
WHERE NOT EXISTS (
    SELECT 1 
    FROM Arbeit AS ar 
    WHERE ar.mit_id = m.id
);
GO

PRINT '--- Kontrolle: Archivierte Mitarbeiter ohne Projekte ---';
SELECT * FROM MitarbeiterArchiv;
GO


-- ============================================================================
-- TEIL 2: TRANSFER AP 2022 W (Rechnungserstellung, MwSt & Rabatte)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Transfer 5 (zu 2022W Aufgabe a): Brutto-Projektbudgets inkl. 19% MwSt
-- IHK-Analogon: "Bruttopreise aus Nettopreisen und MwSt berechnen."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 5: Projektbudgets Netto vs. Brutto (19% MwSt) ---';

SELECT p.id,
       p.kuerzel,
       p.bezeichnung,
       p.mittel AS budget_netto,
       CAST(p.mittel * 1.19 AS DECIMAL(12, 2)) AS budget_brutto,
       FORMAT(p.mittel * 1.19, 'C', 'de-DE') AS budget_brutto_formatiert
FROM Projekt AS p
ORDER BY p.mittel DESC;
GO

-- ----------------------------------------------------------------------------
-- Transfer 6 (zu 2022W Aufgabe b): Kunde-Umsatz-Dashboard mit Aggregation
-- IHK-Analogon: "Umsatz, Anzahl Positionen und Durchschnitt pro Kunde/Projekt."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 6: Umsatz-Dashboard pro Mitarbeiter (Summe, Anzahl, Avg) ---';

SELECT m.id AS mitarbeiter_id,
       CONCAT(m.vorname, ' ', m.nachname) AS mitarbeiter_name,
       a.bezeichnung AS abteilung,
       COALESCE(SUM(u.umsatz), 0.00) AS gesamtumsatz,
       COUNT(u.id) AS anzahl_umsatzvorgaenge,
       COALESCE(AVG(u.umsatz), 0.00) AS durchschnittlicher_umsatz
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a 
    ON m.abt_id = a.id
LEFT JOIN Umsatz AS u 
    ON m.id = u.mit_id
GROUP BY m.id, m.vorname, m.nachname, a.bezeichnung
ORDER BY gesamtumsatz DESC;
GO

-- ----------------------------------------------------------------------------
-- Transfer 7 (zu 2022W Aufgabe c): Gehaltsabweichung vom Abteilungsdurchschnitt
-- IHK-Analogon: "Artikel mit abweichendem Verkaufspreis und Differenz."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 7: Gehaltsabweichung zum Abteilungsdurchschnitt ---';

WITH AbtSchnitt AS (
    SELECT abt_id,
           AVG(g.gehalt) AS avg_gehalt_abt
    FROM Mitarbeiter AS m
    INNER JOIN Gehalt AS g 
        ON m.id = g.mit_id
    GROUP BY abt_id
)

SELECT m.id,
       m.nachname,
       a.bezeichnung AS abteilung,
       g.gehalt AS mitarbeiter_gehalt,
       CAST(s.avg_gehalt_abt AS DECIMAL(10, 2)) AS abt_durchschnitt,
       CAST(g.gehalt - s.avg_gehalt_abt AS DECIMAL(10, 2)) AS differenz_zum_schnitt
FROM Mitarbeiter AS m
INNER JOIN Abteilung AS a 
    ON m.abt_id = a.id
INNER JOIN Gehalt AS g 
    ON m.id = g.mit_id
INNER JOIN AbtSchnitt AS s 
    ON m.abt_id = s.abt_id
WHERE g.gehalt <> s.avg_gehalt_abt
ORDER BY differenz_zum_schnitt DESC;
GO

-- ----------------------------------------------------------------------------
-- Transfer 8 (zu 2022W Aufgabe d): Nachträglicher Bonus-Update auf Umsätze
-- IHK-Analogon: "Nachträgliche Rabattierung für bestimmtes Jahr (DML UPDATE mit JOIN)."
-- ----------------------------------------------------------------------------
PRINT '--- Transfer 8: 5% Bonus-Erhöhung auf alle Umsätze im Jahr 2023 ---';

-- Simulierte DML-Aktualisierung mit Transaktionsschutz
BEGIN TRANSACTION;

UPDATE u
SET u.umsatz = u.umsatz * 1.05
FROM Umsatz AS u
INNER JOIN Mitarbeiter AS m 
    ON u.mit_id = m.id
WHERE u.datum >= '2023-01-01' 
  AND u.datum < '2024-01-01';

PRINT CONCAT('Betroffene Umsatzzeilen aktualisiert: ', @@ROWCOUNT);

-- Rollback zur Wahrung der Konsistenz der ProjektDB
ROLLBACK TRANSACTION;
PRINT '>>> Test-Update sicher gerollbackt (ProjektDB bleibt unverändert). <<<';
GO
