Login-AzureRMAccount
Get-AzureRmNetworkInterface

$subscriptionname = Read-Host -Prompt "Enter your Subscription ID"
$rgname = Read-Host -Prompt "Enter Resource Group name"
$vmname = Read-Host -Prompt "Enter the VM name"
$nicname = Read-Host -Prompt "Enter the new NIC name"

$myvm = Get-AzureRmVM -ResourceGroupName $rgname -VMName $vmname
Add-AzureRmVMNetworkInterface -VM $myvm -Id "/subscriptions/$subscriptionname/resourceGroups/$rgname/providers/Microsoft.Network/networkInterfaces/$nicname"
Update-AzureRmVM -ResourceGroupName $rgname -VM $myvm
