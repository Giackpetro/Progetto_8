# =========================
# Cartella di output log
# =========================
$OutputFolder = "C:\Logs"
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder
}

# =========================
# Log da raccogliere
# =========================
$Logs = @("Application", "System", "Security")

# =========================
# Definisce filtro temporale: ultimi 30 giorni
# =========================
$StartTime = (Get-Date).AddDays(-30)

# =========================
# Ciclo sui log
# =========================
foreach ($log in $Logs) {

    $Date = Get-Date -Format "yyyyMMdd_HHmmss"
    $File = "$OutputFolder\$log-$Date.json"

    try {
    Get-WinEvent -FilterHashtable @{
        LogName   = $log
        Level     = 1,2,3
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue |
    Select-Object TimeCreated, Id, LevelDisplayName, ProviderName, Message |
    ConvertTo-Json -Depth 4 |
    Out-File $File

    Write-Host "Log $log raccolto in $File"

} catch {
    $err = $_
    Write-Host "Errore nella lettura del log $log"
    Write-Host $err.Exception.Message
}



}

# =========================
# Pulizia log vecchi (oltre 30 giorni)
# =========================
Get-ChildItem $OutputFolder -File |
Where-Object { $_.CreationTime -lt (Get-Date).AddDays(-30) } |
Remove-Item

Write-Host "Pulizia log vecchi completata."
