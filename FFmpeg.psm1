# FFmpeg PowerShell Module

# Helper function to check if FFmpeg is installed
function Test-FFmpegInstalled {
    return (Get-Command ffmpeg -ErrorAction SilentlyContinue) -ne $null
}

# Helper function to install FFmpeg
function Install-FFmpegDependency {
    [CmdletBinding()]
    param()
    
    Write-Host "FFmpeg is not installed. Attempting to install..." -ForegroundColor Yellow
    
    # Try Chocolatey first
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "Installing FFmpeg via Chocolatey..." -ForegroundColor Cyan
        try {
            choco install ffmpeg -y
            Write-Host "FFmpeg installed successfully via Chocolatey!" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "Failed to install via Chocolatey: $_"
        }
    }
    
    # Try Scoop
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Installing FFmpeg via Scoop..." -ForegroundColor Cyan
        try {
            scoop install ffmpeg
            Write-Host "FFmpeg installed successfully via Scoop!" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "Failed to install via Scoop: $_"
        }
    }
    
    # Try winget
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "Installing FFmpeg via winget..." -ForegroundColor Cyan
        try {
            winget install --id Gyan.FFmpeg -e --silent
            Write-Host "FFmpeg installed successfully via winget!" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Warning "Failed to install via winget: $_"
        }
    }
    
    # No package manager available
    Write-Warning "No package manager found (Chocolatey, Scoop, or winget)."
    Write-Host "`nTo install FFmpeg manually, choose one of these options:" -ForegroundColor Yellow
    Write-Host "1. Chocolatey: choco install ffmpeg" -ForegroundColor Cyan
    Write-Host "2. Scoop: scoop install ffmpeg" -ForegroundColor Cyan
    Write-Host "3. winget: winget install Gyan.FFmpeg" -ForegroundColor Cyan
    Write-Host "4. Manual download: https://ffmpeg.org/download.html" -ForegroundColor Cyan
    
    return $false
}

# Check for FFmpeg on module import
if (-not (Test-FFmpegInstalled)) {
    Write-Warning "FFmpeg is not found in PATH."
    
    $response = Read-Host "Would you like to attempt automatic installation? (Y/N)"
    if ($response -eq 'Y' -or $response -eq 'y') {
        $installed = Install-FFmpegDependency
        
        if ($installed) {
            # Refresh PATH in current session
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
            
            if (-not (Test-FFmpegInstalled)) {
                Write-Warning "FFmpeg was installed but not found in PATH. You may need to restart your PowerShell session."
            }
        }
    }
    else {
        Write-Host "FFmpeg installation skipped. Install manually to use this module." -ForegroundColor Yellow
    }
}

# Export the installation function for manual use
Export-ModuleMember -Function Install-FFmpegDependency

# TODO: Import actual FFmpeg wrapper functions here
# . $PSScriptRoot\Functions\Invoke-FFmpeg.ps1
# . $PSScriptRoot\Functions\ConvertTo-VideoFormat.ps1
# etc.
