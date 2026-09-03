--	Nutzen Sie die Datenbank ProjektDB zur 
--	Lösung dieser Aufgabe


--	Aufgabe P1.1
--
--	Erstellen Sie eine gespeicherte Prozedur "sp_FilterMitarbeiter1",
--	die eine Liste der Mitarbeiter ausgibt, die in einer bestimmten
--	Abteilung arbeiten. Die Prozedur soll den Parameter @Abteilung
--	für die Bezeichnung der Abteilung entgegennehmen.
--
--	Beispiel: EXEC sp_FilterMitarbeiter1 'Einkauf'
--	
--	id     vorname  nachname  abt_id  bezeichnung
--	-----  -------  --------  ------  -----------
--	9912   Klaus    Wolf      a4      Einkauf
--	12121  Ursula   Richter   a4      Einkauf
--	20204  Dirk     Fuchs     a4      Einkauf
--	22222  Anke     Vogel     a4      Einkauf



--	Aufgabe P1.2
--
--	Verändern Sie die Prozedur aus Aufgabe P1.1:
--	Wenn keine Mitarbeiter zur angeforderten Abteilung gefunden
--	werden, soll der Text 'Abteilung ungültig: <Bezeichnung>'
--	angezeigt werden. Entweder im Meldungs-Fenster oder im Grid.
--
--	Beispiel: EXEC sp_FilterMitarbeiter1 'Produktion'
--
--	Fehlermeldung
--	------------------------------
--	Abteilung ungültig: Produktion


