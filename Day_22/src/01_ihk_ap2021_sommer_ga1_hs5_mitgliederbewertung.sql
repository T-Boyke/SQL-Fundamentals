-- ============================================================================
-- SQL-Fundamentals: Day 22 - IHK-Prüfungstraining
-- Datei: 01_ihk_ap2021_sommer_ga1_hs5_mitgliederbewertung.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 01.09.2026
-- IHK-Abschlussprüfung Sommer 2021: Fachinformatiker (GA1, Handlungsschritt 5)
-- Thema: Mitgliederbewertung, Angebotsvermittlung & Datenarchivierung (25 Punkte)
-- ============================================================================

USE master;
GO

-- ============================================================================
-- 1. DDL: Schema-Aufbau der IHK-Prüfungsdatenbank
-- ============================================================================

DROP DATABASE IF EXISTS IHK_Mitgliederbewertung_2021S;
GO

CREATE DATABASE IHK_Mitgliederbewertung_2021S;
GO

USE IHK_Mitgliederbewertung_2021S;
GO

-- Tabelle 1: Leistungsarten (z.B. Kinderbetreuung, Gartenarbeit)
CREATE TABLE LeistungArt (
    idleistungArt INT IDENTITY(1, 1) NOT NULL,
    artBezeichnung VARCHAR(50) NOT NULL,
    CONSTRAINT pk_LeistungArt PRIMARY KEY (idleistungArt)
);
GO

-- Tabelle 2: Mitglieder
CREATE TABLE Mitglied (
    idmitglied INT IDENTITY(1, 1) NOT NULL,
    mitgliedName VARCHAR(50) NOT NULL,
    gebDat DATE NOT NULL,
    fuehrungsZeugnis VARCHAR(50) NULL,
    CONSTRAINT pk_Mitglied PRIMARY KEY (idmitglied)
);
GO

-- Tabelle 3: Angebote von Mitgliedern
CREATE TABLE Angebot (
    idangebot INT IDENTITY(1, 1) NOT NULL,
    beschreibung VARCHAR(100) NULL,
    wochentag VARCHAR(20) NOT NULL,
    vonZeit TIME NOT NULL,
    bisZeit TIME NOT NULL,
    mitgliedlid INT NOT NULL,
    leistungArtId INT NOT NULL,
    CONSTRAINT pk_Angebot PRIMARY KEY (idangebot),
    CONSTRAINT fk_Angebot_Mitglied FOREIGN KEY (mitgliedlid)
        REFERENCES Mitglied (idmitglied),
    CONSTRAINT fk_Angebot_LeistungArt FOREIGN KEY (leistungArtId)
        REFERENCES LeistungArt (idleistungArt)
);
GO

-- Tabelle 4: Bewertungen für erbrachte Leistungen
CREATE TABLE Bewertung (
    idbewertung INT IDENTITY(1, 1) NOT NULL,
    bewertungText VARCHAR(200) NULL,
    bewertungZahl DECIMAL(3, 1) NOT NULL,
    leistungArtId INT NOT NULL,
    mitgliedlid INT NOT NULL,
    CONSTRAINT pk_Bewertung PRIMARY KEY (idbewertung),
    CONSTRAINT fk_Bewertung_LeistungArt FOREIGN KEY (leistungArtId)
        REFERENCES LeistungArt (idleistungArt),
    CONSTRAINT fk_Bewertung_Mitglied FOREIGN KEY (mitgliedlid)
        REFERENCES Mitglied (idmitglied)
);
GO


-- ============================================================================
-- 2. DML: Realistische Testdaten (analog zum IHK-Prüfungssatz)
-- ============================================================================

-- Leistungsarten anlegen
INSERT INTO LeistungArt (artBezeichnung)
VALUES 
    ('Kinderbetreuung'),
    ('Gartenarbeit'),
    ('Hausarbeit'),
    ('Nachhilfe');

-- Mitglieder anlegen (inkl. inaktiver Mitglieder für Aufgabe d)
SET IDENTITY_INSERT Mitglied ON;

INSERT INTO Mitglied (idmitglied, mitgliedName, gebDat, fuehrungsZeugnis)
VALUES 
    (1, 'Schmidt', '1985-03-12', 'vorhanden (erweitert)'),
    (2, 'Maier', '1992-07-25', 'vorhanden'),
    (3, 'Müller', '1990-11-04', 'vorhanden'),
    (4, 'Hauser', '1988-02-18', 'vorhanden'),
    (25, 'Spielmann', '1995-09-30', 'nicht erforderlich'),
    (26, 'Inaktiv_Eins', '2001-04-15', 'nicht vorgelegt'), -- Inaktiv (kein Angebot)
    (27, 'Inaktiv_Zwei', '1998-12-20', 'nicht vorgelegt'); -- Inaktiv (kein Angebot)

SET IDENTITY_INSERT Mitglied OFF;

-- Angebote anlegen
INSERT INTO Angebot (beschreibung, wochentag, vonZeit, bisZeit, mitgliedlid, leistungArtId)
VALUES 
    ('Kinderbetreuung Nachmittag', 'Donnerstag', '14:00', '16:00', 2, 1),
    ('Gartenpflege & Rasenmähen', 'Donnerstag', '14:00', '16:00', 4, 2),
    ('Hausarbeiten aller Art', 'Donnerstag', '14:00', '16:00', 4, 3),
    ('Nachhilfe Mathematik', 'Dienstag', '15:00', '17:00', 3, 4),
    ('Babysitting am Abend', 'Samstag', '18:00', '22:00', 25, 1);

