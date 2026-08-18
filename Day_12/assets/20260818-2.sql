USE ProjektDB;

--	Aggregatfunktionen
SELECT COUNT(*) AS anzahl
FROM Kunde;

SELECT COUNT(*)
FROM Kunde
WHERE ort LIKE '%e%';

SELECT COUNT(*) AS alle, COUNT(aufgabe) AS aufgaben, COUNT(DISTINCT aufgabe) AS einmal
FROM Arbeit;

SELECT MIN(gehalt), MAX(gehalt), AVG(gehalt), SUM(gehalt), MIN(mit_id)
FROM Gehalt;

SELECT *
FROM Gehalt;
