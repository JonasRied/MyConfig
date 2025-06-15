[CmdletBinding()]
param (
    [Parameter(ParameterSetName = 'build', Mandatory = $true)]
    [System.String]
    $Id,

    [Parameter(ParameterSetName = 'build', Mandatory = $false)]
    [Parameter(ParameterSetName = 'noop', Mandatory = $false)]
    [string]$Repository = 'PSGallery',

    [Parameter(ParameterSetName = 'build', Mandatory = $false)]
    [Parameter(ParameterSetName = 'noop', Mandatory = $false)]
    [switch]
    $InstallRequirements,

    [Parameter(ParameterSetName = 'noop', Mandatory = $true)]
    [switch]
    $Noop
)

try {

    Import-Module -Name "$PSScriptRoot\M365Build\M365Build.psm1" -Force -ErrorAction Stop

    if ( $InstallRequirements ) {
        Write-Verbose "Installing M365Build requirements..."
        Install-M365BuildRequirements -RequirementsFile "$PSScriptRoot\requirements.json" -Repository $Repository -ErrorAction Stop
    }

    if ( $Noop ) {
        Write-Host "No operation mode enabled. Skipping build."
        return
    }

    Invoke-M365Build -Path "$PSScriptRoot\src\$Id" -ModulesPath "$PSScriptRoot\modules" -ErrorAction Stop

    Write-Host "Build completed."
}
catch {
    Write-Error "Failed to build configuration: $_"
    return
}