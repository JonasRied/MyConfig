[CmdletBinding()]
param (
    [Parameter()]
    [System.String]
    $Id,

    [Parameter()]
    [switch]
    $InstallRequirements
)

$modules = "$PSScriptRoot\modules"

$modulePath = $env:PSModulePath -split ';'

if ($modulePath -notcontains $modules) {
    $env:PSModulePath += ";$modules"
    Write-Verbose "Added '$modules' to the PSModulePath."
}

Import-Module -Name M365Build -Force -ErrorAction Stop

if($installRequirements) {
    Write-Verbose "Installing M365Build requirements..."
    Install-M365BuildRequirements -Path .\requirements.json
}
