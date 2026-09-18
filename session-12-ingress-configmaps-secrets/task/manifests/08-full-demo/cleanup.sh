#!/usr/bin/env bash
# Session 12 - tear everything down again.
set -uo pipefail
NS=s12-lab
kubectl delete ingress    --all -n "$NS" --ignore-not-found
kubectl delete deployment --all -n "$NS" --ignore-not-found
kubectl delete service    --all -n "$NS" --ignore-not-found
kubectl delete configmap yatri-app-config -n "$NS" --ignore-not-found
kubectl delete secret    yatri-db-secret campus-tls-cert -n "$NS" --ignore-not-found
echo "==> Remaining in $NS:"
kubectl get all -n "$NS"
