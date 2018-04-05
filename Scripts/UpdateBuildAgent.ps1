param
(
    [Parameter(Mandatory=$true, HelpMessage="The name of the resourceGroup DevTest Lab")]
    [string] $DevTestLabResourceGroupName,
    
    [Parameter(Mandatory=$true, HelpMessage="The name of the Image Factory DevTest Lab")]
    [string] $DevTestLabName,

	[Parameter(Mandatory=$true, HelpMessage="The name of the build agent")]
    [string] $BuildAgent,

	[Parameter(Mandatory=$true, HelpMessage="Either Start or Stop to apply an action to the Virtual Machine")]
    [string] $Action

)

# find the build agent in the subscription
$agentVM = Get-AzureRmResource -ResourceGroupName $DevTestLabResourceGroupName -ResourceType 'Microsoft.DevTestLab/labs/virtualmachines' -ResourceName "$DevTestLabName/$BuildAgent"

if ($agentVM -ne $null) {

    Write-Output "##[section] Found VSTS Build Agent. Build Agent: $BuildAgent"
    Write-Output "##[section] Running Action. VSTS Build Agent: $BuildAgent, Action: $Action"

    # Update the agent via DevTest Labs with the specified action (start or stop)
    $status = Invoke-AzureRmResourceAction -ResourceGroupName $DevTestLabResourceGroupName -ResourceType 'Microsoft.DevTestLab/labs/virtualmachines' -ResourceName ($DevTestLabName + "/" + $BuildAgent) -Action $Action -ApiVersion 2016-05-15 -Force

    if ($status.Status -eq 'Succeeded') {
        Write-Output "##[section] Successfully updated VSTS Build Agent: $BuildAgent , Action: $Action"
    }
    else {
        Write-Error "##[error] Failed to update the VSTS Build Agent: $BuildAgent , Action: $Action"
    }
}
else {
    $context = Get-AzureRmContext
    Write-Error "##[error] $BuildAgent was not found in the DevTest Lab '$DevTestLabName' in resource group '$DevTestLabResourceGroupName' in subscription '$($context.Subscription.SubscriptionId)'.  Unable to update the agent"
}

