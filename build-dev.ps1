# build-dev.ps1
# Development build: compiles the target board variant and generates merged-binary.bin.
# Does NOT perform git operations or release archiving.

param (
    [string]$Board = "nologo/xingzhi-cube-0.96oled-wifi",
    [string]$Variant = "xingzhi-cube-0.96oled-wifi",
    [string]$Language = "en-US"
)

$ErrorActionPreference = "Stop"

$projectDir = $PSScriptRoot
Set-Location $projectDir

# Read version from CMakeLists.txt
$cmakeLines = Get-Content (Join-Path $projectDir "CMakeLists.txt")
$version = $null
foreach ($line in $cmakeLines) {
    if ($line -match '^set\(PROJECT_VER\s+"([^"]+)"\)') {
        $version = $matches[1]
        break
    }
}

Write-Host "=== MEMO ESP32 - Fast Development Build ===" -ForegroundColor Cyan
Write-Host "Version:  $version" -ForegroundColor Cyan
Write-Host "Board:    $Board ($Variant)" -ForegroundColor Cyan
Write-Host ""

# 1. Configure ESP-IDF environment
$idfPath = "C:\Users\herma\AppData\Local\Programs\esp\v5.5.4"
$env:IDF_PATH = $idfPath
Write-Host "Exporting ESP-IDF environment..." -ForegroundColor Yellow
. (Join-Path $idfPath "export.ps1")

# 2. Compile via build.py
Write-Host "Compiling firmware..." -ForegroundColor Yellow
python scripts/build.py $Board --name $Variant --language $Language
if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed with exit code $LASTEXITCODE"
    exit 1
}

$mergedBin = Join-Path $projectDir "build\merged-binary.bin"
if (-not (Test-Path $mergedBin)) {
    Write-Error "Build failed: merged-binary.bin not found in build/"
    exit 1
}

Write-Host ""
Write-Host "=== Development Build Completed! ===" -ForegroundColor Green
Write-Host "Binary available at: $mergedBin" -ForegroundColor Green
Write-Host "To flash to the ESP32 board, run: flash.bat" -ForegroundColor Cyan
