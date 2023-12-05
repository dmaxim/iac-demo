#--- terraform/demo-vm/compute.tf ---#

# Create random id for storage account for diagnostics data
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.iac_demo.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "iac_demo" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.iac_demo.name
  location                 = azurerm_resource_group.iac_demo.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_public_ip" "iac_demo" {
  name                = join("-", ["pip", var.namespace, var.environment])
  location            = azurerm_resource_group.iac_demo.location
  resource_group_name = azurerm_resource_group.iac_demo.name
  allocation_method   = "Static"

  sku = "Standard"
  tags = {
    environment = var.environment
  }
}


resource "azurerm_network_interface" "iac_demo" {
  name                = join("-", ["nic", var.namespace, var.environment])
  location            = azurerm_resource_group.iac_demo.location
  resource_group_name = azurerm_resource_group.iac_demo.name

  ip_configuration {
    name                          = join("-", ["nic", var.namespace, var.environment])
    subnet_id                     = azurerm_subnet.iac_demo.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.iac_demo.id
  }

  tags = {
    environment = var.environment
  }
}


# Associate NIC with nework security group
resource "azurerm_network_interface_security_group_association" "iac_demo" {
  network_interface_id      = azurerm_network_interface.iac_demo.id
  network_security_group_id = azurerm_network_security_group.iac_demo.id
}

resource "azurerm_linux_virtual_machine" "iac_demo" {
  name                            = join("-", ["vm", var.namespace, var.environment])
  location                        = azurerm_resource_group.iac_demo.location
  resource_group_name             = azurerm_resource_group.iac_demo.name
  network_interface_ids           = [azurerm_network_interface.iac_demo.id]
  size                            = var.vm_size
  disable_password_authentication = true
  admin_username                  = var.vm_admin_user
  computer_name                   = join("-", ["vm", var.namespace, var.environment])

  os_disk {
    name                 = join("-", ["disk", var.namespace, var.environment, "vm"])
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  #   admin_ssh_key {
  #     username   = data.azurerm_key_vault_secret.vm_admin_user.value
  #     public_key = data.azurerm_key_vault_secret.vm_admin_ssh_key.value
  #   }

  admin_ssh_key {
    username   = var.vm_admin_user
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-LTS"
    version   = "latest"
  }


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.iac_demo.primary_blob_endpoint
  }

  tags = {
    environment = var.environment
  }
}
