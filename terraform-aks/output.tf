##################################################################################
# OUTPUTS
##################################################################################
output "host" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config.0.host}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.aks.kube_config_raw}"
}

output "config"{
    value = <<CONFIGURE

Run the following commands to configure kubernetes clients:

$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

Test configuration using kubectl

$kubectl get nodes
CONFIGURE
}
