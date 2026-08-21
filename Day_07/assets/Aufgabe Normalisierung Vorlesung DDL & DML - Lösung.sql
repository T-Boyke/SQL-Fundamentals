USE master;

DROP DATABASE IF EXISTS Vorlesung;

CREATE DATABASE Vorlesung;
GO

USE Vorlesung;

--	Aufgabe a)
CREATE TABLE Vorlesung (
	vorlesungId INT IDENTITY,
	vorlesung NVARCHAR(30) NOT NULL,
	profId INT NOT NULL,
	profVorname NVARCHAR(30),
	profNachname NVARCHAR(30),
	CONSTRAINT pk_vorlesung
		PRIMARY KEY (vorlesungId)
);

CREATE TABLE Student (
	matrikelNr INT IDENTITY(10001, 1),
	studVorname NVARCHAR(30),
	studNachname NVARCHAR(30),
	CONSTRAINT pk_student
		PRIMARY KEY (matrikelNr)
);

CREATE TABLE Anwesenheit (
	vorlesungId INT,
	matrikelNr INT,
	anwesend CHAR(1),
	CONSTRAINT pk_anwesenheit
		PRIMARY KEY (vorlesungId, matrikelNr),
	CONSTRAINT fk_anwesenheit_vorlesung
		FOREIGN KEY (vorlesungId)
		REFERENCES Vorlesung (vorlesungId),
	CONSTRAINT fk_anwesenheit_student
		FOREIGN KEY (matrikelNr)
		REFERENCES Student (matrikelNr)
);
GO

--	Aufgabe b)
INSERT INTO Vorlesung
VALUES ('Einführung BWL', 1, 'Hans', 'Meier'),
('Marketing für IT', 2, 'Gerda', 'Müller'),
('Business English', 1, 'Hans', 'Meier'),
('Java in d. Praxis', 3, 'Inga', 'Ludwig');

INSERT INTO Student
VALUES ('Hans', 'Müller'),
('Udo', 'Meier'),
('Karl', 'Schulz'),
('Laura', 'Richter'),
('Petra', 'Meier'),
('Lisa', 'Sommer');

INSERT INTO Anwesenheit
VALUES (1, 10001, 'j'),
(1, 10002, 'n'),
(1, 10003, 'j'),
(2, 10003, 'n'),
(2, 10004, 'j'),
(2, 10005, 'n'),
(3, 10005, 'j'),
(3, 10006, 'j'),
(4, 10001, 'j'),
(4, 10004, 'j');

--	Aufgabe c)
--	1)
CREATE TABLE Professor (
	profId INT,
	vorname NVARCHAR(30) NOT NULL,
	nachname NVARCHAR(30) NOT NULL,
	CONSTRAINT pk_professor
		PRIMARY KEY (profId)
);

--  2)
INSERT INTO Professor
SELECT DISTINCT profId, profVorname, profNachname
FROM Vorlesung;

--	3)
ALTER TABLE Vorlesung
ADD CONSTRAINT fk_vorlesung_professor
	FOREIGN KEY (profId)
	REFERENCES Professor (profId);

--	4)
ALTER TABLE Vorlesung
DROP COLUMN profVorname, profNachname;
