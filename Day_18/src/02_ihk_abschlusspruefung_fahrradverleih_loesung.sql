-- ============================================================================
-- 🎓 IHK Abschlussprüfung: 5. Handlungsschritt (25 Punkte)
-- Szenario: Datenbank der Fahrradvermietung "Die Speiche GmbH" (ZPA FI Ganz I Anw)
-- Prüfungsdokumente:
--   - Aufgabe: Day_18/assets/AP 2019 W GA1 HS5 SQL Fahrradverleih - Aufgabe.pdf
--   - Lösung:  Day_18/assets/AP 2019 W GA1 HS5 SQL Fahrradverleih - Lösung.pdf
-- Datei: Day_18/src/02_ihk_abschlusspruefung_fahrradverleih_loesung.sql
-- Autor: Tobias Boyke
-- Datum: 26.08.2026 / Update 27.08.2026
-- ============================================================================

-- ============================================================================
-- 📋 Schema-Definition (Aufbau der Test-Tabellen für Übung & Verifikation)
-- ============================================================================

-- Bereinigung alter Tabellen falls vorhanden
IF OBJECT_ID('DefektBuchung', 'U') IS NOT NULL DROP TABLE DefektBuchung;
IF OBJECT_ID('Defekt', 'U') IS NOT NULL DROP TABLE Defekt;
IF OBJECT_ID('Buchung', 'U') IS NOT NULL DROP TABLE Buchung;
IF OBJECT_ID('VerleihRad', 'U') IS NOT NULL DROP TABLE VerleihRad;
IF OBJECT_ID('RadTyp', 'U') IS NOT NULL DROP TABLE RadTyp;
IF OBJECT_ID('Standort', 'U') IS NOT NULL DROP TABLE Standort;
IF OBJECT_ID('Kunde', 'U') IS NOT NULL DROP TABLE Kunde;
GO

-- 1. Tabelle Kunde
CREATE TABLE Kunde (
    KdID INT PRIMARY KEY,
    KdName VARCHAR(100) NOT NULL,
    KdStrNr VARCHAR(100) NOT NULL,
    KdPLZ VARCHAR(10) NOT NULL,
    KdOrt VARCHAR(100) NOT NULL
);

-- 2. Tabelle Standort
CREATE TABLE Standort (
    StdID INT PRIMARY KEY,
    StdName VARCHAR(100) NOT NULL,
    StdStrNr VARCHAR(100) NOT NULL,
    StdPLZ VARCHAR(10) NOT NULL,
    StdOrt VARCHAR(100) NOT NULL
);

-- 3. Tabelle RadTyp
CREATE TABLE RadTyp (
    RadTypID INT PRIMARY KEY,
    RadTypBez VARCHAR(100) NOT NULL,
    RadTypPreis DECIMAL(10, 2) NOT NULL
);

-- 4. Tabelle VerleihRad
CREATE TABLE VerleihRad (
    VRadID INT PRIMARY KEY,
    VRadFarbe VARCHAR(50) NOT NULL,
    RadTypID INT NOT NULL,
    StdID INT NOT NULL,
    CONSTRAINT FK_VerleihRad_RadTyp FOREIGN KEY (RadTypID) REFERENCES RadTyp(RadTypID),
    CONSTRAINT FK_VerleihRad_Standort FOREIGN KEY (StdID) REFERENCES Standort(StdID)
);

-- 5. Tabelle Buchung
CREATE TABLE Buchung (
    KdID INT NOT NULL,
    VRadID INT NOT NULL,
    Datum DATE NOT NULL,
    Tage INT NOT NULL,
    CONSTRAINT PK_Buchung PRIMARY KEY (KdID, VRadID, Datum),
    CONSTRAINT FK_Buchung_Kunde FOREIGN KEY (KdID) REFERENCES Kunde(KdID),
    CONSTRAINT FK_Buchung_VerleihRad FOREIGN KEY (VRadID) REFERENCES VerleihRad(VRadID)
);
GO

-- ============================================================================
-- 📥 Testdaten-Befüllung (Prüfungsdaten gemäß Aufgabenstellung)
-- ============================================================================

