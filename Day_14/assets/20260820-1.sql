USE ProjektDB;

--	Subquery in SELECT-Klausel (selbständig)
--	In zwei Schritten
SELECT AVG(gehalt)
FROM Gehalt;

SELECT *, 3633.3333 as durchschnitt
FROM Gehalt;

--	In einem Schritt
SELECT *, 
	(SELECT AVG(gehalt) FROM Gehalt) as durchschnitt
FROM Gehalt;

--	Mit Rechnung
SELECT *, 
	gehalt - (SELECT AVG(gehalt) FROM Gehalt) as differenz
FROM Gehalt;

--	Korrelierte Unterabfrage
SELECT *, 
	gehalt - (SELECT AVG(gehalt) FROM Gehalt) as differenz,
	(SELECT CONCAT(vorname, ' ', nachname) FROM Mitarbeiter
	WHERE id = Gehalt.mit_id) AS name
FROM Gehalt;

--	Subquery in der WHERE-Klausel
--	in zwei Schritten
SELECT id
FROM Abteilung
WHERE ort = 'München';

SELECT * 
FROM Mitarbeiter
WHERE abt_id IN (1, 2, 4);

--	in einem Schritt
SELECT *
FROM Mitarbeiter
WHERE abt_id IN (SELECT id FROM Abteilung
				 WHERE ort = 'München');

--	korrelierte Unterabfrage im WHERE
SELECT *
FROM Mitarbeiter AS m
WHERE (SELECT COUNT(*) FROM Umsatz AS u
		WHERE u.mit_id = m.id) > 5;
