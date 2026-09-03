# 📅 Day_24: T-SQL Prozedurale Programmierung – Variablen, Kontrollstrukturen, WHILE-Schleifen, Stored Procedures & Functions

## ℹ️ Kurs-Informationen

* **Datum:** Donnerstag, 03.09.2026
* **Arbeitszeit:** 08:15 - 16:00 Uhr
* **Dozent:** Tom S. (BITLC)
* **Autor:** Tobias Boyke
* **Kursunterlagen:** [`20260903-1.sql`](./assets/20260903-1.sql) & [`ProjektDB P1 - Programmierung 1 - Aufgaben.sql`](./assets/ProjektDB%20P1%20-%20Programmierung%201%20-%20Aufgaben.sql)
* **Themenschwerpunkt:** `DECLARE`, `SET`, `PRINT`, `[test declare von select]`, `IF...ELSE`, `BEGIN...END`, `WHILE` (`BREAK`, `CONTINUE`), `CREATE PROCEDURE` (Input, `OUTPUT`, `RETURN`), `CREATE FUNCTION` (Skalar, iTVF, MSTVF) & Gegenüberstellung SP vs. UDF

---

## 🎯 Lernziele des Tages

- [x] **Deklaration & Initialisierung lokaler Variablen mit `DECLARE`:**
  - Lokale Variablen mit Präfix `@` deklarieren (`DECLARE @name Datentyp`).
  - Direkte Wertzuweisung bei der Deklaration (`DECLARE @test INT = 100`).
  - Mehrfach-Deklarationen in einer kompakten Anweisung.
  - Standardwert uninitialisierter Variablen (`NULL`).
- [x] **Gültigkeitsbereich (Batch-Scope) & Lebenszyklus:**
  - Variablen existieren ausschließlich innerhalb des ausführenden Batches.
  - Das Schlüsselwort `GO` als Trenner von Batches und das Ende des Variablen-Lebenszyklus.
- [x] **Skalare Zuweisung mit `SET` & Arithmetik:**
  - Standardkonforme Wertzuweisung mit `SET @var = ausdruck`.
  - Arithmetische Berechnungen und Einbindung von Systemfunktionen (`GETDATE()`, `SUSER_NAME()`, `DB_NAME()`).
- [x] **Meldungsausgabe mit `PRINT` vs. Tabellarisches Resultset (`SELECT`):**
  - Textausgabe in den Reiter *Meldungen* (*Messages Tab*) für Logging und Debugging.
  - Typkonvertierung nicht-textueller Datentypen (`CAST`, `CONVERT`, `FORMAT`).
  - Vermeidung von `NULL`-Fallen bei String-Verkettungen (`CONCAT()` vs. `+`).
- [x] **Dynamische Variablenzuweisung aus Tabellenabfragen (`[test declare von select]`):**
  - Zuweisung via `SELECT @var = spalte FROM tabelle WHERE ...`.
  - Parallele Zuweisung mehrerer Spalten in mehrere Variablen in einem einzigen Lesezugriff.
  - Gegenüberstellung `SELECT @var = col` vs. `SET @var = (SELECT col)`.
  - **Kritische Randfälle:**
    - Verhalten bei Mehrfachtreffern (> 1 Zeile): Stillschweigendes Überschreiben vs. Laufzeitfehler 512.
    - Verhalten bei 0 Treffern: Erhalt des alten Variablenwerts vs. explizites `NULL`.
    - Sichere Initialisierungsmuster zur Fehlervermeidung.
- [x] **Ablaufsteuerung & Kontrollstrukturen (`IF...ELSE`):**
  - Bedingte Anweisungsausführung mit `IF <Bedingung> ... ELSE ...`.
  - **Die zwingende Notwendigkeit von `BEGIN...END`:** Kapselung mehrzeiliger Anweisungsblöcke zur Vermeidung tückischer Einzeiler-Bugs.
  - Kaskadierte Mehrfachverzweigungen mittels `ELSE IF`.
  - Verschachtelte Bedingungen (*Nested IF*) und komplexe logische Ausdrücke (`AND`, `OR`, `NOT`).
  - Performante Existenzprüfungen mit `IF EXISTS (...)` und `IF NOT EXISTS (...)`.
- [x] **Iterative Programmierung mit WHILE-Schleifen:**
  - Kopfgesteuerte `WHILE`-Schleifen mit Bedingungsprüfung.
  - Schleifensteuerung: Vorzeitiger Gesamtabbruch mit `BREAK` und Iterationssprung mit `CONTINUE`.
  - RBAR (*Row-By-Agonizing-Row*) vs. mengenorientiertes SQL (*Set-Based*): Wann Schleifen nützen (Chunk-weises Batching großer Datenmengen zur Vermeidung von Lock Escalation) und wann sie schaden.
  - Iteratives Durchlaufen von Datensätzen via temporärer Tabelle mit `IDENTITY`-Schlüssel (Cursor-Alternative).
- [x] **Gespeicherte Prozeduren (Stored Procedures):**
  - Definition mit `CREATE OR ALTER PROCEDURE dbo.usp_Name`.
  - **Die 4 Kernvorteile:** Plan-Caching & Performance, Sicherheit & Kapselung (Least Privilege / Ownership Chaining), SQL-Injection-Schutz und zentrale Wartbarkeit.
  - Parameter-Architektur: Eingabeparameter mit Standardwerten (Defaults), `OUTPUT`-Parameter für Ergebnisrückgaben an den Aufrufer, ganzzahlige Statuscodes mit `RETURN`.
  - Suchkaskaden mit optionalen Parametern (`@param = NULL`) zur Vermeidung von Parameter Sniffing.
  - Aufruf mit `EXECUTE` / `EXEC` und Übergabe von Rückgabevariablen.
- [x] **Benutzerdefinierte Funktionen (User-Defined Functions - UDF):**
  - **Skalare Funktionen:** Berechnung einzelner Werte (`RETURNS Datentyp`), zwingendes `dbo.`-Präfix beim Aufruf, Einbettung direkt in `SELECT`, `WHERE`, `ORDER BY`.
  - **Inline Table-Valued Functions (iTVF):** Parametrisierte Sichten (`RETURNS TABLE` ohne `BEGIN...END`), hohe Performance durch Query Inlining, Einsatz mit `CROSS APPLY`.
  - **Multi-Statement Table-Valued Functions (MSTVF):** Tabellenwertfunktionen mit `BEGIN...END` und expliziter Tabellenvariable.
- [x] **Der fundamentale IHK-Vergleich: Stored Procedures vs. Functions:**
  - Zweck (Aktion/Workflow vs. Berechnung/Transformation).
  - DML- und Seiteneffekt-Verbot in Funktionen (Strikt Read-Only!).
  - Transaktionsverbot in Funktionen (`BEGIN TRAN` verboten).
  - Einbettbarkeit in Abfragen (Functions: JA | Procedures: NEIN).
