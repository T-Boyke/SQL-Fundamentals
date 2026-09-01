-- ============================================================================
-- SQL-Fundamentals: Day 22 - IHK-Prüfungstraining
-- Datei: 03_projektdb_sot_transfer_pruefungslogik.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 01.09.2026
-- Fokus: Transfer der 4 IHK-Prüfungsmuster auf die Single Source of Truth (ProjektDB)
-- ============================================================================

USE master;
GO

USE ProjektDB;
GO

-- ============================================================================
-- Transfer 1 (zu Aufgabe a): Extremwert-Suche mit skalarer Subquery
-- IHK-Analogon: "Geben Sie alle Attribute des Projekts mit dem höchsten Budget aus."
-- ============================================================================

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


-- ============================================================================
-- Transfer 2 (zu Aufgabe b): Aggregation, Join & Sortierung
-- IHK-Analogon: "Ermitteln Sie die Abteilungen sortiert nach dem Durchschnittsgehalt."
-- ============================================================================

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


-- ============================================================================
-- Transfer 3 (zu Aufgabe c): Multi-Table Verknüpfung mit Bereichsfilter
-- IHK-Analogon: "Ermitteln Sie alle Mitarbeiter, die an Projekten mit Budget >= 100.000 € arbeiten."
-- ============================================================================

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


-- ============================================================================
-- Transfer 4 (zu Aufgabe d): Archivierung inaktiver Mitarbeiter (ETL-Muster)
-- IHK-Analogon: "Mitarbeiter ohne Projekteinsatz in MitarbeiterArchiv transferieren."
-- ============================================================================

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
