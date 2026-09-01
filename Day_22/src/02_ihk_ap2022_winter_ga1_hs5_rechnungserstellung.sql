-- ============================================================================
-- SQL-Fundamentals: Day 22 - IHK-Prüfungstraining
-- Datei: 02_ihk_ap2022_winter_ga1_hs5_rechnungserstellung.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 01.09.2026
-- IHK-Abschlussprüfung Winter 2022/2023: Fachinformatiker (GA1, Handlungsschritt 5)
-- Thema: Rechnungserstellung, Preisberechnungen, Umsatz & Rabattierung (25 Punkte)
-- ============================================================================

USE master;
GO

-- ============================================================================
-- 1. DDL: Schema-Aufbau der IHK-Prüfungsdatenbank (Rechnungserstellung)
-- ============================================================================

DROP DATABASE IF EXISTS IHK_Rechnungserstellung_2022W;
GO

CREATE DATABASE IHK_Rechnungserstellung_2022W;
GO

USE IHK_Rechnungserstellung_2022W;
GO

-- Tabelle 1: Kunde
CREATE TABLE Kunde (
    Kd_IdKey INT IDENTITY(1, 1) NOT NULL,
    Kd_Firma VARCHAR(100) NOT NULL,
    Kd_Strasse VARCHAR(100) NOT NULL,
    Kd_PLZ CHAR(5) NOT NULL,
    Kd_Ort VARCHAR(50) NOT NULL,
    Kd_Nummer VARCHAR(20) NOT NULL,
    CONSTRAINT pk_Kunde PRIMARY KEY (Kd_IdKey)
);
GO

-- Tabelle 2: Artikel
CREATE TABLE Artikel (
    IdKey INT IDENTITY(1, 1) NOT NULL,
    Art_Nummer VARCHAR(20) NOT NULL,
    Art_Bezeichnung VARCHAR(100) NOT NULL,
    Art_Preis DECIMAL(10, 2) NOT NULL,
    VkEinheit VARCHAR(20) NOT NULL,
    Art_MwStSatz DECIMAL(5, 2) NOT NULL,
    CONSTRAINT pk_Artikel PRIMARY KEY (IdKey)
);
GO

-- Tabelle 3: Rechnung
CREATE TABLE Rechnung (
    Rg_IdKey INT IDENTITY(1, 1) NOT NULL,
    Rg_KdIdKey INT NOT NULL,
    Rg_Nummer VARCHAR(20) NOT NULL,
    Rg_Datum DATE NOT NULL,
    Rg_ZahlFristTage INT NOT NULL,
    CONSTRAINT pk_Rechnung PRIMARY KEY (Rg_IdKey),
    CONSTRAINT fk_Rechnung_Kunde FOREIGN KEY (Rg_KdIdKey)
        REFERENCES Kunde (Kd_IdKey)
);
GO

-- Tabelle 4: RechnungPosition
CREATE TABLE RechnungPosition (
    RgPos_IdKey INT IDENTITY(1, 1) NOT NULL,
    RgPos_RgIdKey INT NOT NULL,
    RgPos_ArtIdKey INT NOT NULL,
    RgPos_Nummer INT NOT NULL,
    RgPos_Menge DECIMAL(10, 2) NOT NULL,
    RgPos_EinzelPreis DECIMAL(10, 2) NOT NULL,
    RgPos_RabattProzent DECIMAL(5, 2) NOT NULL,
    RpPos_MwStSatz DECIMAL(5, 2) NOT NULL,
    CONSTRAINT pk_RechnungPosition PRIMARY KEY (RgPos_IdKey),
    CONSTRAINT fk_RgPos_Rechnung FOREIGN KEY (RgPos_RgIdKey)
        REFERENCES Rechnung (Rg_IdKey),
    CONSTRAINT fk_RgPos_Artikel FOREIGN KEY (RgPos_ArtIdKey)
        REFERENCES Artikel (IdKey)
);
GO


-- ============================================================================
-- 2. DML: Original-Testdaten aus dem IHK-Prüfungsbogen
-- ============================================================================

-- Kunden
SET IDENTITY_INSERT Kunde ON;

INSERT INTO Kunde (Kd_IdKey, Kd_Firma, Kd_Strasse, Kd_PLZ, Kd_Ort, Kd_Nummer)
VALUES
    (1, 'LikeLimo', 'Musterstr. 12', '50778', 'Köln', '012204'),
    (2, 'Gasthaus ''Die Perle''', 'Perlenstr. 22', '50778', 'Köln', '012201'),
    (3, 'Traberstübchen', 'Traberweg 1', '50889', 'Köln', '012205'),
    (4, 'Brauhaus Brömle', 'Brauhausstr. 555', '50778', 'Köln', '013000'),
    (5, 'Zur Ente', 'Teichallee 11', '50780', 'Köln', '012211'),
    (6, 'Neukunde OhneUmsatz', 'Neustr. 1', '50667', 'Köln', '019999');

