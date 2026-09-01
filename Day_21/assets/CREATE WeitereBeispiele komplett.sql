USE master;

DROP DATABASE IF EXISTS WeitereBeispiele;

CREATE DATABASE WeitereBeispiele;
GO

USE WeitereBeispiele;

-- APPLY
CREATE TABLE Person (
	PersID INT IDENTITY PRIMARY KEY,
	Name VARCHAR(10)
);

CREATE TABLE Fahrzeug (
	FzgID INT IDENTITY PRIMARY KEY,
	PersID INT FOREIGN KEY REFERENCES Person (PersID),
	Modell VARCHAR(20),
	Baujahr INT
);
GO

INSERT INTO Person
VALUES ('Peter'),
('Paul'),
('Mary');

INSERT INTO Fahrzeug
VALUES (1, 'VW Golf', 2005),
(1, 'Opel Astra', 1999),
(1, 'Seat Ibiza', 2018),
(2, 'BMW 5er', 2017),
(2, 'VW Passat', 2012),
(2, 'Dacia Logan', 2001);
GO

-- GROUPING SETS
CREATE TABLE SocialNetwork (
	id INT IDENTITY,
	socialnetwork VARCHAR(10),
	country CHAR(3),
	firstname VARCHAR(30),
	lastname VARCHAR(30),
	CONSTRAINT pk_SocialNetwork
		PRIMARY KEY (id)
);
INSERT INTO SocialNetwork VALUES ('Facebook', 'DEU', 'Amely', 'Nitschke');
INSERT INTO SocialNetwork VALUES ('Facebook', 'DEU', 'Lionel', 'Lampe');
INSERT INTO SocialNetwork VALUES ('Facebook', 'GBR', 'Ellen', 'Nolte');
INSERT INTO SocialNetwork VALUES ('Facebook', 'GBR', 'Luis', 'Ahlers');
INSERT INTO SocialNetwork VALUES ('Facebook', 'GBR', 'Eva', 'Pape');
INSERT INTO SocialNetwork VALUES ('Facebook', 'USA', 'Matti', 'Geisler');
INSERT INTO SocialNetwork VALUES ('Facebook', 'USA', 'Philippa', 'Kessler');
INSERT INTO SocialNetwork VALUES ('Facebook', 'USA', 'Connor', 'Hopf');
INSERT INTO SocialNetwork VALUES ('Facebook', 'USA', 'Marlen', 'Hermann');
INSERT INTO SocialNetwork VALUES ('Instagram', 'DEU', 'Eliah', 'Steffen');
INSERT INTO SocialNetwork VALUES ('Instagram', 'DEU', 'Nisa', 'Funke');
INSERT INTO SocialNetwork VALUES ('Instagram', 'DEU', 'Lian', 'Stolz');
INSERT INTO SocialNetwork VALUES ('Instagram', 'DEU', 'Nadia', 'Krause');
INSERT INTO SocialNetwork VALUES ('Instagram', 'DEU', 'Jackson', 'Schnabel');
INSERT INTO SocialNetwork VALUES ('Instagram', 'GBR', 'Marie', 'Schober');
INSERT INTO SocialNetwork VALUES ('Instagram', 'GBR', 'Marian', 'Hanisch');
INSERT INTO SocialNetwork VALUES ('Instagram', 'GBR', 'Ivy', 'Liedtke');
INSERT INTO SocialNetwork VALUES ('Instagram', 'GBR', 'Joshua', 'Herr');
INSERT INTO SocialNetwork VALUES ('Instagram', 'USA', 'Emilia', 'Stenzel');
INSERT INTO SocialNetwork VALUES ('Instagram', 'USA', 'Sami', 'Janzen');
INSERT INTO SocialNetwork VALUES ('Twitter', 'DEU', 'Selin', 'Trautmann');
INSERT INTO SocialNetwork VALUES ('Twitter', 'DEU', 'Jonah', 'Peters');
INSERT INTO SocialNetwork VALUES ('Twitter', 'DEU', 'Alara', 'Gehring');
INSERT INTO SocialNetwork VALUES ('Twitter', 'GBR', 'Alan', 'Welsch');
INSERT INTO SocialNetwork VALUES ('Twitter', 'GBR', 'Sara', 'Wolff');
INSERT INTO SocialNetwork VALUES ('Twitter', 'GBR', 'Tyler', 'Frisch');
INSERT INTO SocialNetwork VALUES ('Twitter', 'USA', 'Talia', 'Christ');
INSERT INTO SocialNetwork VALUES ('Twitter', 'USA', 'Quentin', 'Engelhardt');
INSERT INTO SocialNetwork VALUES ('Twitter', 'USA', 'Leah', 'Witte');
INSERT INTO SocialNetwork VALUES ('Twitter', 'USA', 'Filip', 'Heuser');


-- MERGE
CREATE TABLE ProductsDW
(
   ProductID INT PRIMARY KEY,
   ProductName VARCHAR(100),
   Price MONEY
);
GO

TRUNCATE TABLE ProductsDW;
INSERT INTO ProductsDW
VALUES
   (1, 'Tea', 10.00),
   (2, 'Coffee', 20.00),
   (3, 'Muffin', 30.00),
   (4, 'Biscuit', 40.00);
GO

CREATE TABLE ProductsLive
(
   ProductID INT PRIMARY KEY,
   ProductName VARCHAR(100),
   Price MONEY
);
GO

INSERT INTO ProductsLive
VALUES
   (1, 'Tea', 10.00),
   (2, 'Coffee', 25.00),
   (3, 'Muffin', 35.00),
   (5, 'Pizza', 60.00);
GO