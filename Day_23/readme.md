# 📅 Day_23: DCL & SQL Server Sicherheit – Logins, Users, Rollen & Berechtigungshierarchien

## ℹ️ Kurs-Informationen

* **Datum:** Mittwoch, 02.09.2026
* **Arbeitszeit:** 08:15 - 16:00 Uhr
* **Dozent:** Tom S. (BITLC)
* **Autor:** Tobias Boyke
* **Kursunterlagen:** [`SQL 07 - DCL Teil 1.pdf`](./assets/SQL%2007%20-%20DCL%20Teil%201.pdf) & [`ProjektDB 12 - Rollen und Rechte - Aufgaben.sql`](./assets/ProjektDB%2012%20-%20Rollen%20und%20Rechte%20-%20Aufgaben.sql)

---

## 🎯 Lernziele des Tages

- [x] **Aufgaben & Einordnung der DCL (Data Control Language):**
  - DCL als eine der fünf Hauptsäulen von SQL (neben DQL, DML, DDL und TCL).
  - Verwaltung von Server-Logins, Datenbank-Benutzern, Rollen und granularen Berechtigungen.
  - Das fundamentale Sicherheitsprinzip: **Least Privilege** (*"Jeder Benutzer darf nur das können, was er auch wirklich braucht"*).
- [x] **Das 2-stufige Sicherheitsmodell von Microsoft SQL Server:**
  - **Stufe 1 (Server-Ebene / Authentifizierung):** Server-Logins (`CREATE LOGIN`), Authentifizierungsmodi (*Windows Authentication*, *SQL Server Authentication*, Active Directory Groups, Microsoft Entra ID Cloud-Provider via `EXTERNAL PROVIDER` sowie Zertifikate).
  - **Stufe 2 (Datenbank-Ebene / Autorisierung):** Datenbank-Benutzer (`CREATE USER ... FOR LOGIN ...` bzw. `WITHOUT LOGIN`), Standard-Schemas (`dbo`), Datenbank-Rollen und Zuweisung von Rechten.
  - **Grundregel:** *Jedes Login kann nur einen User in derselben Datenbank besitzen.*
- [x] **DCL-Kernbefehle & Konfliktauflösung:**
  - `GRANT`: Explizites Erteilen von Berechtigungen auf Schemas, Tabellen, Views und Prozeduren.
  - `REVOKE`: Zurücknehmen von Rechten in den neutralen Standardzustand (weder erlaubt noch verboten).
  - `DENY`: Explizites Verbieten von Rechten mit absoluter Priorität (*"DENY schlägt immer GRANT"*).
  - **Abhängigkeit:** *Für `UPDATE`- und `DELETE`-Rechte ist immer auch das `SELECT`-Recht erforderlich*, da Datensätze lesend selektiert werden.
- [x] **Die relationale Berechtigungshierarchie (Securables Hierarchy):**
  - Kaskadierende Berechtigungsvererbung: $\text{Server} \rightarrow \text{Datenbank} \rightarrow \text{Schema} \rightarrow \text{Objekt (Tabelle/View)} \rightarrow \text{Spalte}$.
  - Berechtigungskapselung auf Schema-Ebene (`GRANT SELECT ON SCHEMA::dbo`) und deren automatische Vererbung auf alle enthaltenen Tabellen.
  - Granulare Spaltenberechtigungen (*Column-Level Permissions*) und deren Vor- und Nachteile gegenüber sicherheitskapselnden Sichten.
- [x] **Role-Based Access Control (RBAC) & Rollenverwaltung:**
  - Das Best-Practice-Paradigma: Logins $\rightarrow$ Users $\rightarrow$ Rollen $\rightarrow$ Berechtigungen (Verbot direkter User-Berechtigungen).
  - Erstellung und Pflege benutzerdefinierter Rollen (`DataReader`, `DataEditor`, `MitarbeiterCRUD`, `ProjektRO`, `ProjektRW`, `ProjektHR`).
  - Rollenmitgliedschaften dynamisch verwalten mittels `ALTER ROLE ... ADD MEMBER` und `DROP MEMBER`.
- [x] **Praxis-Workshop: ProjektDB 12 – Rollen & Rechte (Aufgaben 12.1 – 12.4):**
  - Vollständige Modellierung von `Alice` (Leserin ohne Gehaltseinsicht via `DENY`), `Bob` (Sachbearbeiter/Editor) und `Charlie` (Doppelrollen-Inhaber).
- [x] **Schemakonzept, `dbo` (Database Owner) & Ownership Chaining:**
  - Trennung von Benutzer und Schema (seit SQL Server 2005).
  - Das Prinzip der Eigentümerketten (*Ownership Chaining*): Sichere Datenmaskierung sensibler Attribute (z. B. `Gehalt`) über Views, ohne direkte Tabellenberechtigung.
