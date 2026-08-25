-- ============================================================================
-- 🎓 IHK Abschlussprüfung: 5. Handlungsschritt (25 Punkte)
-- Szenario: Fakturierungsdatenbank (Weinhandel & Fakturierung)
-- Datei: Day_17/src/03_ihk_abschlusspruefung_fakturierung_loesung.sql
-- Autor: Tobias Boyke
-- Datum: 25.08.2026
-- ============================================================================

-- ============================================================================
-- 📋 Schema-Definition (Aufbau der Tabellen zum lokalen Testen)
-- ============================================================================

CREATE TABLE ARTIKEL_TYP (
    ArtTyp_ID INT PRIMARY KEY,
    ArtTyp_Bezeichnung VARCHAR(100) NOT NULL
);

CREATE TABLE WEIN_TYP (
    WeinTyp_ID INT PRIMARY KEY,
    WeinTyp_Bezeichnung VARCHAR(100) NOT NULL
);

CREATE TABLE GESCHMACK_TYP (
    Geschmack_ID INT PRIMARY KEY,
    Geschmack_Name VARCHAR(100) NOT NULL,
    Geschmack_Beschreibung VARCHAR(255)
);

CREATE TABLE ARTIKEL (
    Art_ID INT PRIMARY KEY,
    Art_Nr VARCHAR(20) NOT NULL,
    Art_Bezeichnung VARCHAR(255) NOT NULL,
    Art_Preis DECIMAL(10, 2) NOT NULL,
    Art_ArtTypID INT FOREIGN KEY REFERENCES ARTIKEL_TYP(ArtTyp_ID),
    Art_WeinTypID INT FOREIGN KEY REFERENCES WEIN_TYP(WeinTyp_ID),
    Art_GeschmackTypID INT FOREIGN KEY REFERENCES GESCHMACK_TYP(Geschmack_ID)
);

CREATE TABLE KUNDE (
    Kd_ID INT PRIMARY KEY,
    Kd_Firma VARCHAR(255) NOT NULL,
    Kd_PLZ VARCHAR(10),
    Kd_Ort VARCHAR(100),
    Kd_Strasse VARCHAR(150),
    Kd_HausNr VARCHAR(20)
);

CREATE TABLE RECHNUNG (
    Rg_ID INT PRIMARY KEY,
    Rg_KdID INT FOREIGN KEY REFERENCES KUNDE(Kd_ID),
    Rg_RgNr VARCHAR(50) NOT NULL,
    Rg_RgDatum DATE NOT NULL
);

CREATE TABLE RECHNUNG_POSITION (
    RgPos_ID INT PRIMARY KEY,
    RgPos_RgID INT FOREIGN KEY REFERENCES RECHNUNG(Rg_ID),
    RgPos_PosNr INT NOT NULL,
    RgPos_ArtId INT FOREIGN KEY REFERENCES ARTIKEL(Art_ID),
    RgPos_Menge INT NOT NULL,
    RgPos_Preis DECIMAL(10, 2) NOT NULL
);
GO

