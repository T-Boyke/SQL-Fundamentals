USE ProjektDB;

--	Variablen
DECLARE @anzahlP1 INT;
SET @anzahlP1 = 
	(SELECT COUNT(*) FROM Arbeit
	 WHERE pro_id = 1);

SELECT @anzahlP1 AS [Anzahl Mitarbeiter in Projekt 1];
PRINT 'Anzahl Mitarbeiter in Projekt 1: ' + CONVERT(VARCHAR(10), @anzahlP1);

--	Verzweigungen
IF @anzahlP1 < 3
	PRINT 'Mitarbeiter-Anzahl ist kleiner 3'
ELSE
BEGIN
	PRINT 'Liste der Mitarbeiter im Projekt 1:'
	SELECT a.mit_id, m.nachname, m.vorname
	FROM Arbeit a
	INNER JOIN Mitarbeiter m ON m.id = a.mit_id
	WHERE a.pro_id = 1
	DECLARE @test INT = 42	--	Scope ist der Batch, nicht der Block
END

PRINT @test;

--	Schleifen
WHILE (SELECT SUM(mittel) FROM Projekt) < 1000000
BEGIN
	UPDATE Projekt
	SET mittel = mittel * 1.1
	PRINT 'Projekt-Mittel wurden erhöht'

	IF (SELECT MAX(mittel) FROM Projekt) > 250000
	BEGIN
		PRINT 'Das maximale Mittel eines Projekts wurde überschritten.'
		BREAK
	END
END
GO


--	Stored Procedures
CREATE OR ALTER PROCEDURE usp_AlleProjekte
AS
BEGIN
	SELECT *
	FROM Projekt
END
GO

EXEC usp_AlleProjekte
GO

CREATE OR ALTER PROCEDURE usp_MitarbeiterProjekte
@mit_id INT = NULL
AS
BEGIN
	SELECT m.vorname, m.nachname, p.bezeichnung
	FROM Mitarbeiter m
	INNER JOIN Arbeit a ON a.mit_id = m.id
	INNER JOIN Projekt p ON p.id = a.pro_id
	WHERE m.id = @mit_id OR @mit_id IS NULL;
END
GO

EXEC usp_MitarbeiterProjekte 17000
