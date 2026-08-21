USE master;

DROP DATABASE IF EXISTS RabattBestellungen;

CREATE DATABASE RabattBestellungen;
GO

USE RabattBestellungen;

--	Aufgabe a)
CREATE TABLE Bestellung (
	bestellId INT IDENTITY(4711, 1) /*CONSTRAINT pk_bestellung*/ PRIMARY KEY,
	datum DATE NOT NULL,
	kundenId INT
);

CREATE TABLE Artikel (
	artikelId INT IDENTITY(1, 1),
	bezeichnung NVARCHAR(100) NOT NULL,
	preis DECIMAL(10, 2) NOT NULL,
	gruppe NVARCHAR(20) NOT NULL,
	rabatt DECIMAL(5, 2) NOT NULL,
	/*CONSTRAINT pk_artikel*/ PRIMARY KEY (artikelId)
);

CREATE TABLE bestellungArtikel (
	bestellId INT,
	artikelId INT /*CONSTRAINT fk_bestellungArtikel_artikel*/ FOREIGN KEY REFERENCES Artikel (artikelId),
	menge INT,
	/*CONSTRAINT pk_bestellungArtikel*/		-- muss hier stehen, weil mehrere Spalten
		PRIMARY KEY (bestellId, artikelId),
	/*CONSTRAINT fk_bestellungArtikel_bestellung*/	-- kann auch oben stehen
		FOREIGN KEY (bestellid)
		REFERENCES Bestellung (bestellId)
);
GO

--	Aufgabe b)
INSERT INTO Bestellung
VALUES ('20210927', 11),
('20210928', 22),
('20210930', 33),
('20211001', 11);

SELECT * FROM Bestellung;

INSERT INTO Artikel
VALUES ('Fernseher', 799, 'Elektronik', 10),
('Monitor', 199, 'Elektronik', 10),
('Tastatur', 39, 'Peripherie', 20),
('Maus', 19, 'Peripherie', 20),
('Hundefutter', 49, 'Tiernahrung', 0);

SELECT * FROM Artikel;

INSERT INTO bestellungArtikel
VALUES (4711, 1, 1),
(4712, 2, 1),
(4712, 3, 2),
(4712, 1, 2),
(4713, 4, 1),
(4714, 5, 1);

SELECT * FROM bestellungArtikel;

--	Aufgabe c)
--	1. Tabelle Gruppe erstellen
CREATE TABLE Gruppe (
	gruppeId INT IDENTITY,
	gruppe NVARCHAR(20) NOT NULL,
	rabatt DECIMAL(5, 2) NOT NULL,
	/*CONSTRAINT pk_gruppe*/
		PRIMARY KEY (gruppeId)
);

-- Daten einfügen
INSERT INTO Gruppe
SELECT DISTINCT gruppe, rabatt FROM Artikel;	-- Alternative zu VALUES-Klausel

SELECT * FROM Gruppe;

--	Tabelle Artikel erweitern
ALTER TABLE Artikel
ADD gruppeId INT CONSTRAINT fk_artikel_gruppe
	FOREIGN KEY REFERENCES Gruppe (gruppeId);

--	gruppeId in Tabelle Artikel eintragen
UPDATE Artikel SET gruppeId = 1
WHERE gruppe = 'Elektronik';

UPDATE Artikel SET gruppeId = 2
WHERE gruppe = 'Peripherie';

UPDATE Artikel SET gruppeId = 3
WHERE gruppe = 'Tiernahrung';

SELECT * FROM Artikel;

--	Spalten aus Artikel entfernen
ALTER TABLE Artikel
DROP COLUMN gruppe, rabatt;

SELECT * FROM Bestellung;
SELECT * FROM Artikel;
SELECT * FROM bestellungArtikel;
SELECT * FROM Gruppe;
