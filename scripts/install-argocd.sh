#!/usr/bin/env bash
set -euo pipefail

echo "Argo CD install starter"

for cli in kubectl helm; do
  if ! command -v "$cli" >/dev/null 2>&1; then
    echo "Missing required CLI: $cli"
    exit 1
  fi
done

echo "Review the target cluster context before installing:"
kubectl config current-context || true
echo "Example install command:"
echo "kubectl create namespace argocd"
echo "kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml"
echo "No cluster mutations were performed by this starter script."
