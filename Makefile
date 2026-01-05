APP_DIR ?= app
IMAGE_NAME ?= fifth-app:local
K8S_NS ?= devops-demo

.PHONY: help test package docker-build docker-run k8s-deploy k8s-set-image k8s-port-forward monitoring-port-forward

help:
	@echo "Common targets:"
	@echo "  test                 - Run Maven tests"
	@echo "  package              - Package the app (jar)"
	@echo "  docker-build         - Build local Docker image"
	@echo "  docker-run           - Run the image locally on port 8080"
	@echo "  k8s-deploy           - Apply k8s manifests"
	@echo "  k8s-set-image        - Point k8s deployment to IMAGE_NAME"
	@echo "  k8s-port-forward     - Port-forward app service to localhost:8081"
	@echo "  monitoring-port-forward - Port-forward Prometheus (9090) and Grafana (3000)"

test:
	cd $(APP_DIR) && ./mvnw -B test

package:
	cd $(APP_DIR) && ./mvnw -B package

docker-build:
	docker build -t $(IMAGE_NAME) $(APP_DIR)

docker-run:
	docker run --rm -p 8080:8080 $(IMAGE_NAME)

k8s-deploy:
	bash ci/scripts/deploy-k8s.sh

k8s-set-image:
	kubectl -n $(K8S_NS) set image deployment/fifth-app fifth-app=$(IMAGE_NAME)
	kubectl -n $(K8S_NS) rollout status deployment/fifth-app

k8s-port-forward:
	kubectl -n $(K8S_NS) port-forward svc/fifth-app 8081:80

monitoring-port-forward:
	kubectl -n $(K8S_NS) port-forward svc/prometheus-server 9090:80 & \
	kubectl -n $(K8S_NS) port-forward svc/grafana 3000:80

