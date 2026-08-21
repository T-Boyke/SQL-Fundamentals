-- ============================================================================
-- 📅 Day_09: Klausurvorbereitung & IHK-Prüfungstraining
-- Themen: ERM, Relationales Tabellenmodell, DDL & DML Refactoring
-- Autor: Tobias Boyke
-- Dozent: Tom S.
-- Datum: 13.08.2026
-- ============================================================================

-- ============================================================================
-- 📝 SZENARIO 1: Fußballverein (ERM -> Tabellenmodell -> DDL)
-- ============================================================================
-- Entitäten:
-- 1. Mannschaft (MannschaftsID [PK], Name, Liga)
-- 2. Spieler (SpielerID [PK], Vorname, Nachname, Geburtsdatum, Position, MannschaftsID [FK])
-- 3. Spiel (SpielID [PK], Datum, HeimMannschaftsID [FK], GastMannschaftsID [FK], ToreHeim, ToreGast)
-- 4. Spielereinsatz (SpielID [PK, FK], SpielerID [PK, FK], Spielminuten, GelbeKarten, RoteKarte, Tore)

CREATE DATABASE FussballVereinDB;
GO

USE FussballVereinDB;
GO

CREATE TABLE Mannschaft (
    MannschaftsID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Liga NVARCHAR(50) NOT NULL
);

CREATE TABLE Spieler (
    SpielerID INT IDENTITY(1,1) PRIMARY KEY,
    Vorname NVARCHAR(50) NOT NULL,
    Nachname NVARCHAR(50) NOT NULL,
    Geburtsdatum DATE NOT NULL,
    Position NVARCHAR(30) NOT NULL,
    MannschaftsID INT NOT NULL,
    CONSTRAINT FK_Spieler_Mannschaft FOREIGN KEY (MannschaftsID) 
        REFERENCES Mannschaft(MannschaftsID)
);

CREATE TABLE Spiel (
    SpielID INT IDENTITY(1,1) PRIMARY KEY,
    Datum DATETIME2 NOT NULL,
    HeimMannschaftsID INT NOT NULL,
    GastMannschaftsID INT NOT NULL,
    ToreHeim TINYINT DEFAULT 0,
    ToreGast TINYINT DEFAULT 0,
    CONSTRAINT FK_Spiel_Heim FOREIGN KEY (HeimMannschaftsID) 
        REFERENCES Mannschaft(MannschaftsID),
    CONSTRAINT FK_Spiel_Gast FOREIGN KEY (GastMannschaftsID) 
        REFERENCES Mannschaft(MannschaftsID),
    CONSTRAINT CHK_Verschiedene_Teams CHECK (HeimMannschaftsID <> GastMannschaftsID)
);

CREATE TABLE Spielereinsatz (
    SpielID INT NOT NULL,
    SpielerID INT NOT NULL,
    Spielminuten TINYINT DEFAULT 90,
    GelbeKarten TINYINT DEFAULT 0,
    RoteKarte BIT DEFAULT 0,
    Tore TINYINT DEFAULT 0,
    CONSTRAINT PK_Spielereinsatz PRIMARY KEY (SpielID, SpielerID),
    CONSTRAINT FK_Einsatz_Spiel FOREIGN KEY (SpielID) 
        REFERENCES Spiel(SpielID) ON DELETE CASCADE,
    CONSTRAINT FK_Einsatz_Spieler FOREIGN KEY (SpielerID) 
        REFERENCES Spieler(SpielerID)
);
GO

-- ============================================================================
-- 📝 SZENARIO 2: Zooverwaltung (Gehege, Tierarten, Tiere, Pfleger)
-- ============================================================================

CREATE DATABASE ZooDB;
GO

USE ZooDB;
GO

CREATE TABLE Gehege (
    GehegeID INT IDENTITY(1,1) PRIMARY KEY,
    Bezeichnung NVARCHAR(50) NOT NULL,
    FlaecheQuadratmeter DECIMAL(8,2) NOT NULL,
    IstAussengehege BIT NOT NULL DEFAULT 1
);

CREATE TABLE Tierart (
    ArtID INT IDENTITY(1,1) PRIMARY KEY,
    WissenschaftlicherName NVARCHAR(100) NOT NULL UNIQUE,
    DeutscherName NVARCHAR(100) NOT NULL,
    Gefaehrdungsstatus NVARCHAR(20) DEFAULT 'Nicht gefährdet'
);

CREATE TABLE Tier (
    TierID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Geburtsdatum DATE,
    Geschlecht CHAR(1) CHECK (Geschlecht IN ('M', 'W', 'U')),
    ArtID INT NOT NULL,
    GehegeID INT NOT NULL,
    CONSTRAINT FK_Tier_Art FOREIGN KEY (ArtID) REFERENCES Tierart(ArtID),
    CONSTRAINT FK_Tier_Gehege FOREIGN KEY (GehegeID) REFERENCES Gehege(GehegeID)
);

CREATE TABLE Pfleger (
    PflegerID INT IDENTITY(1,1) PRIMARY KEY,
    Vorname NVARCHAR(50) NOT NULL,
    Nachname NVARCHAR(50) NOT NULL,
    Telefon NVARCHAR(30)
);

-- M:N Koppeltabelle: Pfleger betreut Gehege
CREATE TABLE PflegerGehege (
    PflegerID INT NOT NULL,
    GehegeID INT NOT NULL,
    Hauptzustaendig BIT DEFAULT 0,
    CONSTRAINT PK_PflegerGehege PRIMARY KEY (PflegerID, GehegeID),
    CONSTRAINT FK_PG_Pfleger FOREIGN KEY (PflegerID) REFERENCES Pfleger(PflegerID) ON DELETE CASCADE,
    CONSTRAINT FK_PG_Gehege FOREIGN KEY (GehegeID) REFERENCES Gehege(GehegeID) ON DELETE CASCADE
);
GO
