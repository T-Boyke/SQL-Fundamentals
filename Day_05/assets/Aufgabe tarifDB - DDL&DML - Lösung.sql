--	Nutzen Sie die Datenbank TarifDB
--	um die folgenden Aufgaben zu lösen:
USE TarifDB;


--	Aufgabe 1)
--
--	Legen Sie eine neue Tabelle kundengruppe
--	mit folgenden Feldern an:
--		kundengruppeNr INT,
--		name NVARCHAR(50)

CREATE TABLE kundengruppe (
	kundengruppeNr INT IDENTITY,
	name NVARCHAR(50),
	CONSTRAINT pk_kundengruppe
		PRIMARY KEY (kundengruppeNr)
);

--	Aufgabe 2)
--
--	Fügen Sie die folgenden beiden Gruppen in die 
--	Tabelle ein:
--		Stammkunden
--		Rabatt-Jäger

INSERT INTO kundengruppe
VALUES ('Stammkunden'), ('Rabatt-Jäger');

SELECT * FROM kundengruppe;

--	Aufgabe 3)
--
--	Die Tabelle kunde soll in einer 1:n-Beziehung
--	zur Tabelle kundengruppe stehen. Ein Kunde ist
--	in genau einer Gruppe und in einer Gruppe können
--	mehrere Kunden sein. Stellen Sie die Verknüpfung
--	zwischen den Tabellen her.

ALTER TABLE kunde
ADD kundengruppeNr INT CONSTRAINT fk_kunde_kundengruppe
	FOREIGN KEY REFERENCES kundengruppe (kundengruppeNr);

--	Aufgabe 4)
--
--	Ordnen Sie alle Kunden der Gruppe Stammkunden zu.

--	Erstmal Kunden/AP anlegen

INSERT INTO ansprechpartner
VALUES ('Müller', 'Hans', '0111-45678', 'hm@energieversorger.de');

INSERT INTO Kunde
VALUES ('Maier', 'Clara', 'Waldessaum 11', '99999', 'Tannen', 1, NULL),
('Mustermann', 'Max', 'Zum Beispiel 1', '12345', 'Musterstadt', 1, NULL);

--	Eigentliche Aufgabe

UPDATE Kunde
SET kundengruppeNr = 1;

--	Aufgabe 5)
--
--	Die Spalte kundengruppeNr (oder wie sie die Spalte
--	auch immer genannt haben) in der Tabelle kunde
--	soll ab sofort kein NULL mehr erlauben. Passen Sie 
--	die Tabelle entsprechend an.

ALTER TABLE Kunde
ALTER COLUMN kundengruppeNr INT NOT NULL;

--	Aufgabe 6)
--	
--	Benennen Sie in der Tabelle kundengruppe die Spalte 
--	name in bezeichnung um.

EXEC sp_rename 'kundengruppe.name', 'bezeichnung', 'COLUMN';

--	Aufgabe 7)
--
--	Die Tabelle kundengruppe mit all ihren Informationen
--	soll wieder aus der Datenbank entfernt werden.
--	Unternehmen Sie die notwendigen Schritte.

--	Fremdschlüssel entfernen
ALTER TABLE Kunde
DROP CONSTRAINT fk_kunde_kundengruppe;

--	Spalte löschen
ALTER TABLE Kunde
DROP COLUMN kundengruppeNr;

--	Tabelle löschen
DROP TABLE kundengruppe;

