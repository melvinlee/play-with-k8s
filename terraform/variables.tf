##################################################################################
# VARIABLES
##################################################################################

variable "client_id" {
  type        = "string"
  description = "Client ID"
}

variable "client_secret" {
  type        = "string"
  description = "Client secret."
}

variable "resource_group_name" {
  type        = "string"
  description = "Name of the azure resource group."
  default     = "dev-k8s-rg"
}

variable "resource_group_location" {
  type        = "string"
  description = "Location of the azure resource group."
  default     = "southeastasia"
}

variable "aks_name"{
  type        = "string"
  description = "Name of aks cluster."
  default     = "dev-aks"
}

variable "environment" {
  type        = "string"
  description = "dev, test or production."
  default     = "dev"
}

variable "linux_admin_username" {
  type        = "string"
  description = "User name for authentication to the Kubernetes linux agent virtual machines in the cluster."
}

variable "linux_admin_ssh_publickey" {
  type        = "string"
  description = "Configure all the linux virtual machines in the cluster with the SSH RSA public key string. The key should include three parts, for example 'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm'"
}