<#
Author:     Mizuki Hachisuka, Thomas Laurenson
Email:      hachm1@student.op.ac.nz
Date:       31/3/2019
Description:
Powershell script to search blueprint with specific name and create it
#>


<# 1/3/2019 #>
Do 
{
    $vra_server = Read-host "Enter the hostname for your vRealize server"
} 

While ($vra_server -eq "")

# Enter hard-coded vRealize server here and comment above Do statement
#$vra_server = "https://fthvra01.op.ac.nz/"

#get the script direoty
$pwd = $PSScriptRoot 

#import the vRealize connect module from the module directory
import-Module $pwd\vRealizeConnect -Force

Write-Host ">>> Attempting to connect now..."
$bearer_token = vRealizeConnect($vra_server)
Write-Host "  > Continuing..."

<#7th march 2019#>
# Append forward slash if vRealize hostname does not end with a forward slash
if (-Not $vra_server.endswith("/")) 
{
    $vra_server = $vra_server + "/"
}

# Update URI to request available resources
$uri = $vra_server + "catalog-service/api/consumer/entitledCatalogItemViews"

Write-Host $uri
Write-Host "  > Current URI:" $uri

# Create request header
$header = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$header.Add("Accept", 'application/json')
$header.Add("Authorization", $bearer_token)

Write-Host ">>> Fetching Entitled Catalog Items..."


<# 12th march 2019 #>
# This request will return an array of every catalog item the user has entitlements for

$response = Invoke-RestMethod -Method Get -Uri $uri -Headers $header

# Input field to specify search term for items
$search_term = Read-Host -Prompt '>>> Please input a blueprint name'
Write-Host "  > Search for blueprint name:" $search_term
if (-Not $search_term.endswith("*")) 
{
    $search_term = $search_term + "*"
}
if (-Not $search_term.startswith("*")) 
{

    $search_term = "*" + $search_term
}
Write-Host "  > Search Blueprint Name:" $search_term

#Loop though the array of entitled items
ForEach ($deployment in $response.content) 
{
    if ($deployment.name -Like $search_term) 
    {
        # Get the id of the deployment
        $deployment_id = $deployment.catalogItemId

        Write-Host ""
        Write-Host ">>> Deployment Blueprint name:" $deployment.name
        Write-Host "  > Deployment Blueprint id:" $deployment_id

        # Strict check for deletion
        Write-Host ">>> ARE YOU SURE YOU WANT TO CREATE THIS DEPLOYMENT???" -ForegroundColor red
        $continue = Read-Host -Prompt "  > Press [Y] or [y] to continue, or anything else to skip..."

        if ($continue.Contains("n"))
        {
            Write-Host ">>> Skipping this deployment..."
            continue
        }
		Write-Host "  > Create Blueprint Name: " $deployment.name
        Write-Host "  > Create action id:" $deployment_id
        
        # Fetch the create template
        $uri = $vra_server + "catalog-service/api/consumer/entitledCatalogItems/" `
                            + $deployment_id `
                            + "/requests/template"

        $data = Invoke-WebRequest $uri -Headers $header
        $form = $data.content | ConvertFrom-Json 

        # The previous response contains the data needed to send to invoke a create action
        $uri = $vra_server + "catalog-service/api/consumer/entitledCatalogItems/" `
                + $deployment_id `
                + "/requests"

        $data_json = $form | ConvertTo-Json -Depth 10
        $response = Invoke-WebRequest $uri -Headers $header -Method Post -Body $data_json -ContentType "application/json"
        Write-Host "  > Created: Blueprint Name" $deployment.name
		Write-Host "  > Created: Blueprint ID" $deployment_id
        Write-Host ""    
    }
}

