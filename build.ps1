[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Id,

    [Parameter(Mandatory = $false)]
    [switch]
    $InstallRequirements
)

Import-Module -Name "$PSScriptRoot\M365Build\M365Build.psm1" -Force -ErrorAction Stop

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