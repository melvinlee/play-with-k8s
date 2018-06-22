DOCKER_IMAGE_FOO ?=micro-backend-foo
DOCKER_IMAGE_BAR ?=micro-backend-bar
VERSION1 ?=v1
VERSION2 ?=v2

.PHONY: build-backend
build-backend:
	docker build --no-cache -t melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION1) ./backend
	docker build --no-cache --build-arg service_name=bar -t melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION2) ./backend
	docker build --no-cache --build-arg service_name=bar -t melvinlee/$(DOCKER_IMAGE_BAR):$(VERSION1) ./backend

.PHONY: push-backend
push-backend:
	docker push melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION1)
	docker push melvinlee/$(DOCKER_IMAGE_FOO):$(VERSION2)
	docker push melvinlee/$(DOCKER_IMAGE_BAR):$(VERSION1)

.PHONY: build-frontend
build-frontend:
	docker build --no-cache -t melvinlee/micro-frontend:$(VERSION1) ./frontend

.PHONY: push-frontend
push-frontend:
	docker push melvinlee/micro-frontend:$(VERSION1)