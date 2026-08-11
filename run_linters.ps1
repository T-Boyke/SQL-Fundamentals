# ============================================================================
# SQL-Fundamentals: Lokaler Linter-Testlauf (Identisch zu GitHub Actions)
# Autor: Tobias Boyke | Dozent: Tom S.
# ============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Starte lokale Code-Pruefung (Linter-Testlauf)          " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$success = $true

# 1. Markdown Linting via npx (keine globale Installation noetig)
Write-Host "[1/2] Pruefe Markdown-Dateien..." -ForegroundColor Cyan
if (Get-Command "npx" -ErrorAction SilentlyContinue) {
    # Fuehrt markdownlint-cli2 mit denselben Regeln aus
    $mdResult = Start-Process -FilePath "npx.cmd" -ArgumentList "-y", "markdownlint-cli2", "**/*.md", "!node_modules/**" -Wait -PassThru -NoNewWindow
    if ($mdResult.ExitCode -eq 0) {
        Write-Host "[OK] Markdown-Formatierung ist korrekt." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Markdown-Formatierungsfehler gefunden. Bitte korrigieren." -ForegroundColor Red
        $success = $false
    }
} else {
    Write-Host "[!] Node.js/npx ist nicht installiert. Markdown-Lint übersprungen." -ForegroundColor Yellow
}

Write-Host "----------------------------------------------------------" -ForegroundColor Gray

# 2. SQL Linting via SQLFluff
Write-Host "[2/2] Pruefe SQL-Dateien..." -ForegroundColor Cyan
if (Get-Command "sqlfluff" -ErrorAction SilentlyContinue) {
    $sqlResult = Start-Process -FilePath "sqlfluff" -ArgumentList "lint", "--dialect", "tsql", "Day_*/src/*.sql" -Wait -PassThru -NoNewWindow
    if ($sqlResult.ExitCode -eq 0) {
        Write-Host "[OK] SQL-Dateien entsprechen den Standards." -ForegroundColor Green
    } else {
        Write-Host "[FAIL] SQL-Formatierungsfehler gefunden. Bitte korrigieren." -ForegroundColor Red
        $success = $false
    }
} else {
    Write-Host "[!] SQLFluff ist nicht installiert. Installiere es ueber: pip install sqlfluff" -ForegroundColor Yellow
    Write-Host "    Pruefe auf Python/pip..." -ForegroundColor Gray
    if (Get-Command "pip" -ErrorAction SilentlyContinue) {
        Write-Host "    Fuehre automatische Installation von sqlfluff aus..." -ForegroundColor Gray
        pip install sqlfluff | Out-Null
        $sqlResult = Start-Process -FilePath "sqlfluff" -ArgumentList "lint", "--dialect", "tsql", "Day_*/src/*.sql" -Wait -PassThru -NoNewWindow
        if ($sqlResult.ExitCode -eq 0) {
            Write-Host "[OK] SQL-Dateien entsprechen den Standards." -ForegroundColor Green
        } else {
            Write-Host "[FAIL] SQL-Formatierungsfehler gefunden." -ForegroundColor Red
            $success = $false
        }
    } else {
        Write-Host "[!] pip ist nicht verfuegbar. SQL-Lint uebersprungen." -ForegroundColor Yellow
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
if ($success) {
    Write-Host "SUCCESS: Alle lokalen Pruefungen erfolgreich abgeschlossen!" -ForegroundColor Green
} else {
    Write-Host "ERROR: Es wurden Fehler gefunden. Bitte vor dem Push beheben." -ForegroundColor Red
}
