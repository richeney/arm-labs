#!/bin/bash

templateUri="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.json"
parametersUri="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.parameters.json"
loc=westeurope
query="properties.outputs.vpnGatewayIpAddress.value"

## rgs=$(curl $template | jq .parameters | grep -i resourceGroup | cut -f4 -d\")
## 
## while read rg
## do
  ## az group create --location $loc --name $rg
  ## [[ -z $hubrg ]] && hubrg=$rg
## done <<< "$rgs"

[[ -z $hubrg ]] && hubrg=core

parameters=$(curl --silent $parametersUri | jq .parameters)

hubrg=$(jq --raw-output .hub.value.resourceGroup <<< $parameters)
spokergs=$(jq --raw-output .spokes.value[].resourceGroup <<< $parameters)

echo $hubrg $spokergs
exit



# [[ -n "$parameters" ]] && { echo "Error: $parameterUri not found or incorrectly formed." >&2; exit 1; }

vpnGatewayIpAddress=$(az group deployment create --resource-group $hubrg --template-uri $templateUri --query $query --output tsv --parameters $parameters)

echo $vpnGatewayIpAddress
