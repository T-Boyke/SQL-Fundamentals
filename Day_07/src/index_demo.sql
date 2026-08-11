-- ============================================================================
-- Day_07: SQL Server Indizes Demo (Clustered, Non-Clustered, Heaps)
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

-- 1. Setup einer Testdatenbank (falls nicht vorhanden, in master/tempdb arbeiten)
USE tempdb;
GO

-- Bereinigung alter Demotabellen
IF OBJECT_ID('dbo.MitarbeiterHeap', 'U') IS NOT NULL DROP TABLE dbo.MitarbeiterHeap;
IF OBJECT_ID('dbo.MitarbeiterClustered', 'U') IS NOT NULL DROP TABLE dbo.MitarbeiterClustered;
GO

-- 2. Erstellung einer Tabelle als HEAP (Kein Primärschlüssel, kein gruppierter Index)
CREATE TABLE dbo.MitarbeiterHeap (
    MitarbeiterID INT NOT NULL,
    Vorname NVARCHAR(50) NOT NULL,
    Nachname NVARCHAR(50) NOT NULL,
    Gehalt DECIMAL(10,2) NOT NULL,
    Abteilung NVARCHAR(30) NOT NULL
);
-- HINWEIS: Dies ist ein Heap. Die Daten werden unsortiert abgelegt.
GO

-- 3. Erstellung einer Tabelle mit CLUSTERED INDEX (über PRIMARY KEY)
CREATE TABLE dbo.MitarbeiterClustered (
    MitarbeiterID INT NOT NULL PRIMARY KEY CLUSTERED, -- Automatischer Clustered Index
    Vorname NVARCHAR(50) NOT NULL,
    Nachname NVARCHAR(50) NOT NULL,
    Gehalt DECIMAL(10,2) NOT NULL,
    Abteilung NVARCHAR(30) NOT NULL
);
GO

-- 4. Testdaten einfügen
INSERT INTO dbo.MitarbeiterHeap (MitarbeiterID, Vorname, Nachname, Gehalt, Abteilung)
VALUES 
(3, 'Max', 'Mustermann', 45000.00, 'IT'),
(1, 'Anna', 'Schmidt', 55000.00, 'HR'),
(5, 'John', 'Doe', 48000.00, 'IT'),
(2, 'Sarah', 'Kaiser', 62000.00, 'Finance'),
(4, 'Peter', 'Müller', 39000.00, 'Marketing');

INSERT INTO dbo.MitarbeiterClustered (MitarbeiterID, Vorname, Nachname, Gehalt, Abteilung)
VALUES 
(3, 'Max', 'Mustermann', 45000.00, 'IT'),
(1, 'Anna', 'Schmidt', 55000.00, 'HR'),
(5, 'John', 'Doe', 48000.00, 'IT'),
(2, 'Sarah', 'Kaiser', 62000.00, 'Finance'),
(4, 'Peter', 'Müller', 39000.00, 'Marketing');
GO

-- 5. Abfragen vergleichen & Ausführungsplan prüfen (STRG+M in SSMS einschalten!)

-- Abfrage auf dem Heap: Führt zu einem Table Scan (Tabelle muss komplett gelesen werden)
SELECT * FROM dbo.MitarbeiterHeap WHERE MitarbeiterID = 2;

-- Abfrage auf der Clustered Table: Führt zu einem Clustered Index Seek (Sehr schnell!)
SELECT * FROM dbo.MitarbeiterClustered WHERE MitarbeiterID = 2;
GO

-- 6. Erstellung eines UNGRUPPIERTEN INDEX (Non-Clustered Index)
-- Wir suchen häufig nach dem Nachnamen.
CREATE NONCLUSTERED INDEX IX_MitarbeiterClustered_Nachname
ON dbo.MitarbeiterClustered(Nachname);
GO

-- Abfrage mit Index Seek im Non-Clustered Index & anschließendem Key Lookup
-- Da wir SELECT * nutzen, fehlen die Spalten Gehalt, Abteilung etc. im Index.
-- SQL Server macht einen Index Seek auf IX_MitarbeiterClustered_Nachname und nutzt dann den
-- Clustered Key, um den Rest der Spalten aus der Tabelle zu holen (Key Lookup).
SELECT * FROM dbo.MitarbeiterClustered WHERE Nachname = 'Schmidt';
GO

-- 7. COVERING INDEX (Abdeckender Index mit INCLUDE)
-- Wenn wir oft Nachname suchen und nur das Gehalt anzeigen wollen:
CREATE NONCLUSTERED INDEX IX_MitarbeiterClustered_Nachname_Covering
ON dbo.MitarbeiterClustered(Nachname)
INCLUDE (Gehalt);
GO

-- Hier reicht ein reiner Index Seek aus! Kein Key Lookup nötig, da alle Daten
-- direkt im Indexblattknoten liegen (Höchste Performance).
SELECT Nachname, Gehalt FROM dbo.MitarbeiterClustered WHERE Nachname = 'Schmidt';
GO
