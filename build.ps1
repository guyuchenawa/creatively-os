# Simple Operating System Compilation Script (PowerShell)
# Used for rapid compilation and testing of the OS

param(
    [string]$Command = "build"
)

$ErrorActionPreference = "Stop"

# Configuration
$ASM = "nasm"
$BOOT_SRC = "boot.asm"
$KERNEL_SRC = "kernel.asm"
$BOOT_BIN = "boot.bin"
$KERNEL_BIN = "kernel.bin"
$OS_IMG = "os.img"

function Show-Banner {
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host "creatively OS (cos) - Build Tool v1.0.1" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    Write-Host ""
}

function Backup-Files {
    $backupScript = Join-Path $PSScriptRoot "backup.ps1"
    if (Test-Path $backupScript) {
        Write-Host "Saving pre-build backup..." -ForegroundColor Cyan
        & $backupScript
        Write-Host "" 
    }
}

function Build-OS {
    Backup-Files
    Write-Host "Compiling operating system..." -ForegroundColor Yellow
    Write-Host ""
    
    # Check NASM
    $nasm_path = Get-Command $ASM -ErrorAction SilentlyContinue
    if (-not $nasm_path) {
        Write-Host "Error: NASM compiler not found" -ForegroundColor Red
        Write-Host "Please install NASM first: https://www.nasm.us/" -ForegroundColor Yellow
        exit 1
    }
    
    # Compile bootloader
    Write-Host "[1/3] Compiling bootloader..." -ForegroundColor Green
    & $ASM -f bin -o $BOOT_BIN $BOOT_SRC
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Bootloader compilation failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Generated: $BOOT_BIN ($($(Get-Item $BOOT_BIN).Length) bytes)" -ForegroundColor Green
    
    # Compile kernel
    Write-Host "[2/3] Compiling kernel..." -ForegroundColor Green
    & $ASM -f bin -o $KERNEL_BIN $KERNEL_SRC
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Kernel compilation failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Generated: $KERNEL_BIN ($($(Get-Item $KERNEL_BIN).Length) bytes)" -ForegroundColor Green
    
    # Generate image
    Write-Host "[3/3] Generating OS image..." -ForegroundColor Green
    $boot_content = [System.IO.File]::ReadAllBytes($BOOT_BIN)
    $kernel_content = [System.IO.File]::ReadAllBytes($KERNEL_BIN)
    [System.IO.File]::WriteAllBytes($OS_IMG, $boot_content + $kernel_content)
    
    $img_size = $(Get-Item $OS_IMG).Length
    Write-Host "✓ Generated: $OS_IMG ($img_size bytes)" -ForegroundColor Green
    Write-Host ""
    Write-Host "✓ Compilation complete!" -ForegroundColor Green
}

function Clean-Files {
    Write-Host "Cleaning up files..." -ForegroundColor Yellow
    Write-Host ""
    
    @($BOOT_BIN, $KERNEL_BIN, $OS_IMG) | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item $_ -Force
            Write-Host "✓ Deleted: $_" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "✓ Cleanup complete!" -ForegroundColor Green
}

function Run-VM {
    if (-not (Test-Path $OS_IMG)) {
        Write-Host "Error: $OS_IMG does not exist, please compile first" -ForegroundColor Red
        Build-OS
    }
    
    Write-Host "Starting virtual machine..." -ForegroundColor Yellow
    Write-Host ""
    
    $qemu_path = Get-Command "qemu-system-i386" -ErrorAction SilentlyContinue
    if (-not $qemu_path) {
        Write-Host "QEMU virtual machine not found" -ForegroundColor Red
        Write-Host "Please install QEMU first: https://www.qemu.org/" -ForegroundColor Yellow
        exit 1
    }
    
    & "qemu-system-i386" -fda $OS_IMG -boot a
}

function Debug-VM {
    if (-not (Test-Path $OS_IMG)) {
        Write-Host "Error: $OS_IMG does not exist, please compile first" -ForegroundColor Red
        Build-OS
    }
    
    Write-Host "Starting virtual machine in debug mode..." -ForegroundColor Yellow
    Write-Host "Debug server address: localhost:1234" -ForegroundColor Cyan
    Write-Host ""
    
    $qemu_path = Get-Command "qemu-system-i386" -ErrorAction SilentlyContinue
    if (-not $qemu_path) {
        Write-Host "QEMU virtual machine not found" -ForegroundColor Red
        Write-Host "Please install QEMU first: https://www.qemu.org/" -ForegroundColor Yellow
        exit 1
    }
    
    & "qemu-system-i386" -fda $OS_IMG -boot a -s -S
}

function Show-Help {
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  .\build.ps1 [command]" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  build      Compile the operating system (default)" -ForegroundColor White
    Write-Host "  clean      Delete generated files" -ForegroundColor White
    Write-Host "  run        Compile and run virtual machine (requires QEMU)" -ForegroundColor White
    Write-Host "  debug      Run in debug mode (requires QEMU)" -ForegroundColor White
    Write-Host "  help       Display this help message" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  .\build.ps1              (compile)" -ForegroundColor Gray
    Write-Host "  .\build.ps1 run          (compile and run)" -ForegroundColor Gray
    Write-Host "  .\build.ps1 clean        (cleanup files)" -ForegroundColor Gray
    Write-Host "  .\build.ps1 debug        (debug mode)" -ForegroundColor Gray
    Write-Host ""
}

# Main program
Show-Banner

switch ($Command.ToLower()) {
    "build" {
        Build-OS
    }
    "clean" {
        Clean-Files
    }
    "run" {
        Build-OS
        Run-VM
    }
    "debug" {
        Build-OS
        Debug-VM
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "Error: Unknown command '$Command'" -ForegroundColor Red
        Show-Help
        exit 1
    }
}
