-- ============================================================================
-- SQL-Fundamentals: Day 21 - Fortgeschrittene T-SQL Techniken
-- Datei: 02_merge_datenabgleich_und_upsert.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 31.08.2026
-- Fokus: MERGE Anweisung (Upsert, ETL-Synchronisation & OUTPUT-Klausel)
-- Datenbank: WeitereBeispiele & ProjektDB
-- ============================================================================

-- ============================================================================
-- THEORIE: Das MERGE-Statement in T-SQL
-- ----------------------------------------------------------------------------
-- Die MERGE-Anweisung kombiniert INSERT-, UPDATE- und DELETE-Operationen in
-- einem einzigen atomaren Befehl (Upsert-Pattern).
--
-- Grundsyntax:
--   MERGE [TargetTable] AS TGT
--   USING [SourceTableOrQuery] AS SRC
--   ON (TGT.Key = SRC.Key)
--   WHEN MATCHED [AND <Filter>]
--       THEN UPDATE SET TGT.Spalte = SRC.Spalte
--   WHEN NOT MATCHED [BY TARGET] [AND <Filter>]
--       THEN INSERT (Spalten...) VALUES (SRC.Werte...)
--   WHEN NOT MATCHED BY SOURCE [AND <Filter>]
--       THEN DELETE | UPDATE SET ...
--   OUTPUT $action, DELETED.*, INSERTED.*;
--
-- Wichtige Verhaltensregeln:
-- 1. Jede Zeile im Ziel (TARGET) darf maximal EINMAL von der Quelltabelle (SOURCE)
--    gematcht werden, sonst tritt Laufzeitfehler 8672 auf (nicht-deterministisches Update).
-- 2. Das MERGE-Statement MUSS zwingend mit einem Semikolon (;) abgeschlossen werden!
-- 3. Die OUTPUT-Klausel liefert über die Pseudospalte $action ('INSERT', 'UPDATE', 'DELETE')
--    den genauen Änderungstyp für jede betroffene Zeile.
-- ============================================================================

USE master;
GO

USE WeitereBeispiele;
GO

-- ----------------------------------------------------------------------------
-- Vorbereitung: Tabellen für Data Warehouse (DW) & Live-System zurücksetzen
-- ----------------------------------------------------------------------------
TRUNCATE TABLE ProductsDW;
TRUNCATE TABLE ProductsLive;

INSERT INTO ProductsDW (ProductID, ProductName, Price)
VALUES
    (1, 'Tea', 10.00),
    (2, 'Coffee', 20.00),
    (3, 'Muffin', 30.00),
    (4, 'Biscuit', 40.00);

INSERT INTO ProductsLive (ProductID, ProductName, Price)
VALUES
    (1, 'Tea', 10.00),      -- Unverändert
    (2, 'Coffee', 25.00),   -- Preis geändert (Update)
    (3, 'Muffin', 35.00),   -- Preis geändert (Update)
    (5, 'Pizza', 60.00);    -- Neues Produkt (Insert in DW, Produkt 4 fehlt in Live)
GO

PRINT '--- Vorher-Zustand: ProductsDW ---';
SELECT * FROM ProductsDW;

PRINT '--- Vorher-Zustand: ProductsLive ---';
SELECT * FROM ProductsLive;
GO


-- ============================================================================
-- 1. Synchronisation mit DELETE bei fehlenden Quelldaten
-- ============================================================================

PRINT '--- 1. MERGE mit INSERT, UPDATE und DELETE ---';

MERGE ProductsDW AS TGT
USING ProductsLive AS SRC
ON (TGT.ProductID = SRC.ProductID)
WHEN MATCHED AND (TGT.Price <> SRC.Price)
    THEN UPDATE SET TGT.Price = SRC.Price
WHEN NOT MATCHED BY TARGET
    THEN INSERT (ProductID, ProductName, Price) 
         VALUES (SRC.ProductID, SRC.ProductName, SRC.Price)
WHEN NOT MATCHED BY SOURCE
    THEN DELETE;

PRINT '--- Nachher-Zustand: ProductsDW (nach DELETE) ---';
SELECT * FROM ProductsDW;
GO


-- ============================================================================
-- 2. Soft-Delete / Inaktivierung & OUTPUT-Audit-Protokollierung
-- ============================================================================

-- Erneutes Rücksetzen der Ausgangsdaten für Demonstration 2
TRUNCATE TABLE ProductsDW;
INSERT INTO ProductsDW (ProductID, ProductName, Price)
VALUES
    (1, 'Tea', 10.00),
    (2, 'Coffee', 20.00),
    (3, 'Muffin', 30.00),
    (4, 'Biscuit', 40.00);
GO

PRINT '--- 2. MERGE mit Soft-Markierung und OUTPUT-Audit ---';

MERGE ProductsDW AS TGT
USING ProductsLive AS SRC
ON (TGT.ProductID = SRC.ProductID)
WHEN MATCHED AND (TGT.Price <> SRC.Price)
    THEN UPDATE SET TGT.Price = SRC.Price
WHEN NOT MATCHED BY TARGET
    THEN INSERT (ProductID, ProductName, Price) 
         VALUES (SRC.ProductID, SRC.ProductName, SRC.Price)
WHEN NOT MATCHED BY SOURCE
    THEN UPDATE SET TGT.ProductName = CONCAT(TGT.ProductName, ' - invalid')
OUTPUT 
    $action AS aktion,
    DELETED.ProductID   AS alt_product_id,
    DELETED.ProductName AS alt_name,
    DELETED.Price       AS alt_preis,
    INSERTED.ProductID  AS neu_product_id,
    INSERTED.ProductName AS neu_name,
    INSERTED.Price      AS neu_preis;

PRINT '--- Nachher-Zustand: ProductsDW (nach Soft-Markierung) ---';
SELECT * FROM ProductsDW;
GO


-- ============================================================================
-- 3. ProjektDB SoT Transfer: Gehaltsspiegel-Synchronisation
-- ============================================================================

USE ProjektDB;
GO

-- Simuliertes Gehaltserhöhungs-Batch
-- Wir erstellen eine temporäre Gehaltstabelle für ein Gehalts-Update
IF OBJECT_ID('tempdb..#GehaltsUpdate') IS NOT NULL
    DROP TABLE #GehaltsUpdate;

CREATE TABLE #GehaltsUpdate (
    mit_id INT PRIMARY KEY,
    neues_gehalt DECIMAL(10, 2)
);

INSERT INTO #GehaltsUpdate (mit_id, neues_gehalt)
VALUES
    (101, 5500.00), -- Angepasstes Gehalt
    (102, 3800.00), -- Angepasstes Gehalt
    (999, 4200.00); -- Neuer fiktiver Mitarbeiter

PRINT '--- 3. Gehaltssynchronisation mit MERGE & OUTPUT ---';

MERGE Gehalt AS TGT
USING #GehaltsUpdate AS SRC
ON (TGT.mit_id = SRC.mit_id)
WHEN MATCHED AND (TGT.gehalt <> SRC.neues_gehalt)
    THEN UPDATE SET TGT.gehalt = SRC.neues_gehalt
OUTPUT 
    $action AS aktion,
    INSERTED.mit_id,
    DELETED.gehalt AS altes_gehalt,
    INSERTED.gehalt AS neues_gehalt;

-- Cleanup Temp-Tabelle
DROP TABLE #GehaltsUpdate;
GO
