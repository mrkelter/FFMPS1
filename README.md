# FFMPS1 - FFmpeg PowerShell Module

A comprehensive PowerShell wrapper for FFmpeg with full discoverability, parameter completion, and automatic dependency installation.

## Features

- 🎬 **32 FFmpeg wrapper functions** covering video/audio conversion, editing, and analysis
- 🔍 **Full IntelliSense support** with parameter completion
- 📦 **Automatic FFmpeg installation** via Chocolatey, Scoop, or winget
- 🎯 **Intuitive cmdlet names** following PowerShell conventions
- 🛠️ **Easy to use** - no need to memorize FFmpeg command syntax

## Installation

### From PowerShell Gallery (Recommended)
```powershell
Install-Module -Name FFMPS1 -Scope CurrentUser
```

### From Chocolatey
```powershell
choco install ffmps1
```

### From GitHub
```powershell
# Download latest release
Invoke-WebRequest -Uri "https://github.com/mrkelter/FFMPS1/releases/latest/download/FFMPS1-1.0.0.zip" -OutFile "FFMPS1.zip"
Expand-Archive -Path "FFMPS1.zip" -DestinationPath "$env:USERPROFILE\Documents\PowerShell\Modules\FFMPS1"
Import-Module FFMPS1
```

## FFmpeg Dependency

FFmpeg is required but will be automatically installed on first module import if not found.

### Manual Installation
If automatic installation fails, install FFmpeg manually:

```powershell
# Chocolatey
choco install ffmpeg

# Scoop
scoop install ffmpeg

# winget
winget install Gyan.FFmpeg

# Or call the module's helper function
Install-FFmpegDependency
```

## Available Functions

### Video Conversion & Encoding
- `ConvertTo-VideoFormat` - Convert videos between formats
- `Convert-VideoCodec` - Change video codec
- `Optimize-VideoForWeb` - Optimize videos for web streaming

### Video Editing
- `Trim-Video` - Cut video segments
- `Split-Video` - Split video into multiple parts
- `Merge-Video` - Combine multiple videos
- `Crop-Video` - Crop video dimensions
- `Rotate-Video` - Rotate video orientation
- `Resize-Video` - Resize video resolution
- `Adjust-VideoSpeed` - Change playback speed

### Audio Operations
- `ConvertTo-AudioFormat` - Convert audio formats
- `Extract-Audio` - Extract audio from video
- `Add-AudioToVideo` - Add/replace audio track
- `Remove-Audio` - Remove audio from video
- `Normalize-Audio` - Normalize audio levels
- `Adjust-Volume` - Change audio volume
- `Set-AudioBitrate` - Set audio bitrate

### Media Information
- `Get-MediaInfo` - Get detailed media file information
- `Get-FFmpegCodecs` - List available codecs
- `Get-FFmpegFormats` - List supported formats
- `Get-FFmpegFilters` - List available filters
- `Get-FFmpegEncoders` - List encoders
- `Get-FFmpegDecoders` - List decoders

### Advanced Features
- `New-FFmpegFilterComplex` - Create complex filter chains
- `Add-Watermark` - Add watermark to video
- `Add-Subtitle` - Add subtitles to video
- `Create-GIF` - Convert video to animated GIF
- `New-VideoFromImages` - Create video from image sequence
- `Export-VideoFrames` - Extract frames from video
- `Create-VideoThumbnail` - Generate video thumbnail
- `Set-VideoBitrate` - Set video bitrate

### Direct FFmpeg Access
- `Invoke-FFmpeg` - Execute FFmpeg with custom parameters

## Usage Examples

### Convert Video Format
```powershell
ConvertTo-VideoFormat -InputPath "input.avi" -OutputPath "output.mp4" -Format mp4
```

### Extract Audio
```powershell
Extract-Audio -InputPath "video.mp4" -OutputPath "audio.mp3" -AudioCodec libmp3lame
```

### Create GIF
```powershell
Create-GIF -InputPath "video.mp4" -OutputPath "animation.gif" -Width 480 -FPS 15
```

### Get Media Information
```powershell
Get-MediaInfo -Path "video.mp4"
```

### Trim Video
```powershell
Trim-Video -InputPath "long_video.mp4" -OutputPath "clip.mp4" -StartTime "00:01:30" -Duration "00:00:45"
```

## Requirements

- PowerShell 5.1 or later
- Windows (primary support), Linux/macOS (community tested)
- FFmpeg (automatically installed if missing)

## License

MIT License - see [LICENSE](LICENSE) file for details

## Contributing

Contributions welcome! Please feel free to submit a Pull Request.

## Links

- **GitHub**: https://github.com/mrkelter/FFMPS1
- **PowerShell Gallery**: https://www.powershellgallery.com/packages/FFMPS1
- **Issues**: https://github.com/mrkelter/FFMPS1/issues

## Author

Mark Kelter ([@mrkelter](https://github.com/mrkelter))

---

## Install-FFmpegDependency

### Synopsis
Installs FFmpeg using available package managers (Chocolatey, Scoop, or winget).

### Description
This helper function attempts to install FFmpeg automatically using one of the common Windows package managers. It tries them in order: Chocolatey, Scoop, then winget.

If no package manager is available, it provides manual installation instructions.

### Syntax
```powershell
Install-FFmpegDependency
```

### Examples

#### Example 1
```powershell
Install-FFmpegDependency
```
Attempts to install FFmpeg using available package managers.

### Notes
- The module will prompt to install FFmpeg automatically on first import if it's not found
- You can also run this function manually at any time
- After installation, you may need to restart your PowerShell session to update the PATH

### Manual Installation Options

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