- [x] **Testen, Simulation & Sicherheitsaudit:**
  - Kontextwechsel zu Test- und Revisionszwecken (`EXECUTE AS USER = '...'` und `REVERT`).
  - Abfrage von Systemkatalogen (`sys.server_principals`, `sys.database_principals`, `sys.database_permissions`, `sys.database_role_members`).
  - Überprüfung effektiver Rechte mit `HAS_PERMS_BY_NAME()` und `sys.fn_my_permissions()`.
  - Identifikation und Reparatur verwaister Datenbankbenutzer (*Orphaned Users*) nach DB-Restores.

---

## 🗺️ Relationale Kompasse: Single Source of Truth & Sicherheitsarchitektur

### 1. Single Source of Truth (`ProjektDB`)

Alle praktischen Sicherheitskonzepte, Rollenmodelle und Berechtigungsprüfungen basieren verbindlich auf dem kanonischen Schema der **`ProjektDB`**:

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

### 2. Das 2-Stufige Sicherheitsmodell von Microsoft SQL Server

Die Architektur trennt strikt zwischen **Authentifizierung** (Instanz-Ebene) und **Autorisierung** (Datenbank-Ebene):

```mermaid
flowchart TD
    subgraph Stufe1["🔐 STUFE 1: SERVER-EBENE (Authentifizierung - Wer bist du?)"]
        Client["💻 Client / Anwendung"] --> AuthMethod{"Authentifizierungs-Quelle"}
        AuthMethod -- "SQL-Auth (Passwort)" --> SqlLogin["🔑 SQL Login<br/><code>[ProjektDBRW]</code>"]
        AuthMethod -- "Windows AD User" --> WinLogin["👤 Windows AD User<br/><code>[FIRMA\\TobiaBoyke]</code>"]
        AuthMethod -- "Windows AD Gruppe" --> WinGroup["👥 Windows AD Gruppe<br/><code>[FIRMA\\Finance-Dept]</code>"]
        AuthMethod -- "Microsoft Entra ID (Cloud)" --> CloudGroup["☁️ Entra ID Security Group<br/><code>[sg-cloudtec-finance]</code>"]
        AuthMethod -- "Zertifikat / Service" --> CertLogin["📜 Zertifikats-Login<br/><code>[CertServiceAccount]</code>"]

        SqlLogin --> ServerPrincipals["📋 sys.server_principals<br/>(Server-Rollen: sysadmin, dbcreator...)"]
        WinLogin --> ServerPrincipals
        WinGroup --> ServerPrincipals
        CloudGroup --> ServerPrincipals
        CertLogin --> ServerPrincipals
    end

    ServerPrincipals --> ConnectionCheck{"Darf sich verbinden?<br/>(CONNECT SQL)"}
    ConnectionCheck -- "Ja" --> Stufe2
    ConnectionCheck -- "Nein" --> DenyConn["🚫 Verbindung abgelehnt"]

    subgraph Stufe2["🛡️ STUFE 2: DATENBANK-EBENE (Autorisierung - Was darfst du?)"]
        DBUser["👤 DB-Benutzer (ProjektDBRW / Alice / Bob)<br/><code>CREATE USER ProDBRW FOR LOGIN ProjektDBRW</code>"]
        DBUser --> RoleMember{"Mitglied in Rollen?"}
        RoleMember -- "Read-Only Rolle" --> RoleRO["📖 DataReader / ProjektRO<br/>(GRANT SELECT dbo)"]
        RoleMember -- "Read-Write Rolle" --> RoleRW["✏️ DataEditor / ProjektRW<br/>(GRANT DML dbo)"]
        RoleMember -- "Fachrolle CRUD" --> RoleCRUD["🛠️ MitarbeiterCRUD<br/>(GRANT DML Mitarbeiter, DENY DELETE)"]

        RoleRO --> SchemaLevel["📂 SCHEMA::dbo"]
        RoleRW --> SchemaLevel
        RoleCRUD --> ObjectLevel["📄 Tabellen & Views"]

        SchemaLevel --> Tables["📊 dbo.Mitarbeiter<br/>📊 dbo.Abteilung<br/>📊 dbo.Projekt<br/>📊 dbo.Kunde"]
        ObjectLevel --> SecureTables["🔒 dbo.Gehalt<br/>🔒 dbo.Umsatz"]
    end
```

---

### 3. Der DCL-Entscheidungsbaum & Rechteauswertung

Bei jeder SQL-Abfrage durchläuft die SQL Server Security Engine folgenden hierarchischen Prüfpfad:

