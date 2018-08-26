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

resource "tls_private_key" "key" {
  algorithm   = "RSA"
  ecdsa_curve = "P224"
  rsa_bits    = "2048"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  tags {
    source = "terraform"
    env    = "${var.environment}"
  }
}

resource "azurerm_subnet" "aks" {
  name                 = "aks"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/28"
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_subnet" "apigateway" {
  name                 = "apigateway"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.3.0/28"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name       = "${var.aks_name}-${random_integer.random_int.result}"
  location   = "${azurerm_resource_group.rg.location}"
  dns_prefix = "${var.aks_name}-${random_integer.random_int.result}"

  resource_group_name = "${azurerm_resource_group.rg.name}"

  linux_profile {
    admin_username = "${var.linux_admin_username}"

    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)}"
    }
  }

  agent_pool_profile {
    name    = "agentpool"
    count   = "${var.aks_node_count}"
    vm_size = "Standard_DS2_v2"
    os_type = "Linux"

    vnet_subnet_id = "${azurerm_subnet.aks.id}"
    max_pods       = 50
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.100.0.0/16"
    dns_service_ip     = "10.100.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  tags {
    source = "terraform"
    env    = "${var.environment}"
  }
}

resource "null_resource" "aks-credentials" {
  provisioner "local-exec" {
    command = "az aks get-credentials -n ${azurerm_kubernetes_cluster.aks.name} -g ${azurerm_resource_group.rg.name}"
  }
}
