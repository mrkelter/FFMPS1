# Install-FFmpeg

## Synopsis
Installs FFmpeg using available package managers (Chocolatey, Scoop, or winget).

## Description
This helper function attempts to install FFmpeg automatically using one of the common Windows package managers. It tries them in order: Chocolatey, Scoop, then winget.

If no package manager is available, it provides manual installation instructions.

## Syntax
```powershell
Install-FFmpegDependency
```

## Examples

### Example 1
```powershell
Install-FFmpegDependency
```
Attempts to install FFmpeg using available package managers.

## Notes
- The module will prompt to install FFmpeg automatically on first import if it's not found
- You can also run this function manually at any time
- After installation, you may need to restart your PowerShell session to update the PATH

## Manual Installation Options

If automatic installation fails, you can install FFmpeg manually:

1. **Chocolatey**
   ```powershell
   choco install ffmpeg
   ```

2. **Scoop**
   ```powershell
   scoop install ffmpeg
   ```

3. **winget**
   ```powershell
   winget install Gyan.FFmpeg
   ```

4. **Manual Download**
   - Download from: https://ffmpeg.org/download.html
   - Extract to a folder
   - Add the folder to your system PATH