INSERT INTO Kunde (KdID, KdName, KdStrNr, KdPLZ, KdOrt) VALUES
(2001, 'Müller GmbH', 'Hauptstr. 12', '80331', 'München'),
(2002, 'Schmidt Reisen', 'Bahnhofstr. 4', '86150', 'Augsburg'),
(2003, 'Weber & Partner', 'Ulmer Str. 22', '89073', 'Ulm');

INSERT INTO Standort (StdID, StdName, StdStrNr, StdPLZ, StdOrt) VALUES
(1, 'Station Hauptbahnhof', 'Bahnhofsplatz 1', '80335', 'München'),
(2, 'Station Ostbahnhof', 'Orleansplatz 2', '81667', 'München');

INSERT INTO RadTyp (RadTypID, RadTypBez, RadTypPreis) VALUES
(1000, 'Citybike Basic', 15.00),
(1001, 'Mountainbike', 20.00),
(1002, 'Tandem 500', 30.00),
(1003, 'E-Bike Premium', 35.00);

INSERT INTO VerleihRad (VRadID, VRadFarbe, RadTypID, StdID) VALUES
(101, 'Blau', 1000, 1),
(102, 'Rot', 1000, 1),
(103, 'Schwarz', 1001, 1),
(104, 'Gelb', 1002, 2),
(105, 'Silber', 1003, 2);

-- Buchungsdaten (inkl. Daten für 2019 für Aufgaben b, c, e)
INSERT INTO Buchung (KdID, VRadID, Datum, Tage) VALUES
-- Buchungen für Kunde 2002 (Umsatz: 2*30*10 + 20*35 = 1400 EUR)
(2002, 104, '2019-01-10', 10), -- Tandem (30 EUR/Tag * 10 Tage = 300)
(2002, 104, '2019-01-20', 10), -- Tandem (30 EUR/Tag * 10 Tage = 300)
(2002, 105, '2019-02-05', 10), -- E-Bike (35 EUR/Tag * 10 Tage = 350)
(2002, 105, '2019-02-18', 10), -- E-Bike (35 EUR/Tag * 10 Tage = 350)
(2002, 104, '2019-03-01', 3),  -- Tandem (30 EUR/Tag * 3 Tage = 90)
(2002, 104, '2019-03-10', 1),  -- Tandem (30 EUR/Tag * 1 Tag = 30)

-- Buchungen für Kunde 2001 (Umsatz: 40*20 = 800 EUR)
(2001, 103, '2019-01-15', 20), -- Mountainbike (20 EUR * 20 = 400)
(2001, 103, '2019-02-10', 20), -- Mountainbike (20 EUR * 20 = 400)

-- Weitere Buchungen für Citybike Basic (RadTyp 1000) um >= 10 Buchungen zu erreichen
(2003, 101, '2019-01-01', 1),
(2003, 101, '2019-01-02', 1),
(2003, 101, '2019-01-03', 1),
(2003, 101, '2019-01-04', 1),
(2003, 101, '2019-02-01', 1),
(2003, 101, '2019-02-02', 1),
(2003, 101, '2019-03-01', 1),
(2003, 101, '2019-03-02', 1),
(2003, 102, '2019-04-01', 1),
(2003, 102, '2019-04-02', 1),
(2003, 102, '2019-05-01', 1),
(2003, 102, '2019-05-02', 1);
GO

-- ============================================================================
-- 📝 Teilaufgabe a) DDL: Tabellenerstellung (5 Punkte)
-- ============================================================================

