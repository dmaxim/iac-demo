#--- terraform/demo-vm/network.tf

resource "azurerm_virtual_network" "iac_demo" {
  name                = join("-", ["vnet", var.namespace, var.environment])
  location            = azurerm_resource_group.iac_demo.location
  resource_group_name = azurerm_resource_group.iac_demo.name
  address_space       = [var.vm_vnet_address_space]
}

resource "azurerm_subnet" "iac_demo" {
  name                 = join("-", ["sn", var.namespace, var.environment, "01"])
  resource_group_name  = azurerm_resource_group.iac_demo.name
  address_prefixes     = [cidrsubnet(var.vm_vnet_address_space, 8, 1)]
  virtual_network_name = azurerm_virtual_network.iac_demo.name

}

# Create a network security group
resource "azurerm_network_security_group" "iac_demo" {
  name                = join("-", ["nsg", var.namespace, var.environment])
  location            = azurerm_resource_group.iac_demo.location
  resource_group_name = azurerm_resource_group.iac_demo.name

  tags = {
    environment = var.environment
  }
}


# Allow SSH
resource "azurerm_network_security_rule" "iac_demo" {
  name                        = "ssh-dm-home"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.home_ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.iac_demo.name
  network_security_group_name = azurerm_network_security_group.iac_demo.name
}