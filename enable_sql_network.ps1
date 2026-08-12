# ============================================================================
# SQL-Fundamentals: Enable TCP/IP, Named Pipes & Browser for SQL Server Express
# Run this script in PowerShell as Administrator
# ============================================================================

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Dieses Skript benoetigt Administratorrechte."
    Write-Host "Bitte starte PowerShell als Administrator und fuehre das Skript erneut aus:" -ForegroundColor Yellow
    Write-Host "  Start-Process powershell -Verb RunAs -ArgumentList '-File `"$PSCommandPath`"'" -ForegroundColor Cyan
    Exit
}

Write-Host "Aktiviere Netzwerk-Protokolle (TCP/IP und Named Pipes) fuer SQLEXPRESS..." -ForegroundColor Cyan

# 1. Enable TCP/IP in Registry
$tcpPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Tcp'
if (Test-Path $tcpPath) {
    Set-ItemProperty -Path $tcpPath -Name 'Enabled' -Value 1
    Write-Host "[OK] TCP/IP aktiviert." -ForegroundColor Green
}

# 2. Enable Named Pipes in Registry
$npPath = 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL17.SQLEXPRESS\MSSQLServer\SuperSocketNetLib\Np'
if (Test-Path $npPath) {
    Set-ItemProperty -Path $npPath -Name 'Enabled' -Value 1
    Write-Host "[OK] Named Pipes aktiviert." -ForegroundColor Green
}

# 3. Enable & Start SQL Server Browser Service
Write-Host "Aktiviere SQL Server-Browser Dienst..." -ForegroundColor Cyan
Set-Service -Name SQLBrowser -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name SQLBrowser -ErrorAction SilentlyContinue
Write-Host "[OK] SQL Server-Browser Dienst gestartet." -ForegroundColor Green

# 4. Restart SQLEXPRESS Service to apply network changes
Write-Host "Neustart des SQL Server Dienstes (SQLEXPRESS)..." -ForegroundColor Cyan
$svcName = 'MSSQL$SQLEXPRESS'
Restart-Service -Name $svcName -Force
Write-Host "[OK] SQL Server (SQLEXPRESS) erfolgreich neu gestartet!" -ForegroundColor Green

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "Setup abgeschlossen! Du kannst nun in DataGrip auf 'Test Connection' klicken." -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan
