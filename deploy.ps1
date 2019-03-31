<# 

.SYNOPSIS
This script deploys the demo environment with default parameters, achieving "one-button deployment". Parameter file can easily be created to accommodate different deployments.

Note that you need to be logged into azure with login-azurermaccount. 

Created resources:
- see README.MD of this repo

.DEPENDENCIES
Tested with Powershell module AzureRM 6.7.0. If you have already moved to Az modules, try enabling the aliases with "Enable-AzureRmAlias -Scope CurrentUser"

.PARAMETERS
No parameters needed. 

.EXAMPLE
.\deploy.ps1
#>

# Set parameters:
$resourceGroupName = "Huuhka_FarmIOT"
$location = "westeurope"
$templateUri = "https://raw.githubusercontent.com/DrBushyTop/FarmIoT/master/ARM/azuredeploy.json"

# Create RG if it does not exist
Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    # ResourceGroup doesn't exist
    Write-Output "Creating resource group"
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $location
}
else
{
    # ResourceGroup exist
    Write-Output "Resource Group exists, continuing"
}

$deploymentName =  "farmiotdeployment-{0}" -f (get-date -f FileDateTime)

Write-Output "Submitting deployment"

New-AzureRmResourceGroupDeployment `
  -Name $deploymentName `
  -ResourceGroupName $resourceGroupName `
  -TemplateUri $templateUri `

