-- ============================================================================
-- 🎓 IHK Abschlussprüfung: 4. Handlungsschritt (30 Punkte)
-- Prüfung: AP2 Sommer 2024 Fachinformatiker Anwendungsentwicklung (ZPA FIA II)
-- Szenario: Aktienkurse, Börsentransaktionen & Archivierung mit Mengenoperatoren
-- Prüfungsdokument:
--   - Aufgabe: Day_19/assets/AP2 2024 S FIAE2 A4 SQL Aktien - Aufgaben.pdf
-- Datei: Day_19/src/03_ihk_abschlusspruefung_aktien_loesung.sql
-- Autor: Tobias Boyke
-- Datum: 27.08.2026
-- Dozent: Tom S.
-- ============================================================================

-- ============================================================================
-- 📋 Schema-Definition (Aufbau der Test-Tabellen für Übung & Verifikation)
-- ============================================================================

IF OBJECT_ID('AktienKurs', 'U') IS NOT NULL DROP TABLE AktienKurs;
IF OBJECT_ID('AktienKursArchiv', 'U') IS NOT NULL DROP TABLE AktienKursArchiv;
IF OBJECT_ID('Aktie', 'U') IS NOT NULL DROP TABLE Aktie;
IF OBJECT_ID('Boerse', 'U') IS NOT NULL DROP TABLE Boerse;
GO

-- 1. Tabelle Aktie
CREATE TABLE Aktie (
    A_ID INT PRIMARY KEY,
    A_AktienName VARCHAR(100) NOT NULL,
    A_WKN VARCHAR(20) NOT NULL
);

-- 2. Tabelle Boerse
CREATE TABLE Boerse (
    B_ID INT PRIMARY KEY,
    B_BoersenName VARCHAR(100) NOT NULL,
    B_BoerseKng VARCHAR(20) NOT NULL
);

-- 3. Tabelle AktienKurs (Operative Live-Daten)
CREATE TABLE AktienKurs (
    AK_ID INT PRIMARY KEY,
    AK_DatumZeit DATETIME NOT NULL,
    AK_Kurs DECIMAL(10, 5) NOT NULL,
    AK_BoerseID INT NOT NULL,
    AK_AktieID INT NOT NULL,
    AK_Anzahl INT NOT NULL,
    CONSTRAINT FK_AktienKurs_Boerse FOREIGN KEY (AK_BoerseID) REFERENCES Boerse(B_ID),
    CONSTRAINT FK_AktienKurs_Aktie FOREIGN KEY (AK_AktieID) REFERENCES Aktie(A_ID)
);

-- 4. Tabelle AktienKursArchiv (Historische Vorjahresdaten)
CREATE TABLE AktienKursArchiv (
    AK_ID INT PRIMARY KEY,
    AK_DatumZeit DATETIME NOT NULL,
    AK_Kurs DECIMAL(10, 5) NOT NULL,
    AK_BoerseID INT NOT NULL,
    AK_AktieID INT NOT NULL,
    AK_Anzahl INT NOT NULL,
    CONSTRAINT FK_AktienKursArchiv_Boerse FOREIGN KEY (AK_BoerseID) REFERENCES Boerse(B_ID),
    CONSTRAINT FK_AktienKursArchiv_Aktie FOREIGN KEY (AK_AktieID) REFERENCES Aktie(A_ID)
);
GO

-- ============================================================================
-- 📥 Testdaten-Befüllung (Prüfungsdaten gemäß IHK-Aufgabenstellung)
-- ============================================================================

INSERT INTO Aktie (A_ID, A_AktienName, A_WKN) VALUES
(1, 'Hannover Rück', '840221'),
(2, 'Deutsche Bank', '514000'),
(3, 'Daimler Truck', 'DTROCK'),
(4, 'MTU Aero Engines', 'A0D9PT'),
(5, 'Münchener Rück', '843002'),
(6, 'AMAG', '999999');

INSERT INTO Boerse (B_ID, B_BoersenName, B_BoerseKng) VALUES
(1, 'Börse Frankfurt', 'FWB'),
(2, 'Stuttgarter Wertpapierbörse', 'EUWAX'),
(3, 'Niedersächsische Börse Hannover', 'BÖAG'),
(4, 'Börse Düsseldorf', 'BD'),
(5, 'Börse München', 'BM'),
(6, 'Tradegate Exchange', 'Tradegate');

