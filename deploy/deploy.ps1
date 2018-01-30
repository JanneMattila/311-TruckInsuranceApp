Param (
    [string] $ResourceGroupName = "truckapp-local-rg",
    [string] $Location = "North Europe",
    [string] $Template = "$PSScriptRoot\azuredeploy.json",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json",
    [string] $PricingTier = "B1"
)

$ErrorActionPreference = "Stop"

if ((Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue) -eq $null)
{
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Create additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['truckAppPlanSkuName'] = $PricingTier

$result = New-AzureRmResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
	-Verbose

$result