```mermaid
flowchart TD
    Start(["🚀 Benutzer führt Abfrage aus"]) --> IsAdmin{"Ist Benutzer Mitglied von<br/><code>sysadmin</code> oder <code>db_owner</code>?"}
    IsAdmin -- "Ja" --> Granted(["✅ ZUGRIFF ERLAUBT<br/>(Volle Administrator-Rechte)"])
    IsAdmin -- "Nein" --> CheckDeny{"Liegt ein explizites <code>DENY</code> vor?<br/>(Auf User, Rolle, Schema, Tabelle oder Spalte)"}

    CheckDeny -- "Ja" --> Denied(["⛔ ZUGRIFF VERWEIGERT<br/>(DENY schlägt immer GRANT!)"])
    CheckDeny -- "Nein" --> CheckGrant{"Liegt ein explizites <code>GRANT</code> vor?<br/>(Auf User, Rolle, Schema oder Objekt)"}

    CheckGrant -- "Ja" --> Granted
    CheckGrant -- "Nein" --> DefaultDeny(["🚫 ZUGRIFF VERWEIGERT<br/>(Standard: Kein Zugriff ohne Recht)"])

    style Granted fill:#15803d,stroke:#22c55e,color:#ffffff
    style Denied fill:#b91c1c,stroke:#ef4444,color:#ffffff
    style DefaultDeny fill:#991b1b,stroke:#f87171,color:#ffffff
```

---

## 📖 Theorie & Kernkonzepte im Detail

---

### 1. Aufgaben der DCL & Das 2-Stufen-Sicherheitsmodell

Die **DCL (Data Control Language)** ist neben DQL, DML, DDL und TCL eine der fünf Untergruppen von SQL. Ihre Kernaufgabe ist die Berechtigungs- und Identitätsverwaltung:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ 1. AUTHENTIFIZIERUNG (Server-Ebene): "Wer bist du?"                         │
│    - Prüfung der Identität anhand von Anmeldeinformationen (Login).        │
│    - Ein Login gilt serverweit und ermöglicht den Zugriff auf die Instanz.  │
│    - Im SSMS Objekt-Explorer unter: Sicherheit / Anmeldungen                │
└──────────────────────────────────────┬──────────────────────────────────────┘
                                       │ Mappt auf (1:1 pro DB)
┌──────────────────────────────────────▼──────────────────────────────────────┐
│ 2. AUTORISIERUNG (Datenbank-Ebene): "Was darfst du tun?"                    │
│    - Ein Login wird in jeder Datenbank einem spezifischen USER zugeordnet. │
│    - Der DB-User definiert über Rechte und Rollen den Zugriff auf Daten.   │
│    - Im SSMS Objekt-Explorer unter: <Datenbank> / Sicherheit / Benutzer     │
└─────────────────────────────────────────────────────────────────────────────┘
```

> [!IMPORTANT]
> **Die goldene Grundregel:**  
> Es wird **immer sowohl ein Login als auch ein DB-User** benötigt! Ein Login ohne zugeordneten Datenbank-Benutzer hat keinerlei Zugriff auf Tabellen oder Daten (Ausnahme: `sysadmin`).  
> Zudem gilt: **Jedes Login kann nur genau einen User in derselben Datenbank besitzen.**

#### 1.1 Moderne Login-Typen & Authentifizierungsquellen

In modernen Unternehmensarchitekturen (On-Premises, Hybrid und Cloud) unterstützt SQL Server vielfältige Authentifizierungs-Provider:

```mermaid
mindmap
  root((SQL Server Logins))
    SQL Server Auth
      Benutzername & Passwort
      Gekapselt in master
    Windows Auth
      Active Directory Domain User [DOMAIN\User]
      Active Directory Security Group [FIRMA\Finance-Dept]
    Cloud Identity (Azure / Hybrid)
      Microsoft Entra ID User [user@domain.com]
      Microsoft Entra ID Security Group [sg-cloudtec-finance]
    Service Principals
      Zertifikatsbasierte Logins (FROM CERTIFICATE)
      Asymmetrische Schlüssel (FROM ASYMMETRIC KEY)
    Contained Users
      DB-User WITHOUT LOGIN (Sandbox & Testing)
      Contained DB User mit Kennwort
