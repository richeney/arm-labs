# arm
Azure Resource Manager JSON files

See my workshop on https://azurecitadel.github.io/workshops/arm.  The files in this repository are referenced there and the workshop will help to explain some of the constructs and functions that are used. 

This azuredeploy.json master template will create a simple hub and spoke architecture, but it exists more to demonstrate some of the capabilities of Azure ARM templates. It will create a VPN gateway in the hub's GatewaySubnet, and the spokes will ve vNet peered back to the hub vNet.  There is nothing currently in the templates to cover RBAC, NSGs and UDRs, or the introduction of any NVAs.  If none of these terms mean anything then it is recommended to look at the Azure 101 and Virtual Data Centre (VDC) workshops on the [Citadel](https://aka.ms/citadel) site for a better understanding.  

The master template has sufficient default values for the parameters for you to submit using the following commands:

```json
for rg in core spoke1 spoke2
do az group create --location westeurope --name $rg
done

az group deployment create --resource-group $hubrg --template-uri $templateUri
```

If you are looking to customise the parameters then copy the azuredeploy.parameters.json file locally, and configure as required. Create the appropriate resource groups in readiness for the deployment and then deploy using:

```json
loc=westeurope
hubrg=<yourHubResourceGroup>
templateUri="https://raw.githubusercontent.com/richeney/arm/master/azuredeploy.json"
parametersFile=/path/to/your/azuredeploy.parameters.json

az group deployment create --resource-group $hubrg --template-uri $templateUri --parameters "@$parametersFile"
```

There is also a deploy.sh script that runs in bash.  It requires both Azure CLI 2.0 and the jq utility for handling jmespath queries against JSON strings. I have used curl and jq to extract and query the parameters from the URI, and the parameters are passed inline as JSON to the deployment. It also determines the hub and spoke resource groups and creates them if required.  Feel free to make use of the script.

Richard Cheney
Cloud Solution Architect, Microsoft
@RichCheneyAzure    

