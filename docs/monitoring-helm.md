# Monitoring with Helm (Prometheus + Grafana)

This is a simple setup for local clusters (kind/minikube) using Helm charts.

## Prereqs
- Helm installed locally
- Cluster context pointing at your local cluster

## Prometheus (scrapes the Spring Boot app)
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install prometheus prometheus-community/prometheus \
  --namespace devops-demo --create-namespace \
  -f infra/monitoring/prometheus-values.yaml
```
- Scrapes the app via service annotations on `svc/fifth-app` (`:8080/actuator/prometheus`).

## Grafana
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install grafana grafana/grafana \
  --namespace devops-demo \
  --set adminUser=admin \
  --set adminPassword=admin \
  --set service.type=ClusterIP
```
- Port-forward to access:
```bash
kubectl -n devops-demo port-forward svc/grafana 3000:80
```
- Data source URL (in-cluster): `http://prometheus-server.devops-demo.svc.cluster.local`
- If using port-forward, use `http://localhost:9090` and keep `kubectl -n devops-demo port-forward svc/prometheus-server 9090:80` running.
- Log in (admin/admin) and import `infra/monitoring/grafana-dashboard.json`.

## Notes
- Prometheus persistence is disabled for local use.
- For non-local clusters, switch services to `LoadBalancer` or use an ingress and enable storage.
