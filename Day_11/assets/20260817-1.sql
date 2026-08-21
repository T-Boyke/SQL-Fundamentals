USE ProjektDB;

--	SELECT-Klausel
--	ohne FROM mit Alias
SELECT 'abc' AS spalte1, 5 * 5 AS spalte2;

--	mit FROM
SELECT firma, ort 
FROM Kunde;

SELECT *		--	alle Spalten
FROM Kunde;

--	Funktionen/Berechnungen
SELECT CONCAT(vorname, ' ', nachname) AS name
FROM Mitarbeiter;

--	Doppelte Zeile entfernen
SELECT DISTINCT ort
FROM Mitarbeiter;

--	Filtern mit WHERE Klausel
SELECT *
FROM Kunde
WHERE ort = 'Ulm';

SELECT *
FROM Mitarbeiter
WHERE abt_id = 4 AND ort = 'München';

--	NOT vor AND vor OR

--	NULL
--	Jeder "normale" Vergleich mit NULL ergibt UNKNOWN
SELECT *
FROM Mitarbeiter
WHERE ort = NULL;	-- geht nicht!

SELECT *
FROM Mitarbeiter
WHERE ort IS NULL;

--	Auswahloperatoren
SELECT *
FROM Mitarbeiter
WHERE id BETWEEN 9000 AND 10000;

SELECT *
FROM Mitarbeiter
WHERE ort IN ('Ulm', 'Fürth');