-- ============================================================================
-- 📝 Teilaufgabe a) DML: Artikelpreise um 15 % erhöhen (3 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Anweisung, mit der Sie alle Artikelpreise um 15 % erhöhen.
-- ============================================================================

UPDATE ARTIKEL
SET Art_Preis = Art_Preis * 1.15;
GO

-- ============================================================================
-- 📝 Teilaufgabe b) DML: Artikel zwischen 10 und 15 EUR löschen (2 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Anweisung, mit der Sie alle Artikel löschen, die
-- einen Artikelpreis besitzen, der zwischen 10 EUR und 15 EUR liegt.
-- ============================================================================

DELETE FROM ARTIKEL
WHERE Art_Preis BETWEEN 10.00 AND 15.00;
GO

-- ============================================================================
-- 📝 Teilaufgabe c) DQL: Kunden und Gesamtumsatz (5 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Abfrage, mit der Sie für alle Kunden den Firmennamen
-- sowie den Gesamtumsatz erhalten. Die Ergebniszeilen sollen aufsteigend nach
-- Umsatz sortiert sein.
--
-- Erwartetes Ergebnis lt. Prüfungsangabe:
-- Kd_Firma               | Umsatz
-- Weinfabrik Sumpp       | NULL
-- Weinhandel Peters      | 17,94 EUR
-- Weinschnecke           | 88,56 EUR
-- Weingut am Weinberg    | 153,36 EUR
-- Weinhandel Predisto    | 766,37 EUR
-- ============================================================================

SELECT k.Kd_Firma,
       SUM(rp.RgPos_Menge * rp.RgPos_Preis) AS Umsatz
FROM KUNDE AS k
LEFT JOIN RECHNUNG AS rg ON k.Kd_ID = rg.Rg_KdID
LEFT JOIN RECHNUNG_POSITION AS rp ON rg.Rg_ID = rp.RgPos_RgID
GROUP BY k.Kd_ID, k.Kd_Firma
ORDER BY Umsatz ASC;
GO

-- ============================================================================
-- 📝 Teilaufgabe d) DQL: Artikelumsatz März 2020 für definierte Weine (10 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Abfrage, mit der Sie für alle Artikel die Artikelnummer
-- und die Artikelbezeichnung sowie den Umsatz für den März 2020 erhalten.
-- Es sollen alle Weine ausgegeben werden, die mit dem Artikel-Typ "Wein",
-- dem Geschmackstyp "Trocken" oder "Halbtrocken" und mit Weintyp "Weißwein"
-- gekennzeichnet sind.
--
-- Erwartetes Ergebnis lt. Prüfungsangabe:
-- Art_Nr | Art_Bezeichnung | ArtikelUmsatz
-- 00102  | Voliar          | 206,64 EUR
-- 00112  | Mendazie        | 120,00 EUR
-- 00115  | Tinto Templa    | 60,00 EUR
-- ============================================================================

SELECT a.Art_Nr,
       a.Art_Bezeichnung,
       SUM(rp.RgPos_Menge * rp.RgPos_Preis) AS ArtikelUmsatz
FROM ARTIKEL AS a
INNER JOIN ARTIKEL_TYP AS at ON a.Art_ArtTypID = at.ArtTyp_ID
INNER JOIN GESCHMACK_TYP AS gt ON a.Art_GeschmackTypID = gt.Geschmack_ID
INNER JOIN WEIN_TYP AS wt ON a.Art_WeinTypID = wt.WeinTyp_ID
INNER JOIN RECHNUNG_POSITION AS rp ON a.Art_ID = rp.RgPos_ArtId
INNER JOIN RECHNUNG AS rg ON rp.RgPos_RgID = rg.Rg_ID
WHERE at.ArtTyp_Bezeichnung = 'Wein'
  AND gt.Geschmack_Name IN ('Trocken', 'Halbtrocken')
  AND wt.WeinTyp_Bezeichnung = 'Weißwein'
  AND rg.Rg_RgDatum BETWEEN '2020-03-01' AND '2020-03-31'
GROUP BY a.Art_ID, a.Art_Nr, a.Art_Bezeichnung;
GO

-- ============================================================================
-- 📝 Teilaufgabe e) DQL: Alle Artikel mit durchschnittlichem VK (5 Punkte)
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Abfrage, mit der Sie alle Artikel, wie in der
-- Ergebnistabelle vorgegeben, mit dem durchschnittlichen Verkaufspreis anzeigen.
--
-- Erwartetes Ergebnis lt. Prüfungsangabe:
-- Art_ID | Art_Nr | Art_Bezeichnung | Art_Preis | Durchschnitt
-- 1      | 00102  | Voliar          | 7,38      | 7,38 EUR
-- 2      | 00105  | Piladar         | 5,98      | 5,98 EUR
-- 3      | 00106  | Dos Pantas      | 7,95      | 7,95 EUR
-- 4      | 00112  | Mendazie        | 24,95     | 20,00 EUR
-- 5      | 00115  | Tinto Templa    | 22,90     | 20,00 EUR
-- 6      | 00128  | La Grandala     | 15,37     | 15,37 EUR
-- 7      | 00131  | Lay Blanco      | 16,38     | 15,69 EUR
-- 8      | 00132  | Mese Rosade     | 17,37     | 17,37 EUR
-- 9      | 00133  | Rosato Ron      | 12,99     | NULL
-- ============================================================================

SELECT a.Art_ID,
       a.Art_Nr,
       a.Art_Bezeichnung,
       a.Art_Preis,
       AVG(rp.RgPos_Preis) AS Durchschnitt
FROM ARTIKEL AS a
LEFT JOIN RECHNUNG_POSITION AS rp ON a.Art_ID = rp.RgPos_ArtId
GROUP BY a.Art_ID, a.Art_Nr, a.Art_Bezeichnung, a.Art_Preis
ORDER BY a.Art_ID ASC;
GO
