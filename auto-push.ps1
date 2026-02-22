$changes = git status --porcelain

if ($changes) {
    Write-Host "Changes detected. Auto pushing..."

    git add .
    git commit -m "chore: auto sync"
    git push
}