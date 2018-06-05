# Configure the Microsoft Azure Provider
provider "azurerm" {
	client_id 		= "${var.azurerm_client_id}"
	client_secret	= "${var.azurerm_client_secret}"
	subscription_id	= "${var.azurerm_subscription_id}"
	tenant_id		= "${var.azurerm_tenant_id}"
}

# ********** RESOURCE GROUP **********

# Create a resource group
resource "azurerm_resource_group" "demo" {
	name		= "moodys-demo"
	location	= "east us"
}

# ********** VNET **********

# Create a virtual network in the resource group
resource "azurerm_virtual_network" "demo" {
	name				= "vnet-fw"
	address_space		= ["10.0.0.0/16"]
	location			= "${azurerm_resource_group.demo.location}"
	resource_group_name	= "${azurerm_resource_group.demo.name}"
}

# ********** SUBNETS **********

resource "azurerm_subnet" "Mgmt" {
  name                 = "Mgmt"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "10.0.0.0/24"
}

resource "azurerm_subnet" "Untrust" {
  name                 = "Untrust"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_subnet" "Trust" {
  name                 = "Trust"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "EgressLB" {
  name                 = "EgressLB"
  resource_group_name  = "${azurerm_resource_group.demo.name}"
  virtual_network_name = "${azurerm_virtual_network.demo.name}"
  address_prefix       = "10.0.3.0/24"
}

# ********** STORAGE ACCOUNT **********

# Generate a random id for the storage account due to the need to be unique across azure.
# Here we are generating a random hex value of length 4 (2*2) that is prefixed with
# the static string "kbstorageaccount". For example: kbstorageaccount1n8a
resource "random_id" "storage_account" {
	prefix 		= "storageblackstone"
	byte_length = "2"
}

# Create the storage account
resource "azurerm_storage_account" "demo" {
	name				= "${lower(random_id.storage_account.hex)}"
	resource_group_name	= "${azurerm_resource_group.demo.name}"
	location			= "${azurerm_resource_group.demo.location}"
	account_replication_type = "LRS"
    	account_tier = "Standard"
}

# Create the storage account container
resource "azurerm_storage_container" "demo" {
	name							= "vhds"
	resource_group_name				= "${azurerm_resource_group.demo.name}"
	storage_account_name			= "${azurerm_storage_account.demo.name}"
	container_access_type			= "private"
}

# ********** VM PUBLIC IP ADDRESSES FOR MANAGEMENT **********

# Create the public IP address
resource "azurerm_public_ip" demo {
	count							= "${var.azurerm_instances}"
	name							= "fw${count.index}-mgmt"
	location						= "${azurerm_resource_group.demo.location}"
	resource_group_name				= "${azurerm_resource_group.demo.name}"
	public_ip_address_allocation	= "static"
}

# ********** VM NETWORK INTERFACES **********

# Create the network interfaces
resource "azurerm_network_interface" "Management" {
	count								= "${var.azurerm_instances}"
	name								= "fw-${count.index}-mgmt"
	location							= "${azurerm_resource_group.demo.location}"
	resource_group_name 				= "${azurerm_resource_group.demo.name}"

	ip_configuration {
		name							= "fw${count.index}-ip-0"
		subnet_id						= "${azurerm_subnet.Mgmt.id}"
		private_ip_address_allocation 	= "dynamic"
		public_ip_address_id = "${element(azurerm_public_ip.demo.*.id, count.index)}"
	}
}

# Create the network interfaces
resource "azurerm_network_interface" "Trust" {
	count								= "${var.azurerm_instances}"
	name								= "fw-${count.index}-trust"
	location							= "${azurerm_resource_group.demo.location}"
	resource_group_name 				= "${azurerm_resource_group.demo.name}"
	enable_ip_forwarding				= "true"

	ip_configuration {
		name							= "fw${count.index}-ip-0"
		subnet_id						= "${azurerm_subnet.Trust.id}"
		private_ip_address_allocation 	= "dynamic"
	}
}

# Create the network interfaces
resource "azurerm_network_interface" "Untrust" {
	count								= "${var.azurerm_instances}"
	name								= "fw-${count.index}-untrust"
	location							= "${azurerm_resource_group.demo.location}"
	resource_group_name 				= "${azurerm_resource_group.demo.name}"
	enable_ip_forwarding				= "true"

	ip_configuration {
		name							= "fw${count.index}-ip-0"
		subnet_id						= "${azurerm_subnet.Untrust.id}"
		private_ip_address_allocation 	= "dynamic"
		load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb1-1.id}"]

	}
}

