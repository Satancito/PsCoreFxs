param (
    [Parameter(Position = 0)]
    [System.String]
    $ProjectFileName = "*.csproj"
)

$ErrorActionPreference = "Stop"
Import-Module -Name "$(Get-Item "./Z-PsCoreFxs.ps1")" -Force -NoClobber

Update-ProjectBuildNumber -ProjectFilename $ProjectFileName