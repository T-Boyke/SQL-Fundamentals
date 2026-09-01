-- ============================================================================
-- SQL-Fundamentals: Day 22 - IHK-Prüfungstraining
-- Datei: 03_ihk_ap2019_sommer_ga1_hs5_maschinenwartung.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 01.09.2026
-- IHK-Abschlussprüfung Sommer 2019: Fachinformatiker (GA1, Handlungsschritt 5)
-- Thema: Maschinenwartung, Laufzeiten, Multi-Table LEFT JOINs & Updates (25 Punkte)
-- ============================================================================

USE master;
GO

-- ============================================================================
-- 1. DDL: Schema-Aufbau der IHK-Prüfungsdatenbank (Maschinenwartung)
-- ============================================================================

DROP DATABASE IF EXISTS IHK_Maschinenwartung_2019S;
GO

CREATE DATABASE IHK_Maschinenwartung_2019S;
GO

USE IHK_Maschinenwartung_2019S;
GO

-- Tabelle 1: Maschinentyp
CREATE TABLE Maschinentyp (
    MaschineTypID INT IDENTITY(1, 1) NOT NULL,
    Beschreibung VARCHAR(50) NOT NULL,
    WartungsintervallInStunden INT NOT NULL,
    CONSTRAINT pk_Maschinentyp PRIMARY KEY (MaschineTypID)
);
GO

-- Tabelle 2: Kunde
CREATE TABLE Kunde (
    KundeID INT IDENTITY(1, 1) NOT NULL,
    KundeFirma VARCHAR(100) NOT NULL,
    KundeAdresse VARCHAR(100) NOT NULL,
    CONSTRAINT pk_Kunde PRIMARY KEY (KundeID)
);
GO

-- Tabelle 3: Maschine
CREATE TABLE Maschine (
    MaschineID INT IDENTITY(1, 1) NOT NULL,
    MaschineTypID INT NOT NULL,
    ProduktionsDatum DATE NOT NULL,
    KundeID INT NOT NULL,
    DatumLetzteWartung DATE NOT NULL,
    CONSTRAINT pk_Maschine PRIMARY KEY (MaschineID),
    CONSTRAINT fk_Maschine_Maschinentyp FOREIGN KEY (MaschineTypID)
        REFERENCES Maschinentyp (MaschineTypID),
    CONSTRAINT fk_Maschine_Kunde FOREIGN KEY (KundeID)
        REFERENCES Kunde (KundeID)
);
GO

-- Tabelle 4: Laufzeit
CREATE TABLE Laufzeit (
    LfdNrID INT IDENTITY(1, 1) NOT NULL,
    MaschineID INT NOT NULL,
    Datum DATE NOT NULL,
    Stunden DECIMAL(10, 2) NOT NULL,
    CONSTRAINT pk_Laufzeit PRIMARY KEY (LfdNrID),
    CONSTRAINT fk_Laufzeit_Maschine FOREIGN KEY (MaschineID)
        REFERENCES Maschine (MaschineID)
);
GO


-- ============================================================================
-- 2. DML: Originalgetreue Testdaten aus dem IHK-Prüfungssatz
-- ============================================================================

-- Maschinentypen
SET IDENTITY_INSERT Maschinentyp ON;

INSERT INTO Maschinentyp (MaschineTypID, Beschreibung, WartungsintervallInStunden)
VALUES
    (1, 'Füll', 900),
    (2, 'Verpackung', 1800),
    (3, 'Etikettierung', 1000); -- Keine Maschine vorhanden

SET IDENTITY_INSERT Maschinentyp OFF;

-- Kunden
SET IDENTITY_INSERT Kunde ON;

INSERT INTO Kunde (KundeID, KundeFirma, KundeAdresse)
VALUES
    (1, 'LikeLimo', 'Musteradresse 1'),
    (2, 'Musterfirma', 'Hauptstraße 12');

SET IDENTITY_INSERT Kunde OFF;

-- Maschinen
SET IDENTITY_INSERT Maschine ON;

INSERT INTO Maschine (MaschineID, MaschineTypID, ProduktionsDatum, KundeID, DatumLetzteWartung)
VALUES
    (1, 1, '2018-01-15', 1, '2019-01-01'), -- Füllmaschine 1 bei LikeLimo
    (2, 1, '2018-05-20', 1, '2019-02-01'), -- Füllmaschine 2 bei LikeLimo (ohne Laufzeit)
    (3, 1, '2018-09-10', 2, '2019-03-01'), -- Füllmaschine 3 bei Musterfirma (ohne Laufzeit)
    (4, 2, '2017-11-05', 1, '2018-12-01'); -- Verpackungsmaschine bei LikeLimo (ohne Laufzeit)

SET IDENTITY_INSERT Maschine OFF;

