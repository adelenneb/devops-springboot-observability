# DevOps Demo Mono-Repo
[![CI](https://github.com/adelenneb/devops-springboot-observability/actions/workflows/ci.yml/badge.svg)](https://github.com/adelenneb/devops-springboot-observability/actions/workflows/ci.yml)
[![CD](https://github.com/adelenneb/devops-springboot-observability/actions/workflows/cd.yml/badge.svg)](https://github.com/adelenneb/devops-springboot-observability/actions/workflows/cd.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Minimal Spring Boot 3 + Java 21 service with Docker/Kubernetes deployment, CI/CD via GitHub Actions, and Prometheus/Grafana monitoring. Tailored for local clusters (kind/minikube) and GHCR publishing.

```
          +-----------+       +---------------+       +-----------+
  Users --|  Ingress  |------>| fifth-app SVC |------>|  Pods x2  |
          +-----------+       +---------------+       +-----------+
                  ^                    |                     |
                  |                    | scrape              |
                  |          +-------------------+           |
                  +----------| Prometheus Server |<----------+
                             +-------------------+
                                       |
                                       v
                               +---------------+
                               |   Grafana     |
                               +---------------+
```

## Repository Layout
- `app/` – Spring Boot app, Maven wrapper, Dockerfile, tests.
- `infra/k8s/` - Namespace, ConfigMap, Deployment, Service, optional Ingress.
- `infra/monitoring/` - Prometheus values, Grafana dashboard JSON.
- `ci/scripts/` - Deploy helper (`deploy-k8s.sh`), CI/CD helpers.
- `.github/workflows/` - CI (build/test/image) and CD (publish/deploy).
- `docs/` - Runbooks and monitoring Helm guide.
- `Makefile` - Common shortcuts (tests, package, docker build/run, k8s deploy/set-image/port-forward, monitoring port-forward).

## Prerequisites
- Docker (and Compose)
- kubectl
- kind or minikube (for local Kubernetes)
- Helm (for monitoring option)
- Make (for the provided shortcuts)

## Local Run
### Direct (no Docker)
```bash
cd app
./mvnw test
./mvnw spring-boot:run
# Health: http://localhost:8080/api/health
# Metrics: http://localhost:8080/actuator/prometheus
```

### Docker
```bash
docker build -t fifth-app:local app
docker run -p 8080:8080 fifth-app:local
```

### Kubernetes (kind/minikube)
```bash
# Apply core manifests
bash ci/scripts/deploy-k8s.sh

# Port-forward app
kubectl -n devops-demo port-forward svc/fifth-app 8080:80
```

## CI/CD (GitHub Actions)
- `ci.yml`: builds/tests Maven project, builds Docker image; pushes to GHCR on `main` and version tags, optional Trivy scan.
- `cd.yml`: on `main` push, builds/pushes image to GHCR and deploys to cluster using `kubectl` (KUBECONFIG_BASE64 secret). Updates deployment image tag and waits for rollout.

## Monitoring
- Prometheus scrapes the app via service annotations on `svc/fifth-app` (target `:8080/actuator/prometheus`); config in `infra/monitoring/prometheus-values.yaml`.
- Grafana dashboard JSON: `infra/monitoring/grafana-dashboard.json` (heap, CPU, HTTP RPS; filters on `application="fifth-app"`).
- Helm install (local): `docs/monitoring-helm.md` has commands; then port-forward Prometheus (`kubectl -n devops-demo port-forward svc/prometheus-server 9090:80`) and Grafana (`kubectl -n devops-demo port-forward svc/grafana 3000:80`). In Grafana, set the Prometheus data source to `http://prometheus-server.devops-demo.svc.cluster.local` (or `http://localhost:9090` if port-forwarded) and import the dashboard JSON.

## Troubleshooting
- Pods: `kubectl -n devops-demo get pods`, `kubectl -n devops-demo logs deploy/fifth-app`.
- Probes: `kubectl -n devops-demo exec deploy/fifth-app -- curl -sf http://localhost:8080/actuator/health`.
- Image: ensure deployment image matches GHCR tag from the latest pipeline.
- Monitoring: check Prometheus Targets; if “connection refused”, ensure service annotations point to port 8080 and app is running. Set Grafana’s data source URL correctly (in-cluster service or port-forward).

## Roadmap (Nice-to-have)
- Add ingress manifest with TLS for shared clusters.
- Enable persistent volumes for Prometheus/Grafana.
- Add autoscaling (HPA) based on CPU/RPS.
- Extend security scanning (SAST/DAST) and SBOM uploads.
- Add synthetic checks and smoke tests post-deploy.

