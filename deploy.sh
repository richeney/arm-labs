#!/bin/bash

error()
{
  echo "ERROR: $*" >&2
  exit 1
}

templateUri="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.json"
parametersUri="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.parameters.json"
loc=westeurope
query="properties.outputs.vpnGatewayIpAddress.value"

which jq > /dev/null || error "Error: jq must be installed.  Go to https://stedolan.github.io/jq/download/."
which az > /dev/null || error "Error: az must be installed.  Go to https://aka.ms/GetTheAzureCLI."

parameters=$(curl --silent $parametersUri | jq .parameters)
[[ -z "$parameters" ]] && error "$parametersUri not found or incorrectly formed."

hubrg=$(jq --raw-output .hub.value.resourceGroup <<< $parameters)
spokergs=$(jq --raw-output .spokes.value[].resourceGroup <<< $parameters)

echo "Checking or creating resource groups:" >&2
for rg in $hubrg $spokergs
do az group create --location $loc --name $rg --output tsv --query name | sed 's/^/\* /1'
done 

echo "Deploying master template..." >&2
vpnGatewayIpAddress=$(az group deployment create --resource-group $hubrg --template-uri $templateUri --query $query --output tsv --parameters "$parameters")

echo $vpnGatewayIpAddress