SET IDENTITY_INSERT Kunde OFF;

-- Artikel
SET IDENTITY_INSERT Artikel ON;

INSERT INTO Artikel (IdKey, Art_Nummer, Art_Bezeichnung, Art_Preis, VkEinheit, Art_MwStSatz)
VALUES
    (1, 'BK1221', 'Unterhopf', 14.30, 'Kasten', 19.00),
    (2, 'BK1229', 'Frühes', 13.80, 'Kasten', 19.00),
    (3, 'BK1233', 'Pilschen', 15.40, 'Kasten', 19.00),
    (4, 'BB0088', 'Birnenbrand', 9.60, 'Flasche', 19.00),
    (5, 'BB0092', 'Apfelbrand', 9.60, 'Flasche', 19.00),
    (6, 'BB0097', 'Marillenbrand', 10.20, 'Flasche', 19.00),
    (7, 'BB0121', 'Pfirsichbrand', 9.60, 'Flasche', 19.00);

SET IDENTITY_INSERT Artikel OFF;

-- Rechnungen
SET IDENTITY_INSERT Rechnung ON;

INSERT INTO Rechnung (Rg_IdKey, Rg_KdIdKey, Rg_Nummer, Rg_Datum, Rg_ZahlFristTage)
VALUES
    (2223, 2, 'RG-002249', '2022-09-02', 14),
    (2224, 3, 'RG-002250', '2022-09-02', 14),
    (2225, 3, 'RG-002251', '2022-09-04', 14),
    (2226, 1, 'RG-002252', '2022-09-05', 7),
    (2227, 5, 'RG-002253', '2022-09-06', 14),
    (2228, 3, 'RG-002254', '2022-09-07', 14),
    (2229, 1, 'RG-002255', '2022-09-08', 7),
    (2230, 4, 'RG-002256', '2022-09-09', 14),
    (2231, 4, 'RG-002257', '2022-09-10', 14);

SET IDENTITY_INSERT Rechnung OFF;

-- Rechnungspositionen
SET IDENTITY_INSERT RechnungPosition ON;

INSERT INTO RechnungPosition (
    RgPos_IdKey, RgPos_RgIdKey, RgPos_ArtIdKey, RgPos_Nummer, 
    RgPos_Menge, RgPos_EinzelPreis, RgPos_RabattProzent, RpPos_MwStSatz
)
VALUES
    (555434, 2223, 2, 1, 4.0, 12.80, 0.00, 19.00), -- Abweichender Preis!
    (555435, 2223, 1, 2, 12.0, 13.30, 0.00, 19.00), -- Abweichender Preis!
    (555436, 2223, 4, 3, 6.0, 9.60, 5.00, 19.00),
    (555437, 2223, 5, 4, 12.0, 9.60, 5.00, 19.00),
    (555438, 2224, 2, 1, 8.0, 13.80, 0.00, 19.00),
    (555439, 2225, 4, 1, 6.0, 9.60, 0.00, 19.00),
    (555440, 2225, 5, 2, 6.0, 9.60, 0.00, 19.00),
    (555441, 2225, 6, 3, 12.0, 10.20, 0.00, 19.00),
    (555442, 2225, 7, 4, 6.0, 9.60, 0.00, 19.00),
    (555453, 2226, 1, 1, 6.0, 14.30, 0.00, 19.00),
    (555454, 2226, 3, 2, 6.0, 15.40, 0.00, 19.00),
    (555455, 2226, 2, 3, 6.0, 13.80, 0.00, 19.00);

SET IDENTITY_INSERT RechnungPosition OFF;
GO


