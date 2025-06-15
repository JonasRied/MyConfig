[CmdletBinding()]
param (
    [Parameter(ParameterSetName = 'build', Mandatory = $true)]
    [System.String]
    $Id,

    [Parameter(ParameterSetName = 'build', Mandatory = $false)]
    [Parameter(ParameterSetName = 'noop',Mandatory = $false)]
    [switch]
    $InstallRequirements,

    [Parameter(ParameterSetName = 'noop',Mandatory = $true)]
    [switch]
    $Noop
)

Import-Module -Name "$PSScriptRoot\M365Build\M365Build.psm1" -Force -ErrorAction Stop

if( $Noop ) {
    Write-Host "No operation mode enabled. Skipping build."
    return
}

try {
    Invoke-M365Build `
        -Path "$PSScriptRoot\src\$Id" `
        -ModulesPath "$PSScriptRoot\modules" `
        -RequirementsFile "$PSScriptRoot\requirements.json" `
        -InstallRequirements:$InstallRequirements
}
catch {
    Write-Error "Failed to build configuration: $_"
    return
}

Write-Host "Build completed."