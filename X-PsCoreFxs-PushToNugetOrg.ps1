param (
    [System.String]
    $ProjectFileName = "*.csproj",

    [System.String]
    [ValidateSet("Release", "Debug")]
    $Configuration = "Release",

    [System.String]
    [ValidateSet("Default", "EnvironmentVariable", "ApiKeyValue")]
    $ApiKeyType = "Default",

    [string]
    $NugetPushApiKey = [string]::Empty,

    [switch]
    $NoSymbols
)

$ErrorActionPreference = "Stop"
Import-Module -Name "$(Get-Item "./Z-PsCoreFxs.ps1")" -Force -NoClobber

$ProjectFilename = Get-Item $ProjectFilename
if (!(Test-Path $ProjectFilename -PathType Leaf) -or (!"$ProjectFilename".EndsWith(".csproj"))) {
    throw "Invalid file `"$ProjectFilename`"."
}

Remove-ItemTree -Path "$($ProjectFileName | Split-Path)/bin/$Configuration" -ErrorAction Ignore
dotnet build $ProjectFileName --configuration $Configuration
Test-LastExitCode
dotnet pack $ProjectFileName --configuration $Configuration
Test-LastExitCode

$nupkg = Get-Item "$($ProjectFileName | Split-Path)/bin/$Configuration/*.nupkg"
Write-Host "Package: $nupkg"

switch ($ApiKeyType) {
    ("EnvironmentVariable") {  
        $NugetPushApiKey = Get-StringCoalesce $NugetPushApiKey "Unknown-$([Guid]::NewGuid())"
        $NugetPushApiKey = "$(Get-Item "env:$NugetPushApiKey" -ErrorAction Ignore)"
    }

    ("ApiKeyValue") {  

    }

    ("Default")
    {
        $NugetPushApiKey = "$($env:NUGETORG_PUSH_API_KEY)"
    }

    Default {
        $NugetPushApiKey = [System.Environment]::Empty
    }
}


if (![string]::IsNullOrWhiteSpace($NugetPushApiKey)) {
    [string] $symbols = $NoSymbols.IsPresent ? "--no-symbols" : [string]::Empty
    Write-Host $symbols
    dotnet nuget push "$nupkg" --api-key "$NugetPushApiKey" --source "$NUGET_ORG_URI" $symbols
    Test-LastExitCode
    return
}

throw "No ""$NUGET_ORG_URI"" api key found."