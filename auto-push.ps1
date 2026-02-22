# ⏳ wait a bit to batch rapid changes
Start-Sleep -Seconds 5

$changes = git status --porcelain

if ($changes) {
    Write-Host "Changes detected. Auto pushing..."

    git add .
    git commit -m "chore: auto sync"
    git push
}