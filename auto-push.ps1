# ⏳ Wait for filesystem + git to settle
Start-Sleep -Seconds 4

# Refresh git index
git update-index -q --refresh

# Get changed files
$changesRaw = git status --porcelain

if (-not $changesRaw) {
    Write-Host "Git reports no changes."
    exit
}

# Split into lines
$lines = $changesRaw -split "`n"

# Normalize slashes (Windows fix)
$lines = $lines | ForEach-Object { $_.Trim() -replace '\\', '/' }

# 🔥 Find first changed Dart file ANYWHERE in repo
$dartLine = $lines | Where-Object { $_ -match "\.dart$" } | Select-Object -First 1

if (-not $dartLine) {
    Write-Host "No Dart file change detected."
    exit
}

# Extract clean path
$filePath = $dartLine -replace '^[ MADRCU\?]+', ''

# ✅ ALWAYS use just the file name (root-safe)
$fileNameOnly = [System.IO.Path]::GetFileNameWithoutExtension($filePath)

# Make readable
$readableName = $fileNameOnly -replace '_', ' '

# Build commit message
$commitMessage = "feat: $readableName updated"

Write-Host "Auto commit message: $commitMessage"

git add .
git commit -m "$commitMessage"
git push