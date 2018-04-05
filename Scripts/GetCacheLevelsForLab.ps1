[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "The name of the resourceGroup DevTest Lab")]
    [string] $LabResourceGroupName,
    
    [Parameter(Mandatory = $true, HelpMessage = "The name of the DevTest Lab")]
    [string] $LabName,

    [Parameter(Mandatory = $true, HelpMessage = "The full path claimable pool configuration file")]
    [string] $ConfigurationFilePath 
)

$modulePath =  (Join-Path (split-path -parent $MyInvocation.MyCommand.Definition) 'ClaimablePoolHelpers.psm1')
Write-Verbose "Importing module $modulePath" 
Import-Module $modulePath -Force

#get information for claimable pools
$cacheInfo = (ConvertFrom-Json -InputObject ( Get-Content $ConfigurationFilePath -Raw)).Caches
$results = New-Object System.Collections.ArrayList

foreach ($info in $cacheInfo) {
    $status = GetClaimablePoolStatus `
        -LabResourceGroupName $LabResourceGroupName `
        -LabName $LabName `
        -CacheId  $info.CacheId `
        -Quota $info.Quota
    $status | Add-Member TemplatePath $info.TemplatePath

    $results.Add($status) | Out-Null
}
Write-Output $results | Format-Table 