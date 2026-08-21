USE master;

-- Datenbank löschen, falls vorhanden
DROP DATABASE IF EXISTS ProjektDB;

-- Datenbank erstellen
CREATE DATABASE ProjektDB;
GO

-- Authorisierung ändern für Diagramme
ALTER AUTHORIZATION ON DATABASE::ProjektDB TO sa
GO

-- Zur neuen Datenbank wechseln
USE ProjektDB;
GO

-- Anlegen der Tabellen
CREATE TABLE Abteilung (
    id          INT IDENTITY  NOT NULL,
    kuerzel     NCHAR(2)      NOT NULL,
    bezeichnung NVARCHAR(30)  NOT NULL,
    ort         NVARCHAR(25)  NULL,
    CONSTRAINT pk_abteilung 
        PRIMARY KEY (id)
);
GO

CREATE TABLE Kunde (
    id          INT IDENTITY  NOT NULL,
    firma       NVARCHAR(30)  NOT NULL,
    ort         NVARCHAR(25)  NOT NULL,
    CONSTRAINT pk_kunde 
        PRIMARY KEY (id)
);
GO

CREATE TABLE Projekt (
    id          INT IDENTITY  NOT NULL,
    kuerzel     NCHAR(2)      NOT NULL,
    bezeichnung NVARCHAR(30)  NOT NULL,
    mittel      MONEY         NULL,
    kunde_id    INT           NULL,
    CONSTRAINT pk_projekt 
        PRIMARY KEY (id),
    CONSTRAINT fk_projekt_kunde 
        FOREIGN KEY (kunde_id) REFERENCES Kunde (id)
);
GO

CREATE TABLE Mitarbeiter (
    id          INT IDENTITY  NOT NULL,
    vorname     NVARCHAR(30)  NOT NULL,
    nachname    NVARCHAR(30)  NOT NULL,
    abt_id      INT           NULL,
    ort         NVARCHAR(25)  NULL,
    chef_id     INT           NULL,
    CONSTRAINT pk_mitarbeiter 
        PRIMARY KEY (id),
    CONSTRAINT fk_mitarbeiter_abteilung 
        FOREIGN KEY(abt_id) REFERENCES Abteilung (id),
    CONSTRAINT fk_mitarbeiter_mitarbeiter
        FOREIGN KEY(chef_id) REFERENCES Mitarbeiter (id)
);
GO

CREATE TABLE Arbeit (
    mit_id      INT           NOT NULL,
    pro_id      INT           NOT NULL,
    aufgabe     NVARCHAR(30)  NULL,
    einst_dat   DATE          NULL,
    CONSTRAINT pk_arbeit 
        PRIMARY KEY(mit_id, pro_id),
    CONSTRAINT fk_arbeit_mitarbeiter 
        FOREIGN KEY (mit_id) REFERENCES Mitarbeiter (id),
    CONSTRAINT fk_arbeit_projekt 
        FOREIGN KEY (pro_id) REFERENCES Projekt (id)
);
GO

CREATE TABLE Gehalt (
    mit_id      INT    NOT NULL,
    gehalt      MONEY  NOT NULL, 
    CONSTRAINT pk_gehalt 
        PRIMARY KEY(mit_id),
    CONSTRAINT fk_gehalt_mitarbeiter 
        FOREIGN KEY (mit_id) REFERENCES Mitarbeiter (id)
);
GO

CREATE TABLE Umsatz (
    id          INT IDENTITY  NOT NULL,
    mit_id      INT           NOT NULL,
    datum       DATE          NOT NULL,
    umsatz      MONEY         NOT NULL,
    CONSTRAINT pk_umsatz 
        PRIMARY KEY (id),
    CONSTRAINT fk_umsatz_mitarbeiter 
        FOREIGN KEY (mit_id) REFERENCES Mitarbeiter (id)
);
GO
  
