#!/usr/bin/env bash
set -euo pipefail

MANIFEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../infra/k8s" && pwd)"

kubectl apply -f "${MANIFEST_DIR}/namespace.yaml"
kubectl apply -f "${MANIFEST_DIR}/configmap.yaml"
kubectl apply -f "${MANIFEST_DIR}/deployment.yaml"
kubectl apply -f "${MANIFEST_DIR}/service.yaml"

kubectl rollout status deployment/fifth-app -n devops-demo