- [x] **Praxis-Workshop auf der `ProjektDB` (Single Source of Truth):**
  - Implementierung realer Business-Logik: Budget-Ampelprüfung, HR-Gehaltsbenchmark, Mitarbeiter-Auslastungsmonitor, dynamische Provisionsberechnung, Nettogehaltsberechnung via UDF und geschäftslogische Prozeduren.

---

## 🗺️ Relationale Kompasse & Architektur-Diagramme

### 1. Single Source of Truth (`ProjektDB`)

Alle prozeduralen Skripte, Variablenzuweisungen, Schleifen und Stored Procedures basieren konsistent auf dem kanonischen Schema der **`ProjektDB`**:

```mermaid
erDiagram
    ABTEILUNG ||--o{ MITARBEITER : "beschaeftigt (abt_id)"
    MITARBEITER ||--o{ MITARBEITER : "leitet (chef_id)"
    MITARBEITER ||--|| GEHALT : "bezieht (mit_id)"
    MITARBEITER ||--o{ ARBEIT : "arbeitet_in (mit_id)"
    PROJEKT ||--o{ ARBEIT : "beschaeftigt (pro_id)"
    KUNDE ||--o{ PROJEKT : "beauftragt (kunde_id)"
    MITARBEITER ||--o{ UMSATZ : "erzielt (mit_id)"

    MITARBEITER {
        int id PK "Personalnummer"
        string vorname "Vorname"
        string nachname "Nachname"
        int abt_id FK "Abteilung -> Abteilung(id)"
        string ort "Wohnort"
        int chef_id FK "Vorgesetzter -> Mitarbeiter(id)"
    }

    GEHALT {
        int mit_id PK, FK "Mitarbeiter-ID -> Mitarbeiter(id)"
        decimal gehalt "Monatsgehalt in EUR"
    }

    ABTEILUNG {
        int id PK "Abteilungs-ID"
        string kuerzel "Kürzel (BE, DI, FR, EK, VK)"
        string bezeichnung "Abteilungsname"
        string ort "Standort"
    }

    KUNDE {
        int id PK "Kunden-ID"
        string firma "Firmenname"
        string ort "Firmensitz"
    }

    PROJEKT {
        int id PK "Projekt-ID"
        string kuerzel "Kürzel (AP, GM, MK, PL, AR)"
        string bezeichnung "Projektname"
        decimal mittel "Projektbudget in EUR"
        int kunde_id FK "Kunden-ID -> Kunde(id)"
    }

    ARBEIT {
        int mit_id PK, FK "Mitarbeiter-ID -> Mitarbeiter(id)"
        int pro_id PK, FK "Projekt-ID -> Projekt(id)"
        string aufgabe "Rolle / Aufgabe"
        date einst_dat "Eintrittsdatum / Beginn"
    }

    UMSATZ {
        int id PK "Umsatz-ID"
        int mit_id FK "Mitarbeiter-ID -> Mitarbeiter(id)"
        date datum "Umsatzdatum"
        decimal umsatz "Umsatzbetrag in EUR"
    }
```

---

### 2. Lebenszyklus & Scope einer T-SQL-Variablen

Lokale Variablen werden mit einem führenden `@` gekennzeichnet und besitzen eine strikt begrenzte Lebensdauer innerhalb des jeweiligen Batches:

```mermaid
flowchart TD
    StartBatch(["🎬 Start des SQL-Batches"]) --> DeclareNode["📦 <b>DECLARE @var Datentyp [= Wert]</b><br/><i>Speicher wird reserviert (Standard: NULL)</i>"]
    DeclareNode --> AssignChoice{"Wertzuweisung"}
    
    AssignChoice -- "Konstante / Skalar" --> SetNode["✏️ <b>SET @var = Ausdruck</b><br/><i>(Arithmetik, Funktionen)</i>"]
    AssignChoice -- "Aus Datenbanktabelle" --> SelectNode["🔍 <b>SELECT @var = Spalte FROM Tab</b><br/><i>(Kann mehrere Variablen füllen)</i>"]
    
    SetNode --> UsageNode["⚙️ <b>Verwendung in Logik</b><br/><i>• IF @var > Wert<br/>• PRINT @var<br/>• WHERE col = @var</i>"]
    SelectNode --> UsageNode
    
    UsageNode --> BatchEnd{"Trifft auf <code>GO</code>-Trenner?"}
    BatchEnd -- "Nein" --> MoreStatements["Fortlaufende Batch-Anweisungen"]
    MoreStatements --> UsageNode
    BatchEnd -- "Ja (GO)" --> ScopeDestroyed(["💥 <b>Ende des Scopes</b><br/><i>Variable wird aus dem RAM gelöscht.<br/>Im nächsten Batch unbekannt!</i>"])

    style DeclareNode fill:#1e293b,stroke:#3b82f6,stroke-width:2px,color:#ffffff
    style SetNode fill:#0f766e,stroke:#14b8a6,stroke-width:2px,color:#ffffff
    style SelectNode fill:#0369a1,stroke:#0ea5e9,stroke-width:2px,color:#ffffff
    style UsageNode fill:#4338ca,stroke:#6366f1,stroke-width:2px,color:#ffffff
    style ScopeDestroyed fill:#991b1b,stroke:#ef4444,stroke-width:2px,color:#ffffff
```

---

### 3. Zuweisungs-Entscheidungsbaum: `SELECT @var` vs. `SET @var = (SELECT ...)`

Das Verhalten bei der Variablenzuweisung aus Abfragen unterscheidet sich fundamental, sobald das Abfrageergebnis von genau einem Datensatz abweicht:

