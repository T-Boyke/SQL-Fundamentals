-- ============================================================================
-- 🎓 IHK Abschlussprüfung: 5. Handlungsschritt (25 Punkte)
-- Szenario: Film-Datenbank der SteamQueen GmbH (Filmarchiv & Mitwirkende)
-- Datei: Day_17/src/02_ihk_abschlusspruefung_filmarchiv_loesung.sql
-- Autor: Tobias Boyke
-- Datum: 25.08.2026
-- ============================================================================

-- ============================================================================
-- 📋 Schema-Definition (Aufbau der Tabellen zum Testen)
-- ============================================================================

-- Tabelle Film
CREATE TABLE Film (
    FilmID INT PRIMARY KEY,
    Titel VARCHAR(255) NOT NULL,
    Erscheinungsjahr INT,
    SpieldauerMinuten INT,
    Preis DECIMAL(10, 2)
);

-- Tabelle Person
CREATE TABLE Person (
    PersonID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Vorname VARCHAR(100) NOT NULL
);

-- Tabelle Eigenschaft
CREATE TABLE Eigenschaft (
    EigenschaftID INT PRIMARY KEY,
    Bezeichnung VARCHAR(100) NOT NULL
);

-- Brückentabelle Person_Eigenschaft_Film
CREATE TABLE Person_Eigenschaft_Film (
    LaufendeNr INT PRIMARY KEY,
    PersonID INT FOREIGN KEY REFERENCES Person(PersonID),
    FilmID INT FOREIGN KEY REFERENCES Film(FilmID),
    EigenschaftID INT FOREIGN KEY REFERENCES Eigenschaft(EigenschaftID)
);
GO

-- ============================================================================
-- 📝 Teilaufgabe a) Tabelle Filmarchiv erstellen (4 Punkte)
-- Aufgabenstellung:
-- Die Tabelle Filmarchiv erstellen, die bis auf das Attribut Preis
-- alle übrigen Attribute der Tabelle Film enthält.
-- ============================================================================

CREATE TABLE Filmarchiv (
    FilmID INT PRIMARY KEY,
    Titel VARCHAR(255) NOT NULL,
    Erscheinungsjahr INT,
    SpieldauerMinuten INT
);
GO

-- ============================================================================
-- 📝 Teilaufgabe b) Daten vor 1950 in Filmarchiv übertragen (4 Punkte)
-- Aufgabenstellung:
-- Aus der Tabelle Film die Daten aller Filme, die vor 1950 erschienen sind,
-- in die Tabelle Filmarchiv übertragen.
-- ============================================================================

INSERT INTO Filmarchiv (FilmID, Titel, Erscheinungsjahr, SpieldauerMinuten)
SELECT FilmID,
       Titel,
       Erscheinungsjahr,
       SpieldauerMinuten
FROM Film
WHERE Erscheinungsjahr < 1950;
GO

-- ============================================================================
-- 📝 Teilaufgabe c) Übertragene Filme aus Film löschen (4 Punkte)
-- Aufgabenstellung:
-- Aus der Tabelle Film alle Daten der Filme löschen, die in die
-- Tabelle Filmarchiv übertragen wurden.
-- ============================================================================

-- Variante 1 (⭐ IHK Musterlösung - Abgleich mit Filmarchiv):
DELETE FROM Film
WHERE FilmID IN (SELECT FilmID FROM Filmarchiv);
GO

-- Variante 2 (Mit EXISTS):
-- DELETE FROM Film
-- WHERE EXISTS (
--     SELECT 1 FROM Filmarchiv 
--     WHERE Filmarchiv.FilmID = Film.FilmID
-- );
-- GO

-- ============================================================================
-- 📝 Teilaufgabe d) Schauspieler und Anzahl ihrer Filme (6 Punkte)
-- Aufgabenstellung:
-- Liste aller Personen ausgeben, die in mindestens einem Film in der
-- Eigenschaft "Schauspieler" mitgewirkt haben. Zu jeder Person die
-- Anzahl der Filme angeben, in denen sie gespielt hat.
--
-- Erwartetes Ergebnis lt. Prüfungsangabe:
-- PersonID | Name   | Vorname | AnzahlFilme
-- 1        | Kelly  | Grace   | 4
-- 2        | Reeves | Keanu   | 1
-- ============================================================================

SELECT p.PersonID,
       p.Name,
       p.Vorname,
       COUNT(pef.FilmID) AS AnzahlFilme
FROM Person AS p
INNER JOIN Person_Eigenschaft_Film AS pef ON p.PersonID = pef.PersonID
INNER JOIN Eigenschaft AS e ON pef.EigenschaftID = e.EigenschaftID
WHERE e.Bezeichnung = 'Schauspieler'
GROUP BY p.PersonID, p.Name, p.Vorname;
GO

-- ============================================================================
-- 📝 Teilaufgabe e) Filme von Grace Kelly vor 1960 (7 Punkte)
-- Aufgabenstellung:
-- Liste aller Filme, an denen Grace Kelly beteiligt war und die vor 1960
-- erschienen sind, absteigend sortiert nach Erscheinungsjahr.
--
-- Erwartetes Ergebnis lt. Prüfungsangabe:
-- Titel                      | Erscheinungsjahr
-- Über den Dächern von Nizza | 1955
-- Das Fenster zum Hof        | 1954
-- High Noon                  | 1952
-- ============================================================================

SELECT DISTINCT f.Titel,
       f.Erscheinungsjahr
FROM Film AS f
INNER JOIN Person_Eigenschaft_Film AS pef ON f.FilmID = pef.FilmID
INNER JOIN Person AS p ON pef.PersonID = p.PersonID
WHERE p.Name = 'Kelly'
  AND p.Vorname = 'Grace'
  AND f.Erscheinungsjahr < 1960
ORDER BY f.Erscheinungsjahr DESC;
GO
