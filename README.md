# VM-Series for Microsoft Azure

This is a "non official" repository for Azure Resoure Manager (ARM) templates to deploy VM-Series Next-Generation firewall from Palo Alto Networks into the Azure public cloud.  The initial driver for this repository was that I wanted to modified the PaloAltoNetworks template to enable the ability to deploy a firewall with 4 interfaces.  Mgmt, Trust, Untrust, and DMZ.  There are many variations of this scenario in this repository.  



**Documentation**

- [Technical documentation v7.1](https://www.paloaltonetworks.com/documentation/71/virtualization/virtualization/set-up-the-vm-series-firewall-in-azure)
- [Technical documentation v8.0](https://www.paloaltonetworks.com/documentation/80/virtualization/virtualization/set-up-the-vm-series-firewall-on-azure)
- [VM-Series Datasheet](https://www.paloaltonetworks.com/products/secure-the-network/virtualized-next-generation-firewall/vm-series-for-azure)
- [Deploying ARM Templates](https://azure.microsoft.com/en-us/documentation/articles/resource-group-template-deploy/#deploy-with-azure-cli)

**NOTE:**

- Deploying ARM templates requires some customization of the ARM JSON template. Please review the basic structure of ARM templates.
- Before you use the custom ARM templates here, you must first deploy the related VM from the Azure Marketplace into the intended/destination Azure location. This enables programmatic access (i.e. template-based deployment) to deploy the VM from Azure Marketplace. You can then delete the Marketplace-based deployment if you don't need it.
- For example, if you plan to use a custom ARM template to deploy a BYOL VM of VM-Series into Australia-East, then first deploy the BYOL VM from Marketplace into Australia. This is needed only the first time. You can then delete this VM and its related resources. Now your ARM templates, from GitHub or via CLI, will work.
- When deploying an ARM template you may see the following error if above steps have not been done once for each SKU:

``` json
"ResourceDeploymentFailure\",\r\n \"message\": \"The resource operation completed with terminal provisioning state
'Failed'.\",\r\n \"details\": [\r\n {\r\n \"code\": \"ImageNotFound\",\r\n \"message\":
\"The platform image 'paloaltonetworks:vmseries1:byol:latest' is not available.
Verify that all fields in the storage profile are correct.\"
```