-- Daten der Tabelle Abteilung
INSERT INTO Abteilung VALUES (N'BE', N'Beratung', N'München');
INSERT INTO Abteilung VALUES (N'DI', N'Diagnose', N'München');
INSERT INTO Abteilung VALUES (N'FR', N'Freigabe', N'Stuttgart');
INSERT INTO Abteilung VALUES (N'EK', N'Einkauf', N'München');
INSERT INTO Abteilung VALUES (N'VK', N'Verkauf', N'Ulm');

-- Daten der Tabelle Kunde
INSERT INTO Kunde VALUES (N'Im- und Export AG', N'München');
INSERT INTO Kunde VALUES (N'Technische Produkte oHG', N'Ulm');
INSERT INTO Kunde VALUES (N'Frankreich-Reisen GmbH', N'Saarlouis');
INSERT INTO Kunde VALUES (N'Getränke Schneider', N'Heidenheim');
INSERT INTO Kunde VALUES (N'Finanzamt Ulm', N'Fürth');
INSERT INTO Kunde VALUES (N'100% Sonderzeichen AG', N'Baden_Baden');

-- Daten der Tabelle Projekt
INSERT INTO Projekt VALUES (N'AP', N'Apollo', 120000.0, 3);
INSERT INTO Projekt VALUES (N'GM', N'Gemini', 95000.0, 5);
INSERT INTO Projekt VALUES (N'MK', N'Merkur', 186500.0, 1);
INSERT INTO Projekt VALUES (N'PL', N'Pluto', 88500.0, 4);
INSERT INTO Projekt VALUES (N'AR', N'Ariane', 165000.0, 2);

-- Daten der Tabelle Mitarbeiter
SET IDENTITY_INSERT Mitarbeiter ON;
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (2581, N'Kaufmann', N'Brigitte', 2, NULL, NULL);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (22222, N'Vogel', N'Anke', 4, N'München', NULL);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (5765, N'Schäfer', N'Sabine', 3, N'Landshut', 2581);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (9031, N'Meier', N'Rainer', 2, NULL, 2581);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (9912, N'Wolf', N'Klaus', 4, N'Heidenheim', 22222);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (10102, N'Huber', N'Petra', 3, N'Landshut', 2581);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (12121, N'Richter', N'Ursula', 4, N'München', 22222);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (17000, N'Krüger', N'Martin', 5, N'Ulm', 22222);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (18316, N'Müller', N'Gabriele', 1, N'Rosenheim', 2581);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (20204, N'Fuchs', N'Dirk', 4, N'Fürth', 22222);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (24321, N'Schubert', N'Rolf', 5, N'München', 22222);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (25348, N'Keller', N'Hans', 3, N'München', 2581);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (27365, N'Albrecht', N'Lena', 5, NULL, 22222);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (28559, N'Mozer', N'Sibille', 1, N'Ulm', 2581);
INSERT INTO Mitarbeiter (id, nachname, vorname, abt_id, ort, chef_id) VALUES (29346, N'Probst', N'Andreas', 2, N'Augsburg', 2581);
SET IDENTITY_INSERT Mitarbeiter OFF;

-- Daten der Tabelle Gehalt
INSERT INTO Gehalt VALUES (2581, 3000);
INSERT INTO Gehalt VALUES (5765, 4500);
INSERT INTO Gehalt VALUES (9031, 4000);
INSERT INTO Gehalt VALUES (9912, 3500);
INSERT INTO Gehalt VALUES (10102, 3500);
INSERT INTO Gehalt VALUES (12121, 3000);
INSERT INTO Gehalt VALUES (17000, 4000);
INSERT INTO Gehalt VALUES (18316, 3000);
INSERT INTO Gehalt VALUES (20204, 3500);
INSERT INTO Gehalt VALUES (22222, 5000);
INSERT INTO Gehalt VALUES (24321, 3000);
INSERT INTO Gehalt VALUES (25348, 1000);
INSERT INTO Gehalt VALUES (27365, 2500);
INSERT INTO Gehalt VALUES (28559, 6000);
INSERT INTO Gehalt VALUES (29346, 5000);

