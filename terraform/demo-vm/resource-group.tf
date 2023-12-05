#---terraform/demo-vm/resource-group.tf---#

resource "azurerm_resource_group" "iac_demo" {
  name     = join("-", ["rg", var.namespace, var.environment])
  location = var.location
  tags     = local.tags
}


