# Microservice Samples

## Quickstart

Let's deploy all the services in this stack.

```sh
$ kubectl apply -f ./kube/backend-foo-v1.yaml
$ kubectl apply -f ./kube/backend-bar-v1.yaml
$ kubectl apply -f ./kube/frontend.yaml
$ kubectl apply -f ./kube/config-frontend.yaml
```

Next, verify the deployments status

```sh
$ kubectl get deploy,pod,svc
```

## Sending traffic

Let's send traffic to the frontend services. However, we need to determining the ingress IP and ports for a load balancer

```sh
$ export INGRESS_HOST=$(kubectl get svc/micro-frontend -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Now, let's sending http traffic to the services (i am using [httpie](https://httpie.org/))

```sh
$ http $INGRESS_HOST
```

and the expected result:

```sh
HTTP/1.1 200 OK
Connection: keep-alive
Content-Length: 155
Content-Type: text/plain; charset=utf-8
Date: Mon, 09 Jul 2018 02:15:22 GMT

frontend:v1 (micro-frontend-5ddb9f45c6-g7ttq)
0.093secs - http://micro-backend-foo -> backend-foo:v1
0.002secs - http://micro-backend-bar -> backend-bar:v1
```

## Scale

Let's scale the frontend microservies from 2 to 5 instances

```sh
$ kubectl scale deploy/micro-frontend --replicas=5
deployment.extensions "micro-frontend" scaled
```

Verify the pod count

```sh
$ kubectl get deploy/micro-frontend
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
micro-frontend   5         5         5            3           1h
```