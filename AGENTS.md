# 🤖 Workspace Guidelines: SQL-Fundamentals

## 🗄️ Single Source of Truth (SoT): `ProjektDB`

Für **alle** Module (`Day_01` bis `Day_27`) gilt die **`ProjektDB`** als verbindliche **Single Source of Truth (SoT)**.

### Kanonisches Schema & Entitäten

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

### Namenskonventionen & Feldzuordnungen
* **Mitarbeiter:** `id`, `vorname`, `nachname`, `abt_id`, `ort`, `chef_id`
* **Abteilung:** `id`, `kuerzel`, `bezeichnung`, `ort`
* **Gehalt:** `mit_id`, `gehalt`
* **Kunde:** `id`, `firma`, `ort`
* **Projekt:** `id`, `kuerzel`, `bezeichnung`, `mittel`, `kunde_id`
* **Arbeit:** `mit_id`, `pro_id`, `aufgabe`, `einst_dat` *(in Skripten/Aufgaben teils synonym als `beginn` deklariert)*
* **Umsatz:** `id`, `mit_id`, `datum`, `umsatz`

### Regeln für alle Day-Module
1. Alle SQL-Queries, Lösungsbeispiele, Joins, Subqueries, Stored Procedures und Trigger müssen sich auf die Tabellen und Spalten der `ProjektDB` stützen.
2. Abweichende Bezeichnungen (z. B. `gehalt.betrag` oder `mitarbeiter.name`) sind stets auf das kanonische SoT-Schema anzupassen.
