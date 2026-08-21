-- Den Fokus verlegen
USE master;

-- Datenbank löschen - nur im Entwicklungsstadium
DROP DATABASE IF EXISTS TarifDB;
GO

-- Datenbank erstellen
CREATE DATABASE TarifDB;
GO

-- Fokus auf neue Datenbank
USE TarifDB;

-- Tabellen erstellen
CREATE TABLE ansprechpartner (
	ansprechpartnerNr INT IDENTITY,
	name NVARCHAR(100) NOT NULL,
	vorname NVARCHAR(100) NOT NULL,
	telefon NVARCHAR(30) NOT NULL,
	mail NVARCHAR(100) NOT NULL,
	CONSTRAINT pk_ansprechpartner
		PRIMARY KEY (ansprechpartnerNr)
);
GO

CREATE TABLE Tarif (
	tarifNr INT IDENTITY,
	bezeichnung NVARCHAR(100) NOT NULL,
	CONSTRAINT pk_tarif
		PRIMARY KEY (tarifNr)
);
GO

CREATE TABLE Kunde (
	kundenNr INT IDENTITY,
	name NVARCHAR(100) NOT NULL,
	vorname NVARCHAR(100) NOT NULL,
	strasse NVARCHAR(50) NOT NULL,
	plz NCHAR(5) NOT NULL,
	ort NVARCHAR(100) NOT NULL,
	ansprechpartnerNr INT NOT NULL,
	CONSTRAINT pk_kunde
		PRIMARY KEY (kundenNr),
	CONSTRAINT fk_kunde_ansprechpartner
		FOREIGN KEY (ansprechpartnerNr)
		REFERENCES ansprechpartner (ansprechpartnerNr)
);
GO

CREATE TABLE kundetarif (
	ktNr INT IDENTITY,
	kundenNr INT NOT NULL,
	tarifNr INT NOT NULL,
	beginn DATE NOT NULL,
	ende DATE NULL,
	CONSTRAINT pk_kundetarif
		PRIMARY KEY (ktNr),
	CONSTRAINT fk_kundetarif_kunde
		FOREIGN KEY (kundenNr)
		REFERENCES Kunde (kundenNr),
	CONSTRAINT fk_kundetarif_tarif
		FOREIGN KEY (tarifNr)
		REFERENCES Tarif (tarifNr)
);
GO
