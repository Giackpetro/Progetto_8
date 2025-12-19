# =========================
# Cartella dei log
# =========================
$LogFolder = "C:\Logs"
$TopEventsFile = Join-Path $LogFolder "TopEvents.json"

# =========================
# Array per tutti gli eventi
# =========================
$AllEvents = @()

# =========================
# Legge tutti i JSON
# =========================
$LogFiles = Get-ChildItem $LogFolder -Filter "*.json" -File
foreach ($file in $LogFiles) {
    try {
        $Events = Get-Content $file.FullName -Raw | ConvertFrom-Json

        # Se è un singolo oggetto, lo converte in array
        if ($Events -isnot [System.Array]) { $Events = @($Events) }

        $AllEvents += $Events
        Write-Host "File $($file.Name) letto: $($Events.Count) eventi"

    } catch {
        Write-Host "Errore nella lettura del file $($file.Name): $($_.Exception.Message)"
    }
}

# =========================
# Calcola Top 10 eventi per ID
# =========================
if ($AllEvents.Count -gt 0) {
    $TopEvents = $AllEvents |
        Group-Object Id |
        Sort-Object Count -Descending |
        Select-Object -First 10 |
        ForEach-Object {
            [PSCustomObject]@{
                Id    = $_.Name
                Count = $_.Count
            }
        }

    $TopEvents | ConvertTo-Json -Depth 4 | Out-File $TopEventsFile
    Write-Host "TopEvents.json creato: $TopEventsFile"

} else {
    Write-Host "Nessun evento trovato. TopEvents.json non creato."
}

$HtmlContent = @"
<!DOCTYPE html>
<html lang="it">
<head>
    <meta charset="UTF-8">
    <title>Top Events Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        table { border-collapse: collapse; width: 50%; margin-top: 20px; }
        th, td { border: 1px solid #999; padding: 8px; text-align: left; }
        th { background-color: #eee; }
    </style>
</head>
<body>
    <h1>Top Events</h1>
    <table id="eventsTable">
        <thead>
            <tr>
                <th>Id Evento</th>
                <th>Conteggio</th>
            </tr>
        </thead>
        <tbody>
"@

foreach ($event in $TopEvents) {
    $HtmlContent += "            <tr><td>$($event.Id)</td><td>$($event.Count)</td></tr>`n"
}

$HtmlContent += @"
        </tbody>
    </table>
</body>
</html>
"@

# =========================
# Salva HTML
# =========================
$HtmlContent | Out-File "C:\Logs\dashboard.html" -Encoding UTF8

Write-Host "Dashboard generata in C:\Logs\dashboard.html"