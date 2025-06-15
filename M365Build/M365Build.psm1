function Invoke-M365Build {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulesPath,

        [Parameter(Mandatory = $true)]
        [System.String]
        $RequirementsFile,

        [Parameter(Mandatory = $false)]
        [switch]
        $InstallRequirements
    )

    $modulePath = $env:PSModulePath -split ';'

    if ($modulePath -notcontains $ModulesPath) {
        $env:PSModulePath += ";$ModulesPath"
        Write-Verbose "Added '$ModulesPath' to the PSModulePath."
    }

    if ($InstallRequirements) {
        Write-Verbose "Installing M365Build requirements..."
        Install-M365BuildRequirements -RequirementsFile $RequirementsFile
    }
    
    $Global:configData = Get-M365ConfigurationData -Path $Path -ErrorAction Stop

    $configFile = Join-Path -Path $Path -ChildPath 'configuration.ps1'

    Write-Host "Building configuration from: $configFile"
    . $configFile
    $config = OutPut -ConfigurationData $configData

    if($null -eq $config) {
        throw
    }

    $OutPutPath = Join-Path -Path (Get-Location) -ChildPath 'Output'
    Add-M365BuildMetaData -ConfigurationData $configData -Path $OutPutPath -ErrorAction Stop
}

function Install-M365BuildRequirements {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RequirementsFile,

        [Parameter(Mandatory = $false)]
        [string]$Repository
    )

    Write-Host "Installing M365Build requirements..."

    if (-Not (Test-Path -Path $RequirementsFile)) {
        Write-Error "Requirements file not found at path: $RequirementsFile"
        return
    }

    $installModuleCommonParams = @{
        Scope = 'CurrentUser'
        Force = $true
    }

    if ($Repository) {
        $installModuleCommonParams.Repository = $Repository
    }

    # reading requirements from a JSON file
    $requirements = Get-Content -Path $RequirementsFile | ConvertFrom-Json
    
    foreach ($module in $requirements) {
        Write-Host "Installing $($module.Name) version $($module.Version)"
        # If the module is not found, it will be installed from the PowerShell Gallery or the specified repository
        Install-Module @installModuleCommonParams -Name $module.Name -RequiredVersion $module.Version -ErrorAction Stop
    }

    Write-Host "Requirements installed successfully."
}

function Get-M365ConfigurationData {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $dataFile = Join-Path -Path $Path -ChildPath 'environments.yaml'

    if (-Not (Test-Path -Path $dataFile)) {
        Write-Error "Configuration file not found at path: $dataFile"
        return $null
    }

    Write-Host "Reading configuration data from: $dataFile"
    $configData = Get-Content -Path $dataFile -Raw
    $configData = @{
        AllNodes = [array]($configData | ConvertFrom-Yaml).AllNodes
    } 
    return $configData
}

function Add-M365BuildMetaData {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.Hashtable]$ConfigurationData,

        [Parameter(Mandatory = $true)]
        [System.string]$Path
    )

    $ConfigurationData.AllNodes | ConvertTo-Json -Depth 10 | Out-File -FilePath "$Path\metadata.json" -Encoding UTF8}

function Add-M365ConfigurationNode {
    param (
        [Parameter(Mandatory = $true)]
        [string]$NodeName,
        [Parameter(Mandatory = $true)]
        [hashtable]$Authentication
    )

    Write-Host "Adding M365Build configuration node: $NodeName"
    Write-Host "Authentication Data: $($Authentication | Out-String)"
}

function Add-M365ConfigurationModule {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$ModuleVersion
    )

    Write-Host "Adding M365Build configuration module: $ModuleName, Version: $ModuleVersion"
}

function Add-M365ConfigurationResource {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ResourceName,
        [Parameter(Mandatory = $true)]
        [string]$ResourceType
    )

    Write-Host "Adding M365Build configuration resource: $ResourceName, Type: $ResourceType"
}

Export-ModuleMember -Function '*'