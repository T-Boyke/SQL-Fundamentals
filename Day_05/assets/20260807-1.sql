USE master;

DROP DATABASE IF EXISTS DMLBeispiel;

CREATE DATABASE DMLBeispiel;
GO

USE DMLBeispiel;

CREATE TABLE kunde (
	id INT,
	vorname NVARCHAR(50) NOT NULL,
	name NVARCHAR(50) NOT NULL,
	gebDat DATE NULL,
	CONSTRAINT pk_kunde
		PRIMARY KEY (id)
);

CREATE TABLE bestellung (
	id INT IDENTITY,
	datum DATE NOT NULL,
	summe MONEY NOT NULL,
	kunde_id INT NOT NULL,
	CONSTRAINT pk_bestellung
		PRIMARY KEY (id),
	CONSTRAINT fk_bestellung_kunde
		FOREIGN KEY (kunde_id)
		REFERENCES kunde (id)
);