```

| Login-Typ & Syntax | Identitäts-Quelle | Typischer Einsatzzweck & Best Practice |
| :--- | :--- | :--- |
| **SQL Server Login**<br/>`CREATE LOGIN [ProjektDBRW] WITH PASSWORD = 'PDBRW';` | SQL Server interner Hash-Katalog (`master`) | Legacy-Applikationen, externe Dienstleister ohne Active Directory |
| **Windows Domain User**<br/>`CREATE LOGIN [FIRMA\TobiaBoyke] FROM WINDOWS;` | On-Premises Active Directory (Kerberos/NTLM) | Personengebundene Administrations- und Entwicklerzugänge |
| **Windows Security Group**<br/>`CREATE LOGIN [FIRMA\Finance-Dept] FROM WINDOWS;` | Active Directory Abteilungs-Sicherheitsgruppe | **Best Practice für Großunternehmen:** Verwaltung der Zugänge im AD |
| **Microsoft Entra ID Security Group**<br/>`CREATE LOGIN [sg-cloudtec-finance] FROM EXTERNAL PROVIDER;` | Azure Active Directory / Microsoft Entra ID | **Cloud- & Hybrid-Standard (Azure SQL / Managed Instance):** Rollen-Mapping |
| **Microsoft Entra ID Cloud User**<br/>`CREATE LOGIN [tobia@cloudtec.com] FROM EXTERNAL PROVIDER;` | Azure AD Cloud-Benutzer | Cloud-Identitäten ohne On-Premises Domain Controller |
| **Zertifikats-Login**<br/>`CREATE LOGIN CertLogin FROM CERTIFICATE AppCert;` | X.509 Zertifikat | Automatisierte CI/CD-Pipelines & kryptografisch signierte Prozeduren |
| **User WITHOUT LOGIN**<br/>`CREATE USER Alice WITHOUT LOGIN;` | Reine Datenbank-Ebene (Kein Instanz-Login) | Sandboxing, isolierte Test-Suiten & Rechte-Simulation via `EXECUTE AS` |
| **Contained Database User**<br/>`CREATE USER AppUser WITH PASSWORD = '...';` | Eigenständige Datenbank (*Contained DB*) | Hochverfügbarkeit (Always On), einfache Datenbank-Migrationen |

#### 1.2 User anlegen: Gleicher Name vs. Abweichender Name (Alias)

Beim Anlegen eines Datenbank-Benutzers existieren in T-SQL zwei Syntax-Varianten:

```sql
USE ProjektDB;
GO

-- Variante A: Gleicher Name wie das Login (automatische Verknüpfung)
CREATE USER ProjektDBRW;

-- Variante B: Abweichender Name (Alias-Name für das Login)
CREATE USER ProDBRW FOR LOGIN ProjektDBRW;
```

---

### 2. Die DCL-Triade: `GRANT`, `REVOKE` und `DENY`

Die Data Control Language (DCL) steuert die Zugriffsberechtigungen auf allen Ebenen des SQL Servers:

```
                  ┌───────────────────────┐
                  │    GRANT (Erlauben)   │
                  └───────────┬───────────┘
                              │
               REVOKE         │         DENY
         (Neutralisieren)     │   (Explizit verbieten)
                              │
                  ┌───────────▼───────────┐
                  │    NEUTRALER STATUS   │
                  │ (Standard: Kein Recht)│
                  └───────────▲───────────┘
                              │
                  ┌───────────┴───────────┐
                  │    DENY (Verbieten)   │
                  │   *SCHLÄGT ALLES*     │
                  └───────────────────────┘
