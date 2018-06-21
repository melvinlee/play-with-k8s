# HitCounter

## Deploy the app to Kubernetes

Deploy Frontend

```sh
$ kubectl apply -f ./k8s/hitcounter-frontend-deployment.yaml
```

Deploy Frontend Service

```sh
$ kubectl apply -f ./k8s/hitcounter-frontend-service.yaml
```

Deploy Backend(Redis Master)

```sh
$ kubectl apply -f ./k8s/hitcounter-redis-master-deployment.yaml
```

Deploy Backend Service(Redis Master)

```sh
$ kubectl apply -f ./k8s/hitcounter-redis-master-service.yaml
```

## Verify

Check Pods and Services status

```sh
$ kubectl get deploy,pod,svc
```

and the expected result:

```sh
NAME                                            DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deployment.extensions/hitcounter-frontend       1         1         1            1           5m
deployment.extensions/hitcounter-redis-master   1         1         1            1           15s

NAME                                          READY     STATUS    RESTARTS   AGE
pod/hitcounter-frontend-8487f7b6b6-642v9      1/1       Running   0          5m
pod/hitcounter-redis-master-c6595fd97-pnwtg   1/1       Running   0          15s

NAME                              TYPE           CLUSTER-IP    EXTERNAL-IP    PORT(S)        AGE
service/hitcounter-frontend       LoadBalancer   10.0.49.175   168.62.166.3   80:32731/TCP   5m
service/hitcounter-redis-master   ClusterIP      10.0.14.242   <none>         6379/TCP       11s
service/kubernetes                ClusterIP      10.0.0.1      <none>         443/TCP        11m
```

## Testing

Determining the ingress IP and ports for a load balancer

```sh
$ export INGRESS_HOST=$(kubectl get svc/hitcounter-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Now, hiting the app

```sh
$ curl $INGRESS_HOST
```