-- Daten der Tabelle Arbeit
INSERT INTO Arbeit VALUES (2581, 3, N'Projektleiter', '20191015');
INSERT INTO Arbeit VALUES (5765, 4, N'Projektleiter', '20180720');
INSERT INTO Arbeit VALUES (9031, 1, N'Gruppenleiter', '20190415');
INSERT INTO Arbeit VALUES (9031, 3, N'Sachbearbeiter', '20181115');
INSERT INTO Arbeit VALUES (9912, 5, N'Sachbearbeiter', '20190117');
INSERT INTO Arbeit VALUES (10102, 1, N'Projektleiter', '20181001');
INSERT INTO Arbeit VALUES (10102, 3, N'Gruppenleiter', '20190101');
INSERT INTO Arbeit VALUES (12121, 4, N'Gruppenleiter', '20180903');
INSERT INTO Arbeit VALUES (17000, 5, NULL, '20191112');
INSERT INTO Arbeit VALUES (17000, 1, NULL, '20191112');
INSERT INTO Arbeit VALUES (18316, 2, NULL, '20190601');
INSERT INTO Arbeit VALUES (20204, 4, N'Sachbearbeiter', '20171220');
INSERT INTO Arbeit VALUES (22222, 5, N'Projektleiter', '20190101');
INSERT INTO Arbeit VALUES (24321, 3, NULL, '20181201');
INSERT INTO Arbeit VALUES (25348, 2, N'Sachbearbeiter', '20180215');
INSERT INTO Arbeit VALUES (27365, 4, N'Sachbearbeiter', '20180903');
INSERT INTO Arbeit VALUES (28559, 1, NULL, '20180415');
INSERT INTO Arbeit VALUES (28559, 2, N'Sachbearbeiter', '20180201');
INSERT INTO Arbeit VALUES (29346, 1, N'Sachbearbeiter', '20190401');
INSERT INTO Arbeit VALUES (29346, 2, NULL, '20171215');

-- Daten der Tabelle Umsatz
INSERT INTO Umsatz VALUES (10102, '20181001', 500);
INSERT INTO Umsatz VALUES (10102, '20181002', 500);
INSERT INTO Umsatz VALUES (10102, '20181101', 500);
INSERT INTO Umsatz VALUES (10102, '20181101', 5000);
INSERT INTO Umsatz VALUES (10102, '20181102', 500);
INSERT INTO Umsatz VALUES (10102, '20181209', 500);
INSERT INTO Umsatz VALUES (10102, '20181210', 500);
INSERT INTO Umsatz VALUES (10102, '20181223', 5000);
INSERT INTO Umsatz VALUES (10102, '20181228', 500);
INSERT INTO Umsatz VALUES (10102, '20190101', 4500);
INSERT INTO Umsatz VALUES (25348, '20180215', 1500);
INSERT INTO Umsatz VALUES (25348, '20180216', 1500);
INSERT INTO Umsatz VALUES (25348, '20180217', 1500);
INSERT INTO Umsatz VALUES (25348, '20180501', 1500);
INSERT INTO Umsatz VALUES (25348, '20180502', 15000);
INSERT INTO Umsatz VALUES (25348, '20181011', 15000);
INSERT INTO Umsatz VALUES (25348, '20190201', 150000);
INSERT INTO Umsatz VALUES (25348, '20190301', 1500);
INSERT INTO Umsatz VALUES (25348, '20190401', 15);
INSERT INTO Umsatz VALUES (25348, '20190501', 150);
INSERT INTO Umsatz VALUES (2581, '20190501', 100000);
INSERT INTO Umsatz VALUES (17000, '20180303', 5000);
INSERT INTO Umsatz VALUES (17000, '20180304', 5000);
INSERT INTO Umsatz VALUES (17000, '20180305', 5000);
INSERT INTO Umsatz VALUES (17000, '20180306', 5000);
