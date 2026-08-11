-- ============================================================================
-- Day_07: Tagesaufgabe - Teil A (Datenbank & Tabellenerstellung)
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE master;
GO

-- Datenbank loeschen, falls sie bereits existiert (fuer saubere Re-Execution)
IF DB_ID('VorlesungDB') IS NOT NULL
BEGIN
    ALTER DATABASE VorlesungDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE VorlesungDB;
END
GO

CREATE DATABASE VorlesungDB;
GO

USE VorlesungDB;
GO

-- 1. Tabelle: Student (PK: MatrikelNr mit IDENTITY ab 10001)
CREATE TABLE dbo.Student (
    MatrikelNr INT IDENTITY(10001, 1) CONSTRAINT PK_Student PRIMARY KEY,
    StudVorname NVARCHAR(50) NOT NULL,
    StudNachname NVARCHAR(50) NOT NULL
);
GO

-- 2. Tabelle: Vorlesung (PK: VorlesungID mit IDENTITY ab 1)
-- Enthält noch redundante Professor-Details (nicht in 3NF)
CREATE TABLE dbo.Vorlesung (
    VorlesungID INT IDENTITY(1, 1) CONSTRAINT PK_Vorlesung PRIMARY KEY,
    Vorlesung NVARCHAR(100) NOT NULL,
    ProfID INT NOT NULL,
    ProfVorname NVARCHAR(50) NOT NULL,
    ProfNachname NVARCHAR(50) NOT NULL
);
GO

-- 3. Tabelle: Anwesenheit (Verbindungstabelle fuer M:N)
CREATE TABLE dbo.Anwesenheit (
    VorlesungID INT NOT NULL,
    MatrikelNr INT NOT NULL,
    Anwesend CHAR(1) NOT NULL,

    -- Constraints
    CONSTRAINT PK_Anwesenheit PRIMARY KEY (VorlesungID, MatrikelNr),
    CONSTRAINT FK_Anwesenheit_Vorlesung FOREIGN KEY (VorlesungID)
        REFERENCES dbo.Vorlesung (VorlesungID) ON DELETE CASCADE,
    CONSTRAINT FK_Anwesenheit_Student FOREIGN KEY (MatrikelNr)
        REFERENCES dbo.Student (MatrikelNr) ON DELETE CASCADE,
    CONSTRAINT CHK_Anwesenheit_Anwesend CHECK (Anwesend IN ('j', 'n'))
);
GO
