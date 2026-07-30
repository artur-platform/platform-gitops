#!/usr/bin/env bash
set -euo pipefail

cluster_name="artur-platform"
argocd_version="v3.4.2"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

for command_name in docker kind kubectl; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command is missing: $command_name" >&2
    exit 1
  fi
done

if ! kind get clusters | grep -qx "$cluster_name"; then
  kind create cluster --config "$repo_root/kind/cluster.yaml" --wait 120s
fi

kubectl config use-context "kind-${cluster_name}" >/dev/null
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply --server-side --force-conflicts -n argocd \
  -f "https://raw.githubusercontent.com/argoproj/argo-cd/${argocd_version}/manifests/install.yaml"
kubectl rollout status deployment/argocd-server -n argocd --timeout=180s
kubectl apply -f "$repo_root/bootstrap/root-application.yaml"

echo "Cluster is ready. Run scripts/port-forward.sh in another terminal."
