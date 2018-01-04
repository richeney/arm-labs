#!/bin/bash

template="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.json"
parameters="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.parameters.json"
loc=westeurope
query="properties.output.vpnGatewayIpAddress.value"

rgs=$(curl $template | jq .parameters | grep -i resourceGroup | cut -f4 -d\")

while read rg
do
  az group create --location $loc --name $rg
  hubrg=${hubrg:-$rg}
done <<< "$rgs"

vpnGatewayIpAddress=$(az group deployment create --resource-group $hubrg --template-uri $template --query $query --output tsv)

print $vpnGatewayIpAddress
dd
