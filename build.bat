@echo off
REM Simple Operating System Compilation Script (Windows)
REM Used for rapid compilation and testing of the OS

setlocal enabledelayedexpansion

if exist backup.ps1 (
    where powershell.exe >nul 2>&1
    if not errorlevel 1 (
        powershell -NoProfile -ExecutionPolicy Bypass -File backup.ps1 >nul
    )
)

set ASM=nasm
set BOOT_SRC=boot.asm
set KERNEL_SRC=kernel.asm
set BOOT_BIN=boot.bin
set KERNEL_BIN=kernel.bin
set OS_IMG=os.img

echo ================================
echo creatively OS (cos) - Build Tool
echo ================================

if "%1"=="" (
    call :build
) else if "%1"=="build" (
    call :build
) else if "%1"=="clean" (
    call :clean
) else if "%1"=="run" (
    call :build
    call :run
) else if "%1"=="debug" (
    call :build
    call :debug
) else if "%1"=="help" (
    call :help
) else (
    echo Unknown command: %1
    echo Type "build.bat help" for help
    exit /b 1
)

exit /b 0

:build
    echo.
    echo Compiling...
    
    REM Check NASM
    where %ASM% >nul 2>&1
    if errorlevel 1 (
        echo Error: NASM compiler not found
        echo Please install NASM first: https://www.nasm.us/
        exit /b 1
    )
    
    REM Compile bootloader
    echo Compiling bootloader...
    %ASM% -f bin -o %BOOT_BIN% %BOOT_SRC%
    if errorlevel 1 (
        echo Error: Bootloader compilation failed
        exit /b 1
    )
    echo Generated: %BOOT_BIN%
    
    REM Compile kernel
    echo Compiling kernel...
    %ASM% -f bin -o %KERNEL_BIN% %KERNEL_SRC%
    if errorlevel 1 (
        echo Error: Kernel compilation failed
        exit /b 1
    )
    echo Generated: %KERNEL_BIN%
    
    REM Generate image
    echo Generating OS image...
    copy /b %BOOT_BIN% + %KERNEL_BIN% %OS_IMG%
    if errorlevel 1 (
        echo Error: Image generation failed
        exit /b 1
    )
    
    echo.
    echo ✓ Compilation successful!
    echo Generated files:
    dir %OS_IMG% | find "%OS_IMG%"
    exit /b 0

:clean
    echo.
    echo Cleaning up...
    
    if exist %BOOT_BIN% (
        del %BOOT_BIN%
        echo Deleted: %BOOT_BIN%
    )
    
    if exist %KERNEL_BIN% (
        del %KERNEL_BIN%
        echo Deleted: %KERNEL_BIN%
    )
    
    if exist %OS_IMG% (
        del %OS_IMG%
        echo Deleted: %OS_IMG%
    )
    
    echo ✓ Cleanup complete
    exit /b 0

:run
    echo.
    echo Starting virtual machine...
    
    if not exist %OS_IMG% (
        echo Error: os.img does not exist, please compile first
        exit /b 1
    )
    
    where qemu-system-i386 >nul 2>&1
    if errorlevel 1 (
        echo QEMU virtual machine not found
        echo Please install QEMU first: https://www.qemu.org/
        exit /b 1
    )
    
    qemu-system-i386 -fda %OS_IMG% -boot a
    exit /b 0

:debug
    echo.
    echo Starting virtual machine in debug mode...
    
    if not exist %OS_IMG% (
        echo Error: os.img does not exist, please compile first
        exit /b 1
    )
    
    where qemu-system-i386 >nul 2>&1
    if errorlevel 1 (
        echo QEMU virtual machine not found
        echo Please install QEMU first: https://www.qemu.org/
        exit /b 1
    )
    
    echo Starting debug server (localhost:1234)...
    qemu-system-i386 -fda %OS_IMG% -boot a -s -S
    exit /b 0

:help
    echo.
    echo Usage:
    echo.
    echo   build.bat [command]
    echo.
    echo Commands:
    echo   build      Compile the operating system
    echo   clean      Delete generated files
    echo   run        Compile and run virtual machine (requires QEMU)
    echo   debug      Run in debug mode (requires QEMU)
    echo   help       Display this help message
    echo.
    echo Examples:
    echo   build.bat           (compile)
    echo   build.bat run       (compile and run)
    echo   build.bat clean     (cleanup files)
    echo.
    exit /b 0
