#---terraform/demo-vm/variables.tf---#

variable "namespace" {
  type        = string
  default     = "mxinfo-iac"
  description = "Namespace for resources"
}

variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region"
}

variable "environment" {
  type        = string
  default     = "demo"
  description = "Resource environment"
}

variable "vm_size" {
  type        = string
  default     = "Standard_DS3_v2"
  description = "Azure VM size"
}

variable "home_ip_address" {
  type        = string
  description = "IP address for SSH access"
}

variable "vm_vnet_address_space" {
  type        = string
  default     = "10.1.0.0/16"
  description = "Address space for the virtual network"
}

variable "vm_admin_user" {
  type        = string
  description = "Admin user for the VM"
  sensitive = true
}