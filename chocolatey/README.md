# Quick Start Guide - Chocolatey Package

This is a quick reference for common Chocolatey packaging tasks for FFMPS1.

## Prerequisites

```powershell
# Install Chocolatey (if not already installed)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

## Local Testing

### Build and Test Package

```powershell
# Navigate to chocolatey directory
cd s:\git\ffmps1\chocolatey

# Build the package
choco pack ffmps1.nuspec

# Test installation locally
choco install ffmps1 -source . -force -y

# Verify module
Import-Module FFmpeg
Get-Command -Module FFmpeg

# Test uninstall
choco uninstall ffmps1 -y
```

### Test with Debugging

```powershell
# Detailed output
choco install ffmps1 -source . -force -y --debug --verbose

# Check for errors
choco install ffmps1 -source . -force -y 2>&1 | Out-File test-install.log
```

## Publishing to Chocolatey.org

### One-Time Setup

1. Create account at [Chocolatey.org](https://community.chocolatey.org/)
2. Get API key from [account page](https://community.chocolatey.org/account)
3. Set API key locally:

```powershell
choco apikey --key YOUR_API_KEY_HERE --source https://push.chocolatey.org/
```

### Publish Package

```powershell
# Build package
cd s:\git\ffmps1\chocolatey
choco pack ffmps1.nuspec

# Push to Chocolatey.org
choco push ffmps1.1.0.0.nupkg --source https://push.chocolatey.org/
```

## Version Updates

### Update All Version Numbers

```powershell
# Set new version
$newVersion = "1.0.1"

# Update module manifest
$psd1 = Get-Content ..\FFmpeg.psd1 -Raw
$psd1 = $psd1 -replace "ModuleVersion = '[\d.]+'", "ModuleVersion = '$newVersion'"
$psd1 | Set-Content ..\FFmpeg.psd1

# Update nuspec
$nuspec = Get-Content ffmps1.nuspec -Raw
$nuspec = $nuspec -replace '<version>[\d.]+</version>', "<version>$newVersion</version>"
$nuspec | Set-Content ffmps1.nuspec

# Update install script
$install = Get-Content tools\chocolateyInstall.ps1 -Raw
$install = $install -replace '\$moduleVersion = ''[\d.]+''', "`$moduleVersion = '$newVersion'"
$install | Set-Content tools\chocolateyInstall.ps1

# Update uninstall script
$uninstall = Get-Content tools\chocolateyUninstall.ps1 -Raw
$uninstall = $uninstall -replace '\$moduleVersion = ''[\d.]+''', "`$moduleVersion = '$newVersion'"
$uninstall | Set-Content tools\chocolateyUninstall.ps1
```

## GitHub Actions Setup

### Configure Secrets

1. Go to repository Settings → Secrets and variables → Actions
2. Add secret: `CHOCOLATEY_API_KEY` with your API key

### Create Release

```powershell
# Commit changes
git add .
git commit -m "Release v1.0.0"

# Create and push tag
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions will automatically:
# - Build the package
# - Test it locally
# - Push to Chocolatey.org
```

### Manual Workflow Trigger

Can also trigger manually from GitHub Actions tab with custom version.

## Common Commands

```powershell
# List local packages
choco list --local-only

# Get package info
choco info ffmps1

# Search Chocolatey.org
choco search ffmps1

# Install from Chocolatey.org (after published)
choco install ffmps1

# Upgrade package
choco upgrade ffmps1

# Uninstall
choco uninstall ffmps1
```

## Troubleshooting

### Module Not Found After Install

```powershell
# Check installation path
Get-Module -ListAvailable FFmpeg

# Check module paths
$env:PSModulePath -split ';'

# Refresh module cache
Import-Module FFmpeg -Force

# Restart PowerShell
```

### Package Build Errors

```powershell
# Validate nuspec
choco pack ffmps1.nuspec --debug

# Check file structure
Get-ChildItem . -Recurse
```

### Permission Issues

```powershell
# Run PowerShell as Administrator
# Or use user-specific module path in chocolateyInstall.ps1
```

## File Structure Reference

```
chocolatey/
├── ffmps1.nuspec                    # Package manifest
├── tools/
│   ├── chocolateyInstall.ps1        # Installation script
│   ├── chocolateyUninstall.ps1      # Uninstall script
│   └── VERIFICATION.txt             # Verification info
└── legal/
    ├── LICENSE.txt                  # License
    └── VERIFICATION.txt             # Legal verification
```

## Next Steps

1. ✅ Test package locally
2. ✅ Review all files
3. ✅ Update version numbers
4. ✅ Commit to Git
5. ✅ Create GitHub release
6. ✅ Verify GitHub Actions workflow
7. ✅ Monitor Chocolatey moderation queue

---

For complete documentation, see [CHOCOLATEY_PACKAGING_GUIDE.md](CHOCOLATEY_PACKAGING_GUIDE.md)
