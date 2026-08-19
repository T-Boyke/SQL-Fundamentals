-- ============================================================================
-- Day 13: IHK Prüfungsaufgaben & Handlungsschritte (SQL & DML)
-- Enthält die Musterlösungen aus den IHK-Abschlussprüfungen
-- Autor: Tobias Boyke
-- ============================================================================

-- ============================================================================
-- 1. IHK Prüfungsszenario: Fahrt / Fahrdienst (Handlungsschritt 3b)
-- Tabelle: Fahrt (Fahrt_nr, Datum, Fahrtstrecke_km, Ort, Anzahl_Fahrgaeste, Preis_Fahrt, Preis_Zusatzleistung)
-- ============================================================================

-- ba) Länge der längsten Fahrtstrecke in km mit Alias 'km'
SELECT MAX(Fahrtstrecke_km) AS km
FROM Fahrt;

-- bb) Anzahl der Fahrgäste für Fahrt Nr. 2367
SELECT Anzahl_Fahrgaeste
FROM Fahrt
WHERE Fahrt_Nr = 2367;

-- bc) Summe aller Preise pro Fahrt ohne Zusatzleistungen am 10.11.2017
SELECT SUM(Preis_Fahrt)
FROM Fahrt
WHERE Datum = '2017-11-10'; -- bzw. '10.11.2017'

-- bd) Neuen Datensatz für Fahrt Nr. 6789 einfügen
INSERT INTO Fahrt (Fahrt_nr, Datum, Ort, Preis_Fahrt)
VALUES (6789, '2017-11-10', 'Hamburg', 35.50);

-- be) Für Fahrt Nr. 3333 den Preis für Zusatzleistungen um 10,30 EUR erhöhen
UPDATE Fahrt
SET Preis_Zusatzleistung = Preis_Zusatzleistung + 10.30
WHERE Fahrt_Nr = 3333;


-- ============================================================================
-- 2. IHK Prüfungsszenario: Mitarbeiterverwaltung Fidule GmbH (Handlungsschritt 4c)
-- Tabelle: Mitarbeiter (MitarbeiterNr [PK], Name, Vorname, Geburtsdatum, TelefonPrivat)
-- ============================================================================

-- ca) Fehleranalyse:
-- DELETE FROM Mitarbeiter WHERE Name = 'Müller' AND Vorname = 'Frank';
-- Begründung: Löscht die gesamte Zeile / alle Datensätze von Personen mit dem Namen Frank Müller,
-- anstatt nur das Attribut TelefonPrivat zu leeren!

-- cb) Korrekte Anweisung zur Löschung der privaten Telefonnummer für Mitarbeiter-Nr. 123:
UPDATE Mitarbeiter
SET TelefonPrivat = NULL
WHERE MitarbeiterNr = 123;


-- ============================================================================
-- 3. IHK Prüfungsszenario: Medizinisches Versorgungszentrum (Handlungsschritt 4c)
-- Tabellen: Patient (PID [PK], Nachname, Vorname, Geburtsdatum, TelefonNr)
--           Behandlung (BID [PK], PID [FK], Datum)
-- ============================================================================

-- ca) Alle Patienten (Nachname, Vorname) mit Nachname beginnend mit 'M', aufsteigend sortiert
SELECT Nachname, Vorname
FROM Patient
WHERE Nachname LIKE 'M%'
ORDER BY Nachname ASC;

-- cb) Telefonnummer für Patient mit PID 734 ändern
UPDATE Patient
SET TelefonNr = '0162 - 1234567'
WHERE PID = 734;

-- cc) Anzahl der Behandlungen im Januar 2019
SELECT COUNT(*)
FROM Behandlung
WHERE YEAR(Datum) = 2019 AND MONTH(Datum) = 1;
-- Alternative: WHERE Datum BETWEEN '2019-01-01 00:00:00' AND '2019-01-31 23:59:59';


-- ============================================================================
-- 4. IHK Prüfungsszenario: Ticketsystem (Handlungsschritt 4)
-- Entitäten: Kunde, Ticket, Mitarbeiter, Tätigkeiten
-- ============================================================================

-- cb) Anzahl der Tickets pro Priorität
SELECT Prioritaet, COUNT(TicketID) AS Anzahl
FROM Ticket
GROUP BY Prioritaet;

-- cc) Anzahl der Kunden, die mindestens ein Ticket eröffnet haben
SELECT COUNT(DISTINCT KundenID) AS Anzahl
FROM Ticket;

-- cd) Code-Analyse der Abfrage:
-- SELECT Problembeschreibung, Prioritaet, Zustand, ErfassungDatum 
-- FROM Ticket 
-- WHERE Month(NOW()) - Month(ErfassungDatum) > 2 AND Zustand = 'offen' 
-- ORDER BY ErfassungDatum ASC;
-- Erklärung: Liefert alle offenen Tickets, die vor mehr als zwei Monaten erfasst wurden, 
-- sortiert nach dem Erfassungsdatum aufsteigend.


-- ============================================================================
-- 5. IHK Prüfungsszenario: KFZ-Versicherung
-- Entitäten: Versicherungsnehmer, KFZ_Versicherung, Fahrzeug
-- ============================================================================

-- da) Durchschnittliche Versicherungssumme über alle KFZ-Versicherungsverträge
SELECT AVG(Versicherung_Summe)
FROM KFZ_Versicherung;

-- db) Vertragsnummern (VID) für Mai 2022 mit Summe > 100.000 EUR und Garage = false
SELECT VID
FROM KFZ_Versicherung
WHERE YEAR(Vertragsbeginn) = 2022 
  AND MONTH(Vertragsbeginn) = 5 
  AND Versicherung_Summe > 100000 
  AND Garage = 0; -- bzw. Garage = false


-- ============================================================================
-- 6. IHK Prüfungsszenario: Wellpappe-Produktion
-- Tabelle: ProductionData (OrderID [PK], Width, Length, Thickness, Quantity)
-- ============================================================================

-- aa) Breite, Länge, Dicke und Anzahl für OrderID 736298 (ohne OrderID in Ausgabe)
SELECT Width, Length, Thickness, Quantity
FROM ProductionData
WHERE OrderID = 736298;

-- ab) Anzahl der Produktionsaufträge mit Dicke 2 mm
SELECT COUNT(*)
FROM ProductionData
WHERE Thickness = 2;

-- ac) Gesamtzahl gefertigter Wellpappen (Quantity) mit Dicke 2 mm, Breite 200 mm, Länge 300 mm
SELECT SUM(Quantity)
FROM ProductionData
WHERE Width = 200 
  AND Length = 300 
  AND Thickness = 2;
