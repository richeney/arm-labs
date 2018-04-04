#!/bin/bash

error()
{
  echo "ERROR: $*" >&2
  exit 1
}

templateUri="https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/azuredeploy.json"
parametersUri="https://raw.githubusercontent.com/richeney/arm/master/nestedTemplates/azuredeploy.parameters.json"
loc=westeurope
query="properties.outputs.vpnGatewayPipId.value"

# Check that both jq and az are installed
which jq > /dev/null || error "Error: jq must be installed.  Go to https://stedolan.github.io/jq/download/."
which az > /dev/null || error "Error: az must be installed.  Go to https://aka.ms/GetTheAzureCLI."

# Get the parameters sections of the parameters file as a multi-line variable
# Use epoch seconds as a querystring to force server to not use the cache
parameters=$(curl --silent "$parametersUri?$(date +%s)" | jq .parameters)
[[ -z "$parameters" ]] && error "$parametersUri not found or incorrectly formed."

# Determine the resource groups
hubrg=$(jq --raw-output .hub.value.resourceGroup <<< $parameters)
spokergs=$(jq --raw-output .spokes.value[].resourceGroup <<< $parameters)

# Create the resource groups is they do not exist
echo "Checking or creating resource groups:" >&2
for rg in $hubrg $spokergs
do az group create --location $loc --name $rg --output tsv --query name | sed 's/^/- /1'
done 

# Deploy the ARM template into the hub resource group
echo "Deploying master template..." >&2
vpnGatewayPipId=$(az group deployment create --resource-group $hubrg --template-uri $templateUri --query $query --output tsv --parameters "$parameters" --verbose)
[[ -z "$vpnGatewayPipId" ]] && error "Deployment issue. See resource manager error messages above."

# The VPN gateway's public IP is dynamic, and so will not be allocated until the gateway itself is up and running
# Once the deployment has cocompleted then we determine the address
az network public-ip show --ids $vpnGatewayPipId --query ipAddress --output tsv
