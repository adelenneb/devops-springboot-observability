#!/usr/bin/env bash
set -euo pipefail

MANIFEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../infra/k8s" && pwd)"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/namespace.yaml"
kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/configmap.yaml"
kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/deployment.yaml"
kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/service.yaml"

if [[ -n "${REGISTRY:-}" && -n "${IMAGE_NAME:-}" && -n "${IMAGE_TAG:-}" ]]; then
  kubectl --kubeconfig "${KUBECONFIG}" set image deployment/fifth-app fifth-app=${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} -n devops-demo
fi

kubectl --kubeconfig "${KUBECONFIG}" rollout status deployment/fifth-app -n devops-demo --timeout=180s || {
  echo "Rollout failed or timed out; collecting diagnostics..."
  kubectl --kubeconfig "${KUBECONFIG}" get pods -n devops-demo -o wide || true
  kubectl --kubeconfig "${KUBECONFIG}" describe deployment/fifth-app -n devops-demo || true
  kubectl --kubeconfig "${KUBECONFIG}" describe pods -l app=fifth-app -n devops-demo || true
  kubectl --kubeconfig "${KUBECONFIG}" get events -n devops-demo --sort-by=.metadata.creationTimestamp | tail -n 50 || true
  exit 1
}
