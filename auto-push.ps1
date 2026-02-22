# Prevent multiple parallel runs
$lockFile = ".autopush.lock"

if (Test-Path $lockFile) {
    Write-Host "Auto-push already running, skipping..."
    exit
}

New-Item $lockFile -ItemType File | Out-Null

try {
    # Wait for filesystem to settle
    Start-Sleep -Seconds 2

    git add -A

    $changesRaw = git diff --name-only --cached

    if (-not $changesRaw) {
        Write-Host "No staged Dart changes."
        return
    }

    $files = $changesRaw -split "`n"
    $files = $files | ForEach-Object { $_.Trim() -replace '\\', '/' }

    $dartFile = $files | Where-Object { $_ -match "\.dart$" } | Select-Object -First 1

    if (-not $dartFile) {
        Write-Host "No Dart file change detected."
        return
    }

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($dartFile)
    $readableName = $baseName -replace '_', ' '

    $commitMessage = "feat: $readableName updated"

    Write-Host "Auto commit message: $commitMessage"

    git commit -m "$commitMessage"
    git push
}
finally {
    Remove-Item $lockFile -ErrorAction SilentlyContinue
}