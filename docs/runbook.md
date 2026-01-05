# Runbook: App Alerts

## AppDown
- Check if pods are running: `kubectl -n devops-demo get pods`
- Inspect recent pod events: `kubectl -n devops-demo describe deploy/fifth-app`
- Verify service endpoints: `kubectl -n devops-demo get endpoints fifth-app`
- Confirm liveness/readiness probes succeed: `kubectl -n devops-demo exec deploy/fifth-app -- curl -sf http://localhost:8080/actuator/health`
- If image pull failing, verify the image tag in the deployment matches GHCR and credentials are valid.
- Verify Prometheus target is UP: Prometheus UI → Status → Targets → `kubernetes-service-endpoints` → `fifth-app`.

## HighErrorRate
- Check recent logs for 5xx causes: `kubectl -n devops-demo logs deploy/fifth-app --tail=200`
- Inspect app metrics: `http://localhost:8080/actuator/prometheus` (via port-forward) to see http_server_requests counters (label `application="fifth-app"`).
- Confirm downstream dependencies (DB, APIs) are reachable; test with curl from a pod.
- If configuration related, review ConfigMap and environment values: `kubectl -n devops-demo get cm fifth-app-config -o yaml`.

## HighLatencyP95
- Inspect pod resource usage: `kubectl -n devops-demo top pod -l app=fifth-app`
- Check recent GC/CPU metrics in Prometheus/Grafana (heap usage, process_cpu_usage).
- Review request volume and any long-running endpoints; consider scaling replicas or tightening resource limits/requests.
- Validate network path/service discovery: `kubectl -n devops-demo exec deploy/fifth-app -- curl -w '%{time_total}\n' -o /dev/null -s http://localhost:8080/api/health`.
