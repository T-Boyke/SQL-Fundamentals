-- ============================================================================
-- Day_07: Tagesaufgabe - Teil B (Datenbefüllung)
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE VorlesungDB;
GO

-- 1. Studentendaten einfuegen (mit IDENTITY_INSERT fuer exakte Matrikelnummern)
SET IDENTITY_INSERT dbo.Student ON;
GO

INSERT INTO dbo.Student (MatrikelNr, StudVorname, StudNachname)
VALUES
    (10001, 'Hans', 'Müller'),
    (10002, 'Udo', 'Meier'),
    (10003, 'Karl', 'Schulz'),
    (10004, 'Laura', 'Richter'),
    (10005, 'Petra', 'Meier'),
    (10006, 'Lisa', 'Sommer');
GO

SET IDENTITY_INSERT dbo.Student OFF;
GO

-- 2. Vorlesungen einfuegen (mit IDENTITY_INSERT fuer exakte VorlesungsIDs)
SET IDENTITY_INSERT dbo.Vorlesung ON;
GO

INSERT INTO dbo.Vorlesung (VorlesungID, Vorlesung, ProfID, ProfVorname, ProfNachname)
VALUES
    (1, 'Einführung BWL', 1, 'Hans', 'Meier'),
    (2, 'Marketing für IT', 2, 'Gerda', 'Müller'),
    (3, 'Business English', 1, 'Hans', 'Meier'),
    (4, 'Java in d. Praxis', 3, 'Inga', 'Ludwig');
GO

SET IDENTITY_INSERT dbo.Vorlesung OFF;
GO

-- 3. Anwesenheitsdaten einfuegen
INSERT INTO dbo.Anwesenheit (VorlesungID, MatrikelNr, Anwesend)
VALUES
    (1, 10001, 'j'),
    (1, 10002, 'n'),
    (1, 10003, 'j'),
    (2, 10003, 'n'),
    (2, 10004, 'j'),
    (2, 10005, 'n'),
    (3, 10005, 'j'),
    (3, 10006, 'j'),
    (4, 10001, 'j'),
    (4, 10004, 'j');
GO

-- Kontrolle: Daten anzeigen
SELECT
    v.Vorlesung,
    v.ProfVorname + ' ' + v.ProfNachname AS Professor,
    s.StudVorname + ' ' + s.StudNachname AS Student,
    a.Anwesend
FROM dbo.Anwesenheit AS a
INNER JOIN dbo.Vorlesung AS v ON a.VorlesungID = v.VorlesungID
INNER JOIN dbo.Student AS s ON a.MatrikelNr = s.MatrikelNr;
GO
