DOCKER_IMAGE_FOO ?=micro-backend-foo
DOCKER_IMAGE_BAR ?=micro-backend-bar
VERSION1 ?=v1
VERSION2 ?=v2

.PHONY: build-backend
build-backend:
	docker build --no-cache -t melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION1) ./backend
	docker build --no-cache --build-arg service_name=foo --build-arg version=v2 -t melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION2) ./backend
	docker build --no-cache --build-arg service_name=bar -t melvinlee/$(DOCKER_IMAGE_BAR):$(VERSION1) ./backend

.PHONY: push-backend
push-backend:
	docker push melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION1)
	docker push melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION2)
	docker push melvinlee/$(DOCKER_IMAGE_BAR):$(VERSION1)

.PHONY: build-frontend
build-frontend:
	docker build --no-cache -t melvinlee/micro-frontend:$(VERSION1) ./frontend
	docker build --no-cache --build-arg version=v2 -t melvinlee/micro-frontend:$(VERSION2) ./frontend

.PHONY: push-frontend
push-frontend:
	docker push melvinlee/micro-frontend:$(VERSION1)
	docker push melvinlee/micro-frontend:$(VERSION2)

.PHONY: deploy
deploy:
	kubectl apply -f ./kube/backend-foo-v1.yaml
	kubectl apply -f ./kube/backend-bar-v1.yaml
	kubectl apply -f ./kube/frontend.yaml
	kubectl apply -f ./kube/config-frontend.yaml

.PHONY: cleanup
cleanup:
	kubectl delete -f ./kube/

.PHONY: status
status:
	kubectl get deploy,pod,svc