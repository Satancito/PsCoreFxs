[CmdletBinding()]
param (
    [Parameter(ParameterSetName = "Zero")]
    [Parameter(ParameterSetName = "ZeroR")]
    [Parameter(ParameterSetName = "ZeroP")]
    [Parameter( ParameterSetName = "Major")]
    [Parameter( ParameterSetName = "Minor")]
    [Parameter( ParameterSetName = "Patch")]
    [Parameter( ParameterSetName = "MajorR")]
    [Parameter( ParameterSetName = "MinorR")]
    [Parameter( ParameterSetName = "PatchR")]
    [Parameter( ParameterSetName = "MajorP")]
    [Parameter( ParameterSetName = "MinorP")]
    [Parameter( ParameterSetName = "PatchP")]
    [System.String]
    $ProjectFileName = "*.csproj",

    [Parameter(ParameterSetName = "Major", Mandatory = $true)]
    [Parameter(ParameterSetName = "MajorR", Mandatory = $true)]
    [Parameter(ParameterSetName = "MajorP", Mandatory = $true)]
    [Switch]
    $Major,

    [Parameter(ParameterSetName = "Minor", Mandatory = $true)]
    [Parameter(ParameterSetName = "MinorR", Mandatory = $true)]
    [Parameter(ParameterSetName = "MinorP", Mandatory = $true)]
    [Switch]
    $Minor,

    [Parameter(ParameterSetName = "Patch", Mandatory = $true)]
    [Parameter(ParameterSetName = "PatchR", Mandatory = $true)]
    [Parameter(ParameterSetName = "PatchP", Mandatory = $true)]
    [Switch]
    $Patch,

    [Parameter(ParameterSetName = "ZeroP", Mandatory = $true)]
    [Parameter(ParameterSetName = "MajorP", Mandatory = $true)]
    [Parameter(ParameterSetName = "MinorP", Mandatory = $true)]
    [Parameter(ParameterSetName = "PatchP", Mandatory = $true)]
    [Switch]
    $IsPrerelease,
    
    [Parameter(ParameterSetName = "ZeroR", Mandatory = $true)]
    [Parameter(ParameterSetName = "MajorR", Mandatory = $true)]
    [Parameter(ParameterSetName = "MinorR", Mandatory = $true)]
    [Parameter(ParameterSetName = "PatchR", Mandatory = $true)]
    [Switch]
    $IsRelease,

    [System.String]
    $Prerelease = [string]::Empty,
    
    [System.String]
    $Build = [string]::Empty,

    [switch]
    $Force
)

$ErrorActionPreference = "Stop"
Import-Module -Name "$(Get-Item "./Z-PsCoreFxs.ps1")" -Force -NoClobber

[System.Collections.Hashtable]$params = new-object System.Collections.Hashtable
$params.Add( $(Get-VariableName $ProjectFileName) , $ProjectFileName)
if ($PSBoundParameters.ContainsKey($(Get-VariableName $Verbose))) {
    $params.Add($(Get-VariableName $Verbose) , $true)
}
$params.Add( $(Get-VariableName $Build) , $Build)
$params.Add( $(Get-VariableName $Prerelease) , $Prerelease)

if ($IsRelease.IsPresent) {
    $params.Add($(Get-VariableName $IsRelease) , $true)
}

if ($IsPrerelease.IsPresent) {
    $params.Add($(Get-VariableName $IsPrerelease) , $true)
}

if ($Major.IsPresent) {
    $params.Add($(Get-VariableName $Major) , $true)
}

if ($Minor.IsPresent) {
    $params.Add($(Get-VariableName $Minor) , $true)
}

if ($Patch.IsPresent -or (!$Major.IsPresent -and !$Minor.IsPresent)) {
    $params.Add($(Get-VariableName $Patch) , $true)
}

if($Force.IsPresent)
{
    $params.Add($(Get-VariableName $Force) , $true)
}

Update-ProjectVersion @params


