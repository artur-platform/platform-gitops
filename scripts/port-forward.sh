#!/usr/bin/env bash
set -euo pipefail

cleanup() {
  jobs -p | xargs -r kill 2>/dev/null || true
}
trap cleanup EXIT INT TERM

kubectl -n argocd port-forward service/argocd-server 8080:443 >/tmp/artur-argocd-port-forward.log 2>&1 &
kubectl -n observability port-forward service/prometheus 9090:9090 >/tmp/artur-prometheus-port-forward.log 2>&1 &

echo "Argo CD:   https://localhost:8080"
echo "Prometheus: http://localhost:9090"
echo "Press Ctrl-C to stop port forwarding."
wait
