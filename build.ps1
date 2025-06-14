[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [System.String]
    $Id,

    [Parameter(Mandatory = $false)]
    [switch]
    $InstallRequirements
)

#Requires -PSEdition Desktop

Import-Module -Name "$PSScriptRoot\M365Build\M365Build.psm1" -Force -ErrorAction Stop

Invoke-M365Build @PSBoundParameters -ModulesPath "$PSScriptRoot\modules" -RequirementsFile "$PSScriptRoot\requirements.json"