USE ProjektDB;

--	%	Beliebige Zeichenkette, beliebige Länge (auch nichts)
SELECT *
FROM Mitarbeiter
WHERE nachname LIKE 'S%';

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE 'S%e';

--	_	genau ein beliebiges Zeichen
SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '_a%';

SELECT *
FROM Mitarbeiter
WHERE vorname LIKE '_a%n_';

--	[abc]	genau ein Zeichen aus der Menge abc
SELECT *
FROM Mitarbeiter
WHERE ort LIKE '[AF]%';

--	[^abc]	genau ein beliebiges Zeichen, aber nicht a, b oder c
SELECT *
FROM Mitarbeiter
WHERE ort LIKE '[^AF]%';	-- erwischt keine NULLs!

--	[0-9]	genau ein Zeichen aus dem Bereich 0 bis 9
SELECT *
FROM Mitarbeiter
WHERE nachname LIKE '[T-Z]%';

--	[^0-9]	genau ein beliebiges Zeichen, aber nicht aus dem Bereich 0 bis 9
SELECT *
FROM Mitarbeiter
WHERE nachname LIKE '%[^M-Z]';

--	[%_-]	Suche nach den Joker-Zeichen
SELECT *
FROM Kunde
WHERE firma LIKE '%[%]%';
