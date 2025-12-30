$ErrorActionPreference = 'Stop'

$packageName = 'ffmps1'
$moduleName = 'FFmpeg'
$moduleVersion = '1.0.0'

Write-Host "Uninstalling $packageName PowerShell module..." -ForegroundColor Cyan

# Module installation paths to check
$modulePaths = @(
    "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleVersion",
    "$env:ProgramFiles\PowerShell\Modules\$moduleName\$moduleVersion",
    "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName",
    "$env:ProgramFiles\PowerShell\Modules\$moduleName"
)

$removedAny = $false

foreach ($path in $modulePaths) {
    if (Test-Path $path) {
        Write-Host "Removing module from: $path" -ForegroundColor Yellow
        
        # Remove the module from memory if it's loaded
        $loadedModule = Get-Module -Name $moduleName -ErrorAction SilentlyContinue
        if ($loadedModule) {
            Write-Host "  Unloading module from current session..." -ForegroundColor Gray
            Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        }
        
        # Remove the directory
        try {
            Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
            Write-Host "  Removed: $path" -ForegroundColor Green
            $removedAny = $true
        }
        catch {
            Write-Warning "Failed to remove $path : $_"
        }
        
        # If this was a version-specific path, check if parent module directory is empty
        if ($path -like "*\$moduleVersion") {
            $parentPath = Split-Path $path -Parent
            if ((Test-Path $parentPath) -and ((Get-ChildItem $parentPath -ErrorAction SilentlyContinue).Count -eq 0)) {
                Write-Host "  Removing empty parent directory: $parentPath" -ForegroundColor Gray
                Remove-Item -Path $parentPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

if ($removedAny) {
    Write-Host ""
    Write-Host "Successfully uninstalled $packageName v$moduleVersion" -ForegroundColor Green
} else {
    Write-Host "No installation found to remove" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Note: FFmpeg dependency was not removed (may be used by other packages)" -ForegroundColor Gray
Write-Host "      To remove FFmpeg, run: choco uninstall ffmpeg" -ForegroundColor Gray
