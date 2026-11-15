# flash.ps1
# Flashes the compiled firmware to the ESP32 board via esptool.

param (
    [string]$Port = "COM4",
    [string]$Binary = "",
    [int]$Baud = 921600
)

$ErrorActionPreference = "Stop"

$projectDir = $PSScriptRoot

# Read version from CMakeLists.txt
$cmakeLines = Get-Content (Join-Path $projectDir "CMakeLists.txt")
$version = $null
foreach ($line in $cmakeLines) {
    if ($line -match '^set\(PROJECT_VER\s+"([^"]+)"\)') {
        $version = $matches[1]
        break
    }
}

if (-not $Binary) {
    $releaseBin = Join-Path $projectDir "releases\memo-esp32-v$version.bin"
    $buildBin = Join-Path $projectDir "build\merged-binary.bin"

    if (Test-Path $releaseBin) {
        $Binary = $releaseBin
    } elseif (Test-Path $buildBin) {
        $Binary = $buildBin
    } else {
        Write-Error "No firmware binary found! Run build.bat or build-dev.ps1 first."
        exit 1
    }
}

if (-not (Test-Path $Binary)) {
    Write-Error "Binary file not found: $Binary"
    exit 1
}

# Resolve Python with esptool
$pythonCmd = "python"
$idfPython = "C:\Users\herma\.espressif\python_env\idf5.5_py3.12_env\Scripts\python.exe"
if (Test-Path $idfPython) {
    $pythonCmd = $idfPython
}

Write-Host "=== MEMO ESP32 - Flash Firmware ===" -ForegroundColor Cyan
Write-Host "Port:   $Port" -ForegroundColor Cyan
Write-Host "Baud:   $Baud" -ForegroundColor Cyan
Write-Host "Binary: $Binary" -ForegroundColor Cyan
Write-Host ""
Write-Host "Writing flash at offset 0x0 via esptool..." -ForegroundColor Yellow

& $pythonCmd -m esptool --chip esp32s3 -p $Port -b $Baud write_flash 0x0 $Binary
if ($LASTEXITCODE -ne 0) {
    Write-Error "esptool failed with exit code $LASTEXITCODE"
    exit 1
}

Write-Host ""
Write-Host "=== Flash Completed Successfully! ===" -ForegroundColor Green