-- Operative Kurse für 2024 (inkl. Testdaten für MTU Aero Engines [4] und AMAG [6])
INSERT INTO AktienKurs (AK_ID, AK_DatumZeit, AK_Kurs, AK_BoerseID, AK_AktieID, AK_Anzahl) VALUES
(10021, '2024-04-19 10:08:00.033', 53.55, 1, 6, 5),
(10022, '2024-04-19 10:09:20.110', 54.21, 2, 6, 100),
(10023, '2024-04-19 10:09:55.110', 54.19, 1, 6, 150),
(10024, '2024-04-19 10:09:55.120', 222.66, 2, 4, 150), -- MTU Aero Engines
(10025, '2024-04-19 10:11:55.120', 53.99, 4, 6, 150),
(10026, '2024-04-19 10:12:05.120', 53.98, 3, 6, 70),
(10027, '2024-04-19 11:00:01.020', 54.02, 2, 6, 99),
(10028, '2024-04-19 11:00:02.033', 54.06, 3, 6, 120),
(10029, '2024-04-19 11:00:02.133', 54.00, 2, 6, 250);

-- Archivdaten für Vorjahre (2023 und 2022 für Aufgabe d)
INSERT INTO AktienKursArchiv (AK_ID, AK_DatumZeit, AK_Kurs, AK_BoerseID, AK_AktieID, AK_Anzahl) VALUES
(8001, '2023-03-15 09:30:00.000', 48.33, 1, 6, 500),
(8002, '2023-06-20 14:15:00.000', 52.09, 2, 6, 800),
(8003, '2023-11-10 11:00:00.000', 50.12, 3, 6, 300),
(7001, '2022-04-05 10:00:00.000', 48.32, 1, 6, 400),
(7002, '2022-08-18 15:30:00.000', 51.44, 2, 6, 600),
(7003, '2022-12-01 12:45:00.000', 49.80, 4, 6, 250);
GO

-- ============================================================================
-- 📝 Aufgabe 4.a) DML: Datensätze einer nicht mehr gehandelten Aktie löschen (2 Punkte)
--
-- Aufgabenstellung:
-- Die Aktie mit dem Namen "MTU Aero Engines" wird nicht mehr gehandelt.
-- Erstellen Sie eine SQL-Anweisung, welche alle Einträge der Aktie
-- (AK_AktieID: 4) aus der Tabelle AktienKurs entfernt.
-- ============================================================================

DELETE FROM AktienKurs
WHERE AK_AktieID = 4;
GO

-- ============================================================================
-- 📝 Aufgabe 4.b) DQL: Kursstatistiken der AMAG-Aktie je Börse (8 Punkte)
--
-- Aufgabenstellung:
-- Erstellen Sie eine SQL-Anweisung, welche den Minimal-, den Maximal-, den
-- Durchschnittskurs sowie die Anzahl der Transaktionen der AMAG-Aktie
-- (AK_AktieID: 6) an den verschiedenen Börsen entsprechend der Ergebnistabelle ausgibt:
--
-- Ergebnistabelle:
-- B_ID | B_BoersenName                  | KursMin | KursMax | KursDurchschnitt | AnzahlTransaktionen
-- 1    | Börse Frankfurt                | 53.55   | 54.19   | 53.870000        | 2434
-- 2    | Stuttgarter Wertpapierbörse   | 54.00   | 54.21   | 54.076666        | 3234
-- 3    | Niedersächsische Börse Hannov. | 53.98   | 54.06   | 54.020000        | 2334
-- 4    | Börse Düsseldorf              | 53.99   | 53.99   | 53.990000        | 1223
-- ============================================================================

SELECT b.B_ID,
       b.B_BoersenName,
       MIN(ak.AK_Kurs) AS KursMin,
       MAX(ak.AK_Kurs) AS KursMax,
       AVG(ak.AK_Kurs) AS KursDurchschnitt,
       COUNT(*) AS AnzahlTransaktionen
