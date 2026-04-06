param(
    [string]$BackupRoot = "backup"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = Join-Path $scriptDir $BackupRoot
$targetPath = Join-Path $backupPath $timestamp

New-Item -ItemType Directory -Path $targetPath -Force | Out-Null

$exclude = @($BackupRoot, "boot.bin", "kernel.bin", "os.img")
Get-ChildItem -Path $scriptDir -File -Force | Where-Object { $exclude -notcontains $_.Name } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $targetPath
}

Write-Host "Backup created at: $targetPath"