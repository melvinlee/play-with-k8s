LOCATION ?= eastus
RESOURCE_GROUP ?= aks-101-rg
AKS_CLUSTER_NAME ?= aks-101-Cluster
NODE_COUNT ?= 3
SUBSCRUBTION_ID ?= 
GRAFANA_POD_NAME ?= $(shell kubectl -n istio-system get pod -l app=grafana -o jsonpath='{.items[0].metadata.name}')
JAEGER_POD_NAME=$(shell kubectl -n istio-system get pod -l app=jaeger -o jsonpath='{.items[0].metadata.name}')

.PHONY: get-account
get-account:
	az account show

.PHONY: set-account
set-account:
	az account set -s $(SUBSCRUBTION_ID)

.PHONY: create-cluster
create-cluster:
	az group create --name $(RESOURCE_GROUP) --location $(LOCATION)
	az aks create --resource-group $(RESOURCE_GROUP) --name $(AKS_CLUSTER_NAME) --node-count 3

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
	kubectl apply -f ./samples/hitcounter/

.PHONY: deploy-nodeweb
deploy-nodeweb:
	kubectl apply -f ./samples/nodeweb/k8s

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
