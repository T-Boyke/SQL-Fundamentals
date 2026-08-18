USE ProjektDB;

--	ORDER BY
SELECT abt_id, CONCAT(vorname, ' ', nachname) AS name
FROM Mitarbeiter
ORDER BY abt_id DESC, name ASC;

--	TOP (Anzahl oder Prozent)
SELECT TOP (2) *
FROM Mitarbeiter
ORDER BY id;

SELECT TOP (35.37) PERCENT *
FROM Mitarbeiter
ORDER BY id;

--	WITH TIES
SELECT TOP (3) WITH TIES *
FROM Mitarbeiter
ORDER BY abt_id;