-- aa) Tabelle Defekt erstellen (2 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie die Tabelle Defekt, welche als Attribut eine DefektID
-- und eine Beschreibung enthält.
CREATE TABLE Defekt (
    DefektID INT PRIMARY KEY,
    Beschreibung VARCHAR(255) NOT NULL
);
GO

-- ab) Tabelle DefektBuchung erstellen (3 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie die Tabelle DefektBuchung, welche bis auf das Attribut Tage
-- alle Attribute der Tabelle Buchung und eine DefektID aus der Tabelle Defekt enthält.
CREATE TABLE DefektBuchung (
    KdID INT NOT NULL,
    VRadID INT NOT NULL,
    Datum DATE NOT NULL,
    DefektID INT NOT NULL,
    PRIMARY KEY (KdID, VRadID, Datum),
    FOREIGN KEY (KdID) REFERENCES Kunde(KdID),
    FOREIGN KEY (VRadID) REFERENCES VerleihRad(VRadID),
    FOREIGN KEY (DefektID) REFERENCES Defekt(DefektID)
);
GO

-- ============================================================================
-- 📝 Teilaufgabe b) DQL: Buchungen pro RadTyp >= 10 (5 Punkte)
-- 
-- Aufgabenstellung:
-- Erstellen Sie eine Liste aller Buchungen pro RadTyp für alle Radtypen,
-- zu denen mindestens zehn Buchungen vorliegen.
-- 
-- Ergebnistabelle:
-- RadTypID | Anzahl
-- 1000     | 23
-- 1001     | 12
-- ...
-- ============================================================================

SELECT vr.RadTypID,
       COUNT(*) AS Anzahl
FROM VerleihRad AS vr
INNER JOIN Buchung AS b ON vr.VRadID = b.VRadID
GROUP BY vr.RadTypID
HAVING COUNT(*) >= 10;
GO

-- ============================================================================
-- 📝 Teilaufgabe c) DQL: Gesamtumsatz pro Kunde (5 Punkte)
-- 
-- Aufgabenstellung:
-- Erstellen Sie eine Liste, in der für jeden Kunden der Gesamtumsatz seiner
-- Buchungen (jeweils Tage * RadTypPreis) aufgelistet ist. Die Liste soll
-- die Datensätze absteigend sortiert nach dem Umsatz enthalten.
-- 
-- Ergebnistabelle:
-- KdID | Umsatz
-- 2002 | 1400
-- 2001 | 800
-- ...
-- ============================================================================

SELECT b.KdID,
       SUM(b.Tage * rt.RadTypPreis) AS Umsatz
FROM Buchung AS b
INNER JOIN VerleihRad AS vr ON b.VRadID = vr.VRadID
INNER JOIN RadTyp AS rt ON vr.RadTypID = rt.RadTypID
GROUP BY b.KdID
ORDER BY Umsatz DESC;
GO

-- ============================================================================
-- 📝 Teilaufgabe d) DQL: Subquery - Räder teurer als Mountainbike (5 Punkte)
-- 
-- Aufgabenstellung:
-- Geben Sie alle Radtyp-IDs, deren Radtypbezeichnung und Preis an, die
-- einen höheren Preis als der Radtyp 'Mountainbike' haben (RadTypID = 1001).
-- 
-- Ergebnistabelle:
-- RadTypID | RadTypBez   | RadTypPreis
-- 1002     | Tandem 500  | 30
-- ...
-- ============================================================================

SELECT RadTypID,
       RadTypBez,
       RadTypPreis
FROM RadTyp
WHERE RadTypPreis > (
    SELECT RadTypPreis
    FROM RadTyp
    WHERE RadTypBez = 'Mountainbike'
       OR RadTypID = 1001
);
GO

-- ============================================================================
-- 📝 Teilaufgabe e) DQL: Prozentualer Anteil Buchungen pro Monat 2019 (5 Punkte)
-- 
-- Aufgabenstellung:
-- Geben Sie für jeden Monat den prozentualen Anteil der Anzahl der Buchungen
-- an der Gesamtanzahl der Buchungen für das Jahr 2019 an.
-- 
-- Ergebnistabelle:
-- Monat | Anteil
-- 1     | 5
-- 2     | 7
-- ...
-- ============================================================================

SELECT MONTH(Datum) AS Monat,
       ROUND((COUNT(*) * 100.0) / (SELECT COUNT(*) FROM Buchung WHERE YEAR(Datum) = 2019), 0) AS Anteil
FROM Buchung
WHERE YEAR(Datum) = 2019
GROUP BY MONTH(Datum)
ORDER BY Monat ASC;
GO
