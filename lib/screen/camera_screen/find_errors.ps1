$logPath = "C:\Users\hi\.gemini\antigravity\brain\8126e7a2-0ded-4e5f-a5fc-595e050bbb15\.system_generated\tasks\task-467.log"
if (-not (Test-Path $logPath)) {
    Write-Host "Log file not found: $logPath"
    Exit
}
$lines = Get-Content $logPath
$start = 6348
$end = [Math]::Min($start + 45, $lines.Length)
for ($j = $start; $j -lt $end; $j++) {
    Write-Host $lines[$j]
}
