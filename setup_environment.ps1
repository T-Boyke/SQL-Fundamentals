# ============================================================================
# SQL-Fundamentals: Automatisches Setup-Skript für SQL Server & DataGrip
# Autor: Tobias Boyke | Dozent: Tom S.
# ============================================================================

$ErrorActionPreference = "Stop"

# 1. Administrator-Rechte prüfen
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Dieses Skript benötigt Administratorrechte, um SQL Server Express zu installieren."
    Write-Host "Bitte starte PowerShell als Administrator und führe das Skript erneut aus." -ForegroundColor Yellow
    Exit
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SQL-Fundamentals: System & DataGrip-Konfiguration   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 2. Prüfen, ob SQL Server SQLEXPRESS bereits läuft
$serviceName = "MSSQL`$SQLEXPRESS"
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service) {
    Write-Host "[✓] SQL Server ($serviceName) ist bereits installiert." -ForegroundColor Green
    if ($service.Status -ne "Running") {
        Write-Host "    Dienst startet..." -ForegroundColor Yellow
        Start-Service -Name $serviceName
    }
    Write-Host "[✓] SQL Server Dienst läuft." -ForegroundColor Green

    # Enable TCP/IP & Named Pipes
    $tcpPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp'
    if (Test-Path $tcpPath) { Set-ItemProperty -Path $tcpPath -Name 'Enabled' -Value 1 -ErrorAction SilentlyContinue }
    $npPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Np'
    if (Test-Path $npPath) { Set-ItemProperty -Path $npPath -Name 'Enabled' -Value 1 -ErrorAction SilentlyContinue }
    Set-Service -Name SQLBrowser -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name SQLBrowser -ErrorAction SilentlyContinue
    Restart-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
} else {
    # SQL Server Express herunterladen und installieren
    $downloadUrl = "https://go.microsoft.com/fwlink/p/?linkid=2216019&clcid=0x409&culture=en-us&country=us"
    $installerPath = Join-Path $env:TEMP "SQLServerExpress-Bootstrapper.exe"

    Write-Host "[1/3] Downloade SQL Server Express Bootstrapper..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

    Write-Host "[2/3] Installiere SQL Server Express (SQLEXPRESS) im Hintergrund..." -ForegroundColor Cyan
    Write-Host "      Dies kann einige Minuten dauern. Bitte warten..." -ForegroundColor Gray
    
    # Silent Installation über den Bootstrapper
    $arguments = @(
        "/ACTION=Install",
        "/FEATURES=SQL",
        "/INSTANCENAME=SQLEXPRESS",
        "/SQLSYSADMINACCOUNTS=`"BUILTIN\Administrators`"",
        "/IAcceptSQLServerLicenseTerms",
        "/QS",
        "/UpdateEnabled=True"
    )
    
    $process = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow
    
    if ($process.ExitCode -eq 0 -or $process.ExitCode -eq 3010) {
        Write-Host "[✓] SQL Server Express wurde erfolgreich installiert." -ForegroundColor Green
        if ($process.ExitCode -eq 3010) {
            Write-Host "    HINWEIS: Ein Systemneustart wird empfohlen." -ForegroundColor Yellow
        }
    } else {
        Write-Error "Fehler bei der Installation von SQL Server Express. Exit Code: $($process.ExitCode)"
        Exit
    }
}

# 3. DataGrip Konfiguration verifizieren
$ideaPath = Join-Path (Get-Location) ".idea"
$dataSourcesPath = Join-Path $ideaPath "dataSources.xml"

Write-Host "[3/3] Konfiguriere JetBrains DataGrip..." -ForegroundColor Cyan

if (-not (Test-Path $ideaPath)) {
    New-Item -ItemType Directory -Path $ideaPath -Force | Out-Null
}

$xmlContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="DataSourceManagerImpl" format="xml" multifile-model="true">
    <data-source source="LOCAL" name="SQL-Fundamentals (SQLBEISEELIG)" uuid="4c2ea557-7945-4277-bf31-15b5cd91ee4c">
      <driver-ref>sqlserver.ms</driver-ref>
      <synchronize>true</synchronize>
      <configured-by-url>true</configured-by-url>
      <jdbc-driver>com.microsoft.sqlserver.jdbc.SQLServerDriver</jdbc-driver>
      <jdbc-url>jdbc:sqlserver://localhost;instanceName=SQLBEISEELIG;encrypt=true;trustServerCertificate=true;integratedSecurity=true;</jdbc-url>
      <working-dir>`$ProjectFileDir$</working-dir>
    </data-source>
  </component>
</project>
"@

Set-Content -Path $dataSourcesPath -Value $xmlContent -Encoding Utf8

Write-Host "[✓] DataGrip-Verbindung wurde in .idea/dataSources.xml eingerichtet." -ForegroundColor Green
Write-Host "    Öffne diesen Ordner einfach in JetBrains DataGrip. Die Datenbankverbindung" -ForegroundColor Gray
Write-Host "    'SQL-Fundamentals (SQLEXPRESS)' wird automatisch geladen." -ForegroundColor Gray
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Setup abgeschlossen! Du kannst nun die Skripte ausführen." -ForegroundColor Green
