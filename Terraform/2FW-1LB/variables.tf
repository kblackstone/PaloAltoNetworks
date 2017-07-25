variable "azurerm_client_id" {
  type 		= "string"
  default 	= ""
}

variable "azurerm_client_secret" {
  type 		= "string"
  default 	= ""
}

variable "azurerm_subscription_id" {
  type 		= "string"
  default	= ""
}

variable "azurerm_tenant_id" {
  type 		= "string"
  default	= ""
}

variable "azurerm_instances" {
  type    = "string"
  default = "2"
}

variable "azurerm_vm_admin_username" {
  type		= "string"
  default	= ""
}

variable "azurerm_vm_admin_password" {
  type 		= "string"
  default 	= ""
}
