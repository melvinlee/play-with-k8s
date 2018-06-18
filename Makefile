LOCATION ?= eastus
RESOURCE_GROUP ?= aks-test-rg
AKS_CLUSTER_NAME ?= aksCluster
NODE_COUNT ?= 3
SUBSCRUBTION_ID ?= 

.PHONY: get-account
get-account:
	az account show

.PHONY: set-account
set-account:
	az account set -s $(SUBSCRUBTION_ID)

.PHONY: create-cluster
create-cluster:
	az group create --name $(RESOURCE_GROUP) --location $(LOCATION)
	az aks create --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME)
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME)

.PHONY: scale-cluster
scale-cluster:
	az aks scale --name $(AKS_CLUSTER_NAME) --resource-group $(RESOURCE_GROUP)  --node-count $(NODE_COUNT)

.PHONY: delete-cluster
delete-cluster:
	az group delete --name $(RESOURCE_GROUP) --yes --no-wait
