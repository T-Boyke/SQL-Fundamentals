-- Nutzen Sie die Datenbank ProjektDB, 
-- um die folgenden Aufgaben zu lösen:
USE ProjektDB;

-- ==================
-- Aggregatfunktionen
-- ==================

-- Aufgabe 4.3
--
-- Nennen Sie die kleinste Personalnummer der Mitarbeiter.
--
--      minimum
--      2581

SELECT MIN(id) AS minimum
FROM Mitarbeiter;

-- Aufgabe 4.4
--
-- Berechnen Sie die Summe der finanziellen Mittel aller Projekte.
--
--      summe
--      655000,00

SELECT SUM(mittel) AS summe
FROM Projekt;

-- Aufgabe 4.5
--
-- Berechnen Sie den arithmetischen Mittelwert der Geldbeträge, 
-- die höher als 92336,10 Euro sind.
--
--      durchschnitt
--      141625,00

SELECT AVG(mittel) AS durchschnitt
FROM Projekt
WHERE mittel > 92336.1;

-- Aufgabe 4.6
--
-- Ermitteln Sie den höchsten, einzelnen Umsatz, der bisher erzielt wurde.
--
--      umsatz
--      150000,00

SELECT MAX(umsatz) AS umsatz
FROM Umsatz;
