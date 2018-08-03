LOCATION ?= eastus
RESOURCE_GROUP ?= kubernetes-rg
AKS_CLUSTER_NAME ?= aks-cluster
ACR_NAME ?= kube3421
NODE_COUNT ?= 1
VM_SIZE ?= Standard_DS2_v2
KUBE_VERSION = 1.10.5
AKS_SP_FILE = $(HOME)/.azure/aksServicePrincipal.json
SUBSCRIPTION_ID ?= 
GRAFANA_POD_NAME=$(shell kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}')
JAEGER_POD_NAME=$(shell kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}')
APP_ID=$(shell az ad app list --query "[?displayName=='$(AKS_CLUSTER_NAME)'].{Id:appId}" --output table | tail -1)
AKS_PARAM = --enable-rbac --enable-addons http_application_routing 

.PHONY: get-account
get-account:
	az account show

.PHONY: set-account
set-account:
	az account set -s $(SUBSCRUPTION_ID)

.PHONY: create-cluster
create-cluster:
	#################################################################
	# Create AKS Cluster
	#################################################################
	az group create --name $(RESOURCE_GROUP) --location $(LOCATION)
	az aks create --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME) \
	--node-vm-size $(VM_SIZE) \
	--kubernetes-version $(KUBE_VERSION) \
	--node-count $(NODE_COUNT) \
	$(AKS_PARAM)

.PHONE: create-acr
create-acr:
	#################################################################
	# Create ACR
	#################################################################
	az acr create --name $(ACR_NAME) --resource-group $(RESOURCE_GROUP) --sku Basic --admin-enabled

.PHONY: get-credential
get-credential:
	#################################################################
	# Get AKS Credentials
	#################################################################
	az aks get-credentials --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME)

.PHONY: get-node
get-node:
	kubectl get nodes

.PHONY: deploy-metricserver
deploy-metricserver:
	#################################################################
	# Deploy Kubernetes Metric Server
	#################################################################
	kubectl create -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-delegator.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-reader.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-apiservice.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-deployment.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-service.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/resource-reader.yaml

.PHONY: delete-metricserver
delete-metricserver:
	#################################################################
	# Delete Kubernetes Metric Server
	#################################################################
	kubectl delete -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-delegator.yaml
	kubectl delete -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/auth-reader.yaml
	kubectl delete -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-apiservice.yaml
	kubectl delete -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-deployment.yaml
	kubectl delete -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/metrics-server-service.yaml
	kubectl delete -f https://raw.githubusercontent.com/kubernetes-incubator/metrics-server/master/deploy/1.8%2B/resource-reader.yaml

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
	#################################################################
	# Scale AKS Cluster
	#################################################################
	az aks scale --name $(AKS_CLUSTER_NAME) --resource-group $(RESOURCE_GROUP)  --node-count $(NODE_COUNT)

.PHONY: start-monitoring-services
start-monitoring-services:
	$(shell kubectl -n istio-system port-forward $(GRAFANA_POD_NAME) 3000:3000 && kubectl -n istio-system port-forward $(JAEGER_POD_NAME) 16686:16686)

.PHONY: delete-cluster
delete-cluster:
	#################################################################
	# Delete AKS Cluster
	#################################################################
	az group delete --name $(RESOURCE_GROUP) --yes --no-wait
	az ad app delete --id $(APP_ID)

.PHONY: delete-sp
delete-sp:
	#################################################################
	# Delete Service Principal Local Cache
	#################################################################
	if [ -f $(AKS_SP_FILE) ] ; then \
    	rm $(AKS_SP_FILE); \
	fi
