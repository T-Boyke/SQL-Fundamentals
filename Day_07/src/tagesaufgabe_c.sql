-- ============================================================================
-- Day_07: Tagesaufgabe - Teil C (Überführung in 3. Normalform)
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE VorlesungDB;
GO

-- 1. Tabelle Professor anlegen
-- ProfID dient als Primärschlüssel. Vorname und Nachname werden gespeichert.
CREATE TABLE dbo.Professor (
    ProfID INT CONSTRAINT PK_Professor PRIMARY KEY,
    Vorname NVARCHAR(50) NOT NULL,
    Nachname NVARCHAR(50) NOT NULL
);
GO

-- 2. Daten aus Vorlesung in Professor-Tabelle migrieren (DISTINCT zur Vermeidung von Dubletten)
INSERT INTO dbo.Professor (ProfID, Vorname, Nachname)
SELECT DISTINCT ProfID, ProfVorname, ProfNachname
FROM dbo.Vorlesung;
GO

-- 3. Fremdschluessel-Beziehung in Vorlesung definieren
ALTER TABLE dbo.Vorlesung
ADD CONSTRAINT FK_Vorlesung_Professor FOREIGN KEY (ProfID)
    REFERENCES dbo.Professor (ProfID);
GO

-- 4. Redundante Spalten (Vorname, Nachname des Professors) aus Vorlesung entfernen
ALTER TABLE dbo.Vorlesung
DROP COLUMN ProfVorname, ProfNachname;
GO

-- Kontrolle: Verifikation der 3NF
-- Datenabfrage ueber die neuen normalisierten Beziehungen (ProfID verknuepft)
SELECT
    v.VorlesungID,
    v.Vorlesung,
    p.Vorname + ' ' + p.Nachname AS Professor,
    s.StudVorname + ' ' + s.StudNachname AS Student,
    a.Anwesend
FROM dbo.Anwesenheit AS a
INNER JOIN dbo.Vorlesung AS v ON a.VorlesungID = v.VorlesungID
INNER JOIN dbo.Professor AS p ON v.ProfID = p.ProfID
INNER JOIN dbo.Student AS s ON a.MatrikelNr = s.MatrikelNr;
GO
