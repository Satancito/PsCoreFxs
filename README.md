# **PsCoreFxs**


# ***Steps to use***

# Install

**1.** Run this line in Powershell.

```
Remove-Item -Force "X-PsCoreUpdate.ps1" -ErrorAction "Continue"; Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Satancito/PsCoreFxs/main/X-PsCoreUpdate.ps1" -OutFile "X-PsCoreUpdate.ps1";
```

**2.** Run "**X-PsUpdate.ps1**"

```
./X-PsCoreUpdate.ps1
```

**3.** Edit "**Z-PsCoreFxsConfig.json**", in the "Files" key's value remove from array the innecesary scripts and save. 

**4.** Import the downloaded script from your ps scripts.  
```
Import-Module -Name "$($PSCommandPath | Split-Path)/Z-PsCoreFxs.ps1" -Force -NoClobber #Same directory

Import-Module -Name "$($PSCommandPath | Split-Path | Split-Path | Split-Path)/PsCoreFxs/Z-PsCoreFxs.ps1" -Force -NoClobber

Import-Module -Name "$($PSCommandPath)/../../../PsCoreFxs/Z-PsCoreFxs.ps1" -Force -NoClobber

Import-Module -Name "path/to/script/Z-PsCoreFxs.ps1" -Force -NoClobber
```

Or run the downloaded scripts

```
./X-PsCoreFxs-Update.ps1
./X-PsCoreFxs-ManageProjectSecrets.ps1 -Set -Project "J:\Projects\MyProject.csproj"
./X-PsCoreFxs-ManageProjectSecrets.ps1 -List
```

# Update

**1.** Run "**X-PsUpdate.ps1**" 

```
./X-PsUpdate.ps1
```

# Get all scripts files 

**1.** Remove "**Z-PsCoreFxsConfig.json**"   
 
**2.** Run "**X-PsUpdate.ps1**" 

```
./X-PsUpdate.ps1
```

# Get specific script files
**1.** Edit "**Z-PsCoreFxsConfig.json**" in the "Files" key's value add inside of array desired/removed script and finally save. "CoreFiles", "DeprecatedFiles" keys's values don't be modified.

*Original file*
```
{
  "Files": [
    "X-PsCoreFxs-ManageProjectSecrets.ps1"
  ],
  "CoreFiles": [
    "Z-PsCoreFxs.ps1",
    "Z-PsCoreFxsConfig.json"
  ],
  ...
}
```

*Updated file*
```
{
  "Files": [
    "X-PsCoreFxs-ManageProjectSecrets.ps1",
    "X-PsCoreFxs-PushProjectToRemote.ps1"
  ],
  "CoreFiles": [
    "Z-PsCoreFxs.ps1",
    "Z-PsCoreFxsConfig.json"
  ],
  ...
}
```

**2.** Run "**X-PsUpdate.ps1**" 
```
./X-PsUpdate.ps1
```

# Update "Z-PsCoreFxsConfig.json"
if "**Z-PsCoreFxsConfig.json**" exists the script "**X-PsUpdate.ps1**" don't replace the file, it creates the file "**Z-PsCoreFxsConfig.Last.json**" it contains the latest configuration values.

If you need any latest configuration from new versions you need to copy manually the content from "**Z-PsCoreFxsConfig.Last.json**" to "**Z-PsCoreFxsConfig.json**".

# Files Prefixes

"**Z-**" prefix is a not runnable script(library). It can be imported from your scripts.
"**X-**" prefix is a runnable script. It can be called by your scripts with [pwsh](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.1) command 