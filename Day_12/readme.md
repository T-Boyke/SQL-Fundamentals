# 📅 Day_12: Stored Procedures (Gespeicherte Prozeduren) & Parameter

## ℹ️ Kurs-Informationen
*   **Datum:** Mittwoch, 18.08.2026
*   **Arbeitszeit:** 08:15 - 16:00 Uhr
*   **Dozent:** Tom S.
*   **Autor:** Tobias Boyke

---

## 🎯 Lernziele des Tages
- [x] **Konzepte verstehen:** Was sind Stored Procedures (Prozeduren) und welche Vorteile bieten sie gegenüber Ad-hoc SQL-Abfragen?
- [x] **Erstellung & Ausführung:** Beherrschung der Befehle `CREATE PROCEDURE`, `ALTER PROCEDURE` und `EXECUTE`.
- [x] **Parameterisierung:** Implementierung von Eingabeparametern mit Default-Werten.
- [x] **Rückgabewerte:** Verwendung von `OUTPUT`-Parametern und dem Befehl `RETURN` für Statuscodes.
- [x] **Fehlerbehandlung:** Strukturierung von robustem Fehler- und Transaktions-Handling (`TRY...CATCH`) innerhalb von Prozeduren.
- [x] **Praktische Anwendung:** Erstellung von lauffähigen Prozeduren auf der `ProjektDB` im [src/](file:///c:/Users/Tobia/Desktop/cSharpRepo/SQL-Fundamentals/Day_12/src/) Ordner.

---

## 📖 Theorie & Konzepte

### 1. Was ist eine Stored Procedure?
Eine **Stored Procedure (gespeicherte Prozedur)** ist ein vorkompiliertes Paket aus SQL-Anweisungen und Kontrollflussstrukturen (wie `IF...ELSE`, `WHILE`, Variable Deklarationen), das dauerhaft in der Datenbank gespeichert wird. 

Im Gegensatz zu einfachen DQL-Abfragen können Stored Procedures Daten abfragen, Daten manipulieren (`INSERT`/`UPDATE`/`DELETE`), administrative Aufgaben durchführen und komplexe Logiken kapseln.

#### 📊 Vergleich: Views vs. Functions vs. Stored Procedures

| Kriterium | View (Sicht) | User-Defined Function (UDF) | Stored Procedure |
| :--- | :--- | :--- | :--- |
| **Primärer Zweck** | Vereinfachung von Abfragen, logische Tabelle | Berechnungen, Datenaufbereitung | Ausführung von Logik & Datenmanipulation |
| **DML-Operationen** | Stark eingeschränkt | Verboten (nur Lesezugriff erlaubt) | Uneingeschränkt erlaubt |
| **Parameter** | Nein | Ja (nur Eingabeparameter) | Ja (Eingabe- und Ausgabeparameter) |
| **Rückgabe** | Ergebnismenge (Tabelle) | Skalarwert oder Tabelle | Ergebnismengen, Output-Parameter & Return-Code |
| **Aufruf** | `SELECT ... FROM View` | `SELECT dbo.Func()` | `EXECUTE ProcName` |
| **Transaktionen** | Nein | Nein | Ja (vollwertiges Transaktions-Handling) |

---

### 2. Die entscheidenden Vorteile von Stored Procedures

*   **1. Höhere Performance (Execution Plan Caching):**
    Wenn eine Stored Procedure zum ersten Mal ausgeführt wird, analysiert der SQL Server die SQL-Statements, erstellt einen optimalen **Ausführungsplan (Execution Plan)** und speichert diesen im *Procedure Cache*. Bei jedem weiteren Aufruf wird dieser Plan wiederverwendet, was Parsing- und Optimierungszeit spart.
*   **2. Starke Sicherheitsvorteile (Ownership Chaining):**
    Benutzer müssen keine direkten Leserechte (`SELECT`) oder Schreibrechte (`INSERT`/`UPDATE`) auf den darunterliegenden Tabellen besitzen. Es genügt, ihnen das Recht `EXECUTE` auf der Stored Procedure zu erteilen. Die Prozedur agiert als Kontrollschicht. Zudem schützt die Parameterbindung effektiv vor **SQL Injection**.
*   **3. Reduzierung der Netzwerklast:**
    Anstatt Hunderte Zeilen komplexen SQL-Codes vom Client-Applikationsserver an den Datenbankserver zu senden, wird lediglich der kurze Befehl `EXEC dbo.usp_Name @Param = 'Wert';` über das Netzwerk geschickt.
*   **4. Kapselung und Wartbarkeit:**
    Die Geschäftslogik liegt zentral in der Datenbank. Ändert sich beispielsweise die Berechnungslogik für einen Rabatt, muss nur die Stored Procedure auf dem Datenbankserver angepasst werden, ohne die Client-Anwendungen neu kompilieren oder verteilen zu müssen.

---

### 3. Syntax & Parameterschnittstellen

#### a) Basis-Syntax (Erstellung & Änderung)

Prozeduren im SQL Server sollten immer mit dem Präfix `usp_` (User Stored Procedure) benannt werden. **Vermeide das Präfix `sp_`!** Das System sucht bei Prozeduren mit `sp_` zuerst in der Systemdatenbank `master`, was zu unnötigem Performance-Overhead führt.

```sql
-- Erstellung einer Prozedur
CREATE PROCEDURE dbo.usp_GetMitarbeiterListe
AS
BEGIN
    -- Best Practice: Unterdrückt Statusmeldungen (z. B. "X Zeilen betroffen")
    SET NOCOUNT ON; 

    SELECT MitarbeiterID, Vorname, Nachname, Gehalt
    FROM dbo.Mitarbeiter;
END;
GO
```

Zum Aktualisieren einer bestehenden Prozedur wird das Schlüsselwort `ALTER` verwendet:
```sql
ALTER PROCEDURE dbo.usp_GetMitarbeiterListe
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MitarbeiterID, Vorname, Nachname, Gehalt, Eintrittsdatum
    FROM dbo.Mitarbeiter
    ORDER BY Nachname ASC;
END;
GO
```

#### b) Eingabeparameter (Input Parameter) mit Default-Werten
Parameter werden nach dem Namen der Prozedur deklariert und beginnen in T-SQL immer mit einem `@`-Zeichen. Standardwerte werden mit dem `=` Operator zugewiesen.

```sql
CREATE PROCEDURE dbo.usp_GetMitarbeiterByGehalt
    @MinGehalt DECIMAL(10,2),                  -- Pflichtparameter
    @MaxGehalt DECIMAL(10,2) = 999999.99      -- Optionaler Parameter mit Default-Wert
AS
BEGIN
    SET NOCOUNT ON;

    SELECT MitarbeiterID, Vorname, Nachname, Gehalt
    FROM dbo.Mitarbeiter
    WHERE Gehalt BETWEEN @MinGehalt AND @MaxGehalt;
END;
GO
```

**Aufruf-Varianten:**
```sql
-- Variante 1: Positionsparameter (Reihenfolge muss exakt stimmen)
EXEC dbo.usp_GetMitarbeiterByGehalt 3000.00, 6000.00;

-- Variante 2: Benannte Parameter (Best Practice, da unabhängig von Reihenfolge)
EXEC dbo.usp_GetMitarbeiterByGehalt @MinGehalt = 3000.00, @MaxGehalt = 6000.00;

-- Variante 3: Nutzung des Default-Wertes für MaxGehalt
EXEC dbo.usp_GetMitarbeiterByGehalt @MinGehalt = 5000.00;
```

#### c) Ausgabeparameter (Output Parameter)
Um Werte an den Aufrufer zurückzuliefern, ohne eine Tabelle als Ergebnismenge auszugeben, wird das Schlüsselwort `OUTPUT` (oder kurz `OUT`) verwendet.

```sql
CREATE PROCEDURE dbo.usp_GetAbteilungStats
    @AbtID INT,
    @AvgGehalt DECIMAL(10,2) OUTPUT,         -- Ausgabeparameter 1
    @MitarbeiterCount INT OUTPUT             -- Ausgabeparameter 2
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        @AvgGehalt = AVG(Gehalt),
        @MitarbeiterCount = COUNT(*)
    FROM dbo.Mitarbeiter
    WHERE AbteilungID = @AbtID;
END;
GO
```

**Aufruf einer Prozedur mit OUTPUT-Parametern:**
Der Aufrufer muss zuvor Variablen deklarieren, diese beim EXEC-Aufruf mitgeben und das Schlüsselwort `OUTPUT` zwingend wiederholen!

```sql
-- 1. Variablen deklarieren
DECLARE @AusgabeAvg DECIMAL(10,2);
DECLARE @AusgabeCount INT;

-- 2. Prozedur ausführen
EXEC dbo.usp_GetAbteilungStats 
    @AbtID = 1, 
    @AvgGehalt = @AusgabeAvg OUTPUT, 
    @MitarbeiterCount = @AusgabeCount OUTPUT;

-- 3. Werte verwenden
SELECT @AusgabeAvg AS Durchschnittsgehalt, @AusgabeCount AS MitarbeiterAnzahl;
```

#### d) Der Rückgabewert (RETURN-Statement)
Der Befehl `RETURN` beendet die Ausführung der Prozedur sofort und gibt einen **einzelnen, ganzzahligen Integer-Wert** an das aufrufende Programm zurück.

> [!IMPORTANT]
> **IHK-Konzept-Tipp:** 
> Verwende `RETURN` ausschließlich zur Übermittlung von **Statuscodes** (z. B. `0` für Erfolg, `50001` für einen spezifischen Validierungsfehler). Verwende für fachliche Rückgabewerte (wie Gehälter, Namen etc.) immer `OUTPUT`-Parameter.

```sql
CREATE PROCEDURE dbo.usp_AddAbteilung
    @Name NVARCHAR(50),
    @Ort NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validierung
    IF EXISTS (SELECT 1 FROM dbo.Abteilung WHERE AbteilungsName = @Name)
    BEGIN
        RETURN -1; -- Fehlercode: Abteilung existiert bereits
    END

    INSERT INTO dbo.Abteilung (AbteilungsName, Standort)
    VALUES (@Name, @Ort);

    RETURN 0; -- Erfolgscode
END;
GO
```

**Abfragen des Statuscodes:**
```sql
DECLARE @Status INT;

EXEC @Status = dbo.usp_AddAbteilung @Name = 'IT-Entwicklung', @Ort = 'München';

IF @Status = 0
    PRINT 'Abteilung erfolgreich angelegt!';
ELSE IF @Status = -1
    PRINT 'Fehler: Abteilung existiert bereits!';
```

---

### 4. Transaktions- & Fehlerbehandlung in Prozeduren

In modernen Datenbanken müssen kritische Logiken (z. B. Datenkonsistenz über mehrere Tabellen hinweg) transaktionssicher gekapselt werden. Dies geschieht durch die Kombination aus `TRY...CATCH` und `TRANSACTION`.

```sql
CREATE PROCEDURE dbo.usp_TransferMitarbeiter
    @MitarbeiterID INT,
    @ZielAbteilungID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Prüfen, ob Mitarbeiter existiert
        IF NOT EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE MitarbeiterID = @MitarbeiterID)
        BEGIN
            -- Benutzerdefinierten Fehler auslösen
            THROW 50002, 'Mitarbeiter existiert nicht.', 1;
        END

        -- 2. Prüfen, ob Zielabteilung existiert
        IF NOT EXISTS (SELECT 1 FROM dbo.Abteilung WHERE AbteilungID = @ZielAbteilungID)
        BEGIN
            THROW 50003, 'Zielabteilung existiert nicht.', 1;
        END

        -- 3. Update durchführen
        UPDATE dbo.Mitarbeiter
        SET AbteilungID = @ZielAbteilungID
        WHERE MitarbeiterID = @MitarbeiterID;

        -- Wenn alles klappt, dauerhaft speichern
        COMMIT TRANSACTION;
        RETURN 0;
    END TRY
    BEGIN CATCH
        -- Bei Fehlern Rollback durchführen, falls Transaktion aktiv
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END

        -- Fehlerdetails abfragen & erneut werfen / protokollieren
        DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMsg, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH
END;
GO
```

---

### 5. Performance-Phänomen: Parameter Sniffing

**Parameter Sniffing** bezeichnet den Prozess, bei dem der SQL Server beim ersten Kompilieren einer Prozedur die übergebenen Parameterwerte analysiert ("erschnüffelt"), um den bestmöglichen Ausführungsplan für *genau diese* Werte zu erstellen.

#### Das Problem
Hat ein Parameterwert eine untypische Datenverteilung, wird ein Plan erzeugt, der für andere Werte extrem ineffizient sein kann.
*   **Beispiel:** Eine Suche nach `@Status = 'Inaktiv'` (betrifft 2 Zeilen) erzeugt einen Plan mit *Index Seek*. Wird die Prozedur danach mit `@Status = 'Aktiv'` (betrifft 10.000.000 Zeilen) aufgerufen, wird derselbe Plan verwendet, was zu massiven Performance-Problemen (unendliche Key Lookups) führt.

#### Die Lösungen
1.  **`WITH RECOMPILE` (Prozedurebene):**
    Erzwingt bei *jedem* Aufruf eine Neukompilierung. Nur sinnvoll für Prozeduren, die selten laufen, aber stark schwankende Parameter haben.
    ```sql
    CREATE PROCEDURE dbo.usp_Suche WITH RECOMPILE ...
    ```
2.  **`OPTIMIZE FOR` (Statementebene):**
    Weist den Query Optimizer an, einen Plan für einen typischen Durchschnittswert oder für einen unbekannten Wert (`OPTIMIZE FOR UNKNOWN`) zu erstellen.
    ```sql
    SELECT * FROM dbo.Mitarbeiter WHERE Nachname = @Nachname
    OPTION (OPTIMIZE FOR (@Nachname UNKNOWN));
    ```

---

## 🎓 IHK-Prüfungsrelevanz: Stored Procedures

In IHK-Prüfungen werden Stored Procedures im Bereich *Anwendungsentwicklung* und *Datenanalyse* regelmäßig abgefragt. Typisch sind theoretische Verständnisfragen oder das Formulieren von kleinen DDL-Blöcken.

### 📝 Typische Prüfungsfragen & Antworten

#### 1. Nennen Sie drei Vorteile, die der Einsatz von Stored Procedures im Vergleich zu direkt in der Programmiersprache formulierten SQL-Statements bietet. (6 Punkte)
> **IHK-Musterantwort:**
> 1. **Performance-Steigerung:** Da Stored Procedures vorkompiliert sind und ihr Ausführungsplan im Cache liegt, entfällt das wiederkehrende Parsing und Optimieren.
> 2. **Sicherheitsgewinn:** Benutzer benötigen keine direkten Rechte auf Tabellenebene, sondern können durch Ausführungsberechtigungen (`EXECUTE`) auf die Prozedur beschränkt werden. Parameterbindung verhindert zudem SQL-Injections.
> 3. **Geringere Netzwerklast:** Es wird nur der Aufrufname und die Parameterwerte übertragen, nicht das gesamte SQL-Kommando.

#### 2. Erklären Sie den Unterschied zwischen einem Eingabeparameter, einem Ausgabeparameter und dem RETURN-Wert einer Stored Procedure. (6 Punkte)
> **IHK-Musterantwort:**
> * **Eingabeparameter (INPUT):** Dienen der Übergabe von Werten *an* die Prozedur beim Start (z. B. Filterwerte).
> * **Ausgabeparameter (OUTPUT):** Dienen der Rückgabe von fachlichen Werten (Strings, Zahlen, Daten) *aus* der Prozedur an den Aufrufer. Es können mehrere Ausgabeparameter definiert werden.
> * **RETURN-Wert:** Gibt zwingend einen einzelnen ganzzahligen Wert (Integer) zurück, der standardmäßig zur Status- und Fehlerübermittlung (Erfolg = 0, Fehler != 0) verwendet wird.

---

## 💻 Praktische Übungen

Die Übungsaufgaben des heutigen Tages befinden sich im SQL-Skript:
👉 **[stored_procedures_exercises.sql](file:///c:/Users/Tobia/Desktop/cSharpRepo/SQL-Fundamentals/Day_12/src/stored_procedures_exercises.sql)**

Es enthält vier praxisnahe Aufgaben zur Kapselung von DQL- und DML-Logik auf der `ProjektDB` inklusive ausführbarer Kontrollabfragen zur Überprüfung.

---

## 💡 Wichtige Notizen

> [!NOTE]
> *   Verwende innerhalb von Stored Procedures stets **`SET NOCOUNT ON;`** direkt als erstes Statement nach dem `AS`. Das verbessert die Netzwerkeffizienz und verhindert Probleme in manchen Client-Frameworks (z. B. ADO.NET), die sonst fälschlicherweise die "Zeilen betroffen"-Rückmeldung als erstes ResultSet interpretieren.
> *   Fremdschlüsselverletzungen oder Primärschlüssel-Konflikte fängst du sauber mit **`BEGIN TRY...END TRY`** ab, um der Applikation sprechende Fehlercodes statt roher SQL-Fehlermeldungen zurückzugeben.