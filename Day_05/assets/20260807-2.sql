USE DMLBeispiel;

-- Neue Datensätze anlegen (kunde)
INSERT INTO kunde
VALUES (1, N'Max', N'Mustermann', '19900404');

INSERT INTO kunde (id, vorname, name)
VALUES (2, N'Max', 'Müller');

INSERT INTO kunde (id, name)	-- geht nicht => vorname NOT NULL
VALUES (3, 'Meier');

INSERT INTO kunde				-- geht nicht => PRIMARY KEY
VALUES (2, 'M', 'M', NULL);

INSERT INTO kunde
VALUES (3, 'Max', 'Meier', NULL),
	   (4, 'Max', 'Mueller', '19600101');

SELECT *
FROM kunde;

-- Neue Datensätze (bestellung)
INSERT INTO bestellung
VALUES ('20260807', 123.45, 1);

INSERT INTO bestellung
VALUES (2, '20260807', 123.45, 1);	-- geht nicht => IDENTITY


SELECT *
FROM bestellung;

-- Daten ändern (kunde)
UPDATE kunde
SET vorname = 'Maximilian'
WHERE id = 1;				-- ohne WHERE werden alle Datensätze geändert

UPDATE kunde
SET vorname = 'Gerda', name = 'Schulz'
WHERE id = 2;

SELECT *
FROM kunde
WHERE name = 'Mustermann';

-- Daten löschen
DELETE FROM kunde
WHERE id = 1;		-- ohne WHERE werden alle Datensätze gelöscht

DELETE FROM kunde
WHERE id = 4;

SELECT *
FROM kunde;
