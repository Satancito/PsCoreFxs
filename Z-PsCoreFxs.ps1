function Pop-LocationStack {
    param (
        [string]
        $StackName = [string]::Empty,

        [int]
        $Count = 0
    )

    if ($Count -lt 0) {
        $Count = 0
    }

    if ([string]::IsNullOrWhiteSpace($StackName)) {
        if ($Count -eq 0) {
            $Count = (Get-Location -Stack).Count
        }
        for ($i = 0; $i -lt $Count; $i++) {
            Pop-Location 
        }
    }
    else {
        $stackCount = (Get-Location -Stack -StackName $StackName).Count 
        if ($Count -eq 0) {
            $Count = $stackCount
        }
        if ($Count -gt $stackCount) {
            $Count = $stackCount
        }
        for ($i = 0; $i -lt $Count; $i++) {
            try {
                
                Pop-Location -StackName $StackName 
            }
            finally {
                
            }
        }
    }
    
}

function Get-StringCoalesce {
    param (
        [string]
        [Parameter()]
        $Value,

        [string]
        [Parameter()]
        $Value2,

        [switch]
        $Force
    )
    if (!$Force.IsPresent -and [string]::IsNullOrWhiteSpace($Value2)) {
        throw [System.ArgumentException]::new("$(Get-VariableName $Value2) value can't be null or whitespace.")
    }
    return [string]::IsNullOrWhiteSpace($value) ? $Value2 : $Value
}

function Get-StringEmptyOrValue {
    param (
        [string]
        [Parameter()]
        $TestValue,

        [string]
        [Parameter(Mandatory = $true)]
        $Value
    )
    return [string]::IsNullOrWhiteSpace($TestValue) ? [string]::Empty : $Value
}

function Set-GlobalConstant {
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true)]
        [System.Object]
        $Value

    )
    Process {
        if (!(Get-Variable "$Name"  -ErrorAction 'Ignore')) {
            Set-Variable -Name "$Name" -Option Constant -Value $Value -Scope Global -Force
        }
    }
}

function Set-GlobalVariable {
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name,

        [Parameter(Mandatory = $false, Position = 1, ValueFromPipeline = $true)]
        [System.Object]
        $Value
    )
    Process {
        Set-Variable -Name "$Name" -Value $Value -Option ReadOnly -Scope Global -Force
    }
}

# █ Output

function Write-OutputIntroOutroMessage {
    [CmdletBinding()]
    param (
        [Parameter()]
        [object]
        $Value = [string]::Empty,

        [Parameter()]
        [string]
        $IntroFormat = [string]::Empty,

        [Parameter()]
        [string]
        $OutroFormat = [string]::Empty,

        [parameter()]
        [System.ConsoleColor]
        $ForegroundColor = [System.ConsoleColor]::ForegroundColor,

        [parameter()]
        [System.ConsoleColor]
        $BackgroundColor = [System.Console]::BackgroundColor,

        [parameter()]
        [Switch]
        $NoNewLine,

        [Parameter()]
        [switch]
        $NoOutput,

        [Parameter()]

        [switch]
        $IsOutro
    )
    $IntroFormat = [string]::IsNullOrWhiteSpace($IntroFormat) ? "<🔓-- {0}" : $IntroFormat
    $OutroFormat = [string]::IsNullOrWhiteSpace($OutroFormat) ? "{0} --🔒>" : $OutroFormat
    $format = $IsOutro.IsPresent ? $OutroFormat : $IntroFormat
    $message = [string]::Format($format, $value)
    Write-OutputMessage "$message"  -ForegroundColor:$ForegroundColor -BackgroundColor:$BackgroundColor -NoNewLine:$NoNewLine -NoOutput:$NoOutput
}

function Write-OutputMessage {
    param (
        [Parameter()]
        [object]
        $Value = [string]::Empty,

        [parameter()]
        [System.ConsoleColor]
        $ForegroundColor = [System.Console]::ForegroundColor,

        [parameter()]
        [System.ConsoleColor]
        $BackgroundColor = [System.Console]::BackgroundColor,

        [parameter()]
        [Switch]
        $NoNewLine,

        [Parameter()]
        [switch]
        $NoOutput
    )
    if ($NoOutput.IsPresent) {
        return
    } 
    $actualForeground = [System.Console]::ForegroundColor
    $actualBackground = [System.Console]::BackgroundColor
    [System.Console]::ForegroundColor = $ForegroundColor
    [System.Console]::BackgroundColor = $BackgroundColor
    Write-Host "$Value" -NoNewline:$NoNewLine
    [System.Console]::ForegroundColor = $actualForeground
    [System.Console]::BackgroundColor = $actualBackground
     
}

function Write-TextColor {
    Param(
        [parameter(Position = 0, ValueFromPipeline = $true)]
        [Object]
        $Info,

        [parameter(Position = 1, ValueFromPipeline = $true)]
        [System.ConsoleColor]
        $ForegroundColor = [System.ConsoleColor]::White,
    
        [parameter(Position = 2, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        foreach ($value in $Info) {
            if ($NoNewLine) {
                Write-Host $value -ForegroundColor $ForegroundColor -NoNewline
            }
            else {
                Write-Host $value -ForegroundColor $ForegroundColor
            }
        }            
    }
}

function Write-PrettyKeyValue {
    [CmdletBinding()]
    Param(
        [parameter(Position = 0, ValueFromPipeline = $true)]
        [Object]
        $Key,

        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Object]
        $Value,

        [parameter(Position = 2, ValueFromPipeline = $true)]
        [System.ConsoleColor]
        $LabelForegroudColor = [System.ConsoleColor]::Magenta,

        [parameter(Position = 3, ValueFromPipeline = $true)]
        [System.ConsoleColor]
        $InfoForegroundColor = [System.ConsoleColor]::White,

        [parameter(Position = 4, ValueFromPipeline = $true, Mandatory = $false)]
        [Switch]
        $NoNewLine,

        [Parameter(Position = 5, Mandatory = $false)]
        [System.Management.Automation.SwitchParameter]
        $IsDebug
    )
    
    Process {
        if ($IsDebug) {
            Write-InfoYellow "DEBUG: " -NoNewLine
        }
        Write-TextColor "$($Key): " $LabelForegroudColor -NoNewLine
        foreach ($value in $Value) {
            Write-TextColor $value $InfoForegroundColor -NoNewline:$NoNewLine
        }
    }
}

function Write-InfoRed {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $false)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Red $NoNewLine
    }
}

function Write-InfoDarkRed {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $false)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information DarkRed $NoNewLine
    }
}

function Write-InfoYellow {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Yellow $NoNewLine
    }
}

function Write-InfoDarkYellow {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information DarkYellow $NoNewLine
    }
}

function Write-InfoGray {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Gray $NoNewLine
    }
}

function Write-InfoDarkGray {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information DarkGray $NoNewLine
    }
}

function Write-InfoGreen {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $false)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Green $NoNewLine
    }
}

function Write-InfoDarkGreen {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information DarkGreen $NoNewLine
    }
}

function Write-InfoMagenta {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Magenta $NoNewLine
    }
}

function Write-InfoDarkMagenta {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information DarkMagenta $NoNewLine
    }
}

function Write-InfoWhite {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information White $NoNewLine
    }
}

function Write-InfoBlue {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Blue $NoNewLine
    }
}

function Write-InfoDarkBlue {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information DarkBlue $NoNewLine
    }
}

function Write-InfoCyan {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Cyan $NoNewLine
    }
}

function Write-InfoDarkCyan {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Cyan $NoNewLine
    }
}

function Write-InfoBlack {
    Param(
        [parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Object]
        $Information,
    
        [parameter(Position = 1, ValueFromPipeline = $true)]
        [Switch]
        $NoNewLine
    )

    Process {
        Write-TextColor $Information Black $NoNewLine
    }
}

function Test-OnlyWindows {
    param (
    )
    process {
        if (!$IsWindows) {
            Write-Error "Windows operating system is required to run this function."
            exit
        }
    }
}

function Test-OnlyLinux {
    param (
    )
    process {
        if (!$IsLinux) {
            Write-Error "Linux operating system is required to run this function."
            exit
        }
    }
}

function Test-OnlyMacOS {
    param (
    )
    process {
        if (!$IsMacOS) {
            throw "MacOS operating system is required to run this function."
        }
    }
}

class DbProviderSet : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return @($Global:SQLSERVER_PROVIDER, $Global:POSTGRESQL_PROVIDER, $Global:MYSQL_PROVIDER, $Global:ORACLE_PROVIDER, $Global:ALL_PROVIDER)
    }
}

function Stop-WhenIsDbProviderName {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [System.String]
        $Value
    )
    switch ($Value) {
        { $_ -in [DbProviderSet]::new().GetValidValues() } {
            throw "Value cannot be a db Provider"
        }
        default {
            return;
        }       
    }
}

function Install-EfCoreTools {
    param (
        
    )
    Write-Host "██ Try Install Entity Framework Core Tools" -ForegroundColor Blue
    if (Get-Command dotnet-ef -ErrorAction Ignore) {
        "Updating..."
        dotnet tool update --global dotnet-ef
    }
    else {
        "Installing..."
        dotnet tool install --global dotnet-ef
        
    }
    dotnet-ef --version
}

