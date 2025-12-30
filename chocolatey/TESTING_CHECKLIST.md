# Chocolatey Package Testing Checklist

Use this checklist before publishing to Chocolatey.org to ensure quality.

## Pre-Build Checks

- [ ] All version numbers are synchronized
  - [ ] FFmpeg.psd1 ModuleVersion
  - [ ] ffmps1.nuspec version
  - [ ] chocolateyInstall.ps1 $moduleVersion
  - [ ] chocolateyUninstall.ps1 $moduleVersion
  - [ ] Release notes URL in nuspec

- [ ] LICENSE file is up to date
- [ ] README.md is current
- [ ] VERIFICATION.txt files are accurate
- [ ] All URLs in scripts point to correct locations
- [ ] GitHub release tag matches version (if using releases)

## Build Process

- [ ] Navigate to chocolatey directory
  ```powershell
  cd s:\git\ffmps1\chocolatey
  ```

- [ ] Build package successfully
  ```powershell
  choco pack ffmps1.nuspec
  ```

- [ ] No warnings during pack
- [ ] .nupkg file created with correct version

## Local Installation Test

- [ ] Install from local source
  ```powershell
  choco install ffmps1 -source . -force -y
  ```

- [ ] Installation completes without errors
- [ ] Module appears in module list
  ```powershell
  Get-Module -ListAvailable FFmpeg
  ```

- [ ] Module imports successfully
  ```powershell
  Import-Module FFmpeg
  ```

- [ ] Functions are available
  ```powershell
  Get-Command -Module FFmpeg
  ```

- [ ] FFmpeg dependency installed
  ```powershell
  choco list ffmpeg --local-only
  ```

- [ ] FFmpeg is in PATH
  ```powershell
  ffmpeg -version
  ```

## Functionality Tests

Run a few key functions to verify:

- [ ] Basic function works
  ```powershell
  # Test with your actual functions
  # Get-MediaInfo -Path "test.mp4"
  ```

- [ ] FFmpeg wrapper executes
  ```powershell
  # Invoke-FFmpeg -Arguments "-version"
  ```

- [ ] No error messages in console
- [ ] Module help is available
  ```powershell
  Get-Help Get-MediaInfo
  ```

## Uninstall Test

- [ ] Uninstall package
  ```powershell
  choco uninstall ffmps1 -y
  ```

- [ ] Module removed from file system
  ```powershell
  Test-Path "$env:ProgramFiles\WindowsPowerShell\Modules\FFmpeg"
  ```

- [ ] Module not in module list
  ```powershell
  Get-Module -ListAvailable FFmpeg
  ```

- [ ] No leftover directories
- [ ] FFmpeg remains installed (dependency not removed)

## Clean Environment Test

Test in a fresh environment (Windows Sandbox, VM, or clean container):

- [ ] Install Chocolatey on clean system
- [ ] Install ffmps1 package
  ```powershell
  choco install ffmps1 -source "\\network\path\to\package" -y
  ```

- [ ] Verify all functionality
- [ ] Check for missing dependencies
- [ ] Verify PowerShell 5.1 compatibility
- [ ] Test in PowerShell 7 if available

## Debug Test

- [ ] Install with verbose output
  ```powershell
  choco install ffmps1 -source . -force -y --debug --verbose
  ```

- [ ] Review debug output for issues
- [ ] Check for deprecation warnings
- [ ] Verify all paths are correct

## Package Quality Checks

- [ ] Package description is clear and helpful
- [ ] Tags are relevant and accurate
- [ ] Project URL is accessible
- [ ] Documentation URL works
- [ ] Bug tracker URL is correct
- [ ] Release notes are meaningful
- [ ] License URL is accessible

## Chocolatey.org Requirements

- [ ] Package ID follows naming conventions (lowercase)
- [ ] Version follows semantic versioning
- [ ] Dependencies are correctly specified
- [ ] No hardcoded paths to user directories
- [ ] Install location is appropriate
- [ ] Uninstall is clean and complete
- [ ] VERIFICATION.txt is comprehensive
- [ ] Package doesn't require admin rights unnecessarily

## Pre-Publication

- [ ] Tested on Windows 10
- [ ] Tested on Windows 11 (if available)
- [ ] All tests passed
- [ ] Documentation reviewed
- [ ] Git repository is up to date
- [ ] GitHub release created (if applicable)
- [ ] API key is configured
  ```powershell
  choco apikey --key YOUR_KEY --source https://push.chocolatey.org/
  ```

## Publication

- [ ] Push package to Chocolatey.org
  ```powershell
  choco push ffmps1.1.0.0.nupkg --source https://push.chocolatey.org/
  ```

- [ ] Submission confirmed
- [ ] Package enters moderation queue
- [ ] Monitor email for moderator feedback

## Post-Publication

- [ ] Respond to any moderator feedback promptly
- [ ] Update package based on feedback if needed
- [ ] Once approved, test installation from Chocolatey.org
  ```powershell
  choco install ffmps1
  ```

- [ ] Update documentation with install instructions
- [ ] Announce release (optional)
- [ ] Monitor for user feedback/issues

## Continuous Monitoring

- [ ] Check package page periodically
  - https://community.chocolatey.org/packages/ffmps1

- [ ] Monitor GitHub issues for package-related problems
- [ ] Keep package updated with module versions
- [ ] Respond to community questions

---

## Quick Test Script

Save and run this script for automated basic testing:

```powershell
# quick-test.ps1
$ErrorActionPreference = 'Stop'

Write-Host "Building package..." -ForegroundColor Cyan
choco pack ffmps1.nuspec

Write-Host "`nInstalling package..." -ForegroundColor Cyan
choco install ffmps1 -source . -force -y

Write-Host "`nVerifying installation..." -ForegroundColor Cyan
$module = Get-Module -ListAvailable FFmpeg
if ($module) {
    Write-Host "✓ Module found: $($module.Name) v$($module.Version)" -ForegroundColor Green
} else {
    Write-Error "✗ Module not found!"
}

Import-Module FFmpeg
$commands = Get-Command -Module FFmpeg
Write-Host "✓ Found $($commands.Count) commands" -ForegroundColor Green

Write-Host "`nUninstalling package..." -ForegroundColor Cyan
choco uninstall ffmps1 -y

$moduleAfter = Get-Module -ListAvailable FFmpeg
if (-not $moduleAfter) {
    Write-Host "✓ Module removed successfully" -ForegroundColor Green
} else {
    Write-Warning "Module still present after uninstall"
}

Write-Host "`nAll tests passed!" -ForegroundColor Green
```

Run with:
```powershell
cd s:\git\ffmps1\chocolatey
.\quick-test.ps1
```
