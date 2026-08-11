-- ============================================================================
-- Day_07: SQL Server Isolationsstufen Demo
-- Dozent: Tom S. | Autor: Tobias Boyke
-- ============================================================================

USE tempdb;
GO

-- 1. Dirty Read Simulation
-- Um dies zu testen, öffnet man typischerweise zwei Sessions (zwei Tabs in SSMS).

-- ==================== SESSION 1 (Schreiber) ====================
/*
BEGIN TRANSACTION;
UPDATE dbo.BankKonten
SET Saldo = 9999.00
WHERE KontoID = 1;

-- Noch KEIN COMMIT oder ROLLBACK!
*/

-- ==================== SESSION 2 (Leser) ====================
-- Wenn Session 2 den Standard-Isolationslevel READ COMMITTED verwendet,
-- blockiert diese SELECT-Abfrage und wartet, bis Session 1 committet oder rollt.
SELECT * FROM dbo.BankKonten WHERE KontoID = 1;

-- Setzt man in Session 2 jedoch READ UNCOMMITTED (oder NOLOCK Hint),
-- kann man den ungeänderten/unbestätigten Wert lesen (Dirty Read!):
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
GO

SELECT * FROM dbo.BankKonten WHERE KontoID = 1; -- Zeigt 9999.00 € an!

-- Wenn Session 1 nun ROLLBACK ausführt, war dieser Wert ein Phantom und hat nie existiert.
-- ROLLBACK TRANSACTION in Session 1.
GO


-- 2. Zurücksetzen auf Standard-Level
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO


-- 3. Non-Repeatable Read Simulation

-- ==================== SESSION 1 (Leser) ====================
/*
BEGIN TRANSACTION;
SELECT Saldo FROM dbo.BankKonten WHERE KontoID = 1; -- Tobias hat z. B. 800.00 €

-- Während die Transaktion läuft, ändert Session 2 den Wert:
-- ==================== SESSION 2 ====================
-- UPDATE dbo.BankKonten SET Saldo = 50.00 WHERE KontoID = 1; COMMIT;

-- Session 1 fragt erneut ab:
SELECT Saldo FROM dbo.BankKonten WHERE KontoID = 1; -- Wert hat sich mitten in der Transaktion geändert! (50.00 €)
COMMIT;
*/

-- Verhinderung durch REPEATABLE READ:
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO

/*
BEGIN TRANSACTION;
SELECT Saldo FROM dbo.BankKonten WHERE KontoID = 1; -- Sperrt diese Zeile für Updates!

-- Wenn Session 2 nun versucht, die Zeile zu ändern:
-- UPDATE dbo.BankKonten SET Saldo = 0.00 WHERE KontoID = 1;
-- -> Session 2 blockiert und wartet, bis Session 1 fertig ist.

COMMIT; -- Gibt die Sperre frei.
*/
GO

-- Standard wiederherstellen
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
GO
