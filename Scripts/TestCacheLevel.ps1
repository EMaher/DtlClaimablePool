[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage="The name of the resourceGroup DevTest Lab")]
    [string] $DevTestLabResourceGroupName,
    
    [Parameter(Mandatory=$true, HelpMessage="The name of the Image Factory DevTest Lab")]
    [string] $DevTestLabName,

    [Parameter(Mandatory)] [string] $CacheId,

    [Parameter(Mandatory)] [int] $Quota
)

Write-Output "##[section] Looking for lab vm with cache id $CacheId in lab '$DevTestLabName'"
Write-Output "##[section] Quota is $Quota lab vms with cache id $CacheId"

$currentCacheCount = `
    @(Get-AzureRmResource `
        -ResourceGroupName $DevTestLabResourceGroupName `
        -ResourceType 'Microsoft.DevTestLab/labs/virtualmachines' `
        -ResourceName $DevTestLabName `
        -ApiVersion 2016-05-15 `
    | Where-Object `
        { `
            (($_ | Get-Member -name "tags") -ne $null) `
            -and ($_.Tags["CacheId"] -ieq $CacheId) `
            -and ($_.Properties.allowClaim -eq $true)`
        }`
    ).Count

Write-Output "##[section] Found $currentCacheCount lab vms with cache id $CacheId"


$returnVal = [pscustomobject] @{
    CacheId =  $CacheId;
    Current = $currentCacheCount;
    Needed = ($Quota - $currentCacheCount);
    Quota =  $Quota
}

return $returnVal