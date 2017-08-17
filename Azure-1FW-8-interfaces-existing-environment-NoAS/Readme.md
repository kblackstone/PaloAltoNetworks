# Azure-Firewall-into-existing-environment

[<img src="http://azuredeploy.net/deploybutton.png"/>](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fkblackstone%2FPaloAltoNetworks%2Fmaster%2FAzure-1FW-4-interfaces-existing-environment-NoAS%2FAzureDeploy.json)

This template was created to support the deployment of a 8 interface Palo Alto Networks firewall into an existing Microsoft Azure environment that has the following items already deployed:

                    -VNET - with subnets
                    -Storage Account for the firewall VHD
                    -Resource Group for Firewall
            

FEATURES:
- The firewall deploys with 8 interfaces.  1 MGMT and 7 data plane into an existing environment.
- The PAN-OS required version is 8.0 (Latest)
- The deployment SKU can also be choosen during deployment.  BYOL, Bundle1 or Bundle2 are the available options.
- Static IP addresses assignment is used for all the firewall interfaces.


The following Storage Account types are supported:

                    -Standard_LRS
                    -Standard_GRS
                    -Standard_RAGRS
                    -Premium_LRS
                    
The following VMs are supported:

                    -Standard_DS5_v2
        
NOTE: Make sure the VMs are supported in the specific Storage Account Type and Azure Region.
