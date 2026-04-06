param(
    [string]$Command = "build",
    [string]$BackupRoot = "backup"
)

$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

function Timestamp { Get-Date -Format "yyyyMMdd_HHmmss" }

try {
    Write-Host "Running build.ps1 ($Command) and creating post-build backup..." -ForegroundColor Cyan

    # Run the build (build.ps1 is located in the parent directory)
    $buildScript = Join-Path $scriptDir "..\build.ps1"
    $buildScript = (Resolve-Path $buildScript).ProviderPath
    & $buildScript $Command

    # After successful build, create post-build backup
    $ts = Timestamp
    $target = Join-Path $scriptDir "$BackupRoot\${ts}_post"
    New-Item -ItemType Directory -Path $target -Force | Out-Null

    $exclude = @($BackupRoot, "boot.bin", "kernel.bin", "os.img")
    Get-ChildItem -Path $scriptDir -File -Force | Where-Object { $exclude -notcontains $_.Name } | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination $target -Force
    }

    Write-Host "Post-build backup created at: $target" -ForegroundColor Green
    exit 0
} catch {
    Write-Host "Error during build or backup: $_" -ForegroundColor Red
    exit 1
}
