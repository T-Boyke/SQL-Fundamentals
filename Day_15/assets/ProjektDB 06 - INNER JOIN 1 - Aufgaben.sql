-- Nutzen Sie die ProjektDB-Datenbank, um die folgenden
-- Aufgaben zu lösen


-- Aufgabe 6.1
--
-- Schreiben Sie eine Abfrage, die alle Mitarbeiter aus der 
-- Abteilung 4 ausgibt. Geben Sie die Felder vorname, nachname
-- und Abteilungsname aus.
--
--      vorname  nachname  bezeichnung
--      Klaus    Wolf      Einkauf
--      Ursula   Richter   Einkauf
--      Dirk     Fuchs     Einkauf
--      Anke     Vogel     Einkauf



-- Aufgabe 6.2
--
-- Schreiben Sie eine Abfrage, die alle Projekte mit den 
-- zugehörigen Projektleitern ausgibt. Geben Sie alle Daten 
-- aus der Projekt-Tabelle und zusätzlich Id und Einstell-
-- Datum aus der Arbeit-Tabelle aus. Sortieren Sie das
-- Ergebnis nach der Projekt-ID.
--
--      id  kuerzel  bezeichnung  mittel     kd_id  mit_id  einst_dat
--      1   AP       Apollo       120000,00  3      10102   2018-10-01
--      3   MK       Merkur       186500,00  1      2581    2019-10-15
--      4   PL       Pluto        88500,00   4      5765    2018-07-20
--      5   AR       Ariane       165000,00  2      22222   2019-01-01



-- Aufgabe 6.3
--
-- Verändern Sie die Abfrage aus Aufgabe 6.2, indem Sie statt der
-- Mitarbeiter-Id den Nachnamen des Mitarbeiters in das Ergebnis 
-- einbauen.
--
--      id  kuerzel  bezeichnung  mittel     kd_id  nachname  einst_dat
--      1   AP       Apollo       120000,00  3      Huber     2018-10-01
--      3   MK       Merkur       186500,00  1      Kaufmann  2019-10-15
--      4   PL       Pluto        88500,00   4      Schäfer   2018-07-20
--      5   AR       Ariane       165000,00  2      Vogel     2019-01-01



-- Aufgabe 6.4
--
-- Erweitern Sie die Abfrage aus Aufgabe 6.3, indem Sie zusätzlich
-- die Bezeichnung der Abteilung in das Ergebnis einbauen.
--
--      id  kuerzel  bezeichnung  mittel     kd_id  nachname  einst_dat   bezeichnung
--      1   AP       Apollo       120000,00  3      Huber     2018-10-01  Freigabe
--      3   MK       Merkur       186500,00  1      Kaufmann  2019-10-15  Diagnose
--      4   PL       Pluto        88500,00   4      Schäfer   2018-07-20  Freigabe
--      5   AR       Ariane       165000,00  2      Vogel     2019-01-01  Einkauf



-- Aufgabe 6.5
--
-- Erstellen Sie eine Abfrage, die die Mitarbeiter mit allen
-- zusätzlichen Informationen zu Abteilung, Gehalt, Arbeit und 
-- Projekt ausgibt. Geben Sie dabei keine Spalten doppelt im 
-- Ergebnis aus.
--
--      id     nachname  vorname   abt_id  ort         chef_id  kuerzel  bezeichnung  ort        gehalt   aufgabe         einst_dat   id  bezeichnung  kd_id
--      2581   Kaufmann  Brigitte  2       NULL        NULL     DI       Diagnose     München    3000,00  Projektleiter   2019-10-15  3   Merkur       1
--      5765   Schäfer   Sabine    3       Landshut    2581     FR       Freigabe     Stuttgart  4500,00  Projektleiter   2018-07-20  4   Pluto        4
--      9031   Meier     Rainer    2       NULL        2581     DI       Diagnose     München    4000,00  Gruppenleiter   2019-04-15  1   Apollo       3
--      9031   Meier     Rainer    2       NULL        2581     DI       Diagnose     München    4000,00  Sachbearbeiter  2018-11-15  3   Merkur       1
--      9912   Wolf      Klaus     4       Heidenheim  22222    EK       Einkauf      München    3500,00  Sachbearbeiter  2019-01-17  5   Ariane       2
--      10102  Huber     Petra     3       Landshut    2581     FR       Freigabe     Stuttgart  3500,00  Projektleiter   2018-10-01  1   Apollo       3
--      ...
--      (20 Zeilen)



-- Aufgabe 6.6
--
-- Geben Sie für die Projekte die mit "A" beginnen die unten
-- gezeigten Informationen aus. Sortieren Sie die Ausgabe 
-- nach dem Projektnamen aufsteigend und der Mitarbeiter-Id 
-- absteigend.
--
--      bezeichnung  firma                    mit_id  aufgabe
--      Apollo       Frankreich-Reisen GmbH   29346   Sachbearbeiter
--      Apollo       Frankreich-Reisen GmbH   28559   NULL
--      Apollo       Frankreich-Reisen GmbH   17000   NULL
--      Apollo       Frankreich-Reisen GmbH   10102   Projektleiter
--      Apollo       Frankreich-Reisen GmbH   9031    Gruppenleiter
--      Ariane       Technische Produkte oHG  22222   Projektleiter
--      Ariane       Technische Produkte oHG  17000   NULL
--      Ariane       Technische Produkte oHG  9912    Sachbearbeiter 



-- Aufgabe 6.7
--
-- Finden Sie Namen und Vornamen aller Mitarbeiter, 
-- die im Projekt Merkur arbeiten.
--
--      nachname  vorname
--      Kaufmann  Brigitte            
--      Meier     Rainer              
--      Huber     Petra 
--      Schubert  Rolf



-- Aufgabe 6.8
--
-- Nennen Sie Namen und Vornamen aller Projektleiter, deren 
-- Abteilung den Standort München hat.
--
--      nachname  vorname
--      Kaufmann  Brigitte
--      Vogel     Anke


