# update_version.ps1
# Bumps the firmware version in CMakeLists.txt and optionally resets UPDATES.md

param (
    [string]$type = "patch",
    [string]$resetUpdates = "false"
)

$ErrorActionPreference = "Stop"

$projectDir = $PSScriptRoot
$cmakeFile = Join-Path $projectDir "CMakeLists.txt"

if (-not (Test-Path $cmakeFile)) {
    Write-Error "CMakeLists.txt not found!"
    exit 1
}

$content = Get-Content $cmakeFile
$updated = $false
$newContent = @()
$newVer = $null

foreach ($line in $content) {
    if ($line -match '^set\(PROJECT_VER\s+"([^"]+)"\)') {
        $currentVer = $matches[1]
        if ($currentVer -match '^(\d+)\.(\d+)\.(\d+)') {
            $major = [int]$matches[1]
            $minor = [int]$matches[2]
            $patch = [int]$matches[3]

            if ($type -eq "major") {
                $major++
                $minor = 0
                $patch = 0
            } elseif ($type -eq "minor") {
                $minor++
                $patch = 0
            } else {
                $patch++
            }

            $newVer = "$major.$minor.$patch"
            $line = "set(PROJECT_VER `"$newVer`")"
            $updated = $true
            Write-Host "Firmware version updated from $currentVer to $newVer" -ForegroundColor Green
        }
    }
    $newContent += $line
}

if ($updated) {
    $newContent | Out-File -FilePath $cmakeFile -Encoding utf8

    if ($resetUpdates -eq "true") {
        $updatesFile = Join-Path $projectDir "UPDATES.md"
        $header = @"
# Update History - v$newVer

This file tracks improvements, fixes, and new features implemented in **MEMO ESP32**.

---
"@
        $header | Out-File -FilePath $updatesFile -Encoding utf8
        Write-Host "UPDATES.md reset for version v$newVer" -ForegroundColor Green
    }

    Write-Host "Staging version bump locally..." -ForegroundColor Yellow
    git add $cmakeFile
    if ($resetUpdates -eq "true") {
        git add (Join-Path $projectDir "UPDATES.md")
    }
    git commit -m "bump: start version v$newVer"
} else {
    Write-Error "Could not find set(PROJECT_VER) in CMakeLists.txt"
    exit 1
}
