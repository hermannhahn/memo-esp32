# build.ps1
# Release build for MEMO ESP32 firmware.
# Compiles the target board variant, generates merged binary, and copies binaries to releases/.
# Does NOT perform git operations. Use publish.bat / publish.ps1 to release.

param (
    [string]$Board = "nologo/xingzhi-cube-0.96oled-wifi",
    [string]$Variant = "xingzhi-cube-0.96oled-wifi",
    [string]$Hardware = "n16r8-oled098",
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
if (-not $version) {
    Write-Error "Could not find PROJECT_VER in CMakeLists.txt"
    exit 1
}

Write-Host "=== MEMO ESP32 - Release Build ===" -ForegroundColor Cyan
Write-Host "Version:  $version" -ForegroundColor Cyan
Write-Host "Board:    $Board" -ForegroundColor Cyan
Write-Host "Variant:  $Variant" -ForegroundColor Cyan
Write-Host "Language: $Language" -ForegroundColor Cyan
Write-Host ""

# 1. Configure ESP-IDF environment
$idfPath = "C:\Users\herma\AppData\Local\Programs\esp\v5.5.4"
if (-not (Test-Path $idfPath)) {
    Write-Error "ESP-IDF not found at: $idfPath"
    exit 1
}

$env:IDF_PATH = $idfPath
Write-Host "Exporting ESP-IDF environment from $idfPath..." -ForegroundColor Yellow
. (Join-Path $idfPath "export.ps1")

# 2. Build via scripts/build.py
Write-Host ""
Write-Host "Building firmware for board: $Board (variant: $Variant)..." -ForegroundColor Yellow

python scripts/build.py $Board --name $Variant --language $Language --zip
if ($LASTEXITCODE -ne 0) {
    Write-Error "scripts/build.py failed with exit code $LASTEXITCODE"
    exit 1
}

# 3. Verify merged binary
$mergedBin = Join-Path $projectDir "build\merged-binary.bin"
if (-not (Test-Path $mergedBin)) {
    Write-Error "Build failed: merged-binary.bin not found in build/"
    exit 1
}

# 4. Copy binaries to releases/
$releasesDir = Join-Path $projectDir "releases"
New-Item -ItemType Directory -Force -Path $releasesDir | Out-Null

$hwMergedName = "memo-esp32-v$version-$Hardware.bin"
$hwAppName = "memo-esp32-app-v$version-$Hardware.bin"
$destMergedHw = Join-Path $releasesDir $hwMergedName
$destAppHw = Join-Path $releasesDir $hwAppName

Copy-Item -Path $mergedBin -Destination $destMergedHw -Force
Write-Host "Hardware merged binary (cable flash): $destMergedHw" -ForegroundColor Green

$destMerged = Join-Path $releasesDir "memo-esp32-v$version.bin"
Copy-Item -Path $mergedBin -Destination $destMerged -Force

$appBin = Join-Path $projectDir "build\memo-esp32.bin"
$legacyAppBin = Join-Path $projectDir "build\xiaozhi.bin"
$appSource = $null

if (Test-Path $appBin) {
    $appSource = $appBin
} elseif (Test-Path $legacyAppBin) {
    $appSource = $legacyAppBin
} else {
    Write-Error "Build failed: App binary (memo-esp32.bin or xiaozhi.bin) not found in build/"
    exit 1
}

Copy-Item -Path $appSource -Destination $destAppHw -Force
Write-Host "Hardware app binary (OTA update):    $destAppHw" -ForegroundColor Green

$destApp = Join-Path $releasesDir "memo-esp32-app-v$version.bin"
Copy-Item -Path $appSource -Destination $destApp -Force

Write-Host ""
Write-Host "=== Build Completed Successfully! ===" -ForegroundColor Green
Write-Host "Primary Release Target: $destMergedHw" -ForegroundColor Green
Write-Host "Primary OTA Target:     $destAppHw" -ForegroundColor Green
Write-Host ""
Write-Host "To flash to the ESP32 board, run: flash.bat" -ForegroundColor Cyan
Write-Host "To publish the release, run:      publish.bat" -ForegroundColor Cyan
