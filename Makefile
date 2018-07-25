LOCATION ?= japaneast
RESOURCE_GROUP ?= aks-101-rg
AKS_CLUSTER_NAME ?= aks-101-Cluster
NODE_COUNT ?= 1
VM_SIZE ?= Standard_DS2_v2
KUBE_VERSION = 1.10.5
SUBSCRIPTION_ID ?= 
GRAFANA_POD_NAME=$(shell kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}')
JAEGER_POD_NAME=$(shell kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}')
APP_ID=$(shell az ad app list --query "[?displayName=='$(AKS_CLUSTER_NAME)'].{Id:appId}" --output table | tail -1)

.PHONY: get-account
get-account:
	az account show

.PHONY: set-account
set-account:
	az account set -s $(SUBSCRUPTION_ID)

.PHONY: create-cluster
create-cluster:
	az group create --name $(RESOURCE_GROUP) --location $(LOCATION)
	az aks create --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME) \
	--enable-rbac \
	--enable-addons http_application_routing \
	--node-vm-size $(VM_SIZE) \
	--kubernetes-version $(KUBE_VERSION) \
	--node-count $(NODE_COUNT)

.PHONY: get-credential
get-credential:
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME)

.PHONY: get-node
get-node:
	kubectl get nodes

.PHONY: deploy-metricserver
deploy-metricserver:
	rm -rf ./tmp/metrics-server
	git clone https://github.com/kubernetes-incubator/metrics-server.git tmp/metrics-server
	kubectl create -f ./tmp/metrics-server/deploy/1.8+/

.PHONY: delete-metricserver
delete-metricserver:
	 kubectl delete -f ./tmp/metrics-server/deploy/1.8+/
	 rm -rf tmp/metrics-server

.PHONY: deploy-helm
deploy-helm:
	kubectl create -f ./helm/helm-service-account.yaml
	helm init --service-account tiller

.PHONY: deploy-istio
deploy-istio:
	kubectl create ns istio-system
	kubectl apply -n istio-system -f ./istio/istio.yaml
	kubectl label namespace default istio-injection=enabled

.PHONY: deploy-istio-dashboard
deploy-istio-dashboard:
	kubectl apply -f ./istio/install/kubernetes/addons/grafana.yaml

.PHONY: deploy-hitcounter
deploy-hitcounter:
	kubectl apply -f ./samples/hitcounter/kube

.PHONY: deploy-nodeweb
deploy-nodeweb:
	kubectl apply -f ./samples/nodeweb/kube

.PHONY: get-stuff
get-stuff:
	kubectl get deploy,pod,svc,hpa

.PHONY: scale-cluster
scale-cluster:
	az aks scale --name $(AKS_CLUSTER_NAME) --resource-group $(RESOURCE_GROUP)  --node-count $(NODE_COUNT)

.PHONY: start-monitoring-services
start-monitoring-services:
	$(shell kubectl -n istio-system port-forward $(GRAFANA_POD_NAME) 3000:3000 && kubectl -n istio-system port-forward $(JAEGER_POD_NAME) 16686:16686)

.PHONY: delete-cluster
delete-cluster:
	az group delete --name $(RESOURCE_GROUP) --yes --no-wait
	az ad app delete --id $(APP_ID)

.PHONY: delete-sp
delete-sp:
	if [ -f $(AKS_SP_FILE) ] ; then \
    	rm $(AKS_SP_FILE); \
	fi
