Start-Sleep -Seconds 5

$changes = git status --porcelain

if ($changes) {
    # Get first changed file
    $file = ($changes | Select-Object -First 1).ToString().Trim()

    # Extract file name
    $fileName = $file -replace '^[ MADRCU\?]+', ''
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($fileName)

    # Make readable text
    $messageName = $baseName -replace '_', ' '

    $commitMessage = "feat: $messageName updated"

    Write-Host "Auto commit message: $commitMessage"

    git add .
    git commit -m "$commitMessage"
    git push
}