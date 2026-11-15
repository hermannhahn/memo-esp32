# publish.ps1
# Publication script for MEMO ESP32 firmware:
#   1. Validates current branch (development) and checks repository state
#   2. Reads current version (PROJECT_VER) from CMakeLists.txt
#   3. Validates that binaries for the current version exist in releases/
#   4. Merges development -> main in the project repository and pushes main
#   5. Updates releases/manifest.json for OTA tracking
#   6. Creates GitHub Release v<current_version> on hermannhahn/memo-esp32 with binaries
#   7. Switches back to development
#   8. Increments version (patch/minor/major) via update_version.ps1 for the next cycle
#   9. Syncs branches and cleans up
#
# Flags:
#   major | --major          Increment major version (X.0.0) for next cycle
#   minor | --minor          Increment minor version (0.X.0) for next cycle
#   patch | --patch          Increment patch version (0.0.X) for next cycle [default]
#   -v <type> | --version <type>
#   --reset-updates          Reset UPDATES.md during version bump
#
# Does NOT compile. Run build.bat beforehand.

param (
    [string]$v         = "",
    [string]$version   = "",
    [switch]$major,
    [switch]$minor,
    [switch]$patch,
    [switch]$resetUpdates
)

$ErrorActionPreference = "Stop"

$versionType = "patch"
if ($major)                             { $versionType = "major" }
elseif ($minor)                         { $versionType = "minor" }
elseif ($patch)                         { $versionType = "patch" }
elseif ($v -ne "")                      { $versionType = $v.ToLower() }
elseif ($version -ne "")               { $versionType = $version.ToLower() }

if ($versionType -notin @("major","minor","patch")) {
    Write-Error "Invalid version type: '$versionType'. Choose from: major, minor, patch."
    exit 1
}

$resetUpdatesStr = if ($resetUpdates) { "true" } else { "false" }

$gitPath    = "git"
$projectDir = $PSScriptRoot
Set-Location $projectDir

$repoOwnerName = "hermannhahn/memo-esp32"

Write-Host "=== MEMO ESP32 - Firmware Release Publication ===" -ForegroundColor Cyan
Write-Host "Next version increment: $versionType" -ForegroundColor Cyan
Write-Host "Target GitHub repo:      $repoOwnerName" -ForegroundColor Cyan
Write-Host ""

# 1. Validate branch and local changes
Write-Host "[Git] Verifying repository branch and status..." -ForegroundColor Yellow

$currentBranch = (& $gitPath rev-parse --abbrev-ref HEAD 2>&1).Trim()
if ($currentBranch -ne "development") {
    Write-Error "[ERROR] Publishing must be initiated from the 'development' branch. Current branch: '$currentBranch'"
    exit 1
}

$pendingChanges = & $gitPath status --porcelain 2>&1
if ($pendingChanges) {
    Write-Host "[Git] Staging and committing uncommitted changes on development..." -ForegroundColor Yellow
    & $gitPath add .
    & $gitPath commit -m "chore: save working state before publishing"
    & $gitPath push origin development
}

Write-Host "Branch: development | Status: Clean." -ForegroundColor Green

# 2. Read version to publish
$cmakeLines = Get-Content (Join-Path $projectDir "CMakeLists.txt")
$currentVersion = $null
foreach ($line in $cmakeLines) {
    if ($line -match '^set\(PROJECT_VER\s+"([^"]+)"\)') {
        $currentVersion = $matches[1]
        break
    }
}

if (-not $currentVersion) {
    Write-Error "Could not read PROJECT_VER from CMakeLists.txt."
    exit 1
}

Write-Host "Version to publish: v$currentVersion" -ForegroundColor Green

# 3. Validate binaries exist in releases/
$releasesDir = Join-Path $projectDir "releases"
$binFiles = Get-ChildItem -Path $releasesDir -Filter "memo-esp32-v$currentVersion*.bin" -ErrorAction SilentlyContinue
$appFiles = Get-ChildItem -Path $releasesDir -Filter "memo-esp32-app-v$currentVersion*.bin" -ErrorAction SilentlyContinue

if (-not $binFiles -or $binFiles.Count -eq 0) {
    Write-Error "[ERROR] No merged binary found in releases/ matching memo-esp32-v$currentVersion*.bin`nMake sure to run build.bat before publishing."
    exit 1
}

if (-not $appFiles -or $appFiles.Count -eq 0) {
    Write-Error "[ERROR] No app binary (OTA) found in releases/ matching memo-esp32-app-v$currentVersion*.bin`nMake sure to run build.bat before publishing."
    exit 1
}

