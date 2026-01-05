# Architecture

## Overview
- Spring Boot 3 / Java 21 app (`fifth-app`) packaged via Maven, containerized with a multi-stage Dockerfile (non-root, Temurin 21 JRE).
- Kubernetes deployment (2 replicas) in namespace `devops-demo`, behind a ClusterIP service, optional ingress. Configurable via ConfigMap for `JAVA_OPTS`/profiles.
- CI/CD with GitHub Actions: CI builds/tests/packages and builds the Docker image; CD publishes to GHCR and deploys to the cluster using `kubectl`.
- Observability: Actuator + Micrometer Prometheus registry, Prometheus scrape, Grafana dashboard, alert rules, runbooks.

```
Users -> [Ingress]* -> [Service fifth-app] -> [Pods x2]
                       ^                         |
                       | scrape                  |
                 [Prometheus] <------------------+
                       |
                       v
                   [Grafana]
```
`*` ingress optional; for local use, port-forwarding is typical.

## Runtime Components
- App: Exposes `/api/health`, `/actuator/health`, `/actuator/prometheus`. JVM opts via env (`JAVA_OPTS`). Non-root user in container.
- Service: ClusterIP on port 80 -> container 8080; annotated for Prometheus scrape on `/actuator/prometheus`.
- Probes: Readiness `/actuator/health/readiness`, Liveness `/actuator/health/liveness`.
- Resources: Requests 100m CPU / 256Mi; Limits 500m CPU / 512Mi (tunable).

## CI/CD Flow
- CI (`.github/workflows/ci.yml`): checkout -> Java 21 -> `mvn test` -> `mvn package` -> Docker build. Push to GHCR only on `main` or tags; optional Trivy scan.
- CD (`.github/workflows/cd.yml`): on `main` push -> build & push image to GHCR -> decode kubeconfig secret -> `ci/scripts/deploy-k8s.sh` -> `kubectl set image` -> rollout status.

## Observability
- Metrics: Prometheus scrapes via service annotations. Dashboard JSON in `infra/monitoring/grafana-dashboard.json` (heap, CPU, HTTP RPS; label `application="fifth-app"`).
- Alerts: `infra/monitoring/prometheus-values.yaml` (AppDown, HighErrorRate, HighLatencyP95).
- Runbooks: `docs/runbook.md` for triage steps.

## Local Workflows
- Dev/test: `./mvnw test` / `./mvnw spring-boot:run`.
- Docker: `docker build -t fifth-app:local app` -> `docker run -p 8080:8080 fifth-app:local`.
- Kubernetes: `bash ci/scripts/deploy-k8s.sh` -> `kubectl -n devops-demo port-forward svc/fifth-app 8081:80`.
- Monitoring (Helm): install Prometheus/Grafana per `docs/monitoring-helm.md`; port-forward Prometheus 9090, Grafana 3000.

## Security & Compliance (baseline)
- Non-root runtime image; slim JRE.
- GHCR auth via `GITHUB_TOKEN` in CI/CD; optional Trivy scan.
- Config via ConfigMap (no secrets checked in). Add imagePullSecret if GHCR is private.

## Extensibility
- Add ingress + TLS for shared clusters.
- Enable persistence for Prometheus/Grafana in non-local envs.
- Add HPA (CPU/RPS) and autoscaling policies.
- Add SBOM/signing and SAST/DAST steps to CI.
