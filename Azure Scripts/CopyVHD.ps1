### Be sure to shut down the virtual machine you want to copy ###

### Log into your account and select the subscription if necessary ###
#Login-AzureRmAccount
#Select-AzureSubscription "my subscription" 
 
### Source VHD - authenticated container ###
$srcUri = "https://example.blob.core.windows.net/vhds/example.vhd" 
 
### Source Storage Account name and access key ###
$srcStorageAccount = "STORAGEACCOUNTNAME"
$srcStorageKey = "SOURCE KEY"
 
### Target Storage Account name and access key ###
$destStorageAccount = "DESTINATIONSTORAGEACCOUNTNAME"
$destStorageKey = "DESTINATION KEY"
 
### Create the source storage account context ### 
$srcContext = New-AzureStorageContext  –StorageAccountName $srcStorageAccount `
                                        -StorageAccountKey $srcStorageKey  
 
### Create the destination storage account context ### 
$destContext = New-AzureStorageContext  –StorageAccountName $destStorageAccount `
                                        -StorageAccountKey $destStorageKey  
 
### Destination Container Name ### 
$containerName = "vhds"
 
### Uncomment to create the container on the destination ### 
#New-AzureStorageContainer -Name $containerName -Context $destContext 
 
### Start the asynchronous copy - specify the source authentication with -SrcContext ### 
$blob1 = Start-AzureStorageBlobCopy -srcUri $srcUri `
                                    -SrcContext $srcContext `
                                    -DestContainer $containerName `
                                    -DestBlob "NEWVHDNAME.vhd" `
                                    -DestContext $destContext

### Retrieve the current status of the copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState 
 
### Print out status ### 
$status 
 
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState 
  Start-Sleep 10
  ### Print out status ###
  $status
}


### Now run DeployVHD.ps1 ###