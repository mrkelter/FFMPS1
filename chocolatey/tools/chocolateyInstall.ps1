$ErrorActionPreference = 'Stop'

$packageName = 'ffmps1'
$moduleName = 'FFmpeg'  # The actual module name from FFmpeg.psd1
$moduleVersion = '1.0.0'

Write-Host "Installing $packageName PowerShell module..." -ForegroundColor Cyan

# Determine installation paths for both Windows PowerShell and PowerShell Core
$installPaths = @()

# Windows PowerShell 5.1 path
$psModulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleVersion"
if (Test-Path "$env:ProgramFiles\WindowsPowerShell\Modules") {
    $installPaths += $psModulePath
}

# PowerShell 7+ path (if installed)
$ps7ModulePath = "$env:ProgramFiles\PowerShell\Modules\$moduleName\$moduleVersion"
if (Test-Path "$env:ProgramFiles\PowerShell\Modules") {
    $installPaths += $ps7ModulePath
}

# Use primary path for installation
$modulePath = $installPaths[0]

# Create module directory
Write-Host "Creating module directory: $modulePath" -ForegroundColor Gray
New-Item -ItemType Directory -Path $modulePath -Force | Out-Null

# Option 1: Download from GitHub Release (Recommended for production)
# Uncomment and update when you create a release with a ZIP file
<#
$url64 = "https://github.com/mrkelter/FFMPS1/releases/download/v$moduleVersion/FFMPS1-v$moduleVersion.zip"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $modulePath
    url64bit       = $url64
    checksum64     = 'PASTE_CHECKSUM_HERE'  # Run: Get-FileHash -Algorithm SHA256 FFMPS1-v1.0.0.zip
    checksumType64 = 'sha256'
}

Install-ChocolateyZipPackage @packageArgs
#>

# Option 2: Download individual files from GitHub (current implementation)
# This downloads the files directly from the repository
$baseUrl = "https://raw.githubusercontent.com/mrkelter/FFMPS1/main"
$files = @{
    'FFmpeg.psd1' = "$baseUrl/FFmpeg.psd1"
    'FFmpeg.psm1' = "$baseUrl/FFmpeg.psm1"
    'README.md'   = "$baseUrl/README.md"
}

foreach ($file in $files.GetEnumerator()) {
    $fileName = $file.Key
    $downloadUrl = $file.Value
    $destination = Join-Path $modulePath $fileName
    
    Write-Host "Downloading $fileName..." -ForegroundColor Gray
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($downloadUrl, $destination)
        Write-Host "  Downloaded: $fileName" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to download $fileName from $downloadUrl : $_"
        throw
    }
}

# Copy to additional PowerShell paths if they exist
foreach ($additionalPath in $installPaths | Select-Object -Skip 1) {
    Write-Host "Copying module to: $additionalPath" -ForegroundColor Gray
    New-Item -ItemType Directory -Path $additionalPath -Force | Out-Null
    Copy-Item -Path "$modulePath\*" -Destination $additionalPath -Recurse -Force
}

# Verify installation
Write-Host "Verifying installation..." -ForegroundColor Gray
$installedModule = Get-Module -ListAvailable -Name $moduleName | Where-Object { $_.Version -eq $moduleVersion }

if ($installedModule) {
    Write-Host ""
    Write-Host "Successfully installed $packageName v$moduleVersion" -ForegroundColor Green
    Write-Host "Module location: $modulePath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Available commands:" -ForegroundColor Yellow
    Write-Host "  Import-Module $moduleName" -ForegroundColor Cyan
    Write-Host "  Get-Command -Module $moduleName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Example usage:" -ForegroundColor Yellow
    Write-Host "  ConvertTo-VideoFormat -InputPath input.mp4 -OutputPath output.avi" -ForegroundColor Cyan
    Write-Host "  Get-MediaInfo -Path video.mp4" -ForegroundColor Cyan
    Write-Host "  Extract-Audio -VideoPath video.mp4 -OutputPath audio.mp3" -ForegroundColor Cyan
    Write-Host ""
} else {
    throw "Module installation verification failed. Module not found in expected location."
}

# FFmpeg dependency information
Write-Host "FFmpeg dependency:" -ForegroundColor Yellow
Write-Host "  FFmpeg will be automatically installed/verified by Chocolatey" -ForegroundColor Gray
Write-Host "  If FFmpeg is not already installed, Chocolatey is installing it now..." -ForegroundColor Gray
Write-Host ""
Write-Host "Installation complete! 🎉" -ForegroundColor Green