```mermaid
flowchart TD
    StartAssign(["🚀 Variablenzuweisung aus Abfrage"]) --> RowCountCheck{"Wie viele Zeilen liefert<br/>die Abfrage zurück?"}
    
    RowCountCheck -- "Genau 1 Zeile" --> ExactOne["✅ <b>Normalfall:</b><br/>Beide Methoden weisen den Wert korrekt zu."]
    ExactOne --> DoneOk(["Erfolg: @var enthält Wert"])
    
    RowCountCheck -- "0 Zeilen (Kein Treffer)" --> ZeroRows{"Welche Syntax wurde genutzt?"}
    ZeroRows -- "SELECT @var = col" --> ZeroSelect["⚠️ <b>Variable behält bisherigen Wert!</b><br/><i>Wird NICHT auf NULL gesetzt!</i>"]
    ZeroRows -- "SET @var = (SELECT col)" --> ZeroSet["ℹ️ <b>Variable wird explizit NULL!</b><br/><i>(ANSI-konformes Subquery-Verhalten)</i>"]
    
    RowCountCheck -- "> 1 Zeile (Mehrere Treffer)" --> MultiRows{"Welche Syntax wurde genutzt?"}
    MultiRows -- "SELECT @var = col" --> MultiSelect["⚠️ <b>KEIN FEHLER!</b><br/><i>Variable wird zeilenweise überschrieben.<br/>Letzte verarbeitete Zeile gewinnt (nicht-deterministisch)!</i>"]
    MultiRows -- "SET @var = (SELECT col)" --> MultiSet["❌ <b>LAUFZEITFEHLER 512!</b><br/><i>Unterabfrage lieferte mehrere Werte.<br/>Batch bricht ab!</i>"]

    style ExactOne fill:#15803d,stroke:#22c55e,color:#ffffff
    style ZeroSelect fill:#d97706,stroke:#f59e0b,color:#ffffff
    style ZeroSet fill:#0284c7,stroke:#38bdf8,color:#ffffff
    style MultiSelect fill:#c2410c,stroke:#f97316,color:#ffffff
    style MultiSet fill:#b91c1c,stroke:#ef4444,color:#ffffff
```

---

### 4. Kontrollfluss-Architektur: `IF ... BEGIN ... END ELSE`

Strukturierte Ablaufsteuerung mit Anweisungsblöcken:

```mermaid
flowchart TD
    ConditionCheck{"Bedingung wahr?<br/>(IF @test > Schwelle)"}
    
    ConditionCheck -- "TRUE" --> BlockIf["📦 <b>BEGIN (IF-Zweig)</b><br/>• Anweisung 1<br/>• Anweisung 2<br/>• PRINT 'Erfolg'<br/><b>END</b>"]
    ConditionCheck -- "FALSE oder UNKNOWN" --> HasElse{"Existiert ein ELSE-Zweig?"}
    
    HasElse -- "Ja (ELSE IF)" --> CheckElseIf{"Nächste Bedingung wahr?<br/>(ELSE IF @test > Schwelle2)"}
    CheckElseIf -- "TRUE" --> BlockElseIf["📦 <b>BEGIN (ELSE IF-Zweig)</b><br/>• Spezifische Behandlung<br/><b>END</b>"]
    CheckElseIf -- "FALSE" --> BlockDefaultElse["📦 <b>BEGIN (Standard ELSE)</b><br/>• Fallback-Aktionen<br/><b>END</b>"]
    
    HasElse -- "Ja (Standard ELSE)" --> BlockDefaultElse
    HasElse -- "Nein" --> SkipBlock["Überspringen"]
    
    BlockIf --> ContinueScript(["▶️ Fortfahren mit Folgecode"])
    BlockElseIf --> ContinueScript
    BlockDefaultElse --> ContinueScript
    SkipBlock --> ContinueScript

    style BlockIf fill:#15803d,stroke:#22c55e,color:#ffffff
    style BlockElseIf fill:#0369a1,stroke:#0ea5e9,color:#ffffff
    style BlockDefaultElse fill:#475569,stroke:#94a3b8,color:#ffffff
```

---

### 5. Ablaufsteuerung in WHILE-Schleifen (`BREAK` & `CONTINUE`)

Die Schleifensteuerung erlaubt vorzeitigen Abbruch oder das Überspringen einzelner Iterationen:

```mermaid
flowchart TD
    WhileHead{"Bedingung erfüllt?<br/>(WHILE @i <= @max)"}
    
    WhileHead -- "Nein" --> LoopExit(["🏁 <b>Schleifenende</b><br/><i>Ausführung nach END fortsetzen</i>"])
    WhileHead -- "Ja" --> StepA["Anweisung 1"]
    
    StepA --> CheckBreak{"Soll abgebrochen<br/>werden? (BREAK)"}
    CheckBreak -- "Ja" --> DoBreak["🛑 <b>BREAK</b><br/><i>Schleife sofort verlassen!</i>"]
    DoBreak --> LoopExit
    
    CheckBreak -- "Nein" --> CheckContinue{"Schritt überspringen?<br/>(CONTINUE)"}
    CheckContinue -- "Ja" --> DoContinue["⏭️ <b>CONTINUE</b><br/><i>Rest überspringen, zurück zum Kopf!</i>"]
    DoContinue --> WhileHead
    
    CheckContinue -- "Nein" --> StepB["Reguläre Verarbeitung"]
    StepB --> Increment["Zähler anpassen: <code>SET @i = @i + 1</code>"]
    Increment --> WhileHead

    style WhileHead fill:#1e293b,stroke:#3b82f6,stroke-width:2px,color:#ffffff
    style DoBreak fill:#b91c1c,stroke:#ef4444,stroke-width:2px,color:#ffffff
    style DoContinue fill:#d97706,stroke:#f59e0b,stroke-width:2px,color:#ffffff
    style LoopExit fill:#15803d,stroke:#22c55e,stroke-width:2px,color:#ffffff
```

---

### 6. Stored Procedure Architektur & Ausführungs-Pipeline

Gespeicherte Prozeduren bieten Performance- und Sicherheitsvorteile durch Vorkompilierung, Parameter-Bindung und Kapselung:

```mermaid
flowchart LR
    subgraph Client["💻 Client / Aufrufer"]
        ExecCall["<code>EXEC dbo.usp_Action<br/>  @in = 42,<br/>  @out = @res OUTPUT;</code>"]
    end

    subgraph SQLServer["⚙️ SQL Server Engine"]
        PlanCache{"Liegt Ausführungsplan<br/>im Plan Cache?"}
        Compile["🛠️ Einmalig:<br/>Parse & Compile Plan"]
        ExecPlan["⚡ Vorkompilierter<br/>Ausführungsplan"]
        
        ProcBody["📦 <b>Prozedurrumpf (usp_...)</b><br/>• Berechtigungsprüfung (Ownership Chaining)<br/>• Logik (IF, WHILE, DML)<br/>• Transaktionsschutz (TRY/CATCH)"]
        
        PlanCache -- "Nein (1. Aufruf)" --> Compile --> ExecPlan
        PlanCache -- "Ja (Cache-Hit)" --> ExecPlan
        ExecPlan --> ProcBody
    end

    subgraph DataLayer["🗄️ Datenbasis (ProjektDB)"]
        Tables["📊 Mitarbeiter<br/>📊 Projekt<br/>📊 Gehalt"]
    end

    ExecCall --> PlanCache
    ProcBody <--> Tables
    ProcBody -->|"OUTPUT-Parameter & RETURN Status"| ExecCall

    style PlanCache fill:#1e293b,stroke:#3b82f6,stroke-width:2px,color:#ffffff
    style ExecPlan fill:#15803d,stroke:#22c55e,stroke-width:2px,color:#ffffff
    style ProcBody fill:#4338ca,stroke:#6366f1,stroke-width:2px,color:#ffffff
```

