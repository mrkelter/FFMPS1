# Publishing Guide for FFMPS1

## Overview
This module can be published to three different package repositories:
1. **PowerShell Gallery** - Primary distribution for PowerShell modules
2. **GitHub Releases** - For manual downloads and versioned archives
3. **Chocolatey** - Windows package manager distribution

## Prerequisites

### 1. PowerShell Gallery
- Create account at https://www.powershellgallery.com/
- Generate API key from your account settings
- Add to GitHub secrets as `PSGALLERY_API_KEY`

### 2. Chocolatey (Optional)
- Create account at https://community.chocolatey.org/
- Generate API key from account settings
- Add to GitHub secrets as `CHOCOLATEY_API_KEY`

### 3. GitHub Repository Secrets
Navigate to: `Settings > Secrets and variables > Actions > New repository secret`

Add these secrets:
- `PSGALLERY_API_KEY` - Your PowerShell Gallery API key
- `CHOCOLATEY_API_KEY` - Your Chocolatey API key (optional)

## Publishing Methods

### Automatic Publishing (via GitHub Actions)

The workflow automatically publishes when you create a GitHub release:

```powershell
# 1. Update version in FFmpeg.psd1 (ModuleVersion field)
# 2. Commit and push changes
git add FFmpeg.psd1
git commit -m "Bump version to 1.0.1"
git push

# 3. Create and push a tag
git tag v1.0.1
git push origin v1.0.1

# 4. Create GitHub release (via web UI or CLI)
gh release create v1.0.1 --title "v1.0.1" --notes "Release notes here"
```

The workflow will automatically:
- ✅ Validate module manifest
- ✅ Run tests (if present)
- ✅ Publish to PowerShell Gallery
- ✅ Create downloadable .zip file
- ✅ Attach .zip to GitHub release
- ✅ Build and publish Chocolatey package (if configured)

### Manual Publishing

#### PowerShell Gallery
```powershell
# Test the manifest first
Test-ModuleManifest -Path .\FFmpeg.psd1

# Publish
Publish-Module -Path . -NuGetApiKey "YOUR_API_KEY" -Verbose
```

#### GitHub Release
```powershell
# Create package
$version = (Test-ModuleManifest .\FFmpeg.psd1).Version
$packageName = "FFMPS1-$version"
New-Item -ItemType Directory -Path $packageName
Copy-Item FFmpeg.* $packageName\
Compress-Archive -Path $packageName -DestinationPath "$packageName.zip"

# Create release
gh release create v$version --title "v$version" --notes "Release notes"
gh release upload v$version "$packageName.zip"
```

#### Chocolatey
```powershell
# Build package
cd chocolatey
choco pack ffmps1.nuspec

# Test locally
choco install ffmps1 -source . -force -y

# Publish
choco apikey --key YOUR_API_KEY --source https://push.chocolatey.org/
choco push ffmps1.1.0.0.nupkg --source https://push.chocolatey.org/
```

## Version Management

Always update version in these locations:
1. `FFmpeg.psd1` - ModuleVersion field
2. `chocolatey/ffmps1.nuspec` - version element (if using Chocolatey)

The GitHub Actions workflow handles synchronization automatically.

## Testing Before Publishing

```powershell
# 1. Test manifest
Test-ModuleManifest -Path .\FFmpeg.psd1

# 2. Import module locally
Import-Module .\FFmpeg.psd1 -Force

# 3. Run tests (create Tests directory with Pester tests)
Invoke-Pester -Path .\Tests

# 4. Test installation from local source
Publish-Module -Path . -Repository LocalRepo -NuGetApiKey "test"
Install-Module FFMPS1 -Repository LocalRepo
```

## First-Time Setup Checklist

- [ ] Update module metadata in `FFmpeg.psd1`
- [ ] Add LICENSE file (already created)
- [ ] Update README.md with usage examples
- [ ] Create PowerShell Gallery account and get API key
- [ ] Add `PSGALLERY_API_KEY` to GitHub secrets
- [ ] (Optional) Create Chocolatey account and get API key
- [ ] (Optional) Add `CHOCOLATEY_API_KEY` to GitHub secrets
- [ ] Test module locally
- [ ] Create first release

## Monitoring

- **PowerShell Gallery**: https://www.powershellgallery.com/packages/FFMPS1
- **GitHub Releases**: https://github.com/mrkelter/FFMPS1/releases
- **Chocolatey**: https://community.chocolatey.org/packages/ffmps1

## Troubleshooting

### Module not found on PowerShell Gallery
- Wait 10-15 minutes after publishing
- Check for errors in GitHub Actions workflow
- Verify API key is correct

### GitHub Actions failing
- Check that secrets are properly set
- Review workflow run logs in Actions tab
- Ensure version numbers match between manifest and tags

### Chocolatey validation errors
- Run `choco pack --validate` locally
- Check that all files referenced in nuspec exist
- Verify chocolateyInstall.ps1 syntax
