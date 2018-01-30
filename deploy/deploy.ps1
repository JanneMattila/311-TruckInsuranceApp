# To create securestring you can use following command:
# $password = ConvertTo-SecureString -String "password" -AsPlainText -Force
#
# .\deploy.ps1 -DatabaseAdminPassword $password
#
Param (
    [string] $ResourceGroupName = "truckapp-local-rg",
    [string] $Location = "North Europe",
    [string] $Template = "$PSScriptRoot\azuredeploy.json",
    [string] $TemplateParameters = "$PSScriptRoot\azuredeploy.parameters.json",
    [string] $PricingTier = "B1",
    [string] $DatabaseName = "truckdb",
    [string] $DatabaseAdminUser = "sqluser",
    [Parameter(Mandatory=$true)] [securestring] $DatabaseAdminPassword
)

$ErrorActionPreference = "Stop"

$date = (Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")
$deploymentName = "Local-$date"

if ([string]::IsNullOrEmpty($env:RELEASE_DEFINITIONNAME))
{
    Write-Host (@"
Not executing inside VSTS Release Management.
Make sure you have done "Login-AzureRmAccount" and
"Select-AzureRmSubscription -SubscriptionName name"
so that script continues to work correctly for you.
"@)
}
else
{
	$deploymentName = $env:RELEASE_RELEASENAME
}

if ((Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction SilentlyContinue) -eq $null)
{
    Write-Warning "Resource group '$ResourceGroupName' doesn't exist and it will be created."
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Verbose
}

# Create additional parameters that we pass to the template deployment
$additionalParameters = New-Object -TypeName hashtable
$additionalParameters['truckAppPlanSkuName'] = $PricingTier
$additionalParameters['databaseName'] = $DatabaseName
$additionalParameters['administratorLogin'] = $DatabaseAdminUser
$additionalParameters['administratorLoginPassword'] = $DatabaseAdminPassword

$result = New-AzureRmResourceGroupDeployment `
	-DeploymentName $deploymentName `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $Template `
    -TemplateParameterFile $TemplateParameters `
    @additionalParameters `
	-Verbose

$result