-- ============================================================================
-- 3. Musterlösungen der IHK-Aufgaben
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Aufgabe a) Artikel mit berechnetem Bruttopreis ausgeben (3 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Selektion aller geforderten Spalten (1 Punkt)
-- 2. Korrekte Berechnung des Bruttopreises (2 Punkte):
--    Brutto = Art_Preis * (1 + Art_MwStSatz / 100)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe a: Artikel mit Bruttopreis ===';

SELECT IdKey AS Art_IdKey,
       Art_Nummer,
       Art_Bezeichnung,
       Art_Preis,
       Art_MwStSatz,
       Art_Preis * (1.0 + Art_MwStSatz / 100.0) AS BruttoPreis
FROM Artikel;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe b) Kunden, Rechnungen, Umsatz, Positionen & Durchschnitt (10 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Joins zwischen Kunde, Rechnung und RechnungPosition (3 Punkte)
-- 2. Umsatzberechnung: SUM(Menge * Einzelpreis * (1 - Rabatt/100)) (3 Punkte)
-- 3. Anzahl der Positionen: COUNT(RgPos_IdKey) (1 Punkt)
-- 4. Durchschnittsrechnung: AVG(...) oder Umsatz / Anzahl (1 Punkt)
-- 5. GROUP BY über alle Kunden- und Rechnungsspalten (1 Punkt)
-- 6. Sortierung: ORDER BY Kd_Firma ASC (1 Punkt)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe b: Rechnungs-Umsatz, Positionen & Durchschnitt ===';

SELECT k.Kd_IdKey AS KdId,
       k.Kd_Firma AS Firma,
       r.Rg_Nummer AS Rechnungsnummer,
       COALESCE(SUM(rp.RgPos_Menge * rp.RgPos_EinzelPreis * (1.0 - rp.RgPos_RabattProzent / 100.0)), 0.00) AS Umsatz,
       COUNT(rp.RgPos_IdKey) AS AnzahlPositionen,
       COALESCE(AVG(rp.RgPos_Menge * rp.RgPos_EinzelPreis * (1.0 - rp.RgPos_RabattProzent / 100.0)), 0.00) AS Durchschnitt
FROM Kunde AS k
LEFT JOIN Rechnung AS r 
    ON k.Kd_IdKey = r.Rg_KdIdKey
LEFT JOIN RechnungPosition AS rp 
    ON r.Rg_IdKey = rp.RgPos_RgIdKey
GROUP BY k.Kd_IdKey, k.Kd_Firma, r.Rg_IdKey, r.Rg_Nummer
ORDER BY k.Kd_Firma ASC, r.Rg_Nummer ASC;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe c) Artikel mit abweichendem Verkaufspreis & Differenz (8 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. Joins zwischen Artikel, RechnungPosition und Rechnung (3 Punkte)
-- 2. Filter: WHERE rp.RgPos_EinzelPreis <> a.Art_Preis (2 Punkte)
-- 3. Berechnung der Differenz: (rp.RgPos_EinzelPreis - a.Art_Preis) (2 Punkte)
-- 4. Korrekte Spaltenauswahl (1 Punkt)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe c: Abweichende Verkaufspreise und Differenz ===';

SELECT a.IdKey AS Art_IdKey,
       a.Art_Nummer,
       a.Art_Bezeichnung,
       a.Art_Preis,
       a.VkEinheit AS Art_VkEinheit,
       r.Rg_Nummer,
       (rp.RgPos_EinzelPreis - a.Art_Preis) AS Differenz
FROM Artikel AS a
INNER JOIN RechnungPosition AS rp 
    ON a.IdKey = rp.RgPos_ArtIdKey
INNER JOIN Rechnung AS r 
    ON rp.RgPos_RgIdKey = r.Rg_IdKey
WHERE rp.RgPos_EinzelPreis <> a.Art_Preis;
GO


-- ----------------------------------------------------------------------------
-- Aufgabe d) Nachträglicher Rabatt von 7,5 % für Artikel 6 im Jahr 2022 (4 Punkte)
-- ----------------------------------------------------------------------------
-- Bewertungskriterien:
-- 1. UPDATE Anweisung auf RechnungPosition (1 Punkt)
-- 2. SET RgPos_RabattProzent = 7.5 (1 Punkt)
-- 3. Filterung auf ArtIdKey = 6 (1 Punkt)
-- 4. Zeitfilterung auf das Rechnungsjahr 2022 über Join oder Subquery (1 Punkt)
-- ----------------------------------------------------------------------------
PRINT '=== Aufgabe d: Rabatt-Update auf 7,5 % für Artikel 6 (2022) ===';

-- Variante 1: T-SQL UPDATE mit JOIN (Standard in der Microsoft-Welt)
UPDATE rp
SET rp.RgPos_RabattProzent = 7.5
FROM RechnungPosition AS rp
INNER JOIN Rechnung AS r 
    ON rp.RgPos_RgIdKey = r.Rg_IdKey
WHERE rp.RgPos_ArtIdKey = 6
  AND r.Rg_Datum >= '2022-01-01' 
  AND r.Rg_Datum < '2023-01-01';

-- Variante 2: ANSI SQL UPDATE mit Subquery (Universell portabel)
UPDATE RechnungPosition
SET RgPos_RabattProzent = 7.5
WHERE RgPos_ArtIdKey = 6
  AND RgPos_RgIdKey IN (
      SELECT r.Rg_IdKey
      FROM Rechnung AS r
      WHERE r.Rg_Datum >= '2022-01-01' 
        AND r.Rg_Datum < '2023-01-01'
  );
GO

PRINT '--- Kontrolle: Aktualisierte Positionen von Artikel 6 ---';
SELECT rp.RgPos_IdKey,
       rp.RgPos_RgIdKey,
       rp.RgPos_ArtIdKey,
       rp.RgPos_RabattProzent,
       r.Rg_Datum
FROM RechnungPosition AS rp
INNER JOIN Rechnung AS r 
    ON rp.RgPos_RgIdKey = r.Rg_IdKey
WHERE rp.RgPos_ArtIdKey = 6;
GO
