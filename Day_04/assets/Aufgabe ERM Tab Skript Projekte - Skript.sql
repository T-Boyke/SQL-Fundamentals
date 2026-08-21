USE master;

DROP DATABASE IF EXISTS Projekte;

CREATE DATABASE Projekte;
GO

USE Projekte;

CREATE TABLE abteilung (
	abteilungNr INT IDENTITY,
	bezeichnung NVARCHAR(50) NOT NULL,
	standort NVARCHAR(50) NOT NULL,
	CONSTRAINT pk_abteilung
		PRIMARY KEY (abteilungNr)
);

CREATE TABLE mitarbeiter (
	personalNr INT IDENTITY,
	vorname NVARCHAR(50) NOT NULL,
	name NVARCHAR(50) NOT NULL,
	gebDat DATE NOT NULL,
	gehalt MONEY NOT NULL,
	taetigkeit NVARCHAR(50) NOT NULL,
	abteilungNr INT NOT NULL,
	CONSTRAINT pk_mitarbeiter
		PRIMARY KEY (personalNr),
	CONSTRAINT fk_mitarbeiter_abteilung
		FOREIGN KEY (abteilungNr)
		REFERENCES abteilung (abteilungNr)
);

CREATE TABLE projekt (
	projektNr INT IDENTITY,
	bezeichnung NVARCHAR(100),
	beginn DATE NULL,
	ende DATE NULL,
	leiterNr INT NULL,
	CONSTRAINT pk_projekt
		PRIMARY KEY (projektNr),
	CONSTRAINT fk_projekt_mitarbeiter
		FOREIGN KEY (leiterNr)
		REFERENCES mitarbeiter (personalNr)
);

CREATE TABLE projektMitarbeiter (
	projektNr INT,
	personalNr INT,
	wochenstunden TINYINT NULL,
	CONSTRAINT pk_projektMitarbeiter
		PRIMARY KEY (projektNr, personalNr),
	CONSTRAINT fk_projektMitarbeiter_projekt
		FOREIGN KEY (projektNr)
		REFERENCES projekt (projektNr),
	CONSTRAINT fk_projektMitarbeiter_mitarbeiter
		FOREIGN KEY (personalNr)
		REFERENCES mitarbeiter (personalNr)
);
