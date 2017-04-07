### Be sure to shut down the virtual machine you want to copy ###

### Log into your account and select the subscription if necessary ###
#Login-AzureRmAccount
#Select-AzureSubscription "my subscription" 
 
### Source VHD - authenticated container ###
$srcUri = "https://alliedstorage01.blob.core.windows.net/vhds/alliedfw01-vmseries1-byol.vhd" 
 
### Source Storage Account name and access key ###
$srcStorageAccount = "alliedstorage01"
$srcStorageKey = "SOURCE KEY"
 
### Target Storage Account name and access key ###
$destStorageAccount = "alliedstorage2"
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
                                    -DestBlob "alliedfw01.vhd" `
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