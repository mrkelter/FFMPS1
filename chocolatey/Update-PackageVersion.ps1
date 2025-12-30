# Update-PackageVersion.ps1
# Helper script to update version numbers across all files

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$NewVersion,
    
    [Parameter()]
    [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

Write-Host "Updating FFMPS1 package to version $NewVersion" -ForegroundColor Cyan
Write-Host ""

# Validate version format
if ($NewVersion -notmatch '^\d+\.\d+\.\d+$') {
    Write-Error "Invalid version format. Use semantic versioning (e.g., 1.0.0)"
    exit 1
}

# File paths
$rootDir = Split-Path $PSScriptRoot -Parent
$files = @{
    'Module Manifest' = @{
        Path = Join-Path $rootDir 'FFmpeg.psd1'
        Pattern = "ModuleVersion = '[\d.]+'"
        Replacement = "ModuleVersion = '$NewVersion'"
    }
    'Chocolatey NuSpec' = @{
        Path = Join-Path $rootDir 'chocolatey\ffmps1.nuspec'
        Patterns = @(
            @{
                Pattern = '<version>[\d.]+</version>'
                Replacement = "<version>$NewVersion</version>"
            },
            @{
                Pattern = '<releaseNotes>https://github.com/mrkelter/FFMPS1/releases/tag/v[\d.]+</releaseNotes>'
                Replacement = "<releaseNotes>https://github.com/mrkelter/FFMPS1/releases/tag/v$NewVersion</releaseNotes>"
            }
        )
    }
    'Install Script' = @{
        Path = Join-Path $rootDir 'chocolatey\tools\chocolateyInstall.ps1'
        Pattern = '\$moduleVersion = ''[\d.]+'''
        Replacement = "`$moduleVersion = '$NewVersion'"
    }
    'Uninstall Script' = @{
        Path = Join-Path $rootDir 'chocolatey\tools\chocolateyUninstall.ps1'
        Pattern = '\$moduleVersion = ''[\d.]+'''
        Replacement = "`$moduleVersion = '$NewVersion'"
    }
}

# Update each file
foreach ($fileInfo in $files.GetEnumerator()) {
    $name = $fileInfo.Key
    $config = $fileInfo.Value
    $path = $config.Path
    
    if (-not (Test-Path $path)) {
        Write-Warning "File not found: $path"
        continue
    }
    
    Write-Host "Updating: $name" -ForegroundColor Yellow
    Write-Host "  Path: $path" -ForegroundColor Gray
    
    $content = Get-Content $path -Raw
    $originalContent = $content
    
    # Handle single pattern or multiple patterns
    if ($config.Pattern) {
        $content = $content -replace $config.Pattern, $config.Replacement
        Write-Host "  Pattern: $($config.Pattern)" -ForegroundColor Gray
        Write-Host "  Replacement: $($config.Replacement)" -ForegroundColor Gray
    }
    elseif ($config.Patterns) {
        foreach ($patternInfo in $config.Patterns) {
            $content = $content -replace $patternInfo.Pattern, $patternInfo.Replacement
            Write-Host "  Pattern: $($patternInfo.Pattern)" -ForegroundColor Gray
            Write-Host "  Replacement: $($patternInfo.Replacement)" -ForegroundColor Gray
        }
    }
    
    if ($content -ne $originalContent) {
        if ($WhatIf) {
            Write-Host "  [WHATIF] Would update file" -ForegroundColor Cyan
        }
        else {
            $content | Set-Content $path -NoNewline
            Write-Host "  ✓ Updated successfully" -ForegroundColor Green
        }
    }
    else {
        Write-Host "  ! No changes needed" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Summary
Write-Host "Version update complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review the changes:" -ForegroundColor Gray
Write-Host "     git diff" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Test the package locally:" -ForegroundColor Gray
Write-Host "     cd chocolatey" -ForegroundColor Cyan
Write-Host "     choco pack ffmps1.nuspec" -ForegroundColor Cyan
Write-Host "     choco install ffmps1 -source . -force -y" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Commit and tag:" -ForegroundColor Gray
Write-Host "     git add ." -ForegroundColor Cyan
Write-Host "     git commit -m 'Release v$NewVersion'" -ForegroundColor Cyan
Write-Host "     git tag v$NewVersion" -ForegroundColor Cyan
Write-Host "     git push origin main" -ForegroundColor Cyan
Write-Host "     git push origin v$NewVersion" -ForegroundColor Cyan
Write-Host ""

if ($WhatIf) {
    Write-Host "This was a dry run. Use without -WhatIf to apply changes." -ForegroundColor Cyan
}
