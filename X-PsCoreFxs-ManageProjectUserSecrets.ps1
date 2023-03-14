[CmdletBinding(DefaultParameterSetName = "setc")]
param (
    [Parameter(ParameterSetName = "seta")]
    [switch]
    $Edit,

    [Parameter(ParameterSetName = "setb")]
    [switch]
    $List,
    
    [string]
    [Parameter(ParameterSetName = "seta")]
    $Editor = "code",

    [string]
    [Parameter()]
    $ProjectFileName = "*.csproj"

)
    
$ErrorActionPreference = "Stop"
Import-Module -Name "$(Get-Item "Z-PsCoreFxs.ps1")" -Force -NoClobber

if ($Edit.IsPresent) { 
    Edit-ProjectUserSecrets -ProjectFileName $ProjectFileName -Editor $Editor
    return
}
    
Show-ProjectUserSecrets -ProjectFileName $ProjectFileName 

