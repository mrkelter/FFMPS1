# Chocolatey Packaging Guide for FFMPS1

## Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Package Structure](#package-structure)
4. [Step-by-Step Guide](#step-by-step-guide)
5. [File Examples](#file-examples)
6. [Testing Locally](#testing-locally)
7. [Publishing to Chocolatey.org](#publishing-to-chocolateyorg)
8. [CI/CD Automation](#cicd-automation)
9. [Best Practices](#best-practices)

## Overview

This guide covers creating a Chocolatey package for FFMPS1, a PowerShell module that wraps FFmpeg functionality. The package will:
- Install the PowerShell module to the appropriate location
- Declare FFmpeg as a dependency (Chocolatey will handle installation)
- Follow Chocolatey best practices for PowerShell modules
- Support automatic updates

## Prerequisites

### Required Tools
1. **Chocolatey** - Install if not already installed:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

2. **Chocolatey Package Builder Tools**:
   ```powershell
   choco install checksum -y
   ```

3. **API Key** - Get from [Chocolatey.org account](https://community.chocolatey.org/account) after registration

### Optional Tools
```powershell
choco install chocolatey-core.extension -y
```

## Package Structure

Create a directory structure for your Chocolatey package:

```
chocolatey/
├── ffmps1.nuspec
├── tools/
│   ├── chocolateyInstall.ps1
│   ├── chocolateyUninstall.ps1
│   └── VERIFICATION.txt
└── legal/
    ├── LICENSE.txt
    └── VERIFICATION.txt
```

## Step-by-Step Guide

### Step 1: Create Package Directory

```powershell
# Navigate to your project root
cd s:\git\ffmps1

# Create Chocolatey package structure
New-Item -ItemType Directory -Path "chocolatey\tools" -Force
New-Item -ItemType Directory -Path "chocolatey\legal" -Force
```

### Step 2: Create .nuspec File

The `.nuspec` file is the package manifest. See [File Examples](#file-examples) section below.

### Step 3: Create Installation Script

The `chocolateyInstall.ps1` script handles installation. See [File Examples](#file-examples) section below.

### Step 4: Create Uninstallation Script

The `chocolateyUninstall.ps1` script handles cleanup. See [File Examples](#file-examples) section below.

### Step 5: Add Legal Files

Copy your LICENSE and create VERIFICATION.txt for transparency.

### Step 6: Package the Chocolatey Package

```powershell
cd chocolatey
choco pack ffmps1.nuspec
```

This creates `ffmps1.1.0.0.nupkg` (version based on your nuspec).

## File Examples

### ffmps1.nuspec

```xml
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
  <metadata>
    <!-- Required -->
    <id>ffmps1</id>
    <version>1.0.0</version>
    <authors>mrkelter</authors>
    <description>PowerShell wrapper module for FFmpeg with full discoverability and parameter completion. Provides easy-to-use cmdlets for video/audio conversion, editing, and media manipulation.</description>
    
    <!-- Optional but recommended -->
    <title>FFMPS1 - FFmpeg PowerShell Wrapper</title>
    <owners>mrkelter</owners>
    <projectUrl>https://github.com/mrkelter/FFMPS1</projectUrl>
    <packageSourceUrl>https://github.com/mrkelter/FFMPS1/tree/main/chocolatey</packageSourceUrl>
    <docsUrl>https://github.com/mrkelter/FFMPS1#readme</docsUrl>
    <bugTrackerUrl>https://github.com/mrkelter/FFMPS1/issues</bugTrackerUrl>
    <tags>ffmpeg powershell video audio media conversion encoding cmdlet module</tags>
    <summary>PowerShell wrapper for FFmpeg with intuitive cmdlets</summary>
    <licenseUrl>https://github.com/mrkelter/FFMPS1/blob/main/LICENSE</licenseUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <iconUrl>https://rawcdn.githack.com/mrkelter/FFMPS1/main/icon.png</iconUrl>
    <releaseNotes>https://github.com/mrkelter/FFMPS1/releases/tag/v1.0.0</releaseNotes>
    
    <!-- Dependencies -->
    <dependencies>
      <dependency id="ffmpeg" version="4.4.1" />
      <dependency id="powershell" version="5.1.0" />
    </dependencies>
  </metadata>
  
  <files>
    <!-- Installation scripts -->
    <file src="tools\**" target="tools" />
    
    <!-- Legal files -->
    <file src="legal\**" target="legal" />
  </files>
</package>
```

### chocolateyInstall.ps1

```powershell
$ErrorActionPreference = 'Stop'

$packageName = 'ffmps1'
$moduleName = 'FFmpeg'  # The actual module name
$moduleVersion = '1.0.0'

# Get the module installation path
$modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleVersion"

Write-Host "Installing $packageName PowerShell module..." -ForegroundColor Cyan

# Create module directory
New-Item -ItemType Directory -Path $modulePath -Force | Out-Null

# GitHub release download
$url64 = "https://github.com/mrkelter/FFMPS1/releases/download/v$moduleVersion/FFMPS1-v$moduleVersion.zip"

# Alternative: Direct file download from GitHub
# $url64 = "https://github.com/mrkelter/FFMPS1/archive/refs/tags/v$moduleVersion.zip"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $modulePath
    url64bit       = $url64
    checksum64     = 'PASTE_CHECKSUM_HERE'  # Run: Get-FileHash -Algorithm SHA256 file.zip
    checksumType64 = 'sha256'
}

# Download and extract
Install-ChocolateyZipPackage @packageArgs

# Alternative: If not using a zip release, clone specific files
# This approach downloads individual files from GitHub
<#
$baseUrl = "https://raw.githubusercontent.com/mrkelter/FFMPS1/v$moduleVersion"
$files = @(
    'FFmpeg.psd1',
    'FFmpeg.psm1',
    'README.md'
)

foreach ($file in $files) {
    $downloadUrl = "$baseUrl/$file"
    $destination = Join-Path $modulePath $file
    
    Get-ChocolateyWebFile -PackageName $packageName `
                          -FileFullPath $destination `
                          -Url $downloadUrl `
                          -Url64bit $downloadUrl
}
#>

# Verify installation
$installedModule = Get-Module -ListAvailable -Name $moduleName | Where-Object { $_.Version -eq $moduleVersion }

if ($installedModule) {
    Write-Host "Successfully installed $packageName v$moduleVersion" -ForegroundColor Green
    Write-Host "Module location: $modulePath" -ForegroundColor Gray
    Write-Host ""
    Write-Host "To use the module, run:" -ForegroundColor Yellow
    Write-Host "  Import-Module $moduleName" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "To see available commands:" -ForegroundColor Yellow
    Write-Host "  Get-Command -Module $moduleName" -ForegroundColor Cyan
} else {
    throw "Module installation verification failed"
}

# Note: FFmpeg dependency is automatically handled by Chocolatey
Write-Host "FFmpeg dependency will be installed/verified by Chocolatey" -ForegroundColor Gray
```

### chocolateyUninstall.ps1

```powershell
$ErrorActionPreference = 'Stop'

$packageName = 'ffmps1'
$moduleName = 'FFmpeg'
$moduleVersion = '1.0.0'

Write-Host "Uninstalling $packageName PowerShell module..." -ForegroundColor Cyan

# Module installation paths to check
$modulePaths = @(
    "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleVersion",
    "$env:ProgramFiles\PowerShell\Modules\$moduleName\$moduleVersion"
)

foreach ($path in $modulePaths) {
    if (Test-Path $path) {
        Write-Host "Removing module from: $path" -ForegroundColor Yellow
        
        # Remove the module if it's loaded
        if (Get-Module -Name $moduleName) {
            Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        }
        
        # Remove the directory
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
        
        # If version directory is empty, remove parent
        $parentPath = Split-Path $path -Parent
        if ((Test-Path $parentPath) -and ((Get-ChildItem $parentPath).Count -eq 0)) {
            Remove-Item -Path $parentPath -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "Successfully uninstalled $packageName" -ForegroundColor Green

# Note: We don't uninstall FFmpeg as other packages might depend on it
Write-Host "Note: FFmpeg dependency is not removed (may be used by other packages)" -ForegroundColor Gray
```

### VERIFICATION.txt (in tools/ and legal/)

```
VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

Package can be verified like this:

1. Download the source code from GitHub:
   https://github.com/mrkelter/FFMPS1/releases/tag/v1.0.0

2. Extract and verify the files match the package contents

3. The checksum can be verified with:
   Get-FileHash -Algorithm SHA256 FFMPS1-v1.0.0.zip

Expected SHA256: [YOUR_CHECKSUM_HERE]
```

### LICENSE.txt (in legal/)

Copy your repository's LICENSE file here.

## Testing Locally

### Test Installation

```powershell
# Navigate to chocolatey directory
cd s:\git\ffmps1\chocolatey

# Pack the package
choco pack ffmps1.nuspec

# Install locally (test installation)
choco install ffmps1 -source . -force -y

# Verify the module is available
Get-Module -ListAvailable FFmpeg
Import-Module FFmpeg
Get-Command -Module FFmpeg

# Test a command
# Example: Get-MediaInfo -Path "test.mp4"
```

### Test Uninstallation

```powershell
# Uninstall the package
choco uninstall ffmps1 -y

# Verify module is removed
Get-Module -ListAvailable FFmpeg
```

### Test in a Clean Environment

Use a Windows Sandbox or VM for testing:

```powershell
# In a fresh environment
choco install ffmps1 -source "C:\path\to\your\package" -y

# Test functionality
Import-Module FFmpeg
# Run your module commands
```

## Publishing to Chocolatey.org

### Step 1: Create Chocolatey Account

1. Go to [Chocolatey.org](https://community.chocolatey.org/)
2. Sign up for an account
3. Navigate to your account settings
4. Copy your API key

### Step 2: Set API Key Locally

```powershell
# Set your API key (only need to do once)
choco apikey --key YOUR_API_KEY_HERE --source https://push.chocolatey.org/
```

### Step 3: Prepare Package for Publication

```powershell
# Ensure package is built
cd s:\git\ffmps1\chocolatey
choco pack ffmps1.nuspec

# Validate the package
choco install ffmps1 -source . --debug --verbose
```

### Step 4: Push to Chocolatey.org

```powershell
# Push the package
choco push ffmps1.1.0.0.nupkg --source https://push.chocolatey.org/

# Alternative: Specify API key inline
choco push ffmps1.1.0.0.nupkg --source https://push.chocolatey.org/ --api-key YOUR_API_KEY
```

### Step 5: Package Review Process

1. **Initial Submission**: Package enters moderation queue
2. **Automated Tests**: Chocolatey runs automated validation
3. **Manual Review**: Moderators review your package (can take 1-7 days)
4. **Feedback**: You may receive feedback for improvements
5. **Approval**: Once approved, package becomes publicly available

### Step 6: Monitor Package Status

Check package status at: `https://community.chocolatey.org/packages/ffmps1`

## CI/CD Automation

### GitHub Actions Workflow

Create `.github/workflows/chocolatey-publish.yml`:

```yaml
name: Publish to Chocolatey

on:
  release:
    types: [published]
  workflow_dispatch:

jobs:
  publish-chocolatey:
    runs-on: windows-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Get version from release
      id: get_version
      shell: pwsh
      run: |
        if ($env:GITHUB_REF -match 'refs/tags/v(.+)') {
          $version = $matches[1]
        } else {
          $version = "1.0.0"
        }
        echo "VERSION=$version" >> $env:GITHUB_OUTPUT
        
    - name: Create release archive
      shell: pwsh
      run: |
        $version = "${{ steps.get_version.outputs.VERSION }}"
        Compress-Archive -Path FFmpeg.psd1, FFmpeg.psm1, README.md `
                         -DestinationPath "FFMPS1-v$version.zip"
        
    - name: Calculate checksum
      id: checksum
      shell: pwsh
      run: |
        $version = "${{ steps.get_version.outputs.VERSION }}"
        $hash = (Get-FileHash -Algorithm SHA256 "FFMPS1-v$version.zip").Hash
        echo "CHECKSUM=$hash" >> $env:GITHUB_OUTPUT
        echo "Checksum: $hash"
        
    - name: Update nuspec version
      shell: pwsh
      run: |
        $version = "${{ steps.get_version.outputs.VERSION }}"
        $nuspec = Get-Content chocolatey/ffmps1.nuspec -Raw
        $nuspec = $nuspec -replace '<version>.*</version>', "<version>$version</version>"
        $nuspec | Set-Content chocolatey/ffmps1.nuspec
        
    - name: Update install script checksum
      shell: pwsh
      run: |
        $checksum = "${{ steps.checksum.outputs.CHECKSUM }}"
        $install = Get-Content chocolatey/tools/chocolateyInstall.ps1 -Raw
        $install = $install -replace 'PASTE_CHECKSUM_HERE', $checksum
        $install | Set-Content chocolatey/tools/chocolateyInstall.ps1
        
    - name: Install Chocolatey
      shell: pwsh
      run: |
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
    - name: Pack Chocolatey package
      shell: pwsh
      run: |
        cd chocolatey
        choco pack ffmps1.nuspec
        
    - name: Test package locally
      shell: pwsh
      run: |
        cd chocolatey
        choco install ffmps1 -source . -force -y
        Get-Module -ListAvailable FFmpeg
        
    - name: Push to Chocolatey
      if: github.event_name == 'release'
      shell: pwsh
      env:
        CHOCO_API_KEY: ${{ secrets.CHOCOLATEY_API_KEY }}
      run: |
        cd chocolatey
        choco apikey --key $env:CHOCO_API_KEY --source https://push.chocolatey.org/
        choco push ffmps1.*.nupkg --source https://push.chocolatey.org/
        
    - name: Upload package as artifact
      uses: actions/upload-artifact@v4
      with:
        name: chocolatey-package
        path: chocolatey/*.nupkg
```

### Setup GitHub Secrets

1. Go to your GitHub repository settings
2. Navigate to Secrets and variables → Actions
3. Add secret: `CHOCOLATEY_API_KEY` with your Chocolatey API key

### Azure DevOps Pipeline

Create `azure-pipelines.yml`:

```yaml
trigger:
  tags:
    include:
    - v*

pool:
  vmImage: 'windows-latest'

variables:
  version: ''

steps:
- pwsh: |
    $version = "$(Build.SourceBranchName)" -replace '^v', ''
    Write-Host "##vso[task.setvariable variable=version]$version"
  displayName: 'Extract Version'

- pwsh: |
    Compress-Archive -Path FFmpeg.psd1, FFmpeg.psm1, README.md `
                     -DestinationPath "FFMPS1-v$(version).zip"
  displayName: 'Create Release Archive'

- pwsh: |
    $hash = (Get-FileHash -Algorithm SHA256 "FFMPS1-v$(version).zip").Hash
    Write-Host "##vso[task.setvariable variable=checksum]$hash"
  displayName: 'Calculate Checksum'

- pwsh: |
    choco pack chocolatey/ffmps1.nuspec
  displayName: 'Pack Chocolatey Package'

- task: PublishBuildArtifacts@1
  inputs:
    pathToPublish: '$(Build.SourcesDirectory)/chocolatey'
    artifactName: 'chocolatey-package'

- pwsh: |
    choco apikey --key $(CHOCO_API_KEY) --source https://push.chocolatey.org/
    choco push chocolatey/*.nupkg --source https://push.chocolatey.org/
  displayName: 'Push to Chocolatey'
  env:
    CHOCO_API_KEY: $(ChocolateyApiKey)
```

## Best Practices

### 1. Versioning

- **Semantic Versioning**: Use SemVer (MAJOR.MINOR.PATCH)
- **Sync Versions**: Keep PowerShell module version in sync with Chocolatey package
- **Release Tags**: Create Git tags for each version (e.g., `v1.0.0`)

```powershell
# Update version in multiple files
$newVersion = "1.0.1"

# Update .psd1
$psd1 = Get-Content FFmpeg.psd1 -Raw
$psd1 = $psd1 -replace "ModuleVersion = '[\d.]+'", "ModuleVersion = '$newVersion'"
$psd1 | Set-Content FFmpeg.psd1

# Update .nuspec
$nuspec = Get-Content chocolatey/ffmps1.nuspec -Raw
$nuspec = $nuspec -replace '<version>[\d.]+</version>', "<version>$newVersion</version>"
$nuspec | Set-Content chocolatey/ffmps1.nuspec
```

### 2. Dependencies

**Chocolatey Dependency Declaration**:
```xml
<dependencies>
  <!-- Specify minimum version -->
  <dependency id="ffmpeg" version="4.4.1" />
  
  <!-- Or version range -->
  <dependency id="ffmpeg" version="[4.4.1,6.0)" />
  
  <!-- PowerShell version -->
  <dependency id="powershell" version="5.1.0" />
</dependencies>
```

**PowerShell Module Dependencies** (in .psd1):
```powershell
RequiredModules = @()  # Other PowerShell modules
PowerShellVersion = '5.1'
```

### 3. File Organization

**Recommended structure**:
```
Repository Root/
├── FFmpeg.psd1
├── FFmpeg.psm1
├── Functions/
│   ├── Public/
│   └── Private/
├── chocolatey/
│   ├── ffmps1.nuspec
│   ├── tools/
│   │   ├── chocolateyInstall.ps1
│   │   ├── chocolateyUninstall.ps1
│   │   └── VERIFICATION.txt
│   └── legal/
│       ├── LICENSE.txt
│       └── VERIFICATION.txt
└── .github/
    └── workflows/
        └── chocolatey-publish.yml
```

### 4. Installation Location

**Best Practice**: Install to system-wide module path for all users
```powershell
$modulePath = "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleVersion"
```

**Alternative**: User-specific installation
```powershell
$modulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$moduleName\$moduleVersion"
```

### 5. Security & Checksums

**Always include checksums**:
```powershell
# Generate checksum
Get-FileHash -Algorithm SHA256 FFMPS1-v1.0.0.zip

# In chocolateyInstall.ps1
$packageArgs = @{
    checksum64     = 'ABC123...'
    checksumType64 = 'sha256'
}
```

### 6. Testing Checklist

Before publishing:
- [ ] Test installation on clean system
- [ ] Test uninstallation completely removes files
- [ ] Verify FFmpeg dependency installs correctly
- [ ] Test all module functions work after Chocolatey install
- [ ] Check module loads without errors
- [ ] Verify version numbers match across all files
- [ ] Run `choco pack` without warnings
- [ ] Test with `--debug --verbose` flags

### 7. Documentation

Include in package:
- README with usage examples
- LICENSE file
- VERIFICATION.txt for transparency
- CHANGELOG for version history
- Inline comments in installation scripts

### 8. Update Strategy

**For updates**:
```powershell
# 1. Update module version
# 2. Create new release on GitHub
# 3. Update chocolatey package version
# 4. Update checksums
# 5. Test locally
# 6. Push to Chocolatey

# Automated with CI/CD
git tag v1.0.1
git push origin v1.0.1
# GitHub Actions handles the rest
```

### 9. Icon and Branding

```xml
<!-- In .nuspec -->
<iconUrl>https://rawcdn.githack.com/mrkelter/FFMPS1/main/icon.png</iconUrl>
```

Create a 128x128 or 256x256 PNG icon for your package.

### 10. Support Multiple PowerShell Versions

```powershell
# In chocolateyInstall.ps1
$modulePaths = @()

# Windows PowerShell 5.1
if (Test-Path "$env:ProgramFiles\WindowsPowerShell\Modules") {
    $modulePaths += "$env:ProgramFiles\WindowsPowerShell\Modules\$moduleName\$moduleVersion"
}

# PowerShell 7+
if (Test-Path "$env:ProgramFiles\PowerShell\Modules") {
    $modulePaths += "$env:ProgramFiles\PowerShell\Modules\$moduleName\$moduleVersion"
}

# Install to all applicable locations
foreach ($path in $modulePaths) {
    # Installation logic
}
```

## Quick Reference Commands

### Package Creation
```powershell
# Create package structure
mkdir chocolatey\tools, chocolatey\legal

# Create nuspec
choco new ffmps1

# Pack package
choco pack chocolatey\ffmps1.nuspec
```

### Local Testing
```powershell
# Install from local package
choco install ffmps1 -source . -force -y

# Uninstall
choco uninstall ffmps1 -y

# Test with verbose output
choco install ffmps1 -source . -debug -verbose
```

### Publishing
```powershell
# Set API key (one time)
choco apikey --key YOUR_KEY --source https://push.chocolatey.org/

# Push package
choco push ffmps1.1.0.0.nupkg --source https://push.chocolatey.org/
```

### Utilities
```powershell
# Generate checksum
Get-FileHash -Algorithm SHA256 file.zip

# List installed packages
choco list --local-only

# Get package info
choco info ffmps1
```

## Troubleshooting

### Package Won't Install
- Check all file paths are correct
- Verify checksums match
- Test URLs are accessible
- Check PowerShell version requirements

### Module Not Found After Install
- Verify installation path
- Check $env:PSModulePath includes install location
- Restart PowerShell session
- Run `Get-Module -ListAvailable` to verify

### Chocolatey Moderation Issues
- Ensure all URLs are accessible
- Include proper LICENSE and VERIFICATION files
- Add detailed description
- Follow naming conventions
- Respond promptly to moderator feedback

### FFmpeg Dependency Not Installing
- Verify dependency declaration in .nuspec
- Check FFmpeg package exists: `choco info ffmpeg`
- Test dependency chain: `choco install ffmps1 --debug`

## Additional Resources

- [Chocolatey Documentation](https://docs.chocolatey.org/)
- [Creating Chocolatey Packages](https://docs.chocolatey.org/en-us/create/create-packages)
- [Chocolatey Package Validator](https://github.com/chocolatey/package-validator)
- [PowerShell Gallery](https://www.powershellgallery.com/) - Alternative distribution
- [Community Package Repository](https://community.chocolatey.org/packages)

---

**Next Steps:**
1. Create the package structure
2. Customize the templates above for your specific needs
3. Test locally thoroughly
4. Set up CI/CD for automated releases
5. Submit to Chocolatey.org

Good luck with your FFMPS1 Chocolatey package! 🚀
