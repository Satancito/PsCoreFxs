
[CmdletBinding()]
param (
    [Parameter(Position = 0, ParameterSetName = "Default")]
    [Parameter(Position = 0, ParameterSetName = "Major")]
    [Parameter(Position = 0, ParameterSetName = "Minor")]
    [Parameter(Position = 0, ParameterSetName = "Patch")]
    [System.String]
    $Message = [string]::Empty,

    [Parameter(Mandatory = $True, ParameterSetName = "Major")]
    [Switch]
    $Major,
        
    [Parameter(Mandatory = $True, ParameterSetName = "Minor")]
    [Switch]
    $Minor,

    [Parameter(Mandatory = $True, ParameterSetName = "Patch")]
    [Switch]
    $Patch
)
    
$ErrorActionPreference = "Stop"
Import-Module -Name "$(Get-Item "./Z-PsCoreFxs.ps1")" -Force -NoClobber

Clear-Host

Write-Host
Write-InfoMagenta "███ Commit and push" 

Write-Host
Write-InfoBlue "█ Commit"


$configFile = "./Z-PsCoreFxsConfig.json"
$jsonObj = Get-JsonObject -Filename "$configFile"
$jsonObj.Build += 1
Set-JsonObject -Value $jsonObj -Filename "$configFile"

git add -A
Test-LastExitCode
git status
git commit -m "$(Get-StringCoalesce -Value $message -Value2 "Build.$($jsonObj.Build)")"
Write-Host
Write-InfoBlue "█ Pushing to remote"
git push origin main

Write-Host
Write-Host
Write-InfoMagenta "███ Finished all actions"