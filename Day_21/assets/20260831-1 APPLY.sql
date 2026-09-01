USE WeitereBeispiele;

--	Person mit letzem Fahrzeug
--	Lösung mit 2x LEFT JOIN 
SELECT p.*, f.*
FROM Person p
LEFT JOIN Fahrzeug f ON f.PersID = p.PersID
LEFT JOIN Fahrzeug f2 ON f2.PersID = p.PersID AND f2.Baujahr > f.Baujahr
WHERE f2.FzgID IS NULL;

--	Lösung mit APPLY
SELECT *
FROM Person p
OUTER APPLY
(
	SELECT TOP (1) *
	FROM Fahrzeug f
	WHERE f.PersID = p.PersID
	ORDER BY Baujahr DESC
) AS a;

USE ProjektDB;

--	Alle Mitarbeiter und dazu der DS mit dem höchsten Umsatz des MA
--	mit APPLY
SELECT *
FROM Mitarbeiter m
CROSS APPLY
(
	SELECT TOP (1) *
	FROM Umsatz u
	WHERE u.mit_id = m.id
	ORDER BY u.umsatz DESC, u.datum DESC
) AS a
ORDER BY a.umsatz DESC;

--	Mit 2x LEFT JOIN
SELECT *
FROM Mitarbeiter m
LEFT JOIN Umsatz u1 ON u1.mit_id = m.id
LEFT JOIN Umsatz u2 ON u2.mit_id = m.id 
	AND (u2.umsatz > u1.umsatz 
		OR (u2.umsatz = u1.umsatz AND u2.datum > u1.datum)
	)
WHERE u2.id IS NULL;
