#!/usr/bin/env bash
set -euo pipefail

MANIFEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../infra/k8s" && pwd)"
export KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/namespace.yaml"
kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/configmap.yaml"
kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/deployment.yaml"
kubectl --kubeconfig "${KUBECONFIG}" apply -f "${MANIFEST_DIR}/service.yaml"

kubectl --kubeconfig "${KUBECONFIG}" rollout status deployment/fifth-app -n devops-demo
