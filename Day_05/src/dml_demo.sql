-- ============================================================================
-- Day_05: DML (Data Manipulation Language) Demonstration
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- ============================================================================
-- 1. UMGEBUNG AUFBAUEN (Falls nicht vorhanden)
-- ============================================================================
IF OBJECT_ID('Schule.Anmeldungen', 'U') IS NOT NULL DROP TABLE Schule.Anmeldungen;
IF OBJECT_ID('Schule.Schueler', 'U') IS NOT NULL DROP TABLE Schule.Schueler;
IF OBJECT_ID('Schule.Kurse', 'U') IS NOT NULL DROP TABLE Schule.Kurse;
GO

IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'Schule')
BEGIN
    DROP SCHEMA Schule;
END
GO

CREATE SCHEMA Schule;
GO

CREATE TABLE Schule.Schueler (
    SchuelerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    [Alter] TINYINT NOT NULL,
    RegistriertSeit DATE DEFAULT GETDATE(),
    Email VARCHAR(150),
    CONSTRAINT CHK_Schueler_Alter CHECK ([Alter] >= 6)
);

CREATE TABLE Schule.Kurse (
    KursID INT PRIMARY KEY,
    Titel VARCHAR(50) NOT NULL UNIQUE,
    Gebuehr DECIMAL(6,2) DEFAULT 0.00
);

CREATE TABLE Schule.Anmeldungen (
    SchuelerID INT NOT NULL,
    KursID INT NOT NULL,
    Note TINYINT,
    CONSTRAINT PK_Anmeldungen PRIMARY KEY (SchuelerID, KursID),
    CONSTRAINT FK_Anmeldungen_Schueler FOREIGN KEY (SchuelerID) 
        REFERENCES Schule.Schueler(SchuelerID) ON DELETE CASCADE, -- Automatische Kaskadierung
    CONSTRAINT FK_Anmeldungen_Kurse FOREIGN KEY (KursID) 
        REFERENCES Schule.Kurse(KursID) ON DELETE NO ACTION,
    CONSTRAINT CHK_Anmeldungen_Note CHECK (Note BETWEEN 1 AND 6)
);
GO

-- ============================================================================
-- 2. INSERT - DATEN EINFUEGEN
-- ============================================================================

-- A. Einfache Inserts (explizite Spalten)
INSERT INTO Schule.Schueler (Name, [Alter], Email)
VALUES ('Tobias Boyke', 25, 'tobias.boyke@example.de');

INSERT INTO Schule.Schueler (Name, [Alter], Email)
VALUES ('Maxi Muster', 17, 'maxi.muster@example.de');

-- B. Multiple Werte in einem INSERT einfügen
INSERT INTO Schule.Kurse (KursID, Titel, Gebuehr)
VALUES 
    (101, 'SQL Fundamentals', 299.00),
    (102, 'C# Deep Dive', 450.00),
    (103, 'Linux Essentials', 150.00);

-- C. Anmeldungen eintragen (Beziehungen)
INSERT INTO Schule.Anmeldungen (SchuelerID, KursID, Note)
VALUES 
    (1, 101, 1), -- Tobias in SQL (Note 1)
    (1, 102, 2), -- Tobias in C# (Note 2)
    (2, 101, 3); -- Maxi in SQL (Note 3)
GO

-- Kontroll-Abfrage (SELECT)
PRINT '--- Inhalt vor Updates/Deletes ---';
SELECT 
    s.Name AS Schueler,
    k.Titel AS Kurs,
    a.Note
FROM Schule.Anmeldungen AS a
INNER JOIN Schule.Schueler AS s ON a.SchuelerID = s.SchuelerID
INNER JOIN Schule.Kurse AS k ON a.KursID = k.KursID;
GO

-- ============================================================================
-- 3. UPDATE - DATEN AENDERN
-- ============================================================================

-- Tobias hat Geburtstag und seine Mailadresse aendert sich
UPDATE Schule.Schueler
SET 
    [Alter] = 26,
    Email = 'tobias.boyke.neu@example.de'
WHERE SchuelerID = 1;

-- Preissenkung für alle Kurse über 300 € um 10%
UPDATE Schule.Kurse
SET Gebuehr = Gebuehr * 0.90
WHERE Gebuehr > 300.00;
GO

-- ============================================================================
-- 4. DELETE - DATEN LOESCHEN & KASKADIERUNG
-- ============================================================================

-- Wir loeschen Schueler 2 ('Maxi Muster').
-- Wegen 'ON DELETE CASCADE' loescht SQL Server auch alle Anmeldungen von Maxi!
DELETE FROM Schule.Schueler
WHERE SchuelerID = 2;
GO

-- Kontroll-Abfrage zur Verifikation der Kaskadierung
PRINT '--- Inhalt nach Loeschung (Maxi entfernt) ---';
SELECT * FROM Schule.Anmeldungen; -- Zeigt nur noch Tobias' Anmeldungen
GO

-- ============================================================================
-- 5. TRUNCATE TABLE
-- ============================================================================

-- Versuch, Kurse zu leeren. Schlaegt fehl, da Fremdschluessel vorhanden sind!
-- TRUNCATE TABLE Schule.Kurse; -- (Wirft Fehler: 'Cannot truncate table... because it is being referenced...')

-- Zuerst loeschen wir die Verweise
TRUNCATE TABLE Schule.Anmeldungen; -- Loescht alle Anmeldungen (Kopplung)
GO

-- Nun koennen wir die Kurse leeren
TRUNCATE TABLE Schule.Kurse;
GO
