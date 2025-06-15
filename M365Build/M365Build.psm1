function Invoke-M365Build {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ModulesPath
    )

    $modulePath = $env:PSModulePath -split ';'

    if ($modulePath -notcontains $ModulesPath) {
        $env:PSModulePath += ";$ModulesPath"
        Write-Verbose "Added '$ModulesPath' to the PSModulePath."
    }
    
    $Global:configData = Get-M365ConfigurationData -Path $Path -ErrorAction Stop

    $configFile = Join-Path -Path $Path -ChildPath 'configuration.ps1'

    Write-Host "Building configuration from: $configFile"
    . $configFile
    $config = OutPut -ConfigurationData $configData

    if ($null -eq $config) {
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

    $filePath = Join-Path -Path $Path -ChildPath 'metadata.json'

    $ConfigurationData.AllNodes | ForEach-Object {
        @{
            NodeName       = $_.NodeName
            Environment    = $_.Environment
            Authentication = $_.Authentication
        }
    } | ConvertTo-Json -Depth 10 | Out-File -FilePath $filePath -Encoding UTF8

    Write-Host "Metadata added to $filePath"
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
    <#
    .DESCRIPTION     
        Adds a resource to the M365Build configuration. 
    .EXAMPLE
        Get-Module M365Configuration -ListAvailable | Add-M365ConfigurationResource -Name "MyResource"
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Management.Automation.PSModuleInfo]$Module
    )

    $template = @'
Configuration #RESOURCE_NAME#
{
    Import-DscResource -ModuleName Microsoft365DSC

    Node $AllNodes.NodeName
    {
        AADUser 'ConfigureJohnSMith' {
            UserPrincipalName     = "John.Smith@$Env:M365_TenantId"
            FirstName             = "John"
            LastName              = "Smith"
            DisplayName           = "John J. Smith"
            City                  = "Gatineau"
            Country               = "Canada"
            Office                = "Ottawa - Queen"
            UsageLocation         = "US"
            Ensure                = "Present"
            TenantId              = $Env:M365_TenantId
            ApplicationId         = $Env:M365_ApplicationId
            CertificateThumbprint = $Env:M365_CertificateThumbprint
        }
    }
}
'@

    $resourceFolder = Join-Path -Path $Module.ModuleBase -ChildPath "DSCResources\$Name"
    New-Item -Path $resourceFolder -ItemType Directory | Out-Null

    $resourcePath = Join-Path -Path $resourceFolder -ChildPath "$Name.schema.psm1"
    $schemaFile = New-Item -Path $resourcePath -ItemType File
    $template.Replace('#RESOURCE_NAME#', $Name) | Out-File -FilePath $schemaFile.FullName -Encoding UTF8

    New-ModuleManifest -Path (Join-Path -Path $resourceFolder -ChildPath "$Name.psd1") `
        -RootModule "$Name.schema.psm1" `
        -ModuleVersion '0.0.0' `
        -PowerShellVersion '5.1' `
        -CompatiblePSEditions 'Core', 'Desktop' `
        -RequiredModules @('Microsoft365DSC')

    Write-Host "Resource '$Name' added to module '$($Module.Name)'."
    
}

Export-ModuleMember -Function @(
    'Invoke-M365Build',
    'Install-M365BuildRequirements',
    'Get-M365ConfigurationData',
    # 'Add-M365BuildMetaData',
    'Add-M365ConfigurationModule',
    'Add-M365ConfigurationResource'
)