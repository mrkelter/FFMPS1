 @{
    # Module manifest for FFmpeg PowerShell wrapper
    RootModule = 'FFmpeg.psm1'
    ModuleVersion = '1.0.0'
    GUID = 'a8f3d2c1-5b4e-4d9a-8c7f-1e2b3c4d5e6f'
    Author = 'FFmpeg PowerShell Wrapper'
    CompanyName = 'Community'
    Copyright = '(c) 2025. All rights reserved.'
    Description = 'PowerShell wrapper module for FFmpeg with full discoverability and parameter completion'
    PowerShellVersion = '5.1'
    
    # Functions to export
    FunctionsToExport = @(
        'Invoke-FFmpeg',
        'ConvertTo-VideoFormat',
        'ConvertTo-AudioFormat',
        'Get-MediaInfo',
        'Resize-Video',
        'Split-Video',
        'Merge-Video',
        'Extract-Audio',
        'Add-AudioToVideo',
        'Remove-Audio',
        'Set-VideoBitrate',
        'Set-AudioBitrate',
        'New-VideoFromImages',
        'Export-VideoFrames',
        'Add-Watermark',
        'Crop-Video',
        'Rotate-Video',
        'Adjust-VideoSpeed',
        'Create-VideoThumbnail',
        'Trim-Video',
        'Get-FFmpegCodecs',
        'Get-FFmpegFormats',
        'Get-FFmpegFilters',
        'Get-FFmpegEncoders',
        'Get-FFmpegDecoders',
        'New-FFmpegFilterComplex',
        'Add-Subtitle',
        'Convert-VideoCodec',
        'Optimize-VideoForWeb',
        'Create-GIF',
        'Normalize-Audio',
        'Adjust-Volume'
    )
    
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    
    PrivateData = @{
        PSData = @{
            Tags = @('FFmpeg', 'Video', 'Audio', 'Media', 'Conversion', 'Encoding')
            LicenseUri = ''
            ProjectUri = ''
            ReleaseNotes = 'Initial release with comprehensive FFmpeg wrapper functionality'
        }
    }
}