function Add-EfCoreMigration {
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateSet([DbProviderSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        $Provider,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Project,

        [Parameter(Mandatory = $true)]
        [System.String]
        $StartupProject,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Context = "",

        [switch]
        $InstallEfCoreTools
    )
    if ($InstallEfCoreTools.IsPresent) {
        Install-EfCoreTools
    }
    Stop-WhenIsDbProviderName -Value $Name

    $projectFile = "$(Get-Item -Path "$Project/*.csproj" | Split-Path -Leaf)"
    $startupProjectFile = "$(Get-Item -Path "$StartupProject/*.csproj" | Split-Path -Leaf)" 


    switch ($Provider) {
        { $_ -in @($SQLSERVER_PROVIDER, $POSTGRESQL_PROVIDER, $MYSQL_PROVIDER, $ORACLE_PROVIDER) } { 
            $Context = "$($Context)$($Provider)DbContext"
            $outputDir = "Migrations/$Provider/$($Context)_"
        }

        ($ALL_PROVIDER) {
            Add-EfCoreMigration -Name $Name -Provider $SQLSERVER_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            Add-EfCoreMigration -Name $Name -Provider $POSTGRESQL_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            Add-EfCoreMigration -Name $Name -Provider $MYSQL_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            Add-EfCoreMigration -Name $Name -Provider $ORACLE_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            return
        } 

        Default {
            Write-Error "Invalid Provider"
            exit
        }

    }
    Write-Host "█ Add Migration - $context - $outputDir" -ForegroundColor Magenta
    dotnet add "$StartupProject/$startupProjectFile" package "Microsoft.EntityFrameworkCore.Design"
    if ($projectFile -cne $startupProjectFile) {
        dotnet add "$StartupProject/$startupProjectFile" reference "$Project/$projectFile"
    }
    dotnet-ef migrations add "Migration_$($context)_$Name" --startup-project "$StartupProject" --project "$Project" --context "$context" --output-dir "$outputDir" --verbose
}

function Remove-EfCoreMigration {
    param ( 
        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet([DbProviderSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        [System.String]
        $Provider = "All",

        [Parameter(Mandatory = $true)]
        [System.String]
        $Project,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $StartupProject,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Context = "",

        [switch]
        $Force,

        [switch]
        $InstallEfCoreTools
    )
    if ($InstallEfCoreTools.IsPresent) {
        Install-EfCoreTools
    }

    $projectFile = "$(Get-Item -Path "$Project/*.csproj" | Split-Path -Leaf)"
    $startupProjectFile = "$(Get-Item -Path "$StartupProject/*.csproj" | Split-Path -Leaf)" 

    switch ($Provider) {
        { $_ -in @($SQLSERVER_PROVIDER, $POSTGRESQL_PROVIDER, $MYSQL_PROVIDER, $ORACLE_PROVIDER) } { 
            $Context = "$($Context)$($Provider)DbContext"
        }

        ($ALL_PROVIDER) {
            Remove-EfCoreMigration -Provider $SQLSERVER_PROVIDER -Project $Project -StartupProject $StartupProject -Context $context
            Remove-EfCoreMigration -Provider $POSTGRESQL_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            Remove-EfCoreMigration -Provider $MYSQL_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            Remove-EfCoreMigration -Provider $ORACLE_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            return
        } 

        Default {
            Write-Error "Invalid Provider"
            exit
        }
    }
    Write-Host "█ Remove Migration - $context" -ForegroundColor Magenta
    dotnet add "$StartupProject/$startupProjectFile" package "Microsoft.EntityFrameworkCore.Design"
    if ($projectFile -cne $startupProjectFile) {
        dotnet add "$StartupProject/$startupProjectFile" reference "$Project/$projectFile"
    }
    #Con el parámetro --force Elimina la migración desde código y desde la base de datos.
    dotnet ef migrations remove --startup-project "$startupProject" --project "$project" --context "$context" --verbose "$($Force.IsPresent ? "--force" : ([string]::Empty))"
    
}

function Remove-EfCoreDatabase {
    param (
        [System.String]
        [ValidateSet([DbProviderSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        $Provider = "All",
        [Parameter(Mandatory = $true)]
        [System.String]
        $Project,
        [Parameter(Mandatory = $true)]
        [System.String]
        $StartupProject,

        [Parameter(Mandatory = $false)]
        [System.String]
        $Context = "",

        [switch]
        $InstallEfCoreTools
    )
    if ($InstallEfCoreTools.IsPresent) {
        Install-EfCoreTools
    }

    $projectFile = "$(Get-Item -Path "$Project/*.csproj" | Split-Path -Leaf)"
    $startupProjectFile = "$(Get-Item -Path "$StartupProject/*.csproj" | Split-Path -Leaf)" 

    switch ($Provider) {
        { $_ -in @($SQLSERVER_PROVIDER, $POSTGRESQL_PROVIDER, $MYSQL_PROVIDER, $ORACLE_PROVIDER) } { 
            $Context = "$($Context)$($Provider)DbContext"
        }

        ($ALL_PROVIDER) {
            Remove-EfCoreDatabase -Provider $SQLSERVER_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            Remove-EfCoreDatabase -Provider $POSTGRESQL_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            Remove-EfCoreDatabase -Provider $MYSQL_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            Remove-EfCoreDatabase -Provider $ORACLE_PROVIDER -Project $project -StartupProject $startupProject -Context $Context
            return;
        } 

        Default {
            Write-Error "Invalid Provider"
            exit
        }

    }
    Write-Host "█ Remove Database - $context" -ForegroundColor Magenta
    dotnet add "$StartupProject/$startupProjectFile" package "Microsoft.EntityFrameworkCore.Design"
    if ($projectFile -cne $startupProjectFile) {
        dotnet add "$StartupProject/$startupProjectFile" reference "$Project/$projectFile"
    }
    dotnet-ef database drop --startup-project "$startupProject" --context "$context" --project "$project" --force --verbose
}

function Update-EfCoreDatabase {
    param (
        [System.String]
        [ValidateSet([DbProviderSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        $Provider = "All",
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $Project,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $StartupProject,

        [System.String]
        $Context = "",

        [switch]
        $InstallEfCoreTools
    )
    if ($InstallEfCoreTools.IsPresent) {
        Install-EfCoreTools
    }

    $projectFile = "$(Get-Item -Path "$Project/*.csproj" | Split-Path -Leaf)"
    $startupProjectFile = "$(Get-Item -Path "$StartupProject/*.csproj" | Split-Path -Leaf)" 

    switch ($Provider) {
        { $_ -in @($SQLSERVER_PROVIDER, $POSTGRESQL_PROVIDER, $MYSQL_PROVIDER, $ORACLE_PROVIDER) } { 
            $Context = "$($Context)$($Provider)DbContext"
        }

        ($ALL_PROVIDER) {
            Update-EfCoreDatabase -Provider $SQLSERVER_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            Update-EfCoreDatabase -Provider $POSTGRESQL_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            Update-EfCoreDatabase -Provider $MYSQL_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            Update-EfCoreDatabase -Provider $ORACLE_PROVIDER -Project $Project -StartupProject $StartupProject -Context $Context
            return
        }

        Default {
            Write-Error "Invalid Provider"
            exit
        }
    }
    Write-Host "█ Update database - $context" -ForegroundColor Magenta
    dotnet add "$StartupProject/$startupProjectFile" package "Microsoft.EntityFrameworkCore.Design"
    if ($projectFile -cne $startupProjectFile) {
        dotnet add "$StartupProject/$startupProjectFile" reference "$Project/$projectFile"
    }
    dotnet-ef database update --startup-project "$StartupProject" --context "$context" --project "$Project" --verbose
}

function New-EfCoreMigrationScript {
    param (
        [System.String]
        $Name = [String]::Empty,
        
        [System.String]
        [ValidateSet([DbProviderSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        $Provider = "All",
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $Project,
        
        [Parameter(Mandatory = $true)]
        [System.String]
        $StartupProject,

        [System.String]
        $Context = [string]::Empty,

        [switch]
        $Idempotent,

        [switch]
        $InstallEfCoreTools
    )

    if ($InstallEfCoreTools.IsPresent) {
        Install-EfCoreTools
    }
    Stop-WhenIsDbProviderName -Value $Name

    $projectFile = "$(Get-Item -Path "$Project/*.csproj" | Split-Path -Leaf)"
    $startupProjectFile = "$(Get-Item -Path "$StartupProject/*.csproj" | Split-Path -Leaf)" 

    switch ($Provider) {
        { $_ -in @($SQLSERVER_PROVIDER, $POSTGRESQL_PROVIDER, $MYSQL_PROVIDER, $ORACLE_PROVIDER) } { 
            $Context = "$($Context)$($Provider)DbContext"
            $outputFile = "$Project/MigrationScripts/$Provider/$Context/Migration_$($context)_$([string]::IsNullOrWhiteSpace($Name) ? "$([DateTime]::Now.ToString("yyyyMMddHHmmssfff"))" : $Name).sql"
            break
        }

        ($ALL_PROVIDER) {
            New-EfCoreMigrationScript -Name $Name -Provider $SQLSERVER_PROVIDER -Project $project -StartupProject $startupProject -Context $Context -Idempotent:$Idempotent
            New-EfCoreMigrationScript -Name $Name -Provider $POSTGRESQL_PROVIDER -Project $project -StartupProject $startupProject -Context $Context -Idempotent:$Idempotent
            New-EfCoreMigrationScript -Name $Name -Provider $MYSQL_PROVIDER -Project $project -StartupProject $startupProject -Context $Context -Idempotent:$Idempotent
            New-EfCoreMigrationScript -Name $Name -Provider $ORACLE_PROVIDER -Project $project -StartupProject $startupProject -Context $Context -Idempotent:$Idempotent
            return
        }

        Default {
            Write-Error "Invalid Provider"
            exit
        }

    }
    Write-Host "█ Creating Sql Script - $context - $outputFile" -ForegroundColor Magenta
    dotnet add "$StartupProject/$startupProjectFile" package "Microsoft.EntityFrameworkCore.Design"
    if ($projectFile -cne $startupProjectFile) {
        dotnet add "$StartupProject/$startupProjectFile" reference "$Project/$projectFile"
    }
    dotnet ef migrations script --output "$outputFile" --context "$context" --project "$project" --startup-project "$startupProject" --verbose ($Idempotent.IsPresent? "--idempotent" : [string]::Empty)
}

function Update-ProjectBuildNumber {
    param (
        [Parameter(Position = 0)]
        [System.String]
        $ProjectFilename = "*.csproj"
    )

    $basePath = "//Project/PropertyGroup"
    $buildNumberLabel = "BuildNumber"

    $ProjectFilename = Get-Item $ProjectFilename
    if (!(Test-Path $ProjectFilename -PathType Leaf) -or (!"$ProjectFilename".EndsWith(".csproj"))) {
        throw "Invalid file `"$ProjectFilename`"."
    }

    [System.Xml.XmlDocument] $doc = [System.Xml.XmlDocument]::new()
    $doc.PreserveWhitespace = $true
    $doc.Load($ProjectFilename)
    $ProjectBuild = $doc.DocumentElement.SelectSingleNode("$basePath/$buildNumberLabel") 

    if ($null -eq $ProjectBuild) {
        [System.Xml.XmlElement]$e = $doc.CreateElement("$buildNumberLabel")
        $e.InnerText = "1"
        $doc.DocumentElement.SelectSingleNode("$basePath").AppendChild($e);
        $doc.Save($ProjectFilename)
        $ProjectBuild = $e
        return $ProjectBuild.InnerText
    }

    if ([String]::IsNullOrWhiteSpace($ProjectBuild.InnerText)) {
        $ProjectBuild.InnerText = "1" 
    }

    $ProjectBuild.InnerText = [int]::Parse($ProjectBuild.InnerText) + 1
    $doc.Save($ProjectFilename)
    return $ProjectBuild.InnerText
}

function Get-NextVersion {
    param (
        [Parameter(Position = 0, ParameterSetName = "Default")]
        [Parameter(Position = 0, ParameterSetName = "Major")]
        [Parameter(Position = 0, ParameterSetName = "Minor")]
        [Parameter(Position = 0, ParameterSetName = "Patch")]
        [System.String]
        $Version = [string]::Empty,

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
    if ([string]::IsNullOrWhiteSpace($Version)) {
        $Version = "0.0.0"
    }
    # check https://semver.org/
    $pattern = "^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$";
    $match = [System.Text.RegularExpressions.Regex]::Match($Version, $pattern, [System.Text.RegularExpressions.RegexOptions]::Multiline, [System.TimeSpan]::FromSeconds(1))
    if ($match.Success) {
        $majorValue = $match.Groups[1].Value.Trim()
        $minorValue = $match.Groups[2].Value.Trim()
        $patchValue = $match.Groups[3].Value.Trim()
        $OldVersionValue = "$majorValue.$minorValue.$patchValue"
        

        $configured = $false
        if ($Major.IsPresent) {
            $majorValue = "$([Convert]::ToInt32($majorValue, 10) + 1)";
            $minorValue = "0"
            $patchValue = "0"
            $configured = $true
        }
    
        if ($Minor.IsPresent) {
            $minorValue = "$([Convert]::ToInt32($minorValue, 10) + 1)";
            $patchValue = "0"
            $configured = $true
        }
    
        if ($Patch.IsPresent) {
            $patchValue = "$([Convert]::ToInt32($patchValue, 10) + 1)";
            $configured = $true
        }

        if (!$configured) {
            $patchValue = "$([Convert]::ToInt32($patchValue, 10) + 1)";
        }

       
        $NewVersionValue = "$majorValue.$minorValue.$patchValue".Trim()

        return $version.Replace($OldVersionValue, $NewVersionValue)
    }

    throw "Invalid version format. Check format in https://semver.org/"
}

function Update-ProjectVersion {
    param (
        [Parameter(ParameterSetName = "Major")]
        [Parameter(ParameterSetName = "Minor")]
        [Parameter(ParameterSetName = "Patch")]
        [Parameter(ParameterSetName = "MajorR")]
        [Parameter(ParameterSetName = "MinorR")]
        [Parameter(ParameterSetName = "PatchR")]
        [Parameter(ParameterSetName = "MajorP")]
        [Parameter(ParameterSetName = "MinorP")]
        [Parameter(ParameterSetName = "PatchP")]
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

        [Switch]
        $Force
    )

    if ($PSBoundParameters.ContainsKey("Verbose") -and $PSBoundParameters["Verbose"]) {
        Write-PrettyKeyValue "PSBoundParameters" $PSCmdlet.MyInvocation.InvocationName -NoNewLine
        $PSBoundParameters | Format-Table
    }

    $ProjectFileName = Get-Item $ProjectFileName
    if (($null -eq $ProjectFileName) -or !(Test-Path $ProjectFileName -PathType Leaf) -or (!"$ProjectFileName".EndsWith(".csproj"))) {
        throw "Invalid project filename `"$ProjectFileName`". Not found."
    }

    
    [System.Xml.XmlDocument] $doc = [System.Xml.XmlDocument]::new()
    $doc.PreserveWhitespace = $true
    $doc.Load($ProjectFileName)

    $basePath = "//Project/PropertyGroup"

    $isPrereleaseLabel = "IsPrerelease"
    $prereleaseNameLabel = "PrereleaseName"
    $buildSuffixLabel = "BuildSuffix"
    $buildNumberLabel = "BuildNumber"
    $versionPrefixLabel = "VersionPrefix"
    $versionSuffixLabel = "VersionSuffix"
    $versionLabel = "Version"

    $defaultPrefix = "0.0.0"
    $defaultBuildNumber = "0"
    $defaultPrereleaseName = "Preview"
    $defaultBuildSuffix = "Build"

    $isPrereleaseNode = $doc.DocumentElement.SelectSingleNode("$basePath/$isPrereleaseLabel") 
    $prereleaseNameNode = $doc.DocumentElement.SelectSingleNode("$basePath/$prereleaseNameLabel") 
    $buildSuffixNode = $doc.DocumentElement.SelectSingleNode("$basePath/$buildSuffixLabel") 
    $buildNumberNode = $doc.DocumentElement.SelectSingleNode("$basePath/$buildNumberLabel")
    $versionPrefixNode = $doc.DocumentElement.SelectSingleNode("$basePath/$versionPrefixLabel") 
    $versionSuffixNode = $doc.DocumentElement.SelectSingleNode("$basePath/$versionSuffixLabel") 
    $version = $doc.DocumentElement.SelectSingleNode("$basePath/$versionLabel")

    if ($null -eq $versionSuffixNode) {
        [System.Xml.XmlElement]$versionSuffixNode = $doc.CreateElement($versionSuffixLabel)
        $versionSuffixNode.InnerText = [string]::Empty
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($versionSuffixNode);
    }

    if ($null -eq $versionPrefixNode) {
        [System.Xml.XmlElement]$versionPrefixNode = $doc.CreateElement($versionPrefixLabel)
        $versionPrefixNode.InnerText = $defaultPrefix
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($versionPrefixNode);
    }
    
    if ($null -eq $buildNumberNode) {
        [System.Xml.XmlElement]$buildNumberNode = $doc.CreateElement($buildNumberLabel)
        $buildNumberNode.InnerText = $defaultBuildNumber
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($buildNumberNode);
    }

    if ($null -eq $prereleaseNameNode) {
        [System.Xml.XmlElement]$prereleaseNameNode = $doc.CreateElement($prereleaseNameLabel)
        $prereleaseNameNode.InnerText = $defaultPrereleaseName
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($prereleaseNameNode);
    }
    
    if ($null -eq $buildSuffixNode) {
        [System.Xml.XmlElement]$buildSuffixNode = $doc.CreateElement($buildSuffixLabel)
        $buildSuffixNode.InnerText = $defaultBuildSuffix
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($buildSuffixNode);
    }

    if ($null -eq $isPrereleaseNode) {
        [System.Xml.XmlElement]$isPrereleaseNode = $doc.CreateElement($isPrereleaseLabel)
        $isPrereleaseNode.InnerText = "false"
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($isPrereleaseNode);
    }

    $prereleaseNameNode.InnerText = $(Get-StringCoalesce $Prerelease $(Get-StringCoalesce $prereleaseNameNode.InnerText $defaultPrereleaseName))
    $buildSuffixNode.InnerText = $(Get-StringCoalesce $Build $(Get-StringCoalesce $buildSuffixNode.InnerText $defaultBuildSuffix))

    $isPrereleaseConfirmed = $false
    if ($IsPrerelease.IsPresent) {
        $isPrereleaseNode.InnerText = "true"
        $isPrereleaseConfirmed = $true
    }

    if ($IsRelease.IsPresent) {
        $prereleaseNameNode.InnerText = $defaultPrereleaseName
        $isPrereleaseNode.InnerText = "false"
    }


    if ($null -eq $version) {
        [System.Xml.XmlElement]$version = $doc.CreateElement($versionLabel)
        $version.InnerText = [string]::Empty
        $doc.DocumentElement.SelectSingleNode($basePath).AppendChild($version);
        $doc.Save($ProjectFileName)
    }
    if ($Force.IsPresent -or (!$isPrereleaseConfirmed) ) {
        $configured = $false
        if ($Major.IsPresent -and !$configured) {
            $versionPrefixNode.InnerText = Get-NextVersion -Version $versionPrefixNode.InnerText -Major 
            $configured = $true
        }

        if ($Minor.IsPresent -and !$configured) {
            $versionPrefixNode.InnerText = Get-NextVersion -Version $versionPrefixNode.InnerText -Minor 
            $configured = $true
        }

        if ($Patch.IsPresent -and !$configured) {
            $versionPrefixNode.InnerText = Get-NextVersion -Version $versionPrefixNode.InnerText -Patch
            $configured = $true
        }
        if (!$configured) {
            $versionPrefixNode.InnerText = Get-NextVersion -Version $versionPrefixNode.InnerText -Patch
        }
    }

    $suffix = "$($prereleaseNameNode.InnerText)-$([System.DateTimeOffset]::Now.ToString("yyyyMMddHHmmssfff"))-$($buildSuffixNode.InnerText).$($buildNumberNode.InnerText)"
    $versionSuffixNode.InnerText = $isPrereleaseConfirmed ? $suffix : [string]::Empty
    $version.InnerText = "$($versionPrefixNode.InnerText)$($isPrereleaseConfirmed ? "-$suffix" : [string]::Empty)"
    $doc.Save($ProjectFileName)
    return $version.InnerText
}

function Read-Key {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Prompt = "Press any key to continue",
    
        [Parameter()]
        [bool]
        $Display = $false,

        [Parameter()]
        [bool]
        $Discard = $true
    )
    Write-Host "$Prompt " -NoNewline -ForegroundColor DarkGray
    $key = [Console]::ReadKey(!$Display)
    if (!(($key -eq 13) -or ($key -eq 10))) {
        [Console]::WriteLine()
    }

    if (!$Discard) {
        return $key
    }
}

function Get-VariableName {
    Param(
        [Parameter()]    
        [System.Object]
        $Variable
    )
    $Line = @(Get-PSCallStack)[1].Position.Text
        
    if ($Line -match '(.*)(Get-VariableName)([ ]+)(-Variable[ ]+)*\$(?<varName>([\w]+:)*[\w]*)(.*)') {
        #https://regex101.com/r/Uc6asf/1
        return $Matches['varName'] 
    }
} 
    
function Test-LastExitCode {
    param (
        [Parameter()]
        [switch]
        $NoThrowError
    )
    if (($LASTEXITCODE -ne 0) -or (-not $?)) {
        if ($NoThrowError.IsPresent) {
            return $false
        }
        throw "ERROR: When execute last command. Check and try again. ExitCode = $($LASTEXITCODE)."
    }  
    if ($NoThrowError.IsPresent) {
        return $true
    }
}
    
function Select-ValueByPlatform {
    param (
        [parameter()]
        [System.Object]
        $WindowsValue = [string]::Empty,
        
        [parameter()]
        [System.Object]
        $LinuxValue = [string]::Empty,
        
        [parameter()]
        [System.Object]
        $MacOSValue = [string]::Empty
        
    )
    if ($IsWindows) {
        return $WindowsValue
    }
    if ($IsLinux) {
        return $LinuxValue
    }
    if ($IsMacOS) {
        return $MacOSValue
    }
        
    throw "Invalid Platform."
}
    
function Get-UserHome {
    return "$(Select-ValueByPlatform "$env:USERPROFILE" "$env:HOME" "$env:HOME")";
}

function Set-LocalEnvironmentVariable {
    param (
        [Parameter()]
        [System.String]
        $Name,

        [Parameter()]
        [System.String]
        $Value,

        [Parameter()]
        [Switch]
        $Append,

        [Parameter()]
        [Switch]
        $NoOutput
    )

    function Write-MyMessage {
        param(
            [System.String]
            $VarName,

            [Parameter()]
            [Switch]
            $NoOutput 
        )
        $envVar = Get-Item env:$VarName -ErrorAction SilentlyContinue
        $envVar = ([string]::IsNullOrWhiteSpace($envVar)) ? [string]::Empty : $envVar.Value
        $color = ([string]::IsNullOrWhiteSpace($envVar)) ? "DarkGray" : "Magenta"
        
        Write-OutputMessage "Local Environment variable " -NoNewline -ForegroundColor White -NoOutput:$NoOutput
        Write-OutputMessage "`"$VarName`"" -NoNewline -ForegroundColor Magenta -NoOutput:$NoOutput
        Write-OutputMessage "  ➡  " -NoNewline -ForegroundColor White -NoOutput:$NoOutput
        Write-OutputMessage "`"$envVar`"" -ForegroundColor $Color -NoOutput:$NoOutput
    }

    if ($Append.IsPresent) {
        if (Test-Path "env:$Name") {
            $Value = (Get-Item "env:$Name").Value + $Value
        }
    }
    New-Item env:$Name -Value "$value" -Force | Out-Null
    Write-MyMessage -VarName "$Name" -NoOutput:$NoOutput
}

function Set-PersistentEnvironmentVariable {
    param (
        [Parameter()]
        [System.String]
        $Name,
    
        [Parameter()]
        [System.String]
        $Value,
    
        [Parameter()]
        [Switch]
        $Append, 
        
        [Parameter()]
        [Switch]
        $NoOutput 
    )
    
    function Write-MyMessage {
        param(
            [System.String]
            $VarName,

            [Parameter()]
            [Switch]
            $NoOutput
        )
        $envVar = Get-Item env:$VarName -ErrorAction SilentlyContinue
        $envVar = ([string]::IsNullOrWhiteSpace($envVar)) ? [string]::Empty : $envVar.Value
        $color = ([string]::IsNullOrWhiteSpace($envVar)) ? "DarkGray" : "Magenta"
        Write-OutputMessage "Persistent Environment variable " -NoNewline -ForegroundColor White -NoOutput:$NoOutput
        Write-OutputMessage "`"$VarName`"" -NoNewline -ForegroundColor Magenta -NoOutput:$NoOutput
        Write-OutputMessage "  ➡  " -NoNewline -ForegroundColor White -NoOutput:$NoOutput
        Write-OutputMessage "`"$envVar`"" -ForegroundColor $Color -NoOutput:$NoOutput
    }    

    Set-LocalEnvironmentVariable -Name $Name -Value $Value -Append:$Append -NoOutput
    if ($Append.IsPresent) {
        $value = (Get-Item "env:$Name").Value
    }
    if ($IsWindows) {
        setx "$Name" "$Value" | Out-Null
        Write-MyMessage -VarName $Name -NoOutput:$NoOutput
        return
    }
    if ($IsLinux -or $IsMacOS) {
        $pattern = "\s*export\s+$name=[\w\W]*\w*\s+>\s*\/dev\/null\s+; \s*#\s*$Name\s*"
        $files = @("~/.bashrc", "~/.zshrc", "~/.bash_profile", "~/.zprofile")
        
        $files | ForEach-Object {
            if (Test-Path -Path $_ -PathType Leaf) {
                $content = [System.IO.File]::ReadAllText("$(Resolve-Path $_)")
                $content = [System.Text.RegularExpressions.Regex]::Replace($content, $pattern, [System.Environment]::NewLine);
                $content += [System.Environment]::NewLine + "export $Name=$Value > /dev/null ; # $Name" + [System.Environment]::NewLine
                [System.IO.File]::WriteAllText("$(Resolve-Path $_)", $content)
            }
            
        }
        Write-MyMessage -VarName $Name -NoOutput:$NoOutput
        return
    }
    throw "Invalid platform."
}

function Get-JsonObject {
    param (
        [String]
        [parameter(Mandatory = $true)]
        $Filename
    )
    
    if (Test-Path $Filename -PathType Leaf) {
        return (Get-Content -Path $Filename | ConvertFrom-Json)
    }
    
    throw "Invalid file `"$Filename`""
}

function Set-JsonObject {
    param (
        [object]
        [parameter(Mandatory = $true, Position = 0)]
        $Value,

        [String]
        [parameter(Mandatory = $true, Position = 1)]
        $Filename
    )
    
    $json = ConvertTo-Json $Value
    Set-Content $Filename -Value $json
}

function Get-ItemTree {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $Path = ".",

        [Parameter()]
        [System.String]
        $Include = "*",

        [Parameter()]
        [switch]
        $IncludePath,

        [Parameter()]
        [switch]
        $Force

    )
    $result = @()
    if (!(Test-Path $Path)) {
        throw "Invalid path. The path `"$Path`" doesn't exist." #Test if path is valid.
    }
    if (Test-Path $Path -PathType Container) {
        $result += (Get-ChildItem "$Path" -Include "$Include" -Force:$Force -Recurse) # Add all items inside of a container, if path is a container.
    }
    if ($IncludePath.IsPresent) {
        $result += @(Get-Item $Path -Force) # Add the $Path in the result.
    }
    $result = , @($result | Sort-Object -Descending -Unique -Property "PSPath") # Sort elements by PSPath property, order in descending, remove duplicates with unique.
    return  $result
}

function Remove-ItemTree {
    [CmdletBinding()]
    param (
        [Parameter()]
        [System.String]
        $Path
    )
    (Get-ItemTree -Path $Path -Force -IncludePath) | ForEach-Object {
        Remove-Item "$($_.PSPath)" -Force
        if ($PSBoundParameters.ContainsKey("Verbose")) {
            Write-InfoYellow -Information "Deleted: $($_.PSPath)"
        }
    }
}

function Get-WslPath {
    param (
        [string]$Path
    )
    if ($Path -match '^([A-Za-z]):[\\\/]') {
        $drive = $matches[1].ToLower()
        $result = "/mnt/$drive" + ($Path -replace '^([A-Za-z]):[\\\/]', '/')
        $result = $result.Replace("\", "/")
        return $result 
    }
    else {
        throw "Invalid path '$Path'."
    }
}

function Test-GitRepository {
    param (
        [Parameter()]
        [System.String]
        $Path,

        [Parameter()]
        [switch]
        $NoOutput
    )
    if (!(Test-Path $Path -PathType Container)) {
        return $false
    }
    try {
        Push-Location $Path
        $result = $(Test-ExternalCommand "git rev-parse --is-inside-work-tree --quiet" -NoOutput:$NoOutput -NoAssertion)
        return $result
    }
    finally {
        Pop-Location
    }
}

function Test-GitRemoteUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    try {
        Push-Location $Path
        $remoteUrl = & git remote get-url origin
        return ($remoteUrl -eq $Url)
    }
    catch {
        return $false
    }
    finally {
        Pop-Location
    }
}

function Add-GitSafeDirectory {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Path, 

        [Parameter()]
        [ValidateSet("system", "global", "local", "worktree")]
        [string]
        $ConfigFile = "global"

    )
    if (!(Test-Path $Path -PathType Container)) {
        throw "Invalid path: $Path"
    }
    $null = Test-ExternalCommand "git config --$ConfigFile --fixed-value --replace-all safe.directory ""$Path"" ""$Path""" -ThrowOnFailure -NoAssertion
}

function Reset-GitRepositoryHard {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [string]
        $RemoteName = "origin",

        [Parameter()]
        [string]
        $BranchName = "main"
    )
        
    if (Test-GitRepository $Path) {
        try {
            Push-Location "$Path"
            $null = Test-ExternalCommand "git fetch $RemoteName $BranchName" -ThrowOnFailure -NoAssertion
            $null = Test-ExternalCommand "git reset --hard $RemoteName/$BranchName" -ThrowOnFailure -NoAssertion
            $null = Test-ExternalCommand "git checkout $BranchName" -ThrowOnFailure -NoAssertion
        }
        finally {
            Pop-Location 
        }
    }
    else {
        throw "Path ""$Path"" is not a repository."
    }
}

function Update-GitSubmodules {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force
    )
    
    try {
        Push-Location "$Path"
        $null = Test-ExternalCommand -Command "git submodule init" -ThrowOnFailure
        $null = Test-ExternalCommand -Command "git submodule update --init --recursive $($Force.IsPresent ? "--force" : [string]::Empty)" -ThrowOnFailure
        $null = Test-ExternalCommand -Command "git submodule update --remote --recursive $($Force.IsPresent ? "--force" : [string]::Empty)" -ThrowOnFailure
    }
    catch {
        throw "Error: Update-GitSubmodules"
    }
    finally {
        Pop-Location
    }
}

function Install-GitRepository {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $true)]
        [string]
        $Path,

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [string]
        $RemoteName = "origin",

        [Parameter()]
        [string]
        $BranchName = "main",

        [Parameter()]
        [ValidateSet("system", "global", "local", "worktree")]
        [string]
        $ConfigFile = "global"

    )
    $isRepo = Test-GitRepository $Path

    if ($isRepo) {
        if (Test-GitRemoteUrl -Url $Url -Path $Path) {
            Reset-GitRepositoryHard -Path "$Path" -RemoteName "$RemoteName" -BranchName "$BranchName"
            Add-GitSafeDirectory -ConfigFile $ConfigFile -Path $Path
        }
        else {
            if ($Force.IsPresent) {
                Remove-Item -Path "$Path" -Force -Recurse -ErrorAction Ignore
                New-Item -Path "$Path" -Force -ItemType Directory | Out-Null
                git clone "$Url" "$Path"
                Add-GitSafeDirectory -ConfigFile $ConfigFile -Path $Path
            }
            else {
                throw "It seems there is a different Git repository in path ""$Path"". Use -Force to replace directory."
            }
        }   
    }
    else {
        Remove-Item -Path "$Path" -Force -Recurse -ErrorAction Ignore
        New-Item -Path "$Path" -Force -ItemType Directory | Out-Null
        $null = Test-ExternalCommand "git clone ""$Url"" ""$Path""" -ThrowOnFailure -NoAssertion
        Add-GitSafeDirectory -ConfigFile $ConfigFile -Path $Path
    }
}

function Get-ProjectSecretsId {
    param (
        [string]
        [Parameter()]
        $Project
    )
    $xml = [System.Xml.Linq.XDocument]::Parse((Get-Content -Path $Project -Raw))
    return $xml.Root.Elements("PropertyGroup").Elements("UserSecretsId").Value;
}

function Get-TextEditor {
    param (
        [string]
        [Parameter()]
        $Editor = "code"
    )

    if (Get-Command $Editor -ErrorAction Ignore) {
        return $Editor
    }

    if (Get-Command "code" -ErrorAction Ignore) {
        return "code"
    }

    if ($IsWindows) {
        return "notepad.exe"
    }
    if ($IsLinux) {
        if (Get-Command "nano" -ErrorAction Ignore) {
            return "nano"
        }

        if (Get-Command "vim" -ErrorAction Ignore) {
            return "vim"
        }

        if (Get-Command "vi" -ErrorAction Ignore) {
            return "vi"
        }
        
    }
    if ($IsMacOS) {
        return "open -e"
    }

    throw "No text editor was found."
}

function Get-ProjectUserSecretsFilename {
    param (
        [string]
        [Parameter()]
        $SecretsId
    )
    return Select-ValueByPlatform -WindowsValue "$($env:APPDATA)\Microsoft\UserSecrets\$SecretsId\secrets.json" -LinuxValue "$(Get-UserHome)/.microsoft/usersecrets/$SecretsId/secrets.json" -MacOSValue "$(Get-UserHome)/.microsoft/usersecrets/$SecretsId/secrets.json"
}

function Edit-ProjectUserSecrets {
    param (
        [string]
        [Parameter()]
        $ProjectFileName = "*.csproj",

        [string]
        [Parameter()]
        $Editor = "code"
    )
    
    $ProjectFileName = (Get-Item -Path $ProjectFileName).FullName
    Write-PrettyKeyValue "██ Opening secrets for project" "`"$projectFilename`"" -LabelForegroudColor Blue
    
    $secretsId = Get-ProjectSecretsId $projectFilename
    if ([string]::IsNullOrWhiteSpace($secretsId)) {
        Write-InfoBlue "█ Initializing secrets"
        dotnet user-secrets init --project $projectFilename
    }
    $secretsId = Get-ProjectSecretsId $projectFilename
    Write-PrettyKeyValue "UserSecretsId" $secretsId -LabelForegroudColor Blue

    $SecretsFilename = (Get-ProjectUserSecretsFilename $secretsId)
    Write-PrettyKeyValue "█ Secrets - Json file" "$SecretsFilename" -LabelForegroudColor Blue
    if (!(Test-Path $SecretsFilename -PathType Leaf)) {
        New-Item $SecretsFilename -Value "{$([System.Environment]::NewLine)   $([System.Environment]::NewLine)}" -Force
    }

    $Editor = Get-TextEditor $Editor
    & $editor $SecretsFileName 
}

function Show-ProjectUserSecrets {
    param (
        [string]
        [Parameter()]
        $ProjectFileName = "*.csproj"
    )
    
    $ProjectFilename = (Get-Item -Path $ProjectFileName).FullName
    Write-PrettyKeyValue "██ Listing secrets for project" "`"$ProjectFilename`"" -LabelForegroudColor Blue
    
    $secretsId = Get-ProjectSecretsId $ProjectFilename
    if ([string]::IsNullOrWhiteSpace($secretsId)) {
        Write-InfoBlue "█ Initializing secrets"
        dotnet user-secrets init --project $ProjectFilename
    }
    $secretsId = Get-ProjectSecretsId $ProjectFilename
    Write-PrettyKeyValue "UserSecretsId" $secretsId -LabelForegroudColor Blue
    
    Write-InfoBlue "█ Secrets in project"
    dotnet user-secrets list --project $ProjectFilename
    $SecretsFilename = (Get-ProjectUserSecretsFilename $secretsId)
    Write-PrettyKeyValue "█ Secrets - Json file" "$SecretsFilename" -LabelForegroudColor Blue
    if (!(Test-Path $SecretsFilename -PathType Leaf)) {
        New-Item $SecretsFilename -Value "{$([System.Environment]::NewLine)   $([System.Environment]::NewLine)}" -Force
    }
    Write-Host (Get-Content -Path (Get-ProjectUserSecretsFilename $secretsId) -Raw)

}

function Test-ExternalCommand {
    param (
        [string]$Command,

        [switch]
        $NoOutput, 

        [switch]
        $ThrowOnFailure,

        [switch]
        $ShowExitCode,

        [int[]]
        $AllowedExitCodes = @(0),

        [switch]
        $NoAssertion
    )
    try {
        Write-OutputMessage "⚡ Running Command: $Command" -NoOutput:$NoOutput
        if ($NoOutput.IsPresent) {
            Invoke-Expression -Command "& $Command" | Out-Null
        }
        else {
            Invoke-Expression -Command "& $Command" | Out-Host
        }
        $exitCode = $LASTEXITCODE
        if ($ShowExitCode.IsPresent) {
            Write-OutputMessage "ExitCode: $exitCode" -NoOutput:$NoOutput
        }
        if ($exitCode -in $AllowedExitCodes) {
            if (!$NoAssertion.IsPresent) {
                Write-OutputMessage "✅ [$Command]" -NoOutput:$NoOutput -ForegroundColor Green
            }
            return $true
        }
        throw
    }
    catch {
        if (!$NoAssertion.IsPresent) {
            Write-OutputMessage "❌ [$Command]" -NoOutput:$NoOutput -ForegroundColor Red
        }
        if ($ThrowOnFailure) {
            throw "An error occurred while executing the command."
        }
        return $false
    }
}

function Get-HexRandomName {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Prefix = "_",

        [Parameter()]
        [int]
        $BytesSize = 8
    )
    $bytes = [System.Security.Cryptography.RandomNumberGenerator]::GetBytes(16)
    $hexString = -join ($bytes | ForEach-Object { $_.ToString("X2") })
    return "$Prefix$hexString"
}

function Get-GitRepositoryRemoteUrl {
    param (
        [string]
        $Path = [string]::Empty
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        $Path = "$(Get-Location)"
    }
    $result = [string]::Empty
    try {
        Push-Location $Path
        return "$(Split-Path -Path (git remote get-url origin) -Leaf -ErrorAction Ignore)"
    }
    catch {
        return $result
    }
    finally {
        Pop-Location
    }
}

function Use-Disposable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [AllowNull()]
        [Object]
        $InputObject,

        [Parameter(Mandatory = $true)]
        [scriptblock]
        $ScriptBlock
    )

    try {
        . $ScriptBlock
    }
    finally {
        if ($null -ne $InputObject -and $InputObject -is [System.IDisposable]) {
            $InputObject.Dispose()
        }
    }
}

function Test-HttpUri {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $Uri
    )
    Use-Disposable($client = New-Object System.Net.Http.HttpClient) {
        try {
            $request = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Head, $Uri)
            $response = $client. SendAsync($request).WaitAsync([timespan]::FromSeconds(5)).Result
            return ($response.StatusCode -eq 'OK')
        }
        finally {
        }
        return $false;
    }
}

function Invoke-HttpDownload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Url,

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationPath,

        [Parameter()]
        [string]
        $Name = [string]::Empty,

        [Parameter()]
        [string]
        $Hash = [string]::Empty,

        [Parameter()]
        [string]
        [ValidateSet("SHA1", "SHA256", "SHA384", "SHA512", "MD5")]
        $HashAlgorithm = "SHA1",

        [Parameter()]
        [switch]
        $Force,

        [Parameter()]
        [switch]
        $ReturnFilename
    )
    Write-OutputMessage -Value "Downloading: $Url" -ForegroundColor Blue
    if (!(Test-HttpUri -Uri "$Url")) {
        throw "Resource is offline or invalid uri `"$Url`"."
    }

    New-Item -Path "$DestinationPath" -ItemType Directory -Force | Out-Null
    $filename = [string]::IsNullOrWhiteSpace($Name) ? "$DestinationPath/$([System.IO.Path]::GetFileName("$Url"))" : "$DestinationPath/$Name"
    $download = (!(Test-Path -Path "$filename" -PathType Leaf))
    
    Write-OutputMessage -Value "Preparing download `"$filename`"."
    if (![string]::IsNullOrWhiteSpace($Hash) ) {
        if (!$download) {
            $fileHash = (Get-FileHash -Path "$filename" -Algorithm "$HashAlgorithm").Hash
            $download = $download -or (!$Hash.Equals($fileHash))
        }
    }
    else {
        $download = $download -or $Force.IsPresent
    }

    if ($download) {
        Write-OutputMessage -Value "Saving `"$filename`"." 
        Invoke-WebRequest -Uri "$Url" -OutFile "$filename" 
    }
    else {
        Write-OutputMessage -Value "Already downloaded `"$filename`". Skipping download."
    }

    if (![string]::IsNullOrWhiteSpace($Hash)) {
        $fileHash = (Get-FileHash -Path "$filename" -Algorithm "$HashAlgorithm").Hash
        if (!$Hash.Equals($fileHash)) {
            throw "Verification error. Hashes are different: $Hash <> $fileHash; file: `"$filename`"."
        }
    }
    if ($ReturnFilename.IsPresent) {
        return $filename
    }
}

function Expand-TarXzArchive {
    [CmdletBinding()]
    param (
        
        [Parameter(Mandatory = $true)]
        [string]
        $Path,
        
        [Parameter()]
        [string]
        $DestinationPath = [string]::Empty
    )
    Write-OutputMessage -Value "Expanding: $Path" -ForegroundColor Blue 
    if (!($Path.ToLower().EndsWith(".tar.xz"))) {
        throw "Invalid file extension. File: `"$($Path)`"."
    }
    $tarXzFile = $Path
    $tarFile = "$($Path | Split-Path)/$([System.IO.Path]::GetFileNameWithoutExtension($Path))"
    if ($IsWindows) {
        
        & "$__PSCOREFXS_7_ZIP_EXE" x -aoa -o"$DestinationPath" "$tarXzFile"
        & "$__PSCOREFXS_7_ZIP_EXE" x -aoa -o"$DestinationPath" -r "$tarFile"
        Remove-Item -Force -Path "$tarFile" -ErrorAction Ignore
    }
    if ($IsLinux -or $IsMacOS) {
        & tar -xf "$Path" -C "$DestinationPath" --overwrite
    }  
    Write-Host "Finished expand."
}

function Expand-ZipArchive {
    [CmdletBinding()]
    param (
        
        [Parameter(Mandatory = $true)]
        [string]
        $Path,
        
        [Parameter()]
        [string]
        $DestinationPath = [string]::Empty
    )
    process {
        $DestinationPath = [string]::IsNullOrWhiteSpace($DestinationPath) ? "$(Get-Location)" : $DestinationPath
        Write-OutputMessage 
        Write-OutputMessage -Value "Expanding: `"$Path`", Destination: `"$DestinationPath`"" -ForegroundColor Blue  
        if (!($Path.ToLower().EndsWith(".zip"))) {
            throw "Invalid file extension. File: `"$($Path)`"."
        }
        if ($IsWindows) {
            & "$__PSCOREFXS_7_ZIP_EXE" x -aoa -o"$DestinationPath" "$Path"
        }
        if ($IsLinux -or $IsMacOS) {
            & unzip -oq "$Path" -d "$DestinationPath" 
        }  
        Write-Host "Finished expand."
    }
}

function Join-CompileCommandsJson {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SourceDir,
        
        [Parameter(Mandatory = $true)]
        [string]
        $DestinationDir,

        [Parameter()]
        [string]
        $FilesExtension = ".compile_commands.json"
    )
    $jsonFiles = Get-ChildItem "$SourceDir/*$FilesExtension"  
    $encoding = [System.Text.Encoding]::UTF8 
    $CompilationDatabase = "$DestinationDir/compile_commands.json"
    [System.Text.StringBuilder]$jsonContent = [System.Text.StringBuilder]::new()
    $jsonContent.Append("[") | Out-Null
    $jsonFiles | ForEach-Object {
        $jsonContent.Append([System.IO.File]::ReadAllText($_.FullName)) | Out-Null
    }
    $json = $jsonContent.ToString().Trim().TrimEnd(',') + "]"
    [System.IO.File]::WriteAllText($CompilationDatabase, $json, $encoding)
}

function New-CppLibsDir {
    New-Item -Path "$__PSCOREFXS_CPP_LIBS_DIR" -ItemType Directory -Force | Out-Null
}

function Get-CppLibsDir {
    return "$__PSCOREFXS_CPP_LIBS_DIR"
}

function Get-OsName {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Minimal
    )
    if ($Minimal.IsPresent) {
        return Select-ValueByPlatform -WindowsValue "Windows" -LinuxValue "Linux" -MacOSValue "MacOS"
    }
    if ($IsWindows) {
        return (Get-CimInstance Win32_OperatingSystem).Caption
    }
    if ($IsLinux) {
        return "$(& lsb_release -d)".Split(":")[1].Trim()
    }
    if ($IsMacOS) {
        return "$(& sw_vers -productName) $(& sw_vers -productVersion)"
    }
    throw "Not supported, unknown operating system."
}


# ███ Vcvarsall.bat

class VisualStudioVersionValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return @($Global:__PSCOREFXS_VISUAL_STUDIO_VERSION_2022)
    }
}

class VisualStudioEditionValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return @($Global:__PSCOREFXS_VISUAL_STUDIO_EDITION_COMMUNITY, $Global:__PSCOREFXS_VISUAL_STUDIO_EDITION_PROFESSIONAL, $Global:__PSCOREFXS_VISUAL_STUDIO_EDITION_ENTERPRISE)
    }
}

function Get-VcvarsScriptPath {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateSet([VisualStudioVersionValidateSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        [string]
        $VisualStudioVersion,

        [Parameter()]
        [ValidateSet([VisualStudioEditionValidateSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        [string]    
        $VisualStudioEdition
    )
    return "C:/Program Files/Microsoft Visual Studio/$VisualStudioVersion/$VisualStudioEdition/VC/Auxiliary/Build/vcvarsall.bat" 
}

function Set-Vcvars {
    param (
        [Parameter()]
        [string[]]
        $Parameters = @(),

        [Parameter()]
        [ValidateSet([VisualStudioVersionValidateSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        [string]
        $VisualStudioVersion,

        [Parameter()]
        [ValidateSet([VisualStudioEditionValidateSet], IgnoreCase = $false, ErrorMessage = "Value `"{0}`" is invalid. Try one of: `"{1}`"")]
        [string]    
        $VisualStudioEdition,

        [Parameter()]
        [switch]
        $ShowValues
    )

    if (!$IsWindows) {
        throw "Windows x64 operating system is required."
    }
    if (!($env:PROCESSOR_ARCHITECTURE -eq "AMD64")) {
        throw "Windows x64 operating system is required."
    }

    Write-Host
    Write-InfoGreen "Initialize environment "
    $vcvars = Get-VcvarsScriptPath -VisualStudioVersion $VisualStudioVersion -VisualStudioEdition $VisualStudioEdition
    if (!(Test-Path -Path $vcvars -PathType Leaf)) {
        throw "Invalid vcvars file, it doesn't exist. ""$vcvars"""
    }
    Write-InfoBlue "Running: $vcvars"
    Write-Host

    $pattern = "^([^\s=]+)=(.*)$"
    & cmd /c """$vcvars"" $Parameters  && SET" | . { process {
            $result = [System.Text.RegularExpressions.Regex]::Matches($_, $pattern)
            if ($result.Success) {
                Set-LocalEnvironmentVariable "$($result.Groups[1].Value)" "$($result.Groups[2].Value)" -NoOutput
                if ($ShowValues.IsPresent) {
                    Write-Host "$($result.Groups[1].Value)" -NoNewline -ForegroundColor Green
                    Write-Host "=" -NoNewline -ForegroundColor Yellow
                    Write-Host  "`"$($result.Groups[2].Value)`"" -ForegroundColor White
                }
            }
            else {
                Write-InfoDarkGray $_
            }
        } 
    }
    Write-Host      
}

# ███ Emscripten

function Set-EmscriptenSDKEnvironmentVariables {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Clean
    )
    Write-OutputMessage "$($Clean.IsPresent ? "Cleaning" : "Setting") Emscripten SDK environment variables" -ForegroundColor Blue 
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_SDK_DIR" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_DIR" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_ROOT_DIR" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_COMPILER" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_COMPILER_EXE" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_EMCC" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_EMCC_EXE" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_EMCXX" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_EMCXX_EXE" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_EMRUN" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_EMRUN_EXE" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_EMMAKE" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_EMMAKE_EXE" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_EMAR" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_EMAR_EXE" )
    Set-PersistentEnvironmentVariable -Name "EMSCRIPTEN_EMCONFIGURE" -Value ($Clean.IsPresent ? [string]::Empty : "$__PSCOREFXS_EMSCRIPTEN_SDK_EMCONFIGURE_EXE" )
}

function Test-EmscriptenSDKDependencies {
    [CmdletBinding()]
    param (
    )
    Write-OutputMessage "Testing Emscripten - Dependency tools" -ForegroundColor Blue
    Assert-PythonExecutable  
    Assert-GitExecutable
}

function Install-EmscriptenSDK {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Force
    )
        
    process {
        Write-OutputMessage "Installing Emscripten SDK - Path: `"$__PSCOREFXS_EMSCRIPTEN_SDK_DIR`"" -ForegroundColor Blue
        if ($Force) {
            Remove-EmscriptenSDK 
        }
        Test-EmscriptenSDKDependencies 
        Set-EmscriptenSDKEnvironmentVariables 
    
        Write-OutputMessage -Value "Installing on `"$__PSCOREFXS_EMSCRIPTEN_SDK_DIR`"" 
        Install-GitRepository -Url "$__PSCOREFXS_EMSCRIPTEN_SDK_REPO_URL" -Path "$__PSCOREFXS_EMSCRIPTEN_SDK_DIR" -Force
        $null = Test-ExternalCommand "git -C `"$__PSCOREFXS_EMSCRIPTEN_SDK_DIR`" pull" -ThrowOnFailure -NoAssertion
        $null = Test-ExternalCommand "`"$__PSCOREFXS_EMSCRIPTEN_SDK_EXE`" install latest" -ThrowOnFailure -ShowExitCode -NoAssertion
        $null = Test-ExternalCommand "`"$__PSCOREFXS_EMSCRIPTEN_SDK_EXE`" activate latest" -ThrowOnFailure -ShowExitCode  -NoAssertion
    }
}

function Remove-EmscriptenSDK {    
    Write-OutputMessage "Removing Emscripten SDK - Path: `"$__PSCOREFXS_EMSCRIPTEN_SDK_DIR`"" -ForegroundColor Blue
    Remove-Item -Path "$__PSCOREFXS_EMSCRIPTEN_SDK_DIR" -Force -Recurse -ErrorAction Ignore
    Set-EmscriptenSDKEnvironmentVariables -Clean 
    Write-Host "SDK removed."
}

# ███ Android NDK functions

class AndroidNDKApiValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return $Global:__PSCOREFXS_ANDROID_NDK_API_NUMBERS
    }

    static [String[]] $ValidValues = [AndroidNDKApiValidateSet]::new().GetValidValues()
    static [bool] IsValidApi([string] $api) {
        return ($api -in [AndroidNDKApiValidateSet]::ValidValues)
    }
}

function Test-AndroidNDKApi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Api
    )
    return [AndroidNDKApiValidateSet]::IsValidApi($Api)
}

function Assert-AndroidNDKApi {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Api
    )
    Write-OutputMessage "Validating Android API number [$Api]: " -ForegroundColor Magenta -NoNewLine
    if (Test-AndroidNDKApi -Api $Api) {
        Write-OutputMessage "OK." 
        return
    } 
    throw "Invalid Android NDK API `"$Api`"."
    
}

function Mount-DmgImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $DiskImageFilename,

        [Parameter(Mandatory = $true)]
        [string]
        $MountPoint
    )
    Test-OnlyMacOS
    Write-OutputMessage "Mounting: `"$DiskImageFilename`" in `"$MountPoint`", "
    & hdiutil mount "$DiskImageFilename" -mountpoint "$MountPoint"
}

function Dismount-DmgImage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $MountPoint
    )
    Test-OnlyMacOS
    Write-OutputMessage "Dismounting: `"$MountPoint`""
    & hdiutil detach "$MountPoint"
}

function Install-AndroidNDK {
    param (
        [Parameter()]
        [switch]
        $Force
    )
    Write-OutputMessage "Installing Android NDK - Path: `"$__PSCOREFXS_ANDROID_NDK_TEMP_DIR`"" -ForegroundColor Blue
    $ndkVariant = $__PSCOREFXS_ANDROID_NDK_OS_VARIANTS["$(Get-OsName -Minimal)"]
    $ndkDirExists = $(Test-Path -Path "$__PSCOREFXS_ANDROID_NDK_DIR")
    $downloadedFilename = Invoke-HttpDownload -Url "$($ndkVariant.Url)" -DestinationPath "$__PSCOREFXS_ANDROID_NDK_TEMP_DIR" -Hash "$($ndkVariant.Sha1)" -HashAlgorithm SHA1 -Force:$ForceDownload -ReturnFilename
    
    if (!$ndkDirExists -or $Force.IsPresent) {
        if ($IsLinux -or $IsWindows) {
            Expand-ZipArchive -Path "$downloadedFilename" -DestinationPath "$__PSCOREFXS_ANDROID_NDK_TEMP_DIR" 
        }
        if ($IsMacOS) {
            $mountPoint = "/Volumes/android-ndk-$($__PSCOREFXS_ANDROID_NDK_VERSION)"
            Mount-DmgImage -MountPoint "$mountPoint" -DiskImageFilename "$downloadedFilename"
            Write-PrettyKeyValue "NDK Destination: `"$__PSCOREFXS_ANDROID_NDK_DIR`""
            New-Item -Path "$__PSCOREFXS_ANDROID_NDK_DIR" -ItemType Directory -Force | Out-Null
            & sh -c "cp -R -f -u '$mountPoint/$($ndkVariant.NdkInternalMountedDir)/' '$__PSCOREFXS_ANDROID_NDK_DIR'"
            Dismount-DmgImage -MountPoint "$mountPoint"
        }
    }
    else {
        Write-OutputMessage -Value "Skipping expand archive `"$downloadedFilename`". Already installed." 
    }
    
    Get-Item -Path "$__PSCOREFXS_ANDROID_NDK_TEMP_DIR/*" -Exclude @("$([System.IO.Path]::GetFileName($downloadedFilename))", "$($__PSCOREFXS_ANDROID_NDK_DIR | Split-Path -Leaf)") | Remove-Item -Force -Recurse -ErrorAction Ignore
}

function Remove-AndroidNDK {
    Write-OutputMessage "Removing Android NDK - Path: `"$__PSCOREFXS_ANDROID_NDK_TEMP_DIR`"" -ForegroundColor Blue    
    Remove-Item -Path "$__PSCOREFXS_ANDROID_NDK_TEMP_DIR" -Force -Recurse -ErrorAction Ignore
    Write-OutputMessage -Value "Android NDK removed."
    
}

# █ Assert executables functions

function Assert-Executable {
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $ExeName,

        [Parameter()]
        [string[]]
        $Parameters = @()
    )

    Write-OutputMessage "Testing executable: [$ExeName]" -ForegroundColor Magenta 
    Write-Host
    $command = Get-Command "$ExeName"
    $Parameters = $Parameters | ForEach-Object {
        $parameter = $_
        if ($parameter.Contains("{0}") -or $parameter.Contains("{1}")) {
            $parameter = [string]::Format($parameter, $command.Name, $command.Source)
        }
        $parameter
    }
    $null = Test-ExternalCommand -Command "`"$($command.Source)`" $($Parameters -join " ")" -NoAssertion
    Write-Host
}

function Assert-WslExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_WSL_EXE" -Parameters @("--version")
}

function Assert-7ZipExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_7_ZIP_EXE" -Parameters @("h", "`"{1}`"")
}

function Assert-VsCodeExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_VSCODE_EXE" -Parameters @("--version")
}

function Assert-NinjaBuildExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_NINJA_EXE" -Parameters @("--version")
}

function Assert-PythonExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_PYTHON_EXE" -Parameters @("--version")
}

function Assert-NodeExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_NODE_EXE" -Parameters @("--version")
}

function Assert-DenoExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_DENO_EXE" -Parameters @("--version")
}

function Assert-JavaExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_JAVA_EXE" -Parameters @("--version")
}

function Assert-MakeExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_MAKE_EXE" -Parameters @("--version")
}

function Assert-GitExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_GIT_EXE" -Parameters @("--version")
}

function Assert-TarExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_TAR_EXE" -Parameters @("--version")
}

function Assert-UnzipExecutable {
    Assert-Executable -ExeName "$__PSCOREFXS_TAR_EXE" -Parameters @("--version")
}

# █ Validation Sets
class BuildConfigurationValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [String[]] GetValidValues() {
        return @("Debug", "Release")
    }
}
# ███ Constants

# █ Misc Constants
Set-GlobalConstant -Name "__PSCOREFXS_TEMP_DIR" -Value "$(Get-UserHome)/.PsCoreFxs"
Set-GlobalConstant -Name "__PSCOREFXS_REPO_URL" -Value "https://github.com/Satancito/PsCoreFxs.git" 
Set-GlobalConstant -Name "__PSCOREFXS_REPO_NAME" -Value $([System.IO.Path]::GetFileNameWithoutExtension("https://github.com/Satancito/PsCoreFxs.git") )
Set-GlobalConstant -Name "__PSCOREFXS_CPP_LIBS_DIR" -Value "$(Get-UserHome)/.CppLibs"
Set-GlobalConstant -Name "__PSCOREFXS_CLANGD_COMPILATION_DATABASE_JSON" -Value "compile_commands.json"
Set-GlobalConstant -Name "__PSCOREFXS_CLANGD_COMPILATION_DATABASE_JSON_WITHOUT_EXTENSION" -Value "compile_commands"

# █ Executables
Set-GlobalConstant -Name "__PSCOREFXS_7_ZIP_EXE" -Value "7z.exe"
Set-GlobalConstant -Name "__PSCOREFXS_WSL_EXE" -Value "wsl.exe"
Set-GlobalConstant -Name "__PSCOREFXS_VSCODE_EXE" -Value $(Select-ValueByPlatform -WindowsValue "code.com" -LinuxValue "code" -MacOSValue "code")
Set-GlobalConstant -Name "__PSCOREFXS_NINJA_EXE" -Value $(Select-ValueByPlatform -WindowsValue "ninja.exe" -LinuxValue "ninja" -MacOSValue "ninja")
Set-GlobalConstant -Name "__PSCOREFXS_PYTHON_EXE" -Value $(Select-ValueByPlatform -WindowsValue "python.exe" -LinuxValue "python" -MacOSValue "python")
Set-GlobalConstant -Name "__PSCOREFXS_NODE_EXE" -Value $(Select-ValueByPlatform -WindowsValue "node.exe" -LinuxValue "node" -MacOSValue "node")
Set-GlobalConstant -Name "__PSCOREFXS_DENO_EXE" -Value $(Select-ValueByPlatform -WindowsValue "deno.exe" -LinuxValue "deno" -MacOSValue "deno")
Set-GlobalConstant -Name "__PSCOREFXS_JAVA_EXE" -Value $(Select-ValueByPlatform -WindowsValue "java.exe" -LinuxValue "java" -MacOSValue "java")
Set-GlobalConstant -Name "__PSCOREFXS_MAKE_EXE" -Value $(Select-ValueByPlatform -WindowsValue "make.exe" -LinuxValue "make" -MacOSValue "make")
Set-GlobalConstant -Name "__PSCOREFXS_GIT_EXE" -Value $(Select-ValueByPlatform -WindowsValue "git.exe" -LinuxValue "git" -MacOSValue "git")
Set-GlobalConstant -Name "__PSCOREFXS_TAR_EXE" -Value $(Select-ValueByPlatform -WindowsValue "tar.exe" -LinuxValue "tar" -MacOSValue "tar")
Set-GlobalConstant -Name "__PSCOREFXS_UNZIP_EXE" -Value "unzip"


# █ Vcvarsall.bat constants
Set-GlobalConstant -Name "__PSCOREFXS_VCVARS_ARCH_X86" -Value "x86"
Set-GlobalConstant -Name "__PSCOREFXS_VCVARS_ARCH_X64" -Value "x64"
Set-GlobalConstant -Name "__PSCOREFXS_VCVARS_ARCH_ARM" -Value "x64_arm"
Set-GlobalConstant -Name "__PSCOREFXS_VCVARS_ARCH_ARM64" -Value "x64_arm64"

Set-GlobalConstant -Name "__PSCOREFXS_VCVARS_PLATFORM_TYPE_UWP" -Value "uwp"
Set-GlobalConstant -Name "__PSCOREFXS_VCVARS_SPECTRE_MODE_PARAMETER" -Value "-vcvars_spectre_libs=spectre"

# █ Visual Studio constants
Set-GlobalConstant -Name "__PSCOREFXS_VISUAL_STUDIO_VERSION_2022" -Value "2022"

Set-GlobalConstant -Name "__PSCOREFXS_VISUAL_STUDIO_EDITION_COMMUNITY" -Value "Community"
Set-GlobalConstant -Name "__PSCOREFXS_VISUAL_STUDIO_EDITION_PROFESSIONAL" -Value "Professional"
Set-GlobalConstant -Name "__PSCOREFXS_VISUAL_STUDIO_EDITION_ENTERPRISE" -Value "Enterprise"

# █ DbProviders constans     TODO: Rename
Set-GlobalConstant -Name "SQLSERVER_PROVIDER" -Value "SqlServer"
Set-GlobalConstant -Name "POSTGRESQL_PROVIDER" -Value "PostgreSql"
Set-GlobalConstant -Name "MYSQL_PROVIDER" -Value "MySql"
Set-GlobalConstant -Name "ORACLE_PROVIDER" -Value "Oracle"
Set-GlobalConstant -Name "ALL_PROVIDER" -Value "All"

# █ Nuget constants
Set-GlobalConstant -Name "__PSCOREFXS_NUGET_ORG_V3_URI" -Value "https://api.nuget.org/v3/index.json"

# █ Emscripten constants
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_REPO_URL" -Value "https://github.com/emscripten-core/emsdk.git"
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_DIR" -Value "$(Get-UserHome)/.emsdk" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_DIR/$(Select-ValueByPlatform -WindowsValue "emsdk.bat" -LinuxValue "emsdk" -MacOSValue "emsdk")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_DIR/upstream/emscripten" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_COMPILER_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "em++.bat" -LinuxValue "em++" -MacOSValue "em++")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EMCC_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "emcc.bat" -LinuxValue "emcc" -MacOSValue "emcc")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EMCXX_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "em++.bat" -LinuxValue "em++" -MacOSValue "em++")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EMRUN_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "emrun.bat" -LinuxValue "emrun" -MacOSValue "emrun")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EMMAKE_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "emmake.bat" -LinuxValue "emmake" -MacOSValue "emmake")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EMAR_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "emar.bat" -LinuxValue "emar" -MacOSValue "emar")" 
Set-GlobalConstant -Name "__PSCOREFXS_EMSCRIPTEN_SDK_EMCONFIGURE_EXE" -Value "$__PSCOREFXS_EMSCRIPTEN_SDK_ROOT_DIR/$(Select-ValueByPlatform -WindowsValue "emconfigure.bat" -LinuxValue "emconfigure" -MacOSValue "emconfigure")" 

# █ Android NDK constants
Set-GlobalConstant -Name "__PSCOREFXS_ANDROID_NDK_TEMP_DIR" -Value "$(Get-UserHome)/.android-ndk" 
Set-GlobalConstant -Name "__PSCOREFXS_ANDROID_NDK_API_NUMBERS" -Value @("21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34") # Update on new available Android API. 
Set-GlobalVariable -Name "__PSCOREFXS_ANDROID_NDK_VERSION" -Value "r26c" #Update on next NDK version. 
Set-GlobalVariable -Name "__PSCOREFXS_ANDROID_NDK_DIR" -Value "$__PSCOREFXS_ANDROID_NDK_TEMP_DIR/android-ndk-$__PSCOREFXS_ANDROID_NDK_VERSION" #Update on next NDK version.
Set-GlobalVariable -Name "__PSCOREFXS_ANDROID_NDK_CLANG_PLUS_PLUS_EXE_SUFFIX" -Value "$(Select-ValueByPlatform -WindowsValue "clang++.cmd" -LinuxValue "clang++" -MacOSValue "clang++")"
Set-GlobalVariable -Name "__PSCOREFXS_ANDROID_NDK_AR_EXE" -Value "$(Select-ValueByPlatform -WindowsValue "llvm-ar.exe" -LinuxValue "llvm-ar" -MacOSValue "llvm-ar")"
Set-GlobalVariable -Name "__PSCOREFXS_ANDROID_NDK_OS_VARIANTS" -Value $([ordered]@{
        Windows = @{ 
            Url           = "https://dl.google.com/android/repository/android-ndk-$__PSCOREFXS_ANDROID_NDK_VERSION-windows.zip" #Update on next NDK version.
            Sha1          = "f8c8aa6135241954461b2e3629cada4722e13ee7".ToUpper() #Update on next NDK version.
            HostTag       = "windows-x86_64"
            ToolchainsDir = "$__PSCOREFXS_ANDROID_NDK_DIR/toolchains/llvm/prebuilt/windows-x86_64" #Update on next NDK version.
        }
        Linux   = @{ 
            Url           = "https://dl.google.com/android/repository/android-ndk-$__PSCOREFXS_ANDROID_NDK_VERSION-linux.zip" #Update on next NDK version.
            Sha1          = "7faebe2ebd3590518f326c82992603170f07c96e".ToUpper() #Update on next NDK version.
            HostTag       = "linux-x86_64"
            ToolchainsDir = "$__PSCOREFXS_ANDROID_NDK_DIR/toolchains/llvm/prebuilt/linux-x86_64" #Update on next NDK version.
        }
        MacOS   = @{ 
            Url                   = "https://dl.google.com/android/repository/android-ndk-$__PSCOREFXS_ANDROID_NDK_VERSION-darwin.dmg" #Update on next NDK version.
            Sha1                  = "9d86710c309c500aa0a918fa9902d9d72cca0889".ToUpper() #Update on next NDK version.
            HostTag               = "darwin-x86_64"
            ToolchainsDir         = "$__PSCOREFXS_ANDROID_NDK_DIR/toolchains/llvm/prebuilt/darwin-x86_64" #Update on next NDK version.
            NdkInternalMountedDir = "AndroidNDK11394342.app/Contents/NDK" #Update on next NDK version.
        }
    })

Set-GlobalVariable -Name "__PSCOREFXS_ANDROIDNDK_ANDROID_ABI_CONFIGURATIONS" -Value $([ordered]@{
        Arm   = @{ 
            Name    = "Arm"
            NameDebug    = "Arm-Debug"
            NameRelease    = "Arm-Release"
            Abi     = "armv7a"
            Triplet = "armv7a-linux-androideabi"
        }
        Arm64 = @{ 
            Name    = "Arm64"
            NameDebug    = "Arm64-Debug"
            NameRelease    = "Arm64-Release"
            Abi     = "aarch64"
            Triplet = "aarch64-linux-android"
        }
        X86   = @{ 
            Name    = "X86"
            NameDebug    = "X86-Debug"
            NameRelease    = "X86-Release"
            Abi     = "x86"
            Triplet = "i686-linux-android"
        }
        X64   = @{ 
            Name    = "X64"
            NameDebug    = "X64-Debug"
            NameRelease    = "X64-Release"
            Abi     = "x86-64"
            Triplet = "x86_64-linux-android"
        }
    })

Set-GlobalVariable -Name "__PSCOREFXS_WINDOWS_ARCH_CONFIGURATIONS" -Value $([ordered]@{
        X86   = @{ 
            Name              = "X86"
            VcVarsArch        = "$__PSCOREFXS_VCVARS_ARCH_X86" 
            VcVarsSpectreMode = "-vcvars_spectre_libs=spectre"
        }
        X64 = @{ 
            Name              = "X64"
            VcVarsArch        = "$__PSCOREFXS_VCVARS_ARCH_X64"
            VcVarsSpectreMode = "-vcvars_spectre_libs=spectre"
        }
        Arm64 = @{ 
            Name              = "Arm64"
            VcVarsArch        = "$__PSCOREFXS_VCVARS_ARCH_ARM64"
            VcVarsSpectreMode = "-vcvars_spectre_libs=spectre"
        }
    })
