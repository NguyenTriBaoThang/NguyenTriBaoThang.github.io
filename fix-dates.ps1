# PowerShell script to fix date format in all markdown files
$contentPath = "content"

# Get all markdown files recursively
$markdownFiles = Get-ChildItem -Path $contentPath -Filter "*.md" -Recurse

Write-Host "Found $($markdownFiles.Count) markdown files to process..."

foreach ($file in $markdownFiles) {
    Write-Host "Processing: $($file.FullName)"

    # Read the file content
    $content = Get-Content -Path $file.FullName -Raw

    # Replace the problematic date format
    $newContent = $content -replace 'date\s*:\s*"`r Sys\.Date\(\)`"', 'date : 2023-10-25'

    # Write back to file if content changed
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent -NoNewline
        Write-Host "  Fixed date format in $($file.Name)"
    }
    else {
        Write-Host "  No changes needed for $($file.Name)"
    }
}

Write-Host "Done! All files processed."
