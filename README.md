# play-with-k8s

## Create Cluster

In this quickstart, an AKS cluster is deployed using the Azure CLI.

```bash
$ make create-cluster get-credential deploy-metricserver get-node
```

### Horizontal Pod Autoscaler

The API requires __**metrics server**__ to be deployed in the cluster. Otherwise it will be not available. 

### Metrics Server

Metrics Server is a cluster-wide aggregator of resource usage data.

## Deploy Istio

Istio: an open platform to connect, manage, and secure microservices. Istio provides an easy way to create a network of deployed services with load balancing, service-to-service authentication, monitoring, and more, __**without requiring any changes in service code**__.

```bash
$ make deploy-istio deploy-istio-dashboard
```

## Delete Cluster

```bash
$ make delete-cluster
```