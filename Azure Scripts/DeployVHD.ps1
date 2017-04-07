### Log into your account and select the subscription if necessary ###
#Login-AzureRmAccount
#Select-AzureSubscription "my subscription" 

### The current location of the file you want to deploy ###
$imageURI = "https://example.blob.core.windows.net/vhds/example.vhd" 

### Define variables ###
$rgName = "EXISTING RESOURCE GROUP NAME"
$subnetName01 = "Mgmt"
$subnetName02 = "Untrust"
$subnetName03 = "Trust"

### Define the subnet addresses for 3 subnets ###
$singleSubnet01 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName01 -AddressPrefix 10.1.0.0/24
$singleSubnet02 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName02 -AddressPrefix 10.1.1.0/24
$singleSubnet03 = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName03 -AddressPrefix 10.1.2.0/24

### Create the VNET ###
$location = "East US"
$vnetName = "EXISTING VNET NAME"
$vnet = New-AzureRmVirtualNetwork -Name $vnetName -ResourceGroupName $rgName -Location $location -AddressPrefix 10.1.0.0/16 -Subnet $singleSubnet01,$singleSubnet02,$singleSubnet03    

### Create the public ip dns name, this can be done later from the resource manager ###
$ipName = "myPip"
$pip01 = New-AzureRmPublicIpAddress -Name $ipName -ResourceGroupName $rgName -Location $location -AllocationMethod Dynamic

### Create the names for your network interfaces ###
$nicName01 = "myNic01"
$nicName02 = "myNic02"
$nicName03 = "myNic03"

### Create the network interfaces ###
$nic1 = New-AzureRmNetworkInterface -Name $nicName01 -ResourceGroupName $rgName -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip01.Id
$nic2 = New-AzureRmNetworkInterface -ResourceGroupName $rGName -Name $nicName02 -SubnetId $vnet.Subnets[1].Id -Location $location  
$nic3 = New-AzureRmNetworkInterface -ResourceGroupName $rGName -Name $nicName03 -SubnetId $vnet.Subnets[2].Id -Location $location 

### Create your network security group name ###
$nsgName = "NETWORK SECURITY GROUP NAME"

### Create your network security group rules ###
$defaultInbound = New-AzureRmNetworkSecurityRuleConfig -Name Allow-Outside-From-IP -Description "Default Inbound Poilcy" `
    -Access Allow -Protocol * -Direction Inbound -Priority 100 `
    -SourceAddressPrefix Internet -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange *

$allowfromIntra = New-AzureRmNetworkSecurityRuleConfig -Name Allow-Intra -Description "Allow Intranet Traffic" `
    -Access Allow -Protocol * -Direction Inbound -Priority 101 `
    -SourceAddressPrefix "10.0.0.0/16" -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange *

$defaultDeny = New-AzureRmNetworkSecurityRuleConfig -Name Default-Deny -Description "Deny Other Traffic" `
    -Access Deny -Protocol * -Direction Inbound -Priority 200 `
    -SourceAddressPrefix * -SourcePortRange * `
    -DestinationAddressPrefix * -DestinationPortRange *

$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgName -Location $location `
    -Name $nsgName -SecurityRules $defaultInbound, $allowfromIntra, $defaultDeny

$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name $vnetName

 ### Enter a new user name and password to use as the local administrator account 
 ### for remotely accessing the VM.
 $cred = Get-Credential

 ### Name of the storage account where the VHD is located. This example sets the 
 ### storage account name as "myStorageAccount"
 $storageAccName = "STORAGE ACCOUNT NAME"

 ### Name of the virtual machine. This example sets the VM name as "myVM".
 $vmName = "VM NAME"

 ### Size of the virtual machine. This example creates "Standard_D2_v2" sized VM. 
 ### See the VM sizes documentation for more information: 
 ### https://azure.microsoft.com/documentation/articles/virtual-machines-windows-sizes/
 $vmSize = "Standard_D3_v2"

 ### Computer name for the VM. This examples sets the computer name as "myComputer".
 $computerName = "Palo Alto Networks VM-300"

 ### Name of the disk that holds the OS. This example sets the 
 ### OS disk name as "myOsDisk"
 $osDiskName = "myOsDisk"

 ### Get the storage account where the uploaded image is stored
 $storageAcc = Get-AzureRmStorageAccount -ResourceGroupName $rgName -AccountName $storageAccName

 ### Set the VM name and size
 $vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize

 ###Set the Linux operating system configuration and add the NIC
 $vm = Set-AzureRmVMOperatingSystem -VM $vmConfig -Linux -ComputerName $computerName -Credential $cred
 $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic1.Id -Primary
 $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic2.Id
 $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic3.Id

 ### Create the OS disk URI
 $osDiskUri = '{0}vhds/{1}-{2}.vhd' `
     -f $storageAcc.PrimaryEndpoints.Blob.ToString(), $vmName.ToLower(), $osDiskName

 $vm = Set-AzureRmVMPlan -VM $vm -Publisher paloaltonetworks -Product vmseries1 -Name byol

 ### Configure the OS disk to be created from the existing VHD image (-CreateOption fromImage).
 $vm = Set-AzureRmVMOSDisk -VM $vm -Name $osDiskName -VhdUri $osDiskUri -CreateOption fromImage -SourceImageUri $imageURI -Linux

 ### Create the new VM
 New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $vm -Verbose

 ### The VM should be running at this point once creation is done ###
