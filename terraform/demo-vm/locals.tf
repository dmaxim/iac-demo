#--- terraform/demo-vm/locals.tf ---#

locals {
  tags = {
    environment = var.environment
  }
}