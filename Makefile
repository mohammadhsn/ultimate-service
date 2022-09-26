SHELL := /bin/bash

VERSION := $(git rev-parse --short HEAD)

# Go
go-run:
	go run -ldflags "-X main.build=failed" main.go


# Docker
IMAGE := sales-service:latest

docker-build:
	docker image build \
		-t $(IMAGE) \
		-f zarf/docker/Dockerfile \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.


# Kind
CLUSTER := ultimate-cluster

kind-up:
	kind create cluster --name $(CLUSTER) --config zarf/k8s/kind/kind-config.yaml
	kubectl config set-context --current --namespace=sales-system

kind-down:
	kind delete cluster --name $(CLUSTER)

kind-load:
	kind load docker-image $(IMAGE) --name $(CLUSTER)

# Kubernetes
k8s-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch

sales-restart:
	kubectl rollout restart deployment sales-pod

sales-apply:
	cat zarf/k8s/base/sales-pod.yaml | kubectl apply -f -

sales-status:
	kubectl get pods -o wide --watch

sales-logs:
	kubectl logs \
		-l app=sales \
		--all-containers=true \
		--tail 100 -f
