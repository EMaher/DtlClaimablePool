function SelectSubscription($subId) {
    # switch to another subscription assuming it's not the one we're already on
    if ((Get-AzureRmContext).Subscription.Id -ne $subId) {
        Write-Output "Switching to subscription $subId"
        Set-AzureRmContext -SubscriptionId $subId | Out-Null
    }
}

function getTagValue($resource, $tagName) {
    $result = $null
    if ($resource.Tags) {
        $result = $resource.Tags | Where-Object {$_.Name -eq $tagName}
        if ($result) {
            $result = $result.Value
        }
        else {
            $result = $resource.Tags[$tagName]
        }
    }
    $result
}

function GetClaimablePoolStatus($LabResourceGroupName, $LabName, $CacheId, $Quota) {
    $currentCacheCount = `
    @(Get-AzureRmResource `
            -ResourceGroupName $LabResourceGroupName `
            -ResourceType 'Microsoft.DevTestLab/labs/virtualmachines' `
            -ResourceName $LabName `
            -ApiVersion 2016-05-15 `
            | Where-Object `
        { `
            (($_ | Get-Member -name "tags") -ne $null) `
                -and ($_.Tags["CacheId"] -ieq $CacheId) `
                -and ($_.Properties.allowClaim -eq $true)`
        }`
    ).Count

    $returnVal = [pscustomobject] @{
        CacheId = $CacheId;
        Current = $currentCacheCount;
        Needed  = ($Quota - $currentCacheCount);
        Quota   = $Quota
    }

    return $returnVal
}
function SaveProfile {
    $profilePath = Join-Path $PSScriptRoot "profile.json"

    If (Test-Path $profilePath) {
        Remove-Item $profilePath
    }
    
    Save-AzureRmContext -Path $profilePath
}

function LoadProfile {
    $scriptFolder = Split-Path $Script:MyInvocation.MyCommand.Path
    Import-AzureRmContext -Path (Join-Path $scriptFolder "profile.json") | Out-Null
}


