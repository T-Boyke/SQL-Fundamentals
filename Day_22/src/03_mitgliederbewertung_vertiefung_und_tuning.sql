-- ============================================================================
-- SQL-Fundamentals: Day 22 - IHK-Prüfungstraining
-- Datei: 03_mitgliederbewertung_vertiefung_und_tuning.sql
-- Dozent: Tom S. | Autor: Tobias Boyke | Datum: 01.09.2026
-- Fokus: Vertiefung, Transaktionssicherheit (TCL), Anti-Joins & Analytik
-- Datenbank: IHK_Mitgliederbewertung_2021S
-- ============================================================================

USE IHK_Mitgliederbewertung_2021S;
GO

-- ============================================================================
-- 1. Transaktionssichere Archivierungs-Pipeline (ACID & Error-Handling)
-- ============================================================================

PRINT '--- 1. Transaktionssichere Archivierung mit TRY...CATCH & TCL ---';

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1.1 Archivtabelle initialisieren, falls nicht vorhanden
    IF OBJECT_ID('MitgliedArchiv', 'U') IS NULL
    BEGIN
        CREATE TABLE MitgliedArchiv (
            idmitglied INT NOT NULL,
            mitgliedName VARCHAR(50) NOT NULL,
            gebDat DATE NOT NULL,
            fuehrungsZeugnis VARCHAR(50) NULL,
            archiviertAm DATETIME DEFAULT GETDATE(),
            CONSTRAINT pk_MitgliedArchiv PRIMARY KEY (idmitglied)
        );
    END;

    -- 1.2 Datentransfer
    INSERT INTO MitgliedArchiv (idmitglied, mitgliedName, gebDat, fuehrungsZeugnis)
    SELECT m.idmitglied,
           m.mitgliedName,
           m.gebDat,
           m.fuehrungsZeugnis
    FROM Mitglied AS m
    WHERE NOT EXISTS (
        SELECT 1 
        FROM Angebot AS a 
        WHERE a.mitgliedlid = m.idmitglied
    )
    AND NOT EXISTS (
        SELECT 1 
        FROM MitgliedArchiv AS ma 
        WHERE ma.idmitglied = m.idmitglied
    );

    -- 1.3 Löschen der archivierten Datensätze
    DELETE FROM Mitglied
    WHERE idmitglied IN (
        SELECT idmitglied 
        FROM MitgliedArchiv
    );

    COMMIT TRANSACTION;
    PRINT '>>> Archivierungstransaktion erfolgreich committet. <<<';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
    
    PRINT CONCAT('FEHLER in Archivierungs-Pipeline: ', ERROR_MESSAGE());
    THROW;
END CATCH;
GO


-- ============================================================================
-- 2. Anti-Join-Methodenvergleich für inaktive Mitglieder
-- ============================================================================

PRINT '--- 2.1 Anti-Join mit NOT EXISTS (Best Practice) ---';
SELECT m.idmitglied, m.mitgliedName
FROM Mitglied AS m
WHERE NOT EXISTS (
    SELECT 1 
    FROM Angebot AS a 
    WHERE a.mitgliedlid = m.idmitglied
);
GO

PRINT '--- 2.2 Anti-Join mit LEFT JOIN & IS NULL ---';
SELECT m.idmitglied, m.mitgliedName
FROM Mitglied AS m
LEFT JOIN Angebot AS a 
    ON m.idmitglied = a.mitgliedlid
WHERE a.idangebot IS NULL;
GO

PRINT '--- 2.3 Anti-Join mit NOT IN (Achtung bei NULL-Werten!) ---';
SELECT m.idmitglied, m.mitgliedName
FROM Mitglied AS m
WHERE m.idmitglied NOT IN (
    SELECT a.mitgliedlid 
    FROM Angebot AS a 
    WHERE a.mitgliedlid IS NOT NULL
);
GO


-- ============================================================================
-- 3. Erweiterte Analytik: Bewertungs-Rangliste mit Window Functions
-- ============================================================================

PRINT '--- 3. Dichte Rangfolge (DENSE_RANK) aller Mitglieder nach Notenschnitt ---';
SELECT m.idmitglied,
       m.mitgliedName,
       la.artBezeichnung AS leistungsart,
       CAST(AVG(b.bewertungZahl) AS DECIMAL(3, 1)) AS durchschnittsnote,
       COUNT(b.idbewertung) AS anzahl_bewertungen,
       DENSE_RANK() OVER(
           PARTITION BY la.idleistungArt 
           ORDER BY AVG(b.bewertungZahl) ASC
       ) AS rang_innerhalb_leistung
FROM Mitglied AS m
INNER JOIN Bewertung AS b 
    ON m.idmitglied = b.mitgliedlid
INNER JOIN LeistungArt AS la 
    ON b.leistungArtId = la.idleistungArt
GROUP BY m.idmitglied, m.mitgliedName, la.idleistungArt, la.artBezeichnung
ORDER BY la.artBezeichnung ASC, durchschnittsnote ASC;
GO
