Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" | ForEach-Object {
    $content = Get-Content $_.FullName -Raw
    if ($content -match '\.withOpacity\(') {
        $new = $content -replace '\.withOpacity\(([^)]+)\)', '.withValues(alpha: $1)'
        Set-Content $_.FullName $new -NoNewline
        Write-Host "Fixed: $($_.FullName)"
    }
}