```

#### 2.1 Übersicht der DCL-Befehle

| Befehl | Bedeutung | Auswirkung auf Rechteprüfung |
| :--- | :--- | :--- |
| `GRANT` | **Erteilen:** Erlaubt die Ausführung der angegebenen Aktion. | Der Benutzer darf die Aktion ausführen, sofern kein `DENY` existiert. |
| `REVOKE` | **Entziehen / Neutralisieren:** Entfernt eine zuvor explizit vergebene Berechtigung (`GRANT` oder `DENY`). | Setzt die Berechtigung auf den neutralen Zustand zurück. Wenn der Benutzer über eine Rollenmitgliedschaft noch ein `GRANT` besitzt, darf er weiterhin zugreifen! |
| `DENY` | **Verweigern / Verbieten:** Verbietet die Aktion explizit. | **Absolute Priorität:** Verhindert den Zugriff garantiert, selbst wenn der Benutzer über Rollen, Gruppen oder Schema-Vererbung ein `GRANT` besitzt. |

#### 2.2 Die 4-Stufen-Matrix: Rechtevergabe im Konfliktfall (Slide 10)

Das folgende klassische Szenario aus den Vorlesungsunterlagen demonstriert die Priorisierung im Detail:

| Ebene / Prinzipal | `SELECT` | `INSERT` | `UPDATE` | `DELETE` |
| :--- | :---: | :---: | :---: | :---: |
| **Benutzer** | `GRANT` | `REVOKE` | `REVOKE` | `REVOKE` |
| **Rolle 1** | `REVOKE` | `REVOKE` | `GRANT` | `GRANT` |
| **Rolle 2** | `REVOKE` | `REVOKE` | `REVOKE` | `DENY` |
| **Endergebnis** | ✅ **Ja** | ❌ **Nein** | ✅ **Ja** | ❌ **Nein** |

**Begründung:**
1. **`SELECT` (Ja):** Der Benutzer besitzt ein direktes `GRANT`.
2. **`INSERT` (Nein):** Weder auf Benutzerebene noch in den Rollen existiert ein `GRANT` (Standard: kein Zugriff).
3. **`UPDATE` (Ja):** Über **Rolle 1** wird das `GRANT` vererbt; keine andere Regel widerspricht.
4. **`DELETE` (Nein):** Rolle 1 erteilt zwar `GRANT`, doch **Rolle 2 verfügt über ein explizites `DENY`**. Da `DENY` jedes `GRANT` bedingungslos überstimmt, ist das Löschen strikt blockiert!

#### 2.3 Lese-Abhängigkeit bei Schreiboperationen

> [!IMPORTANT]
> **Kritischer Dozenten-Hinweis (Slide 11):**  
> *"Für die `UPDATE`- und `DELETE`-Rechte ist immer auch das `SELECT`-Recht erforderlich, da die Datensätze lesend ausgewählt bzw. über `WHERE`-Klauseln identifiziert werden müssen."*

#### 2.4 DCL-Syntax mit mehreren Empfängern

```sql
-- DCL-Zuweisung an mehrere Benutzer/Rollen gleichzeitig:
DENY DELETE ON SCHEMA::dbo TO ProjektDBRW, AndererUser;
```

---

### 3. Berechtigungshierarchie & Vererbung (Securables Hierarchy)

Berechtigungen im SQL Server sind hierarchisch strukturiert. Ein Recht, das auf einer höheren Ebene vergeben wird, gilt automatisch für alle darunterliegenden Ebenen, sofern kein explizites `DENY` existiert.

```mermaid
flowchart TD
    Server["🖥️ 1. Server-Instanz (CONTROL SERVER, VIEW SERVER STATE)"]
    Database["🗄️ 2. Datenbank: ProjektDB (CONNECT, CREATE TABLE, BACKUP)"]
    Schema["📂 3. Schema: SCHEMA::dbo (SELECT, INSERT, UPDATE, DELETE, EXECUTE)"]
    Object["📄 4. Objekt: dbo.Mitarbeiter / dbo.Gehalt (SELECT, INSERT, UPDATE, DELETE)"]
    Column["🧱 5. Spalte: dbo.Mitarbeiter(nachname), dbo.Gehalt(gehalt)"]

    Server --> Database --> Schema --> Object --> Column

    style Server fill:#1e293b,stroke:#3b82f6,stroke-width:2px,color:#f8fafc
    style Database fill:#1e293b,stroke:#3b82f6,stroke-width:2px,color:#f8fafc
    style Schema fill:#1e293b,stroke:#22c55e,stroke-width:2px,color:#f8fafc
    style Object fill:#1e293b,stroke:#eab308,stroke-width:2px,color:#f8fafc
    style Column fill:#1e293b,stroke:#ef4444,stroke-width:2px,color:#f8fafc
```

#### 3.1 Vererbung auf Schema-Ebene (`SCHEMA::dbo`)

Anstatt für jede einzelne Tabelle separate `GRANT`-Befehle auszuführen, bietet das Schema-Level eine elegante Kapselung:

```sql
-- Erlaubt SELECT auf ALLE aktuellen und zukünftigen Tabellen im dbo-Schema:
GRANT SELECT ON SCHEMA::dbo TO ProjektRO;
```

#### 3.2 Spaltenberechtigungen vs. Maskierende Sichten (Views)

SQL Server erlaubt Berechtigungen bis auf Spaltenebene herunterzubrechen:
```sql
-- Spaltenweises DENY auf sensible Attribute:
DENY SELECT ON dbo.Mitarbeiter(nachname) TO UserA;
DENY SELECT ON dbo.Gehalt(gehalt) TO UserA;
```

> [!TIP]
> **Best Practice in der Datenbank-Architektur:**  
> Granulare Spaltenberechtigungen führen zu erheblichem Wartungsaufwand und können Abfragepläne verkomplizieren.  
> **Empfohlener Best-Practice-Weg:** Erstellung dedizierter Views (z. B. `v_MitarbeiterPublic`), die sensible Spalten gar nicht erst enthalten, kombiniert mit *Ownership Chaining*.

---

### 4. Role-Based Access Control (RBAC) – Das Profi-Sicherheitsmodell

In professionellen Unternehmensdatenbanken werden Berechtigungen **ausschließlich Rollen** zugewiesen, niemals einzelnen Benutzern.

```mermaid
flowchart LR
    subgraph Users["👤 Benutzer"]
        U1["Alice (DataReader)"]
        U2["Bob (DataEditor)"]
        U3["Charlie (Beide Rollen)"]
        U4["ProjektDBRW (MitarbeiterCRUD)"]
    end

    subgraph Roles["🛡️ Datenbankrollen"]
        R1["📖 DataReader"]
        R2["✏️ DataEditor"]
        R3["🛠️ MitarbeiterCRUD"]
    end

    subgraph Permissions["🔑 Berechtigungen"]
        P1["GRANT SELECT ON Mitarbeiter, Gehalt"]
        P2["GRANT SELECT, INSERT, UPDATE ON Mitarbeiter, Gehalt"]
        P3["GRANT SELECT, INSERT, UPDATE ON Mitarbeiter<br/>DENY DELETE ON Mitarbeiter"]
        P4["DENY ALL ON Gehalt (Spezifisch für Alice)"]
    end

    U1 -->|"Member of"| R1
    U2 -->|"Member of"| R2
    U3 -->|"Member of"| R1
    U3 -->|"Member of"| R2
    U4 -->|"Member of"| R3

    R1 --> P1
    R2 --> P2
    R3 --> P3
    U1 -.->|"Explizites Verbot"| P4
