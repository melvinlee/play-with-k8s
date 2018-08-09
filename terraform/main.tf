##################################################################################
# RESOURCES
##################################################################################

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name}"
  location = "${var.resource_group_location}"
}

#an attempt to keep the AKS name (and dns label) unique
resource "random_integer" "random_int" {
  min = 100
  max = 999
}

resource "azurerm_kubernetes_cluster" "aks" {
  name       = "${var.aks_name}-${random_integer.random_int.result}"
  location   = "${azurerm_resource_group.rg.location}"
  dns_prefix = "${var.aks_name}-${random_integer.random_int.result}"

  resource_group_name = "${azurerm_resource_group.rg.name}"
  kubernetes_version  = "1.10.5"

  linux_profile {
    admin_username = "${var.linux_admin_username}"

    ssh_key {
      key_data = "${var.linux_admin_ssh_publickey}"
    }
  }

  agent_pool_profile {
    name    = "agentpool"
    count   = "2"
    vm_size = "Standard_DS2_v2"
    os_type = "Linux"
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    source      = "terraform"
    environment = "${var.environment}"
  }
}