-- Bewertungen anlegen
INSERT INTO Bewertung (bewertungText, bewertungZahl, leistungArtId, mitgliedlid)
VALUES 
    ('Sehr zuverlässig und pünktlich', 2.0, 1, 3),
    ('Gute Arbeit geleistet', 2.2, 1, 3),
    ('Freundlich und engagiert', 3.0, 1, 2),
    ('Hervorragende Betreuung!', 4.5, 1, 25),
    ('Tolle Gartenarbeit', 5.0, 2, 4);
GO


-- ============================================================================
-- 3. Musterlösungen der IHK-Aufgaben
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Aufgabe a) Geben Sie alle Attribute des jüngsten Mitglieds aus. (4 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Subquery zur Ermittlung des maximalen Geburtsdatums (2 Punkte)
-- 2. Korrektes WHERE-Prädikat auf das jüngste Mitglied (2 Punkte)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe a: Alle Attribute des jüngsten Mitglieds ===';

-- Standard-Lösung (ANSI SQL / IHK Standard)
SELECT idmitglied,
       mitgliedName,
       gebDat,
       fuehrungsZeugnis
FROM Mitglied
WHERE gebDat = (
    SELECT MAX(gebDat) 
    FROM Mitglied
);
GO

-- Alternative T-SQL Lösung:
SELECT TOP (1) WITH TIES 
       idmitglied,
       mitgliedName,
       gebDat,
       fuehrungsZeugnis
FROM Mitglied
ORDER BY gebDat DESC;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe b) Mitgliederliste sortiert nach Durchschnittsbewertung 
--            für die Leistungsart "Kinderbetreuung". (6 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Tabellenverknüpfungen Mitglied - Bewertung - LeistungArt (2 Punkte)
-- 2. Filter auf 'Kinderbetreuung' (1 Punkt)
-- 3. Aggregatfunktion AVG(bewertungZahl) & GROUP BY (2 Punkte)
-- 4. Aufsteigende Sortierung nach Durchschnitt (1 Punkt)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe b: Durchschnittsbewertung für Kinderbetreuung ===';

SELECT m.idmitglied,
       m.mitgliedName,
       CAST(AVG(b.bewertungZahl) AS DECIMAL(3, 1)) AS Durchschnitt
FROM Mitglied AS m
INNER JOIN Bewertung AS b 
    ON m.idmitglied = b.mitgliedlid
INNER JOIN LeistungArt AS la 
    ON b.leistungArtId = la.idleistungArt
WHERE la.artBezeichnung = 'Kinderbetreuung'
GROUP BY m.idmitglied, m.mitgliedName
ORDER BY Durchschnitt ASC;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe c) Angebotsliste für Donnerstage von 14:00 bis 16:00 Uhr. (7 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Verknüpfung von Mitglied, Angebot und LeistungArt (3 Punkte)
-- 2. Filter auf Wochentag 'Donnerstag' (1 Punkt)
-- 3. Zeitfilterung vonZeit <= 14:00 und bisZeit >= 16:00 (3 Punkte)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe c: Angebotsliste Donnerstag 14:00 - 16:00 Uhr ===';

SELECT m.idmitglied,
       m.mitgliedName,
       la.artBezeichnung,
       a.wochentag,
       a.vonZeit,
       a.bisZeit
FROM Mitglied AS m
INNER JOIN Angebot AS a 
    ON m.idmitglied = a.mitgliedlid
INNER JOIN LeistungArt AS la 
    ON a.leistungArtId = la.idleistungArt
WHERE a.wochentag = 'Donnerstag'
  AND a.vonZeit <= '14:00'
  AND a.bisZeit >= '16:00';
GO


-- ----------------------------------------------------------------------------
-- Aufgabe d) Tabelle MitgliedArchiv erstellen, inaktive Mitglieder 
--            transferieren und aus Mitglied löschen. (8 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. DDL: CREATE TABLE MitgliedArchiv mit passenden Typen & PK (3 Punkte)
-- 2. DML: INSERT INTO MitgliedArchiv ... SELECT ... WHERE NOT IN / NOT EXISTS (3 Punkte)
-- 3. DML: DELETE FROM Mitglied ... WHERE NOT IN / NOT EXISTS (2 Punkte)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe d: DDL & DML Archivierung inaktiver Mitglieder ===';

-- Schritt 1: DDL Archivtabelle anlegen
IF OBJECT_ID('MitgliedArchiv', 'U') IS NOT NULL
    DROP TABLE MitgliedArchiv;

CREATE TABLE MitgliedArchiv (
    idmitglied INT NOT NULL,
    mitgliedName VARCHAR(50) NOT NULL,
    gebDat DATE NOT NULL,
    fuehrungsZeugnis VARCHAR(50) NULL,
    CONSTRAINT pk_MitgliedArchiv PRIMARY KEY (idmitglied)
);
GO

-- Schritt 2: Transfer aller inaktiven Mitglieder (ohne Angebote)
INSERT INTO MitgliedArchiv (idmitglied, mitgliedName, gebDat, fuehrungsZeugnis)
SELECT m.idmitglied,
       m.mitgliedName,
       m.gebDat,
       m.fuehrungsZeugnis
FROM Mitglied AS m
WHERE NOT EXISTS (
    SELECT 1 
    FROM Angebot AS a 
    WHERE a.mitgliedlid = m.idmitglied
);
GO

-- Schritt 3: Löschen der transferierten Mitglieder aus der Quelltabelle
DELETE FROM Mitglied
WHERE NOT EXISTS (
    SELECT 1 
    FROM Angebot AS a 
    WHERE a.mitgliedlid = Mitglied.idmitglied
);
GO

PRINT '--- Kontrolle: Inhalt der Tabelle MitgliedArchiv ---';
SELECT * FROM MitgliedArchiv;

PRINT '--- Kontrolle: Verbleibende aktive Mitglieder in Mitglied ---';
SELECT * FROM Mitglied;
GO
