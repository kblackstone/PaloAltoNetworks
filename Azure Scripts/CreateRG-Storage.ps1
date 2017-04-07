Login-AzureRmAccount
#Select-AzureSubscription "my subscription"

### Define your variables ###
$rgName = "NEWRESOURCEGROUPNAME"
$storageName = "NEWSTORAGEACCOUNTNAME"

### Adjust location as needed ###
$locationName = "East US"
$storageType = "Standard_LRS"

### Create the new resource group ###
New-AzureRmResourceGroup -Name $rgName -Location $locationName

### Create the storage account within the resource group ###
New-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $storageName -Type $storageType -Location $locationName

### Now run CopyVHD.ps1 ###