-- Laufzeiten für Maschine 1
INSERT INTO Laufzeit (MaschineID, Datum, Stunden)
VALUES
    (1, '2019-01-10', 500.00),
    (1, '2019-02-15', 800.00),
    (1, '2019-03-20', 1200.00); -- Summe = 2500 Stunden (übersteigt Wartungsintervall von 900 h)
GO


-- ============================================================================
-- 3. Musterlösungen der IHK-Aufgaben
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Aufgabe a) Liste aller Maschinentypen mit Anzahl der Maschinen (5 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. LEFT JOIN zwischen Maschinentyp und Maschine (2 Punkte)
-- 2. COUNT(m.MaschineID) & GROUP BY (2 Punkte)
-- 3. Absteigende Sortierung nach Anzahl (1 Punkt)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe a: Maschinentypen mit Anzahl Maschinen ===';

SELECT mt.MaschineTypID,
       mt.Beschreibung,
       mt.WartungsintervallInStunden,
       COUNT(m.MaschineID) AS AnzahlMaschinen
FROM Maschinentyp AS mt
LEFT JOIN Maschine AS m 
    ON mt.MaschineTypID = m.MaschineTypID
GROUP BY mt.MaschineTypID, mt.Beschreibung, mt.WartungsintervallInStunden
ORDER BY AnzahlMaschinen DESC;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe b) Kunden & Maschinen, deren Laufzeit in den nächsten 100 h 
--            das Intervall überschreitet (8 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Verknüpfung von Kunde, Maschine, Maschinentyp und Laufzeit (3 Punkte)
-- 2. Datumsfilter: Laufzeit nach der letzten Wartung (l.Datum >= m.DatumLetzteWartung) (2 Punkte)
-- 3. Summe der Laufzeitstunden: SUM(l.Stunden) & GROUP BY (1 Punkt)
-- 4. HAVING-Filter auf Intervallüberschreitung (+100 Stunden) (2 Punkte)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe b: Maschinen kurz vor Wartungsintervall ===';

SELECT k.KundeID,
       k.KundeFirma,
       k.KundeAdresse,
       m.MaschineID,
       SUM(l.Stunden) AS Laufzeit
FROM Kunde AS k
INNER JOIN Maschine AS m 
    ON k.KundeID = m.KundeID
INNER JOIN Maschinentyp AS mt 
    ON m.MaschineTypID = mt.MaschineTypID
INNER JOIN Laufzeit AS l 
    ON m.MaschineID = l.MaschineID 
    AND m.DatumLetzteWartung <= l.Datum
GROUP BY k.KundeID, k.KundeFirma, k.KundeAdresse, m.MaschineID, mt.WartungsintervallInStunden
HAVING SUM(l.Stunden) + 100 >= mt.WartungsintervallInStunden;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe c) Liste aller Maschinentypen, Kunden & Laufzeit seit Wartung (8 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Multi-Table LEFT JOIN Kette (Maschinentyp -> Maschine -> Kunde -> Laufzeit) (4 Punkte)
-- 2. Laufzeitfilter auf DatumLetzteWartung in der ON-Klausel (2 Punkte)
-- 3. Aggregation SUM(l.Stunden) mit vollständigem GROUP BY (2 Punkte)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe c: Alle Maschinentypen, Kunden & Laufzeiten (Multi LEFT JOIN) ===';

SELECT mt.MaschineTypID,
       mt.Beschreibung,
       k.KundeFirma,
       SUM(l.Stunden) AS Laufzeit
FROM Maschinentyp AS mt
LEFT JOIN Maschine AS m 
    ON mt.MaschineTypID = m.MaschineTypID
LEFT JOIN Kunde AS k 
    ON m.KundeID = k.KundeID
LEFT JOIN Laufzeit AS l 
    ON m.MaschineID = l.MaschineID 
    AND m.DatumLetzteWartung <= l.Datum
GROUP BY mt.MaschineTypID, mt.Beschreibung, m.MaschineID, k.KundeFirma
ORDER BY mt.MaschineTypID ASC, m.MaschineID ASC;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe d) Wartungsintervall für Verpackungsmaschinen um 10% reduzieren (4 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. UPDATE Anweisung auf Tabelle Maschinentyp (1 Punkt)
-- 2. Berechnung: WartungsintervallInStunden = WartungsintervallInStunden * 0.9 (2 Punkte)
-- 3. Filter: WHERE Beschreibung = 'Verpackung' (1 Punkt)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe d: Wartungsintervall-Reduktion um 10% ===';

UPDATE Maschinentyp
SET WartungsintervallInStunden = CAST(WartungsintervallInStunden * 0.9 AS INT)
WHERE Beschreibung = 'Verpackung';
GO

PRINT '--- Kontrolle: Aktualisierter Maschinentyp ---';
SELECT * FROM Maschinentyp;
GO