FROM Boerse AS b
INNER JOIN AktienKurs AS ak ON b.B_ID = ak.AK_BoerseID
WHERE ak.AK_AktieID = 6
GROUP BY b.B_ID, b.B_BoersenName;
GO

-- ============================================================================
-- 📝 Aufgabe 4.c) DML: Vorjahresdaten ins Archiv verschieben (8 Punkte)
--
-- Aufgabenstellung:
-- Am Anfang eines neuen Jahres werden alle Daten der Vorjahre aus der Tabelle
-- AktienKurs in die Tabelle AktienKursArchiv verschoben.
-- Die Tabelle AktienKursArchiv ist gleich der Tabelle AktienKurs aufgebaut.
-- Erstellen Sie SQL-Anweisungen, welche die Daten entsprechend der Beschreibung verschieben.
-- ============================================================================

-- Schritt 1: Kopieren aller Vorjahresdaten in die Archivtabelle (INSERT INTO ... SELECT)
INSERT INTO AktienKursArchiv (AK_ID, AK_DatumZeit, AK_Kurs, AK_BoerseID, AK_AktieID, AK_Anzahl)
SELECT AK_ID,
       AK_DatumZeit,
       AK_Kurs,
       AK_BoerseID,
       AK_AktieID,
       AK_Anzahl
FROM AktienKurs
WHERE YEAR(AK_DatumZeit) < YEAR(GETDATE());

-- Schritt 2: Bereinigung der operativen Live-Tabelle
DELETE FROM AktienKurs
WHERE YEAR(AK_DatumZeit) < YEAR(GETDATE());
GO

-- ============================================================================
-- 📝 Aufgabe 4.d) DQL & MENGENOPERATOR: Fusion von Live- und Archivdaten (12 Punkte)
--
-- Aufgabenstellung:
-- Sie möchten für alle Jahre über alle Börsen den Minimal- und den Maximalkurs
-- sowie die Anzahl der Transaktionen im Jahr von der AMAG-Aktie (AK_AktieID: 6)
-- entsprechend der nachfolgenden Ergebnistabelle erhalten.
-- Die Tabelle soll absteigend nach Jahren sortiert werden.
-- Denken Sie daran, dass die Daten der Vorjahre in der Tabelle AktienKursArchiv archiviert wurden.
--
-- Ergebnistabelle:
-- Boersenjahr | KursMin | KursMax | AnzahlTransaktionen
-- 2024        | 53.55   | 54.21   | 8343
-- 2023        | 48.33   | 52.09   | 9987
-- 2022        | 48.32   | 51.44   | 6554
-- ============================================================================

-- Variante 1: UNION ALL in einer Derived Table (Empfohlene IHK-Musterlösung)
SELECT YEAR(ges.AK_DatumZeit) AS Boersenjahr,
       MIN(ges.AK_Kurs) AS KursMin,
       MAX(ges.AK_Kurs) AS KursMax,
       COUNT(*) AS AnzahlTransaktionen
FROM (
    SELECT AK_DatumZeit, AK_Kurs, AK_AktieID
    FROM AktienKurs
    WHERE AK_AktieID = 6
    UNION ALL
    SELECT AK_DatumZeit, AK_Kurs, AK_AktieID
    FROM AktienKursArchiv
    WHERE AK_AktieID = 6
) AS ges
GROUP BY YEAR(ges.AK_DatumZeit)
ORDER BY Boersenjahr DESC;
GO

-- Variante 2: UNION ALL mit Common Table Expression (CTE)
WITH AlleAktienKurse AS (
    SELECT AK_DatumZeit, AK_Kurs, AK_AktieID
    FROM AktienKurs
    WHERE AK_AktieID = 6
    UNION ALL
    SELECT AK_DatumZeit, AK_Kurs, AK_AktieID
    FROM AktienKursArchiv
    WHERE AK_AktieID = 6
)

SELECT YEAR(AK_DatumZeit) AS Boersenjahr,
       MIN(AK_Kurs) AS KursMin,
       MAX(AK_Kurs) AS KursMax,
       COUNT(*) AS AnzahlTransaktionen
FROM AlleAktienKurse
GROUP BY YEAR(AK_DatumZeit)
ORDER BY Boersenjahr DESC;
GO