```

#### 4.1 Die Beispielsrolle `MitarbeiterCRUD` (Slide 12 & 13)

```sql
-- 1. Rolle anlegen
CREATE ROLE MitarbeiterCRUD;

-- 2. User zur Rolle hinzufügen
ALTER ROLE MitarbeiterCRUD ADD MEMBER ProjektDBRW;

-- 3. Rechte an die Rolle vergeben
GRANT SELECT, INSERT, UPDATE ON dbo.Mitarbeiter TO MitarbeiterCRUD;
DENY DELETE ON dbo.Mitarbeiter TO MitarbeiterCRUD;
```

---

### 5. Praxis-Workshop: ProjektDB 12 – Rollen & Rechte (Aufgaben 12.1 – 12.4)

Die folgende Aufgabenstellung stammt direkt aus dem Kurs-Übungssatz [`Day_23/assets/ProjektDB 12 - Rollen und Rechte - Aufgaben.sql`](./assets/ProjektDB%2012%20-%20Rollen%20und%20Rechte%20-%20Aufgaben.sql) und demonstriert die exakte praktische Umsetzung von RBAC und DCL-Konfliktauflösung:

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│ AUFGABENÜBERSICHT: PROJEKTDB 12                                                         │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│ Aufgabe 12.1: Drei neue User anlegen: Alice, Bob, Charlie.                              │
│ Aufgabe 12.2: Zwei neue Rollen anlegen: DataReader, DataEditor.                         │
│ Aufgabe 12.3: User den Rollen zuordnen:                                                 │
│               • Alice   -> DataReader                                                   │
│               • Bob     -> DataEditor                                                   │
│               • Charlie -> DataReader UND DataEditor                                    │
│ Aufgabe 12.4: Rechte vergeben:                                                          │
│               • DataReader darf Mitarbeiter und Gehalt LESEN.                           │
│               • DataEditor darf Mitarbeiter und Gehalt LESEN, EINFÜGEN und ÄNDERN.      │
│               • Niemand darf über diese Rollen Datensätze LÖSCHEN.                      │
│               • Alice soll AUSDRÜCKLICH keinen Zugriff auf Gehalt bekommen.             │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

#### 5.1 Schritt-für-Schritt Lösung in T-SQL

```sql
USE ProjektDB;
GO

-- Aufgabe 12.1: User anlegen (ohne Server-Login für Sandbox-Tests)
CREATE USER Alice WITHOUT LOGIN;
CREATE USER Bob WITHOUT LOGIN;
CREATE USER Charlie WITHOUT LOGIN;
GO

-- Aufgabe 12.2: Rollen anlegen
CREATE ROLE DataReader;
CREATE ROLE DataEditor;
GO

-- Aufgabe 12.3: User den Rollen zuordnen
ALTER ROLE DataReader ADD MEMBER Alice;
ALTER ROLE DataEditor ADD MEMBER Bob;
ALTER ROLE DataReader ADD MEMBER Charlie;
ALTER ROLE DataEditor ADD MEMBER Charlie;
GO

-- Aufgabe 12.4: Rechte vergeben
-- 1. DataReader darf lesen:
GRANT SELECT ON dbo.Mitarbeiter TO DataReader;
GRANT SELECT ON dbo.Gehalt TO DataReader;

-- 2. DataEditor darf lesen, einfügen und ändern:
GRANT SELECT, INSERT, UPDATE ON dbo.Mitarbeiter TO DataEditor;
GRANT SELECT, INSERT, UPDATE ON dbo.Gehalt TO DataEditor;

-- 3. Keine DELETE-Rechte für die Rollen (wird nicht gegranted).