$releaseAssets = @()
foreach ($f in $binFiles) { $releaseAssets += $f.FullName }
foreach ($f in $appFiles) { $releaseAssets += $f.FullName }

Write-Host "Release binaries verified ($($releaseAssets.Count) files found): OK." -ForegroundColor Green

# 4. Merge development into main and push
Write-Host ""
Write-Host "[Git] Switching to 'main' branch and merging 'development'..." -ForegroundColor Yellow

& $gitPath checkout main
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] Failed to switch to 'main' branch."
    exit 1
}

& $gitPath merge development
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] Failed to merge 'development' into 'main'."
    & $gitPath checkout development
    exit 1
}

# 5. Update releases/manifest.json
Write-Host ""
Write-Host "[Manifest] Updating releases/manifest.json for v$currentVersion..." -ForegroundColor Yellow

$releasesDir = Join-Path $projectDir "releases"
New-Item -ItemType Directory -Force -Path $releasesDir | Out-Null
$manifestFile = Join-Path $releasesDir "manifest.json"

$downloadUrl = "https://github.com/$repoOwnerName/releases/download/v$currentVersion/memo-esp32-app-v$currentVersion.bin"

if (Test-Path $manifestFile) {
    try {
        $manifest = Get-Content $manifestFile -Raw | ConvertFrom-Json
    } catch {
        $manifest = [PSCustomObject]@{ firmwares = [PSCustomObject]@{} }
    }
} else {
    $manifest = [PSCustomObject]@{ firmwares = [PSCustomObject]@{} }
}

if (-not $manifest.firmwares) {
    $manifest | Add-Member -MemberType NoteProperty -Name "firmwares" -Value ([PSCustomObject]@{})
}

$boards = @("memo-esp32", "xingzhi-cube-0.96oled-wifi")
foreach ($b in $boards) {
    if ($manifest.firmwares.PSObject.Properties[$b]) {
        $manifest.firmwares.$b.version = $currentVersion
        $manifest.firmwares.$b.url     = $downloadUrl
    } else {
        $manifest.firmwares | Add-Member -MemberType NoteProperty -Name $b -Value ([PSCustomObject]@{
            version = $currentVersion
            url     = $downloadUrl
        })
    }
}

$manifest | ConvertTo-Json -Depth 5 | Out-File -FilePath $manifestFile -Encoding utf8

& $gitPath add $manifestFile
$statusAfterManifest = & $gitPath status --porcelain 2>&1
if ($statusAfterManifest) {
    & $gitPath commit -m "chore: update manifest.json for v$currentVersion"
}

Write-Host "[Git] Pushing 'main' to GitHub..." -ForegroundColor Yellow
& $gitPath push origin main
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] Failed to push 'main' branch."
    & $gitPath checkout development
    exit 1
}

# 6. Create GitHub Release
Write-Host ""
Write-Host "[GitHub] Creating GitHub Release v$currentVersion..." -ForegroundColor Yellow

gh release create "v$currentVersion" @releaseAssets `
    --title "Release v$currentVersion" `
    --notes "Firmware MEMO ESP32 v$currentVersion" `
    --repo $repoOwnerName

if ($LASTEXITCODE -ne 0) {
    Write-Warning "gh release create returned code $LASTEXITCODE. Verify release on GitHub."
}

# 7. Switch back to development branch
Write-Host ""
Write-Host "[Git] Returning to 'development' branch..." -ForegroundColor Yellow
& $gitPath checkout development

# 8. Bump version for next development cycle
Write-Host ""
Write-Host "[Version] Bumping version ($versionType) for next cycle..." -ForegroundColor Yellow
& $gitPath checkout -b bump-version

powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $projectDir "update_version.ps1") $versionType $resetUpdatesStr
if ($LASTEXITCODE -ne 0) {
    Write-Error "[ERROR] Failed to update version."
    & $gitPath checkout development
    & $gitPath branch -D bump-version
    exit 1
}

& $gitPath checkout development
& $gitPath merge bump-version
& $gitPath branch -d bump-version

# 9. Sync main and push both branches
Write-Host ""
Write-Host "[Git] Syncing main with new version bump..." -ForegroundColor Yellow
& $gitPath checkout main
& $gitPath merge development
& $gitPath push origin main
& $gitPath push origin development

& $gitPath checkout development

Write-Host ""
Write-Host "=== Publication Completed Successfully! ===" -ForegroundColor Green
Write-Host "Release v$currentVersion published to $repoOwnerName" -ForegroundColor Green
Write-Host "CMakeLists.txt updated for next development cycle." -ForegroundColor Green
