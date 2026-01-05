# Portfolio Highlights

## Why This Project Matters
- Demonstrates end-to-end ownership: from application code to containerization, CI/CD, Kubernetes delivery, and observability.
- Relevant to ESN/international roles where standardization, repeatability, and multi-environment deployments are critical.
- Showcases pragmatic defaults for local-first development (kind/minikube) that mirror cloud-native practices (GHCR, GitHub Actions, Prometheus/Grafana).

## Skills Demonstrated
- CI/CD: GitHub Actions for build/test, image build, GHCR publish, and Kubernetes deploy with rollout gates.
- Containers: Multi-stage Dockerfile, JVM tuning via env, non-root runtime, .dockerignore hygiene.
- Kubernetes: Namespaced manifests, probes, ConfigMap-driven config, resource requests/limits, optional ingress, deploy script.
- Monitoring/Alerting: Micrometer Prometheus endpoint, Prometheus scrape via service annotations, Grafana dashboard JSON (application label), alert rules, runbook.
- GitOps-friendly layout: Clear separation of app/infra/ci/docs, helper scripts for idempotent deploys.
- Automation helpers: Makefile targets for tests, packaging, Docker build/run, k8s deploy, port-forwarding.

## Interview Talking Points
- Tradeoffs: slim JRE vs. full JDK in runtime images; ClusterIP + port-forward for local vs. ingress for shared; simple probes and fixed resources vs. autoscaling/HPA.
- Security: non-root containers, minimal base images, GHCR auth via `GITHUB_TOKEN`, Trivy optional scan; note future work for SBOM, image signing, and network policies.
- Rollout strategies: current Recreate/RollingUpdate via `kubectl rollout`; can extend to canary/blue-green with labels and multiple deployments or use GitOps tooling (ArgoCD/Flux).
- Observability: standardized metric tags (`application`), Prometheus alerts for availability/error/latency, dashboard panels for JVM/HTTP; can evolve to logs/traces and SLOs.
- Reliability: health/readiness probes aligned to `/actuator/health`, resource requests/limits to avoid noisy neighbors, idempotent deploy script for repeatable ops.
- Delivery experience: GHCR integration, service annotations for metrics, Helm-based monitoring option for rapid local parity.