-- 4. Alice soll AUSDRÜCKLICH keinen Zugriff auf Gehalt bekommen:
-- ZWINGEND DENY, um das von DataReader geerbte SELECT-Recht zu blockieren!
DENY SELECT, INSERT, UPDATE, DELETE ON dbo.Gehalt TO Alice;
GO
```

#### 5.2 Matrix der effektiven Benutzerrechte

| Benutzer | Rollen | `dbo.Mitarbeiter` | `dbo.Gehalt` |
| :--- | :--- | :--- | :--- |
| **Alice** | `DataReader` | ✅ `SELECT` | ⛔ **VERWEIGERT** (*DENY überschreibt Rollen-GRANT*) |
| **Bob** | `DataEditor` | ✅ `SELECT`, `INSERT`, `UPDATE` | ✅ `SELECT`, `INSERT`, `UPDATE` (❌ Kein `DELETE`) |
| **Charlie** | `DataReader` + `DataEditor` | ✅ `SELECT`, `INSERT`, `UPDATE` | ✅ `SELECT`, `INSERT`, `UPDATE` (❌ Kein `DELETE`) |

---

### 6. Schemakonzept, `dbo` & Ownership Chaining

#### 6.1 Was bedeutet `dbo`?
- **`dbo` als Schema:** Das Standardschema in SQL Server. Wenn bei einer Abfrage kein Schema angegeben wird (`SELECT * FROM Mitarbeiter`), sucht SQL Server standardmäßig nach `dbo.Mitarbeiter`.
- **`dbo` als Benutzer:** Der Datenbank-Eigentümer (*Database Owner*). Innerhalb der Datenbank besitzt der `dbo`-User uneingeschränkte Vollmachten (`CONTROL DATABASE`).

#### 6.2 Ownership Chaining (Eigentümerketten)

Wenn ein Benutzer auf ein Objekt (z. B. eine Sicht oder Stored Procedure) zugreift, das auf andere Objekte (z. B. Basistabellen) verweist, und **beide Objekte denselben Eigentümer** (z. B. `dbo`) haben, prüft SQL Server die Berechtigung **nur auf dem aufgerufenen Objekt**, nicht auf den darunterliegenden Basistabellen!

```mermaid
flowchart LR
    User["👤 UserA<br/>(Kein Recht auf dbo.Gehalt)"]
    View["👁️ View: dbo.v_AbteilungGehaltsstatistik<br/>Owner: dbo<br/><b>UserA hat GRANT SELECT</b>"]
    Table["🔒 Tabelle: dbo.Gehalt<br/>Owner: dbo<br/><b>UserA hat KEIN Recht</b>"]

    User -->|"1. SELECT auf View"| View
    View -->|"2. Interner Zugriff (Gleicher Owner dbo)"| Table
    Table -.->|"3. Aggregierte Daten zurück"| User

    style View fill:#15803d,stroke:#22c55e,color:#ffffff
    style Table fill:#b91c1c,stroke:#ef4444,color:#ffffff
```

```sql
-- Sichere Aggregat-Sicht zur Ermittlung von Abteilungsdurchschnitten
CREATE OR ALTER VIEW dbo.v_AbteilungGehaltsstatistik
AS
SELECT a.id AS AbteilungID,
       a.kuerzel,
       a.bezeichnung AS Abteilungsname,
       COUNT(m.id) AS AnzahlMitarbeiter,
       AVG(g.gehalt) AS Durchschnittsgehalt
FROM dbo.Abteilung AS a
LEFT JOIN dbo.Mitarbeiter AS m ON a.id = m.abt_id
LEFT JOIN dbo.Gehalt AS g ON m.id = g.mit_id
GROUP BY a.id, a.kuerzel, a.bezeichnung;
GO

-- UserA benötigt NUR Recht auf die Sicht, nicht auf dbo.Gehalt!
GRANT SELECT ON dbo.v_AbteilungGehaltsstatistik TO ProjektRO;
```

---

### 7. Testen, Simulieren & Sicherheitsaudit

#### 7.1 Kontextwechsel mit `EXECUTE AS` und `REVERT`

Um als Administrator zu überprüfen, ob die Berechtigungen für einen bestimmten Benutzer oder Login exakt wie gewünscht greifen, bietet T-SQL den temporären Kontextwechsel:

```sql
-- 1. Kontext als UserA einnehmen
EXECUTE AS USER = 'UserA';

-- 2. Aktiven Kontext überprüfen
SELECT SUSER_NAME() AS ServerLogin,
       USER_NAME() AS DBUser,
       ORIGINAL_LOGIN() AS UrspruenglicherAdmin;

-- 3. Testabfrage durchführen
SELECT TOP (5) * FROM dbo.Mitarbeiter;

-- 4. Zurück zum Administrator wechseln
REVERT;
```

#### 7.2 Effektive Rechte abfragen

```sql
-- Alle effektiven Rechte des aktuellen Kontexts auf ein Schema prüfen
SELECT entity_name, subentity_name, permission_name
FROM sys.fn_my_permissions('dbo', 'SCHEMA');

-- Einzelne Berechtigung deterministisch prüfen (1 = Ja, 0 = Nein)
SELECT HAS_PERMS_BY_NAME('dbo.Mitarbeiter', 'OBJECT', 'SELECT') AS KannMitarbeiterLesen,
       HAS_PERMS_BY_NAME('dbo.Gehalt', 'OBJECT', 'SELECT') AS KannGehaltLesen;