# ********** AVAILABILITY SET **********

# Create the availability set
resource "azurerm_availability_set" "demo" {
	name								= "as-fw"
	location							= "${azurerm_resource_group.demo.location}"
	resource_group_name					= "${azurerm_resource_group.demo.name}"
	platform_update_domain_count = "5"
  platform_fault_domain_count  = "3"
}

# ********** INTERNET FACING LOAD BALANCER PUBLIC IP ADDRESSES **********

# Create the public ip for the public facing load balancer
resource "azurerm_public_ip" "lb1-1" {
  name                         = "publicip1forlb"
  location                     = "${azurerm_resource_group.demo.location}"
  resource_group_name          = "${azurerm_resource_group.demo.name}"
  public_ip_address_allocation = "static"
}

# ********** INTERNET FACING LOAD BALANCER **********

# Create the public facing load balancer
resource "azurerm_lb" "lb1" {
  name                = "publicloadbalancer-1"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"

  frontend_ip_configuration {
    name                 = "lbpublicipaddress1"
    public_ip_address_id = "${azurerm_public_ip.lb1-1.id}"
  }
}

# Create the back end pools
resource "azurerm_lb_backend_address_pool" "lb1-1" {
  resource_group_name = "${azurerm_resource_group.demo.name}"
  loadbalancer_id     = "${azurerm_lb.lb1.id}"
  name                = "backendaddresspool-1"
}

resource "azurerm_lb_probe" "lb1" {
  resource_group_name = "${azurerm_resource_group.demo.name}"
  loadbalancer_id     = "${azurerm_lb.lb1.id}"
  name                = "ssh-probe"
  port                = 22
	interval_in_seconds = 5
	number_of_probes 		= 2
}

resource "azurerm_lb_rule" "lb1-1" {
  resource_group_name            = "${azurerm_resource_group.demo.name}"
  loadbalancer_id                = "${azurerm_lb.lb1.id}"
  name                           = "lbrule1"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lbpublicipaddress1"
	backend_address_pool_id				 = "${azurerm_lb_backend_address_pool.lb1-1.id}"
	probe_id											 = "${azurerm_lb_probe.lb1.id}"
	load_distribution							 = "SourceIP"
	enable_floating_ip             = false
}

# ********** VIRTUAL MACHINE CREATION **********

# Create the virtual machine. Use the "count" variable to define how many
# to create.
resource "azurerm_virtual_machine" "demo" {
	count								= "${var.azurerm_instances}"
	name								= "fw-${count.index}"
	location						= "${azurerm_resource_group.demo.location}"
	resource_group_name	= "${azurerm_resource_group.demo.name}"
	network_interface_ids =
	[
		"${element(azurerm_network_interface.Management.*.id, count.index)}",
		"${element(azurerm_network_interface.Untrust.*.id, count.index)}",
		"${element(azurerm_network_interface.Trust.*.id, count.index)}",
	]

	primary_network_interface_id		= "${element(azurerm_network_interface.Management.*.id, count.index)}"
	vm_size								= "Standard_D3_v2"
	availability_set_id		= "${azurerm_availability_set.demo.id}"

	storage_image_reference	{
		publisher 	= "paloaltonetworks"
		offer		= "vmseries1"
		sku			= "byol"
		version		= "latest"
	}

	plan {
    	name = "byol"
    	product = "vmseries1"
    	publisher = "paloaltonetworks"
  	}

	storage_os_disk {
		name			= "pa-vm-os-disk-${count.index}"
		vhd_uri			= "${azurerm_storage_account.demo.primary_blob_endpoint}${element(azurerm_storage_container.demo.*.name, count.index)}/fwDisk${count.index}.vhd"
		caching 		= "ReadWrite"
		create_option	= "FromImage"
	}

	delete_os_disk_on_termination    = true
	delete_data_disks_on_termination = true

	os_profile 	{
		computer_name	= "pa-vm"
		admin_username	= "${var.azurerm_vm_admin_username}"
		admin_password	= "${var.azurerm_vm_admin_password}"
	}
}
