# =========================
# Controllo privilegi amministrativi
# =========================
$IsAdmin = ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $IsAdmin) {
    Write-Host "Riavvio lo script con privilegi amministrativi..."
    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# =========================
# Percorsi assoluti
# =========================
$CollectLogsPath = "C:\Scripts\Progetto_8\Collect-Logs.ps1"
$AnalyzeLogsPath = "C:\Scripts\Progetto_8\Analyze-Logs.ps1"
$DashboardHTMLPath = "C:\Scripts\Progetto_8\dashboard.html"
$LogFolder = "C:\Logs"

# =========================
# ESECUZIONE RACCOLTA LOG
# =========================
if (Test-Path $CollectLogsPath) {
    Write-Host "Eseguo raccolta log..."
    & $CollectLogsPath
    Write-Host "Raccolta log completata."
} else {
    Write-Host "Errore: script Collect-Logs.ps1 non trovato."
}

# =========================
# ESECUZIONE ANALISI LOG
# =========================
if (Test-Path $AnalyzeLogsPath) {
    Write-Host "Eseguo analisi log..."
    & $AnalyzeLogsPath
    Write-Host "Analisi log completata."
} else {
    Write-Host "Errore: script Analyze-Logs.ps1 non trovato."
}

# =========================
# APERTURA DASHBOARD
# =========================
if (Test-Path $DashboardHTMLPath) {
    Write-Host "Apro dashboard..."
    Start-Process $DashboardHTMLPath
} else {
    Write-Host "Errore: dashboard.html non trovato."
}