```

#### 7.3 Orphaned Users (Verwaiste Benutzer) aufspüren

Nach einer Datenbanksicherung und Wiederherstellung (*Backup/Restore*) auf einem anderen SQL Server stimmen die Sicherheits-IDs (SIDs) der Datenbank-Benutzer oft nicht mehr mit den Server-Logins überein. Der Benutzer wird zum „Orphaned User“.

```sql
-- Verwaiste Benutzer ermitteln
SELECT dp.name AS OrphanedUser, dp.sid
FROM sys.database_principals AS dp
LEFT JOIN sys.server_principals AS sp ON dp.sid = sp.sid
WHERE dp.type IN ('S', 'U')
  AND dp.name NOT IN ('dbo', 'guest', 'INFORMATION_SCHEMA', 'sys')
  AND sp.sid IS NULL;

-- Reparatur (Verknüpfung mit bestehendem Server-Login reparieren)
ALTER USER [UserA] WITH LOGIN = [LoginA];
```

---

## 💻 Praktische Übungen im Verzeichnis `src/`

Alle praktischen Übungen sind als eigenständige, idempotent ausführbare T-SQL-Skripte im Ordner [`src/`](./src/) abgelegt:

| Datei | Themenschwerpunkt | Beschreibung & Kerninhalte |
| :--- | :--- | :--- |
| [📄 `01_authentifizierung_logins_und_users.sql`](./src/01_authentifizierung_logins_und_users.sql) | **Authentifizierung & Prinzipale** | Schritt-für-Schritt-Erstellung von Server-Logins (`master`), Zuweisung von DB-Benutzern (`ProjektDB`), Katalogabfragen in `sys.server_principals` / `sys.database_principals` und erster Verbindungstest mit `EXECUTE AS`. |
| [📄 `02_dcl_grant_revoke_deny_und_vererbung.sql`](./src/02_dcl_grant_revoke_deny_und_vererbung.sql) | **DCL & Berechtigungshierarchien** | Praxisdemonstration von `GRANT SELECT ON SCHEMA::dbo`, Kaskadierung, gezieltes `DENY` auf sensible Tabellen (`dbo.Gehalt`), der Unterschied zwischen `REVOKE` und `DENY` sowie Column-Level Permissions. |
| [📄 `03_rollenbasierte_sicherheit_rbac_projektdb.sql`](./src/03_rollenbasierte_sicherheit_rbac_projektdb.sql) | **RBAC & Ownership Chaining** | Vollständige Implementierung von Unternehmensrollen (`ProjektRO`, `ProjektRW`, `ProjektHR`, `MitarbeiterCRUD`) für `ProjektDB`, sichere Aggregat-Sichten mit Ownership Chaining und strukturierte Testfälle. |
| [📄 `04_sicherheitsaudit_metadaten_und_troubleshooting.sql`](./src/04_sicherheitsaudit_metadaten_und_troubleshooting.sql) | **Security Audit & Troubleshooting** | Umfassende Audit-Queries über `sys.database_permissions`, Abfrage effektiver Berechtigungen (`sys.fn_my_permissions`, `HAS_PERMS_BY_NAME`), Erkennung verwaister Benutzer und automatisiertes Teardown-Skript. |
| [📄 `05_projektdb_12_rollen_und_rechte_loesungen.sql`](./src/05_projektdb_12_rollen_und_rechte_loesungen.sql) | **Musterlösung ProjektDB 12** | Vollständige Ausarbeitung der Aufgaben 12.1 – 12.4 (Alice, Bob, Charlie, `DataReader`, `DataEditor`, `DENY` auf `Gehalt`) inkl. automatisierter Testsuite via `EXECUTE AS`. |

---

## 💡 Wichtige Notizen & Best Practices

> [!IMPORTANT]
> **Die 5 goldenen Regeln der Datenbanksicherheit:**
> 1. **Principle of Least Privilege (PoLP):** *"So viele Rechte wie nötig, so wenig Rechte wie möglich."* Jeder Benutzer und jede Anwendung erhält exakt nur die minimal notwendigen Rechte.
> 2. **Keine Direktberechtigung von Benutzern (RBAC):** Berechtigungen werden ausnahmslos an **Rollen** vergeben, Benutzer werden Rollen als Mitglieder zugewiesen.
> 3. **`DENY` schlägt immer `GRANT`:** Ein Verbot hat absolute Priorität und überschreibt alle Rollen- und Gruppenberechtigungen.
> 4. **`SELECT`-Pflicht für Schreiboperationen:** Für `UPDATE` und `DELETE` ist immer auch das Leserecht (`SELECT`) zwingend erforderlich.
> 5. **Sicherheitskapselung über Views statt Spalten-Permissions:** Sensible Daten (wie Gehälter oder Umsätze) werden über Sichten gefiltert und per Ownership Chaining sicher bereitgestellt.