---

### 7. Entscheidungs-Kompass: Wann Stored Procedure, wann Function?

Die Wahl zwischen Prozedur und Funktion richtet sich nach dem Einsatzzweck (Aktion/DML vs. Berechnung/Transformation):

```mermaid
flowchart TD
    StartDecision(["🎯 Welche Aufgabe soll gelöst werden?"]) --> ModifiesData{"Soll die Datenbank modifiziert<br/>werden (INSERT, UPDATE, DELETE)<br/>oder Transaktionen gesteuert werden?"}
    
    ModifiesData -- "Ja (Daten ändern / TCL)" --> UseSP["⚡ <b>STORED PROCEDURE</b><br/>• Darf Daten manipulieren (DML)<br/>• Unterstützt Transaktionen (BEGIN TRAN)<br/>• Gibt Statuscodes via RETURN zurück<br/>• Aufruf via <code>EXEC dbo.usp_Name</code>"]
    
    ModifiesData -- "Nein (Reine Berechnung)" --> WhereUsed{"Wo soll das Objekt<br/>aufgerufen werden?"}
    
    WhereUsed -- "Direkt in SELECT, WHERE,<br/>JOIN oder HAVING" --> WhichReturn{"Welcher Rückgabetyp<br/>wird benötigt?"}
    WhereUsed -- "Als eigenständiger Schritt /<br/>mit OUTPUT-Parametern" --> UseSP
    
    WhichReturn -- "Genau 1 Skalarwert<br/>(Zahl, Text, Datum)" --> UseScalar["🔢 <b>SKALARE FUNKTION (Scalar UDF)</b><br/>• <code>RETURNS DECIMAL / INT...</code><br/>• Zwingend <code>dbo.udf_Name()</code><br/>• Nutzt in SELECT / WHERE"]
    
    WhichReturn -- "Eine tabellarische<br/>Ergebnismenge" --> IsSimple{"Basiert die Tabelle auf<br/>einem einzelnen SELECT?"}
    
    IsSimple -- "Ja (Sehr schnell!)" --> UseITVF["📊 <b>INLINE TVF (iTVF)</b><br/>• <code>RETURNS TABLE</code> ohne BEGIN/END<br/>• Parametrisierte Sicht<br/>• Hervorragende Performance (Inlining)"]
    IsSimple -- "Nein (Komplexe Logik)" --> UseMSTVF["📋 <b>MULTI-STATEMENT TVF (MSTVF)</b><br/>• <code>RETURNS @Tab TABLE</code> mit BEGIN/END<br/>• Schrittweise Tabellenbefüllung"]

    style UseSP fill:#b91c1c,stroke:#ef4444,stroke-width:2px,color:#ffffff
    style UseScalar fill:#0284c7,stroke:#38bdf8,stroke-width:2px,color:#ffffff
    style UseITVF fill:#15803d,stroke:#22c55e,stroke-width:2px,color:#ffffff
    style UseMSTVF fill:#d97706,stroke:#f59e0b,stroke-width:2px,color:#ffffff
```

---

## 📖 Theorie & Kernkonzepte im Detail

---

### 1. Grundlagen von T-SQL-Variablen (`DECLARE`)

In Transact-SQL (T-SQL) dienen lokale Variablen zur temporären Speicherung von Skalarwerten (Zahlen, Texte, Datumsangaben, Booleans als `BIT`) während der Skriptausführung.

#### 1.1 Namenskonvention & Deklaration
* Lokale Variablennamen müssen zwingend mit einem führenden **`@`** beginnen (z. B. `@personalnummer`, `@gehalt`, `@status`).
* Globale Systemfunktionen (historisch teils fälschlich als Systemvariablen bezeichnet) beginnen mit zwei `@@` (z. B. `@@ROWCOUNT`, `@@ERROR`, `@@VERSION`).
* Werden Variablen ohne Initialwert deklariert, besitzen sie standardmäßig den Wert **`NULL`**.

```sql
-- Einzeldeklaration mit Initialwert (seit SQL Server 2008 möglich)
DECLARE @mit_id INT = 25348;
DECLARE @bonusSatz DECIMAL(4, 2) = 0.10;

-- Mehrfach-Deklaration in kompakter Form
DECLARE @vorname NVARCHAR(50) = 'Tobias',
        @nachname NVARCHAR(50) = 'Boyke',
        @istAktiv BIT = 1,
        @erfassungsDatum DATE = GETDATE();
```

#### 1.2 Der Batch-Scope: "Scope ist der Batch, nicht der Block!"
* **Kein Block-Scope:** Im Gegensatz zu Programmiersprachen wie C#, Java oder C++ besitzt T-SQL **keinen Block-Scope** innerhalb von Kontrollstrukturen (`BEGIN...END`). Wird eine Variable innerhalb eines `IF...BEGIN...END` deklariert, ist sie auch **nach dem `END` bis zum Ende des Batches** im gesamten Skript sichtbar und lesbar!
* **Batch-Grenze (`GO`):** Eine lokale Variable ist nur innerhalb des Batches sichtbar, in dem sie deklariert wurde.
* Das Schlüsselwort `GO` ist **kein T-SQL-Befehl**, sondern ein Batch-Trennzeichen für Client-Tools (SSMS, DataGrip, sqlcmd).
* Sobald ein `GO` erreicht wird, sendet das Client-Tool den vorangehenden Codeblock an den SQL Server. Danach wird der Batch beendet und der Arbeitsspeicher für alle darin deklarierten Variablen freigegeben.

```sql
-- Demonstration aus der Vorlesung (20260903-1.sql):
IF (SELECT COUNT(*) FROM dbo.Arbeit WHERE pro_id = 1) >= 3
BEGIN
    DECLARE @testScope INT = 42; -- Deklaration innerhalb des BEGIN...END Blocks
END;

-- In C# wäre @testScope hier außerhalb des Scopes -> In T-SQL funktioniert es einwandfrei!
PRINT @testScope; -- Gibt 42 aus!
GO
-- Erst HIER nach dem 'GO' ist @testScope aus dem Speicher gelöscht.
```

---

### 2. Wertzuweisung: `SET` vs. `SELECT`

Für die Wertzuweisung stehen zwei grundlegende Mechanismen zur Verfügung:

| Kriterium | `SET` (`SET @var = ...`) | `SELECT` (`SELECT @var = ...`) |
| :--- | :--- | :--- |
| **SQL-Standard** | Entspricht dem offiziellen ANSI-SQL Standard. | Proprietäre T-SQL Spracherweiterung von Microsoft. |
| **Anzahl Variablen** | Genau **eine** Variable pro `SET`-Anweisung. | **Mehrere** Variablen parallel in einer einzigen Abfrage. |
| **Tabellenzugriff** | Erfordert skalare Unterabfrage in Klammern. | Direkte Zuweisung über Spaltennamen mit `FROM` und `WHERE`. |
| **Performance bei Multi-Assignments** | Geringer: Mehrere Tabellenzugriffe bei mehreren Variablen. | Sehr hoch: Ein einziger Tabellenscan für $N$ Variablen. |
| **Verhalten bei > 1 Treffer** | Wirft **Laufzeitfehler 512** (Subquery returned > 1 value). | **Kein Fehler:** Überschreibt den Wert; letzte Zeile gewinnt! |
| **Verhalten bei 0 Treffern** | Setzt die Variable explizit auf **`NULL`**. | Variable **behält ihren bisherigen Wert** unverändert! |

---

### 3. Zuweisung aus Abfragen (`[test declare von select]`) & Die Randfall-Fallen

#### 3.1 Das Multi-Assignment-Paradigma
Sollen mehrere Attribute eines Datensatzes aus der `ProjektDB` in Variablen geladen werden, ist `SELECT` unschlagbar effizient:

```sql
USE ProjektDB;
GO

DECLARE @vname NVARCHAR(50),
        @nname NVARCHAR(50),
        @gehalt DECIMAL(10, 2),
        @abteilungsName NVARCHAR(50);

-- Ein einziger JOIN-Select befüllt alle 4 Variablen atomar:
SELECT @vname = m.vorname,
       @nname = m.nachname,
       @gehalt = g.gehalt,
       @abteilungsName = a.bezeichnung
FROM dbo.Mitarbeiter AS m
INNER JOIN dbo.Gehalt AS g ON m.id = g.mit_id
INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
WHERE m.id = 25348;

PRINT CONCAT(@vname, ' ', @nname, ' arbeitet in ', @abteilungsName, ' mit ', @gehalt, ' EUR Gehalt.');
```

#### 3.2 Die 0-Treffer-Falle (Silent No-Op)
Wenn ein `SELECT @var = col` ins Leere läuft (z. B. ID existiert nicht), wird die Zuweisung gar nicht erst ausgeführt. War die Variable vorher belegt, behält sie fälschlicherweise ihren Altwert:

```sql
DECLARE @gehalt DECIMAL(10, 2) = 5000.00; -- Vorheriger Wert

-- Mitarbeiter -99 existiert nicht:
SELECT @gehalt = gehalt FROM dbo.Gehalt WHERE mit_id = -99;

-- ACHTUNG: @gehalt ist weiterhin 5000.00 und NICHT NULL!
PRINT 'Gehalt: ' + CAST(@gehalt AS VARCHAR(20)); -- Gibt 5000.00 aus!
```

> [!CAUTION]
> **Best Practice gegen die 0-Treffer-Falle:**
> Vor einer Zuweisung über `SELECT` sollte die Variable **immer explizit auf `NULL` vorinitialisiert** werden (`DECLARE @var INT = NULL` oder `SET @var = NULL`), oder das Vorhandensein wird vorab via `IF EXISTS (...)` abgesichert!

---

### 4. Kontrollstrukturen & Verzweigungen (`IF...ELSE`)

