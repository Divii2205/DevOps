#!/usr/bin/env bash
# Session 12 - end-to-end deployment of the whole stack into namespace s12-lab.
set -euo pipefail
NS=s12-lab
HERE="$(cd "$(dirname "$0")/.." && pwd)"

kubectl get namespace "$NS" >/dev/null 2>&1 || kubectl create namespace "$NS"

echo "==> ConfigMap + Secret"
kubectl apply -f "$HERE/01-configmap/app-config.yaml"
kubectl apply -f "$HERE/02-secret/db-secret.yaml"

echo "==> Workloads (multi-document YAML: Deployment --- Service)"
kubectl apply -f "$HERE/03-combined/backend.yaml"
kubectl apply -f "$HERE/03-combined/frontend.yaml"

echo "==> Ingress routing"
kubectl apply -f "$HERE/04-ingress-path/ingress-path.yaml"
kubectl apply -f "$HERE/06-ingress-hybrid/ingress-hybrid.yaml"

echo "==> Waiting for rollouts"
kubectl rollout status deployment/yatri-backend  -n "$NS" --timeout=180s
kubectl rollout status deployment/yatri-frontend -n "$NS" --timeout=180s

echo "==> Stack:"
kubectl get configmap,secret,deploy,svc,ingress,pods -n "$NS" -l app=yatri-app