#### 4.1 Warum `BEGIN...END` unverzichtbar ist
In T-SQL kapseln die Schlüsselwörter `BEGIN` und `END` einen Block aus mehreren Anweisungen (analog zu den geschweiften Klammern `{ ... }` in C# oder Java).

> [!WARNING]
> **Die fatale Einzeiler-Falle:**
> Ohne `BEGIN...END` gehört **ausschließlich die unmittelbar nächste Anweisung** zum bedingten Zweig. Jede weitere Zeile wird **immer** ausgeführt!

```sql
-- SAUBERER CODE MIT BEGIN...END (Best Practice):
DECLARE @isAdmin BIT = 0;

IF @isAdmin = 1
BEGIN
    PRINT 'Zugriff gewährt!';
    PRINT 'Sensible Finanzdaten werden exportiert...';
END
ELSE
BEGIN
    PRINT 'Zugriff verweigert: Administratorrechte erforderlich.';
END;
```

---

### 5. Iterative Kontrollstrukturen: Die WHILE-Schleife

T-SQL besitzt ausschließlich die kopfgesteuerte **`WHILE`**-Schleife (es gibt keine `FOR`- oder `DO...WHILE`-Schleifen).

#### 5.1 Syntax & Steuerung mit `BREAK` und `CONTINUE`
```sql
DECLARE @i INT = 1;

WHILE @i <= 10
BEGIN
    IF @i = 8
        BREAK;    -- Bricht die gesamte Schleife bei 8 sofort ab

    IF @i % 2 = 0
    BEGIN
        SET @i = @i + 1;
        CONTINUE; -- Überspringt gerade Zahlen und springt zum Kopf zurück
    END;

    PRINT CONCAT('Ungerade Zahl: ', @i);
    SET @i = @i + 1;
END;
```

#### 5.2 Mengenorientierung vs. RBAR (Row-By-Agonizing-Row)
In relationalen Datenbanken gilt: **Mengenbasierte SQL-Operationen (`UPDATE ... WHERE`, `INSERT ... SELECT`) sind iterativen Schleifen immer vorzuziehen!**  
Dennoch existieren zwei wichtige industrielle Anwendungsfälle für `WHILE`:
1. **Chunk-weises Batching (ETL / Archivierung):** Löschen von Millionen Datensätzen in 5.000er-Häppchen (`DELETE TOP (5000)`), um Lock Escalation und Transaktionsprotokoll-Überlauf zu vermeiden.
2. **Cursor-freies zeilenweises Abarbeiten:** Schrittweises Durchlaufen einer Hilfstabelle mit `IDENTITY`-Spalte, wenn Einzelschritte voneinander abhängen.

---

### 6. Gespeicherte Prozeduren (Stored Procedures)

Eine Stored Procedure ist ein benanntes, vorkompiliertes Programmmodul, das dauerhaft in der Datenbank gespeichert ist.

#### 6.1 Die 4 Kernvorteile
1. **Performance & Plan-Caching:** Beim ersten Aufruf erstellt die Engine einen optimierten Ausführungsplan und legt ihn im Cache ab. Nachfolgende Aufrufe sparen Compilation-Time.
2. **Sicherheit & Berechtigungskapselung (Least Privilege):** Anwender benötigen keine Tabellenrechte, sondern nur `GRANT EXECUTE ON dbo.usp_...`. Über das Prinzip der **Ownership Chaining** greift die Prozedur autorisiert auf Basistabellen zu.
3. **Schutz vor SQL Injection:** Parametrisierte Prozeduren trennen Code strikt von Nutzdaten.
4. **Zentralisierung:** Geschäftsregeln liegen zentral in der Datenbank und müssen bei Änderungen nicht in Client-Programmen nachgepflegt werden.

#### 6.2 Parameter-Typen & Syntax
```sql
CREATE OR ALTER PROCEDURE dbo.usp_GehaltsCheck
    @mit_id INT,                               -- Eingabeparameter (Input)
    @mindestGehalt DECIMAL(10, 2) = 2000.00,   -- Input mit Defaultwert
    @aktuellesGehalt DECIMAL(10, 2) OUTPUT     -- Ausgabeparameter (OUTPUT)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validierung
    IF NOT EXISTS (SELECT 1 FROM dbo.Mitarbeiter WHERE id = @mit_id)
        RETURN -1; -- Negativer Statuscode = Fehler

    SELECT @aktuellesGehalt = gehalt FROM dbo.Gehalt WHERE mit_id = @mit_id;

    IF @aktuellesGehalt >= @mindestGehalt
        RETURN 0;  -- 0 = Erfolg
    ELSE
        RETURN 1;  -- 1 = Gehalt unter Mindestgrenze
END;
GO
```

#### 6.3 Prozeduraufruf mit `EXECUTE`
```sql
DECLARE @gehalt DECIMAL(10, 2);
DECLARE @retCode INT;

EXEC @retCode = dbo.usp_GehaltsCheck
    @mit_id = 25348,
    @mindestGehalt = 3000.00,
    @aktuellesGehalt = @gehalt OUTPUT; -- Wichtig: OUTPUT beim Aufruf!

PRINT CONCAT('Returncode: ', @retCode, ' | Gehalt: ', @gehalt, ' EUR');
```

#### 6.4 Best Practice: Optionale Parameter mit Standardwerten & Such-Kaskade

Ein in der Praxis extrem häufiges und elegantes Entwurfsmuster ist die **Multi-Kriteriensuche mit optionalen Parametern**:

```sql
CREATE OR ALTER PROCEDURE dbo.usp_SucheKunden
    @kundenId INT = NULL,          -- Optionaler Parameter 1 (Default: NULL)
    @nachname NVARCHAR(100) = NULL -- Optionaler Parameter 2 (Default: NULL)
AS
BEGIN
    SET NOCOUNT ON;

    -- Variante A: Suche nach Primärschlüssel-ID, wenn übergeben (höchste Selektivität)
    IF @kundenId IS NOT NULL
    BEGIN
        SELECT * FROM dbo.Kunde WHERE id = @kundenId;
    END
    -- Variante B: Suche nach Name/Muster, wenn ID fehlt aber Name vorhanden ist
    ELSE IF @nachname IS NOT NULL
    BEGIN
        SELECT * FROM dbo.Kunde WHERE firma LIKE @nachname + '%';
    END
    -- Variante C: Keine Parameter übergeben -> Defensiver Fallback mit Schutzlimit
    ELSE
    BEGIN
        SELECT TOP (100) * FROM dbo.Kunde ORDER BY id;
    END;
END;
GO
```

> [!TIP]
> **Warum `IF...ELSE IF` statt Catch-All `WHERE (@id IS NULL OR id = @id)`?**  
> 1. **Index-Nutzung & Plan-Optimierung:** In einer monolithischen Catch-All-Abfrage muss der SQL Server Query Optimizer einen einzigen Ausführungsplan finden, der für alle Parameterkombinationen passt. Dies führt häufig zu ineffizienten *Table/Index Scans*. Bei der `IF...ELSE`-Verzweigung hingegen generiert die Engine für **jeden Zweig einen maßgeschneiderten Ausführungsplan** (z. B. blitzschneller *Clustered Index Seek* im ID-Zweig).  
> 2. **Schutz vor Denial-of-Service:** Das defensive `TOP (100)` im Fallback-Zweig verhindert, dass ein unbedachter Aufruf ohne Parameter Millionen Datensätze über das Netzwerk schaufelt.

---

### 7. T-SQL Funktionen (UDF) & Gegenüberstellung zu Stored Procedures

Benutzerdefinierte Funktionen (*User-Defined Functions* - UDF) dienen der **Berechnung und Transformation von Werten** und sind strikt nebenwirkungsfrei (*Side-Effect Free*).

#### 7.1 Die 3 Arten von Funktionen im Überblick

1. **Skalare Funktionen (Scalar UDF):**
   - Gibt genau **einen Skalarwert** zurück (`RETURNS INT`, `VARCHAR`, `DECIMAL`...).
   - **Besonderheit:** Muss beim Aufruf zwingend mit zweigliedrigem Namen aufgerufen werden: `dbo.udf_BerechneNettoGehalt(gehalt, 30.00)`.
   - Kann direkt in `SELECT`, `WHERE`, `ORDER BY` und `CHECK`-Constraints verwendet werden.
2. **Inline-Tabellenwertfunktionen (Inline TVF - iTVF):**
   - Gibt eine virtuelle Tabelle zurück (`RETURNS TABLE`).
   - Besitzt **kein** `BEGIN...END`, sondern besteht aus einem einzigen `RETURN (SELECT ...)`.
   - **Performance-König:** Der Optimizer bettet die Abfrage wie eine parametrisierte Sicht (*View*) direkt in den Abfrageplan ein (*Query Inlining*).
   - Hervorragend kombinierbar mit `CROSS APPLY`.
3. **Mehrfachanweisungs-Tabellenwertfunktionen (Multi-Statement TVF - MSTVF):**
   - Besitzt einen `BEGIN...END`-Rumpf und deklariert eine Tabellenvariable (`RETURNS @Tab TABLE (...)`).
   - Erlaubt prozedurale Befüllung, ist jedoch bei großen Datenmengen langsamer als eine iTVF.

#### 7.2 Große IHK-Vergleichstabelle: Stored Procedure vs. User-Defined Function

| Kriterium | Stored Procedure (SP) | User-Defined Function (UDF) |
| :--- | :--- | :--- |
| **Primäre Aufgabe** | **Aktionen ausführen & Workflows steuern** (DML, Datenpflege, ETL). | **Werte berechnen & transformieren** (Berechnungsformeln, Filter). |
| **Rückgabewerte** | Beliebig viele Resultsets, optionale `OUTPUT`-Parameter und ganzzahliger `RETURN`-Code. | **Zwingend genau ein Rückgabewert** (entweder ein Skalarwert oder eine `TABLE`). |
| **Aufrufbarkeit** | Nur als eigenständige Anweisung via **`EXECUTE / EXEC`**. | **Direkt eingebettet** in `SELECT`, `WHERE`, `HAVING`, `JOIN` oder `FROM`. |
| **DML-Erlaubnis (Seiteneffekte)** | **JA:** Darf Tabellen manipulieren (`INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`, TempTables). | ⛔ **NEIN (STRIKT READ-ONLY):** Darf den DB-Zustand nicht verändern! Keine DML auf Basistabellen. |
| **Transaktionen (TCL)** | **JA:** Darf Transaktionen steuern (`BEGIN TRAN`, `COMMIT`, `ROLLBACK`). | ⛔ **NEIN:** Transaktionsbefehle sind in Funktionen strengstens verboten. |
| **Parameter** | Unterstützt Eingabeparameter und **`OUTPUT`-Parameter**. | Unterstützt **nur Eingabeparameter** (keine `OUTPUT`-Parameter). |
| **Verschachtelung** | Darf andere Prozeduren und Funktionen aufrufen. | Darf andere Funktionen aufrufen, aber **keine Stored Procedures**! |
| **Client-Meldungen** | Darf `PRINT`-Meldungen ausgeben. | ⛔ **NEIN:** `PRINT` ist in Funktionen verboten. |

---

### 8. Praxis-Workshop: ProjektDB P1 – Programmierung 1 (Aufgaben P1.1 & P1.2)

In den offiziellen Kursübungen ([`assets/ProjektDB P1 - Programmierung 1 - Aufgaben.sql`](./assets/ProjektDB%20P1%20-%20Programmierung%201%20-%20Aufgaben.sql)) wurden die gelernten Konzepte direkt auf die `ProjektDB` angewendet:

#### Aufgabe P1.1: Gespeicherte Prozedur `sp_FilterMitarbeiter1`
Erstellung einer Prozedur, die alle Mitarbeiter einer Abteilung anhand der Abteilungsbezeichnung selektiert:
```sql
CREATE OR ALTER PROCEDURE dbo.sp_FilterMitarbeiter1
    @Abteilung NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT m.id,
           m.vorname,
           m.nachname,
           m.abt_id,
           a.bezeichnung
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    WHERE a.bezeichnung = @Abteilung
    ORDER BY m.id;
END;
GO
```

#### Aufgabe P1.2: Validierung & Fehlerbehandlung bei ungültiger Abteilung
Erweiterung der Prozedur: Wenn keine Mitarbeiter zur angegebenen Abteilung gefunden werden, soll die Fehlermeldung `'Abteilung ungültig: <Bezeichnung>'` ausgegeben werden:
```sql
CREATE OR ALTER PROCEDURE dbo.sp_FilterMitarbeiter1
    @Abteilung NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    -- Validierung mit IF NOT EXISTS
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Mitarbeiter AS m
        INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
        WHERE a.bezeichnung = @Abteilung
    )
    BEGIN
        -- Ausgabe als Resultset im Data Grid
        SELECT CONCAT('Abteilung ungültig: ', ISNULL(@Abteilung, '[NULL]')) AS Fehlermeldung;
        
        -- Zusätzliche Statusmeldung
        PRINT CONCAT('Abteilung ungültig: ', ISNULL(@Abteilung, '[NULL]'));
        RETURN;
    END;

    -- Reguläre Ausgabe
    SELECT m.id,
           m.vorname,
           m.nachname,
           m.abt_id,
           a.bezeichnung
    FROM dbo.Mitarbeiter AS m
    INNER JOIN dbo.Abteilung AS a ON m.abt_id = a.id
    WHERE a.bezeichnung = @Abteilung
    ORDER BY m.id;
END;
GO
```

#### 8.3 🎓 Schlaue Fragen an meinen Dozenten (Tom S.)

Diese Fragen vertiefen die Hintergründe der heutigen Lehrinhalte und eignen sich hervorragend für die Fachdiskussion im Unterricht:

1. **Namenskonvention & Performance-Falle bei `sp_`:**
   > *"In Aufgabe P1.1 lautet der vorgegebene Name `sp_FilterMitarbeiter1`. Laut Microsoft-Best-Practices sollte man eigene Prozeduren niemals mit `sp_` beginnen, weil der SQL Server sonst immer zuerst im `master` nachsieht und einen Cache-Miss riskiert. War das `sp_` in der Aufgabe historisch bedingt oder als gezielte Diskussionsgrundlage für Namenskonventionen gedacht?"*

2. **Fehlerbehandlung: Resultset vs. echte Exception (`THROW`):**
   > *"In Aufgabe P1.2 geben wir bei einer ungültigen Abteilung einen Datensatz mit der Spalte `Fehlermeldung` im Grid aus. In Enterprise-Backends (z. B. C# mit Entity Framework oder Dapper) erwartet die API bei einem Validierungsfehler typischerweise keinen regulären Data-Reader, sondern eine echte SqlException via `THROW 50001, 'Abteilung ungültig', 1;`. Wann empfiehlt Tom S. in der Praxis Resultset-Fehler und wann echte `THROW`-Exceptions?"*

3. **Query Optimization & Parameter Sniffing bei `IF...ELSE`-Zweigen:**
   > *"Wenn eine Stored Procedure mit `IF...ELSE IF` verzweigt: Erstellt der Query Optimizer beim Erstaufruf sofort Ausführungspläne für alle Zweige basierend auf den ersten Parametern (Parameter Sniffing), oder werden die Zweige erst zur Laufzeit kompiliert, wenn sie tatsächlich betreten werden (Deferred Compilation / Statement-Level Recompilation)?"*

4. **Batch-Scope vs. Block-Scope – Warum weicht T-SQL von ANSI/C# ab?**
   > *"Wir haben heute gelernt: 'Scope ist der Batch, nicht der Block' – Variablen in `BEGIN...END` überleben das Blockende bis zum nächsten `GO`. Warum hat Microsoft in T-SQL diesen Weg beibehalten, anstatt wie fast alle modernen Programmiersprachen (C#, Java, Python) einen echten Block-Scope einzuführen? Ist das reine Abwärtskompatibilität zur Sybase-Herkunft?"*

5. **Scalar UDF Inlining in modernen SQL Servern:**
   > *"Skalare UDFs galten historisch als Performance-Falle (RBAR / Kontextwechsel pro Zeile). Seit SQL Server 2019 gibt es das Feature `Scalar UDF Inlining`. Reicht das in modernen Produktionsumgebungen aus, oder gilt nach wie vor die Devise: 'Im Zweifel immer eine Inline-Tabellenwertfunktion (iTVF) mit `CROSS APPLY` bevorzugen'?"*

---

## 💻 Praktische Übungen im Verzeichnis `src/`

Alle praktischen Übungen sind als eigenständige, idempotent ausführbare T-SQL-Skripte im Ordner [`src/`](./src/) abgelegt:

| Datei | Themenschwerpunkt | Beschreibung & Kerninhalte |
| :--- | :--- | :--- |
| [📄 `01_variablen_declare_set_und_print.sql`](./src/01_variablen_declare_set_und_print.sql) | **Variablen-Grundlagen & PRINT** | Deklaration mit `DECLARE`, Mehrfach-Deklarationen, Gültigkeitsbereich (Batch-Scope mit `GO`), Zuweisung mit `SET`, Systemfunktionen, Typkonvertierungen (`CAST`, `CONVERT`, `FORMAT`), String-Handling mit `CONCAT()` und `NULL`-Vermeidung. |
| [📄 `02_variablenzuweisung_select_vs_set.sql`](./src/02_variablenzuweisung_select_vs_set.sql) | **Zuweisung aus Abfragen** | Dynamische Zuweisung über `SELECT @var = col`, parallele Multi-Variablen-Zuweisung, Aggregat-Zuweisung (`SUM`, `AVG`), Multi-Row-Phänomen (Fehler 512 vs. stilles Überschreiben), No-Row-Phänomen (Altwert vs. NULL) und sichere Abfragemuster. |
| [📄 `03_kontrollstrukturen_if_else_begin_end.sql`](./src/03_kontrollstrukturen_if_else_begin_end.sql) | **Kontrollstrukturen & Verzweigungen** | Ablaufsteuerung mit `IF...ELSE`, Demonstration der Gefahrenzone ohne `BEGIN...END`, mehrstufige Einstufungen via `ELSE IF`, verschachtelte Bedingungen (*Nested IF*), komplexe Boolesche Logik und Existenzprüfungen mit `IF EXISTS`. |
| [📄 `04_praxis_business_logik_projektdb.sql`](./src/04_praxis_business_logik_projektdb.sql) | **Praxis-Workshop ProjektDB** | 5 reale Unternehmensszenarien auf der `ProjektDB`: Projekt-Budget-Auditor mit Ampelbewertung, HR-Gehaltsbenchmark mit Abweichungsanalyse, Mitarbeiter-Auslastungsmonitor (`Arbeit`), dynamische Provisionsberechnung (`Umsatz`) und idempotente DML-Guards. |
| [📄 `05_schleifen_while_break_continue.sql`](./src/05_schleifen_while_break_continue.sql) | **Iterative Schleifen (WHILE)** | Zählergesteuerte `WHILE`-Schleifen, Notbremse mit `BREAK`, Iterationsübersprung mit `CONTINUE`, zeilenweises Abarbeiten via temporärer Tabelle (Cursor-Alternative) und Best-Practice-Muster für industrielles Batching (Chunk-Deletes). |
| [📄 `06_stored_procedures_grundlagen_und_parameter.sql`](./src/06_stored_procedures_grundlagen_und_parameter.sql) | **Stored Procedures Grundlagen** | `CREATE OR ALTER PROCEDURE`, Prozeduren ohne Parameter, optionale Parameter mit Defaultwerten (`= NULL`) & Such-Kaskade, `OUTPUT`-Parameter zur Werterückgabe, `RETURN`-Statuscodes, Aufruf via `EXEC` und Metadaten in `sys.procedures`. |
| [📄 `07_stored_procedures_business_logik_projektdb.sql`](./src/07_stored_procedures_business_logik_projektdb.sql) | **Enterprise Stored Procedures** | 3 komplexe Prozeduren auf der `ProjektDB`: `usp_MitarbeiterProjektZuweisen` (validierte DML), `usp_GehaltsanpassungAbteilung` (transaktionsgesichert mit Grenzen) und `usp_IterativerProjektStatusAudit` (integrierte `WHILE`-Schleife). |
| [📄 `08_tsql_functions_vs_stored_procedures.sql`](./src/08_tsql_functions_vs_stored_procedures.sql) | **UDFs vs. Stored Procedures** | Skalare Funktionen (`dbo.udf_BerechneNettoGehalt`), Inline-Tabellenwertfunktionen (`dbo.itvf_ProjektMitarbeiterListe` mit `CROSS APPLY`), Multi-Statement TVF und praktische Demonstration aller Restriktionen (DML- & Transaktionsverbot in UDFs). |
| [📄 `09_projektdb_p1_programmierung_loesungen.sql`](./src/09_projektdb_p1_programmierung_loesungen.sql) | **Musterlösung Aufgaben P1** | Vollständige Ausarbeitung der Vorlesungsaufgaben P1.1 und P1.2 (`sp_FilterMitarbeiter1` mit Fehlerbehandlung) sowie Dokumentation der Vorlesungsexperimente aus `20260903-1.sql` (Scope-Beweis & WHILE-Budgeterhöhung). |

---

## 💡 Wichtige Notizen & Best Practices

> [!IMPORTANT]
> **Die 7 goldenen Regeln für prozedurales T-SQL:**
> 1. **IMMER `BEGIN...END` verwenden:** Auch wenn ein `IF`-, `ELSE`- oder `WHILE`-Zweig zunächst nur aus einer einzigen Zeile besteht. Das verhindert gefährliche Logikfehler bei späteren Code-Erweiterungen.
> 2. **Variablen vor `SELECT`-Zuweisungen initialisieren:** Vor einer Wertzuweisung mit `SELECT @var = col` die Variable immer explizit auf `NULL` setzen, um Phantom-Altwerte bei 0 Treffern auszuschließen.
> 3. **Set-Based vor Iteration (RBAR vermeiden):** Schleifen nur für administrative Aufgaben, Simulationen oder Batching von Großlöschungen verwenden. Abfragen und Datenmanipulationen immer mengenbasiert formulieren.
> 4. **Stored Procedures mit `usp_`, Funktionen mit `udf_` / `itvf_` benennen:** Niemals das Präfix `sp_` verwenden, da der SQL Server sonst immer zuerst in der Systemdatenbank `master` sucht.
> 5. **`SET NOCOUNT ON` am Anfang jeder Prozedur:** Unterdrückt die Übertragung von "X Zeilen betroffen"-Meldungen an den Client und verbessert Netzwerk-Performance sowie Latenz.
> 6. **`OUTPUT` muss beim Aufruf wiederholt werden:** Wenn eine Prozedur einen Parameter als `OUTPUT` definiert, muss beim Aufruf via `EXEC` ebenfalls zwingend das Schlüsselwort `OUTPUT` angegeben werden, sonst wird der Wert nicht in die Aufruf-Variable geschrieben.
> 7. **Wann SP, wann UDF?** Sollen Daten modifiziert oder Transaktionen gesteuert werden ➔ **Stored Procedure**. Soll eine wiederverwendbare Berechnungs- oder Filterformel direkt in Abfragen (`SELECT`, `WHERE`, `JOIN`) eingebettet werden ➔ **User-Defined Function (bevorzugt Inline TVF)**.